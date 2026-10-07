# Phase 40: Always-available GNUS bridge - Research

**Researched:** 2026-10-07
**Domain:** Flutter wallet UI gating (pure-Dart resolver + three call sites), earning-account state in AppBloc, per-network GNUS balance reads
**Confidence:** HIGH on code facts (every file below was opened this session); MEDIUM on dashboard placement (fit at 290px is measured by arithmetic, not by a pump)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**Who can bridge**
- **D-01:** Bridge is enabled only when the Selected wallet is the current earning account. Otherwise it is disabled with a reason. No "switch earning, then bridge" flow, and no burn-only path.
- **D-02:** The gate reads the live earning account: the ETH wallet linked to `AppState.selectedSDKAccount` via `AppState.sdkAccountLinks`. It does not read the stale `SGNUSConnection.walletAddress`. That stream and its other readers (`wallet_overview.dart`, `compute_state.dart`) are left as they are.
- **D-03:** Child wallets cannot bridge. Bridge is disabled with a reason.
- **D-04:** One pure-Dart function owns the gate and the reason, used by all three surfaces. Its precedence and copy are tested in one small test file.

**Where Bridge sits**
- **D-05:** Three surfaces: the dashboard wallet overview card, the GNUS row on Assets, and the GNUS coin page. The existing coin-page button moves to the new gate and is disabled instead of hidden.
- **D-06:** The wallet overview gets a single Bridge button (`GWButton`, `gradientOutline`, `sm`, the same treatment as the coin page). No other actions are added to the card.
- **D-07:** No new nav destination. The desktop bar stays at 8 tabs and the mobile bar is unchanged.

**Disabled reasons**
- **D-08:** Each of these states gets its own reason line: not the earning wallet; earning switch pending (`switchingSDKAccount != null`); earning not started (no `selectedSDKAccount`); no GNUS (zero balance); view-only or child wallet (cannot sign, see `canSendFrom`).
- **D-09:** The reason is a muted one-line caption under the disabled button, visible without hover, and exposed to screen readers. No tooltip.
- **D-10:** Copy uses the Earning terminology (Earning / earning wallet), never node, SDK or minting. Exact strings are up to the planner, one short sentence each.

**Entry without a coin**
- **D-11:** Bridge opened from the dashboard or Assets starts on the Selected wallet's GNUS coin on the selected network, the same as the coin page.
- **D-12:** If the wallet holds no GNUS on the selected network but does on another one, Bridge is disabled and the reason names that network (for example "Your GNUS is on Base. Switch network to bridge."). No chain picker and no automatic network switch.

### Claude's Discretion
- Exact reason strings, the precedence between overlapping states, and how the GNUS coin is resolved for the selected wallet and network.
- Contrast of the reason caption must meet WCAG AA in both appearance modes, using GWColors tokens.

### Deferred Ideas (OUT OF SCOPE)
- Re-emitting `SGNUSConnection.walletAddress` on every earning switch would also correct the compute panel and wallet overview readers. This is a separate fix in `genius_api`.
- A "switch earning to this wallet, then bridge" flow.
- A source-chain picker on BridgeScreen.
</user_constraints>

<phase_requirements>
## Phase Requirements

No IDs were assigned (ROADMAP says `TBD`). Proposed IDs for the planner to add to REQUIREMENTS.md (new `### Bridge (BRDG) - Phase 40` section, mapped to Phase 40):

| ID | Description | Research Support |
|----|-------------|------------------|
| BRDG-01 | A Bridge button is always visible on the dashboard overview card, the Assets GNUS row and the GNUS coin page, and opens `/bridge` on the Selected wallet's GNUS coin on the selected network | Sections "Surfaces", "Opening /bridge" |
| BRDG-02 | Bridge is enabled only when the Selected wallet is the live earning account, read from `AppState.selectedSDKAccount` + `sdkAccountLinks`, never from `SGNUSConnection.walletAddress` | Q1 |
| BRDG-03 | A view-only wallet, an SDK account view and a child wallet cannot bridge and show their own reason | Q2 |
| BRDG-04 | Every disabled state shows a one-line muted caption under the button, visible without hover, readable by a screen reader, AA in both modes | Q6 |
| BRDG-05 | One pure-Dart resolver owns gate, precedence and copy; one test file pins them | Q1-Q3 |
| BRDG-06 | GNUS held only on another network disables Bridge and names that network; no auto switch | Q3 |
| BRDG-07 | The gate is re-read at the moment of the tap; the stale `isGnusWalletConnected` route gate is removed | Q5, Security |
</phase_requirements>

## Summary

The gate is cheap to compute for the earning part and expensive for two of the locked reasons. "Selected wallet is the earning account" is a pure lookup over state that already exists: `AppState.selectedSDKAccount` plus `sdkAccountLinks` (keyed by lowercased SDK address, value `walletAddress` lowercased). "Child wallet" (D-03) and "GNUS only on another network" (D-12) are NOT in any state the three surfaces can see today. Child status needs registration reads (`getChildRegistrations`, one FFI read per own SDK account, no by-child SDK query). Other-network GNUS needs one RPC `balanceOf` per other network, because `WalletDetailsState.coins` only ever holds the selected network. Both reads must live in a cubit and be cached, not run in `build`.

Recommended shape: one pure resolver file next to `bridge_cta_state.dart`, one small app-root `BridgeGateCubit` that feeds it (inputs from AppBloc, WalletDetailsCubit, ChildOperationsCubit plus the two async probes), two tiny widgets (`BridgeButton`, `BridgeReasonCaption`) and one shared open handler. The caption cannot live inside the button's Column on the coin page (it sits in a `Wrap`; a 40-character caption would widen that Wrap item), so each surface places the caption itself.

The dashboard card is the hard placement. `lib/components/wallet_overview.dart` is only the host of `ComputePanel`; the panel's tallest state measures 306 against a 314 budget (8px slack), so any new row needs `kDashboardPanelSlotHeight` raised and the height test updated. That is a UI-SPEC decision, flagged below.

**Primary recommendation:** Build `resolveBridgeGate` (pure, 11 states, precedence below) first and test it; add `BridgeGateCubit` second; wire the three surfaces third, with `ComputePanel` taking optional `bridge`/`onBridge` params so its 5 existing test call sites do not change.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Gate precedence and reason copy | Pure Dart module (`lib/dashboard/bridge/`) | - | D-04; testable with no Flutter, same shape as `bridge_cta_state.dart` |
| Earning-account / link / switching state | AppBloc (existing) | - | Already owns `selectedSDKAccount`, `switchingSDKAccount`, `sdkAccountLinks` |
| GNUS coin on selected network | WalletDetailsCubit (existing `coins`, `coinsNetwork`) | - | Already holds the selected network's holdings |
| Child detection, other-network GNUS probe | New `BridgeGateCubit` -> `GeniusApi` / `Web3` | ChildOperationsCubit (reuse `ownRegistrations()`) | Widgets must not call FFI or RPC (AGENTS.md); one cache for three surfaces |
| Button + caption rendering | Widgets (3 surfaces) | - | Tokens only; no repository access |
| Burn + mint | `GeniusApi.bridgeOut` (unchanged) | - | Out of scope |

