---
quick_id: 260731-hsb
phase: quick-260731-hsb
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: false
branch: redesign/jakub-260730
commit: false
files_modified:
  - lib/tokens/token_info_args.dart
  - lib/tokens/token_info_screen.dart
  - lib/navigation/router.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/dashboard/chart/dashboard_markets.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/dashboard/home/view/dashboard_screen.dart
  - test/tokens/coin_page_entry_parity_test.dart
  - test/tokens/coin_page_stat_rail_test.dart
  - test/tokens/coin_page_range_tile_test.dart

must_haves:
  truths:
    - "Tapping USD Coin in the dashboard Assets panel opens the coin page with a price, a chart, the stat rail and real INFO numbers - not the 'No market data' card."
    - "A coin the market-data provider genuinely does not cover still opens, still shows Receive, and says so - unchanged from today."
    - "A transient market-data failure (rate limit, timeout) shows a retryable error on the coin page instead of the terminal 'not covered' wording."
    - "The back link names the panel the user actually came from: ASSETS from the Assets panel, MARKETS from either Markets surface."
    - "Every `/token-info` push in lib/ passes the same typed payload, and a fourth push site that does not fails a test rather than shipping."
  artifacts:
    - lib/tokens/token_info_args.dart
    - test/tokens/coin_page_entry_parity_test.dart
  key_links:
    - "coins_screen.dart / markets_screen.dart / dashboard_markets.dart -> TokenInfoArgs -> router.dart /token-info -> TokenInfoScreen"
    - "TokenInfoScreen -> resolveMarketData seam -> fetchCoinsMarketData (only when the caller had no data)"
    - "router.dart -> SGNUSConnection BehaviorSubject -> isGnusWalletConnected (no longer carried in extra)"
---

<objective>
Make a coin open the same page, in the same state, from every entry point - and make the
route the one place that assembles that page's inputs, so a fifth call site cannot
reintroduce the divergence.

Purpose: Jakub, on the 2026-07-31 walk: *"jak klikam tutaj na te 'kojny' z Assets, to
wyskakuje mi dziwny screen. Powinien on prowadzic do tego samego screenu, co prezentuje
Markets, wiec popraw to."* Assets -> USD Coin lands on the page degraded to its
"No market data" empty state.

Output: one typed `TokenInfoArgs` payload, three migrated push sites, a route that derives
what the call sites were guessing at, a page that resolves its own market data with real
loading / retry / uncovered states, and a source-scanning gate that keeps it that way.

**DO NOT COMMIT AND DO NOT PUSH.** Jakub reviews locally and opens the PR himself into
`ui-redesign-port`. This overrides the GSD atomic-commit default and is his standing rule.
Leave every change in the working tree.
</objective>

<context>
@.planning/STATE.md
@lib/components/coins/view/coins_screen.dart
@lib/dashboard/chart/markets_screen.dart
@lib/dashboard/chart/dashboard_markets.dart
@lib/navigation/router.dart
@lib/tokens/token_info_screen.dart
@lib/services/coin_gecko/coin_gecko_api.dart
@lib/dashboard/chart/dashboard_markets_util.dart
@.planning/sketches/071-coin-page-whole-screen/README.md
</context>

<findings>

## What the code actually does - read before touching anything

Everything below was read from the tree at HEAD on this branch. The three numbered items in
the brief are confirmed; two of them turn out to be red herrings, and the real cause is
somewhere neither of them pointed.

### 1. The four entry points, tabulated

There are **three** push sites, not four. `lib/dashboard/chart/markets_search_bar.dart` does
not exist on this branch - the previous session's note is stale. The full census
(`grep -rn "token-info" lib/`), excluding comment mentions and
`global_swap_fab_host.dart:53` where the string is a hidden-path entry, not a push:

