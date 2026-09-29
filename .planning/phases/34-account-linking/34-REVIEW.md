---
phase: 34-account-linking
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 8
files_reviewed_list:
  - lib/bloc/app_bloc.dart
  - lib/account/account_drawer.dart
  - lib/components/wallet_information.dart
  - lib/account/sdk_account_manager.dart
  - packages/genius_api/lib/src/genius_api.dart
  - test/account/sdk_account_delete_coupling_test.dart
  - test/components/wallet_information_delete_test.dart
  - test/components/wallet_identity_test.dart
findings:
  critical: 0
  warning: 0
  info: 1
  total: 1
status: clean
---

# Phase 34: Code Review Report (Iteration 2)

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 8 (iteration-1 findings' fix sites; scoped to `git diff 555f6f47..HEAD` plus the callers/tests it touches)
**Status:** clean

## Summary

Re-review of the three iteration-1 fix commits (`e0ac429e`, `fe7426a8`,
`839d6f31`) plus the review-fix report's skip decision for WR-01. All three
applied fixes are correct, each closes the finding it targets without
reopening a different gap, and the regression tests added alongside them
exercise the exact scenario each finding described. The rest of the phase
diff (`git diff 616700e6..HEAD`) outside these fix commits is unchanged from
iteration 1 and was already reviewed there; nothing in the iteration-2 diff
touches any other part of that surface. No new bugs, security issues, or
quality regressions were introduced by the fixes themselves.

## Resolved from iteration 1

### CR-01 — Fixed, verified

`AppBloc.canDeleteWallet` now takes a `deletingWatchOnly` parameter
(`lib/bloc/app_bloc.dart:640-655`) and branches: deleting a watch-only row
only needs one other row of any kind (`WalletType.sgnus` excluded, `tracking`
included in the count), deleting a key-holding wallet needs another
key-holding wallet (`sgnus` and `tracking` both excluded). All three call
sites correctly infer the branch from the row actually being deleted:

- `AppBloc._onDeleteWallet` (`app_bloc.dart:670`): `deletingWatchOnly:
  event.watchOnly`, where `DeleteWallet.watchOnly` is the caller-supplied flag
  for which of two same-address rows is targeted.
- `_AccountDrawerBodyState._confirmDeleteWallet`
  (`account_drawer.dart:270-273`): `deletingWatchOnly: wallet.walletType ==
  WalletType.tracking`.
- `WalletInformationState`'s "More → Delete Wallet" handler
  (`wallet_information.dart:245-249`): same pattern.
- `AppBloc.sdkDeleteBlock`'s call to `canDeleteWallet(wallets)`
  (`app_bloc.dart:831`) is intentionally left at the default (`false`) —
  `sdkDeleteBlock` only ever reaches this check for a `linkedWallet`, which
  `linkedWallet` itself guarantees is never `sgnus` or `tracking`
  (`app_bloc.dart:778-784`), so the key-wallet branch is always the correct
  one there.

Traced every combination by hand against the new logic: one key wallet alone
(blocked, both branches), one key + one tracking (deleting the key wallet:
blocked; deleting the tracking row: allowed), two key wallets (either
deletable), one tracking wallet alone (blocked). All match the intended
"never reach zero usable wallets" rule and the fix does not reintroduce the
original over-block regression the fix report describes (deleting a
watch-only row when a key wallet is the only other row remaining) —
confirmed against the pinned `test/components/wallet_identity_test.dart:496`
case, which still exercises `[key, watch]` deleting the watch-only row and
still expects it to succeed with `key` staying selected.

New regression tests directly hit the previously-uncovered gap:
`sdk_account_delete_coupling_test.dart`'s `'a linked account is blocked as
the last wallet even with a watch-only wallet left'` (expects
`SDKDeleteBlock.lastWallet` for `[keyWallet, trackingWallet]`) and
`wallet_information_delete_test.dart`'s `'with a watch-only wallet as the
only other row, the warning shows and nothing is deleted'`. Both match
CR-01's own suggested fix-verification shape from iteration 1.

### WR-02 — Fixed, verified

