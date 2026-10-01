# Phase 34: Account linking - Context

**Gathered:** 2026-09-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Every SDK account is tied to, and labelled with, the ETH wallet it came from (LINK-01..03). Covers how links are captured on add, what delete does to the pair, the one-time backfill for older accounts, and how linked/unlinked accounts read in the two existing menus. The unified header switcher is Phase 35; child wallets are Phases 36-37.

</domain>

<decisions>
## Implementation Decisions

### SDK-only adds
- **D-01:** The "SDK Accounts" add form (`lib/account/sdk_account_manager.dart:~516`) also saves the ETH wallet, through the same path as normal import (`_registerWallet`, `packages/genius_api/lib/src/genius_api.dart:301`). No path creates an SDK account without a wallet.
- **D-02:** If the seed/key typed there is already one of the user's wallets: do not duplicate; make sure its SDK account exists and is linked, and tell the user it was already there.
- **D-03:** A wallet saved through the SDK form is named the same way normal import names wallets.
- **D-04:** Adding through the SDK form changes neither selection (SDK wallet nor active wallet).
- **D-05:** Both entry points (SDK form and normal import) stay in this phase. Phase 35 decides where add/import lives.
- **D-06:** Half-failed add (wallet saved but SDK add failed, or the reverse): keep what succeeded, complete the link later, show an "SDK account pending" note. Never roll back or lose an import.
- **D-07:** Wallets can be added while the SDK node is down. Their SDK account and link are created once the node starts.

