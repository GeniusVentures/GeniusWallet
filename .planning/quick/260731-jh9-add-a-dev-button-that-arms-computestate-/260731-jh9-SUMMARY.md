---
phase: quick-260731-jh9
plan: 01
subsystem: dev-fixtures
tags: [compute-panel, dev-tools, sgnus, submit-job]
status: complete
dependency-graph:
  requires: [260731-hrn]
  provides: [sgnus-ready-fixture, stale-completion-override]
  affects: [lib/dev/dev_mock_sgnus.dart, lib/bloc/app_bloc.dart, lib/dev/dev_tools_bubble.dart, test/dev/dev_mock_sgnus_test.dart]
decisions:
  - "armReady() is a new DevMockSgnus method, not a fifth ad-hoc button handler - it composes the four existing arm/clear calls plus one new one-shot flag, matching the shape every other dev fixture method already has."
  - "A dedicated stale-completion one-shot flag (mirroring consumeInitRelease's idiom) is required because copyWith cannot null processingCompletedAt - clearing jobCompleteOverride alone is not enough if a real Job done press landed inside the last 60 seconds."
metrics:
  duration: "~35m"
  completed: 2026-07-31
---

# Quick Task 260731-jh9: A dev button that arms ComputeState.ready and holds it Summary

New `SGNUS ready` button in the dev bubble's MOCK section forces `ComputeState.ready` and holds it
there against the 3s init poll and against any fixture armed earlier in the session, closing the
gap that made `New processing job` permanently unclickable on a machine whose real SGNUS node
never finishes initialising.

## The gap, confirmed against source before writing anything

`resolveComputeState` (`compute_state.dart:154-156`) returns `startingUp` whenever
`initPercentage != null && initPercentage < 1.0`, checked above `ready`. Neither existing button
was ever a route to `ready`: `SGNUS idle` only arms `processing: false`, and on Jakub's machine
the real init poll (every 3s, `_onInitializationStatusTicked`, `app_bloc.dart:396`) keeps writing
back a percentage stuck around 0.52, clobbering `idle` to `startingUp` within seconds. `SGNUS init`
arms `startingUp` on purpose. This is a genuine regression from quick task 260731-hrn: before that
task, `SGNUS init` armed `armInitPercentage(37)`, and `37.0 < 1.0` reads `false`, so the panel fell
through to `ready` by accident - Jakub's only (buggy) route. Fixing the fixture to the field's real
0.0-1.0 scale (`0.37`) was correct and removed that accidental route deliberately, which is exactly
what this task restores on purpose.

## What was built

**`DevMockSgnus.armReady()`** (`lib/dev/dev_mock_sgnus.dart`) - composes four existing calls plus
one new one-shot flag: `arm(processing: false)`, `armInitPercentage(1.0)`,
`clearFeedUnavailable()`, `clearJobComplete()`, and sets `_staleCompletionPending = true`. A doc
comment on the method records why a dedicated `ready` fixture exists at all: `ready` is the only
`ComputeState` whose CTA is clickable (`ComputeStatusView.ctaEnabled`), so it is the gateway to
the entire job flow, and it was previously reachable only through the 37-vs-0.37 bug.

**The stale-completion one-shot flag** (`_staleCompletionPending` /
`staleCompletionPending` / `consumeStaleCompletion()`, same idiom as the existing
`consumeInitRelease()`) exists because `copyWith` cannot null `AppState.processingCompletedAt`
(documented on the field itself). Clearing `jobCompleteOverride` alone is not enough: if a real
`Job done` press landed inside the last 60 seconds, `sinceJobFinished <= jobCompleteWindow` would
still resolve to `jobComplete`, not `ready`, despite every other rung being satisfied. Consuming
this flag forces `processingCompletedAt` to `DateTime.now().subtract(jobCompleteWindow * 2)` on
the very next tick - comfortably outside the 60-second window - so `SGNUS ready` cannot be masked
by a fixture pressed moments earlier.

**`app_bloc.dart`'s `_onProcessingStatusTicked`** dev branch: `mock.staleCompletionPending` added
to the branch's entry guard (defensive, mirroring why `initReleasePending` is already there);
`mock.consumeStaleCompletion()` consumed at the top alongside `releasedInit`; the general (final)
emit gained `processingCompletedAt: staleCompletion ? DateTime.now().subtract(jobCompleteWindow *
2) : null` - `null` in the ordinary case leaves the existing value untouched, same as every other
field in that emit.

**`SGNUS ready` button** (`lib/dev/dev_tools_bubble.dart`, MOCK section, placed directly after
`SGNUS idle`): follows the identical four-step load-bearing order every SGNUS button already uses
- `armReady()`, then `updateConnection(...)`, then `injectMockWallet(...)`, then dispatch
`ProcessingStatusTicked()` - followed by a toast stating plainly the fixture is STICKY and
released by `Clear`. The tooltip explains the distinction from both buttons Jakub pressed today
expecting this: `SGNUS idle` only clears `isProcessing` and can still read `startingUp` on a
mid-init node; `SGNUS init` deliberately forces `startingUp`, the opposite of this button.

**`Clear` button**: no changes needed. Every override `armReady()` touches is already released by
the existing `clear()` / `clearInitPercentage()` / `clearFeedUnavailable()` / `clearJobComplete()`
calls in the Clear handler. The one-shot stale-completion flag self-consumes on the tick the
button's own press dispatches, so it never survives long enough to need a separate release.

