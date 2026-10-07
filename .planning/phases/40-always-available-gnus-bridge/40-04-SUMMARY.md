---
phase: 40-always-available-gnus-bridge
plan: 04
subsystem: ui
provides: [submit-time Bridge gate refusal, entry contract tests, phase gate]
affects: []
actuals: {tokens: 9000, tasks: 3, commits: 3}
requirements-completed: [BRDG-08, BRDG-04, BRDG-01]
status: complete
---

# Phase 40 Plan 04: Submit-time refusal and the phase gate
BridgeScreen re-reads the gate before bridgeOut and refuses with a "Can't bridge" toast carrying the gate's caption. The coin-page entry's semantics, variants, contrast and one-line fit are pinned by tests, and the whole phase is green.

## What changed
- `_submitBridge` reads `liveBridgeGate(context)` before `isSubmitting` is set. A closed gate, or no `BridgeGateCubit` in scope, toasts the caption and returns: no burn, no receipt, no "Bridging…". The burn call is unchanged.
- `bridge_submit_gate_test.dart` drives the real screen: control (enabled, one burn), earning flipped with no stream event (zero burns, toast), no gate cubit (zero burns, "Checking your GNUS balance.").
- `bridge_entry_test.dart` gained the contract group; every case passed with no change to `bridge_entry.dart`.
- Two files this phase created were stored CRLF (plan 03 cubit test and summary); converted to LF.

## Phase gate (all run on this branch)
- `flutter test`: `00:48 +2465 ~6: All tests passed!` (baseline 2341 / 6 skipped).
- `flutter analyze lib test`: `No issues found!`, exit 0. `dart format --set-exit-if-changed lib test`: 0 changed, exit 0.
- `check_brace_style.sh`, `check_raw_colors.sh`, `check_no_new_key_logging.sh --scan-tree` (bridge files): exit 0.
- ID gate over `bd7af2ee..HEAD`: 0. Co-Authored-By/Claude in commit messages: 0. Non-LF files created: 0 after the fix.
- `isGnusWalletConnected` in navigation and the coin page: none. Compute, wallet_overview and assets diff: empty. `kDashboardPanelSlotHeight = 340`: 1. New `GoRoute(` in router: 0.
- `flutter build windows --debug`: `√ Built build\windows\x64\runner\Debug\genius_wallet.exe`.

## Deviations from plan
- Tracer gate: the launching orchestrator required the whole phase in one run, so the tracer verify (3 tests, green) was re-run and the plan continued. The CRLF commit is outside the plan; it satisfies the plan's own `i/lf` check.

## Open gap
- Live walk on Windows, GNUS coin page, dark and light: earning wallet enables Bridge; switching earning shows "Switching earning. Try again soon.", then "Only the earning wallet can bridge." Blocked while testnet is stuck. A switch landing after bridgeOut is called is not caught.

## Commits
- 0a5605f2 fix(40-04): Bridge refuses a submit the gate no longer allows
- f838436a test(40-04): pin the Bridge entry semantics, variants, contrast and one-line fit
- 73a128ce chore(40-04): store the cubit test and plan 03 summary with LF line endings

## Self-Check: PASSED