| # | File:line | `marketData` | `coin` | `isGnusWalletConnected` | calls `selectCoin` |
|---|---|---|---|---|---|
| 1 | `markets_screen.dart:57-61` (hero card + All Markets table) | `data` (non-null by construction) | `coin` - **dropped by the route** | hardcoded `false` | no |
| 2 | `dashboard_markets.dart:80-86` (dashboard Markets panel) | `data` (non-null, `!` asserted) | not passed | hardcoded `false` | no |
| 3 | `coins_screen.dart:301-309` (dashboard Assets panel) | `_marketData[coin.symbol?.toLowerCase()]` - **nullable** | not passed | `widget.isGnusWalletConnected` (the only site that computes it) | **yes**, line 300 |

The route (`router.dart:319-344`) parses `marketData` and `isGnusWalletConnected` only. The
`"coin"` key from site 1 has no effect today, exactly as the brief says.

### 2. What `TokenInfoScreen` reads for identity - the answer to point 3

The brief's reading is incomplete in a specific way: **the page's identity and every number
it renders come from `marketData`, not from `selectedCoin`.**

- Title: `marketData?.name ?? selectedCoin?.name ?? selectedCoin?.symbol ?? 'Token'` (`:339`)
- Subtitle, icon, price, 24h pill: `marketData` only (`:351`, `:368`, `_IdentityPriceGroup`)
- Stat rail, chart, chart range footer: mounted **inside** `if (marketData != null)` (`:244`, `:306`)
- Convert card: `marketData?.currentPrice ?? 0.0`
- Info card's four market rows: `marketData?.*`

`state.selectedCoin` supplies only four things, all of them wallet context rather than token
identity: the Info card's `address`, the Receive drawer's title and icon, the Bridge
button's zero-balance gate, and a name/icon fallback when `marketData` is missing.

That is why the asymmetry does not break Markets: **nothing Markets renders depends on
`selectedCoin`.** It also means the fix has nothing to do with the missing `"coin"` key -
adding it would change no pixel.

### 3. Why the USDC lookup missed - the answer to point 4

The brief's guess (symbol-keyed map, bad key) is wrong in its details but right that the map
is the problem. Reading `coin_gecko_api.dart:110-185`, **every** return path of
`fetchCoinsMarketData` keys by `symbol.toLowerCase()` - `cachedData`, `staleData` and
`newMarketData` all do. So Markets' dual lookup at `markets_screen.dart:146`
(`marketData[c.id] ?? marketData[c.symbol.toLowerCase()]`) has a dead first half today, and
Assets' symbol-only lookup is not the asymmetry.

The identity is not wrong either. `assets/json/tokens/*.json` gives USDC
`"coinGeckoId": "usd-coin"` on all eight networks, `read_asset.dart:201` threads it into the
`Coin`, and `coins_screen.dart:94-95` prefers it over the symbol match. The on-chain symbol
is `USDC`, CoinGecko's `usd-coin` record carries symbol `usdc`, so the key matches. The
request is built correctly.

**The cause is that Assets' data is best-effort and its failure is silent.** Two facts
combine:

- `topCoinsByCapitalization` (`dashboard_markets_util.dart:10-34`) is 24 ids and
  **`usd-coin` is not among them**. `fetchCoinsMarketData` unions that list into every
  request (`coin_gecko_api.dart:99-100`), so the 24 market coins are warm in Hive from the
  dashboard Markets panel's own `initState` fetch. USDC is only ever requested by the Assets
  fetch.
- When the CoinGecko call fails for any reason - the free API rate-limits, and the dashboard
  fires the Markets panel fetch and the Assets fetch concurrently on load - the function
  swallows it (`debugPrint`, `coin_gecko_api.dart:180-184`) and returns
  `{...staleData, ...cachedData}`. That is the 24 warm market coins **and nothing else**.

