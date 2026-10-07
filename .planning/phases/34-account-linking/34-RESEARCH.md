# Phase 34: Account linking - Research

**Researched:** 2026-09-29
**Domain:** Flutter self-custody wallet, native SDK over Dart FFI (`packages/genius_api`), bloc/cubit, `flutter_secure_storage`
**Confidence:** HIGH (all claims cite code read this session; one item — legacy re-add idempotency — is now VERIFIED against upstream source where the milestone research had flagged it LOW)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**SDK-only adds**
- D-01: The "SDK Accounts" add form (`lib/account/sdk_account_manager.dart:~516`) also saves the ETH wallet, through the same path as normal import (`_registerWallet`, `packages/genius_api/lib/src/genius_api.dart:301`). No path creates an SDK account without a wallet.
- D-02: If the seed/key typed there is already one of the user's wallets: do not duplicate; make sure its SDK account exists and is linked, and tell the user it was already there.
- D-03: A wallet saved through the SDK form is named the same way normal import names wallets.
- D-04: Adding through the SDK form changes neither selection (SDK wallet nor active wallet).
- D-05: Both entry points (SDK form and normal import) stay in this phase. Phase 35 decides where add/import lives.
- D-06: Half-failed add (wallet saved but SDK add failed, or the reverse): keep what succeeded, complete the link later, show an "SDK account pending" note. Never roll back or lose an import.
- D-07: Wallets can be added while the SDK node is down. Their SDK account and link are created once the node starts.

**Delete coupling**
- D-08: Deleting a wallet keeps its SDK account (the key stays in the SDK's own store). The link record is kept.
- D-09: That surviving SDK account keeps the wallet's name, marked, e.g. "Main (wallet removed)". Re-importing that wallet re-links it.
- D-10: Deleting an SDK account also deletes its linked wallet. The confirmation names the wallet it will remove. No balance or child warning. Reversibility: one-way.
- D-11: If that linked wallet is the active wallet, the SDK-account delete is blocked with the reason (pick another active wallet first). Mirrors `sdkRowActions`, `sdk_account_manager.dart:~606`.
- D-12: Fix the pending "deleting a wallet from the drawer silently does nothing" bug here: both wallet-delete paths (`lib/account/account_drawer.dart`, `lib/components/wallet_information.dart:~231`) go through one shared rule so D-08..D-11 apply everywhere.

**Old-account backfill**
- D-13: Older accounts are linked once, automatically, in the background after the node is up. It re-runs only for wallets still unlinked. The user does nothing.
- D-14: Method: re-add each stored wallet key via `addAccountWithMnemonic`/`addAccountWithPrivateKey` and read back the address. First verify whether re-adding an existing key returns the same address or creates a duplicate. If it creates a duplicate, skip backfill entirely; older accounts read "Unlinked" until their wallet is re-imported. **See "Q2 verdict" below — resolved: no duplicate.**
- D-15: The start-up account (the wallet chosen by `getSGNUSLinkedWalletPrivateKey`, `local_secure_storage_base.dart:312`) is linked directly, without re-adding, even if backfill is skipped.
- D-16: SDK accounts matching no stored wallet read "Unlinked" plus the short address. They stay selectable and deletable; importing the matching wallet later links them.

**How a link reads**
- D-17: Linked SDK account rows show the wallet name on top and the short SDK address below.
- D-18: The "Super Genius Wallet N" rows in the wallet menu (`_mergeSgnusWallet`, `app_bloc.dart:710`) keep their place and are relabelled with the link. Phase 35 decides layout.
- D-19: ETH wallet rows that have a linked SDK account get a small SDK marker in this phase. Colours from `GWColors` tokens, WCAG AA both modes.
- D-20: In the UI, the account the SDK starts with is called "Default account". "Linked" means only wallet-to-SDK-account from now on. Code naming follows: `_sgnusLinkedAddressKey`, `linkedSDKAccount`, `getSGNUSLinkedWalletPrivateKey` are renamed so the two meanings cannot be confused. The persisted secure-storage key string `'__sgnus_linked_address__'` stays as is — no data migration.

### Claude's Discretion
- Storage location and shape of the link map, as long as it holds public addresses only (research suggests `local_secure_storage`, next to the existing start-account key).
- How "SDK account pending" (D-06) and "Unlinked" (D-16) are surfaced, within existing row components.

### Deferred Ideas (OUT OF SCOPE)
- Where add/import lives, and whether the SDK form folds into normal import: Phase 35 (switcher).
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| LINK-01 | Record which SDK address came from a created/imported wallet (public addresses only) | §"Where to hook link capture" — `_registerWallet` diff-and-persist pattern, both call sites traced |
| LINK-02 | Every SDK account shows its source wallet's name; "Super Genius Wallet N" rows gone | §"How labels render today" — `_mergeSgnusWallet` and `sdk_account_manager.dart` row shape traced, exact edit points identified |
| LINK-03 | Pre-existing SDK accounts linked best-effort; unmatched shown as unlinked, never hidden | §"Q2 verdict: backfill idempotency" — resolved from SuperGenius source, backfill is safe |
</phase_requirements>

## Summary

This phase wires a link that has never existed: which ETH wallet produced which SGNUS/SDK address.
No FFI call derives an SGNUS address without registering it, so the link must be captured as a
byproduct of the existing account-creation calls, not computed standalone. `_registerWallet`
(`genius_api.dart:302-332`) is the one place both addresses are in scope — diffing
`getAvailableAccounts()` before/after its `_initSDK`/`addAccountWith*` step yields the new SGNUS
address; the ETH address is `storedKey.account(0).address()`, already in hand at the call site.

The milestone-level research flagged one genuinely open question as LOW confidence: whether
re-adding an already-registered key duplicates the SDK's account list, which would make the D-14
backfill method unsafe. This session resolved it by reading the pinned SuperGenius source
(`c575a16`) directly: **re-adding is idempotent — no duplicate, silent success** (see "Q2 verdict"
below). This substantially de-risks D-13/D-14: the backfill pass can safely re-add every stored
wallet's key without fear of inflating the account list.

A second finding changes the delete-coupling work (D-12): `lib/account/account_drawer.dart`'s
delete path was **already fixed** by prior commits (`828aa820`, `7cc3f4bb`, `150285ac`, `818f36ff`)
— it dispatches `AppBloc.add(DeleteWallet(...))` correctly, gated on `canDeleteWallet`, not gated on
`mounted`. The pending todo describing that bug is now stale for this file. The genuinely broken
path is `lib/components/wallet_information.dart`'s "More Options" drawer (`SlidingDrawerButton` at
line ~229), which calls `geniusApi.deleteWallet(...)` **directly**, bypassing `AppBloc` entirely: no
`canDeleteWallet` guard, no SDK-link update, no replacement-wallet selection, and it navigates to
`/dashboard` unconditionally. This is D-12's real target — repoint it to
`context.read<AppBloc>().add(DeleteWallet(...))`.

