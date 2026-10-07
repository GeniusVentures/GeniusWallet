---
phase: 40-always-available-gnus-bridge
plan: 02
subsystem: ui
provides: [coin page route with no start-up-address gate]
affects: [40-03, 40-04]
actuals: {tokens: 3200, tasks: 2, commits: 2}
requirements-completed: [BRDG-07]
status: complete
---

# Phase 40 Plan 02: Remove the start-up-address route gate

The /token-info route builds TokenInfoScreen directly. Nothing compares the start-up node address to the Selected wallet any more, so the earning gate is the only Bridge gate.

## What changed
- `router.dart`: StreamBuilder and its comment removed; unused `sgnus_connection.dart` import dropped.
- `TokenInfoScreen`: connection-flag field and constructor parameter deleted.
- Four test harnesses and the `_coinPage` helper lost the flag; the 360px dark/light loop now also finds the caption 'Checking your GNUS balance.' once.
- Comments in `token_info_args.dart`, `markets_screen.dart`, `dashboard_screen.dart` and two tests reworded to the current fact. The legacy map branch and its "must not be deleted" warning stay.

## Verification
- `flutter test test/tokens/ test/banxa/ test/dashboard/bridge/`: `+348: All tests passed!` (after each task).
- `flutter analyze lib test`: exit 0, "No issues found!".
- `dart format --set-exit-if-changed` on touched files and `check_brace_style.sh`: exit 0.
- ID gate on both staged diffs: 0. `isGnusWalletConnected` in router/screen: 0. `getSGNUSConnectionStream` in router: 0.
- `git diff --stat` from 8393c505 over wallet_overview.dart, compute_state.dart, app_bloc.dart: empty.
- Not run: full `flutter test` suite.

## Deviations from plan
- Tracer gate: interactive runs stop for human verify after Task 1. The launching orchestrator required the whole phase in one run, so I re-ran the tracer verify (green) and continued. The human check stays open.
- The plan's grep `derives that` over lib and test still hits `lib/squid_router/swap_screen.dart:453` ("never re-derives that decision"). Unrelated wording, left alone.
- Dropped the `T-hsb-01` and quick-task ids from the comments I edited.

## Commits
- 9c63b3a5 refactor(40-02): drop the start-up-address gate from the coin page route
- f67ae942 docs(40-02): comments agree the earning gate is the only Bridge gate

## Self-Check: PASSED
