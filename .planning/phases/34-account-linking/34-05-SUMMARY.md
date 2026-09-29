---
phase: 34-account-linking
plan: 05
subsystem: api
provides:
  - SDKDeleteBlock enum, AppBloc.sdkDeleteBlock, AppBloc._deleteWallet - one shared delete rule
  - LocalWalletStorage.removeSDKAccountLink / GeniusApi.removeSDKAccountLink
actuals: {tokens: 13700, tasks: 3, commits: 3}
key-files:
  modified: [packages/local_secure_storage/lib/src/local_secure_storage_base.dart, packages/genius_api/lib/src/genius_api.dart, lib/bloc/app_bloc.dart, lib/account/sdk_account_manager.dart, lib/components/wallet_information.dart, test/local_wallet_storage_test.dart, test/account/sdk_account_delete_coupling_test.dart, test/components/wallet_information_delete_test.dart, test/account/account_drawer_show_test.dart, test/account/sdk_start_account_delete_test.dart]
key-decisions:
  - "requirements mark-complete skipped for LINK-01/LINK-02: orchestrator closes them at phase end"
  - "VER-02 (live-testnet walk) stays pending, recorded here, not attempted this plan"
requirements-completed: []
duration: ~50min
completed: 2026-09-29
status: complete
---

# Phase 34 Plan 5: Delete coupling Summary

**A wallet delete keeps its SDK account and freezes its name; an SDK-account delete takes its linked wallet with it after a confirmation naming it; both wallet-delete buttons now go through one AppBloc rule.**

## Accomplishments
- `deleteWallet` freezes the wallet's current name onto every link before deleting the entry (D-08, D-09); watch-only deletes never touch links. New `removeSDKAccountLink` (storage + API).
- `AppBloc.sdkDeleteBlock` refuses a delete for the default account, an active wallet, or the last wallet (D-11); `_deleteWallet` is shared between a plain wallet delete and an SDK-account delete's wallet removal (D-10). `DeleteWallet` still never touches an SDK account (D-08).
- `_confirmDeleteSDKAccount` names the linked wallet in its confirmation and shows the refusal reason instead of confirming silently; `wallet_information.dart`'s delete now dispatches `DeleteWallet` through `AppBloc` instead of the API directly (D-12).

## Task Commits
1. Wallet delete freezes link name - `690e3825`  2. One delete rule, SDK delete takes its wallet - `91c077a6`  3. UI names the wallet, both paths via AppBloc - `c42ba875`

## Deviations
**[Rule 3 - Blocking]** `sdk_start_account_delete_test.dart`'s fake API needed a no-op `removeSDKAccountLink` override - a successful SDK delete now calls it unconditionally (`91c077a6`). Task 1's grep check (expects 1) reads 2 post-format since the passthrough wraps across two lines; the method exists once and works correctly.

Full `flutter test`: 1943 passed/5 skipped/0 failed. `flutter analyze lib test`: 0 issues. Format/brace/key-logging gates clean. Windows debug compile gate built successfully, never run.

Self-Check: PASSED - all 10 files and 3 commits verified present.

*Phase: 34-account-linking — completed 2026-09-29*
