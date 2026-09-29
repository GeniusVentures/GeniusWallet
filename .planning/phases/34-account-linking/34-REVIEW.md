---
phase: 34-account-linking
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 23
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/account/sdk_account_manager.dart
  - lib/bloc/app_bloc.dart
  - lib/bloc/app_event.dart
  - lib/bloc/app_state.dart
  - lib/components/job/submit_job_button.dart
  - lib/components/wallet_information.dart
  - lib/dashboard/compute/compute_panel.dart
  - lib/dashboard/compute/compute_state.dart
  - packages/genius_api/lib/src/genius_api.dart
  - packages/local_secure_storage/lib/src/local_secure_storage_base.dart
  - test/account/account_drawer_show_test.dart
  - test/account/sdk_account_delete_coupling_test.dart
  - test/account/sdk_account_links_test.dart
  - test/account/sdk_account_rows_test.dart
  - test/account/sdk_add_account_test.dart
  - test/account/sdk_link_backfill_test.dart
  - test/account/sdk_start_account_delete_test.dart
  - test/components/wallet_identity_test.dart
  - test/components/wallet_information_delete_test.dart
  - test/dashboard/compute_panel_wiring_test.dart
  - test/dashboard/compute_state_test.dart
  - test/local_wallet_storage_test.dart
findings:
  critical: 1
  warning: 3
  info: 2
  total: 6
status: issues_found
---

# Phase 34: Code Review Report

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 23
**Status:** issues_found

## Summary

Phase 34 wires SDK-account ↔ ETH-wallet linking through `AppBloc`, `GeniusApi`
and `LocalWalletStorage`, plus the two drawer surfaces that display it. The
delete-coupling rules (D-08..D-12), the naming rules (D-17..D-20) and the
backfill pass (D-13..D-16) are each backed by focused, well-targeted unit
tests, and no secret material (mnemonic/private key) is logged, stored on a
Bloc/Cubit state class, or otherwise leaked in the diff — the wallet-safety
rules in `AGENTS.md` are respected throughout the new code. `brace-every-if`
is followed in every added line, and no new `_buildFoo()`-style widget
helpers were introduced (`_RowBadge` was correctly promoted to a
`StatelessWidget`).

One finding is a real data-loss/wrong-wallet-selection defect: the
last-wallet guard the new SDK-delete-coupling logic (D-11/D-12) leans on
(`AppBloc.canDeleteWallet`) counts watch-only (keyless) wallets as if they
were a real fallback wallet, so an SDK-account delete (or a direct wallet
delete) can legitimately remove a user's only key-holding wallet while a
watch-only row survives — exactly the "you must keep at least one wallet"
guarantee the feature advertises, silently defeated. The remaining findings
are lower-severity robustness/data-integrity gaps in the new backfill and
stream-timeout code.

## Critical Issues

### CR-01: The last-wallet guard counts watch-only wallets, so an SDK-account delete can remove the user's only signing wallet

**File:** `lib/bloc/app_bloc.dart:635-636` (also reached from `lib/bloc/app_bloc.dart:812-814` inside the new `sdkDeleteBlock`, and from `lib/account/account_drawer.dart:270` and `lib/components/wallet_information.dart:245-247`)

**Issue:** `canDeleteWallet` is the single rule phase 34 explicitly consolidated so D-08..D-12 all "go through one shared rule" (per the `34-CONTEXT.md` D-12 folded todo and the `_onDeleteWallet`/`sdkDeleteBlock` doc comments). It is defined as:

```dart
static bool canDeleteWallet(List<Wallet> wallets) =>
    wallets.where((w) => w.walletType != WalletType.sgnus).length > 1;
```

This excludes only `WalletType.sgnus` rows. `WalletType.tracking` (watch-only,
address-only — see `packages/genius_api/lib/types/wallet_type.dart:2`) is
counted as "another wallet that would remain." A user with exactly one
key-holding wallet (mnemonic/privateKey/keystore) linked to an SDK account,
plus one watch-only wallet, can:

- delete the SDK account through the new `_onDeleteSDKAccount` path
  (`sdkDeleteBlock` returns `null`, not `SDKDeleteBlock.lastWallet`, because
  `canDeleteWallet([keyWallet, trackingWallet])` is `true`), which cascades
  into `_deleteWallet(linked.address, watchOnly: false)` (D-10) and removes
  the key wallet too, or
- delete the key wallet directly from the drawer/wallet-information "More"
  menu the same way.