Both stream waits in `sdk_account_manager.dart` now supply `orElse`:
`_confirmDeleteSDKAccount`'s `.firstWhere((gone) => gone, orElse: () =>
false)` (line 521) and `_showSetPayoutAddressDialog`'s `.firstWhere((_) =>
true, orElse: () => null)` (line 650, replacing the bare `.first`). Both
degrade to their pre-existing `.timeout(...)` fallback value if `bloc.stream`
completes (e.g. `AppBloc.close()`) before the awaited condition is met,
instead of throwing `StateError`. This is the exact fix iteration 1
suggested and it is correct: `Stream.firstWhere` with `orElse` returns the
`orElse` value on stream completion rather than throwing, and the values
chosen (`false` / `null`) are the same values each site's own `onTimeout`
already used, so the two failure modes ("too slow" and "stream ended") now
produce identical, already-handled outcomes.

### WR-03 — Fixed, verified

`addWalletFromSecret` (`genius_api.dart:978-988`) now reuses the
`getStoredKeys()` lookup to find the matching key (`matchingKey`, a `.where`
result) instead of the previous `.any(...)` boolean-only check, and derives
`name` from `matchingKey.first.name()` when `alreadyExists` is true, falling
back to `_defaultWalletName(address)` only for a genuinely new secret.
`matchingKey.first` is safe: it is only read inside the `alreadyExists`
branch, which is defined as `matchingKey.isNotEmpty`. Any SDK link this path
creates now carries the wallet's real, possibly user-renamed name from the
start, closing the latent data-integrity gap without depending on
`AppBloc.sdkAccountName`'s live-name preference or
`LocalWalletStorage._freezeLinkNames`'s re-stamp to mask it.

### WR-01 — Skip accepted; downgraded to Info (IN-01)

See below.

## Info

### IN-01: Backfill re-runs `wallet.reAdd()` for every unresolved wallet on every future wallet add — accepted as a known, documented ceiling, not a defect

**File:** `packages/genius_api/lib/src/genius_api.dart:386-388` (call site
inside `_registerWallet`), `427-468` (`linkExistingSDKAccounts`), `494-526`
(`backfillLinks`' ambiguous-result handling)

**Issue:** As described in iteration 1's WR-01: a wallet whose link can never
be proven deterministically stays "Unlinked" and has its key re-submitted to
the SDK (`_addToSDK` → `addAccountWithMnemonic`/`addAccountWithPrivateKey`)
on every subsequent wallet add, for as long as it remains unlinked.

Iteration 1 treated this as a Warning because the correctness of repeating
the re-add rested on an *unverified* assumption that re-adding an
already-known key to the SDK is a true no-op. That assumption is now
confirmed: re-adding an existing key via `GeniusAccount`'s add path is
idempotent (returns the existing account rather than creating a duplicate),
per the SuperGenius SDK's own `GeniusAccount.cpp`. With that confirmed, the
repeated re-add call can no longer grow duplicate accounts for an unresolved
wallet — the worst case is a wasted, no-op SDK call on each future import,
which is a performance/efficiency concern (explicitly out of v1 review
scope) rather than a correctness one.

This also lines up with what the code already documents: D-14 required
verifying re-add idempotency before backfill shipped ("If it creates a
duplicate, skip backfill entirely"), and the `ponytail:` comment at
`genius_api.dart:470-472` already records the "stays 'Unlinked' forever"
outcome as a known, accepted ceiling with a stated upgrade path (an SDK call
that derives an address without registering it). Recorded as Info rather
than closed outright because the repeated no-op call is still worth
eliminating eventually (the stated upgrade path), and because this
conclusion rests on the native SDK's own source, which this repository does
not vendor or test against directly — a future SDK version changing that
behavior would silently reopen this as a real bug with no local test to
catch it.

**Fix:** No action required now. If/when `linkExistingSDKAccounts()` or its
call sites are next touched, prefer the upgrade path already named in the
`ponytail:` comment (derive an address from a key without registering it) so
the repeated re-add call is eliminated rather than merely proven harmless.

---

_Reviewed: 2026-09-29_
_Depth: standard_
_Iteration: 2_