**Primary recommendation:** capture the link inside `_registerWallet` by diffing
`getAvailableAccounts()`; store it as a new `Map<String,String>` (sgnusAddress -> ethAddress,
lowercased) in `local_secure_storage` next to the existing start-account key; thread it through
`AppState` the same way `sdkAccounts`/`selectedSDKAccount` already are (all five `_getSDKAccountState()`
call sites in `app_bloc.dart`); relabel `_mergeSgnusWallet` and `sdk_account_manager.dart`'s rows
from the link map instead of `'Super Genius Wallet N'`; unify both wallet-delete paths onto
`AppBloc.add(DeleteWallet(...))`; and rename the four start-account identifiers listed in D-20 (full
reference list below) without touching the persisted key string.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Link capture (diff-and-persist) | API/Backend (`genius_api.dart`) | Database/Storage (`local_secure_storage`) | Only `_registerWallet` has both addresses in scope; storage is a thin persistence layer it calls into |
| Link map persistence | Database/Storage (`local_secure_storage`) | — | Same file already owns the adjacent start-account key |
| Link state distribution | API/Backend (`AppBloc`) | — | Existing pattern: `sdkAccounts`/`selectedSDKAccount` are already bloc-owned, re-read from the SDK on every relevant event |
| Label rendering (rows, `_mergeSgnusWallet`) | Browser/Client (widgets) | — | Pure presentation over `AppState.sdkAccountLinks`; no widget reaches storage/FFI directly (AGENTS.md boundary) |
| Delete coupling (wallet <-> SDK account) | API/Backend (`AppBloc`) | — | Business rule (D-08..D-11) belongs in the bloc, not duplicated per call site — this is exactly what D-12 fixes |
| Legacy backfill | API/Backend (`genius_api.dart`) | Database/Storage | Re-add + diff is an FFI-and-storage operation; runs once in the background, no UI surface required |
| Identifier rename (D-20) | API/Backend + Database/Storage | Browser/Client (few reads) | Cuts across `local_secure_storage`, `genius_api`, `AppState`/`AppBloc`, and the two UI reads listed below |

## Standard Stack