So every Assets row whose coin happens to be one of the 24 keeps its price, and USDC alone
goes null. That is precisely Jakub's screenshot. The page then receives `marketData: null`
and renders `_noMarketData` - *"This token is not covered by our market data provider"* -
which is a **factually false statement about a transient network failure**, with no retry
and no way back to data short of leaving and re-entering the dashboard.

**Corollary the brief should know:** USD Coin is not in `topCoinsByCapitalization`, so it
cannot be opened from Markets at all. The claim "the same token opened from Markets renders
fully" is not testable for USDC specifically. It holds for coins that ARE in the list
(BTC, ETH, GNUS) because Markets hides any coin whose data is null (`markets_screen.dart:166`,
`dashboard_markets.dart:55-57`) - Markets never opens a coin without data, which is why it
never shows the empty state and never needed a retry on this page.

### 4. What parity means here - stated before anything changes

Parity is **not** "pass the same map keys". Sites 1 and 2 pass non-null data by construction;
site 3 passes a nullable snapshot of a screen-local map. Making the payloads textually
identical would leave the null exactly where it is.

Parity is:

1. **Same resolution path.** The page resolves market data from the coin's identity. A caller
   that already has the data hands it over as a warm start (no new request, Markets is
   byte-identical in behaviour); a caller that does not hands over the identity and the page
   fetches it.
2. **Same three states, everywhere.** Loading, retryable error, genuinely-uncovered. Markets
   has all three today via `FutureStateWidget`; the coin page has only the third and uses it
   for all three.
3. **Same wallet context, or none.** A row that would state a fact about the wallet
   (Address, Network) renders only when the caller actually knows it.
4. **Same back link semantics.** The link names where you came from.
5. **Structurally enforced.** One payload type, one assembler, and a test that fails on a
   fourth call site.

### 5. The back link - in scope, and here is why

`token_info_screen.dart:225` hardcodes `GWBackLink(label: 'MARKETS', ...)`. Arriving from the
dashboard Assets panel, the link reads MARKETS and `context.pop()` returns to the dashboard.
The word is wrong; the destination is right.

**In scope.** It is the same defect class the brief names - the page not knowing where it came
from - it is one field on a payload this plan is introducing anyway, and shipping a payload
that carries the origin while the page keeps ignoring it would recreate exactly the
"silently dropped on the floor" condition that let the `"coin"` key rot. Cost is one string.

### 6. Two findings this plan acts on, and one it does not

**Acted on - the Info card states a foreign address.** `_buildInfoSection` passes
`address: selectedCoin?.address` and `network: selectedNetwork?.name`. From Markets,
`selectedCoin` is whatever the wallet last selected, so opening Bitcoin from Markets prints
**your Ethereum USDC address** on a row labelled Address, and your wallet's network on a row
labelled Network. `token_info_screen.dart:623-629` already reasons about exactly this hazard
for the Receive drawer's title and refuses to use `marketData` there; the Info card never got
the same treatment. Task 1 routes both rows through the payload so they render only when the
caller genuinely knows them. **This changes what Markets shows** (two rows disappear rather
than lying) - flagged for the walk, see the checklist.

**Acted on - `isGnusWalletConnected` is a flag three of three call sites get wrong.** Two
hardcode `false`; only Assets computes it. `SGNUSConnectionController` is a
`BehaviorSubject.seeded` (`packages/genius_api/lib/controllers/sgnus_connection_controller.dart:7`),
so a late subscriber gets the current value immediately - which means the route can derive
the flag itself and no call site ever has to pass it again.

**Not acted on - Receive and Bridge on a coin you do not hold.** From Markets, Receive opens a
QR for the wallet's address on the wallet's network, which has nothing to do with the token
you were reading about. The code comments already own this decision. Gating the actions on
"is this coin in your wallet" is a design question (what does Receive mean for a market
coin?), not a defect fix, and it is not what Jakub asked for. Recorded, not changed.