## Standard Stack

No new packages. Everything is in the tree.

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| flutter_bloc | already in pubspec | `BridgeGateCubit`, `BlocBuilder` | Every other cubit in the repo |
| go_router | already in pubspec | `push('/bridge')` | Existing entry does exactly this (`token_info_screen.dart:50`) |
| flutter_test | SDK | resolver + widget tests | Existing suite; Flutter 3.41.9 verified below |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| New `BridgeGateCubit` | Compute in each surface's `build` from AppBloc + WalletDetailsCubit | Cannot do D-03 or D-12 without an async/FFI read in `build`, and triples it |
| Probe other networks via new RPC code | `Web3().balanceOf(address, contractAddress, rpcUrl)` | Existing at `packages/genius_api/lib/web3/web3.dart:223`; use it, two eth_calls per network |

**Installation:** none.

## Package Legitimacy Audit

None - this phase installs no external packages. (`gsd-tools query package-legitimacy check` not run: nothing to check.)

## Architecture Patterns

### System Architecture Diagram

```
AppBloc.stream  ------------------------+
 (selectedSDKAccount, switching,        |
  sdkAccounts, sdkAccountLinks)         |
WalletDetailsCubit.stream --------------+--> BridgeGateCubit --> resolveBridgeGate(inputs) --> BridgeGate{state, coin, elsewhere}
 (selectedWallet, selectedNetwork,      |        |  ^                                              |
  coins, coinsNetwork, coinsStatus)     |        |  | async, cached, generation-guarded            |
ChildOperationsCubit.stream ------------+        |  |                                              v
                                                 |  +-- isChild:   ChildOperationsCubit.ownRegistrations()   BridgeButton   (3 surfaces)
                                                 |  +-- elsewhere: Web3.balanceOf on other same-class RPC     BridgeReasonCaption (3 surfaces)
                                                 |      networks, only when every earlier rung passed
                                                 v
 tap -> openGnusBridge(context): re-read gate -> if enabled: selectCoin(gate.coin) -> push('/bridge') -> getCoins()
```

### Recommended Project Structure
```
lib/dashboard/bridge/
  bridge_gate.dart          # pure: enum, inputs, resolveBridgeGate, bridgeGateCaption
  bridge_gate_cubit.dart    # state = BridgeGate; follows the three streams; owns the two probes
  bridge_entry.dart         # BridgeButton, BridgeReasonCaption, openGnusBridge()
lib/reown/utilities.dart    # split walletCanSign(Wallet) out of canSendFrom (behaviour-preserving)
test/dashboard/bridge/
  bridge_gate_test.dart     # pure resolver, copy of bridge_cta_state_test.dart shape
  bridge_gate_cubit_test.dart
  bridge_entry_test.dart    # widgets + contrast
```

### Pattern 1: Pure ladder (copy `bridge_cta_state.dart`)
**What:** enum + resolver + caption function + `enabled` getter, no Flutter imports, colour at the call site.
**Source:** `lib/dashboard/bridge/bridge_cta_state.dart:12-112` (enum `BridgeCtaState`, `resolveBridgeCtaState`, `bridgeCtaLabel`, `bridgeCtaEnabled`). Same pattern also in `lib/dashboard/compute/compute_state.dart` (`resolveComputeState`).

Proposed states and precedence (top wins). Precedence is my recommendation (discretion area):

| # | State | Why this rank | Proposed caption (A1) |
|---|-------|---------------|-----------------------|
| 1 | `noWallet` | nothing else can be said | "Select a wallet to bridge." |
| 2 | `viewOnly` | permanent; telling a watch-only wallet to "switch earning" is wrong | "This wallet can't sign, so it can't bridge." |
| 3 | `child` | switching earning to a child will not help | "Child wallets can't bridge." |
| 4 | `switching` | `selectedSDKAccount` is untrusted while a switch is pending | "Earning is switching. Try again in a moment." |
| 5 | `notStarted` | `selectedSDKAccount == null` | "Earning hasn't started yet." |
| 6 | `notEarning` | the D-01 gate itself | "Only the earning wallet can bridge." |
| 7 | `wrongNetwork` | selected network has no RPC (Super Genius): burn needs an EVM chain | "Bridge isn't available on this network." |
| 8 | `checking` | coins not yet loaded for the selected network | "Checking your GNUS balance." |
| 9 | `gnusElsewhere` | D-12 | "Your GNUS is on Base. Switch network to bridge." |
| 10 | `noGnus` | D-08 zero balance | "You have no GNUS to bridge." |
| 11 | `enabled` | - | none |

`switching` outranks `notStarted` because `_emitSDKAccounts` sets `selectedSDKAccount` to null whenever the SDK answers a placeholder (`clearSelectedSDKAccount: selected == null`, `app_bloc.dart:889-899`), which happens exactly while a switch lands.

### Anti-Patterns to Avoid
- **Reading `defaultSDKAccount` as the earning account.** It is the start account (`getStartAccountAddress`, `genius_api.dart:1534-1549`), used for the "Default account" tag and delete protection. It never follows a switch.
- **Matching GNUS by symbol alone.** On the Super Genius network the native coin is `symbol: network.symbol?.toUpperCase()` = `GNUS` with NO address (`read_asset.dart:236-245`). `bridgeOut` then gets `contractAddress: ""`. Match symbol AND non-empty address.
- **Caption inside the button's own Column on the coin page.** It is a `Wrap` child (`token_info_screen.dart:704`).
- **`_buildFoo()` helpers.** AGENTS.md: widgets, not helper methods.
- **Re-using `SGNUSConnection.walletAddress`.** Set once at init (`genius_api.dart:498-508`); that is the bug.

## Answers to the Seven Questions

### Q1. Selected wallet -> "is the earning account"

