---
phase: quick-260720-cw8
plan: 01
subsystem: ui
tags: [flutter, dev-tooling, dashboard, wallet-details-cubit, coins-screen, mock-data]

requires:
  - phase: 05-dashboard
    provides: CoinsScreen, WalletDetailsCubit, CoinCardRow
  - phase: quick-260720-bgl
    provides: DevToolsBubble draggable dev-only overlay widget
provides:
  - DevMockHoldings dev-only fixture singleton (Populated/Long-extreme/Missing-icon/Clear scenarios)
  - WalletDetailsCubit.mockMode seam (injectMockCoins/clearMock, getCoins() short-circuit)
  - CoinsScreen._fetchMarketData offline short-circuit while mock-mode is ON
  - Four scenario buttons in the dev-tools bubble
affects: [05-dashboard]

tech-stack:
  added: []
  patterns:
    - "Dev-only fixture singleton (private ctor + static final instance) imported only by dev-gated call sites, zero cubit/widget imports itself"
    - "Mock-mode seam: a plain bool on the cubit gates the top of the real async method (getCoins()) so live re-fetches (selectNetwork/selectWallet) can't overwrite injected mock state"

key-files:
  created:
    - lib/dev/dev_mock_holdings.dart
  modified:
    - lib/wallets/cubit/wallet_details_cubit.dart
    - lib/components/coins/view/coins_screen.dart
    - lib/dev/dev_tools_bubble.dart

key-decisions:
  - "Fixture file uses a `// DEV-ONLY:` comment, not the plan's literal `ponytail:` marker (a typo per this run's explicit instructions) -- content and intent (dev-only, compiles away under kDebugMode tree-shaking, not for production use) preserved verbatim"
  - "All Populated/Long-extreme/Missing-icon iconPath values reference crypto assets confirmed to exist under assets/images/crypto/ (eth.png, btc.png, usdc.png, gnus.png, agi.png, sol.png); NOICON's iconPath is deliberately '' to exercise the image_not_supported fallback"
  - "CoinGeckoMarketData fixture builder fills every non-seeded required field with harmless defaults (0 / DateTime.fromMillisecondsSinceEpoch(0) / null where nullable), keeping the scenario tables terse while satisfying the real unnamed constructor's full required-field list"

requirements-completed: [QUICK-260720-cw8]

coverage:
  - id: D1
    description: "DevMockHoldings singleton created with loadPopulated/loadExtreme/loadMissingIcon/clear scenario loaders and a totalBalance getter computing sum(balance*currentPrice)"
    requirement: "QUICK-260720-cw8"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_mock_holdings.dart"
        status: pass
    human_judgment: false
    rationale: "Pure data/logic fixture, fully verified by analyze + the deterministic scenario tables it encodes."
  - id: D2
    description: "WalletDetailsCubit.mockMode seam: injectMockCoins/clearMock added, getCoins() early-returns when mockMode is true (blocking the live read and selectNetwork/selectWallet re-fetches); CoinsScreen._fetchMarketData short-circuits to DevMockHoldings.marketData while mock-mode is ON, leaving the OFF path untouched"
    requirement: "QUICK-260720-cw8"
    verification:
      - kind: other
        ref: "flutter analyze lib/wallets/cubit/wallet_details_cubit.dart lib/components/coins/view/coins_screen.dart"
        status: pass
    human_judgment: true
    rationale: "Whether the mock survives the 1-min refresh timer and a real wallet/network switch, and whether the OFF path is truly byte-identical, can only be confirmed by exercising a running debug build -- covered by Task 4's blocking human-verify checkpoint, not yet performed."
  - id: D3
    description: "Four scenario buttons (Populated / Long-extreme / Missing-icon / Clear) added to the dev-tools bubble's expanded panel, wired to DevMockHoldings loaders + WalletDetailsCubit.injectMockCoins/clearMock, reusing existing gw.textPrimary token"
    requirement: "QUICK-260720-cw8"
    verification:
      - kind: other
        ref: "flutter analyze lib/dev/dev_tools_bubble.dart"
        status: pass
    human_judgment: true
    rationale: "Visual placement/reachability inside the viewport-clamped panel and the actual on-screen scenario behavior require a human walk in a running debug build -- Task 4's blocking human-verify checkpoint."

duration: ~20min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-cw8: Add a dev-only mock-holdings injector Summary

**Dev-only `DevMockHoldings` fixture singleton feeds offline seeded coins + market data through a new `WalletDetailsCubit.mockMode` seam and a `CoinsScreen._fetchMarketData` short-circuit, exposed via four new buttons (Populated / Long-extreme / Missing-icon / Clear) in the existing dev-tools bubble.**

## Performance

- **Duration:** ~20 min
- **Tasks:** 3 of 4 (all auto tasks complete; Task 4 is a blocking human-verify checkpoint, not performed by this run per its explicit instructions)
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments

