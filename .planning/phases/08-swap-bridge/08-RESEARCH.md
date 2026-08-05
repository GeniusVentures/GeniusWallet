# Phase 8: Swap & bridge - Research

**Researched:** 2026-07-25
**Domain:** Flutter re-skin of an existing (partially mocked, partially real) DeFi swap/bridge surface
**Confidence:** HIGH (all claims below are code-grounded via Read/Grep/git-show on this repo; no
external library research was needed — this phase introduces no new dependencies)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

- **D-01:** Keep the unwired swap path, and write the deviation down. `swap_screen.dart:340` is
  `// TODO: invoke Squid API` and `:352` is `// TODO: record transaction`, yet `:387` shows
  `SwapSuccessDrawer` and `:400`/`:406` call `transactionsCubit.addTransaction(...)`. So today the
  screen renders success and records a transaction **without executing a swap**. Wiring real Squid
  execution is a functional change and does not belong in a re-skin phase. This decision IS the
  written record satisfying ROADMAP criterion 3's second branch.
- **D-02:** The receipt must not gain any new language implying an on-chain swap occurred. Re-skin
  the existing copy; do not upgrade its claims.
- **D-03:** Reuse the already-shipped 031-B status-led receipt (030-B shell) for BOTH the swap
  result and the bridge result. Do not design a new receipt.
- **D-04:** 031-B replaces the three `squid_router` drawers for these two flows:
  `swap_success_drawer.dart`, `swap_fail_drawer.dart`, `swap_drawer_content.dart`.
- **D-05:** `lib/reown/swap_result_drawer.dart` is OUT OF SCOPE — do not touch it. Consumed by
  `lib/reown/handle_dapp_requests.dart` (the dApp request path), which belongs to Phase 10.
- **D-06:** Superseded drawer files must not be left orphaned. Once 031-B serves the swap-tab and
  bridge flows, remove the drawer files that no longer have a production caller, and update
  `lib/dev/dev_tools_bubble.dart`, which currently references `swap_success_drawer`,
  `swap_fail_drawer` and `reown/swap_result_drawer`. `swap_fail_drawer` has no production caller at
  all today — only the dev bubble.
- **D-07:** Sketch 105 A1 · Focused (bigger) — 560px column, 38px amounts, brand sheen, subtitle,
  and the flip control in the seam (which kills the existing `-170` offset hack). Locked by the
  design session; not open for re-litigation.
- **D-08:** Preserve develop's route, fee and slippage figures exactly. The quote pipeline is
  mechanics, not skin.
- **D-09:** On a failed route fetch the "You Receive" field shows `—` plus a red "not current"
  notice and a Retry affordance. It must never display a silently stale quote. Designed in sketch
  120.
- **D-10:** Sketch 120 B1 · Swap-twin — the GNUS bridge mirrors the Swap tab exactly. Chosen for
  instant recognition and lowest-churn reskin of `bridge_screen.dart` (726 lines). B2 was rejected.
- **D-11:** Bridge mechanics are untouched: burn on source chain → mint on destination, 1:1, no rate
  and no slippage (cost is gas only). `getBrigeOutGasCost(...)` stays on the 300ms debounced amount
  change; `bridgeOut(... shouldMintTokens: true)` stays on submit.
- **D-12:** Bridge remains GNUS-only (`isGnusBridgeEnabled`) and disabled at zero balance. It stays a
  back-arrow sub-screen — not a tab, not a swap/bridge toggle.
- **D-13:** `swap_settings_drawer.dart` (slippage) is IN scope — it opens directly from the swap tab
  and would visibly clash against the redesigned tab if skipped.
- **D-14:** `gw_swap_fab.dart` (global swap FAB) is IN scope — it is a swap entry point and should
  not read as pre-redesign chrome.
- **D-17:** Phase 8 owns `7a63b4f` and mounts `GlobalSwapFabHost`. Not in the original four success
  criteria; ROADMAP criterion 5 was added to make it explicit. Fixes NAV-02 (the `!_dirty` red screen
  on startup).
- **D-18:** This is a PORT, not a from-scratch build. `lib/components/overlay/global_swap_fab_host.dart`
  (143 lines, fix already applied) exists on branch `ui-redesign-3.514-develop` at `7a63b4f` and is
  absent on `ui-redesign-port`. Port it rather than reimplementing. Preserve the `if (!_ready) return;`
  guard and its comment verbatim. Note the FAB button itself (`gw_swap_fab.dart`) is already visually
  compliant — D-14's re-skin scope for it is close to a no-op.
- **D-15:** WCAG AA contrast in both light and dark modes and in all states, including disabled — a
  hard project rule, not a preference.
- **D-16:** Windows is the walk host. Both screens are ordinary Flutter widgets (no platform views),
  so there is no Windows/macOS parity split here.

### Claude's Discretion

- Task decomposition and plan ordering.
- Which shared `gw_*` primitives to reuse when realising 105 A1 / 120 B1.
- Whether the 031-B receipt is reached by extracting a shared widget or by parameterising the
  existing one — provided D-04/D-05/D-06 hold.

### Deferred Ideas (OUT OF SCOPE)

- Surfacing the bridge entry as a first-class action (IA restructure, not a re-skin).
- Wiring real Squid swap execution (the D-01 TODOs).
- Consolidating the dApp result path onto 031-B (`reown/swap_result_drawer`) — Phase 10 territory.

</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| SCR-04 | Swap (Squid Router) wears the redesign and keeps develop's route/fee/slippage logic | §"The Squid quote pipeline" below traces every figure develop computes today (all of it is static mock data — see Pitfall 2) and confirms none of it needs to change, only its presentation. §"bridge_screen.dart structural map" traces the equivalent bridge mechanics (which, unlike swap, are REAL on-chain calls via `Web3`). |

</phase_requirements>

## Summary

This is a pure re-skin phase with an unusually large "mechanics" surface to protect: two screens
(`swap_screen.dart` 430 lines, `bridge_screen.dart` 726 lines), a settings drawer, a global FAB host
that must be **ported from another branch** (not written fresh), and a drawer-consolidation task that
touches a shared Phase-12 receipt function. No new external packages are introduced anywhere in this
phase — every visual primitive it needs (`GWButton`, `GWCard`, `ResponsiveDrawer`, `GWPageHeader`,
`GWColors`) already exists on `ui-redesign-port`. The Package Legitimacy Audit is therefore N/A.

Three facts materially change how the planner should scope this phase, none of which is in the
CONTEXT.md/UI-SPEC documents as written:

1. **The Squid quote pipeline is 100% mocked, and this predates the redesign.** `SquidTokenService.fetchTokens/fetchBalances/getRoute` all short-circuit to hardcoded constants (`mockTokens`, `mockSquidBalances`, `mockSquidRoute`) with the real HTTP calls commented out — verified present on `origin/develop` at `4d1bb36`, unchanged since `7c40615`/`f2acc14` ("Add Buy / Swap (WIP) #119"). **Criterion 1 ("a quote returns with develop's route, fee and slippage figures unchanged") is therefore checking that a re-skin didn't touch a compile-time constant** — it is not exercising a live network path. See Pitfall 2.

2. **Bridge is functionally real; swap is not.** `bridgeOut()`/`getBrigeOutGasCost()` in `genius_api.dart` call into `Web3(...).executeBridgeOutTransaction(...)` and (on success, when `shouldMintTokens: true`) `mintTokens(...)` — genuine on-chain burn/mint calls, not mocks. This is the opposite of swap's D-01 TODO-stub. The planner must not assume "swap and bridge are both fake" — only swap is.

3. **`bridge_screen.dart` never constructs a `Transaction` object today.** It shows a raw `AlertDialog` built from the `bridgeOut()` response directly; nothing is added to `TransactionsCubit` or `TransactionStorageService`. D-04's mandate to route the bridge result through `showTransactionDetails(context, transaction)` therefore requires **synthesizing** a `Transaction`, not re-skinning an existing one. See "Drawer consolidation mechanics" below for the recommended `TransactionType` strategy and its cross-file cost.

