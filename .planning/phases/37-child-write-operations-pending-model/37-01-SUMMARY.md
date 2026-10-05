---
phase: 37-child-write-operations-pending-model
plan: 01
subsystem: ui
tags: [flutter_bloc, bigint, ffi, pending-state]
requires:
  - phase: 36-child-wallet-bindings-read-only-view
    provides: "ChildWalletsCubit/ChildWalletsScreen, GeniusApi.fundChildGnus/getChildBalanceAll/getMinionsBalance"
provides:
  - "ChildOperationsCubit: app-level registry (submit/resolve/isPending/hasPendingFrom/latestFor), parseGnusAmount"
  - "Fund dialog, pending/notConfirmed badge with Check again, resolved toasts"
  - "GWRowBadge promoted from account_drawer's _RowBadge; _ChildActionMenuItem lock pattern"
affects: [37-02, 37-03, 37-04, 37-05]
key-files:
  created: [lib/child_wallets/child_operations_cubit.dart, lib/child_wallets/child_operation_dialogs.dart, lib/child_wallets/child_operation_status.dart, lib/components/data/gw_row_badge.dart, test/child_wallets/child_operations_cubit_test.dart, test/child_wallets/child_operation_actions_test.dart]
  modified: [lib/account/account_drawer.dart, lib/child_wallets/child_wallets_screen.dart, lib/main.dart, test/child_wallets/child_wallets_screen_test.dart]
key-decisions:
  - "The row's erroneous Navigator.pop() before opening the Fund dialog (copied from a drawer-route pattern that doesn't apply here) was removed; MenuAnchor already closes itself on selection"
  - "notConfirmed+Check again render via Wrap, not Row, so the badge and button drop to a second line instead of overflowing a narrow row"
requirements-completed: [CHILD-04]
duration: n/a (interactive session)
completed: 2026-09-29
status: complete
---

# Phase 37 Plan 01: Child write operations & pending model Summary

**Fund a child end to end -- row menu to Fund dialog to the SDK to a pending badge to a resolved toast -- through one app-level ChildOperationsCubit every later write reuses.**

## Accomplishments
- `ChildOperationsCubit`: submit()/resolve() around `fundChildGnus`, a balance-delta resolve signal, a 2-minute `childOperationTimeout` to "Not confirmed yet", and `isPending`/`hasPendingFrom` locks that never count a timed-out op
- `parseGnusAmount`: exact-BigInt validation reusing `toBaseUnits`, the full message table (empty, unparseable, zero, over-6-decimals, over-balance)
- Fund dialog, pending/not-confirmed `ChildOperationBadge` with "Check again", root-level `ChildOperationToasts`, and a locked, tooltipped Fund menu item via the new `_ChildActionMenuItem`
- `GWRowBadge` promoted from `account_drawer.dart`'s `_RowBadge`; the registry provided in `main.dart` above the router

## Verification
No deviations beyond the two auto-fixes noted in key-decisions (Rule 1: removed a stray `Navigator.pop()` causing a broken RED test; Rule 1: switched a `Row` to `Wrap` fixing a real render overflow). Full suite: 2058 passed / 5 skipped / 0 failed (2034 baseline + 24 new). `flutter analyze lib test`: 0 issues. Format/brace/raw-colour scripts clean. ID-identifier gate: 0 matches on all three commits.