- Created `lib/dev/dev_mock_holdings.dart`: a private-ctor singleton (`DevMockHoldings.instance`) holding `mockMode`, `coins`, `marketData` (keyed by lowercase symbol), and a `totalBalance` getter. Four scenario methods (`loadPopulated`, `loadExtreme`, `loadMissingIcon`, `clear`) populate/reset that state per the plan's fixture spec, with a private `_fixture()` helper building a full `CoinGeckoMarketData` from just symbol/price/change plus harmless defaults for every other required field. Imports only `Coin` and `CoinGeckoMarketData` — no cubit or widget imports.
- Added a `mockMode` field, `injectMockCoins()`, and `clearMock()` to `WalletDetailsCubit`; guarded the top of `getCoins()` with `if (mockMode) return;` so the live read (and the `selectNetwork`/`selectWallet` re-fetches that call it) cannot overwrite injected mock holdings.
- Added a `kDebugMode`-gated short-circuit at the top of `CoinsScreen._fetchMarketData`: while `context.read<WalletDetailsCubit>().mockMode` is true, it sets `_marketData` from `DevMockHoldings.instance.marketData` and returns immediately — no network call, no `_calculateTotalValue` (the balance is already set by `injectMockCoins`). This neutralizes both the 1-min refresh `Timer.periodic` and the `BlocListener`'s `successful`-branch fetch while mock-mode is ON. The OFF path (loading surface, `GWEmptyState`, live fetch, `_calculateTotalValue`, token-info push marketData) is untouched.
- Added a second `Wrap` of four `TextButton`s to `DevToolsBubble`'s expanded panel: Populated / Long-extreme / Missing-icon each call the matching `DevMockHoldings` loader then `WalletDetailsCubit.injectMockCoins(...)`; Clear calls `DevMockHoldings.instance.clear()` then `WalletDetailsCubit.clearMock()`. Reuses the existing `gw.textPrimary` token — no new color literals. `WalletDetailsCubit` is confirmed in scope: `main.dart` provides it above `MaterialApp.router` (line ~305 vs ~325), and `DevToolsBubble` mounts inside the router's screens as a descendant.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Dev fixture singleton (offline seeded holdings + market data)** - `fa7f906` (feat)
2. **Task 2: Mock-mode seam on cubit + offline market-data short-circuit in CoinsScreen** - `3956ee4` (feat)
3. **Task 3: Four scenario buttons in the dev-tools bubble** - `35e40d2` (feat)

Task 4 is a `checkpoint:human-verify` gate (`gate="blocking"`) — not a commit-producing task. Per this run's instructions, the walk was intentionally NOT performed by the executor.

## Files Created/Modified

- `lib/dev/dev_mock_holdings.dart` - New dev-only fixture singleton: 4 scenario loaders + a shared `CoinGeckoMarketData` builder helper.
- `lib/wallets/cubit/wallet_details_cubit.dart` - `mockMode` field, `injectMockCoins`/`clearMock` methods, `getCoins()` mock-mode early return.
- `lib/components/coins/view/coins_screen.dart` - `_fetchMarketData` offline short-circuit while mock-mode is ON; new `DevMockHoldings` + `kDebugMode` imports.
- `lib/dev/dev_tools_bubble.dart` - Second `Wrap` with the four scenario buttons; new `DevMockHoldings`, `WalletDetailsCubit`, `flutter_bloc` imports.

## Decisions Made

- Used `// DEV-ONLY:` comments instead of the plan's literal `ponytail:` marker — flagged as a typo in this run's explicit instructions; same intent (dev-only fixture, tree-shakes away under `kDebugMode`, never for production) preserved.
- Verified every referenced crypto icon asset (`eth.png`, `btc.png`, `usdc.png`, `gnus.png`, `agi.png`, `sol.png`) actually exists under `assets/images/crypto/` before writing the fixture tables — no broken asset reference added. `NOICON`'s empty `iconPath` is intentional (exercises `buildTokenIcon`'s `image_not_supported` fallback, not a missing asset).
- Read `CoinGeckoMarketData`'s real unnamed constructor first (25 required fields) rather than guessing; the `_fixture()` helper supplies harmless defaults (`0` numerics, `DateTime.fromMillisecondsSinceEpoch(0)` for date fields, `null` for nullable fields) for everything the scenario tables don't specify.

## Deviations from Plan

None — plan executed exactly as written for Tasks 1-3 (the `ponytail:`→`DEV-ONLY:` comment-text substitution was an explicit environment instruction for this run, not a discretionary deviation).

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Outstanding

**Task 4 (`checkpoint:human-verify`, `gate="blocking"`) has NOT been performed.** Exact recipe (from `260720-cw8-PLAN.md`), to run on the ALREADY-RUNNING `GW_DEV_TOOLS=true` debug build (do NOT start a new build; hot-restart is fine), on a non-SGNUS wallet dashboard:

1. Open the dev bubble, tap "Populated" — confirm the holdings list shows ETH/BTC/USDC/GNUS with real USD values, at least one GREEN 24h change and at least one RED 24h change, and the hero "Current Balance" shows a non-zero total (~$8,278). Confirm no network flicker (offline).
2. Wait past ~1 min (or trigger a wallet/network switch) — confirm the mock list does NOT get wiped or overwritten.
3. Tap "Long / extreme" — confirm the long balance / tiny-decimal price row does not overflow (AutoSizeText shrinks; no yellow-black overflow stripes).
4. Tap "Missing icon" — confirm the NOICON row shows the grey `image_not_supported` fallback avatar.
5. Tap "Clear" — confirm it returns to the real empty state ("No coins yet" empty state + hero "No funds available"), and that live data behaves normally afterward.

Resume signal: "approved" or a description of issues found.

## Next Phase Readiness

- Code changes are analyze-clean and committed (`fa7f906`, `3956ee4`, `35e40d2`); no blockers for continuing other work.
- The Task 4 walk should be run before/alongside the phase-05 holdings-list (05-03) walk, since it's this quick task's whole reason for existing — unblocking a populated dashboard for that walk.

---
*Quick task: 260720-cw8-add-a-dev-only-mock-holdings-injector-so*
*Completed: 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/dev/dev_mock_holdings.dart
- FOUND: lib/wallets/cubit/wallet_details_cubit.dart
- FOUND: lib/components/coins/view/coins_screen.dart
- FOUND: lib/dev/dev_tools_bubble.dart
- FOUND: .planning/quick/260720-cw8-add-a-dev-only-mock-holdings-injector-so/260720-cw8-SUMMARY.md
- FOUND: fa7f906
- FOUND: 3956ee4
- FOUND: 35e40d2
