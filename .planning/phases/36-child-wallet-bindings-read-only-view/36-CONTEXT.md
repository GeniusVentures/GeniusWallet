# Phase 36: Child wallet bindings & read-only view - Context

**Gathered:** 2026-09-29
**Status:** Ready for planning

<domain>
## Phase Boundary

Bind the 11 GeniusSDK child-wallet functions plus `GeniusSDKGetPubSub` in `packages/genius_api`, and give the user a read-only list of the children registered under the SDK account the node runs as, each with its GNUS balance, with dev mocks so it can be checked without a live node (CHILD-01, CHILD-02, VER-01). No write operation has UI in this phase: register, fund, recover, revoke, detach and replace-main are Phase 37.

</domain>

<decisions>
## Implementation Decisions

### Where the list lives
- **D-01:** A new top-level route `/child-wallets` (a sibling of `/network` in `lib/navigation/router.dart`), not a section inside the switcher drawer. The drawer stays a picker; Phase 37's actions need a full screen.
- **D-02:** It opens from a new "Child wallets" item in the `SDKAccountRow` menu (`lib/account/sdk_account_manager.dart`). The item is enabled only on the account the node is running as (the "main" whose children are listed), disabled-not-hidden on other rows with the reason, matching the menu's existing disabled-item pattern.
- **D-03:** The screen header names the main: its linked wallet name (Phase 34 `sdkAccountName`) over its short address.

### What a child row shows
- **D-04:** Each child row: the linked wallet name when the child is one of the user's own SDK accounts (Phase 34 links), otherwise "Unlinked" + short address; the child's GNUS balance.
- **D-05:** Balance comes from `GeniusSDKGetChildBalanceAll` (minions, uint64) converted to GNUS with an integer-exact divide by 1e6 (1 Minion = 1e-6 GNUS, `GeniusSDK.h:8`), displayed with the existing `formatTxAmount` / GNUS formatting. No floating-point conversion of the raw uint64.
- **D-06:** Registration metadata (`game_id`, `publisher_id`, `dev_wallet`, `peers_cut`) and `sequence` are not shown (no consumer; v3.0 out of scope).
- **D-07:** Row order is the order the SDK returns.

### States and refresh
- **D-08:** Empty: "No child wallets registered under this account." Node not running: "Node not running" (same wording as the switcher). Query failure (`GENIUS_NODE_ERROR_REGISTRATION` or other non-OK): an error note with a Retry action. None of these hide the header.
- **D-09:** A one-line note under the list: balances come from the node's synced view and can lag. A 0 balance is shown as 0, not guessed as "syncing" (the SDK cannot tell the two apart).
- **D-10:** While the screen is open, re-read every 10 seconds (`Timer.periodic` in the State or cubit, cancelled on dispose — the existing balance-polling pattern), plus a manual refresh action.

### Bindings
- **D-11:** Bind all 11 child functions and `GeniusSDKGetPubSub` in `packages/genius_api/lib/ffi/genius_api_ffi.dart`, in the file's existing ffigen style, splicing only the new symbols and structs (`GeniusRegistrationMetadata`, `GeniusRegistrationDiscoveryEntry`, `GENIUS_NODE_ERROR_REGISTRATION`); the 27 existing bindings are not regenerated.
- **D-12:** Dart wrappers in `GeniusApi` for every bound function now, returning plain Dart values (addresses as strings, balances as int/BigInt, results as the existing `GeniusNodeReturnValue`), never raw pointers. Write-operation wrappers exist but have no UI caller until Phase 37.
- **D-13:** `GetRegistrationsForMain`: allocate the two out-params, read `count` entries, free `*out_entries` with `GeniusSDKFree` when non-null, free the out-params. Zero registrations (RET_OK, null, 0) is an empty list, not an error.
- **D-14:** `GeniusSDKGetPubSub` is bound and wrapped as an opaque handle; it is never passed to `GeniusSDKFree` (node-owned, header line ~510). No Dart consumer in this milestone.
- **D-15:** Calls stay synchronous on the main isolate (local CRDT reads, same as the existing transfer/balance wrappers). Only reads are called from UI in this phase.
- **D-16:** A unit test pins struct layout (`sizeOf` of both new structs) against the header's field sizes so a future header change fails loudly.