Either path leaves the user with only the watch-only wallet — no signing
key anywhere in the app — with no warning shown, because the guard reports
"you have another wallet." The in-app delete confirmation even says "If you
have no copy of its recovery phrase, the wallet cannot be restored," but the
guard that is supposed to prevent reaching zero *usable* wallets never
fires. This is the exact failure mode `canDeleteWallet`'s own doc comment
warns about for SDK accounts ("would leave the user with nothing after a
restart") — the same reasoning was never extended to watch-only rows, which
equally hold no key and cannot back up or sign anything.

No test in this phase's diff exercises "one key wallet + one tracking
wallet" for either `canDeleteWallet` or `sdkDeleteBlock`
(`sdk_account_delete_coupling_test.dart`'s "last wallet" case uses a single
wallet only), so this gap is untested as well as unfixed.

**Fix:**

```dart
static bool canDeleteWallet(List<Wallet> wallets) => wallets
    .where((w) =>
        w.walletType != WalletType.sgnus &&
        w.walletType != WalletType.tracking)
    .length >
    1;
```

Because `canDeleteWallet` is the single shared gate D-12 intentionally
routed every delete surface through, this one-line fix closes the gap for
the wallet-delete drawer, the wallet-information "More" menu, and the new
SDK-account delete simultaneously. Add a regression test alongside the
existing `sdkDeleteBlock` group: one key wallet + one tracking wallet linked
to an SDK account must resolve to `SDKDeleteBlock.lastWallet`, not `null`.

## Warnings

### WR-01: Backfill silently retries a real, mutating SDK call for every unresolved wallet on every future wallet add

**File:** `packages/genius_api/lib/src/genius_api.dart:386-388` (call site inside `_registerWallet`), `packages/genius_api/lib/src/genius_api.dart:427-468` (`linkExistingSDKAccounts`), `packages/genius_api/lib/src/genius_api.dart:494-526` (`backfillLinks`' ambiguous-result handling)

**Issue:** `linkExistingSDKAccounts()` is called both from `_onInitializeSDK`
(the intended "once, after the node is up" pass per D-13) **and** from the
end of every `_registerWallet` call — i.e. on every wallet create/import and
every "Add SDK account" submission, per D-13's own "it re-runs only for
wallets still unlinked" clause. For a wallet whose link can never be proven
deterministically (`backfillLinks`' `added.length > 1` abort case, or more
than one simultaneous "no-op" elimination candidate), `wallet.reAdd()` —
which is `_addToSDK(key)`, a real call into `addAccountWithMnemonic`/
`addAccountWithPrivateKey` — gets invoked again on every subsequent,
unrelated wallet add for as long as that one wallet stays unlinked. The
correctness of doing this repeatedly rests entirely on an unverified
assumption recorded only as a "ponytail" about the *outcome* ("stays
'Unlinked' forever"), not about the *side effect* of re-submitting the key
to the SDK indefinitely. If re-adding an already-known key is ever not a
true no-op on some SDK build, this path grows duplicate accounts for that
wallet by one on every future import, not once.

**Fix:** Either gate the repeated re-add behind a persisted "backfill
attempted and failed for this address" marker (skip `reAdd()` for a wallet
already tried and left ambiguous, only retrying it from `_onInitializeSDK`'s
one pass), or restrict `linkExistingSDKAccounts()`'s call sites to
SDK-startup only and let `_registerWallet`'s own direct
`newAddresses.length == 1` check be the sole coverage for accounts added
while the node is already running.

### WR-02: Unhandled `StateError` if the bloc closes while a delete/payout confirmation is waiting on `bloc.stream`

**File:** `lib/account/sdk_account_manager.dart:519-522` (`_confirmDeleteSDKAccount`), `lib/account/sdk_account_manager.dart:648-651` (`_showSetPayoutAddressDialog`)

**Issue:** Both handlers wait for a bloc-stream predicate with a timeout:

```dart
final removed = await bloc.stream
    .map((s) => !s.sdkAccounts.contains(address))
    .firstWhere((gone) => gone)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```

`Stream.firstWhere`/`Stream.first` throw `StateError('No element')` (or
Bad State) if the underlying stream **completes** before the predicate is
satisfied — which is exactly what happens if `AppBloc.close()` runs (e.g.
the app is torn down, or the widget tree unmounts and disposes the bloc)
while this `await` is pending. `.timeout(...)` only covers "too slow," not
"the stream ended," so this throws instead of hitting `onTimeout`. Neither
call site is awaited by its caller (`onPressed: () => _confirmDeleteSDKAccount(...)`
/ `onPressed: () => _showSetPayoutAddressDialog(...)`), so the exception
surfaces as an unhandled async error rather than a caught, reported one.

**Fix:** Wrap the stream wait so a closed stream degrades the same way a
timeout does, e.g.:

```dart
final removed = await bloc.stream
    .map((s) => !s.sdkAccounts.contains(address))
    .firstWhere((gone) => gone, orElse: () => false)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```

(`firstWhere`'s `orElse` covers the "stream closed without a match" case;
`.first` in the payout dialog needs an equivalent `orElse`-via-`fold`/
`defaultIfEmpty` treatment, or a manual `try/catch` around the whole
`await`.)

### WR-03: `addWalletFromSecret`'s "already exists" path can persist the wrong wallet name into a new SDK link

**File:** `packages/genius_api/lib/src/genius_api.dart:983-1005`

**Issue:** `addWalletFromSecret` always constructs its `storedKey` with the
throwaway `_defaultWalletName(address)` (`name = _defaultWalletName(address)`
at line 983), never the wallet's real, possibly user-renamed name — even
when `alreadyExists` is true and the real name is available via
`_secureStorage.getStoredKeys()` (already read one line above to compute
`alreadyExists`). If this "already exists" branch is the one that actually
gets the account onto the running SDK for the first time (e.g. the wallet
was saved while the node was down, per D-07, and the user re-pastes the
same secret into the SDK-add dialog before backfill/init has linked it),
`_registerWallet(storedKey, save: false)` may call `_addToSDK` successfully
and persist `SDKAccountLink.walletName` as the auto-generated address-based
name rather than the wallet's real display name.

Today this is masked: `AppBloc.sdkAccountName` prefers the *live* wallet's
`walletName` whenever the wallet still exists, and
`LocalWalletStorage._freezeLinkNames` re-stamps the link with the correct
current name at delete time. So the wrong name currently never reaches the
UI. It is still a latent data-integrity bug in the stored link record, and
the masking depends on two separate pieces of unrelated code continuing to
cooperate exactly as they do today.

**Fix:** When `alreadyExists` is true, build (or re-derive) `storedKey`'s
name from the matched existing key's own `.name()` instead of
`_defaultWalletName(address)`, so any link this path creates carries the
wallet's real name from the start.

## Info

### IN-01: `wallet_information.dart`'s delete action no longer navigates away, but the file is dead code

**File:** `lib/components/wallet_information.dart:230-264`

**Issue:** The pre-existing "More options → Delete Wallet" handler used to
call `geniusApi.deleteWallet(...)` directly and then `context.go('/dashboard')`
after a short delay. The phase-34 fix (D-12) correctly routes the delete
through `AppBloc.canDeleteWallet` + `DeleteWallet`, but the new handler never
navigates away after a successful delete — it just dispatches the event and
leaves the screen showing whatever `WalletDetailsCubit` now resolves to.
`WalletInformation` is confirmed dead code (per its own header comment and
`lib/dev/generated_closure_canary.dart`'s doc: "nothing reachable from
`main.dart` imports these 9 widgets," this one included, and it is never
mounted, only compiled), so there is no live-app impact today. Flagging so
this isn't rediscovered as a regression if the widget is ever wired up to a
real screen.

**Fix:** No action needed while the widget stays unreachable; if it is ever
mounted for real, decide explicitly whether staying on-screen (showing the
cubit's new selection) or navigating away is the intended UX, and add a test
for whichever is chosen.

### IN-02: No regression test for the watch-only + last-key-wallet interaction (see CR-01)

**File:** `test/account/sdk_account_delete_coupling_test.dart`, `test/components/wallet_information_delete_test.dart`

**Issue:** Every "last wallet" test in this phase's diff (`'a linked account
is blocked as the last wallet'`, `'the last wallet cannot be deleted'`, `'the
last own wallet cannot be deleted even with an SDK account connected'`)
constructs its wallet list from key-holding and/or sgnus wallets only. None
mixes in a `WalletType.tracking` wallet, so CR-01's gap has no failing test
to catch it.

**Fix:** Once CR-01 is fixed, add a case with `[keyWallet, trackingWallet]`
to `AppBloc.sdkDeleteBlock`'s test group (expect `SDKDeleteBlock.lastWallet`)
and to the direct-delete test group (expect the wallet to survive and "You
must keep at least one wallet." to show).

---

_Reviewed: 2026-09-29_
_Reviewer: Claude (gsd-code-reviewer)_
_Depth: standard_