### Delete coupling
- **D-08:** Deleting a wallet keeps its SDK account (the key stays in the SDK's own store). The link record is kept.
- **D-09:** That surviving SDK account keeps the wallet's name, marked, e.g. "Main (wallet removed)". Re-importing that wallet re-links it.
- **D-10:** Deleting an SDK account also deletes its linked wallet. The confirmation names the wallet it will remove. No balance or child warning. — **Reversibility:** one-way — deleting the wallet removes its key from the device; there is no undo short of re-importing from the user's own seed backup.
- **D-11:** If that linked wallet is the active wallet, the SDK-account delete is blocked with the reason (pick another active wallet first). This mirrors the existing rule that the running SDK account and the start-up account cannot be deleted (`sdkRowActions`, `sdk_account_manager.dart:~606`).
- **D-12:** Fix the pending "deleting a wallet from the drawer silently does nothing" bug here: both wallet-delete paths (`lib/account/account_drawer.dart`, `lib/components/wallet_information.dart:~231`) go through one shared rule so D-08..D-11 apply everywhere.

### Old-account backfill
- **D-13:** Older accounts are linked once, automatically, in the background after the node is up. It re-runs only for wallets still unlinked. The user does nothing.
- **D-14:** Method (from research): re-add each stored wallet key via `addAccountWithMnemonic`/`addAccountWithPrivateKey` and read back the address. First verify whether re-adding an existing key returns the same address or creates a duplicate. If it creates a duplicate, skip backfill entirely; older accounts read "Unlinked" until their wallet is re-imported.
- **D-15:** The start-up account (the wallet chosen by `getSGNUSLinkedWalletPrivateKey`, `packages/local_secure_storage/lib/src/local_secure_storage_base.dart:312`) is linked directly, without re-adding, even if backfill is skipped.
- **D-16:** SDK accounts matching no stored wallet read "Unlinked" plus the short address. They stay selectable and deletable; importing the matching wallet later links them.

### How a link reads
- **D-17:** Linked SDK account rows show the wallet name on top and the short SDK address below.
- **D-18:** The "Super Genius Wallet N" rows in the wallet menu (`_mergeSgnusWallet`, `lib/bloc/app_bloc.dart:710`) keep their place and are relabelled with the link. Phase 35 decides layout.
- **D-19:** ETH wallet rows that have a linked SDK account get a small SDK marker in this phase. Colours come from `GWColors` tokens and must meet WCAG AA in both modes.
- **D-20:** In the UI, the account the SDK starts with is called "Default account". "Linked" means only wallet-to-SDK-account from now on. Code naming follows: the Dart identifiers for the existing start-account concept (`_sgnusLinkedAddressKey`, `linkedSDKAccount`, `getSGNUSLinkedWalletPrivateKey`) are renamed so the two meanings cannot be confused. The persisted secure-storage key string `'__sgnus_linked_address__'` stays as is, so no data migration is needed.

### Claude's Discretion
- Storage location and shape of the link map, as long as it holds public addresses only (research suggests `local_secure_storage`, next to the existing start-account key).
- How "SDK account pending" (D-06) and "Unlinked" (D-16) are surfaced, within existing row components.

### Folded Todos
- **Deleting a wallet from the account drawer most likely does nothing** (`.planning/todos/pending/2026-09-26-deleting-a-wallet-from-the-drawer-silently-does-nothing.md`): `_confirmDeleteWallet` closes the drawer before its dialog opens, then gates the delete on `mounted`. Folded via D-12 (retagged from Phase 35 to 34).

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope
- `.planning/REQUIREMENTS.md` — `## v3.0 Requirements`, LINK-01..03, and v3.0 Out of Scope rows
- `.planning/ROADMAP.md` — `# Milestone v3.0` section, Phase 34 success criteria (incl. standing VER-02)

### Research
- `.planning/research/ARCHITECTURE.md` §(a) — link capture as a byproduct of `_registerWallet`, backfill method and its LOW-confidence idempotency question
- `.planning/research/PITFALLS.md` — key safety (no key material in bloc state or logs), account-switch races
- `.planning/research/SUMMARY.md` — build order and phase 34 rationale

### Project rules
- `AGENTS.md` — wallet safety rules, brace style, widgets-not-helpers, GWColors tokens, no Hive/SDK calls in widgets

### Pending todo
- `.planning/todos/pending/2026-09-26-deleting-a-wallet-from-the-drawer-silently-does-nothing.md` — folded (D-12)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `_registerWallet` (`packages/genius_api/lib/src/genius_api.dart:301`): already saves the key and adds its SDK account on create/import. The link capture hooks in here.
- `getSGNUSLinkedWalletPrivateKey` / `saveSGNUSLinkedAddress` (`packages/local_secure_storage/lib/src/local_secure_storage_base.dart:312-347`): the existing start-account storage, and the place for the link map next to it.
- `sdkRowActions` (`lib/account/sdk_account_manager.dart:~606`): the existing delete/copy/QR enablement rules per SDK row.

### Established Patterns
- "Observe the list, don't trust the call": the SDK add/delete dialogs subscribe to `AppBloc` state and wait for the account list to change, with a timeout (`sdk_account_manager.dart:~508`). Reuse this for link-completed detection.
- SDK accounts are plain address strings in `AppState` (`sdkAccounts`, `selectedSDKAccount`, `linkedSDKAccount`, `lib/bloc/app_state.dart:84-87`), re-read from the SDK each time.

### Integration Points
- `_mergeSgnusWallet` (`lib/bloc/app_bloc.dart:710`): builds the "Super Genius Wallet N" rows. Relabel here.
- `SDKAccountManagerButton` drawer rows (`lib/account/sdk_account_manager.dart`) and `account_drawer.dart` wallet rows: the two surfaces that show labels and markers in this phase.
- Wallet delete: `api.deleteWallet` (`genius_api.dart:747`); SDK delete: `api.deleteAccount` (`genius_api.dart:1066`).

</code_context>

<specifics>
## Specific Ideas

- Surviving SDK account after its wallet is deleted reads like "Main (wallet removed)".
- The start-up account is called "Default account" in the UI.

</specifics>

<deferred>
## Deferred Ideas

- Where add/import lives, and whether the SDK form folds into normal import: Phase 35 (switcher).

### Reviewed Todos (not folded)
- `2026-07-22-responsive-type-scale-and-component-consolidation.md`: keyword match only; unrelated to linking.
- `2026-09-26-move-app-and-sdk-data-out-of-documents.md`: shipped in Phase 33.

</deferred>

---

*Phase: 34-account-linking*
*Context gathered: 2026-09-29*