### Architecture
- **D-17:** A `ChildWalletsCubit` under `lib/child_wallets/` reads through `GeniusApi` (repository layer); no FFI or Hive in widgets. Cubit state holds public addresses, names and balances only.

### Dev mocks
- **D-18:** A `DevMockChildWallets` singleton (the `DevMockSgnus` pattern) the cubit checks behind `kDebugMode && kShowDevTools`, with presets: none, one child, three children (mixed linked/unlinked, one zero balance), query error, node not running. A "CHILD WALLETS" section in `dev_tools_bubble.dart` switches presets and clears them.

### Claude's Discretion
- Exact widget/file names inside `lib/child_wallets/`.
- Whether minions→GNUS lives as a small helper next to the existing balance formatting or inside the cubit.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Milestone scope
- `.planning/REQUIREMENTS.md` — `## v3.0 Requirements`, CHILD-01, CHILD-02, VER-01
- `.planning/ROADMAP.md` — `# Milestone v3.0`, Phase 36 success criteria

### SDK contract
- `C:/Users/User/Documents/Projects/GNUS/GeniusSDK/build/Windows/Release/GeniusSDK/include/GeniusSDK.h` — child functions (~505-720), structs (~45-110), `GeniusSDKFree` (~267), PubSub ownership note (~510)
- `.planning/research/FEATURES.md` — protocol mechanics (who calls what, observability, 0-balance ambiguity)
- `.planning/research/STACK.md` — binding approach (hand-splice, no full regen), free patterns
- `.planning/research/PITFALLS.md` — FFI memory, struct drift, stale balances

### Prior phases
- `.planning/phases/34-account-linking/34-CONTEXT.md` + SUMMARYs — `sdkAccountName`, `linkedWallet`, link map
- `.planning/phases/35-unified-header-switcher/35-CONTEXT.md` + SUMMARYs — `SDKAccountRow` menu, "Node not running" wording

### Project rules
- `AGENTS.md`

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `NativeLibrary` ffigen-style bindings (`packages/genius_api/lib/ffi/genius_api_ffi.dart`), `GeniusTokenValue`/`GeniusAddress` structs, `_CharArrayToDartString` (`genius_api.dart:58`).
- Free patterns: `GetOutTransactions` + `GeniusSDKFreeTransactions` (`genius_api.dart:1108-1171`), `GetAvailableAccounts` + `GeniusSDKFree` (`:1241-1246`).
- `formatTxAmount` (`lib/dashboard/home/widgets/transaction_utils.dart:112`), `GeniusBalanceDisplay` (`lib/wallets/view/genius_balance_display.dart`).
- `DevMockSgnus` / `_devButton` / `_Section` in `lib/dev/`.

### Established Patterns
- SDK features get top-level routes (`/network` at `router.dart:198`, built with the `WalletDetailsCubit` passed in).
- Balance polling: `Timer.periodic(10s)` cancelled on dispose (`GeniusBalanceDisplay:58`, `wallet_overview.dart:74`).
- Tests fake `GeniusApi` with a hand-rolled `implements GeniusApi` + `noSuchMethod` (`test/account/sdk_account_rows_test.dart:52-72`).

### Integration Points
- `SDKAccountRow` menu (`lib/account/sdk_account_manager.dart`) — new "Child wallets" item.
- `lib/navigation/router.dart` — new `/child-wallets` route.
- `lib/dev/dev_tools_bubble.dart` — new CHILD WALLETS section.

</code_context>

<specifics>
## Specific Ideas

- Empty copy: "No child wallets registered under this account."
- Lag note: balances come from the node's synced view and can lag.

</specifics>

<deferred>
## Deferred Ideas

- Showing, from a child account, which main it is registered under (no SDK query by child; would need scanning mains): Phase 37 if CHILD-09 needs it.
- All write operations and their pending states: Phase 37.

</deferred>

---

*Phase: 36-child-wallet-bindings-read-only-view*
*Context gathered: 2026-09-29*