No new dependency. This phase reuses:
- `flutter_secure_storage` (already a `local_secure_storage` dependency) for the link map.
- `flutter_bloc`/`equatable` (already used by `AppState`/`AppBloc`) for state distribution.
- The existing hand-rolled fake-class test pattern (`implements GeniusApi` + `noSuchMethod`), not `mockito`'s `Mock`/`when()` — see Validation Architecture.

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Diffing `getAvailableAccounts()` in `_registerWallet` | A dedicated FFI call returning the new address directly | No such call exists in `GeniusSDK.h` — `AddAccountWithMnemonic`/`WithKey` return only a status, never the derived address (confirmed by reading `GeniusNode::AddAccountWithKey`/`AddAccountWithMnemonic`, `gn_new.cpp:2451-2469`) |
| A new top-level `AccountLinkCubit` | Extending `AppState`/`AppBloc` (as ARCHITECTURE.md recommends) | The link is a property of the SDK-account list the bloc already owns and re-reads on every relevant event; a separate cubit would need to stay in lockstep with five existing emit sites for no benefit |

## Package Legitimacy Audit

No external packages are installed in this phase. N/A.

## Architecture Patterns

### System Architecture Diagram

```
Create/Import wallet (onboarding, or SDK-form add per D-01)
        |
        v
genius_api.dart: saveWallet() / importWalletFrom{Mnemonic,PrivateKey,KeyStore}()
        |
        v
_registerWallet(storedKey)  [genius_api.dart:302-332]
        |
        |-- before = getAvailableAccounts()        (diff point START)
        |
        |-- _secureStorage.saveStoredKey(storedKey) -> ETH wallet persisted
        |
        |-- _initSDK(storedKey)                      [first wallet: SDK cold-starts,
        |     OR                                       sets _address = GeniusSDKGetAddress(),
        |   addAccountWithMnemonic/PrivateKey()        calls saveSGNUSLinkedAddress(ethAddr)]
        |     (already initialized: adds account,      [subsequent wallets: SDK already up,
        |      returns only GENIUS_NODE_RET_OK,          addAccountWith* returns status only]
        |      never the new address)
        |
        |-- after = getAvailableAccounts()           (diff point END)
        |
        v
new SGNUS address = after - before (set difference)
        |
        v
_secureStorage.saveSDKAccountLink(sgnusAddress, ethAddress)   <- NEW, local_secure_storage
        |
        v
AppBloc's five _getSDKAccountState() call sites read getSDKAccountLinks()  <- NEW
        |
        v
AppState.sdkAccountLinks: Map<String,String>   <- NEW field
        |
        +--> _mergeSgnusWallet(): label = link map lookup instead of 'Super Genius Wallet N'
        +--> sdk_account_manager.dart rows: wallet name on top, address below (D-17)
        +--> account_drawer.dart rows: small SDK marker on linked ETH wallets (D-19)
```

### Where to hook link capture

`_registerWallet` (`genius_api.dart:302-332`) is called from exactly four places, all of them
"normal import/create": `saveWallet` (:598, create-flow), `importWalletFromKeyStore` (:668),
`importWalletFromMnemonic` (:715), `importWalletFromPrivateKey` (:737). `importWalletFromAddress`
(watch-only, :673) does NOT call it — correct, a watch-only wallet has no key and gets no SDK
account.