## Every rung above `ready`, walked and confirmed

1. `hasSelectedWallet` - `injectMockWallet` sets `WalletDetailsState.selectedWallet`.
2. `isNodeConnected` - `updateConnection(DevMockSgnus.instance.connection)`, `isConnected: true`.
3. `nodeWalletAddress == selectedWalletAddress` - both already `DevMockSgnus.address` on the
   existing fixture wallet/connection pair (unchanged - this was already correct).
4. `isProcessingUnavailable` - `clearFeedUnavailable()` releases a stray `Feed dead` press.
5. `initPercentage >= 1.0` - `armInitPercentage(1.0)`; the dev guard in
   `_onInitializationStatusTicked` (added in an earlier quick task today) stops the real 3s poll
   from ever reaching the FFI read while the override is armed, so it cannot be clobbered back.
6. `isProcessing` false - `arm(processing: false)`.
7. No recent job completion inside `jobCompleteWindow` - `clearJobComplete()` releases a stray
   `Job done` override, and the stale-completion flag forces `processingCompletedAt` past the
   60-second window even if a real `Job done` press landed moments before this button.

## Test added

`test/dev/dev_mock_sgnus_test.dart` gained three new groups, mirroring the file's existing style:
- `armReady - forces every override ComputeState.ready needs` (5 tests): each override's value
  after `armReady()`, including clearing a previously-armed `feedUnavailableOverride` and
  `jobCompleteOverride`.
- `consumeStaleCompletion - one-shot semantics` (2 tests): false with nothing pending, true once
  then false after `armReady()`.
- `the SGNUS ready button resolves to ready` (2 tests): feeds the fixture's own values through
  `resolveComputeState` directly and asserts `ComputeState.ready` - one with `sinceJobFinished:
  jobCompleteWindow * 2` (proving the stale-completion defense actually works against a
  still-in-window timestamp), one with `sinceJobFinished: null` (the no-prior-job case). This is
  the pure-Dart guarantee the brief asked for - the state resolver is pure, so this is where the
  guarantee belongs, not a widget test.

`setUp`/`tearDown` gained a `consumeStaleCompletion()` drain, matching the file's existing
`consumeInitRelease()` drain, so no test starts with a stray pending flag left by a previous one.

## Deviations from Plan

None. The plan (written from the brief before implementation) was followed exactly: `armReady()`,
the stale-completion one-shot flag, the guard addition, the general-emit addition, the button, and
the tests all match what was planned. No architectural changes were needed (Rule 4 never
triggered) - the stale-completion mechanism extends the existing sticky-override pattern
(`initPercentageOverride`, `feedUnavailableOverride`, `jobCompleteOverride` already established
this shape in 260731-hrn) rather than introducing a new one. No auth gates were encountered.

## Known Stubs

None introduced by this task.

## Threat Flags

None - the entire change stays inside the `kDebugMode && kShowDevTools` dev-fixture surface. No
new network endpoint, auth path, file access pattern, or schema change was introduced.

## Self-Check: PASSED

Files confirmed present and modified:
- `lib/dev/dev_mock_sgnus.dart` - FOUND (`armReady()`, `staleCompletionPending`,
  `consumeStaleCompletion()`)
- `lib/bloc/app_bloc.dart` - FOUND (guard extended, `staleCompletion` consumed, general emit
  extended)
- `lib/dev/dev_tools_bubble.dart` - FOUND (`SGNUS ready` button, toast, tooltip, comment)
- `test/dev/dev_mock_sgnus_test.dart` - FOUND (3 new groups, 9 new tests)

No commits were made (per this task's constraints - the tree remains dirty, matching every other
uncommitted quick task already on this branch today). `git status --short` confirms
`lib/dev/dev_mock_sgnus.dart`, `lib/bloc/app_bloc.dart`, and `lib/dev/dev_tools_bubble.dart` show
as modified, and `test/dev/dev_mock_sgnus_test.dart` remains untracked (it was already untracked
from 260731-hrn before this task began - unchanged by this task's own constraint of not touching
files it does not own, this one it does own and edited further).

## Verification (real numbers)

- `flutter analyze`: **No issues found! (ran in 12.3s)**
- `flutter test`: **902/902 passing** (893 baseline + 9 new: 5 in `armReady` group, 2 in
  `consumeStaleCompletion` group, 2 in `the SGNUS ready button resolves to ready` group). Two
  pre-existing console-only `RenderFlex overflowed` warnings from `gw_page_header.dart:170` and
  `token_info_screen.dart:907` printed during the run - not failures, not touched by this task
  (the second is explicitly noted as another quick task's in-progress work in 260731-hrn's own
  summary).
- `tool/check_brace_style.sh`: exit 0.
- `tool/check_raw_colors.sh`: exit 0.

All four gates pass.

## What Jakub should press, and what he should see

Open the dev bubble, expand **MOCK**, and press **`SGNUS ready`**.

The compute panel on the wallet overview should immediately read **"Ready" / "Node online -
waiting for work" / "idle"**, with a green (success) status dot, and the **`New processing job`**
button should be enabled and clickable for the first time. This holds indefinitely - the 3s init
poll cannot claw it back, and pressing `Job done`, `Feed dead`, or waiting out any prior fixture
first will not change the outcome. Press `Clear` in MOCK to release it back to the real SDK.