</findings>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: One typed payload; the route becomes the only assembler</name>
  <files>lib/tokens/token_info_args.dart, lib/navigation/router.dart, lib/dashboard/chart/markets_screen.dart, lib/dashboard/chart/dashboard_markets.dart, lib/components/coins/view/coins_screen.dart, lib/dashboard/home/view/dashboard_screen.dart, lib/tokens/token_info_screen.dart</files>
  <behavior>
    - `TokenInfoArgs.fromExtra` given the legacy untyped map (`marketData` + `isGnusWalletConnected` keys) returns args carrying that market data and the default origin, so a deep link or an unmigrated caller still opens a working page.
    - `TokenInfoArgs.fromExtra(null)` returns an all-null payload with `originLabel` defaulting to `MARKETS`, matching today's hardcoded link.
    - `TokenInfoArgs.fromExtra` given a `TokenInfoArgs` returns it unchanged.
    - `TokenInfoScreen` given `originLabel: 'ASSETS'` renders `ASSETS` in the back link; given the default it renders `MARKETS`.
    - `TokenInfoScreen` given `walletCoin: null` renders no Address row and no Network row; given a `walletCoin` with an address it renders both.
  </behavior>
  <action>
Create `lib/tokens/token_info_args.dart` holding one immutable class, `TokenInfoArgs`, with
const constructor and these fields, all nullable except the last:

  - `coinGeckoId` (`String?`) - the CoinGecko id, the only reliable token identity the app has.
  - `symbol` (`String?`) - the ticker, used as the secondary lookup key because
    `fetchCoinsMarketData` returns a symbol-keyed map (see Findings 3).
  - `marketData` (`CoinGeckoMarketData?`) - a warm start. Non-null means the caller already
    holds it and the page must not issue a request.
  - `walletCoin` (`Coin?` from `package:genius_api/models/coin.dart`) - the wallet's own record
    for this token, when and only when the caller is showing the user's holdings. Null from
    both Markets surfaces.
  - `network` (`String?`) - the wallet network name for `walletCoin`. Null when `walletCoin` is.
  - `originLabel` (`String`, default `'MARKETS'`) - the back link's word.

Give it a static `fromExtra(Object? extra)` that returns the value unchanged when it is already
a `TokenInfoArgs`, reconstructs from the legacy `Map<String, dynamic>` shape when it is a map
(reusing the route's existing three-way `marketData` coercion, including the
`CoinGeckoMarketData.fromJson` branch for a serialised deep link), and returns a const empty
instance otherwise. Document in the class doc that the legacy branch exists for deep links and
must not be deleted when the three in-tree call sites are migrated.

Then rewire, in this order:

**a. `router.dart` `/token-info` (lines 319-344).** Replace the inline extra parsing with
`TokenInfoArgs.fromExtra(state.extra)`. Delete the `isGnusWalletConnected` read entirely and
derive it here instead: wrap the returned `TokenInfoScreen` in a
`StreamBuilder<SGNUSConnection>` on `context.read<GeniusApi>().getSGNUSConnectionStream()`,
and compute the flag as `(snapshot.data?.walletAddress ?? false) == walletCubit.state.selectedWallet?.address`
- the identical expression `dashboard_screen.dart:711-713` uses today, moved rather than
rewritten. Add a comment recording WHY this is safe to read here: the controller is a
`BehaviorSubject.seeded`, so a subscriber that attaches after connection lands still receives
the current value on its first event rather than waiting for a change. Pass `args` to
`TokenInfoScreen`.

**b. `markets_screen.dart` `_openToken` (57-62).** Push
`TokenInfoArgs(coinGeckoId: coin.id, symbol: coin.symbol, marketData: data)` as `extra`.
Drop the `isGnusWalletConnected` key (the route owns it) and the `coin` key (it was never
read; `coinGeckoId` and `symbol` replace it with the two fields anything downstream needs).
`originLabel` takes its default.

**c. `dashboard_markets.dart` (79-87).** Same payload shape as (b), built from `coin.id`,
`coin.symbol` and the non-null `data` already in hand. This site had no `coin` key at all, so
it gains identity it never carried.

