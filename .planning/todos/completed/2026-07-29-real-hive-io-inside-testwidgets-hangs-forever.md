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

## Status right now

**`lib/account/` from plan 14-04 is committed; this test is NOT.** It is left untracked in the
working tree at `test/account/account_drawer_show_test.dart` rather than deleted, because the test
logic itself looks right - it is the harness interaction that is broken, and the file is worth
keeping as the starting point for the fix.

That means **plan 14-04's `AccountDrawer` extraction ships without its own test.** That is a real
gap, stated plainly rather than papered over. The three bisection probes that produced this diagnosis
were written by 14-04's executor and are preserved outside `test/` in the session scratchpad under
`14-04-probes/`.

Plan 14-04 also never produced a SUMMARY - its agent stalled twice on backgrounded test runs.
