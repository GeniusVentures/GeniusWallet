---
phase: 37-child-write-operations-pending-model
plan: 04
subsystem: ui
tags: [flutter_bloc, pending-state]
requires:
  - phase: 37-child-write-operations-pending-model
    provides: "ChildOperationsCubit registry, ensureRunningAs, main picker (plans 01-03)"
provides:
  - "move kind on the registry: child-side, resolves only off both mains agreeing"
  - "startMove dialog flow, wired to the This account card"
  - "SDKAccountRow.lockedReason, wired from the registry in account_drawer"
affects: []
key-files:
  modified: [lib/child_wallets/child_operations_cubit.dart, child_operation_dialogs.dart, child_operation_status.dart, child_wallets_screen.dart, lib/account/sdk_account_manager.dart, lib/account/account_drawer.dart, test/child_wallets/child_operations_cubit_test.dart, child_operation_actions_test.dart, test/account/sdk_account_rows_test.dart]
key-decisions:
  - "The cubit-level fake API's getChildRegistrations() ignored its mainAddress argument -- fine for every single-main kind, but move reads two mains that must disagree. Added a per-main override map (registrationEntriesByMain/registrationsResultByMain) rather than rewriting the fake's shape"
  - "provider's context.watch<ChildOperationsCubit?>() finds a plain BlocProvider<ChildOperationsCubit> because InheritedProvider<T> always registers itself as _InheritedProviderScope<T?> internally -- confirmed against provider 6.1.5+1's own source before relying on it"
requirements-completed: [CHILD-08, SWT-06]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 37 Plan 04: Child write operations & pending model Summary

**Move joins the other five child operations, resolving only once both the old and new main agree, and the switcher locks away from an account with its own pending operation.**

## Accomplishments
- `move` (child-side, sends the new main + empty metadata) resolves only when an OK read of the old main drops the account AND an OK read of the new main lists it -- either half alone, or a failed read of either main, stays pending to "Not confirmed yet" at 2:00
- `startMove`: picker excludes this account and its current main, confirms with the exact copy plus a `GWWarningNote`, destructive "Move"; the card's status line keeps reading the old main until the real signal lands
- `SDKAccountRow.lockedReason`: dims a non-selected row, adds a lock glyph and tooltip, and a tap toasts the reason instead of switching; the selected row and every "Sending from" row are untouched
- `account_drawer` reads the registry via `context.watch<ChildOperationsCubit?>()`, so a host without one (every pre-existing test) renders unlocked exactly as before

## Verification
No plan deviations. Full suite: 2133 passed / 5 skipped / 0 failed (2119 baseline + 14 new). `flutter analyze lib test`: 0 issues. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on all four commits.

**ROADMAP.md deviation (carried from 37-03):** `roadmap.update-plan-progress` still no-ops on this ROADMAP -- hand-edited Phase 37's checkbox, `Plans:` line and Progress row instead; STATE.md hand-edited per plan instruction.
