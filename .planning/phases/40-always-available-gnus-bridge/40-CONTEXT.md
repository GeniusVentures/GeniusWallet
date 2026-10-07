# Phase 40: Always-available GNUS bridge - Context

**Gathered:** 2026-10-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Bridge can always be found. A Bridge entry sits on the dashboard wallet overview, the Assets GNUS row and
the GNUS coin page, and opens the GNUS bridge for the Selected wallet. When that wallet cannot bridge,
the button stays visible and disabled, with a one-line reason under it. The bridge itself (burn on the
source chain, mint through the SDK) is unchanged.

Why the gate exists: `bridgeOut` signs the burn with the selected wallet's own key, but the mint goes
through `GeniusSDKMint`, which credits whichever account the node currently runs (the earning account).
Bridging from any other wallet would burn that wallet's GNUS and mint into a different account. The
current gate compares against `SGNUSConnection.walletAddress`, which is set once at SDK init
(`genius_api.dart` ~line 498) and never follows an earning switch, so Bridge disappears for every wallet
except the start-up one.

</domain>

<decisions>
## Implementation Decisions

### Who can bridge
- **D-01:** Bridge is enabled only when the Selected wallet is the current earning account. Otherwise
  it is disabled with a reason. No "switch earning, then bridge" flow, and no burn-only path.
- **D-02:** The gate reads the live earning account: the ETH wallet linked to
  `AppState.selectedSDKAccount` via `AppState.sdkAccountLinks`. It does not read the stale
  `SGNUSConnection.walletAddress`. That stream and its other readers (`wallet_overview.dart`,
  `compute_state.dart`) are left as they are.
- **D-03:** Child wallets cannot bridge. Bridge is disabled with a reason.
- **D-04:** One pure-Dart function owns the gate and the reason, used by all three surfaces. Its
  precedence and copy are tested in one small test file.

### Where Bridge sits
- **D-05:** Three surfaces: the dashboard wallet overview card, the GNUS row on Assets, and the GNUS
  coin page. The existing coin-page button moves to the new gate and is disabled instead of hidden.
- **D-06:** The wallet overview gets a single Bridge button (`GWButton`, `gradientOutline`, `sm`, the
  same treatment as the coin page). No other actions are added to the card.
- **D-07:** No new nav destination. The desktop bar stays at 8 tabs and the mobile bar is unchanged.

### Disabled reasons
- **D-08:** Each of these states gets its own reason line: not the earning wallet; earning switch
  pending (`switchingSDKAccount != null`); earning not started (no `selectedSDKAccount`); no GNUS
  (zero balance); view-only or child wallet (cannot sign, see `canSendFrom`).
- **D-09:** The reason is a muted one-line caption under the disabled button, visible without hover,
  and exposed to screen readers. No tooltip.
- **D-10:** Copy uses the Earning terminology (Earning / earning wallet), never node, SDK or minting.
  Exact strings are up to the planner, one short sentence each.

### Entry without a coin
- **D-11:** Bridge opened from the dashboard or Assets starts on the Selected wallet's GNUS coin on the
  selected network, the same as the coin page.
- **D-12:** If the wallet holds no GNUS on the selected network but does on another one, Bridge is
  disabled and the reason names that network (for example "Your GNUS is on Base. Switch network to
  bridge."). No chain picker and no automatic network switch. Confirmed after research: one balance
  read per other network is acceptable, cached in an app-level cubit.

### Added after research (2026-10-07)
- **D-13:** The bridge refuses at submit time as well. BridgeScreen re-checks the earning gate before
  calling `bridgeOut` and refuses with the same reason. This narrows "the bridge itself is unchanged"
  to the burn and mint mechanics. The tap handler re-reads the gate too.
- **D-14:** "Assets" means the `/assets` page only. Bridge and its caption sit under the GNUS row
  there. The dashboard panel's asset list is not touched.
- **D-15:** The GNUS coin is matched by symbol plus a non-empty contract address, so the Super Genius
  native GNUS (no address) never opens `/bridge`.

### Claude's Discretion
- Exact reason strings, the precedence between overlapping states, and how the GNUS coin is resolved
  for the selected wallet and network.
- Contrast of the reason caption must meet WCAG AA in both appearance modes, using GWColors tokens.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Bridge today
- `lib/tokens/token_info_screen.dart` - the existing Bridge button (`isGnusBridgeEnabled`,
  `canSendFrom`, `_pushBridgeScreen`)
- `lib/navigation/router.dart` - the `/bridge` route and the `isGnusWalletConnected` StreamBuilder gate
- `lib/dashboard/bridge/bridge_screen.dart` - `BridgeScreen(fromToken:)`, the `bridgeOut` call with
  `shouldMintTokens: true`
- `lib/dashboard/bridge/bridge_cta_state.dart` - an example of a pure-Dart state ladder used in this repo
- `packages/genius_api/lib/src/genius_api.dart` - `bridgeOut`, `mintTokens` (`GeniusSDKMint`), and the
  start-up `SGNUSConnection` emit

### Earning account state
- `lib/bloc/app_state.dart` - `selectedSDKAccount`, `switchingSDKAccount`, `sdkAccountLinks`,
  `defaultSDKAccount`
- `lib/bloc/app_bloc.dart` - `_onSelectSDKAccount`, `_emitSDKAccounts`

### Surfaces
- `lib/components/wallet_overview.dart` - the dashboard wallet overview card
- `lib/dashboard/assets/assets_screen.dart` - the Assets rows (`CoinCardRow` has only `onTap`, no
  actions; `selectCoin` on row tap is load-bearing for `/bridge`)
- `.planning/phases/40-always-available-gnus-bridge/40-RESEARCH.md` - gate states, precedence,
  dashboard height budget

### Project rules
- `AGENTS.md` - brace rule, widgets not helpers, GWColors tokens, no repository access from widgets

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `canSendFrom(wallet, network)`: already decides whether a wallet can sign; reuse it for the
  view-only/child reason.
- `GWButton` with `gradientOutline` + `sm`: the coin page's Bridge treatment.
- `bridge_cta_state.dart` pattern: an enum plus a resolver function with no Flutter imports, easy to
  unit-test.

### Established Patterns
- `/bridge` reads `WalletDetailsCubit.state.selectedCoin`, so a new entry must call `selectCoin`
  with the GNUS coin before pushing.
- The earning-account switch is asynchronous, and the pending state is `switchingSDKAccount`.

### Integration Points
- AppBloc state (`selectedSDKAccount`, `sdkAccountLinks`, `switchingSDKAccount`) plus
  WalletDetailsCubit (selected wallet, network, coins) feed the gate on all three surfaces.

</code_context>

<specifics>
## Specific Ideas

- Bridge stays visible on all three surfaces. Being hidden is the bug this phase fixes.

</specifics>

<deferred>
## Deferred Ideas

- Re-emitting `SGNUSConnection.walletAddress` on every earning switch would also correct the compute
  panel and wallet overview readers. This is a separate fix in `genius_api`.
- A "switch earning to this wallet, then bridge" flow.
- A source-chain picker on BridgeScreen.

### Reviewed Todos (not folded)
- The todo matcher returned only keyword noise (light-mode backlog, type scale, checkout sheet, delete
  wallet drawer). None is about the bridge.

</deferred>

---

*Phase: 40-always-available-gnus-bridge*
*Context gathered: 2026-10-07*