**d. `coins_screen.dart` (295-311).** Keep `walletCubit.selectCoin(coin)` - it is still
load-bearing for `/bridge`, which builds `BridgeScreen(fromToken: walletCubit.state.selectedCoin)`
at `router.dart:353`, and for the Swap preselection fallback. Push
`TokenInfoArgs(coinGeckoId: coin.coinGeckoId, symbol: coin.symbol, marketData: _marketData[coin.symbol?.toLowerCase()], walletCoin: coin, network: state.selectedNetwork?.name, originLabel: 'ASSETS')`.
The market-data entry stays exactly as it is - when the local map has it, nothing is refetched;
when it does not, Task 2 recovers instead of surrendering. Delete the now-unreferenced
`isGnusWalletConnected` field from `CoinsScreen` and its constructor.

**e. `dashboard_screen.dart` `ContributionsDashboardView` (~699-720).** Its
`BlocBuilder<WalletDetailsCubit>` + `StreamBuilder<SGNUSConnection>` exist solely to compute
the flag deleted in (d) - verify that by reading the subtree before cutting, then collapse the
body to `DashboardScrollContainer(child: CoinsScreen(isUseDivider: true))` and remove the
imports that fall dead. `CoinsScreen` runs its own `BlocBuilder` internally, so it keeps
rebuilding on wallet state exactly as before.

**f. `token_info_screen.dart`.** Replace the three constructor fields with a single
`required TokenInfoArgs args` plus the existing `required WalletDetailsCubit walletDetailsCubit`.
Inside, read `marketData` from `args.marketData` for now (Task 2 changes where it comes from,
not who reads it) and `isGnusWalletConnected` from a new required bool parameter supplied by
the route. Feed `GWBackLink(label: args.originLabel)` at line 225. Change
`_buildInfoSection` to take its address and network from `args.walletCoin?.address` and
`args.network` instead of `state.selectedCoin` / `state.selectedNetwork` - `CoinInfoCard`
already omits each row when its value is null, so a Markets-opened coin simply stops printing
two rows it was getting wrong (Findings 6). Leave the Receive drawer, the Bridge gate and the
Swap preselection reading the cubit exactly as they do now: those are wallet actions and the
cubit is the correct source for them.

Do not touch `lib/dev/*`, `lib/submit_job/cubit/submit_job_cubit.dart`, `lib/bloc/app_bloc.dart`
or `lib/components/wallet_overview.dart` - quick task 260731-hrn owns those.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5</automated>
  </verify>
  <done>`flutter analyze` reports zero issues in the root package and in `genius_api`. All three push sites construct `TokenInfoArgs`. `router.dart` is the only file that decides `isGnusWalletConnected`. `grep -rn "isGnusWalletConnected" lib/` returns hits only in `router.dart` and `token_info_screen.dart`.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: The page resolves its own market data, with real loading and retry states</name>
  <files>lib/tokens/token_info_screen.dart</files>
  <behavior>
    - Given `args.marketData` non-null, the screen issues no fetch at all and renders the price, stat rail and chart on its first frame (Markets behaviour unchanged, zero new requests).
    - Given `args.marketData` null and `args.coinGeckoId` non-null, the screen shows a loading state in the chart card slot, then renders fully once the resolver returns data under the symbol key.
    - Given the same and a resolver that returns an empty map or throws, the screen shows an error card with a Retry control, and tapping Retry calls the resolver a second time.
    - Given the same and a second resolver call that succeeds, the page renders fully.
    - Given `args.coinGeckoId` null, the screen issues no fetch and shows the existing "No market data" card immediately.
  </behavior>
  <action>
Convert `TokenInfoScreen` from `StatelessWidget` to `StatefulWidget`. It already carries a
`BlocProvider.value` + `BlocBuilder` at its root, so the conversion is mechanical: the build
body moves to the State and every `marketData!` becomes a read of the State's resolved value.