Facts, all read this session:
- `AppState` fields (`lib/bloc/app_state.dart:80-97`): `final String? selectedSDKAccount;` (live node account), `final String? switchingSDKAccount;` (target of a pending switch), `final List<String> sdkAccounts;`, `final String? defaultSDKAccount;` (start account), `final Map<String, SDKAccountLink> sdkAccountLinks;` ("keyed by lowercased SDK address").
- `typedef SDKAccountLink = ({String walletAddress, String walletName});` (`packages/local_secure_storage/lib/src/local_secure_storage_base.dart:18`). `saveSDKAccountLink` stores `walletAddress: walletAddress.toLowerCase()` and keys by `sdkAddress.toLowerCase()` (`:477-488`). `walletAddress` is the ETH wallet address (0x + 40 hex); an SDK address is `0x` + 128 hex (`sdkAddressOrNull`, `genius_api.dart:59-63`: `RegExp(r'^0x[0-9a-fA-F]{128}$')`).
- Before the node names an account: `getSelectedAccountAddress()` returns null when the SDK is not initialized or answers a placeholder (`genius_api.dart:1519-1530`), and AppBloc then clears `selectedSDKAccount`. `defaultSDKAccount` can already be non-null at that point (it falls back to the init-time `_address`), so it must not stand in.
- Existing helper `AppBloc.linkedWallet(sdkAddress, links, wallets)` (`app_bloc.dart:761-778`) goes SDK account -> own key wallet, excludes sgnus and tracking types, compares `wallet.address.toLowerCase() == link.walletAddress`. `AppBloc.sdkAccountFor(wallet, links)` (`:782-795`) goes the other way but returns the FIRST linked SDK account, which is wrong if two accounts link to one wallet.

Recommended rule (no new link logic, direction earning -> wallet so a duplicate link cannot fool it):

