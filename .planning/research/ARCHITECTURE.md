# Architecture Research — v3.0 Child Wallets & Account Linking

**Domain:** Flutter self-custody wallet, native SDK over FFI (`packages/genius_api`), bloc/cubit
**Researched:** 2026-09-28
**Confidence:** HIGH (all claims cite current code; the one open item — legacy-link backfill — is flagged LOW)

## (a) Where the SDK-address <-> wallet link is derived/stored

**The SGNUS address cannot be derived offline in Dart.** `GeniusAddress` is `0x` + 128 hex chars
(`GeniusSDK.h:57-64`) — not the 42-char Ethereum address. It only exists once the native node
computes it, via `GeniusSDKGetAddress()` (current/selected account) or `GeniusSDKGetAvailableAccounts()`
(all accounts) — both FFI calls, both require the SDK already initialized with that key
(`genius_api.dart:1094-1099`, `:956-971`). There is no header function that derives an address from
a key without registering it (`GeniusSDKAddAccountWith*` always both derives *and* adds).

**So: capture the link as a byproduct of registration, don't try to compute it standalone.**
`_registerWallet` (`genius_api.dart:302-330`) already calls `_secureStorage.saveStoredKey` then
`_initSDK`/`addAccountWithMnemonic`/`addAccountWithPrivateKey` for every ETH wallet created or
imported — this is the one place both the ETH address (`storedKey.account(0).address()`) and the
resulting SGNUS address are in scope in the same call. Diff `getAvailableAccounts()` before/after
the add call; the one new entry is this wallet's SGNUS address. Persist `sgnusAddress -> ethAddress`
there, in `local_secure_storage` (it already owns the adjacent `_sgnusLinkedAddressKey` concept at
`local_secure_storage_base.dart:24,312-347`) — add `saveSDKAccountLink(sgnusAddress, ethAddress)` /
`getSDKAccountLinks() -> Map<String,String>`. **These are two public addresses, not key material** —
storing them is safe under the wallet-safety rule (AGENTS.md) either way, but reusing the existing
storage keeps the "how the SDK knows about a wallet" logic in one file.