Add an injectable resolver so this is testable without Hive or the network:

    final Future<Map<String, CoinGeckoMarketData?>> Function(List<String> coinIds)? resolveMarketData;

defaulting in `initState` to `(ids) => fetchCoinsMarketData(coinIds: ids)`. Document that the
seam exists for the test in Task 3 and that production callers never pass it.

State machine, four values (an enum or a small sealed holder, executor's choice - name it so
the states read from the widget tree):

  - `ready` - `args.marketData` non-null. Set in `initState` without touching the resolver.
    This is the branch Markets and the dashboard Markets panel always take, which is what
    keeps this plan free of new API calls on those routes.
  - `loading` - `args.marketData` null and `args.coinGeckoId` non-null. `initState` calls the
    resolver once with `[args.coinGeckoId!]`.
  - `failed` - the resolver threw, or returned a map with no entry for this coin. Look up
    `result[args.symbol?.toLowerCase()] ?? result[args.coinGeckoId]`, keeping both keys for the
    same reason `markets_screen.dart:146` does. Guard the `setState` with `mounted`.
  - `uncovered` - `args.marketData` null AND `args.coinGeckoId` null. Nothing to ask for.
    Set in `initState`; no fetch.

Render, reusing what the page already owns rather than inventing new chrome:

  - `ready` - today's tree, unchanged.
  - `loading` - `_chartCard`'s slot holds a centred `Loading()` (the component
    `coins_screen.dart` already uses). Header, actions and Info card mount as they do on the
    no-data route today, so the page does not jump when data lands. Stat rail stays hidden
    until there is data.
  - `failed` - the `_noMarketData` card's slot holds a `GWEmptyState` whose title says the
    price could not be loaded and whose message says it is a temporary problem, plus a Retry
    control that re-enters `loading` and calls the resolver again. Use `GWButton` with
    `GWButtonVariant.gradientOutline` and `GWButtonSize.sm`, matching the page's own
    established weight ladder - Swap is the one filled control on this surface and stays the
    only one (CTA weight rule).
  - `uncovered` - today's `_noMarketData` card verbatim. Its wording is the one place on this
    page that is allowed to say the provider does not cover the token, because it is now the
    only state in which that is true.

Copy discipline: no em dashes in any user-visible string. Use " - ".

Colours come from `GWColors` via `Theme.of(context).extension<GWColors>()`, never a raw
`Color(0x...)` - `tool/check_raw_colors.sh` gates this file's directory.

Two invariants to preserve while moving code, both of which the file's own comments explain
and neither of which is obvious:

  - `_chartCard(null)` under `IntrinsicHeight` relies on `_FillHeight` answering zero to an
    intrinsic-height query. The loading and error cards must not be wrapped in anything that
    changes that answer - keep them on the `chartHeight` (non-null) branch only, which is the
    single-column layout, and let the wide layout fall to the single-column branch whenever
    the resolved data is null, exactly as `isWide && marketData != null` already does at
    line 262.
  - `coinChartHeight` must keep reading `constraints.maxHeight` above the
    `SingleChildScrollView`, not inside it.
  </action>
  <verify>
    <automated>flutter test test/tokens/ 2>&1 | tail -20</automated>
  </verify>
  <done>Every test under `test/tokens/` passes. A coin page opened with a null `marketData` and a non-null `coinGeckoId` fetches, and a failure is retryable rather than terminal.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: The parity gate - tests that fail on a fourth divergent call site</name>
  <files>test/tokens/coin_page_entry_parity_test.dart, test/tokens/coin_page_stat_rail_test.dart, test/tokens/coin_page_range_tile_test.dart</files>
  <behavior>
    - A source scan of `lib/**.dart` finds exactly three `push('/token-info', ...)` call sites and every one of them passes a `TokenInfoArgs`. A fourth site, or one passing a bare map, fails the test with a message naming the offending file.
    - No file in `lib/` passes an `isGnusWalletConnected` key inside a `/token-info` extra.
    - `TokenInfoArgs.fromExtra` round-trips the legacy map shape, a `TokenInfoArgs`, and null.
    - `TokenInfoScreen` renders the origin label it is given.
    - `TokenInfoScreen` with a null `walletCoin` renders neither an Address nor a Network row.
    - `TokenInfoScreen` with a null `marketData` and a non-null `coinGeckoId` fetches through the injected resolver, shows loading, then renders the resolved price; a failing resolver yields a Retry that, when tapped, calls the resolver again.
  </behavior>
  <action>
