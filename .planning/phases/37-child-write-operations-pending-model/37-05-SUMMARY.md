---
phase: 37-child-write-operations-pending-model
plan: 05
subsystem: ui
tags: [flutter_bloc, dev-tools, pending-state]
requires:
  - phase: 37-child-write-operations-pending-model
    provides: "ChildOperationsCubit registry (plans 01-04)"
provides:
  - "DevMockChildWallets write simulation: confirm/timeout/fail write modes, per-main simulated add/remove, balance delta"
  - "ChildOperationsCubit's gated seam: submitWrite plus mocked registrations/balances behind kDebugMode && kShowDevTools"
  - "three dev-bubble buttons: Writes confirm / Writes time out / Writes fail"
affects: []
actuals: {tokens: 9400, tasks: 2, commits: 3}
tech-stack:
  patterns: ["fake GeniusApi delegating to a dev mock to prove a gate compiled out under flutter test"]
key-files:
  modified: [lib/dev/dev_mock_child_wallets.dart, lib/child_wallets/child_operations_cubit.dart, lib/dev/dev_tools_bubble.dart, test/dev/dev_mock_child_wallets_test.dart]
key-decisions:
  - "Preset fixtures now scope to the running account (or any main when none selected) before layering simulated writes -- previously any queried main got the same fixture set, which move's two-main resolution needs to tell apart"
requirements-completed: [VER-01]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 37 Plan 05: Child write operations & pending model Summary

**Every write outcome (confirm / time out / fail) is now reachable from the dev bubble for all six child operations, closing the rest of VER-01.**

## Accomplishments
- `DevMockChildWallets` gains `DevChildWalletsWriteMode` (confirm/timeout/fail) and `submitWrite`, applying a confirmed write 3 s later per kind; `clear()` cancels scheduled writes without resetting the mode; `mainBalanceMinions` fixed at 1000 GNUS
- `ChildOperationsCubit`'s reads and writes route through the mock behind `kDebugMode && kShowDevTools` whenever a preset is armed -- no real SDK write is ever reachable while one is
- Three dev-bubble buttons (Writes confirm / Writes time out / Writes fail) between Node not running and Clear

## Task Commits
1. Coverage for simulated writes - `3328bfc9` (test)
2. Simulate writes behind the dev gate (GREEN) - `42dc0320` (feat)
3. Write-mode buttons in the dev bubble; phase gate - `0167d4cf` (feat)

## Verification
No plan deviations. Full suite: 2149 passed / 5 skipped / 0 failed (2133 baseline + 16 new). `flutter analyze lib test`: 0 issues. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on all three commits. Windows debug build compiled (not run).

**Pending, manual, end-of-milestone only (not attempted here):** VER-02's live-testnet walk of all six operations, and the dev-bubble walk of the three write modes against an open Child wallets screen.

**ROADMAP.md/STATE.md deviation (carried forward):** `roadmap.update-plan-progress` still no-ops on this ROADMAP -- hand-edited Phase 37's checkbox, `Plans:` line and Progress row; STATE.md hand-edited per plan instruction (Plan line + `progress.completed_plans`).

## Self-Check: PASSED
All modified files present on disk; all three commit hashes found in git log.
