---
phase: 34-account-linking
fixed_at: 2026-09-29T00:00:00Z
review_path: .planning/phases/34-account-linking/34-REVIEW.md
iteration: 1
findings_in_scope: 4
fixed: 3
skipped: 1
status: partial
---

# Phase 34: Code Review Fix Report

**Fixed at:** 2026-09-29
**Source review:** .planning/phases/34-account-linking/34-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope (critical + warning): 4
- Fixed: 3 (CR-01, WR-02, WR-03)
- Skipped: 1 (WR-01)
- Also added: the IN-02 regression tests, requested alongside CR-01

## Fixed Issues

### CR-01: The last-wallet guard counted watch-only wallets, so an SDK-account delete could remove the user's only signing wallet

**Files modified:** `lib/bloc/app_bloc.dart`, `test/account/sdk_account_delete_coupling_test.dart`, `test/components/wallet_information_delete_test.dart`, `lib/account/account_drawer.dart`, `lib/components/wallet_information.dart`
**Commits:** `e0ac429e`, `aae37584`
**Applied fix:** `AppBloc.canDeleteWallet` now excludes `WalletType.tracking` rows from the "another wallet would remain" count when the wallet actually being deleted is a key-holding wallet (the default, and the case `sdkDeleteBlock` always hits since `linkedWallet` already excludes tracking/sgnus rows). A first pass excluded tracking wallets unconditionally, which over-blocked deleting the watch-only row itself in the pinned `deleting the watch-only row of a key wallet address keeps the key wallet selected` test — removing a watch-only row never removes a key, so it only needs another row of any kind left. A `deletingWatchOnly` parameter (threaded through from `DeleteWallet.watchOnly` / the row's own `walletType` at each of the three direct-delete call sites: the bloc's own guard, the drawer, and `wallet_information`'s "More" menu) makes the rule branch correctly. `sdkDeleteBlock`'s call site is unchanged (defaults to the key-wallet branch, which is always correct for it).

Includes the IN-02 regression tests requested alongside this fix: a `[keyWallet, trackingWallet]` case added to `AppBloc.sdkDeleteBlock`'s test group (expects `SDKDeleteBlock.lastWallet`), and a matching `[main, trackingWallet]` case added to `wallet_information_delete_test.dart` (expects "You must keep at least one wallet." and no delete).

### WR-02: Unhandled `StateError` if the bloc closes while a delete/payout confirmation is waiting on `bloc.stream`

**Files modified:** `lib/account/sdk_account_manager.dart`
**Commit:** `fe7426a8`
**Applied fix:** Added `orElse: () => false` to the delete-confirmation's `firstWhere`, and replaced the payout dialog's bare `.first` with `.firstWhere((_) => true, orElse: () => null)`. Both now degrade to their existing `.timeout(...)` fallback value instead of throwing `StateError` if the bloc closes before the awaited condition is met.

### WR-03: `addWalletFromSecret`'s "already exists" path could persist the wrong wallet name into a new SDK link

**Files modified:** `packages/genius_api/lib/src/genius_api.dart`
**Commit:** `839d6f31`
**Applied fix:** The existing `getStoredKeys()` lookup used to compute `alreadyExists` is now reused to find the matching key; when a match exists, `storedKey`'s name is built from that key's own `.name()` instead of always falling back to `_defaultWalletName(address)`. Any SDK link created from this "already exists" path now carries the wallet's real, possibly user-renamed name from the start.

## Skipped Issues

### WR-01: Backfill silently retries a real, mutating SDK call for every unresolved wallet on every future wallet add

**File:** `packages/genius_api/lib/src/genius_api.dart:386-388, 427-468, 494-526`
**Reason:** Both fix options in the review conflict with this phase's locked decisions or require a larger redesign than a targeted review fix should carry:

- **Restricting `linkExistingSDKAccounts()`'s call sites to SDK-startup only** would break D-07 ("Wallets can be added while the SDK node is down. Their SDK account and link are created once the node starts."). The call inside `_registerWallet` is what gives *older, still-unlinked* wallets their backfill pass the moment a new wallet's registration is what actually brings the node up — if `_onInitializeSDK`'s own pass already ran and no-op'd while the node was still down, nothing else re-triggers it. 34-03-PLAN.md's own verification step (`grep -c "linkExistingSDKAccounts()" ... prints at least 2`) pins both call sites as intentional.
- **A persisted "attempted and failed" marker** is the correct fix, but doing it without introducing a new bug requires `backfillLinks` (a pure, `@visibleForTesting` function pinned by 7 existing unit tests, including one that specifically asserts an early multi-address abort starves every wallet *after* it in the same pass) to report which wallets were actually retried versus never reached this round — otherwise a naive "mark everything not linked as attempted" would wrongly skip wallets that were never given a fair first try once an earlier, unrelated wallet's abort clears up. That is a contract change to a pinned pure function, not a targeted fix.

The underlying worry (re-adding an already-known key might not be a true no-op on some SDK build) was already evaluated at plan time: D-14 explicitly required verifying re-add idempotency before backfill shipped ("If it creates a duplicate, skip backfill entirely"), and the code's own `ponytail:` comment (`packages/genius_api/lib/src/genius_api.dart:470-472`) already documents the "stays 'Unlinked' forever" outcome as a known, accepted ceiling with a stated upgrade path (an SDK call that derives an address without registering it). Recommend filing this as a follow-up todo rather than forcing a fix here.

---

_Fixed: 2026-09-29_
_Fixer: Claude (gsd-code-fixer)_
_Iteration: 1_