Create `test/tokens/coin_page_entry_parity_test.dart` with two groups.

**Group 1, the source-scanning census.** Follow the precedent this repo already set in
`test/components/drawer_padding_invariant_test.dart` - walk `Directory('lib')` recursively,
read each `.dart` file, and apply a whitespace-tolerant pattern that captures the identifier
following `extra:` in a `push` whose first argument is the token-info path. Assert the
captured type is `TokenInfoArgs` at every hit, and assert the hit count equals 3 with a
failure message that says: a new coin-page entry point was added, it must pass `TokenInfoArgs`
so the route stays the only assembler, and this count is the census to update once that holds.
Build the path literal from a joined constant rather than writing it out inline, so the test
file does not match its own scan.

Add a second scan asserting no file in `lib/` puts a connection flag key inside a token-info
extra. Same construction rule for the literal.

**Group 2, widget and unit behaviour.** `TokenInfoArgs.fromExtra` against the legacy map, an
already-typed payload, and null. Then pump `TokenInfoScreen` with a stub `WalletDetailsCubit`
(the two existing tests in this directory already show the setup - reuse it rather than
inventing a second one) and assert:

  - `originLabel: 'ASSETS'` puts `ASSETS` on screen; the default puts `MARKETS`.
  - `walletCoin: null` renders no `Address` and no `Network` row; a `walletCoin` with an
    address and a `network` renders both.
  - With `marketData: null`, `coinGeckoId: 'usd-coin'`, `symbol: 'USDC'` and a resolver
    completer that has not yet fired, a loading indicator is present and the "No market data"
    wording is not. Complete it with `{'usdc': <fixture>}`, pump, and assert the price is on
    screen.
  - With a resolver that throws, assert a Retry control is present and the terminal
    "not covered" wording is not; tap Retry with a resolver that now succeeds and assert the
    price renders. Count resolver invocations to prove Retry re-fetched rather than rebuilt.

Use a locally built `CoinGeckoMarketData` fixture inside the test file. Do not import
`lib/dev/dev_mock_holdings.dart` - `lib/dev/*` belongs to the parallel quick task 260731-hrn.

**Update the two existing call sites.** `test/tokens/coin_page_stat_rail_test.dart:45` and
`test/tokens/coin_page_range_tile_test.dart:89` construct `TokenInfoScreen` directly and will
not compile against the new signature. Move each to `args: TokenInfoArgs(marketData: ...)`,
preserving whatever each test currently asserts - both exist to pin layout, so their intent
must survive the mechanical change unchanged.
  </action>
  <verify>
    <automated>flutter test 2>&1 | tail -10</automated>
  </verify>
  <done>Full suite green at 849 or more passing, zero failing. The census test fails if a fourth `/token-info` push is added without the typed payload.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| go_router `extra` -> route builder | An untyped `Object?` crosses here. A deep link or a hot-reload stale route can deliver a shape the builder did not expect. |