**Primary recommendation:** Treat this phase as two independent re-skin tracks (Swap-tab-family,
Bridge-screen) plus one genuinely new piece of glue code (the synthesized bridge `Transaction` +
receipt wiring) plus one verbatim port (`GlobalSwapFabHost`, which needs a real edit before it can be
ported — see Pitfall 5, the AI-FAB blocker).

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Swap tab visual layout (105 A1) | Client (Flutter widget tree) | — | Pure presentation; `swap_screen.dart`'s `build()`/child widgets |
| Bridge screen visual layout (120 B1) | Client | — | Pure presentation; `bridge_screen.dart`'s `build()` |
| Quote/route computation | Client (mocked local service) | — | `SquidTokenService` is 100% local/mocked today — there is no real backend tier in play (see Summary point 1) |
| Bridge burn/mint execution | Client → on-chain (via `GeniusApi`/`Web3`) | — | `bridgeOut`/`getBrigeOutGasCost` make real RPC/contract calls through the bundled `genius_api` package; this is mechanics, not skin, and is D-11-locked |
| Result receipt (031-B) | Client | Shared component (`transaction_displays.dart`, Phase-12-owned file) | `showTransactionDetails()` is a cross-phase shared function; Phase 8 is a *consumer*, not the owner, of that file |
| Global swap FAB host | Client (app-shell overlay, mounts in `main.dart`) | Navigation (`GoRouter` delegate) | Wraps the router's `Navigator`; must mount inside `MaterialApp.router`'s `builder`, above the `Navigator`'s `Overlay` (per the file's own doc comment) |
| Transaction persistence (swap) | Client (Hive local storage via `TransactionStorageService`) | — | Already wired at `swap_screen.dart:404-409`; D-01 keeps it firing on a non-executed swap (by design, the deviation) |
| Transaction persistence (bridge) | **Currently none** | — | See Summary point 3 — this phase must decide whether to add it |

## Standard Stack

No new libraries. Every widget this phase needs already exists on `ui-redesign-port`:

### Reused primitives (already shipped, Phase 2/3/4)

| Primitive | File | Confirmed signature |
|-----------|------|----------------------|
| `GWButton` | `lib/components/buttons/gw_button.dart` | `GWButtonVariant {primary, secondary, tertiary, ghost, destructive, icon, gradient, gradientOutline}`; `GWButtonSize {sm, md, lg}`; supports `isLoading`, `expand` — confirmed via grep, matches UI-SPEC's `GWButton(variant: GWButtonVariant.gradient, size: GWButtonSize.lg, expand: true, isLoading: ...)` call pattern |
| `GWPageHeader` | `lib/components/scaffold/gw_page_header.dart` | **Currently `{title, trailing}` only — NO `subtitle` param exists yet.** UI-SPEC's "extend with an optional subtitle parameter (default null — additive)" is a real, small, additive edit this phase must make, not something already there. `[VERIFIED: repo read]` |
| `ResponsiveDrawer` | `lib/components/bottom_drawer/responsive_drawer.dart` | `static Future<T?> show<T>({required BuildContext context, required Widget child, String? title, List<Widget>? actions, Widget? footer, double desktopWidth = 420, bool useRootNavigator = true, bool isDismissible = true, bool enableDrag = true})` — desktop renders as a right-edge `showDialog` panel (`gw.surfaceMenu` fill, `radius3xl` rounding), mobile as a bottom sheet. All three existing swap drawers (`SwapSuccessDrawer`, `SwapFailDrawer`, `SwapSettingsDrawer`, `TokenSelectorDrawer`) already call through this — confirmed, no drawer in this phase needs a new shell mechanism |
| `GWColors` | `lib/theme/gw_colors.dart` | Confirmed getters: `surfaceMenu`, `textPrimary38`, `textSecondary`, `statusSuccess`, `statusError`, `borderSubtle`. **No `statusErrorFill` getter exists** — UI-SPEC's fallback (`statusError.withValues(alpha:0.12)`) is the one that must be used. `[VERIFIED: repo read]` |
| `GeniusWalletTypography.numericDisplay` | `lib/theme/genius_wallet_typography.dart:121` | Exists; UI-SPEC's `.copyWith(fontSize: 38, height: 1.0)` pattern is valid |
| Inline error/notice banner primitive (`GWInlineNotice` or similar) | — | **Does not exist anywhere in `lib/`** — grep for `GWInlineNotice`/`InlineNotice` returns zero matches in `lib/`. UI-SPEC already anticipated this ("if none exists, this is additive-only, not a restructure") — confirmed: the planner must hand-roll a small `Container`-based notice for D-09's route-error state; there is nothing to reuse |

### Package Legitimacy Audit

**Not applicable — this phase adds zero new external packages.** No `pubspec.yaml` changes are
anticipated; every widget and API call used is either already in the codebase or already a dependency
of `genius_api`/`squid_router`. If a planner-authored task introduces a new pub.dev dependency for any
reason, the Package Legitimacy Gate protocol must be run before that task ships — but nothing found
during this research calls for one.

## Architecture Patterns