**Legacy orphans (pre-feature accounts already in the SDK's own on-disk account list).** No FFI call
recovers "which key produced this existing address" after the fact. Best-effort backfill: for each
locally-stored ETH wallet not yet in the link map, re-issue `addAccountWithMnemonic`/`WithPrivateKey`
for its key and diff again — deterministic derivation means this either re-surfaces the same address
(if the SDK treats re-adding as idempotent) or grows the list by one (if it doesn't, meaning it was
never actually added and this call is the first genuine link). Either way the returned/diffed address
is capturable and correct. Any wallet that produces no new address and can't be matched 1:1 when
multiple unlinked entries remain should show as "Unlinked SDK account" rather than a guessed label —
inventing a link is worse than admitting the gap. (LOW confidence — the SDK's re-add idempotency
isn't verified from the header alone; confirm behaviorally in phase 1.)

## (b) State shape for two selections, which bloc/cubit owns each

Two selections already exist as **separate, un-synced state** — this is not new plumbing, it's
wiring what's there:

| Selection | Owner today | Field | Persisted |
|---|---|---|---|
| SDK wallet (which key the node signs/mints as) | `AppBloc` | `AppState.selectedSDKAccount` (`app_state.dart:81`) | No — native SDK remembers its own last-selected account across restarts |
| Active wallet (which balance/history the app displays) | `WalletDetailsCubit` | `WalletDetailsState.selectedWallet` | Yes — Hive `walletBoxName` (`wallet_details_cubit.dart:160-163`, `cache.dart:13-15`) |

**Keep this split** — collapsing them into one bloc would cross the FFI-vs-Hive ownership boundary
these two already respect. What's missing is the *link*, not a merged owner:

- Add `AppState.sdkAccountLinks` — `Map<String,String>` (sgnusAddress -> ethAddress, lowercased),
  populated alongside `selectedSDKAccount`/`sdkAccounts` everywhere `_getSDKAccountState()` is called
  (`app_bloc.dart:741-838`: `_onSgnusConnectionChanged`, `_onSelectSDKAccount`,
  `_onAddSDKAccountWith*`, `_onDeleteSDKAccount`, `_onRefreshSDKAccounts`) — read from
  `api.getSDKAccountLinks()`, a plain `Map<String,String>` return, never a `StoredKey`.
- `_mergeSgnusWallet` (`app_bloc.dart:710-733`) stops inventing `'Super Genius Wallet N'` and instead
  looks up each SGNUS address in the link map: linked -> label as the source wallet
  ("<name>'s SDK account"); unlinked -> "Unlinked SDK account N" (an honest label, not a silent drop).
- The new switcher widget reads `AppBloc` for the SDK-wallet list/selection and `WalletDetailsCubit`
  for the active-wallet list/selection — two `BlocBuilder`s in one widget, exactly as
  `_buildActionRowWidgets` already composes two separate chips today (`responsive_overlay.dart:22-86`).
  No new merged state class is needed or wanted.

**Child-wallet state is a third, independent cubit** (see (d)) — it is neither "which SDK identity"
nor "which display wallet," it is "what are my registered children and their pending/confirmed status,"
scoped to whichever SDK wallet is currently selected.

## (c) New components vs modified — file-by-file

| File | New/Modified | What |
|---|---|---|
| `lib/account/account_switcher.dart` | **New** | Replaces `SDKAccountManagerButton` + `AccountDropdownSelector`'s chip pair in the control track. One `StatelessWidget`, two `BlocBuilder`s (`AppBloc` for SDK wallet, `WalletDetailsCubit` for active wallet), renders as two adjacent chips inside one drawer-opening button, or one button opening a drawer with two sections — decide the visual in a UI-SPEC pass, not here. |
| `lib/account/account_switcher_drawer.dart` | **New** | The drawer body: SDK-wallet section (reuses `sdkRowActions`, `_buildAccountRow` logic lifted out of `sdk_account_manager.dart`) + active-wallet section (reuses `_AccountDrawerBody` from `account_drawer.dart`). Each row shows the link label from `AppState.sdkAccountLinks`. |
| `lib/account/sdk_account_manager.dart` | **Modified** | `SDKAccountManagerButton` and its drawer content are superseded by the switcher; keep `sdkRowActions` (pure function, reusable) and the add/delete/payout dialogs — they migrate as-is, called from the new drawer. Delete the old button/drawer-opener once the switcher ships. |
| `lib/account/account_dropdown_selector.dart` | **Modified/Deleted** | Superseded the same way; `AccountDrawer.show` (the static entry other surfaces call, e.g. the compute panel — `account_drawer.dart:34-52`) stays, since it's a public API other call sites depend on. |
| `lib/components/overlay/responsive_overlay.dart` | **Modified** | `_buildActionRowWidgets` (line 42-86) swaps the two `Flexible` chips + divider for one `AccountSwitcher` entry. |
| `lib/components/overlay/mobile_header.dart` | **Modified** | Add the switcher here too — mobile currently has neither control (confirmed: no reference to either widget in this file), so this is new mobile surface, not a re-skin. |
| `packages/genius_api/lib/src/genius_api.dart` | **Modified** | Add `getSDKAccountLinks()`; extend `_registerWallet` to diff-and-persist the link; bind the 11 child functions + `GetPubSub` as new public methods (thin FFI wrappers, same shape as `addAccountWithPrivateKey` etc. at `:1052-1062`). |
| `packages/local_secure_storage/lib/src/local_secure_storage_base.dart` | **Modified** | Add `saveSDKAccountLink`/`getSDKAccountLinks` next to the existing `_sgnusLinkedAddressKey` methods (`:312-347`). |
| `lib/bloc/app_state.dart` / `app_bloc.dart` | **Modified** | Add `sdkAccountLinks` field (props/copyWith); update `_mergeSgnusWallet` labeling as in (b). |
| `lib/child_wallets/` | **New** (see (d)) | Cubit + repository-facing calls + view. |

No widget in this list reaches Hive, `File`, or the SDK directly — every read goes through `AppBloc`,
`WalletDetailsCubit`, or the new `ChildWalletsCubit`, consistent with AGENTS.md's repository-boundary
rule. Colours: every new row/chip reads `Theme.of(context).extension<GWColors>()`, never a literal.

## (d) Where the child-wallet feature lives

`lib/child_wallets/cubit/child_wallets_cubit.dart` + `lib/child_wallets/cubit/child_wallets_state.dart`
+ `lib/child_wallets/view/...` — mirrors the existing `lib/wallets/cubit/` + `lib/wallets/view/` split
(confirmed convention) rather than the flatter `lib/squid_router/` layout, because this feature has
real cubit state (a child list with per-child pending/confirmed status) the way `wallets/` does, not a
handful of stateless screens the way `squid_router/` does.

- **Repository methods live in `genius_api`**, not in a new package — it already is the sole FFI
  boundary and already owns account-lifecycle methods (`addAccountWithMnemonic`, `deleteAccount`,
  etc.) that this is a sibling of. New methods, one per header function: `registerChild`,
  `getRegistrationsForMain`, `getChildBalance`, `getChildBalanceAll`, `fundChild`/`fundChildGNUS`,
  `recoverFromChild`/`recoverFromChildGNUS`, `detachChild`, `replaceMain`, `revokeChild`, `getPubSub`.
  Each: guard `!_isSdkInitialized`, marshal the C struct, map the return value — the exact shape
  `addAccountWithPrivateKey` already uses (`genius_api.dart:1052-1062`).
- **`ChildWalletsCubit`** takes a `GeniusApi` (constructor injection, same pattern as
  `WalletDetailsCubit(geniusApi: ..., networkTokensProvider: ...)`) and owns: the child list for the
  *currently selected SDK account* (re-fetch on `AppBloc.selectedSDKAccount` change — the cubit
  listens to `AppBloc`'s stream, it does not read Hive/FFI from a widget), per-child balances, and
  the pending-operation map described in (e). **No private key ever enters this cubit's state** — it
  only ever holds public addresses and `GeniusTokenValue` strings.
- Child registration metadata (`GeniusRegistrationMetadata`: `game_id`, `publisher_id`, `dev_wallet`,
  `peers_cut`) is opaque, app-supplied data — not secret — safe as plain cubit-state fields.

## (e) Data flow for pending (submitted-not-confirmed) operations and refresh

Every mutating child call (`FundChild(GNUS)`, `RecoverFromChild(GNUS)`, `RevokeChild`, `DetachChild`,
`ReplaceMain`) is fire-and-forget at the FFI layer: `GENIUS_NODE_RET_OK` means **submitted**, not
**confirmed by consensus** (`GeniusSDK.h:611-612,649-652,714-718` — explicit doc notes on three of
the five). There is no push/callback for confirmation; the SDK never tells the app when a submitted
op lands.

The existing app has exactly one pattern for this shape of problem — **poll the observable state
until it changes, with a timeout, rather than trust the synchronous return** — used for delete
(`sdk_account_manager.dart:460-463`), add (`:510-514`), and payout (`:571-574`). Reuse it:

1. On submit, `ChildWalletsCubit` optimistically marks that child/op as `pending` in its state
   (e.g. `Map<String, PendingChildOp>` keyed by child address) the instant `GENIUS_NODE_RET_OK`
   returns — this is the only truth the call gives you.
2. A poll loop (timer or `refresh()` called on pull-to-refresh / screen resume) re-reads
   `getChildBalance`/`getChildBalanceAll` and `getRegistrationsForMain`; when the observed value
   changes in the direction the op implies (balance moved, registration appears/disappears), clear
   the pending flag for that entry. Same shape as the existing delete-poll's
   `bloc.stream.map(...).firstWhere(...).timeout(...)`, just against `ChildWalletsCubit`'s own
   re-fetch rather than `AppBloc`'s stream.
3. A pending entry that never resolves within its timeout stays visibly "pending" in the UI
   (a chip/badge on the row) rather than silently reverting to the pre-op value or claiming success —
   the same honesty rule the delete/add/payout flows already apply ("The SDK refused..." vs silent).
4. `RegisterChild` runs **on the child's own node** (constraint from PROJECT.md) — so after a user
   registers themselves as a child, the *main* wallet's `getRegistrationsForMain` won't show it until
   the main's node has separately synced that CRDT record. This is a second, slower kind of "pending"
   than the fund/recover/revoke case — surface it as a distinct state (e.g. "registration submitted,
   waiting for main to see it") rather than reusing the same pending badge, since the resolution
   signal is different (poll `getRegistrationsForMain` on the *main* side, not a balance on the child
   side).

## (f) Suggested build order across ~3 phases

**Phase 1 — Account linking (foundation, no new UI surface required to land).**
Bind nothing new from the SDK; wire the link capture. `_registerWallet` diff-and-persist,
`local_secure_storage` link storage, `AppState.sdkAccountLinks`, `_mergeSgnusWallet` relabeling, and
the legacy-backfill best-effort pass. Ships value on its own (no more orphan "Super Genius Wallet N"
rows) and de-risks the one genuinely uncertain piece (legacy re-add idempotency) before anything else
depends on it. **Depends on:** nothing new. **Blocks:** phase 2's switcher needs real link data to
display, not placeholder labels.

**Phase 2 — Unified header switcher.** Build `AccountSwitcher`/`AccountSwitcherDrawer`, wire into
`_DesktopTopBar` and `mobile_header.dart`, retire the two old widgets. Pure UI + composition over
existing `AppBloc`/`WalletDetailsCubit` state (now correctly linked from phase 1) — no new bloc
events, no new FFI. **Depends on:** phase 1 (link map must exist or every row still reads "Unlinked").
**Needs a UI-SPEC pass** (desktop chip layout is a decided pattern; mobile is genuinely new
surface — the "table stakes vs where to squeeze it into a phone header" question needs a design
contract before implementation, not left to the executor).

**Phase 3 — Child wallets.** Bind the 11 functions + `GetPubSub` in `genius_api`, build
`ChildWalletsCubit` + `lib/child_wallets/view/` (register, list-with-balances, fund, recover,
revoke, detach, replace-main), wire the pending/poll pattern from (e). **Depends on:** phase 2 only
loosely (the child-wallet screen is reached from wherever product decides — likely a menu item next
to the new switcher, not the switcher itself) but **firmly depends on phase 1's link map** to label
"which of my wallets is this child's main" correctly, and on `SuperGenius c575a16` /
`upnp_enabled: false` being the running node build (constraint from PROJECT.md — verify before
phase 3's plan session, it's an infra precondition, not a code dependency). This phase is the
largest and the most likely to need its own deeper per-function research (11 distinct FFI
signatures, two genuinely different "pending" shapes) — flag it for research during
`/gsd-plan-phase`, not before.

## Sources

- `lib/account/sdk_account_manager.dart:37-286,596-617` — SDK account button/drawer, `sdkRowActions`
- `lib/account/account_dropdown_selector.dart:16-73` — wallet chip, reads `WalletDetailsCubit`
- `lib/account/account_drawer.dart:34-108` — `AccountDrawer.show` public entry, reused by compute panel
- `lib/bloc/app_state.dart:80-91,116-187` — `selectedSDKAccount`/`sdkAccounts`/`linkedSDKAccount` fields
- `lib/bloc/app_bloc.dart:690-839` — `_mergeSgnusWallet`, `_onSelectSDKAccount`, `_getSDKAccountState`, add/delete handlers
- `lib/wallets/cubit/wallet_details_cubit.dart:18-39,156-177` — `WalletDetailsCubit`, `selectWallet`, Hive persistence
- `lib/components/overlay/responsive_overlay.dart:22-93,408-418` — `_buildActionRowWidgets`, `_DesktopTopBar`
- `lib/components/overlay/mobile_header.dart` — confirmed no switcher present today
- `packages/genius_api/lib/src/genius_api.dart:190-330,940-1110` — `_initSDK`, `_registerWallet`, account methods, address size
- `packages/local_secure_storage/lib/src/local_secure_storage_base.dart:280-347` — `getSGNUSLinkedWalletPrivateKey`, `sgnusLinkCandidates`, existing link storage
- `packages/genius_api/lib/types/wallet_type.dart` — `WalletType` enum (adding `.sgnus` merge today)
- GeniusSDK header (`GeniusSDK.h:57-64,546-720`) — `GeniusAddress` format, all 11 child functions + doc notes on submitted-vs-confirmed semantics
- `.planning/PROJECT.md` — v3.0 goal/constraints (SuperGenius pin, RegisterChild-runs-on-child's-node)
- AGENTS.md — widget/repository boundary, no-key-in-state, GWColors token rule