| CoinGecko HTTP -> `CoinGeckoMarketData.fromJson` | Third-party JSON becomes on-screen financial figures. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-hsb-01 | Denial of Service | `TokenInfoArgs.fromExtra` | medium | mitigate | Never `as`-cast `state.extra`. Type-test, and return a const empty payload on anything unrecognised, so a malformed deep link opens an honest empty page instead of throwing inside a route builder. |
| T-hsb-02 | Information Disclosure | Info card Address / Network rows | medium | mitigate | Task 1 sources both rows from the payload, so a coin page opened from Markets stops printing the wallet's address for an unrelated token (Findings 6). |
| T-hsb-03 | Spoofing | `_noMarketData` copy on a network failure | medium | mitigate | Task 2 splits `uncovered` from `failed`. The app stops asserting a token is uncovered when it merely failed to reach the provider. |
| T-hsb-04 | Denial of Service | Retry control | low | mitigate | Retry issues one request per tap and the button is disabled while `loading`, so a held cursor cannot spin up parallel requests into a rate limit. |
| T-hsb-05 | Tampering | package installs | n/a | accept | This plan installs nothing. `pubspec.yaml` is untouched, so the package legitimacy gate does not apply. |
</threat_model>

<verification>
Run in order. The first three are the standing gates for this repo.

    flutter analyze
    flutter test
    tool/check_brace_style.sh
    tool/check_raw_colors.sh

Expected: analyze 0 issues (root and `genius_api`), test 849 or more passing with zero
failures, both shell gates PASS. Also run `dart format --set-exit-if-changed lib test` if
that is how format is checked on this branch, or `dart format lib test` and confirm no diff
noise beyond the touched files.

## Human walk - required, and this plan does not close without it

No live app instance is assumed. Record results against this list.

1. **Dashboard Assets -> USD Coin.** The defect that filed this. Expect the full page: price,
   24h pill, stat rail, chart, real INFO numbers. Not "No market data".
2. **Dashboard Assets -> GNUS.** Regression check on the coin that was already working. Same
   page as before, and the Bridge button still appears when the SGNUS wallet is connected -
   this is the one behaviour the `isGnusWalletConnected` move could break, because the route
   now derives what `dashboard_screen.dart` used to compute.
3. **Markets -> Bitcoin.** Should be visually unchanged except that the Info card's Address and
   Network rows are gone. This is deliberate (Findings 6) - they were printing your wallet's
   address for a token you do not hold. **Judge it.** If the card looks thin without them, the
   alternative is a row that says the token is not in your wallet; say which you want.
4. **Dashboard Markets panel -> any row.** Same page as (3).
5. **Back link wording.** ASSETS from (1) and (2), MARKETS from (3) and (4). Tapping it returns
   where it always did in every case.
6. **Airplane mode, then Assets -> a coin whose price is not cached.** Expect the retryable
   error card, not "not covered by our market data provider". Re-enable the network and tap
   Retry; the page should fill in without a reload.
7. **Both themes.** Dark first per the standing rule. The new loading and error states are the
   only new surfaces; check the Retry button's contrast in each.
</verification>

<success_criteria>
- Assets -> USD Coin opens the same page Markets opens for a covered coin: price, chart, stat
  rail, real INFO numbers.
- Three push sites, one payload type, one assembler. A fourth divergent site fails a test.
- `isGnusWalletConnected` appears in no `extra` anywhere in `lib/`.
- A transient provider failure is retryable and honestly worded; a genuinely uncovered token
  still says so.
- The back link names the panel the user came from.
- `flutter analyze` clean, full suite at 849 or more passing, both shell gates PASS.
- **Nothing committed, nothing pushed.** Every change sits in the working tree on
  `redesign/jakub-260730` for Jakub to review and PR into `ui-redesign-port` himself.
</success_criteria>

<output>
Write `.planning/quick/260731-hsb-assets-coin-tap-must-open-the-same-coin-/260731-hsb-SUMMARY.md`
when done. Record: the walk checklist results (or that the walk is OUTSTANDING and why), the
judgement call on the Info card's two removed rows, and the final analyze / test / gate numbers.
</output>
</content>
</invoke>