The SDK-form add path (D-01's target) is different today: `AppBloc._onAddSDKAccountWithMnemonic`/
`_onAddSDKAccountWithPrivateKey` (`app_bloc.dart:765-799`) call `api.addAccountWithMnemonic`/
`addAccountWithPrivateKey` **directly** — no `StoredKey` is built, no wallet is saved. To satisfy
D-01, this path needs a new `genius_api` method that builds a `StoredKey` from the raw
mnemonic/private key (same as `importWalletFromMnemonic`/`importWalletFromPrivateKey` already do via
`StoredKey.importHDWallet`/`StoredKey.importPrivateKey`, `genius_api.dart:704-717,726-737`) and then
calls `_registerWallet(storedKey)` — reusing the exact diff-and-persist logic rather than
duplicating it. D-02's "already one of the user's wallets" check belongs before this call: compare
`storedKey.account(0).address()` against `getAllWallets()`'s existing addresses
(`local_secure_storage_base.dart:288-310`).

`_initSDK` itself (`genius_api.dart:206-286`) is worth noting as an alternate, narrower hook for the
*first* wallet only: it already has both `_address` (the new SGNUS address, from
`GeniusSDKGetAddress()` right after init, line 260-261) and the ETH address
(`storedKey.wallet("").getAddressForCoin(TWCoinType.TWCoinTypeEthereum)`, used at line 266-270 to
build the `SGNUSConnection`) in the same scope, no diff needed. But `_registerWallet`'s
before/after-diff is the only mechanism that also covers every *subsequent* wallet (where
`_initSDK` returns early because `_isSdkInitialized` is already true), so the diff approach is the
one uniform mechanism — use it for all cases rather than special-casing the first wallet.

### How labels render today (the two edit points)

1. `_mergeSgnusWallet` (`app_bloc.dart:710-733`) builds `Wallet` rows for the wallet-menu with
   `walletName: accounts.length == 1 ? 'Super Genius Wallet' : 'Super Genius Wallet ${index + 1}'`
   — this literal string is what LINK-02 removes. Replace with a lookup into
   `AppState.sdkAccountLinks` (or the freshly-read `api.getSDKAccountLinks()`), falling back to an
   honest "Unlinked SDK account N" per D-16.
2. `sdk_account_manager.dart`'s `_buildAccountRow` (`:169-219`) currently renders `title:
   WalletUtils.getAddressForDisplay(address)` (the address IS the title) and `subtitle:` either
   `'Active processing account'` or `'The app starts with this account'` or `null`. D-17 wants the
   wallet name on top and the address below — this collides with the existing subtitle's use for
   selection/start-account status. The plan needs to decide how status text and the link
   name/address coexist on one row (e.g., status as a trailing badge, link name as title, address as
   subtitle) — flagged as an open question below, not resolved by this research.

### Recommended Project Structure

No new directories. Edits land in:
```
packages/genius_api/lib/src/genius_api.dart            # diff-and-persist, getSDKAccountLinks()
packages/local_secure_storage/lib/src/local_secure_storage_base.dart  # link map storage
lib/bloc/app_state.dart, app_bloc.dart                  # sdkAccountLinks field, relabeling, delete coupling
lib/account/sdk_account_manager.dart                    # row label change, SDK-form add -> _registerWallet
lib/account/account_drawer.dart                         # SDK marker on linked wallet rows (D-19)
lib/components/wallet_information.dart                  # repoint SlidingDrawerButton delete to AppBloc
```

### Anti-Patterns to Avoid
- **Computing the SGNUS address without registering the key:** no header function exists for this
  (confirmed: `GeniusSDKAddAccountWith*` always both derives and adds). Don't invent a "preview"
  path.
- **A new cubit for the link map:** see Alternatives Considered — extend `AppState` instead.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| "Did the add succeed" signal | A new success/failure callback plumbed through FFI | The existing observe-the-list-until-it-changes pattern (`bloc.stream.map(...).firstWhere(...).timeout(...)`, `sdk_account_manager.dart:460-463,510-514`) | Already proven for delete/add/payout; the SDK gives no other completion signal |
| Delete confirmation dialog | A new dialog widget | `GWDialog.show<bool>` (used identically in `account_drawer.dart:211-232` and `sdk_account_manager.dart:426-443`) | Existing, themed, accessible |

**Key insight:** Every "was this actually applied" question in this codebase is already answered by
polling the bloc's own re-fetched state with a timeout, never by trusting a synchronous FFI return
value. The link-capture diff is the same idiom applied to account *creation* instead of deletion.

## Runtime State Inventory

Triggered because D-20 renames Dart identifiers tied to persisted state.

| Category | Items Found | Action Required |
|----------|-------------|------------------|
| Stored data | The persisted secure-storage key string `'__sgnus_linked_address__'` (`local_secure_storage_base.dart:24`) is explicitly NOT renamed per D-20 — only the Dart identifier `_sgnusLinkedAddressKey` referencing it changes. **No data migration.** The new link map is a brand-new key (not a rename), Claude's discretion on its literal string. | Code edit only for the existing key; new key added, no migration needed since nothing existed there before |
| Live service config | None — no external service holds either identifier | None |
| OS-registered state | None | None |
| Secrets/env vars | None — no env var or SOPS-style secret references these identifiers | None |
| Build artifacts | None — pure Dart source rename, no generated files reference these names (`.freezed.dart`/`.g.dart` are for `Wallet`/other models, not `AppState`, which is hand-written) | None |

**Full reference list for the D-20 rename** (every call site found; the plan must update all, and
only these):
- `_sgnusLinkedAddressKey` — `local_secure_storage_base.dart:24,331,344` (3 refs, all in one file)
- `linkedSDKAccount` — `lib/bloc/app_state.dart:87,111,134,158,185`; `lib/bloc/app_bloc.dart:109,129,179,651,679,705,759,777,795,820,836` (11 refs); `lib/account/sdk_account_manager.dart:101`; `test/account/sdk_start_account_delete_test.dart:63,105,110` (test doubles/assertions — must be updated together or the test breaks on the rename, not on behavior)
- `getSGNUSLinkedWalletPrivateKey` — `packages/genius_api/lib/src/genius_api.dart:197`; `local_secure_storage_base.dart:312` (definition)
- `saveSGNUSLinkedAddress` — `genius_api.dart:280`; `local_secure_storage_base.dart:342` (definition); `test/local_wallet_storage_test.dart:202,214`

Not in D-20's list but reads the same underlying concept — verify at rename time it isn't
accidentally touched: `sgnusLinkCandidates` (`local_secure_storage_base.dart:329`, `@visibleForTesting`) is a *different*, still-correctly-named helper (it picks which stored wallet the SDK starts with); D-20 does not ask for it to be renamed.

## Common Pitfalls

### Pitfall 1: `wallet_information.dart`'s delete path bypasses AppBloc entirely
**What goes wrong:** The "More Options" drawer's `SlidingDrawerButton` (`wallet_information.dart:229-259`)
calls `geniusApi.deleteWallet(state.selectedWallet?.address ?? "", watchOnly: ...)` directly — never
dispatches `DeleteWallet`. It skips `AppBloc.canDeleteWallet`'s last-wallet guard, never updates the
SDK link map, never selects a replacement wallet, and unconditionally `context.go('/dashboard')`s
after a 100ms delay regardless of whether the delete succeeded.
**Why it happens:** This drawer predates the bloc-routed delete added to `account_drawer.dart` by
commits `828aa820`/`7cc3f4bb`/`150285ac`/`818f36ff` — those fixes landed in one file, not both.
**How to avoid:** Repoint this button to `context.read<AppBloc>().add(DeleteWallet(address, watchOnly: ...))`,
same as `account_drawer.dart:238-244`, and drop the direct `geniusApi.deleteWallet` call plus the
unconditional navigation/toast.
**Warning signs:** A widget test through this exact drawer/button, mirroring
`account_drawer_show_test.dart`'s pattern, that asserts `AppBloc` state (wallets/links) rather than
just the direct API call.
**Phase to address:** This phase, as D-12's actual fix target (the account_drawer.dart bug it names is already resolved).

### Pitfall 2: `account_drawer.dart`'s bug is already fixed — don't re-fix a non-bug
**What goes wrong:** The pending todo (`2026-09-26-deleting-a-wallet-from-the-drawer-silently-does-nothing.md`)
describes `_confirmDeleteWallet` gating on `mounted` and closing the drawer before the dialog opens.
Reading the current file (`account_drawer.dart:186-245`) shows this is no longer true: the drawer is
popped before the dialog (correct), and the dispatch at line 238 is explicitly NOT gated on
`mounted` (comment says so directly), already `AppBloc`-routed with the last-wallet guard.
**Why it happens:** The todo predates four delete-related commits found in `git log` for this file.
**How to avoid:** Don't spend a task "fixing" this file for D-12; verify it (one line in a test) and
spend the real effort on Pitfall 1.
**Phase to address:** This phase — a quick verification pass, not a rewrite.

### Pitfall 3: SDK-form add (D-01) needs a new `StoredKey`-building method, not a bolt-on
**What goes wrong:** `AddSDKAccountWithMnemonic`/`AddSDKAccountWithPrivateKey` handlers
(`app_bloc.dart:765-799`) currently call `api.addAccountWithMnemonic`/`addAccountWithPrivateKey`
directly. Naively adding a `_registerWallet` call alongside them (rather than routing through it)
would double-add the SDK account (once via the existing direct call, once via `_registerWallet`'s
own add-or-init step) — wasted work at best; at worst a second entry if the underlying add is ever
not idempotent for a *different* reason than the one verified below.
**How to avoid:** Replace the direct `addAccountWithMnemonic`/`addAccountWithPrivateKey` calls in
these two handlers with a new `genius_api` method that builds the `StoredKey` (mirroring
`importWalletFromMnemonic`/`importWalletFromPrivateKey`, `genius_api.dart:699-740`) and calls
`_registerWallet` — so there is exactly one add path, not two running side by side.
**Phase to address:** This phase.

### Pitfall 4: D-17's row relabel collides with the row's existing status subtitle
**What goes wrong:** `sdk_account_manager.dart:217-219`'s `subtitle` is already used for
`'Active processing account'` / `'The app starts with this account'`. D-17 wants the subtitle slot
for the linked wallet's short address instead (with wallet name promoted to `title`). Both cannot
occupy the same slot without a layout decision.
**How to avoid:** Flagged as an open question below — the planner should decide (e.g., move status
text to a trailing badge) rather than let an executor silently drop one or the other.
**Phase to address:** This phase, in the plan's UI task, not left to implementation-time judgment.

### Pitfall 5: Key/mnemonic leaking into Bloc state via the new linking surface
**What goes wrong:** Carried over from the milestone PITFALLS.md — "each SDK account shows its
source wallet" is a short hop from "let me also show the mnemonic here." `getSelectedAccountMnemonic()`
(`genius_api.dart:1106-1118`) returns a raw `String?`.
**How to avoid:** `AppState.sdkAccountLinks` and any new storage method must hold **addresses only**
(both keys and values are already-public addresses, never a `StoredKey`/mnemonic/private key). Grep
`mnemonic|privateKey` against any new `*State`/`*Cubit` file touched this phase before calling it done.
**Phase to address:** This phase — add as a code-review checklist item.

## Q2 verdict: backfill idempotency (resolves D-14's open question)

**Verdict: re-adding an already-registered key is idempotent. No duplicate SDK account is created,
and the call returns success either way.** Confidence: HIGH — read directly from the pinned
SuperGenius source this session (not live-tested, since testnet is blocked by
`INITIALIZING_BLOCKCHAIN`; see Environment note below).

Trace, at commit `c575a16` (the pinned SuperGenius version):

- `GeniusNode::AddAccountWithKey`/`AddAccountWithMnemonic` (`src/account/GeniusNode.cpp`, read via
  the scratchpad's `gn_new.cpp:2451-2469`) call `GeniusAccount::NewFromPrivateKey`/`NewFromMnemonic`
  and only check `new_account == nullptr` for failure.
- `GeniusAccount::NewFromMnemonic`/`NewFromPrivateKey` (`src/account/GeniusAccount.cpp:334-395`)
  both call `GenerateGeniusAddress`, which derives the SGNUS address **deterministically** from the
  private key (ELGAMAL-predefined-secret signature -> sha256 -> key seed — same key always yields
  the same address) and then calls `AppendPublicKeyToFile` (`GeniusAccount.cpp:549`).
- `AppendPublicKeyToFile` (`GeniusAccount.cpp:163-183`) — quoted verbatim:
  ```cpp
  auto existing_keys = ReadPublicKeysFromFile( file_path );
  auto key_it        = std::find( existing_keys.cbegin(), existing_keys.cend(), public_key_hex );
  if ( key_it != existing_keys.cend() )
  {
      genius_account_logger()->debug( "Public key already present in storage file, skipping write" );
      return outcome::success();
  }
  existing_keys.emplace_back( public_key_hex );
  return WritePublicKeysToFile( file_path, existing_keys );
  ```
  This explicitly dedupes before writing and returns success on the duplicate path — the file (and
  therefore `GeniusSDKGetAvailableAccounts()`, which reads it via `GeniusAccount::GetAvailableAccounts`
  -> `ReadPublicKeysFromFile`) never grows for a key already present.
- `ReadPublicKeysFromFile` (`GeniusAccount.cpp:105-142`) also dedupes on read (`std::unordered_set<std::string> seen`), a second line of defense against any historical duplicate entry.

**Implication for the plan:** the D-14 backfill method (re-add each stored wallet's key via
`addAccountWithMnemonic`/`addAccountWithPrivateKey`, diff `getAvailableAccounts()`) is **safe to
implement as specified** — it will never inflate the SDK's account list. A wallet whose key is
already registered will produce an empty diff (not an error) — the backfill loop should treat "no
new address" as "already registered, not necessarily still findable 1:1" and fall back to the
`sgnusLinkCandidates`-style elimination the milestone ARCHITECTURE.md already describes (only safe
when exactly one unmatched wallet remains against exactly one unmatched SDK address); otherwise mark
"Unlinked" per D-16, honest rather than guessed.

**Source note on provenance:** the scratchpad's `gsdk/src/GeniusSDK.cpp` checkout is a stale/older
version (predates `AddAccountWithMnemonic` entirely — verified: zero matches for "account" in that
file). The authoritative implementation was read from `sg` (blobless SuperGenius clone) at the pinned
tag via `git show c575a16:src/account/GeniusAccount.cpp`, not from the stale gsdk checkout.

## Code Examples

### Diff-and-persist link capture (illustrative shape, not exact code)
```dart
// Source: pattern derived from genius_api.dart:302-332's existing _registerWallet,
// combined with the observe-the-list idiom already used for delete/add (sdk_account_manager.dart:460-463)
Future<void> _registerWallet(StoredKey storedKey) async {
  final before = getAvailableAccounts();               // [] if SDK not yet initialized
  final wasAlreadyInitialized = _isSdkInitialized;

  await _secureStorage.saveStoredKey(storedKey);
  await _initSDK(storedKey);
  if (wasAlreadyInitialized) {
    // existing addAccountWithMnemonic/PrivateKey branch, unchanged
  }

  final after = getAvailableAccounts();
  final newAddresses = after.toSet().difference(before.toSet());
  if (newAddresses.length == 1) {
    await _secureStorage.saveSDKAccountLink(
      newAddresses.single,
      storedKey.account(0).address(),
    );
  }
  await loadStoredWallets();
}
```

### Existing observe-the-list pattern to reuse for "link completed" feedback
```dart
// Source: sdk_account_manager.dart:510-514 (existing add-account success signal)
final before = bloc.state.sdkAccounts.length;
final grew = bloc.stream
    .map((s) => s.sdkAccounts.length > before)
    .firstWhere((added) => added)
    .timeout(const Duration(seconds: 3), onTimeout: () => false);
```

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | D-03's "named the same way normal import names wallets" resolves to the `HDWallet.name ?? "${first5}...${last4}"` fallback pattern at `genius_api.dart:584-586`, since the onboarding UI's own naming field wasn't traced past `event.walletName`/`event.wallet` | Architecture Patterns, "Where to hook link capture" | If the actual UI default-naming logic differs, the SDK-form add could produce an inconsistent name pattern — low risk, cosmetic only |
| A2 | "Wallet name" for a linked SDK account row (D-17) reads `wallet.storedKey.name()`/`Wallet.walletName`, the same field `_toSafeWallet` already populates (`local_secure_storage_base.dart:369`) — not a separately-stored "display name" | Architecture Patterns | Low risk — this is the only name field that exists on `Wallet` |

## Open Questions

1. **How does D-17's row layout reconcile wallet-name/address with the existing status subtitle?**
   - What we know: today's row shows address as title, one of two status strings (or null) as subtitle.
   - What's unclear: where "Active processing account" / "The app starts with this account" go once the subtitle is claimed by the linked address.
   - Recommendation: decide in the plan's task breakdown (e.g., trailing badge for status, title=wallet name, subtitle=address), not left implicit.

2. **D-02's "already one of the user's wallets" match — by address only, or also by mnemonic/key equality for watch-only-adjacent edge cases?**
   - What we know: `getAllWallets()` exposes stored wallets with addresses; comparing `storedKey.account(0).address()` against them is straightforward.
   - What's unclear: whether a case-sensitivity or checksum mismatch could cause a false negative.
   - Recommendation: lowercase-compare, consistent with `sgnusLinkCandidates`'s own lowercase convention (`local_secure_storage_base.dart:334-336`).

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Live SuperGenius testnet | Standing VER-02 walk | ✗ (stuck `INITIALIZING_BLOCKCHAIN`, per STATE.md/PROJECT.md) | — | Record as blocked gap per REQUIREMENTS.md's own precondition flag; do not gate phase close on it |
| Flutter SDK | `flutter test`/`flutter analyze` | ✓ (not on PATH by default) | pinned per project | Invoke via full path `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin/flutter` |

**Missing dependencies with no fallback:** none — the testnet walk has an explicit documented fallback (blocked-gap recording) per REQUIREMENTS.md.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with the Flutter SDK) |
| Config file | none — no `dart_test.yaml`; tests run via `flutter test` |
| Quick run command | `flutter test test/account/ test/local_wallet_storage_test.dart` |
| Full suite command | `flutter test` (run from repo root; Flutter SDK at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on PATH) |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| LINK-01 | `_registerWallet`'s diff captures the new SGNUS<->ETH link on create/import | unit | `flutter test test/local_wallet_storage_test.dart` (extend) | ❌ Wave 0 — new test in existing file |
| LINK-01 | SDK-form add (D-01) also saves the wallet, no duplicate on re-entry (D-02) | widget | `flutter test test/account/sdk_add_account_test.dart` (extend, following its existing `_RefusingApi`-style fake) | ❌ Wave 0 |
| LINK-02 | `_mergeSgnusWallet` labels linked accounts by wallet name, unlinked honestly | unit | new `test/bloc/merge_sgnus_wallet_link_test.dart` (or extend an existing app_bloc test) | ❌ Wave 0 |
| LINK-02 | SDK account row shows wallet name + address (D-17) | widget | extend `test/account/sdk_row_actions_test.dart` or a sibling file | ❌ Wave 0 |
| LINK-03 | Backfill re-add does not duplicate; unmatched reads "Unlinked" | unit | new test exercising the backfill method against the `_Api`-style fake (assert `getAvailableAccounts()` length unchanged after a re-add of an already-present key) | ❌ Wave 0 |
| D-12 | `wallet_information.dart`'s delete path dispatches through `AppBloc`, respects `canDeleteWallet` | widget | new `test/components/wallet_information_delete_test.dart`, mirroring `account_drawer_show_test.dart`'s pattern | ❌ Wave 0 |
| D-12 | `account_drawer.dart`'s delete path (already fixed) stays correct | widget | verify existing coverage is sufficient; add one assertion if none currently exercises the not-gated-on-mounted path | Check at plan time |

### Sampling Rate
- **Per task commit:** the quick run command above (account + storage tests only, seconds not minutes)
- **Per wave merge:** full `flutter test`
- **Phase gate:** full suite green before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] Extend `test/local_wallet_storage_test.dart` with `saveSDKAccountLink`/`getSDKAccountLinks` coverage
- [ ] Extend `test/account/sdk_add_account_test.dart`'s fake (`_RefusingApi`-style) to cover the new `_registerWallet`-routed SDK-form add
- [ ] New test file for `_mergeSgnusWallet` relabeling (or confirm an existing app_bloc test file is the natural home)
- [ ] New widget test for `wallet_information.dart`'s delete path (none exists today)
- [ ] Test doubles: extending the existing `implements GeniusApi { ... noSuchMethod }` fakes with `getSDKAccountLinks()`/`saveSDKAccountLink()` — no new mocking framework, matches the established convention (mockito is a dependency but only its `Fake` base class is used, in `test/local_wallet_storage_test.dart`; bloc-level tests hand-roll fakes)

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | no | Out of scope — this phase touches no auth flow |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | yes | Reuse existing `isValidMnemonic`/`isValidPrivateKey` (`genius_api.dart:1010-1036`) for any new SDK-form-add path; no new validation surface introduced |
| V6 Cryptography | yes (by omission) | This phase adds **no** new key handling — it only persists already-derived public addresses. The control is: never let `getSelectedAccountMnemonic()`'s return value or any `StoredKey`/private-key value reach `AppState.sdkAccountLinks` or any new storage method's parameters |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Mnemonic/private key surfacing through the new "show linked wallet" UI | Information Disclosure | Address-only in `AppState`/Cubit state (AGENTS.md rule); grep `mnemonic|privateKey` against every new `*State`/`*Cubit` file before calling a task done |
| Silent data loss on a half-failed add (D-06) | Repudiation (user can't tell what happened) | Explicit "SDK account pending" state, never a silent rollback — per D-06, this is a locked decision, not a suggestion |
| Direct-API-bypass delete (Pitfall 1) allowing the last wallet to be deleted | Elevation of Privilege / Denial of Service (self-inflicted, loses funds access) | Route through `AppBloc.canDeleteWallet`, never call `geniusApi.deleteWallet` from a widget directly |

## Sources

### Primary (HIGH confidence — code read this session)
- `packages/genius_api/lib/src/genius_api.dart:190-332,940-1119` — `_initSDK`, `_registerWallet`, account methods, `getStartAccountAddress`
- `packages/local_secure_storage/lib/src/local_secure_storage_base.dart:1-40,280-347` — existing link storage, `sgnusLinkCandidates`
- `lib/bloc/app_bloc.dart:600-849` — `_onDeleteWallet`, `_mergeSgnusWallet`, all five `_getSDKAccountState()` emit sites, `_onDeleteSDKAccount`
- `lib/bloc/app_state.dart:1-188` — `AppState` fields/copyWith/props (verbatim field list confirmed)
- `lib/account/sdk_account_manager.dart:80-260,420-617` — drawer/row rendering, add dialog, `sdkRowActions`
- `lib/account/account_drawer.dart` (full file) — confirmed delete path already bloc-routed and not `mounted`-gated
- `lib/components/wallet_information.dart:1-60,180-273` — confirmed the genuinely broken direct-API delete path
- `packages/genius_api/lib/types/wallet_type.dart:6` — `enum WalletType { tracking, privateKey, mnemonic, keystore, sgnus }`
- `packages/genius_api/lib/ffi/genius_api_ffi.dart:1389` — `const int GENIUS_SDK_ADDRESS_SIZE = 130;`
- `lib/dev/dev_flags.dart:15` — `const bool kShowDevTools = bool.fromEnvironment('GW_DEV_TOOLS');`
- `test/account/sdk_start_account_delete_test.dart`, `test/account/sdk_add_account_test.dart`, `test/local_wallet_storage_test.dart` — existing test conventions
- `git log --oneline -- lib/account/account_drawer.dart` — confirmed 4 prior delete-fix commits
- SuperGenius pinned commit `c575a16`, `src/account/GeniusAccount.cpp:105-183,334-552` (via `git show c575a16:...`) — resolves the D-14 idempotency question
- `.planning/phases/34-account-linking/34-CONTEXT.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/config.json`, `AGENTS.md`

### Secondary (MEDIUM confidence)
- `.planning/research/ARCHITECTURE.md`, `.planning/research/PITFALLS.md` — milestone-level research, cited where this session's deeper dig confirmed or extended their findings

### Tertiary (LOW confidence)
- None carried into this document as authoritative — the milestone research's one LOW-confidence item (backfill idempotency) was resolved to HIGH this session.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new dependency, every reused pattern cited by file:line
- Architecture: HIGH — every call site of `_registerWallet`, `_mergeSgnusWallet`, and both delete paths read directly
- Pitfalls: HIGH (code-level) — the two delete-path findings and the idempotency verdict are read from source, not inferred
- Backfill idempotency (D-14): HIGH — resolved from pinned SuperGenius source this session (previously LOW in milestone research)

**Research date:** 2026-09-29
**Valid until:** 30 days (stable internal codebase; re-verify if SuperGenius pin changes before this phase executes)
