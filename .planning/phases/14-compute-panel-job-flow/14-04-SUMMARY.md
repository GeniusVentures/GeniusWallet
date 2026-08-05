---
phase: 14-compute-panel-job-flow
plan: 04
subsystem: ui
tags: [dart, flutter, hive, bloc, testing, account-drawer]

# Dependency graph
requires:
  - phase: 14-01
    provides: "ComputeState/viewForComputeState pure resolver this phase's panel is built on (unrelated to this plan's own scope, but the phase's baseline-of-record)"
provides:
  - "AccountDrawer.show(context) - the public entry point plan 14-08's compute-panel switch-wallet affordance needs, verified callable from a bare, non-AccountDropdownSelector context"
  - "test/account/account_drawer_show_test.dart - 4 testWidgets cases proving the return value, the WalletDetailsCubit selection, the Hive persistence write and the any-surface guard"
  - "The in-memory-Hive-backend fix for real-Hive-I/O-hangs-forever-in-testWidgets, recorded in the resolved todo, reusable by any future testWidgets that needs a live Hive box"
affects: [14-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Hive.openBox(name, bytes: Uint8List(0)) selects hive_ce's StorageBackendMemory for a testWidgets harness that needs a REAL, live Hive box with zero real disk I/O - no tester.runAsync gymnastics needed for the Hive calls themselves"
    - "A bloc/cubit with a real polling Timer in its constructor (AppBloc) still needs tester.runAsync(() => bloc.close()) specifically for the close() call, independent of any Hive concern"

key-files:
  created:
    - test/account/account_drawer_show_test.dart
    - .planning/phases/14-compute-panel-job-flow/14-04-SUMMARY.md
  modified:
    - .planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md (moved from pending/, resolution recorded)

key-decisions:
  - "This plan's lib/ work (AccountDrawer.show, the account_dropdown_selector.dart reduction, AccountAvatar's move) already shipped under commit 21a7f4f - a squashed, multi-plan commit whose message never mentions 14-04, which is why git log --grep=14-04 finds nothing. Verified present and correct at HEAD rather than re-implemented: the public entry, the Hive write living inside show(), and account_dropdown_selector.dart's repointed call are all exactly as 14-04-PLAN.md's Task 1/2 specify."
  - "The real Hive I/O hang (recorded in the 2026-07-29 todo, which killed three prior agent attempts) needed more than the todo's own tester.runAsync suggestion. tester.pump/tester.tap cannot be called from inside runAsync's callback at all - frame scheduling depends on the FakeAsync clock, which runAsync's real zone does not drive. Wrapping the tap, then the write, then AppBloc.close(), then Hive.close()/deleteBoxFromDisk each in turn just moved the same zero-output hang to the next real I/O call. The actual fix is hive_ce's own in-memory backend (Hive.openBox(bytes: Uint8List(0)) -> StorageBackendMemory), which has no real disk I/O for FakeAsync to strand AccountDrawer.show's write on."
  - "AppBloc.close() needed its own, independent tester.runAsync wrap - proven via an isolated probe test with zero Hive/widget interaction. AppBloc's constructor starts a real 3s poll Timer (_startInitPolling); close() awaits its internal event-stream settling, which hangs under plain FakeAsync exactly like real disk I/O does, for the same reason."
  - "AppBloc is constructed for real (not mocked) in the test harness, via a _SeededAppBloc subclass that emits state.copyWith(wallets: ...) directly in its constructor body, bypassing LoadWallets (which reaches Hive boxes this test does not open and the real SGNUS merge/account-state path) - the same seeding pattern job_flow_test.dart's _SeededSubmitJobCubit/_SeededGnusCubit already established in this codebase."

patterns-established:
  - "tester.runAsync is for giving a specific real-async call genuine wall-clock time; it is never for wrapping tester.pump/tester.tap themselves."

requirements-completed: [CMP-03, CMP-10]

coverage:
  - id: D1
    description: "Any surface can open the account drawer, not just the top-bar action row - AccountDrawer.show(context) is a public entry point, callable from a bare context that is not AccountDropdownSelector."
    requirement: "CMP-03"
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the guard: a drawer opened from a bare context - one that is not the dropdown selector - still renders its rows"
        status: pass
    human_judgment: false
  - id: D2
    description: "Selecting a wallet from the drawer selects it everywhere (WalletDetailsCubit) and persists (Hive wallet box) across a restart, whoever opened the drawer."
    requirement: "CMP-10"
    verification:
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#opening the drawer from a bare context and tapping a row returns that wallet from show()"
        status: pass
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the selection reaches WalletDetailsCubit, not just the return value"
        status: pass
      - kind: automated_ui
        ref: "test/account/account_drawer_show_test.dart#the persisted selection is written to Hive"
        status: pass
    human_judgment: false
  - id: D3
    description: "The drawer behaves identically regardless of which surface opened it, including its rename and delete affordances (unchanged code move, not re-tested here since it moved verbatim and this file only exercises the row tap / selection path)."
    verification: []
    human_judgment: true
    rationale: "Rename/delete confirm flows moved unchanged per the plan's own instruction (a pure relocation, not a behavior change); this plan's automated tests exercise the selection path only. The <human-check> in 14-04-PLAN.md's own verification section (top-bar rename/delete/persistence-across-restart walk) was never recorded as performed and stays open - not claimed here."

# Metrics
duration: not machine-timed at task granularity - this was a closeout/reconciliation session, not a fresh execution
completed: 2026-07-30
status: complete
---

# Phase 14 Plan 04: Public AccountDrawer entry point Summary

**`AccountDrawer.show(context)` verified working from any surface via a new 4-case `testWidgets` file, closing the standing "real Hive I/O hangs testWidgets forever" gap with hive_ce's in-memory backend - the lib/ work itself shipped days earlier under a differently-worded commit.**

## Performance

- **Completed:** 2026-07-30
- **Tasks:** lib/ work (Tasks 1-2 of 14-04-PLAN.md) already complete at HEAD; this session's own work was the missing test plus reconciliation
- **Files created:** 2 (test file, this SUMMARY)
- **Files modified:** 1 (todo moved pending -> completed with resolution recorded)

## The three must-have truths - one verdict each

1. **"Any surface can open the account drawer, not just the top-bar action row."** SATISFIED. `lib/account/account_drawer.dart:40` exposes `static Future<Wallet?> show(BuildContext context)`. Verified callable from a plain `Builder`'s context - never `AccountDropdownSelector` - by the guard test in this plan's new file. The *second* consumer (the compute panel's `Switch wallet ›` affordance) is explicitly **plan 14-08's** job, not this plan's - `ComputePanel` already takes an `onLinkTap` callback and its host, `lib/components/wallet_overview.dart`, is named in 14-08's `files_modified`. This plan does not wire the compute panel; it proves the entry point it needs already exists and works.
2. **"Selecting a wallet from the drawer selects it everywhere and survives a restart, whoever opened the drawer."** SATISFIED for the in-process half (cubit selection + Hive write), proven by two of this plan's four tests. The Hive write lives inside `show()` itself (`account_drawer.dart:70`, `Hive.box(walletBoxName).put(selectedWalletKey, selected.address)`), by design, so no caller can forget it - the doc comment at `:36-38` says this explicitly. The cross-**restart** half (does the persisted value actually survive an app relaunch) is the `<human-check>` in `14-04-PLAN.md`'s own verification section, and was NOT walked in this session - recorded as an open item below, not claimed.
3. **"The drawer behaves identically regardless of which surface opened it, including its rename and delete affordances."** SATISFIED BY CONSTRUCTION, not re-tested. The rename/delete confirm flows moved into `_AccountDrawerBodyState` verbatim as part of the code move `21a7f4f` already shipped (root-navigator captures preserved, per `14-04-PLAN.md`'s explicit instruction) - this plan's own new tests exercise only the row-tap/selection path, since re-proving an unmodified move was out of this closeout's scope.

## What already shipped (verified, not re-done)

Plan 14-04's `lib/` work landed inside commit `21a7f4f` ("feat(compute): the node's truth leaves a private widget State, and the panel is rebuilt on it"), whose message covers phase 14 plans 01-04 and 07 together and never mentions "14-04" by number - which is why `git log --grep=14-04` finds nothing. Verified present and correct at HEAD (`25ee51a`):

- `lib/account/account_drawer.dart:40` - the public `AccountDrawer.show(context)` entry, with the Hive write and cubit selection living inside it (`:69-70`), exactly as Task 1 specifies.
- `lib/account/account_dropdown_selector.dart:48-61` - `_showAccountDrawer()` reduced to a call to `AccountDrawer.show(context)` plus only the widget-local mirror/callback work, exactly as Task 2 specifies. The moved members (confirm-rename, confirm-delete, row builder, avatar builder) are gone from this file.
- `AccountAvatar` is now a public, shared `StatelessWidget` in `account_drawer.dart`, used by both the drawer's rows and the dropdown selector's collapsed chip.

## What this plan's own session added

- `test/account/account_drawer_show_test.dart` - the file the plan's own Task 2 called for, which its first attempt (2026-07-29) never got to commit because it stalled on the Hive/`FakeAsync` interaction below.
- The resolution of the standing todo `2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md`, moved to `.planning/todos/completed/` with a `## STATUS: RESOLVED` section recording what actually worked (below), leaving the original diagnosis intact as historical record.

## The Hive/`FakeAsync` hang - what the todo's own fix did not cover

The 2026-07-29 todo correctly diagnosed that real Hive I/O inside `testWidgets` hangs forever with zero output, and recommended `tester.runAsync`. In practice that recommendation was not sufficient on its own, and reaching a working test required three more rounds of investigation:

1. **Wrapping only the tap that invokes `AccountDrawer.show`** in `runAsync` let the write start in the real zone, but returning from `runAsync` before the write landed meant the test's own assertions ran too early - the write finished LATE, bleeding into the *next* test as a `ValueNotifier used after being disposed` error and a `Box has already been closed` error.
2. **`tester.pump`/`tester.tap` cannot be called from inside `runAsync`'s callback at all.** Frame scheduling depends on the `FakeAsync` clock, which `runAsync`'s real zone does not drive - a pump call in there simply never returns. This ruled out any design that tries to interleave the widget interaction and the real-I/O wait in one `runAsync` block.
3. **Even after separating them correctly** (tap in `FakeAsync`, then a real wall-clock wait via `runAsync`, then a plain `pump` to flush the now-ready continuation), the SAME hang reappeared one call later at `Hive.close()`/`deleteBoxFromDisk` in teardown, and separately at `AppBloc.close()` (proven via an isolated probe with zero Hive involvement - `AppBloc`'s own constructor-started 3s poll `Timer` makes `close()` hang under plain `FakeAsync` the same way).

**The actual fix:** `Hive.openBox(walletBoxName, bytes: Uint8List(0))` selects hive_ce's own `StorageBackendMemory` (`hive_ce-2.19.3/lib/src/backend/storage_backend_memory.dart`), whose `writeFrames`/`close` both return `Future.value()` - no real disk I/O at all, so there is no real async gap for `FakeAsync` to strand `AccountDrawer.show`'s write on. `AccountDrawer.show` still calls the exact same public `Hive.box(walletBoxName).put(...)` it does in production; only the test's own box-opening call chooses the backend, via `bytes:`, hive_ce's own public parameter on the same `Hive.openBox` API - **not a production seam**, and no `lib/` file was touched to make this test possible. `AppBloc.close()` still needed its own, independent `tester.runAsync(() => appBloc.close())` wrap, unrelated to Hive.

With that fix, all four cases run in well under a second and the full suite (`flutter test --no-pub`, foreground, 900s timeout) passed at **726/0** (722 baseline + 4 new).

## Task Commits

**`21a7f4f`** (pre-existing, verified not re-done) - `lib/account/account_drawer.dart`, `lib/account/account_dropdown_selector.dart`. Shipped under a squashed multi-plan message covering phases 01-04/07.

**`25ee51a`** - `test(14-04): account_drawer_show_test proves the seam, in-memory Hive closes the hang` - `test/account/account_drawer_show_test.dart` (new), `.planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md` (moved from `pending/`, resolution recorded).

**Plan metadata:** this commit (docs: complete plan).

## Files Created/Modified

- `test/account/account_drawer_show_test.dart` - 4 `testWidgets` cases against `AccountDrawer.show`
- `.planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md` - moved from `pending/`, resolution appended

## Decisions Made

See `key-decisions` in the frontmatter. Summary: verified rather than re-implemented the shipped `lib/` work; solved the Hive hang with hive_ce's in-memory backend instead of the `runAsync`-everywhere approach the todo originally recommended; seeded a real `AppBloc`/`WalletDetailsCubit` pair via the codebase's existing `_Seeded*` subclass pattern rather than introducing a mocking library.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] The todo's own recommended fix (`tester.runAsync` around each real-I/O call) does not work as written**
- **Found during:** writing and running the new test file
- **Issue:** Wrapping the tap, then the write, then `close()` calls each in `runAsync` in turn either failed to interleave with required `tester.pump`/`tester.tap` calls, or simply relocated the same zero-output hang to the next real I/O call in the chain.
- **Fix:** Switched the test's own Hive box to hive_ce's in-memory backend (`Hive.openBox(bytes: Uint8List(0))`), eliminating the real disk I/O `FakeAsync` cannot complete, and wrapped only `AppBloc.close()` (a separate, Hive-independent hang) in `runAsync`.
- **Files modified:** `test/account/account_drawer_show_test.dart`
- **Verification:** All 4 cases pass in <1s; full suite 726/0.
- **Committed in:** `25ee51a`

---

**Total deviations:** 1 auto-fixed (Rule 1 - a documented fix that did not actually work once tried).
**Impact on plan:** No scope creep - the fix stays entirely inside the new test file; no production code was touched.

## Issues Encountered

The extensive Hive/`FakeAsync` investigation above. Resolved without a production seam and without leaving the gap unrecorded - the todo now carries the actual working fix for the next agent who needs a live Hive box inside a `testWidgets` test.

## Traceability Gap (recorded, not fixed here)

`14-04-PLAN.md` declares `requirements: [CMP-03, CMP-10]`, but **`.planning/REQUIREMENTS.md` has ZERO `CMP-` ids** - the whole compute-panel requirement family is untracked in that file, the same gap `ORG-01..05` had before Phase 23's closeout wrote them. This is phase 14's closeout work (mirroring Phase 23's pattern), not this plan's - not fabricated here.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- `AccountDrawer.show(context)` is proven callable from any context, with its selection and persistence side effects proven automated. Plan 14-08 can wire the compute panel's `Switch wallet ›` affordance to it with no further groundwork.
- The cross-restart persistence half of truth 2, and the rename/delete-from-either-opener half of truth 3, remain as the `<human-check>` in `14-04-PLAN.md`'s own verification section - not walked this session, not claimed as passed.
- The `2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md` todo is closed with a working, reusable fix - any future `testWidgets` needing a live Hive box can use the same `bytes: Uint8List(0)` pattern without repeating this investigation.

## Self-Check

- `[ -f test/account/account_drawer_show_test.dart ]` → FOUND
- `[ -f .planning/todos/completed/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md ]` → FOUND
- `[ -f .planning/todos/pending/2026-07-29-real-hive-io-inside-testwidgets-hangs-forever.md ]` → MISSING (expected - moved to completed/)
- `git log --oneline --all | grep -q 25ee51a` → FOUND
- `git log --oneline --all | grep -q 21a7f4f` → FOUND
- `flutter test --no-pub test/account/account_drawer_show_test.dart` → 4/4 passed (re-confirmed)

## Self-Check: PASSED

---
*Phase: 14-compute-panel-job-flow*
*Plan: 04*
*Completed: 2026-07-30*
