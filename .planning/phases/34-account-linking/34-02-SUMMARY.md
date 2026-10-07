---
phase: 34-account-linking
plan: 02
subsystem: ui
provides:
  - SDK Accounts rows titled by AppBloc.sdkAccountName, address+status subtitle
  - WalletSDKBadge / walletSDKBadge() - "SDK" / "SDK PENDING" wallet-menu badges
  - Address+type row selection in account_drawer.dart (was name-only)
  - ComputeState.notDefaultAccount (renamed from notLinked, D-20)
actuals: {tokens: 11000, tasks: 3, commits: 4}
key-files:
  modified: [lib/account/sdk_account_manager.dart, lib/account/account_drawer.dart, lib/dashboard/compute/compute_state.dart, lib/dashboard/compute/compute_panel.dart, lib/components/job/submit_job_button.dart]
  created: [test/account/sdk_account_rows_test.dart]
key-decisions:
  - "Balance text gets a 48px ConstrainedBox+ellipsis only when an SDK badge shows (Rule 1: the new pill overflowed the row otherwise)"
requirements-completed: []
duration: ~35min
completed: 2026-09-29
status: complete
---

# Phase 34 Plan 2: Show the link on both menus Summary

**SDK rows say whose wallet they are (or "Unlinked"/"wallet removed"); linked wallets carry an "SDK"/"SDK PENDING" badge; the compute panel drops "linked" for "Default account" (D-20).**

## Accomplishments
- `_buildAccountRow` titles rows via `AppBloc.sdkAccountName`; subtitle is address + " · Active processing account" / " · Default account"
- `walletSDKBadge()` + shared `_RowBadge` (3rd use, promoted from "ACTIVE ON NODE") mark linked/pending own wallets
- Row selection matches lowercased address + walletType, not name, so a same-named SDK row is never checked alongside it
- `ComputeState.notLinked` → `notDefaultAccount` ("Not the default account"); `submit_job_button.dart`'s `isSelectedWalletLinkedToSGNUS` → `isDefaultAccountWallet`

## Task Commits
1. SDK row naming - `c4a2980f`  2. Wallet-menu badges - `1404028b`  3. D-20 rename - `2fd85c34`  4. format fix - `da26cfcb`

## Deviations
**[Rule 1 - Bug]** SDK badge overflowed the drawer row at panel width; balance text now gets a bounded/ellipsised width only when a badge shows (`account_drawer.dart`, `1404028b`).

Self-Check: PASSED - all files and 4 commits verified present. Full `flutter test`: 1913 passed/5 skipped/0 failed. `flutter analyze lib test`: 0 issues.

*Phase: 34-account-linking — completed 2026-09-29*
