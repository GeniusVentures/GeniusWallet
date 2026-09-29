---
phase: 37-child-write-operations-pending-model
plan: 02
subsystem: ui
tags: [flutter_bloc, bigint, ffi, pending-state]
requires:
  - phase: 37-child-write-operations-pending-model
    provides: "ChildOperationsCubit registry, Fund dialog, GWRowBadge (plan 01)"
provides:
  - "Recover and revoke kinds on the registry, with their own submit/resolve arms"
  - "Recover and Revoke dialogs/menu items, sharing plan 01's amount dialog"
  - "ensureRunningAs: the switch-and-continue guard every main-side action starts with"
affects: [37-03, 37-04, 37-05]
actuals: {tokens: 13400, tasks: 2, commits: 3}
tech-stack:
  patterns: ["parameterize-not-copy amount dialog", "await-the-real-signal switch confirmation"]
key-files:
  created: [lib/child_wallets/child_operation_switch_dialog.dart, test/child_wallets/child_operation_switch_dialog_test.dart]
  modified: [lib/child_wallets/child_operations_cubit.dart, lib/child_wallets/child_operation_dialogs.dart, lib/child_wallets/child_operation_status.dart, lib/child_wallets/child_wallets_screen.dart, test/child_wallets/child_operations_cubit_test.dart, test/child_wallets/child_operation_actions_test.dart]
key-decisions:
  - "Fund's private amount dialog became a shared _AmountDialog taking kind/title/sentence/payer/primary label, reused by Recover, rather than a copy"
  - "Both tasks touch child_operation_dialogs.dart (Recover/Revoke bodies, then the ensureRunningAs guard wired into all three actions), so the plan's two tdd tasks landed as one test commit and one feat commit rather than a pair per task"
requirements-completed: [CHILD-05, CHILD-06, CHILD-09]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 37 Plan 02: Child write operations & pending model Summary

**Recover and Revoke join Fund on each child row, and every main-side action now guards itself against running as the wrong account before it opens.**

## Accomplishments
- `ChildOperationsCubit`: `recover` caps at the child's own balance and resolves once it falls to baseline minus amount; `revoke` resolves off an OK, case-insensitive registrations read of the main that no longer lists the child, and never resolves on a failed read
- Recover/Revoke dialogs and row-menu items with the exact UI-SPEC copy; Revoke renders in the destructive foreground and each kind locks independently on the same child
- `ensureRunningAs` (new `child_operation_switch_dialog.dart`): a no-op when already running as required, a plain switch dialog otherwise, a refusal while the running account has its own pending op, and a 30s await-the-real-signal wait (not the delete flow's 3s -- the switch runs in a background isolate) before the guarded action opens

## Task Commits
1. Coverage for recover, revoke and the switch guard - `d7543240` (test)
2. Recover, revoke and the switch-and-continue guard (GREEN) - `c43f9c4f` (feat)
3. LF normalization on the new switch-dialog test - `db9b73d2` (fix)

## Verification
No plan deviations. Full suite: 2079 passed / 5 skipped / 0 failed (2058 baseline + 21 new). `flutter analyze lib test`: 0 issues. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on both content commits.

## Self-Check: PASSED
All created files present on disk; all three commit hashes found in git log.
