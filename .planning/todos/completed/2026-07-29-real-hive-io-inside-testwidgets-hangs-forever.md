---
created: 2026-07-29T00:00:00.000Z
title: Real Hive I/O inside a `testWidgets` body hangs the runner forever, with zero output
area: testing
severity: blocks-a-test
files:
  - test/account/account_drawer_show_test.dart
  - test/dashboard/transaction_row_test.dart
  - lib/account/account_drawer.dart
---

## STATUS: RESOLVED 2026-07-30 (plan 14-04 closeout)

`test/account/account_drawer_show_test.dart` is written, committed and PASSING - 4/4 cases,
under a second, with the full suite still green (726/0). The `tester.runAsync` fix this todo
recommended turned out NOT to be sufficient on its own in practice: wrapping the tap that
invokes `AccountDrawer.show`, then wrapping `AccountDrawer.show`'s own real Hive write, then
wrapping `AppBloc.close()`, then wrapping `Hive.close()`/`deleteBoxFromDisk` each in turn just
moved the same zero-output hang one call further down the chain - `tester.pump`/`tester.tap`
turn out to be unusable from inside `runAsync`'s callback at all (frame scheduling depends on
the `FakeAsync` clock, which `runAsync`'s real zone does not drive), so the tap that starts the
interaction and the wait for its real I/O to land can never share one `runAsync` block, and
disk I/O invoked from a normal tap is real I/O whichever later call tries to rescue it.

**The actual fix: hive_ce's own in-memory backend.** `Hive.openBox(name, bytes:
Uint8List(0))` selects `StorageBackendMemory`
(`hive_ce-2.19.3/lib/src/backend/storage_backend_memory.dart`), whose `writeFrames`/`close`
both return `Future.value()` - no real disk I/O at all, so there is no real async gap for
`FakeAsync` to strand `AccountDrawer.show`'s write on. `AccountDrawer.show` still calls the
exact same public `Hive.box(walletBoxName).put(...)` it does in production; only the TEST'S
own box-opening call chooses the backend, via `bytes:`, hive_ce's own public parameter on the
same `Hive.openBox` API - not a production seam. `deleteFromDisk()` throws `UnsupportedError`
on this backend by hive_ce's own design, so teardown closes the box rather than deleting it.

One further, unrelated hang the same investigation turned up: `AppBloc.close()` alone (no
Hive involved at all) also hangs under plain `FakeAsync` - it starts a real 3s poll `Timer` in
its constructor and awaits its internal event-stream settling on `close()`. That one DOES need
`tester.runAsync(() => appBloc.close())` and works fine wrapped that way, since it involves no
widget pumping inside the wrapped call.

The `Directory.systemTemp.createTemp`/`Hive.init`/temp-dir-cleanup machinery this todo
originally called for is gone entirely from the fix - the memory backend needs none of it.

## What happens

`flutter test test/account/account_drawer_show_test.dart` **never finishes and never prints
anything** - not even the usual `00:00 +0: <test name>` line. Measured at 180s, 400s and beyond, on a
clean tree, with nothing else running. It also hangs any bare `flutter test`, which is how three
separate agents lost time to it on 2026-07-29.

Zero output is the tell. A hanging *test* still prints its own name first; printing nothing means the
runner never gets that far.

## The cause, bisected

Two probes settled it:

1. **The import graph is fine.** A test that does nothing but
   `import 'package:genius_wallet/account/account_drawer.dart'` and assert `AccountDrawer.show` is
   non-null loads and passes in **under a second**. So it is not `GeniusApi`'s native `dlopen`, not
   GoRouter, not the drawer.
2. **Real Hive I/O in a widget test is the hang.** A stripped probe doing only
   `Directory.systemTemp.createTemp` → `Hive.init` → `Hive.openBox` in `setUp`, and
   `deleteBoxFromDisk` → `Hive.close` in `tearDown`, hangs identically.

And the discriminator that names it:

| File | Hive pattern | Wrapper | Result |
|---|---|---|---|
| `test/dashboard/transaction_row_test.dart:160-176` | `createTemp` + `Hive.init` in `setUp`, `deleteBoxFromDisk` + `close` in `tearDown` | plain **`test()`** | **passes**, and has done for months |
| `test/account/account_drawer_show_test.dart:129-146` | the same pattern, near-identical code | **`testWidgets()`** | **hangs forever** |

`testWidgets` runs its body inside `flutter_test`'s **`FakeAsync` zone**. Real filesystem I/O never
completes there, because nothing advances the real clock or pumps the real event loop - the await
simply never returns. `test()` has no such zone, which is why the older file has never had a problem.

## The fix, when someone picks this up

Any real I/O inside a `testWidgets` must go through **`tester.runAsync(() async { ... })`**, which
steps outside the fake zone. That includes `Directory.systemTemp.createTemp`, `Hive.openBox`,
`Hive.deleteBoxFromDisk` and `Hive.close` - **all four**, not just the box open.

`setUp`/`tearDown` for a `testWidgets` share that zone and have no `tester`, so the Hive lifecycle
cannot stay where it is. Either move it into the test bodies behind `runAsync`, or drop real Hive and
assert the persistence some other way.

**Why real Hive is hard to avoid here:** `AccountDrawer.show` writes the selection itself
(`lib/account/account_drawer.dart:70`, `Hive.box(walletBoxName).put(...)`), deliberately - the doc
comment at `:36-38` says the write lives inside the entry point precisely so no caller can forget it.
So any test that taps a row reaches Hive whether it wants to or not. A seam would have to be
introduced in production code to test this without a real box.

## Status right now (superseded by the RESOLVED note above)

**`lib/account/` from plan 14-04 landed in `21a7f4f`; this test now ships alongside it as of
plan 14-04's closeout (2026-07-30).** The paragraphs below are left as-written for the
historical record of what the gap looked like before the fix.

Plan 14-04 also never produced a SUMMARY at the time - its agent stalled twice on backgrounded
test runs. `14-04-SUMMARY.md` is written as part of this closeout.