### System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│ main.dart: MaterialApp.router(routerConfig: geniusWalletRouter)      │
│   └── (builder slot — GlobalSwapFabHost mounts HERE, D-17/D-18)      │
│         Stack:                                                       │
│           widget.child  ──────────────► Navigator (GoRouter routes)  │
│           GWSwapFab (bottom-right, hidden on _hiddenPaths incl /swap)│
└─────────────────────────────────────────────────────────────────────┘
                              │
              ┌───────────────┴────────────────┐
              ▼                                 ▼
   GoRoute '/swap' (in ShellRoute)      GoRoute '/bridge' (top-level,
   → SwapScreen                          pushed, NOT in ShellRoute)
              │                                 │
   ┌──────────▼──────────┐          ┌───────────▼────────────┐
   │ _loadTokens()        │          │ _fetchBridgeNetworks() │
   │  → SquidTokenService  │          │  → readNetworkBridge-  │
   │     .fetchTokens()    │          │     Assets() (real     │
   │     .fetchBalances()  │          │     local asset read)  │
   │  [MOCKED — see        │          └───────────┬────────────┘
   │   Pitfall 2]           │                      │
   └──────────┬────────────┘          amount field onChanged
              │                        (300ms debounce, D-11)
   amount field onChanged                          │
   (500ms debounce)                                 ▼
              │                        api.getBrigeOutGasCost(...)
              ▼                        [REAL Web3 call — Pitfall 4]
   SquidTokenService.getRoute()                     │
   [MOCKED — always returns                          ▼
    mockSquidRoute regardless        Submit → api.bridgeOut(...
    of tokens/amount — Pitfall 2]        shouldMintTokens: true)
              │                        [REAL burn+mint on-chain call]
              ▼                                     │
   RouteDetailsCard (pricing/                        ▼
   slippage/fees — D-08 locked)        bridgeTokensResponse
              │                        (isSuccess, data=txHash,
   Submit → TODO: invoke Squid API      errorMessage)
   (D-01, stays unwired)                             │
              │                        ┌──────────────┴──────────────┐
              ▼                        ▼                              ▼
   synthesize Transaction    ToastManager.showToast          [TODAY: raw AlertDialog,
   (type: swap, already       (success/error, finding 28)     no Transaction object —
    wired :354-377)                    │                       must synthesize one,
              │                        └──────► [D-03/D-04/D-06 TARGET STATE:
              ▼                                  BOTH paths call
   transactionsCubit.addTransaction()             showTransactionDetails(context, tx)
   + TransactionStorageService                     instead of their bespoke drawer/dialog]
   .addTransaction() (persisted)
              │
              ▼
   showTransactionDetails(context, tx)  ← lib/dashboard/home/widgets/transaction_displays.dart:430
   (Phase-12-owned shared function, ResponsiveDrawer-based, isSwap special-case for From/To/Rate rows)
```

### swap_screen.dart structural map

- **State:** `_SwapScreenState` holds `tokens`, `fromToken`/`toToken` (`SquidTokenInfo?`),
  `isLoading`, `fromAmount`/`toAmount` (String), two `TextEditingController`s, a 500ms debounce
  `Timer`, `fetchedRoute` (`SquidRouteResponse?`), `slippage` (double, default 0.5).
- **Lifecycle:** `initState` → `_loadTokens()`. `BlocListener<WalletDetailsCubit, ...>` resets all
  state and re-calls `_loadTokens()` on wallet/network change.
- **`_debouncedFetchRoute()`** — 500ms `Timer`, cancels any pending one, calls `_fetchRoute()`. Fired
  from: the "You Pay" `SwapField.onChanged`, `onTokenSelected` (both fields), and `_flipTokens()`.
  The "You Receive" field's `onChanged` does **not** trigger a re-fetch (read-only in effect, since
  its value is server-computed).
- **`_fetchRoute()`** (`:148-173`) — the one and only place `SquidTokenService.getRoute()` is called.
  On success: sets `toAmount`/`toAmountController.text`/`fetchedRoute`. On error: **today** only a
  transient `showAppSnackBar`; this is exactly the branch D-09 requires replacing/augmenting with the
  field-level `—` + persistent notice + Retry (the snackbar may stay as a *supplementary* toast per
  the UI-SPEC, but is not sufficient alone).
- **Presentation (re-skinnable) vs mechanics (must not move), swap_screen.dart:**

  | Region | Lines | Kind |
  |--------|-------|------|
  | `Scaffold`/`Align`/`ConstrainedBox(maxWidth: 500)` column shell | 218-227 | Presentation (D-07 changes to 560px) |
  | `GWPageHeader` + tune `IconButton` → `SwapSettingsDrawer.show` | 228-251 | Presentation wrapper around mechanics (the `onSlippageChanged` callback IS mechanics — must keep updating `slippage` state, which feeds `swapParams`) |
  | Two `SwapField` widgets, `onChanged`/`onTokenSelected` callbacks | 252-304 | Callbacks are mechanics (drive `_debouncedFetchRoute`); the `SwapField` widget itself is presentation (full re-skin target) |
  | `Transform.translate(offset: Offset(0, -170))` wrapping `TokenFlipButton` | 306-309 | **Presentation hack to remove (D-07)** — `_flipTokens()` callback underneath is mechanics, unchanged |
  | Duplicated `if (fetchedRoute != null)` guard | 310-311 | Dead code, remove (noted as a bug in UI-SPEC, not a mechanics change) |
  | `RouteDetailsCard` | 312-319 | Presentation wrapper; the four values it prints (`route.aggregatePriceImpact`, `route.feeCosts`, `fromAmount`/`toAmount`, `slippage`) are mechanics (D-08) |
  | `ElevatedButton` w/ `Colors.greenAccent`, `onPressed` closure | 320-422 | Button chrome is presentation (→ `GWButton`); **everything inside the `onPressed` closure (332-410) is mechanics** — the `debugPrint`, the `// TODO: invoke Squid API` marker, `Transaction(...)` construction, `ToastManager.showToast`, `SwapSuccessDrawer.show` (→ `showTransactionDetails`, this IS the one authorized mechanics-adjacent change per D-04), `transactionsCubit.addTransaction`, `TransactionStorageService().addTransaction` |

- **`canSwap`** getter and **`swapParams`** getter (`:121-146`) are pure derivations, untouched by
  the re-skin — they gate the CTA's enabled state, which the UI-SPEC's CTA ladder must read from
  (`swapParams == null` ⇒ disabled "Enter an amount"/"Insufficient balance" per whichever sub-case;
  today's code does not actually distinguish "empty" from "insufficient" — see Pitfall 1).

### bridge_screen.dart structural map (726 lines per CONTEXT.md; 727 lines read, all inline in one file — no separate widgets to extract)

- **State:** `BridgeScreenState` holds `fromToken` (`Coin?`, seeded from `widget.fromToken`),
  `toNetwork` (`Network?`), two `TextEditingController`s, `previousNetwork` (unused int?, dead field),
  `availableBridgeNetworks` (`List<Network>?`), `transactionCost` (`String?`), a 300ms debounce
  `Timer`, `_isApiCallInProgress` (bool guard against concurrent gas-cost calls), `isError` (bool).
- **Lifecycle:** `initState` → `fromToken = widget.fromToken` (passed in from
  `router.dart:275: BridgeScreen(fromToken: walletCubit.state.selectedCoin)`), `_fetchBridgeNetworks()`
  → `readNetworkBridgeAssets()` (reads a local asset JSON, sets `toNetwork = networks.first` — this is
  the "destination-network selector" data source; **it is a real local read, not mocked**).
- **The destination-network selector:** built via the generic `_buildDropdown<T>()` helper
  (`:566-697`), instantiated twice — once for the (effectively fixed, single-item) "You Pay" Coin
  dropdown, once for the "You Receive" Network dropdown (`availableBridgeNetworks`). It is a raw
  Material `DropdownButton<T>`, not `TokenSelectorDrawer` — UI-SPEC's requirement to re-skin this as a
  `ResponsiveDrawer`/bottom-sheet list ("mirroring the existing dropdown's data") means **building a
  new selector sheet, not reusing `TokenSelectorDrawer`** (that widget is `SquidTokenInfo`-typed, not
  `Network`-typed — a generic `_buildDropdown<T>` replacement drawer is new code, additive per the
  scope, not a restructure of existing logic since the *data source* (`availableBridgeNetworks`,
  `onItemChanged`) is unchanged).
- **`getBrigeOutGasCost(...)` call site** — inside `onAmountChanged` (`:101-172`), itself inside the
  300ms debounce `Timer` (`:108-171`). Sequence: cancel prior debounce → new `Timer(300ms)` →
  balance-sufficiency pre-check (`double.parse(value) > fromToken.balance` or parse failure ⇒
  `isError = true`, clears `toAmountController`, returns *before* any API call) → `_isApiCallInProgress`
  guard → `context.read<GeniusApi>().getBrigeOutGasCost(sourceChainId:, contractAddress:, rpcUrl:,
  address:, amountToBurn: value, destinationChainId:)` → on `isSuccess`, sets `transactionCost` and
  mirrors the input into `toAmountController.text = value` (bridge is 1:1, so "You Receive" literally
  echoes "You Pay" — confirms D-11's "no rate" is not just a display convention, it's what the code
  already does). On failure: clears everything, `isError = true`.
- **`isGnusBridgeEnabled` / zero-balance disabling is NOT enforced inside `bridge_screen.dart` itself.**
  Grep confirms `isGnusBridgeEnabled` never appears in this file. **The gate lives entirely at the
  caller**, `lib/tokens/token_info_screen.dart` (More → Bridge Tokens row): the outer "More"
  `ActionButton.onPressed` is `isGnusBridgeEnabled ? (...) : null` (finding-37, locked by Phase 7), and
  the inner Bridge-Tokens row is `selectedCoin?.balance == 0 ? null : () => _pushBridgeScreen(...)`. So
  **inside Phase 8's file scope there is nothing to preserve for D-12's gating** — the gate already
  lives outside this phase's files (Phase 7 territory) and is out of scope to touch. D-12's "disabled
  at zero balance" is therefore satisfied by never reaching `/bridge` at all when balance is 0, not by
  any in-screen check. `[VERIFIED: grep + token_info_screen.dart read via 07-07-SUMMARY.md excerpts]`
- **The submit button's `onPressed` closure** (`:205-515`): calls `api.bridgeOut(...
  shouldMintTokens: true)`, then (unconditionally, both success and failure) fires a
  `ToastManager.showToast` (finding 28's "toast alongside" requirement is **already satisfied today**
  for the toast half — it always fires; what's missing is a receipt that survives dismiss, since
  today's `AlertDialog` on `Close` calls `GoRouter.of(context).pop()`, closing the whole bridge screen)
  and **synchronously afterward** opens the `AlertDialog` shown inline (`:233-514`) — this is the
  "result dialog" finding 28 references. Its `Close` action pops the dialog *and* pops the whole
  `/bridge` route (`GoRouter.of(context).pop()`), returning the user to the token-info screen. D-04's
  replacement (`showTransactionDetails`) uses `ResponsiveDrawer.show`, which only pops itself, not the
  underlying route — **the planner should decide explicitly whether the post-receipt navigation
  (return to token-info) is preserved or dropped**; nothing in CONTEXT.md/UI-SPEC states this, and
  losing it would be a silent behavior change worth flagging in the plan.
- **Presentation vs mechanics, bridge_screen.dart:** everything in `_buildDropdown<T>` and the
  `AlertDialog`'s widget tree (`:233-514`) is presentation (full replacement per D-10). Everything
  inside `onAmountChanged`'s debounce body and the submit `onPressed`'s `api.bridgeOut(...)` call
  (`:206-217`) is mechanics (D-11, untouched). The gas-cost/error state variables (`transactionCost`,
  `isError`) are mechanics that the re-skinned route/gas card must continue reading from.

### The Squid quote pipeline

`lib/squid_router/squid_token_service.dart` — **all three methods short-circuit to a mocked
constant, with the real `http` call fully written but commented out beneath each**:

```dart
// Source: lib/squid_router/squid_token_service.dart (also present, byte-identical
// for this class, on origin/develop at 4d1bb36 — this predates the redesign entirely)
static Future<List<SquidTokenInfo>> fetchTokens() async {
  return mockTokens;              // 🧪 MOCKED TOKEN DATA
  // 🌐 REAL API CALL — restore this later when ready  (commented out below)
}

static Future<SquidRouteResponse> getRoute(SquidSwapParams params) async {
  return mockSquidRoute;          // params is IGNORED — same route regardless of input
  // ... real /route call commented out
}
```

`mockSquidRoute` is a single hardcoded constant (`route_id: 'mock-route-123'`, `toAmount: '995000'`,
`aggregatePriceImpact: '0.51'`, one `SquidFeeCost` entry) — **it does not vary by `fromToken`,
`toToken`, or `fromAmount`.** `RouteDetailsCard` (`lib/squid_router/route_details_card.dart`) derives
its three displayed rows purely from this static object plus the caller-supplied `slippage` string —
`pricing = '$fromAmount $fromSymbol ~ $toAmount $toSymbol'`, `priceImpact =
'${route.aggregatePriceImpact}%'`, `fees = totalFeesUsd from route.feeCosts`. **This means Criterion
1 ("route, fee and slippage figures unchanged") reduces to: don't touch `SquidTokenService` or
`RouteDetailsCard`'s three derivations — re-skin the Card's paint only.**

Debounce/refresh behavior: 500ms on swap (`swap_screen.dart:177`), re-triggered on amount change,
token selection (either side), and flip. Failed fetch today surfaces via `showAppSnackBar` only
(`:166-171`) — this is the exact branch D-09/finding-22 requires augmenting, not replacing (keep the
snackbar as supplementary per UI-SPEC, add the field-level `—` + notice + Retry).

### Drawer consolidation mechanics (D-03..D-06)

`showTransactionDetails(context, tx)` — `lib/dashboard/home/widgets/transaction_displays.dart:430`.
Signature: `void showTransactionDetails(BuildContext context, Transaction tx)`. Current production
caller confirmed at `lib/dashboard/home/widgets/transactions_slim_view.dart` (per CONTEXT.md's
line-503 reference — not independently re-verified line-by-line in this pass, but the function's
existence, signature, and full body were read directly from `transaction_displays.dart:430-520+`).

**What it needs to serve a swap result (already works today, D-04 target reuses this path
unchanged):** a real `Transaction` with `type: TransactionType.swap`, `fromAmount`/`toAmount`/
`fromSymbol`/`toSymbol` populated (all four are populated today at `swap_screen.dart:354-377`),
optionally `exchangeRate` (currently **never set** — `Transaction(...)` at `:354` does not pass
`exchangeRate`, so today's swap receipt would print no Rate row at all, since `add()` skips empty
values). The swap-side wiring change is therefore: swap the `SwapSuccessDrawer.show(...)` call
(`:387-399`) for `showTransactionDetails(context, transaction)`, called **after** `transaction` is
constructed and (per finding 28's "toast alongside receipt, not instead") alongside the existing
`ToastManager.showToast` call, not replacing it.

**What it needs to serve a bridge result (does NOT exist today — must be synthesized, see Summary
point 3):** `bridge_screen.dart`'s submit closure has, post-`bridgeOut()`, `bridgeTokensResponse`
(`.isSuccess`, `.data` = tx hash string, `.errorMessage`), plus in-scope local state: `fromToken`
(`Coin`), `toNetwork` (`Network`), `fromAmountController.text`, `state.selectedNetwork` (source chain),
`state.selectedWallet?.address`. None of this is currently packaged into a `Transaction`. A
`Transaction` must be constructed inline in the submit closure (mirroring swap's pattern) with fields
mapped roughly: `hash: bridgeTokensResponse.data ?? ''`, `fromAddress:
state.selectedWallet!.address`, `coinSymbol: fromToken.symbol`, `fees: transactionCost ?? '0'`
(the gas cost — this is bridge's only "fee", per D-11's "gas only"), `transactionStatus:
bridgeTokensResponse.isSuccess ? TransactionStatus.completed : TransactionStatus.failed` (bridge, unlike
swap, has a REAL success/failure branch to report — UI-SPEC explicitly calls this out), `timeStamp:
DateTime.now()`.

**The `TransactionType` gap (the open mechanics question CONTEXT.md/UI-SPEC explicitly defers to this
document):** `packages/genius_api/lib/models/transaction.dart`'s `TransactionType` enum has exactly
seven values — `transfer, mint, escrow, process, escrowRelease, purchase, swap` — **there is no
`bridge` value.** `showTransactionDetails`'s `isSwap` branch (`tx.type == TransactionType.swap`) is
the only special-cased path that produces a From/To pair instead of a single counterparty-address row;
everything else falls into the generic `isSent ? 'To' : 'From'` + one address. Three options, with a
recommendation:

| Option | What it touches | Correctness | Scope-fence risk |
|--------|------------------|-------------|-------------------|
| **A — reuse `TransactionType.swap`** | Nothing outside Phase 8's files | **Wrong**: `_actionFor()`/title derivation (`transaction_utils.dart`, Phase-12-owned) would label the receipt "Swapped" and title it `GNUS → GNUS` (fromSymbol==toSymbol for a bridge) — exactly the "reads as a token conversion" outcome the UI-SPEC's bridge field-label note explicitly warns against | None (no file touched outside scope) but produces incorrect, contract-violating copy |
| **B — reuse `TransactionType.transfer`** | Nothing outside Phase 8's files | Partially wrong: shows a single address row, not a From-network/To-network pair; loses the "on {network}" framing UI-SPEC wants; but at least doesn't say "Swapped" | None, but the receipt for bridge will look noticeably thinner than swap's, which is a real UX inconsistency between the two D-03-unified flows |
| **C (recommended) — add `TransactionType.bridge`** | `packages/genius_api/lib/models/transaction.dart` (append `@HiveField(7) bridge` — the next free index, purely additive to a `hive_ce`-generated adapter, safe for existing serialized data since no existing index is reused/reordered) + regenerate `transaction.g.dart` via `dart run build_runner build`; `lib/dashboard/home/widgets/transaction_utils.dart`'s `_badgeForType`/`_actionFor` switches (add one `case TransactionType.bridge:` arm each — Dart's exhaustive-switch-on-enum will not compile otherwise, so this is forced, not optional, the moment the enum grows); `showTransactionDetails`'s own `isSwap` check needs a parallel `isBridge` check reusing the same From/To/no-Rate layout | Correct: distinct title/action copy ("Bridged"), From/To rows read as network-to-network (not token-to-token), Rate row naturally absent (bridge Transaction never sets `exchangeRate`) | **Touches files outside Phase 8's CONTEXT.md scope fence** (`packages/genius_api`, `transaction_utils.dart`/`transaction_badge.dart` if a distinct badge kind is also wanted) — the planner should either get explicit sign-off to extend the file scope, or reuse an EXISTING `TransactionBadgeKind` (e.g. `.mint`, since bridge mints on the destination chain) to avoid also touching `transaction_badge.dart`'s enum |

Recommendation: **Option C, badge reuse sub-variant** (add `TransactionType.bridge` to the shared enum
+ two small `case` arms in `transaction_utils.dart`, but map it to an *existing* `TransactionBadgeKind`
rather than inventing a tenth one) — this is the minimum edit that avoids the "Swapped"/token-conversion
copy defect while touching the smallest possible set of Phase-12-owned files. Whatever the planner
decides, it must be written down explicitly as a task, since CONTEXT.md defers this exact call to
research.

**Whether the synthesized bridge `Transaction` should also be persisted** (`transactionsCubit
.addTransaction()` + `TransactionStorageService().addTransaction()`, mirroring swap) is a second,
separate discretionary call: today bridge results are NOT persisted anywhere (no Transactions-tab
entry survives a bridge). Adding persistence would make bridge results retroactively visible in the
Transactions tab/panel (Phase 12/15 territory) — a genuine behavior addition beyond "reuse the
receipt," not covered by D-11 ("mechanics untouched" refers to the burn/mint call, not to whether a
local record is kept of it). Recommend: **do not persist** — construct the `Transaction` in-memory,
pass it directly to `showTransactionDetails`, and do not call the Cubit/storage methods. This keeps
the phase's blast radius to "receipt display only," matches D-11's literal untouched-mechanics
framing, and avoids a second cross-phase surface (Transactions tab) silently gaining a new row type
mid-flight. If the user wants bridge persisted, that is a product call for a future todo, not this
phase.

**Superseded-drawer call-site inventory (D-06):**

| File | Production callers | Dev-only callers |
|------|----------------------|--------------------|
| `swap_success_drawer.dart` (`SwapSuccessDrawer`) | `swap_screen.dart:387` (the only one — becomes `showTransactionDetails` per D-04) | `dev_tools_bubble.dart:584` ("Succeed" test button) |
| `swap_fail_drawer.dart` (`SwapFailDrawer`) | **none** (confirmed — CONTEXT.md's claim holds) | `dev_tools_bubble.dart:602` ("Failed" test button) |
| `swap_drawer_content.dart` (`SwapDrawerContent`) | Only consumed by the two files above (no independent caller) | — |
| `lib/reown/swap_result_drawer.dart` (`SwapResultDrawer`) | `lib/reown/handle_dapp_requests.dart:177,205` (**D-05 — do not touch**) | `dev_tools_bubble.dart:538,551` ("Swap OK"/"Swap fail" test buttons) |

D-06's required `dev_tools_bubble.dart` update: the "Succeed"/"Failed" buttons (`SwapSuccessDrawer`/
`SwapFailDrawer`) must be repointed to `showTransactionDetails(context, <a synthetic Transaction>)` or
removed; the "Swap OK"/"Swap fail" buttons (`SwapResultDrawer`, reown) **must be left calling
`SwapResultDrawer`** — per D-05, that file and everything that exercises it (including this dev
button) is untouched. Do not delete `SwapResultDrawer`'s dev-bubble entry point along with the other
two; it is the only thing keeping `reown/swap_result_drawer.dart` reachable for manual testing, and
D-05 does not ask for it to be removed.

### The `GlobalSwapFabHost` port (D-17/D-18)

`git show 7a63b4f:lib/components/overlay/global_swap_fab_host.dart` (143 lines, confirmed) wraps the
app's `Navigator` in a `Stack` and floats **two** FABs over it: `GWSwapFab` (bottom-right, already
ported, `lib/components/buttons/gw_swap_fab.dart` exists and is used) and **`GWAiFab`** (bottom-left,
`lib/components/buttons/gw_ai_fab.dart`).

**`GWAiFab`/`gw_ai_fab.dart` does NOT exist on `ui-redesign-port`.** Confirmed by both a direct file
search (`find lib -iname "*ai_fab*"` → no results) and ROADMAP.md's own Phase 3 accounting: "60
additive − 9 nav-shell (Phase 4) **− 1 `gw_ai_fab.dart` (WIRE-02)** = 50 files" — it was deliberately
excluded from the Phase 3 port because WIRE-02 places `lib/ai/` (and, by the same reasoning, its FAB)
out of scope for this milestone as new, mostly-demo-backed capability requiring a product decision.

**This means the file at `7a63b4f` cannot be ported verbatim — it will fail to compile** (`import
'package:genius_wallet/components/buttons/gw_ai_fab.dart'` resolves to nothing, and the AI-FAB
`Positioned`/`GWAiFab(...)` block references a class that doesn't exist). D-18 says "port it rather
than reimplementing," but a byte-for-byte port is impossible without also porting `gw_ai_fab.dart`
(which WIRE-02 forbids) or its dependency, `lib/submit_job/view/submit_job_screen.dart` (**this one
DOES exist** on `ui-redesign-port` — confirmed at `lib/submit_job/view/submit_job_screen.dart`, and
its route `/submit_job` is already registered in `router.dart:280-292` — so the *destination* of the
AI FAB's tap target is fine; only the FAB widget itself is the blocker).

**Recommendation:** port the file with the `GWSwapFab`/swap half kept verbatim (including the
`_hiddenPaths` set, the `_ready` guard, its comment, and the `_onRouteChanged` scheduler-phase
handling — all confirmed unrelated to the AI FAB) and the `GWAiFab` `Positioned` block (and its
import) **removed**. This is a real, necessary deviation from "port, don't reimplement" that the
planner must call out explicitly as a task-level decision, not silently — D-18's instruction to
preserve the `_ready` guard "verbatim" still fully applies to the surviving 90% of the file; only the
AI-FAB-specific ~15 lines (the import, the `Positioned(left: ..., child: GWAiFab(...))` block, and its
`path != '/submit_job'` condition) are dropped.

**Route-path cross-check (confirms a clean port for the surviving logic):** every path in
`GlobalSwapFabHost._hiddenPaths` was grep-verified to exist on `ui-redesign-port`'s
`wallet_routes.dart` (`/landing_screen`, `/backup_phrase`, `/recovery_phrase`,
`/verify_recovery_phrase`, `/import_wallet`, `/import_security`, `/import_existing_wallet`,
`/create_wallet`) **except `/legal`, which does not exist as a route path on this branch** (grep for
`path: '/legal'` returns nothing). This is not necessarily a bug — Phase 6's `06-02-PLAN.md` mentions
"Shared Legal step," which may be a step *within* another flow rather than its own route — but the
planner should verify this during the port rather than assume the hidden-paths set transfers 1:1; an
extra harmless entry (hiding a FAB on a path that's never actually reached) is low-risk, but silently
means real developer intent (Legal screen should hide the FAB) may not be honored if `/legal` is
reachable under a different path string on this branch.

**Mount point:** `main.dart`'s `MyApp.build()` currently returns `MaterialApp.router(...)` directly
inside a `ValueListenableBuilder<GWAppearanceMode>` — confirmed at `main.dart:332-344`. There is
**no existing `builder:` parameter on `MaterialApp.router`** on this branch today (`MaterialApp.router`
here only sets `debugShowCheckedModeBanner`, `locale`, `builder: DevicePreview.appBuilder`, `title`,
`theme`, `routerConfig`) — wait, it DOES already have a `builder: DevicePreview.appBuilder` set.
`GlobalSwapFabHost`'s own doc comment says it must mount "once at the `MaterialApp.router` builder
level in `main.dart`" — since `builder` is already occupied by `DevicePreview.appBuilder`, the two
must be composed (`DevicePreview.appBuilder` wrapping `GlobalSwapFabHost`, or vice versa — verify which
order `DevicePreview` expects at port time; typically `DevicePreview.appBuilder` should be the
OUTERMOST wrapper since it simulates a full device frame). This composition point is not mentioned in
CONTEXT.md/UI-SPEC and is a genuine new integration detail the planner must handle, not a copy-paste.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Drawer/bottom-sheet shell (desktop side-panel vs mobile bottom-sheet) | A new modal/drawer widget for the destination-network picker | `ResponsiveDrawer.show()` | Already the shell for every other drawer in this phase (`SwapSettingsDrawer`, `TokenSelectorDrawer`, `showTransactionDetails`); breakpoint logic, dismiss/drag behavior, and appearance-aware fill are all solved there |
| Route-error inline banner | A bespoke error-state widget from scratch | A small `Container` following the UI-SPEC's exact spec (background `statusError` @ ~12% alpha, `radiusMd`, `space6`/`space8` padding) — confirmed no existing `GWInlineNotice` primitive exists to reuse instead, so this one *is* new code, but keep it minimal and inline rather than generalizing it into a new shared component (that would be scope creep beyond this phase's fence) | UI-SPEC already pre-authorized this as additive-only |
| CTA disabled/loading state ladder | Custom `ElevatedButton` state machine (as today's raw `ElevatedButton` already hand-rolls, badly — `Colors.greenAccent` hardcode) | `GWButton`'s existing `isLoading`/disabled-via-`onPressed: null` support | The button already supports every state the ladder needs; the CTA's *label copy* per state is the only new logic (a small switch in the screen, not the button) |
| Decimal amount input validation | A new formatter | `DecimalTextInputFormatter` (already defined in `bridge_screen.dart:700-726`) — could be shared/reused for the bridge amount field re-skin rather than reimplemented, though `swap_field.dart`'s `TextField` currently has NO formatter at all (accepts anything `keyboardType: numberWithOptions(decimal: true)` allows, which is a soft-keyboard hint only, not real validation) — this is a pre-existing gap, not introduced by this phase, and out of scope to fix unless the planner decides input hardening belongs in "re-skin" (it does not, per re-skin-never-restructure doctrine — flag, don't fix) | Avoids two divergent decimal-parsing implementations |

**Key insight:** almost everything this phase needs already exists in the codebase under a different
visual skin. The actual net-new code is small and concentrated in exactly three places: (1) the
route-error notice banner, (2) the bridge network-picker drawer body, (3) the synthesized bridge
`Transaction` + its `TransactionType` handling. Everything else is find-the-existing-primitive-and-
swap-it-in.

## Common Pitfalls

### Pitfall 1: The CTA state ladder has no "insufficient balance" branch today
**What goes wrong:** `canSwap` (`swap_screen.dart:121-125`) only checks `fromToken/toToken != null`,
`fromAmount.isNotEmpty`, and `double.tryParse(fromAmount) != null`. It never compares `fromAmount`
against the selected token's balance. The UI-SPEC's CTA ladder requires a distinct "Insufficient
{symbol} balance" disabled state (`statusError` fill) — **this condition does not exist in the
codebase today and must be newly derived** (likely `double.parse(fromAmount) >
(fromToken?.balance?.formattedBalance ?? 0)`, mirroring the pattern `bridge_screen.dart:116-119`
already uses for its own balance check).
**Why it happens:** the mocked swap flow never needed a real balance check since nothing executes.
**How to avoid:** treat this as new derived state (a `bool insufficientBalance` computed from
`fromToken.balance` vs `fromAmount`), added alongside `canSwap`, not a re-skin of existing logic.
**Warning signs:** if the planner assumes "insufficient balance" already exists as a variable
somewhere in `swap_screen.dart`, it doesn't — grep confirms no `balance` comparison exists in the file
outside `SwapField`'s balance *display* line.

### Pitfall 2: The Squid quote pipeline is fully mocked and input-invariant — verification must not assume a live network path
**What goes wrong:** a planner or verifier could write a Nyquist check like "select two different
token pairs, confirm the quote changes" — this will always fail, because `mockSquidRoute` is a single
constant returned regardless of `SquidSwapParams`. This is not a regression risk of this phase; it is
the **existing, correct** behavior on `develop` (confirmed at `origin/develop:4d1bb36`).
**Why it happens:** develop itself never wired the real Squid HTTP calls (they're written and
commented out, `squid_token_service.dart:16-28,38-56,61-82`) — this long predates the redesign.
**How to avoid:** verification for Criterion 1 should be "the SAME three numbers (`995000`/`0.51%`/
fee-derived-from-static-`feeCosts`) appear before and after the re-skin, for ANY token pair selected"
— not "different pairs produce different quotes."
**Warning signs:** if a task's verification step tries to assert quote *variance* by input, that task
is testing something the app has never done.

### Pitfall 3: The `-170` offset hack — confirmed present, confirmed removable
**What goes wrong (if left in place):** `swap_screen.dart:306-309`,
`Transform.translate(offset: const Offset(0, -170), child: TokenFlipButton(onFlip: _flipTokens))` —
this yanks the flip button 170px up the widget tree from wherever `Column` layout would otherwise
place it (currently: after both `SwapField`s, so the hack pulls it back up into the seam between
them). D-07 explicitly names removing this hack as the *signal* that the new seam-based layout landed
correctly.
**Why it happens:** the original implementation solved "put the flip button between two cards" with a
literal pixel offset instead of a `Stack`/seam-overlap layout.
**How to avoid:** the re-skinned layout should position the flip control via a proper overlap
mechanism (e.g. a `Stack` with the button `Positioned` at the seam, or negative margins on the button
itself sized to its own known height, not a magic `-170`). The `onFlip: _flipTokens` callback and
`_flipTokens()`'s body (swaps tokens, swaps amounts, updates controllers, re-fetches route) are
mechanics and must not change.
**Warning signs:** if the new layout still contains any `Transform.translate` with a hardcoded pixel
offset for the flip button, the hack was re-skinned, not removed.

### Pitfall 4: Bridge's `getBrigeOutGasCost`/`bridgeOut` are REAL calls — do not treat bridge like swap's D-01 stub
**What goes wrong:** because D-01 establishes "swap deliberately doesn't execute," a planner could
over-generalize and assume bridge is similarly inert. It is not: `genius_api.dart:1112-1148`'s
`bridgeOut()` calls `Web3(geniusApi: this).executeBridgeOutTransaction(...)` and, on success with
`shouldMintTokens: true`, `mintTokens(...)` — real on-chain burn+mint. `getBrigeOutGasCost` similarly
calls into `Web3(...).getBrigeOutGasCost(...)` for a real gas estimate.
**Why it happens:** confusion from D-01/D-02's swap-specific "deliberately unwired" framing bleeding
into bridge, which CONTEXT.md's D-11 already correctly scopes as "untouched" (implying it currently
works) rather than "stays a stub."
**How to avoid:** any manual/walk verification of bridge behavior on a real network is exercising real
funds — this is explicitly why bridge is GNUS-only and gated (D-12); the planner should NOT add a
"submit a live bridge" step to an automated or unattended verification loop. A human walk with a
non-zero-but-small real GNUS balance, on a testnet if one is configured, is the appropriate level of
verification — confirm this is possible/desired with the user before planning a task that submits a
live `bridgeOut()` call.
**Warning signs:** a plan task that calls `bridgeOut()` in an automated test without an explicit human
checkpoint.

### Pitfall 5: `GlobalSwapFabHost` at `7a63b4f` will not compile as-is on this branch
**What goes wrong:** see "The GlobalSwapFabHost port" above — the file imports
`gw_ai_fab.dart`, which does not exist on `ui-redesign-port` (deliberately excluded, WIRE-02).
**Why it happens:** the source commit lives on `ui-redesign-3.514-develop`, a branch that DID carry
the AI FAB forward; `ui-redesign-port`'s Phase 3 deliberately did not.
**How to avoid:** strip the `GWAiFab` half of the file during the port (see recommendation above);
this is a required edit, not an optional cleanup.
**Warning signs:** `flutter analyze` reporting an unresolved import for `gw_ai_fab.dart` after the
port — if the planner's task description says "port verbatim" with no mention of stripping the AI-FAB
block, the resulting task will fail to compile.

### Pitfall 6: `bridge_screen.dart` has no `Transaction` construction — D-04 needs new code, not a re-skin, for the bridge half of the receipt work
**What goes wrong:** a planner reading D-04 ("replaces the three squid_router drawers... After a
successful bridgeOut(...) call, call showTransactionDetails(context, transaction)") could assume
`transaction` is a pre-existing local variable at that call site, the way it is in `swap_screen.dart`.
It is not — see Summary point 3 and "Drawer consolidation mechanics" above.
**Why it happens:** the UI-SPEC's Component Inventory row for the result receipt reads naturally as a
drop-in replacement, and for swap it genuinely is; the symmetry breaks for bridge.
**How to avoid:** budget a real task (not a one-line swap) for constructing the bridge `Transaction`,
deciding the `TransactionType` question (see Option table above), and deciding the persistence
question (recommend: no).
**Warning signs:** a plan that estimates the bridge receipt wiring as equal-effort to the swap receipt
wiring.

## Code Examples

### The mechanics this phase must NOT change (swap submit closure — reference for "what re-skin
means here": swap ONLY the button chrome and the drawer call, keep every line below it)

```dart
// Source: lib/squid_router/swap_screen.dart:332-410 (current state — the closure
// this phase re-skins the OUTER button for, while preserving everything inside)
onPressed: swapParams == null
    ? null
    : () async {
        final params = swapParams!;
        debugPrint('Swapping with params: ${params.toJson()}');
        // TODO: invoke Squid API   <-- D-01: stays exactly as-is, do not implement
        final walletState = context.read<WalletDetailsCubit>().state;
        final walletAddress = walletState.selectedWallet?.address;
        final walletNetwork = walletState.selectedNetwork?.symbol;
        final transactionsCubit = context.read<TransactionsCubit>();
        // TODO: record transaction...  <-- also stays; the Transaction below is
        // built regardless of whether a real swap happened (the D-01 deviation)
        final transaction = Transaction(
          hash: "",
          fromAddress: walletAddress!,
          recipients: [TransferRecipients(toAddr: walletAddress, amount: toAmount)],
          timeStamp: DateTime.now(),
          transactionDirection: TransactionDirection.received,
          fees: fromAmount,
          coinSymbol: walletNetwork!,
          transactionStatus: TransactionStatus.completed,
          type: TransactionType.swap,
          toAmount: toAmount,
          toIconUrl: toToken?.logoURI,
          fromSymbol: fromToken?.symbol,
          toSymbol: toToken?.symbol,
          fromAmount: fromAmount,
          fromIconUrl: fromToken?.logoURI,
        );
        ToastManager.instance.showToast(/* ... unchanged ... */);
        // D-04 TARGET: replace this call —
        SwapSuccessDrawer.show(context, /* ... */);
        // with:
        // showTransactionDetails(context, transaction);
        transactionsCubit.addTransaction(transaction);
        await TransactionStorageService().addTransaction(walletAddress, transaction);
      },
```

### The receipt function's swap special-case (what a bridge equivalent needs to mirror)

```dart
// Source: lib/dashboard/home/widgets/transaction_displays.dart:437-464
final isSwap = tx.type == TransactionType.swap;
// ...
if (isSwap) {
  // A swap's counterparty is a router contract, not a person, and its
  // "From"/"To" labels would collide with the address row's — so the pairs
  // take those labels and the address row is dropped for this type.
  add('From', '${formatTxAmount(tx.fromAmount ?? '')} ${tx.fromSymbol ?? ''}');
  add('To', '${formatTxAmount(tx.toAmount ?? '')} ${tx.toSymbol ?? ''}');
  add('Rate', tx.exchangeRate ?? '');   // add() skips empty values — no Rate row
                                          // if exchangeRate is never set (true for
                                          // swap today, and should stay true/absent
                                          // for a synthesized bridge Transaction)
} else {
  final counterparty = isSent
      ? (tx.recipients.isEmpty ? '' : tx.recipients.first.toAddr)
      : tx.fromAddress;
  add(isSent ? 'To' : 'From', WalletUtils.getAddressForDisplay(counterparty));
}
```

## State of the Art

Not applicable in the usual "library version bump" sense — no libraries are changing. The only
"before/after" that matters here is develop's raw-Material chrome versus the shipped `gw_*` design
system, which is already fully documented in the UI-SPEC's Component Inventory. No further research
needed on this axis.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | `/legal` not existing as a route path (vs. being a step within another flow, e.g. onboarding) means `GlobalSwapFabHost`'s `_hiddenPaths` entry for it is inert rather than broken | The GlobalSwapFabHost port | Low — worst case the FAB shows on a screen it should be hidden on, or the entry is simply dead and harmless; verify at port time |
| A2 | `DevicePreview.appBuilder` should wrap OUTSIDE `GlobalSwapFabHost` (device-frame simulation as the outermost layer) rather than the reverse | The GlobalSwapFabHost port, mount point | Low-medium — wrong composition order could make the FAB render outside the simulated device frame in `DevicePreview` mode, a dev-only cosmetic issue, not a production behavior change |
| A3 | Reusing an existing `TransactionBadgeKind` (rather than adding a tenth) for a new `TransactionType.bridge` is the lower-risk path the planner should take | Drawer consolidation mechanics, Option C | Low — this is a recommendation, not a fact; if the user/planner prefers a fully distinct bridge badge, that is a valid alternative choice, just touches one more file |
| A4 | The bridge submit's post-dialog `GoRouter.of(context).pop()` (returning to token-info) should NOT be preserved when the AlertDialog is replaced by `showTransactionDetails`'s `ResponsiveDrawer` | bridge_screen.dart structural map | Medium — if the user actually wants "close receipt → return to token detail," dropping this pop is a real behavior regression; flagged explicitly as a planner decision point, not silently assumed either way |

**If this table is empty:** N/A — see above.

## Open Questions

1. **Should the synthesized bridge `Transaction` be persisted (added to `TransactionsCubit`/
   `TransactionStorageService`) or kept in-memory-only for the receipt call?**
   - What we know: today nothing is persisted for bridge; swap already persists (by the D-01
     deviation, unconditionally, even though nothing executed).
   - What's unclear: whether "reuse the receipt" implicitly means "reuse the whole
     record-then-display pattern" or just "display."
   - Recommendation: default to NOT persisting (smallest blast radius, keeps this phase's file scope
     from touching Phase 12/15's Transactions-tab data model); surface this as an explicit
     checkpoint/decision in the plan rather than deciding silently either way.

2. **Does the user want a live `bridgeOut()` call exercised during this phase's human walk (real GNUS,
   real gas, real burn+mint), or should the walk stop at the CTA-ready state without submitting?**
   - What we know: `bridgeOut`/`getBrigeOutGasCost` are real on-chain calls (Pitfall 4); D-16 confirms
     Windows is the walk host with no platform-view complication, but says nothing about whether a
     live submission is expected.
   - What's unclear: whether a testnet is configured for this wallet, or whether "verified by running
     the app" (BLD-02) is expected to include an actual bridge submission for this phase.
   - Recommendation: the planner should surface this as an explicit `checkpoint:human-verify` decision
     rather than assuming either a full live submission or a CTA-only dry run.

## Environment Availability

Not applicable — this phase introduces no new external tool/service dependencies. The existing
project-wide environment facts apply unchanged: Windows debug build via
`C:\Users\User\Documents\Projects\GNUS\flutter\flutter\bin\flutter.bat` (not on PATH),
`flutter analyze lib` baseline = 61 issues (pre-existing, not to be reported as new), `flutter test`
compiles and runs (250 pass / 1 known pre-existing failure unrelated to this phase).

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with Flutter SDK) + `mockito ^5.0.0` |
| Config file | none dedicated — standard `test/` directory convention, no `dart_test.yaml` found |
| Quick run command | `flutter test test/<specific_file>.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SCR-04 (Criterion 1: quote unchanged) | `RouteDetailsCard`'s three derived strings (`pricing`, `priceImpact`, `fees`) are unchanged for the same `mockSquidRoute` input, pre/post re-skin | unit (pure function, no widget pump needed — `RouteDetailsCard` derives its rows in `build()`, so this would need a small extraction or a widget test) | `flutter test test/squid_router/route_details_card_test.dart` (new file) | ❌ Wave 0 — no `test/squid_router/` directory exists today |
| SCR-04 (Criterion 2: route-error notice) | Failed `_fetchRoute()` produces `—` in "You Receive" + visible notice + enabled Retry | widget test (pump `SwapScreen`, mock a throwing `SquidTokenService.getRoute` — not currently mockable via DI, `SquidTokenService` methods are `static`, so this may require a wrapper/interface or fall back to manual walk) | manual-only, OR refactor to injectable service first (out of this phase's re-skin scope — recommend manual walk) | N/A — manual walk is the practical path given the static-method service |
| SCR-04 (Criterion 3: D-01 deviation preserved) | Submitting swap still records+persists a `Transaction` with `type: swap` and does NOT call any real Squid execution endpoint | unit/grep-gate | `grep -q "// TODO: invoke Squid API" lib/squid_router/swap_screen.dart` (regression guard that the deviation stays written down, not accidentally "fixed") | Trivial to add — recommend as a Wave 0 grep gate, not a full test file |
| SCR-04 (Criterion 4: bridge toast + receipt) | Bridge submit fires both `ToastManager.showToast` and `showTransactionDetails` | manual walk (real/testnet `bridgeOut()` call, see Open Question 2) | N/A | N/A |
| SCR-04 (Criterion 5: GlobalSwapFabHost mounted, no `!_dirty`) | Cold start with no red-screen crash, FAB visible on `/dashboard`, hidden on `/swap`/onboarding paths | manual walk (this class of startup-timing bug was explicitly noted in Phase 4/13's ROADMAP entries as NOT reproducible under `pumpWidget`, since it depends on `runApp`'s real mount timing) | N/A — do not attempt a `flutter test` widget-pump reproduction; APP-02's own notes confirm this bug class needs a real walk | N/A |

### Sampling Rate
- **Per task commit:** `flutter analyze lib` (confirm no new issues beyond the 61 baseline) +
  targeted `flutter test` for any new pure-function test files (e.g. route-details derivation, the
  D-01 grep gate).
- **Per wave merge:** `flutter test` (full suite, confirm 250/251 pass unchanged) + a debug build
  launch.
- **Phase gate:** full suite green + the human walk covering Criteria 2, 4, 5 (the three criteria that
  cannot be automated per the table above) before `/gsd-verify-work`.

### Wave 0 Gaps
- [ ] `test/squid_router/` directory — does not exist; create if the planner wants an automated
      regression guard for `RouteDetailsCard`'s derivation (recommended, since Pitfall 2 makes this an
      easy, cheap, high-value test: mock input in, assert the same three strings out)
- [ ] A grep-based regression gate (e.g. a `tool/` script or an inline `<automated>` check in the
      plan) asserting `// TODO: invoke Squid API` and `// TODO: record transaction` still exist in
      `swap_screen.dart` after the re-skin — cheap insurance against D-01 being silently "fixed"
- [ ] No framework install needed — `flutter_test`/`mockito` already present

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | No | This phase touches no auth flow |
| V3 Session Management | No | N/A |
| V4 Access Control | Partial | `isGnusBridgeEnabled`/zero-balance gating already lives outside this phase's file scope (Phase 7's `token_info_screen.dart`) — Phase 8 must not weaken it, but also cannot fix it from within its own files if it were broken (it is not, per this research) |
| V5 Input Validation | Yes | Amount fields: `bridge_screen.dart`'s existing `DecimalTextInputFormatter` (regex `^\d*\.?\d*$`) is the standard already in use; `swap_field.dart`'s `TextField` currently has NO formatter (soft-keyboard hint only) — flagged as a pre-existing gap (Don't Hand-Roll table), not this phase's mechanics to fix, but the planner should not let a re-skin accidentally REMOVE the bridge field's existing formatter while re-skinning its chrome |
| V6 Cryptography | No | Wallet key handling is entirely outside this phase (owned by `local_secure_storage`/`genius_api`'s wallet layer); this phase only reads an already-unlocked wallet's address/balance |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|----------------------|
| Untrusted token symbol/hash interpolated into asset paths or displayed raw | Tampering / Information Disclosure | Already handled upstream by `sanitizeCoinAsset()` (`transaction_utils.dart:106-109`, `a-z0-9` allowlist + length cap) for the receipt path; token data in `swap_field.dart`/`token_selector_drawer.dart` comes from `SquidTokenService`'s mocked constants today (not attacker-controlled), so this is a latent concern for when the real API is wired (out of scope), not an active one now |
| Bridge amount exceeding balance submitted to a real on-chain call | Tampering / Repudiation (spending more than intended) | Already guarded client-side at `bridge_screen.dart:114-126` (balance pre-check before the debounced API call) — preserve this check verbatim per D-11 |
| Displaying a stale/incorrect quote as if current (the exact defect D-09 exists to fix) | Information Disclosure / user financial harm | D-09's `—` + notice + Retry pattern — this phase's one genuinely new interaction lock |

## Sources

### Primary (HIGH confidence — direct repo reads/greps on `ui-redesign-port`, this session)
- `lib/squid_router/swap_screen.dart` (full read)
- `lib/dashboard/bridge/bridge_screen.dart` (full read, 727 lines)
- `lib/squid_router/swap_field.dart`, `swap_settings_drawer.dart`, `token_flip_button.dart`,
  `route_details_card.dart`, `swap_success_drawer.dart`, `swap_fail_drawer.dart`,
  `swap_drawer_content.dart`, `token_selector_drawer.dart`, `squid_token_service.dart`,
  `models/squid_swap_params.dart` (full reads)
- `lib/components/buttons/gw_swap_fab.dart`, `lib/dev/dev_tools_bubble.dart`,
  `lib/reown/swap_result_drawer.dart` (full reads)
- `lib/dashboard/home/widgets/transaction_displays.dart` (lines 280-499, incl. full
  `showTransactionDetails`), `lib/dashboard/home/widgets/transaction_utils.dart` (full read),
  `lib/dashboard/home/widgets/transaction_badge.dart` (full read)
- `lib/navigation/router.dart` (full read), `lib/main.dart` (full read),
  `lib/components/splash.dart` (full read)
- `lib/components/scaffold/gw_page_header.dart` (full read),
  `lib/components/bottom_drawer/responsive_drawer.dart` (partial, signature confirmed),
  `lib/theme/gw_colors.dart` (grep-confirmed getters), `lib/components/buttons/gw_button.dart`
  (grep-confirmed enums/params)
- `packages/genius_api/lib/models/transaction.dart` (full read), `packages/genius_api/lib/src/
  genius_api.dart` lines 1100-1180 (`bridgeOut`/`getBrigeOutGasCost`, full read)
- `git show 7a63b4f:lib/components/overlay/global_swap_fab_host.dart` (full file, from
  `ui-redesign-3.514-develop`) + `git diff 7a63b4f^ 7a63b4f -- .../global_swap_fab_host.dart` (the
  fix's own diff) + `git log`/`git show --stat` for the commit's own description
- `git log --follow -- lib/squid_router/squid_token_service.dart` and
  `git show origin/develop:lib/squid_router/squid_token_service.dart` (confirms the mocking predates
  the redesign)
- Grep sweeps across `lib/` for: `isGnusBridgeEnabled`, `Bridge Tokens`/`BridgeScreen(`,
  `SwapResultDrawer`, `GWInlineNotice`, `gw_ai_fab`, route-path strings from `_hiddenPaths`

### Secondary (MEDIUM confidence)
- `.planning/phases/07-token-screens/07-07-SUMMARY.md` / `07-07-PLAN.md` excerpts (grep results only,
  not full reads) for the exact `token_info_screen.dart` More→Bridge gating code, since that file
  itself was not read in full this session (out of Phase 8's scope, cited for context only)

### Tertiary (LOW confidence)
- None — no WebSearch/Context7 lookups were performed or needed; this phase's entire surface is
  internal repo code with no new third-party library research required

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — no new packages, every primitive's signature was read directly from source
- Architecture: HIGH — both screens read in full; mocked-quote and real-bridge findings are
  git-verified, not inferred
- Pitfalls: HIGH — all six pitfalls are grounded in direct code reads or `git show`/`git diff`, not
  speculation
- The `TransactionType`/bridge-receipt recommendation (Option C): MEDIUM — this is a genuine design
  recommendation among three valid options, not a fact; flagged accordingly in the Assumptions Log

**Research date:** 2026-07-25
**Valid until:** this phase's own execution (re-skin phases are point-in-time against a specific
branch state; if `ui-redesign-port` moves significantly before Phase 8 executes, especially any
change to `squid_token_service.dart`, `genius_api.dart`'s bridge methods, or the `TransactionType`
enum, this research should be re-verified against the new `HEAD`)
