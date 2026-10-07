---
phase: 37-child-write-operations-pending-model
plan: 03
subsystem: ui
tags: [flutter_bloc, pending-state]
requires:
  - phase: 37-child-write-operations-pending-model
    provides: "ChildOperationsCubit registry, ensureRunningAs guard (plans 01-02)"
provides:
  - "ChildWalletsCubit.parentMain: the running account's own registration position"
  - "The 'This account' card: Child of {main} / Not registered as a child, Detach, Register"
  - "detach and register kinds on the registry; child_main_picker_dialog.dart"
affects: [37-04, 37-05]
key-files:
  created: [lib/child_wallets/child_main_picker_dialog.dart, test/child_wallets/child_main_picker_test.dart]
  modified: [lib/child_wallets/child_wallets_cubit.dart, child_wallets_screen.dart, child_operations_cubit.dart, child_operation_dialogs.dart, child_operation_status.dart, test/child_wallets/child_wallets_screen_test.dart, child_operations_cubit_test.dart, child_operation_actions_test.dart]
key-decisions:
  - "_listedUnder returns bool? (null on a non-OK read) rather than a pessimistic bool, since revoke/detach's resolve signal (not listed) and register's (listed) have opposite polarity -- a single true/false default would have been correct for one and wrong for the other"
  - "showMainPicker resolves the registry on the caller's own context and passes nameFor down, rather than reading Provider inside the dialog widget -- a dialog route sits beside home in the tree, not under it"
  - "registry.nameFor (raw sdkAccountName, literal 'Unlinked') added alongside labelFor (short-address fallback) so the picker's row title matches the UI-SPEC's 'Unlinked' copy without duplicating the subtitle's address"
requirements-completed: [CHILD-03, CHILD-07]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 37 Plan 03: Child write operations & pending model Summary

**The running account's own registration position gets a home on the child-wallets screen, with detach and a from-scratch register flow through a new main picker.**

## Accomplishments
- `ChildWalletsCubit.parentMain`: the first other own account whose OK, case-insensitive registrations read lists the running account as a child; the "This account" card shows "Child of {main}" + Detach, or "Not registered as a child" -- identity alone renders on a disconnected or failed read
- `detach` (child-side, empty metadata, resolves off the old main's list) and `register` (child-side, chosen main + empty metadata, resolves once that main lists the account) join the registry; both share `_listedUnder`'s OK/not-OK/listed tri-state rather than reusing revoke's pessimistic bool
- `child_main_picker_dialog.dart`: `isSdkAddress` (`0x` + 128 hex, any case) and `showMainPicker` -- the user's other own accounts in a height-bounded, scrolled list, a manual-entry fallback validated against the same shape and the excluded set, Back keeps the earlier pick

## Verification
No plan deviations. Full suite: 2119 passed / 5 skipped / 0 failed (2079 baseline + 40 new). `flutter analyze lib test`: 0 issues. Format/brace/raw-colour/key-logging scripts clean. ID-identifier gate: 0 matches on all four commits.

**ROADMAP.md deviation:** `roadmap.update-plan-progress` no-ops on this repo's ROADMAP.md -- `editProgressTableSlice` scopes to the FIRST `## Progress` heading in the file (no `</details>` markers exist to bound milestones), which is the v1.0/v2.0 table, not Phase 37's own `## Progress` table further down. Hand-edited Phase 37's checkbox, `Plans:` line and Progress row instead; STATE.md hand-edited per plan instruction.