```dart
// Source: derived from app_bloc.dart:761-795 and local_secure_storage_base.dart:477-488
bool isEarningWallet(Wallet wallet, String earning, Map<String, SDKAccountLink> links) =>
    wallet.walletType == WalletType.sgnus
        ? wallet.address.toLowerCase() == earning.toLowerCase()
        : links[earning.toLowerCase()]?.walletAddress == wallet.address.toLowerCase();
```
The sgnus branch matters: the SDK account row (`WalletType.sgnus`, address = SDK address) is how the app already treats the earning account for balances (`WalletDetailsCubit._sdkReadFor` calls `sdkAccountFor`, which returns an sgnus wallet's own address, `wallet_details_cubit.dart:186-201`). Such a wallet fails `canSendFrom`, so `viewOnly` (rank 2) catches it before `notEarning`.

Compare lowercased everywhere; `selectedSDKAccount` is not lowercased in state.

### Q2. Child wallet vs view-only wallet

- View-only and "SDK account view": `canSendFrom(wallet, network)` (`lib/reown/utilities.dart:22-29`):
  ```dart
  bool canSendFrom(Wallet? wallet, Network? network) =>
      wallet != null &&
      wallet.walletType != WalletType.tracking &&
      wallet.walletType != WalletType.sgnus &&
      network != null &&
      canSignOn(network);
  ```
  `canSignOn` is `network.chainId != null && (network.rpcUrl ?? '').isNotEmpty` (`:19-20`). `WalletType` is `enum WalletType { tracking, privateKey, mnemonic, keystore, sgnus }` (`packages/genius_api/lib/types/wallet_type.dart:6`). `canSendFrom` mixes a wallet fact and a network fact, so it cannot give two distinct reasons. **Refactor first (behaviour-preserving):** extract `bool walletCanSign(Wallet wallet)` (the two type checks) and rewrite `canSendFrom` to call it plus `canSignOn`. Then `viewOnly = !walletCanSign(wallet)`, `wrongNetwork = !canSignOn(network)`. Callers of `canSendFrom`: `bridge_screen.dart:728`, `send_screen.dart:50`, `swap_screen.dart:469,750,1165`, `token_info_screen.dart:746,789`.
- **Gap CONTEXT.md did not see:** `canSendFrom` does NOT identify a child. A child that is one of the user's own accounts and linked to a key wallet is a normal `mnemonic`/`privateKey` wallet, so `canSendFrom` is true for it. The `Wallet` model has no child flag (`packages/genius_api/lib/models/wallet.dart`). The only source of truth is the SDK: `GeniusApi.getChildRegistrations(main)` (`genius_api.dart:1600-1612`) returning `ChildRegistrations` (`result` + `entries`, `isOk`).
- Existing child readers: `ChildOperationsCubit.ownRegistrations()` (`lib/child_wallets/child_operations_cubit.dart:219-257`) returns `Map<String lowerMain, List<ChildWallet>>` for every own SDK account, handles the dev-tools mock preset, and returns null when the node is down. `ChildWalletsCubit._findParentMain` (`child_wallets_cubit.dart:213-230`) is the same scan, private. `account_tree.dart` consumes `ownRegistrations()` for the switcher (`account_drawer.dart:224-244` caches it behind a key tuple).
- Recommended: `isChild` = the Selected wallet's SDK account appears as a `ChildWallet.address` (lowercased) under any other own main in `ownRegistrations()`. Compute it for the Selected wallet's account, not only the earning one, so a child that is not earning reads "child" rather than "switch earning". Cache it in `BridgeGateCubit`; recompute when `selectedSDKAccount`, `sdkAccounts`, `sdkAccountLinks`, the selected wallet or `ChildOperationsCubit.state` change. Never call it from `build`.
- Ceiling to record with a `ponytail:` comment (same as Phase 38 D-09): only mains the user owns are scanned; a child of a foreign main is undetectable because the SDK has no by-child query, so D-03 cannot be enforced for it. D-03 is product policy, not fund safety: a child that is the node's own account mints to itself.

### Q3. Resolve the GNUS coin; detect "only on another network"

- `WalletDetailsState` (`lib/wallets/cubit/wallet_details_state.dart:7-30`) holds `selectedWallet`, `selectedNetwork`, `selectedCoin`, `coins` (selected network only), `coinsNetwork` ("The network [coins] was loaded for ... until this equals [selectedNetwork] the list on state belongs to another chain"), `coinsStatus`, `balanceUnreadable`. It holds NOTHING about other networks.
- `Coin` fields (`packages/genius_api/lib/models/coin.dart:8-17`): `name, symbol, address, balance, networkSymbol, decimals, iconPath, coinGeckoId`.
- On EVM networks GNUS is an ERC-20 from the tokens JSON with `name: "GNUS"` and an `address`, read by `_fetchTokenData` (`read_asset.dart:177-210`) with `symbol` from the contract. I confirmed by script that `assets/json/tokens/` carries a `GNUS` entry with an address on all 8 EVM lists (`eth`, `eth_test_net`, `poly`, `poly_test_net`, `bnb`, `bnb_test_net`, `base`, `base_test_net`) and `{'name': 'GNUS', 'id': '0'}` (no address) on both Super Genius lists. Super Genius networks have `"rpcUrl": ""` in `assets/json/networks/networks.json`.
- Existing GNUS identification is by symbol: `token_info_screen.dart:251-253` (`selectedCoin?.symbol?.toLowerCase() == 'gnus'`), `assets_sort.dart:9` (`_kNativeSymbol = 'GNUS'`). Keep symbol (case-insensitive) AND require a non-empty `address` for the bridge coin (see anti-patterns).
- **Resolve:** `gnusCoin = coins.firstWhereOrNull(symbol.toLowerCase()=='gnus' && (address ?? '').isNotEmpty)`, valid only when `state.coinsNetwork == state.selectedNetwork`; otherwise `checking`. Balance `null` or `<= 0` -> not held here. This also fixes the coin page opened from Markets, where `selectedCoin` is unrelated: the gate no longer depends on `selectedCoin`.
- **GNUS elsewhere (D-12) needs a new read.** Probe set: networks from `NetworkProvider.networks` (provided at `main.dart:164`) that have a non-empty `rpcUrl`, a GNUS token with an address in `NetworkTokensProvider.getTokensByNetwork(network)` (`network_tokens_provider.dart`), the same `Network.testnet` flag as the selected one (`network.dart:28`), and a different `chainId`. Per network: `Web3().balanceOf(address: wallet, contractAddress: token.address!, rpcUrl: ...)` (`web3.dart:223`, two `eth_call`s). Run only when every rung above `gnusElsewhere` passed and the selected network's GNUS is not held. Cache by `(walletAddress.toLowerCase(), chainId)`, drop stale results with a generation counter (same trick as `_coinsGeneration`, `wallet_details_cubit.dart:324-326`), swallow per-network failures as "unknown, make no claim", skip entirely under `kDebugMode && kShowDevTools && walletDetailsCubit.mockMode`. First hit in `networks.json` order names the network (`network.name`). No polling (`ponytail:` ceiling: stale until wallet or network changes).

### Q4. Where button + caption fit; which blocs; `/bridge` needs `selectCoin`

- **Dashboard card.** `lib/components/wallet_overview.dart` builds only `ComputePanel` (`:239-264`) inside `BlocBuilder<AppBloc>` > `BlocBuilder<WalletDetailsCubit>` > `StreamBuilder<SGNUSConnection>`; it is mounted by `OverviewDashboardView` (`dashboard_screen.dart:422-437`). `ComputePanel` reads no bloc by design (doc at `compute_panel.dart:21-34`) and its column is `Compute` title, `_BalanceTile`, `_ComputeTile`, then the `New processing job` `GWButton` (`:144-166`). The Bridge slot belongs in that column, fed by two new OPTIONAL params (`BridgeGate? bridge`, `VoidCallback? onBridge`) so the 5 other `ComputePanel(` call sites (`test/components/gw_section_title_rhythm_test.dart:386`, `test/dashboard/compute_balance_unit_track_test.dart:96`, `compute_panel_height_test.dart:169`, `test/theme/compute_contrast_test.dart:45`, `test/wallets/balance_unreadable_view_test.dart:41`) compile unchanged. `lib/components/wallets_overview.dart` (plural) is a dead twin with the same class name; do not touch it.
- **Height budget is the constraint.** `kDashboardPanelSlotHeight = 340` (`dashboard_screen.dart:72`); `compute_panel_height_test.dart:127-129` derives the content budget `340 - 2*(space6+1) = 314`; the tallest state measures 306 (8px slack). Widths pinned: `_kRealisticPanelWidth = 320`, `_kNarrowPanelWidth = 290` (`:118-119`). A caption (`space2` 4 + 18px line) alone costs 22 > 8. Options, for UI-SPEC to settle:
  - **A (recommended):** Bridge `sm` beside `New processing job` in one Row (no extra row height), caption full width under the row. Cost is the caption only: raise the slot 340 -> 360 (slack 6). Risk: at the 290px case the content width is ~264px; `sm` has `space6` horizontal padding (`gw_button.dart:97-106`), Bridge with icon is ~100px, leaving ~156px for the job label, which may ellipsize (label is `Flexible`, ellipsis built in). If it does, drop Bridge's leading icon.
  - **B:** Bridge full width under the CTA: +8 +44 +22 = +74 on the tallest state, slot ~ 340 -> 416, and the desktop chart row loses ~76px.
  - Phones have no budget (`OneColumnDashBoardView` hands the panel unbounded height), so only desktop is capped.
  - Tests to update with the slot: `compute_panel_height_test.dart` (add a bridge-present case at both widths; the budget follows the constant), `gw_section_title_rhythm_test.dart:540` (derives from the constant).
- **Assets GNUS row.** `AssetsScreen._body` builds `CoinCardRow` per coin and calls `walletCubit.selectCoin(coin)` before `push('/token-info')` (`assets_screen.dart:600-626`); the page header comment calls that the one write and "load-bearing for `/bridge`" (`:64-67`). **CONTEXT.md says the GNUS row has an existing Receive action. It does not in this tree:** `CoinCardRow` has only `onTap` (`coin_card_row.dart:23-39`), and Receive / Buy GNUS exist only as the dashboard panel footer (`coins_screen.dart:480-513`) and the empty-wallet state of `/assets` (`assets_screen.dart:544-580`). Recommended: insert the Bridge button (`gradientOutline`, `sm`) and caption between the GNUS `CoinCardRow` and its `Divider` in the `_body` loop (match by `coin.address == gate.coin?.address`), padded to the row wall (`GeniusWalletConsts.space4`); leave `CoinCardRow` untouched because `test/components/gw_row_rhythm_test.dart` and `gw_section_title_rhythm_test.dart` pin its anatomy. `orderAssets` shows only GNUS when a wallet holds nothing (`assets_sort.dart:68-83`), so the GNUS row is the one row an empty wallet always has; the Bridge entry therefore always has a home there when the wallet holds a listed GNUS token.
- **Coin page.** `_CoinActionRow` is a `Wrap` of Swap, Send, Receive, Bridge, Buy (`token_info_screen.dart:704-811`). Replace `if (isGnusBridgeEnabled && canSendFrom(...))` (`:789`) with `if (pageSymbol == 'gnus')` (the exact test Buy already uses, `:803`) rendering `BridgeButton`; render the caption on its own line below the `Wrap`. `test/tokens/coin_page_stat_rail_test.dart:213-240` ("no Bridge on a coin that isn't GNUS") stays true, but its comment about `isGnusBridgeEnabled` goes stale.
- **Blocs in scope on all three:** `WalletDetailsCubit` (provided at `main.dart:402-407`) and AppBloc (`:417-427`) are root providers; surfaces read only `BridgeGateCubit` (root provider, declared after AppBloc and `ChildOperationsCubit`). `ChildOperationsCubit` is already read nullably in the drawer because "a host that never wires it (an older test harness...) simply has nothing" (`account_drawer.dart:445-448`); use the same nullable read (`context.watch<BridgeGateCubit?>()`) with a fallback `checking` gate, so the ~10 existing harnesses that pump `AssetsScreen`/`TokenInfoScreen` need no new provider.
- **Opening `/bridge`.** The route builds `BridgeScreen(fromToken: walletCubit.state.selectedCoin)` from `context.read<WalletDetailsCubit>()` (`router.dart:304-313`); `extra` is ignored. `BridgeScreen` takes `fromToken` for contract, balance, symbol and uses `state.selectedNetwork` as the source chain (`bridge_screen.dart:310-318`). So the shared handler must `selectCoin(gate.coin)` first. Move `_pushBridgeScreen` (`token_info_screen.dart:46-52`: push, then `getCoins()` to refresh the balance) into `bridge_entry.dart` as `openGnusBridge(context)`; it re-reads the gate at tap time (BRDG-07).

### Q5. Can the router's StreamBuilder go?

Yes. `isGnusWalletConnected` has exactly one producer and one consumer in `lib/`:
- Produced at `router.dart:286-299` (`StreamBuilder<SGNUSConnection>`, `(snapshot.data?.walletAddress ?? false) == walletCubit.state.selectedWallet?.address`, a case-sensitive compare).
- Consumed at `token_info_screen.dart:132,148,252` only.
- Everything else is comments (`token_info_args.dart:62,70`, `dashboard_screen.dart:789`, `markets_screen.dart:63`).
- Other `SGNUSConnection` readers stay untouched per D-02: `wallet_overview.dart:193`, `wallet_information.dart:212`, `network_page.dart:132`, `app_bloc.dart:744,846`, `compute_state.dart`.

Edit list: delete the StreamBuilder and the `isGnusWalletConnected` constructor param/field; **remove `import 'package:genius_api/models/sgnus_connection.dart';` from `router.dart:6`** (only use is `:286`; `flutter analyze` exits non-zero on infos, so a dangling import fails the gate; the `genius_api.dart` import stays, `GeniusApi` is used at `:119,134,320`); update the constructor calls in 4 test files: `test/banxa/buy_entry_points_test.dart:104-107`, `test/tokens/coin_page_entry_parity_test.dart:112,123-126`, `test/tokens/coin_page_range_tile_test.dart:90-93`, `test/tokens/coin_page_stat_rail_test.dart:51-58,119-122`. The census test `coin_page_entry_parity_test.dart:178` (no push carries the flag) keeps passing. Keep the legacy-map branch in `TokenInfoArgs.fromExtra` (its own comment forbids deleting it).

### Q6. Muted caption tokens and existing caption widgets

- Use `gw.textSecondary` with `GeniusWalletTypography.bodySm` or `labelMd`. Dark `0xFF8A8F9D` (`genius_wallet_colors` source), light `const Color(0xFF5A606E)` (`gw_colors.dart:335`, comment "6.3:1"). `test/theme/theme_contrast_test.dart:610-621` already asserts `textSecondary` on `surfaceElevated` >= 4.5 in both modes; `coin_card_row.dart` records 6.01:1 for it on dark `surfaceBase`. The three Bridge sites sit on `DashboardScrollContainer` (card surface) or the page base, so no new token is needed.
- Do NOT use `textMutedOnSunken` (`gw_colors.dart:282`, for text painted directly on `surfaceSunken`), `textDisabled`, `textTertiary`, or any `textPrimary<NN>` alpha below 70 for the caption; none is asserted AA on these surfaces. The compute panel's own sub-line recipe is `numericBody.copyWith(fontSize: 13, height: 18/13, color: gw.textSecondary)` (`compute_panel.dart:180-181`); reuse the metrics (18px line) when sizing the dashboard budget.
- Existing widgets: `GWWarningNote` (`gw_warning_note.dart`) is a bordered amber box: too heavy for a one-line caption. `_AccountSectionNote` (`account_drawer.dart:958-982`) is private and boxed. There is no reusable one-line caption widget; write `BridgeReasonCaption` (a `Text`, `maxLines: 1`, ellipsis, `textSecondary`). One consumer type, three call sites: fine under the Rule of Three.
- Screen readers: a `Text` is announced by default. Wrap button + caption in `Semantics(container: true)` per surface only if reading order proves wrong; assert with `find.bySemanticsLabel(caption)` in the widget test. `GWButton` dims a disabled `gradientOutline` itself (alpha 140 on gradient and label, transparent fill kept; `gw_button.dart:217-239,346-362`, pinned by `gw_button_disabled_test.dart`).

### Q7. Test patterns

- Pure resolver to copy: `test/dashboard/bridge/bridge_cta_state_test.dart` (plain `flutter_test`, `group` per rung, `expect(state, X)` + enabled + label, plus an exhaustive "only ready is enabled" loop). I ran it this session: 16 passed.
- Pure-resolver distinctness idiom: `test/dashboard/compute_state_distinct_test.dart` (iterates `ComputeState.values`); copy it so two `BridgeGate` states can never render the same caption.
- Cubit/widget doubles already in use: `_UnusedApi implements GeniusApi` with `noSuchMethod` (`test/dashboard/assets_screen_test.dart:50-53`, `test/banxa/buy_entry_points_test.dart:28-31`); `_SeededAppBloc extends AppBloc` with `runNodeAs` (`test/dashboard/compute_panel_wiring_test.dart:78-98`); `_SeededWalletDetailsCubit` (`:105-115`); `WalletDetailsCubit(initialState: ...)` seeding with `coins`, `coinsNetwork`, `selectedWallet`, `selectedNetwork` (`buy_entry_points_test.dart:57-70`); a `GoRouter` host that records `/buy` extras (`:76-101`), reusable as a `/bridge` recorder. AppBloc teardown needs `tester.runAsync(appBloc.close)` (`compute_panel_wiring_test.dart:136-143`).
- Contrast helpers: `contrastRatio` and `themeFor` exported from `test/theme/theme_contrast_test.dart:21` (imported by `compute_contrast_test.dart:15`, `gw_button_disabled_test.dart:6`).
- Entry-point precedent: `test/banxa/buy_entry_points_test.dart` pumps real `CoinsScreen`, `AssetsScreen`, `TokenInfoScreen` and asserts the pushed route; the 360px no-overflow loop in both modes (`:195-213`) is the template for the new coin-page and card checks.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| SDK account -> wallet link | a second link lookup | `links[earning.toLowerCase()].walletAddress` / `AppBloc.linkedWallet` | Lowercase keying already normalised at write |
| Child parent lookup | another registrations scan | `ChildOperationsCubit.ownRegistrations()` | Already handles dev mock preset and node-down |
| Per-network GNUS balance | new RPC client | `Web3().balanceOf` | Existing, used by `fetchCoinBalance` |
| Can-sign rule | a third copy of the tracking/sgnus check | extract `walletCanSign`, keep `canSendFrom` | One source of truth |
| Button styling | a custom outlined button | `GWButton(gradientOutline, sm)` | D-06; disabled look is built in |
| Contrast maths | ad-hoc luminance | `contrastRatio` in `theme_contrast_test.dart` | Already the repo's measure |

**Key insight:** the earning check is a one-liner; the cost is entirely in the two reads (children, other networks) that no state exposes. Keep both behind one cubit so three surfaces share one cache.

## Runtime State Inventory

Not a rename/refactor/migration phase. Omitted.

## Common Pitfalls

### Pitfall 1: Stale gate at tap time
**What goes wrong:** the gate was true at render; an earning switch started before the tap; `bridgeOut` burns with the selected wallet's key (`genius_api.dart:1869-1882`) and `GeniusSDKMint` credits the node's current account (`:1884-1893`, `:932`), i.e. the misdirected-funds bug this phase exists to prevent. `bridgeOut` itself has no earning check.
**How to avoid:** `openGnusBridge` re-resolves the gate from live state at the tap and returns if not enabled (BRDG-07). Open Question 3 covers a submit-time guard.

### Pitfall 2: GNUS "found" on Super Genius
**What goes wrong:** symbol-only match returns the native SG coin with no address; `/bridge` opens with an empty contract.
**How to avoid:** require non-empty `address`; `wrongNetwork` (rank 7) catches RPC-less networks first.

### Pitfall 3: "No GNUS" flash while loading
**What goes wrong:** `coins` is empty until `getCoins` lands; a network switch lands before the new list (`coinsNetwork` doc, `wallet_details_state.dart:22-25`).
**How to avoid:** `checking` rung when `coinsNetwork != selectedNetwork` or status is loading with no coins.

### Pitfall 4: Height overflow in the compute slot
**What goes wrong:** tallest state 306 vs 314; a caption alone blows it; `WalletsOverview` wraps the panel in a `SingleChildScrollView` so it scrolls instead of throwing, which hides the regression from the eye.
**How to avoid:** change the slot constant and extend `compute_panel_height_test.dart` with a disabled-with-caption case at both widths.

### Pitfall 5: Case mismatches
**What goes wrong:** the route's old compare is case-sensitive (`router.dart:290-291`); SDK addresses are mixed case in state, lowercase in links.
**How to avoid:** lowercase both sides in the resolver; one test with mixed-case inputs.

### Pitfall 6: Switch pending reports a stale earning account
**What goes wrong:** during a switch `selectedSDKAccount` may name the old account or be null (`app_bloc.dart:883-899`, `909-946`; polled every 3s until it names one).
**How to avoid:** `switching` ranks above `notStarted` and `notEarning`.

### Pitfall 7: Existing harnesses break on a new required provider
**What goes wrong:** `TokenInfoScreen`/`AssetsScreen` tests provide only `WalletDetailsCubit`.
**How to avoid:** nullable read with a fallback gate (precedent `account_drawer.dart:445-448`), new tests provide a seeded `BridgeGateCubit`.

## Code Examples

### Resolver skeleton
```dart
// Source: shape of lib/dashboard/bridge/bridge_cta_state.dart:12-112
enum BridgeGateState {
  noWallet, viewOnly, child, switching, notStarted, notEarning,
  wrongNetwork, checking, gnusElsewhere, noGnus, enabled,
}

BridgeGateState resolveBridgeGate({
  required bool hasWallet,
  required bool walletCanSign,
  required bool isChild,
  required bool isSwitching,
  required String? earningAccount,
  required bool isEarningWallet,
  required bool networkCanSign,
  required bool coinsReady,
  required double? gnusBalance,
  required bool gnusElsewhere,
}) {
  if (!hasWallet) {
    return BridgeGateState.noWallet;
  }
  if (!walletCanSign) {
    return BridgeGateState.viewOnly;
  }
  if (isChild) {
    return BridgeGateState.child;
  }
  if (isSwitching) {
    return BridgeGateState.switching;
  }
  if (earningAccount == null) {
    return BridgeGateState.notStarted;
  }
  if (!isEarningWallet) {
    return BridgeGateState.notEarning;
  }
  if (!networkCanSign) {
    return BridgeGateState.wrongNetwork;
  }
  if (!coinsReady) {
    return BridgeGateState.checking;
  }
  if ((gnusBalance ?? 0) > 0) {
    return BridgeGateState.enabled;
  }
  return gnusElsewhere ? BridgeGateState.gnusElsewhere : BridgeGateState.noGnus;
}
```

### Shared open handler
```dart
// Source: lib/tokens/token_info_screen.dart:46-52 (moved), gate re-read added
Future<void> openGnusBridge(BuildContext context) async {
  final walletCubit = context.read<WalletDetailsCubit>();
  final gate = context.read<BridgeGateCubit>().state;
  final coin = gate.coin;
  if (gate.state != BridgeGateState.enabled || coin == null) {
    return;
  }
  walletCubit.selectCoin(coin);
  await GoRouter.of(context).push('/bridge');
  walletCubit.getCoins();
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Gate on `SGNUSConnection.walletAddress == selectedWallet.address` | Gate on `selectedSDKAccount` + `sdkAccountLinks` | this phase | Bridge no longer vanishes for every wallet but the start-up one |
| Bridge hidden unless gated | Bridge always visible, disabled with a reason | this phase | The bug fix |

**Deprecated/outdated:** `isGnusWalletConnected` on `TokenInfoScreen`. ROADMAP line refs (`token_info_screen.dart:794`, `router.dart:384`, `genius_api.dart:263`, `:1830`) are stale; real lines are `:789-802`, `router.dart:286-299`, `genius_api.dart:498-508`, `:1860`.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | The proposed caption strings are acceptable Earning-terminology copy | Pattern 1 | Low; D-10 leaves strings to the planner |
| A2 | Probing only networks with the same `testnet` flag as the selected one is the right scope for D-12 | Q3 | A mainnet user with GNUS only on a testnet is not told; arguably correct, needs user nod |
| A3 | One `balanceOf` per other network (<= 3 per class today) is acceptable RPC load, run once per wallet/network change | Q3 | Public RPC rate limits (networks.json carries chainstack URLs); failures degrade to "no claim" |
| A4 | Raising `kDashboardPanelSlotHeight` 340 -> 360 is acceptable to the user | Q4 | Visible desktop layout change; this is a UI-SPEC call |
| A5 | At the 290px panel width the job label ellipsizes if Bridge sits beside it with an icon | Q4 | Measured by arithmetic only; the height/width test must pump it |
| A6 | A child of a foreign main being undetectable is an acceptable ceiling for D-03 | Q2 | A foreign-main child could still bridge; same ceiling as Phase 38 |
| A7 | Readers of `isGnusWalletConnected` are only the router and `TokenInfoScreen` | Q5 | Verified by grep over `lib/` and `test/` this session; low |

## Open Questions (RESOLVED)

1. **Dashboard card placement and slot growth (A or B).**
   - Known: 8px slack, caption costs 22, slot constant feeds three layouts and two tests.
   - Unclear: whether Jakub accepts +20 (A) or +76 (B) on desktop.
   - Recommendation: settle in UI-SPEC (`ui_phase` is on); default to A.
   - RESOLVED: A, slot 340 -> 360, Bridge beside "New processing job" (user, 2026-10-07; UI-SPEC).
2. **Which "Assets" surface?** CONTEXT names "the GNUS row on Assets" and an existing Receive action that is not in the tree.
   - Recommendation: `/assets` page only (`assets_screen.dart`); the dashboard overview card covers Home. Confirm with the user whether the Home Assets panel (`coins_screen.dart`) should also carry one.
   - RESOLVED: `/assets` page only (D-14).
3. **Submit-time guard.** `bridgeOut` (`genius_api.dart:1860`) has no earning check and CONTEXT says the bridge is unchanged. The tap-time re-read narrows the window but a switch started while `BridgeScreen` is open (mobile has no header there, so unlikely) still lands.
   - Recommendation: ship the tap-time re-read; record a follow-up todo for a `BridgeScreen` submit-time check rather than widening this phase.
   - RESOLVED: the user chose a submit-time refusal in this phase (D-13, BRDG-08).
4. **D-12 cost.** Naming the other network requires new RPC reads; if the user wants no new network calls, fall back to `noGnus` with generic copy. Recommendation: keep D-12 as locked.
   - RESOLVED: D-12 kept with cached per-network reads (user, 2026-10-07).
5. **Copy for an SDK account view** (`WalletType.sgnus`, reached via "View balance"): currently shares `viewOnly` copy. A dedicated line ("Pick this account's wallet to bridge.") may read better; planner's call.
   - RESOLVED: shares the viewOnly caption, per UI-SPEC row 2.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| Flutter SDK | analyze, tests | yes (not on PATH) | 3.41.9 at `C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin` | - |
| Worktree deps | tests | yes (`.dart_tool` present) | - | `flutter pub get` |
| Live testnet | live walk | blocked per STATE.md precondition flag | - | Dev-tools mock presets (`DevMockChildWallets`) cover child states; `notEarning` etc. need two linked accounts |
| python3 | not needed by plans | yes | - | - |

Not run this session: `flutter analyze` and the full `flutter test` (executor-only per AGENTS.md). Run this session: `flutter test test/dashboard/bridge/bridge_cta_state_test.dart` -> `+16: All tests passed!`.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | flutter_test (Flutter 3.41.9) |
| Config file | none (default); `analysis_options.yaml` for lints |
| Quick run command | `export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"; flutter test test/dashboard/bridge/` |
| Full suite command | `flutter test` (executor only), then `flutter analyze` (check `$?`, it exits 1 on infos), `bash tool/check_brace_style.sh`, `bash tool/check_raw_colors.sh`, `dart format --set-exit-if-changed lib test` |

### Phase Requirements -> Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| BRDG-02 | enabled only when selected wallet is the live earning account; mixed-case addresses; sgnus wallet path; duplicate link cannot fool it | unit | `flutter test test/dashboard/bridge/bridge_gate_test.dart` | Wave 0 |
| BRDG-03 | viewOnly / child / sgnus view each map to their own state; precedence viewOnly > child > switching > notStarted > notEarning | unit | same | Wave 0 |
| BRDG-05 | precedence table, one caption per state, all captions distinct and non-empty, only `enabled` is enabled | unit (iterate `values`) | same | Wave 0 |
| BRDG-06 | `gnusElsewhere` caption names the network; no network name when none | unit | same | Wave 0 |
| BRDG-02/03/06 | cubit recomputes on earning switch, wallet change, network change; probe runs only when earlier rungs pass; stale probe dropped; failed probe makes no claim; child lookup via `ownRegistrations` | unit w/ fakes | `flutter test test/dashboard/bridge/bridge_gate_cubit_test.dart` | Wave 0 |
| BRDG-01 | Bridge button present on card, Assets GNUS row, GNUS coin page, in every state (never absent); non-GNUS coin page has none | widget | `flutter test test/dashboard/bridge/bridge_entry_test.dart` | Wave 0 |
| BRDG-01 | enabled tap calls `selectCoin(gate.coin)` then pushes `/bridge`; disabled tap pushes nothing | widget (router recorder) | same | Wave 0 |
| BRDG-04 | caption visible under disabled button without hover, found by semantics label, one line | widget | same | Wave 0 |
| BRDG-04 | `textSecondary` on `surfaceBase` and `surfaceElevated` >= 4.5 in both modes | unit (`contrastRatio`) | same | Wave 0 |
| BRDG-04 | coin page at 360px, both modes, caption row present, no overflow | widget | extend `test/banxa/buy_entry_points_test.dart:195-213` | exists, extend |
| BRDG-01 | compute panel with bridge slot fits slot budget at 320 and 290, both units, disabled-with-caption worst case | widget | `flutter test test/dashboard/compute_panel_height_test.dart` | exists, extend |
| BRDG-07 | tap-time re-read: gate flips to `switching` between render and tap -> no push | widget | `bridge_entry_test.dart` | Wave 0 |
| BRDG-07 | no `isGnusWalletConnected` left in `lib/` | source scan | `grep -rn isGnusWalletConnected lib` returns only comments or nothing | Wave 0 (one assertion) |
| - | `canSendFrom` unchanged after `walletCanSign` split | unit | existing swap/send/reown tests + add 4-row table | extend |

### Sampling Rate
- **Per task commit:** `flutter test test/dashboard/bridge/ test/tokens/ test/banxa/buy_entry_points_test.dart`
- **Per wave merge:** `flutter test test/dashboard/ test/components/ test/theme/ test/wallets/ test/tokens/ test/banxa/`
- **Phase gate:** full `flutter test`, `flutter analyze` (check `$?`), brace and raw-colour scripts, `dart format` clean; then a live walk (VER-02 stance: blocked on testnet, record as a gap, not a skip).

### Wave 0 Gaps
- [ ] `test/dashboard/bridge/bridge_gate_test.dart`: covers BRDG-02/03/05/06
- [ ] `test/dashboard/bridge/bridge_gate_cubit_test.dart`: covers cubit recompute + probes
- [ ] `test/dashboard/bridge/bridge_entry_test.dart`: covers BRDG-01/04/07
- [ ] Seeded `BridgeGateCubit` helper for widget tests (one small subclass, same style as `_SeededAppBloc`)
- [ ] Update 4 test files that construct `TokenInfoScreen` (drop `isGnusWalletConnected`)

## Security Domain

`security_enforcement` is not set to false in `.planning/config.json` (key absent), so this section applies.

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | - |
| V3 Session Management | no | - |
| V4 Access Control | yes | The gate is the control: a wallet that is not the earning account must not reach the burn. Enforced in the resolver, re-checked at tap |
| V5 Input Validation | yes | Lowercase-normalised address compare; accept only `0x` + 128 hex SDK addresses via existing `sdkAddressOrNull` |
| V6 Cryptography | no | no key material touched |
| V7 Error handling / logging | yes | Never log or put addresses-with-keys in state; gate state holds public addresses only (the existing `sdkAccountLinks` precedent: "public addresses and a display name only") |

### Known Threat Patterns

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|---------------------|
| Burn on wallet A, mint to node account B (the motivating defect) | Tampering / funds loss | Earning-wallet gate + tap-time re-read; follow-up submit-time check (Open Question 3) |
| TOCTOU between render and tap during an earning switch | Tampering | `openGnusBridge` re-resolves from live state; `switching` rung outranks others |
| Spoof token named GNUS | Spoofing | Coins come only from curated `assets/json/tokens`; additionally require non-empty address |
| Private key/mnemonic leaking into the new cubit state | Information disclosure | State is `BridgeGate` (enum, `Coin`, `Network?`); no wallet secrets; AGENTS.md wallet-safety rules; run `tool/check_no_new_key_logging.sh` |
| Untrusted RPC response for the elsewhere probe | Spoofing | Probe result only changes a caption; it can never enable Bridge |

## Project Constraints (from CLAUDE.md / AGENTS.md)

- Lazy-senior ladder: reuse before writing; no new dependency; fewest files. Mark deliberate corners with `ponytail:` naming ceiling and upgrade path (child scan, probe staleness, own-accounts-only).
- Every Dart `if` braced, body on its own line (`tool/check_brace_style.sh` enforces). No one-line `if (x) { return; }`.
- Widgets, not `_buildFoo()` helper methods. Rule of Three: Bridge has three call sites, so shared widgets are justified; do not add a boolean-flag variant.
- Colours from `GWColors` tokens only; no `Colors.*`/`Color(0x...)` outside `lib/theme/`; correct in both modes, WCAG AA; re-read theme inside `build`, never cache.
- Widgets must not reach past the repository layer: no FFI, `http`, Hive in a widget; go through a cubit.
- Wallet safety: no key or mnemonic on a Cubit/Bloc state; never log secrets.
- Comments: minimal, only the why; no plan/phase/sketch/spec numbers in source; no test-file names in source; doc comments 3 lines max.
- Do not create commits (GSD atomic commits are separately authorised for this branch); never add Claude attribution to commits or PRs; no PR without authorisation.
- Files under repo-root `banxa/` and `squidrouter/` are generated: do not change. `lib/banxa/`, `lib/squid_router/` are normal.
- Before calling done: `dart format`, `flutter analyze` (check `$?`), `flutter test`; quote real output. Flutter is not on PATH.
- Earning terminology in user copy: Earning / earning wallet; never node, SDK, minting.
- Parallel sessions: only the executor commits/stages, runs the full suite, edits `lib/`, `test/`. PLAN.md <= 150 lines, SUMMARY.md <= 40.
- C++ rules in AGENTS.md do not apply (Dart phase).

## Sources

### Primary (HIGH confidence): files opened with Read this session
- `.planning/phases/40-always-available-gnus-bridge/40-CONTEXT.md`, `40-DISCUSSION-LOG.md`, `.planning/REQUIREMENTS.md`, `.planning/STATE.md`, `.planning/ROADMAP.md` (Phase 40 entry)
- `lib/bloc/app_state.dart`, `lib/bloc/app_bloc.dart` (:56-135, 730-1040), `lib/reown/utilities.dart`
- `lib/dashboard/bridge/bridge_cta_state.dart`, `bridge_screen.dart` (grep + :90-260)
- `lib/tokens/token_info_screen.dart` (:1-340, 630-890), `lib/navigation/router.dart` (:1-60, 240-331)
- `lib/dashboard/assets/assets_screen.dart`, `assets_sort.dart`, `lib/components/coins/view/coins_screen.dart`, `coin_card_row.dart`
- `lib/components/wallet_overview.dart`, `lib/dashboard/compute/compute_panel.dart`, `compute_state.dart`, `lib/dashboard/home/view/dashboard_screen.dart`
- `lib/wallets/cubit/wallet_details_cubit.dart`, `wallet_details_state.dart`, `lib/assets/read_asset.dart`, `lib/services/coins_service.dart`
- `lib/account/account_tree.dart`, `account_drawer.dart` (:140-160, 215-300, 410-565), `lib/child_wallets/child_wallets_cubit.dart`, `child_operations_cubit.dart` (:100-300)
- `lib/main.dart` (:150-210, 380-480), `lib/theme/gw_colors.dart` (token declarations), `lib/components/buttons/gw_button.dart`, `gw_warning_note.dart`
- `packages/genius_api/lib/src/genius_api.dart` (:470-720, 906-945, 1515-1625, 1855-1915), `models/network.dart`, `models/coin.dart`, `models/wallet.dart`, `types/wallet_type.dart`, `web3/web3.dart` (balanceOf)
- `packages/local_secure_storage/lib/src/local_secure_storage_base.dart` (:14-20, 440-520)
- `assets/json/networks/networks.json`, `bridge.json`, `assets/json/tokens/*.json` (parsed by script)
- Tests: `test/dashboard/bridge/bridge_cta_state_test.dart`, `compute_panel_height_test.dart`, `compute_panel_wiring_test.dart`, `assets_screen_test.dart`, `test/banxa/buy_entry_points_test.dart`, `test/tokens/coin_page_entry_parity_test.dart`, `coin_page_stat_rail_test.dart`, `test/theme/theme_contrast_test.dart`, `test/components/gw_button_disabled_test.dart`
- Executed: `flutter test test/dashboard/bridge/bridge_cta_state_test.dart` (16 passed, Flutter 3.41.9)

### Secondary / Tertiary
- None. No web or Context7 lookups were needed; this phase is entirely in-repo.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH, nothing new
- Architecture: HIGH for gate, cubit and handler; MEDIUM for dashboard placement (arithmetic, not a pump)
- Pitfalls: HIGH, each traced to a file and line

**Research date:** 2026-10-07
**Valid until:** 2026-10-21 (the tree moves fast: phases 39 and 40 landed within days; re-check `compute_panel.dart` and `assets_screen.dart` line numbers at execution time, per the "plans rot" rule)
