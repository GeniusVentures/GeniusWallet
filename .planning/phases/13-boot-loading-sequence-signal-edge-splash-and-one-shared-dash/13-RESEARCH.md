# Phase 13: Boot & Loading Sequence — Research

**Researched:** 2026-07-22
**Domain:** Flutter boot-screen composition, implicit animation sequencing, async-gate widening, FFI single-flight guarding — all within the existing GeniusWallet codebase (no new packages)
**Confidence:** HIGH (every recommendation is grounded in a specific file:line already in this repo; no external library research was needed)

<user_constraints>
## User Constraints (from 13-CONTEXT.md)

### Locked Decisions (measured constraints — non-negotiable)

- **M1** — Main isolate frozen ~9.6s during `GeniusSDKInitWithMnemonic`. Nothing can animate before freeze lifts.
- **M2** — `Isolate.spawn` does NOT free the main isolate (spike 001 INVALIDATED). Do not re-attempt.
- **M3** — SDK stalls at 52.5% forever. Dashboard must NEVER gate on `getInitializationStatus()`.
- **M4** — Dashboard data (wallets/transactions/balances) ready at 141ms.
- **M5** — Network leg can fail entirely (DNS down); anything folded into the gate needs timeout + cached fallback.

### Locked Decisions (design — sketch 015, winner C · Signal Edge)

- **D1** — Composition: `GWMeshBackground` + centred logo (`logo_and_title.png`) + bottom-left `STATUS` kicker/status text + full-bleed bottom-edge gradient hairline.
- **D2** — Status text solid grey `#8A8F9D` (`textSecondary`), NOT gradient.
- **D3** — Rail is gradient cyan→mint (`brandPrimary`→`brandSecondary`), full-bleed, bottom edge, ~2px.
- **D4** — Rail is a closing flourish, not a progress bar. Holds at 0 through the frozen window. NEVER wired to SDK percentage.
- **D5** — Sequence: `Preparing your wallet…` (0%) → freeze-lift: `Wallets ready` (start) → +450ms: `Balances ready` (~33%) → +900ms: `Markets ready` (~67%) → +1500ms: dashboard (100%).
- **D6** — Closing statuses are confirmations ("ready"), not progress claims ("loading").
- **D7** — ~1.5s is a MINIMUM HOLD, not a fixed delay — stretches for slow markets/chart, ends on cache if they fail.
- **D8** — Boot screen is mode-invariant (pins dark token set in both app themes).
- **D9** — Copy is English.

### Engineering (locked)

- **E1** — Single-flight guard on `initSDK` (currently double-dispatched, throws caught `LateInitializationError`).
- **E2** — Per-section loaders removed: `coins_screen.dart:209` (`Loading()`), `crypto_live_chart.dart:523` (`PulsingSkeleton`).

### Claude's Discretion

- How the closing-run sequencer is structured (widget-local state vs a small controller).
- Where the minimum-hold timing lives.
- The exact timeout value on the markets/chart leg (must exist; value is a judgement call).
- Whether the gate state is expressed in `AppBloc` or locally in the splash.

### Deferred / Out of Scope

- Any attempt to unblock the native freeze from Dart (M2 — settled).
- Native changes to GeniusSDK/SuperGenius (escalation, tracked separately).
- Onboarding screens (Phase 6), Transactions (Phase 12), Polish copy/i18n (D9).

### Hazards

- **H1/H2** — `Splash`/`Loading` are shadow-named classes. The ROUTED splash is `lib/screens/splash.dart` (`router.dart:76`). Do not repoint to `lib/components/splash.dart` (a dead `StatefulWidget` shadow) or to `lib/components/loading/loading.dart`.
- **H3** — `GWMeshBackground`'s 36s drift controller freezes too (imperceptible while frozen) but jumps ~27% of cycle on resume — unverified, walk item, not a coding task.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-------------------|
| SC1 | Boot screen never reads as hung — nothing promises motion it can't deliver during the frozen window | Architecture Patterns §1 (composition), §2 (sequencer never animates before freeze-lift signal) |
| SC2 | Dashboard appears complete — no section renders its own loader on entry | Architecture Patterns §3 (gate widening + cache pre-warm); Common Pitfall 6 (double-fetch/timeout must reach inner call sites too) |
| SC3 | App opens even with network down (cached data, timeout honoured) | Architecture Patterns §4 (timeout + cache, exact line-level fix in `coin_gecko_api.dart`) |
| SC4 | Zero overflow/exceptions/`LateInitializationError` across a cold start | Architecture Patterns §5 (single-flight `initSDK` guard), Code Examples |
| SC5 | Contrast verified live in both themes, incl. `STATUS` kicker over the mesh | Common Pitfall 1 (mode-invariant token trap) — flags the exact tokens safe vs unsafe for a pinned-dark screen |
| E1 | Single-flight guard on `initSDK` | Architecture Patterns §5, Code Examples |
| E2 | Remove per-section loaders (coins, chart) | Architecture Patterns §3, Common Pitfall 6 |
</phase_requirements>

## Summary

Every piece this phase needs already exists in the codebase — Flutter's own `Timer`/`Future`/implicit-animation primitives, the existing Hive-backed CoinGecko cache, and a `GWMeshBackground` that already accepts a `baseColor` override. No new package is needed anywhere in this phase.

The single most load-bearing finding is that **most of `GeniusWalletColors`' surface/text/border members are mode-*aware getters***, not mode-invariant constants — including `GeniusWalletColors.surfaceBase`, which is also the *default* `baseColor` `GWMeshBackground` paints itself with. A splash screen built with the naive assumption "the Scaffold's `backgroundColor` pins the canvas dark" will silently flip to light-grey in light mode the moment `GWMeshBackground` is dropped in, because the mesh paints its own full-bleed background on top of the Scaffold and defaults to the same flipping getter. This single override (`baseColor: <pinned-dark literal>`) is the entire mechanism D8 needs — no new theming layer, no new token file.

The second load-bearing finding is that the "widen the dashboard gate" instruction is best implemented as two cooperating layers, not one: the **splash's own sequencer** should be the actual readiness computation (it already needs live status text and a timed rail, so it is naturally the place that awaits wallet+account+markets+chart), and **`dashboard_screen.dart`'s existing gate** should only widen defensively (add the coins/holdings leg) so the screen never shows a bare `LoadingScreen()` seam between splash's handover and full content — it should not re-implement the same async orchestration a second time.

The third load-bearing finding is that `initSDK()`'s existing top-of-function `if (_isSdkInitialized) return;` guard is not the actual race — `_isSdkInitialized` is set only at the very end of `_initSDK`, and `AppBloc.sdkStatus` never leaves `AppStatus.initial` until `_onInitializeSDK` fully completes, so *any* re-evaluation of the router's `redirect` during the ~9.6s frozen window re-dispatches `InitializeSDK()`. The fix is a one-field Future memoization on `GeniusApi.initSDK()` itself — Dart's `Future` already supports being awaited by multiple callers, so no `Completer`, lock package, or new state field beyond a nullable `Future<void>?` is needed.

**Primary recommendation:** Re-skin `lib/screens/splash.dart` in place (Scaffold → `GWMeshBackground(baseColor: <pinned literal>)` → Stack, no `AppScreenView`), drive the closing-run sequencer with a small `Future`-chained state machine + `AnimatedContainer`/`TweenAnimationBuilder` for the rail (not an `AnimationController`), add `.timeout()` to the three `http.get()` calls in `lib/services/coin_gecko/coin_gecko_api.dart` (their existing catch-all blocks already fall back to cache correctly), memoize `GeniusApi.initSDK()`'s Future, and let the splash's own combined readiness gate the navigation to `/dashboard` so the dashboard's existing gate only needs a defensive coins-leg addition.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Boot screen composition (mesh, logo, status, rail) | Browser/Client (Flutter widget tree) | — | Pure UI, no data dependency until the closing run |
| Closing-run sequencer (timing, minimum-hold) | Browser/Client (`splash.dart` local state) | — | Discretion item; widget-local `State` is the natural owner since it drives visible text/rail and nothing else needs it |
| SDK init readiness (wallets/account) | API/Backend boundary (`AppBloc` via `GeniusApi`) | Browser/Client (splash listens) | Already modeled as bloc state (`subscribeToWalletStatus`, `accountStatus`); splash is a consumer, not a new owner |
| Markets/chart readiness | API/Backend boundary (`coin_gecko_api.dart` + Hive cache) | Browser/Client (splash prefetches, dashboard re-reads warm cache) | The CoinGecko fetch functions already own caching + fail-soft; splash and dashboard are both callers, not separate implementations |
| Dashboard gate | Browser/Client (`dashboard_screen.dart:70`) | — | Existing `BlocBuilder<AppBloc, AppState>` branch; widen in place, don't introduce a parallel gate |
| `initSDK` single-flight | API/Backend boundary (`genius_api.dart`) | — | The race is entirely inside `GeniusApi`; fixing it in `AppBloc` or `router.dart` would treat a symptom (double dispatch) instead of the cause (no memoization at the call target) |

## Standard Stack

### Core

No new dependencies. Everything is Flutter SDK / Dart core:

| API | Purpose | Why standard here |
|-----|---------|--------------------|
| `Timer` / `Future.delayed` / `Future.wait` | Closing-run sequencer, minimum-hold | Already the pattern used by `CoinsScreen._refreshTimer` and `CryptoLiveChartState._timer` in this same codebase |
| `AnimatedContainer` / `TweenAnimationBuilder<double>` | Rail sweep animation | Implicit animation widgets are the idiomatic Flutter choice for "animate to a new target value on a discrete state change" — no manual `vsync`/`Ticker`/dispose plumbing needed |
| `Future<T>.timeout(Duration)` | Bound the markets/chart network leg | Core `dart:async` API; throws `TimeoutException`, which the existing broad `catch (e)` blocks in `coin_gecko_api.dart` already handle |
| Future-object memoization (`Future<void>? _f; ... _f ??= _run();`) | `initSDK` single-flight guard | Dart `Future`s natively support multiple listeners/awaits — no `Completer`, no `package:synchronized`, no mutex needed |

### Supporting (already in the app, reused as-is)

| Component | File | Reused for |
|-----------|------|------------|
| `GWMeshBackground` | `lib/components/effects/gw_mesh_background.dart` | Boot background — already accepts `baseColor` override (see Common Pitfall 1) |
| `fetchAllCoinGeckoCoins` / `fetchCoinsMarketData` / `fetchHistoricalPrices` | `lib/services/coin_gecko/coin_gecko_api.dart` | Markets/chart data + existing 3-minute Hive cache (`cacheDuration`) |
| `getDashboardMarketCoins()` | `lib/dashboard/chart/dashboard_markets_util.dart` | The exact markets fetch the dashboard's Markets panel already calls |
| `GeniusWalletColors.textSecondary` / `.brandPrimary` / `.brandSecondary` | `lib/theme/genius_wallet_colors.dart` | D2/D3's status text + rail gradient — all three are plain `static const`, genuinely mode-invariant (see Common Pitfall 1) |

### Alternatives Considered

| Instead of | Could use | Tradeoff |
|------------|-----------|----------|
| `Future`-chain state machine for the sequencer | `AnimationController` + `Interval`s | Rejected: 3 discrete confirmation steps at fixed offsets is not a continuous curve; `AnimationController` adds `vsync`/dispose bookkeeping for no benefit over `TweenAnimationBuilder` reacting to a `setState`-driven target |
| Timeout inside the 3 shared fetch functions | Timeout wrapper duplicated at each call site (splash, `coins_screen.dart`, `crypto_live_chart.dart`, `dashboard_markets_util.dart`) | Rejected: one shared fix in `coin_gecko_api.dart` automatically protects every existing and new caller; duplicating it per call site is exactly the kind of boilerplate CLAUDE.md rules against |
| `GeniusApi.initSDK()` Future memoization | A `Completer`-based lock, or a `bool _initInFlight` flag with manual queuing | Rejected: Dart's plain `Future` object is already awaitable by multiple callers; a flag needs extra logic to make late callers wait, a cached `Future` gives that for free |

**Installation:** none — no `pubspec.yaml` changes required for this phase.

## Package Legitimacy Audit

**Not applicable.** This phase adds zero new dependencies — every recommendation above uses `dart:async`, `dart:io` (`http` — already a dependency), Flutter's `material.dart` implicit-animation widgets, and existing project files. Nothing to check against the registry.

## Architecture Patterns

### System Architecture Diagram

```
Cold start
   │
   ▼
router.dart redirect() ──dispatches──▶ AppBloc: InitializeSDK, LoadWallets,
   │                                    StartSGNUSTransactionsStream, FetchAccount
   │ (redirect may re-fire while sdkStatus stays `initial` for ~9.6s
   │  — this is the InitializeSDK double-dispatch, fixed at the GeniusApi
   │  layer, not here)
   ▼
Splash (lib/screens/splash.dart)
   │  Frozen window (~9.6s): GWMeshBackground paints (imperceptibly static),
   │  logo shown, STATUS = "Preparing your wallet…", rail at 0%.
   │  NOTHING ticks here — freeze-lift is the only possible trigger.
   ▼
freeze lifts ──▶ BlocListener sees subscribeToWalletStatus + accountStatus
   │              AND kicks off (in parallel):
   │                - getDashboardMarketCoins()   [warms Hive cache]
   │                - fetchHistoricalPrices('bitcoin') [warms Hive cache]
   │              both wrapped in Future<T>.timeout(...)
   ▼
Closing-run sequencer (local State, Future-chained):
   "Wallets ready"  (rail → ~33%, delay ~450ms)
   "Balances ready" (rail → ~67%, delay ~450ms)
   "Markets ready"  (rail → 100%, gated on Future.wait([marketsF, chartF])
                      racing a 1500ms minimum-hold — whichever is LATER)
   ▼
context.go('/dashboard') — only once wallet+account+markets/chart are
   settled (resolved OR timed out to cache)
   ▼
DashboardScreen gate (dashboard_screen.dart:70)
   │  subscribeToWalletStatus==loaded && accountStatus==loaded
   │  (+ defensive: coinsStatus != loading — see Pitfall 6)
   ▼
ResponsiveDashboardView / OneColumnDashBoardView
   │  MarketsDashboardView, ChartDashboardView, ContributionsDashboardView
   │  all call the SAME fetch functions splash already warmed —
   │  cache hits, no visible loader (E2: their loader widgets removed)
```

### Recommended file-level changes (no new files)

```
lib/screens/splash.dart                          — re-skinned, sequencer added
lib/services/coin_gecko/coin_gecko_api.dart       — .timeout() on 3 http.get() calls
packages/genius_api/lib/src/genius_api.dart       — initSDK() Future memoization
lib/dashboard/home/view/dashboard_screen.dart     — gate widened defensively (coins leg)
lib/components/coins/view/coins_screen.dart       — loading branch (line ~209) simplified
lib/chart/crypto_live_chart.dart                  — PulsingSkeleton branch (line ~523) + "Loading..." text (line ~310) simplified
```

### Pattern 1: Boot screen composition — mirror `WalletCreationScreen`, not `AppScreenView`

**What:** `lib/onboarding/view/wallet_creation_screen.dart:14-17` composes a full-bleed hero screen as `Scaffold(body: GWMeshBackground(child: Center(...)))` — no `AppScreenView`. `AppScreenView` (`lib/components/app_screen_view.dart`) wraps its body in a `CustomScrollView` + `SliverFillRemaining` footer — built for a scrollable form screen with a pinned footer button, not for a screen needing two absolutely-positioned overlays (bottom-left status block, full-bleed bottom-edge rail).

**When to use:** Any full-bleed hero/boot screen that needs a `Stack` of independently-positioned overlays rather than a scroll body + footer.

**Example:**
```dart
// Adapted from lib/onboarding/view/wallet_creation_screen.dart:14-17
class Splash extends StatefulWidget {
  const Splash({super.key});
  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // ... sequencer state (Pattern 2) ...

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listener: (context, state) => _onAppState(context, state), // starts sequencer once wallet+account ready
      child: Scaffold(
        body: GWMeshBackground(
          // MUST override — see Common Pitfall 1. GWMeshBackground's own
          // default baseColor reads the mode-flipping GeniusWalletColors
          // .surfaceBase getter, which would defeat D8 in light mode.
          baseColor: _kBootSurfaceDark,
          child: Stack(
            children: [
              const Center(
                child: Image(
                  image: AssetImage(
                    'assets/images/logo_and_title.png',
                    package: 'genius_wallet',
                  ),
                ),
              ),
              Positioned(
                left: GeniusWalletConsts.space8,
                bottom: GeniusWalletConsts.space16,
                child: _StatusBlock(text: _statusText), // D2: solid textSecondary
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _ClosingRail(fraction: _railFraction), // D3/D4
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// D8: a literal, NOT GeniusWalletColors.surfaceBase (that getter flips with
// GWAppearance — see Common Pitfall 1). Local to this file: single consumer,
// no shared token needed (CLAUDE.md: no abstraction not requested).
const Color _kBootSurfaceDark = Color(0xFF0B0D12);
```

### Pattern 2: Closing-run sequencer — `Future`-chain + implicit animation, not `AnimationController`

**What:** D5's timeline is three discrete confirmation steps at fixed offsets (0, +450ms, +900ms) plus a variable-length final wait (D7). This is not a continuous curve — it's a small state machine. `AnimationController` + `Interval` is built for scrubbing a single continuous timeline (useful when you need `.reverse()`, manual seeking, or gesture-driven scrubbing); none of that applies here.

**When to use:** Any boot/splash sequence with named discrete stages, one of which must race a real async operation against a minimum-hold duration.

**Example:**
```dart
enum _BootStage { preparing, walletsReady, balancesReady, marketsReady }

class _SplashState extends State<Splash> {
  _BootStage _stage = _BootStage.preparing;
  double _railFraction = 0.0;
  bool _sequenceStarted = false;

  void _onAppState(BuildContext context, AppState state) {
    if (_sequenceStarted) return;
    if (state.subscribeToWalletStatus == AppStatus.loaded &&
        state.accountStatus == AppStatus.loaded) {
      _sequenceStarted = true;
      _runClosingSequence(context);
    }
  }

  Future<void> _runClosingSequence(BuildContext context) async {
    // Kick off the real async work NOW — in parallel with the timed steps,
    // not after them (D7: the 1.5s hold must COVER this work, not precede it).
    final marketsAndChart = Future.wait([
      getDashboardMarketCoins(),
      fetchHistoricalPrices('bitcoin'),
    ]);

    setState(() { _stage = _BootStage.walletsReady; _railFraction = 0.0; });
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() { _stage = _BootStage.balancesReady; _railFraction = 1 / 3; });
    await Future.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;

    setState(() { _stage = _BootStage.marketsReady; _railFraction = 2 / 3; });

    // D7: minimum hold vs real work — whichever finishes LAST wins. The
    // 600ms remainder (1500 - 450 - 450) is the floor; markets/chart may
    // push it later. Each future already has its own .timeout() + cache
    // fallback (Pattern 4), so this Future.wait cannot hang indefinitely.
    await Future.wait([
      Future.delayed(const Duration(milliseconds: 600)),
      marketsAndChart,
    ]);
    if (!mounted) return;

    setState(() => _railFraction = 1.0);
    if (context.mounted) context.go('/dashboard');
  }
}

class _ClosingRail extends StatelessWidget {
  const _ClosingRail({required this.fraction});
  final double fraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction),
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
          builder: (context, value, _) => Align(
            alignment: Alignment.centerLeft,
            child: Container(
              height: 2,
              width: constraints.maxWidth * value,
              decoration: const BoxDecoration(
                // D3: cyan(brandPrimary) → mint(brandSecondary). Neither
                // GeniusWalletGradient.brandCta (green→blue) nor .brandBorder
                // (brandPrimary→brandSecondaryBright) is this exact pair —
                // inline literal, single consumer (no new shared token).
                gradient: LinearGradient(
                  colors: [
                    GeniusWalletColors.brandPrimary,
                    GeniusWalletColors.brandSecondary,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
```

**Runnable check (CLAUDE.md: non-trivial logic leaves ONE runnable check):** The one piece of real branching here is "does the sequence wait for the LONGER of the minimum hold and the real fetch, and does it still terminate if the fetch never settles." Extract the stage-timing/race logic into a plain-Dart (no `flutter` import) class so it can be exercised without the broken `flutter test` harness (`.planning/ROADMAP.md` § "Verification reality": `flutter test` does not compile in this repo). Example shape:

```dart
// tool/boot_sequence_check.dart — run via `dart run tool/boot_sequence_check.dart`
// No flutter import, no test framework — an assert-based self-check per
// CLAUDE.md ("no frameworks, no fixtures").
Future<void> main() async {
  // Case 1: fetch resolves before the minimum hold — hold wins.
  final sw1 = Stopwatch()..start();
  await Future.wait([
    Future.delayed(const Duration(milliseconds: 200)),
    Future.delayed(const Duration(milliseconds: 20)),
  ]);
  assert(sw1.elapsedMilliseconds >= 200, 'minimum hold must not be skipped');

  // Case 2: fetch outlasts the minimum hold — fetch wins (bounded by its
  // own .timeout(), so this must still terminate).
  final sw2 = Stopwatch()..start();
  await Future.wait([
    Future.delayed(const Duration(milliseconds: 20)),
    Future.delayed(const Duration(milliseconds: 200)).timeout(
      const Duration(milliseconds: 500),
    ),
  ]);
  assert(sw2.elapsedMilliseconds >= 200, 'must wait for the slower leg');
  assert(sw2.elapsedMilliseconds < 500, 'must not wait past the timeout');

  print('boot_sequence_check: PASS');
}
```
This exercises exactly the "hold vs. real work, bounded by timeout" branch — the one piece of logic in this phase that isn't pure layout — without needing `flutter test`.

### Pattern 3: Widening the dashboard gate — splash does the waiting, dashboard adds a defensive backstop

**What:** `dashboard_screen.dart:70`'s existing condition (`subscribeToWalletStatus == loaded && accountStatus == loaded`) is the ONLY thing standing between the frozen boot and a fully-assembled dashboard today. Per M4 this resolves in ~141ms — far before the splash's closing run finishes navigating. Two options exist for "widening" it:

1. **Do all the waiting in splash** (recommended) — the closing-run sequencer (Pattern 2) already needs to know when markets/chart are ready to show "Markets ready" and advance the rail; it is the natural single owner of that readiness computation. By the time `context.go('/dashboard')` fires, wallets/account/markets/chart have all resolved (or timed out to cache). `dashboard_screen.dart`'s gate then only needs ONE defensive addition: the coins/holdings leg (`WalletDetailsCubit.state.coinsStatus`), which has no dedicated status line in D5's sequence (see Open Questions) but must not be allowed to show its own loader per E2.
2. **Re-derive full readiness in `dashboard_screen.dart` too** — duplicates the same `Future.wait` logic a second time. Rejected: two independent readiness computations can drift, and it re-introduces exactly the "second implementation of the same gate" boilerplate CLAUDE.md rules against.

**Example (defensive widen only):**
```dart
// dashboard_screen.dart:65-98 — widen the existing BlocBuilder<AppBloc, AppState>
// with one more condition read from WalletDetailsCubit, not a new gate.
BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
  builder: (context, walletState) => BlocBuilder<AppBloc, AppState>(
    builder: (context, state) {
      final coinsSettled = walletState.coinsStatus != WalletStatus.loading;
      if (state.subscribeToWalletStatus == AppStatus.loaded &&
          state.accountStatus == AppStatus.loaded &&
          coinsSettled) {
        // ... existing ResponsiveDashboardView / OneColumnDashBoardView ...
      }
      // ... existing error branch unchanged ...
      return const LoadingScreen(); // now effectively unreachable in the
                                     // normal cold-start path, since splash
                                     // already waited — kept as a genuine
                                     // defensive fallback, not deleted
    },
  ),
)
```

### Pattern 4: Timeout + cached fallback — fix belongs in the shared fetch functions, not per call site

**What:** `lib/services/coin_gecko/coin_gecko_api.dart`'s three network functions already have the RIGHT fallback shape — a broad `catch (e)` that falls back to Hive cache (`fetchHistoricalPrices` line ~67-76, `fetchCoinsMarketData` line ~165-171, `fetchAllCoinGeckoCoins` line ~220-229). What they're missing is a bound on a *hanging* request (M5's captured DNS-down run failed FAST with a thrown exception — that is not the same as a socket that never responds). Chaining `.timeout(Duration(...))` onto each `http.get(...)` call throws a `TimeoutException`, which these existing broad `catch (e)` blocks already catch correctly — this is a 1-line change per call site, not new control flow.

**Example:**
```dart
// coin_gecko_api.dart:38 (inside fetchHistoricalPrices)
final response = await http
    .get(Uri.parse(historyApi))
    .timeout(const Duration(seconds: 3)); // was: await http.get(Uri.parse(historyApi));
// existing `catch (e) { ... return cacheEntry?.toIntMap() ?? {}; }` below
// already handles TimeoutException identically to a network failure.
```
Apply the same one-line change at `coin_gecko_api.dart:134` (`fetchCoinsMarketData`) and `:194` (`fetchAllCoinGeckoCoins`).

**Why this fixes both the splash prefetch AND the dashboard's own re-fetch:** splash's closing-run sequencer (Pattern 2) and `MarketsDashboardView`/`CryptoLiveChart` (which call the identical functions) all funnel through these same three functions. One timeout, applied once, bounds every caller's worst case — this is the "don't hand-roll a second readiness/timeout layer" answer to E2.

### Pattern 5: `initSDK` single-flight guard — Future memoization, not a new lock

**What:** `packages/genius_api/lib/src/genius_api.dart:181-195`'s `initSDK()` already has an `if (_isSdkInitialized) return;` guard, but `_isSdkInitialized` is set `true` only at the very end of `_initSDK` (line 266) — anything that calls `initSDK()` again while the first call is still in its ~9.6s freeze sees `_isSdkInitialized == false` and proceeds again, hitting `_basePath = await prepareConfigFiles()` a second time on a `late final` field already set by the first call → the observed `LateInitializationError`. Meanwhile `router.dart:54` gates the dispatch on `appBloc.state.sdkStatus == AppStatus.initial`, but `AppBloc._onInitializeSDK` (`app_bloc.dart:66-72`) never emits an intermediate `loading` state — `sdkStatus` stays `initial` for the entire frozen window, so any re-evaluation of the router's `redirect` re-dispatches `InitializeSDK()`.

**Example:**
```dart
// packages/genius_api/lib/src/genius_api.dart — replace the top-of-function
// guard in initSDK() with Future memoization. Dart Futures support multiple
// awaiters natively — no Completer, no lock package needed.
Future<void>? _initFuture;

Future<void> initSDK() {
  return _initFuture ??= _doInitSDK();
}

Future<void> _doInitSDK() async {
  requestPermissions();

  final storedKey = await _secureStorage.getSGNUSLinkedWalletPrivateKey();
  if (storedKey == null) {
    debugPrint("No suitable wallet found");
    return;
  }

  await _initSDK(storedKey);
}
```
This is safe to memoize permanently (not just "in-flight"): `initSDK()`'s only caller is `AppBloc._onInitializeSDK`, itself gated by `router.dart`'s `sdkStatus == AppStatus.initial` check, which becomes permanently false the moment `_onInitializeSDK` completes (regardless of outcome) — so `initSDK()` is architecturally a run-at-most-once-per-session operation already; the memoized `Future` simply makes that true even when two dispatches race. `_registerWallet` (onboarding's wallet-creation path) calls `_initSDK(storedKey)` directly, bypassing `initSDK()` entirely — it already has its own `_isSdkInitialized` idempotency check and is unaffected by this change.

### Pattern 6: Mode-invariant theming for one screen inside a mode-aware app

See Common Pitfall 1 — the mechanism is `GWMeshBackground(baseColor: <literal>)`, not a new theming layer.

### Anti-Patterns to Avoid

- **Gating anything on `getInitializationStatus()`** — M3: stalls at 52.5% forever (retracted finding #4 in sketch 015 — an earlier draft said the opposite and was wrong).
- **Wiring the rail to a percentage from the SDK** — D4: it would sit half-full forever; the rail is a closing flourish computed from the SEQUENCER's own timeline, never from `GeniusInitStatus.percentage`.
- **Reusing `GeniusWalletColors.surfaceBase` / `.textPrimary*` / `.borderSubtle`/`.borderStrong` getters on the boot screen** — see Common Pitfall 1.
- **Trying to move `GeniusSDKInitWithMnemonic` to another isolate** — M2, spike 001 INVALIDATED, explicitly out of scope.
- **Adding a new AppBloc state field / event solely to re-derive markets/chart readiness** — Pattern 3 explains why this duplicates work the splash sequencer already does.

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| In-flight-call de-duplication for `initSDK` | A `Completer`/mutex/lock package | Cache the `Future` object itself (`_f ??= _run()`) | Dart `Future`s are natively multi-listener; a lock adds ceremony for something the language already does |
| Markets/chart readiness signal for the gate | A new Cubit/Bloc event + state field | The existing Hive-backed cache in `coin_gecko_api.dart` (already 3-minute TTL) | Splash pre-warms it, dashboard re-reads it — same function, same cache, zero new state plumbing |
| Rail sweep animation | Manual `AnimationController` + `Ticker` + dispose bookkeeping | `TweenAnimationBuilder<double>` / `AnimatedContainer` | Implicit animation widgets exist exactly for "animate to a new target on a state change"; no manual `vsync` needed here |
| Network hang protection | A custom retry/circuit-breaker class | `Future<T>.timeout(Duration)` chained onto the existing `http.get()` calls | The existing `catch (e)` fallback-to-cache logic already does the right thing once a `TimeoutException` is thrown into it |
| A distinct "always-dark" gradient/color token set for one screen | A new `ThemeExtension` or a `GWColorsDark` class | The already-mode-invariant `static const` fields on `GeniusWalletColors` (`brandPrimary`, `brandSecondary`, `textSecondary`) + one new literal for the background | Three of the four colors this screen needs are already mode-invariant; only the background needs a new literal |

**Key insight:** every "gate," "cache," and "timeout" this phase needs is a thin wrapper around infrastructure that already exists in this codebase (Hive cache in `coin_gecko_api.dart`, bloc state in `AppBloc`, Dart's own `Future`). The phase is genuinely a re-skin + a small sequencer + three surgical fixes, not a new subsystem.

## Common Pitfalls

### Pitfall 1: `GeniusWalletColors` mode-aware GETTERS silently defeat D8's "pin dark" requirement

**What goes wrong:** A large fraction of `GeniusWalletColors`' members are `static Color get X => _isLight ? lightValue : darkValue;` — including `surfaceBase`, `surfaceElevated`, `surfaceMenu`, `surfaceSunken`, `textPrimary` and its alpha ladder (`textPrimary80`...`textPrimary10`), `borderSubtle`, `borderStrong`. These flip with `GWAppearance.isLight` at read time. If splash.dart's re-skin uses any of these (e.g. `GeniusWalletColors.surfaceBase` for the background, `.textPrimary38` for a subdued label), the boot screen will silently render light-grey/dark-ink when the user is in light mode — exactly the bug D8 exists to prevent, and it will not show up in a dark-mode-only smoke check.

**Why it happens:** The getters exist so that MOST of the app can re-skin live on an appearance toggle (that's their whole purpose — see `gw_appearance.dart` and `04-02-PLAN.md`'s `GWColors` `ThemeExtension` migration). The boot screen is the one deliberate exception (D8), so it must avoid the exact mechanism the rest of the app relies on.

**Compounding trap:** `GWMeshBackground` (`lib/components/effects/gw_mesh_background.dart:35,63`) paints its own full-bleed `ColoredBox` and its `baseColor` parameter **defaults to `GeniusWalletColors.surfaceBase`** — the mode-flipping getter. Because the mesh's `ColoredBox` sits inside a `Stack(fit: StackFit.expand)` as the FIRST child, it visually covers the `Scaffold.backgroundColor` entirely. So even if `Scaffold(backgroundColor: <pinned dark literal>)` is set correctly, adding `GWMeshBackground` without overriding its own `baseColor` parameter will still flip the visible canvas.

**How to avoid:** Only use the following on the boot screen — all genuinely mode-invariant `static const` fields, verified by reading their declarations directly (not getters):
- `GeniusWalletColors.textSecondary` (`Color(0xFF8A8F9D)`, D2's status text — const, safe)
- `GeniusWalletColors.brandPrimary` / `.brandSecondary` (D3's rail gradient — both const, safe)
- A new literal `Color(0xFF0B0D12)` for the background, passed explicitly to `GWMeshBackground(baseColor: ...)` — mirrors how the CURRENT splash.dart already pins `GeniusWalletColors.deepBlue`, itself a plain const literal, not a getter
- Plain `Colors.white` / `Colors.white.withValues(alpha: 0.38)` for the logo and the `STATUS` kicker (D2's `rgba(255,255,255,.38)`) — literal, not `textPrimary38`

**Warning signs:** Any `GeniusWalletColors.<name>` reference in splash.dart where `<name>` is declared as `static Color get` rather than `static const Color` — grep `static.*get $NAME` in `genius_wallet_colors.dart` before using a token there.

### Pitfall 2: Gating on `getInitializationStatus()`

Already retracted once in sketch 015 (finding #4) — restated here because it is the single easiest mistake to reintroduce if a future edit "simplifies" the gate to read one native status number. M3 measured 161 polls stalling at 52.5% forever; this must never be a `dashboard_screen.dart` or splash condition.

### Pitfall 3: `.catch` without `.timeout` looks like it already handles network failure — it doesn't

The existing `try { await http.get(...) } catch (e) { ...fall back to cache... }` blocks in `coin_gecko_api.dart` correctly handle a thrown exception (DNS failure, connection refused). They do **not** bound a request that is accepted by the OS but never answered (packet black-holing, a slow/degraded link) — `http.get` has no default timeout. M5's captured "network down" run looked safe only because a DNS failure throws fast; a hung socket would block indefinitely with the code as it stands today. Pattern 4 above is the fix.

### Pitfall 4: `AppScreenView` is the wrong shape for this layout

`AppScreenView` (`lib/components/app_screen_view.dart`) is a `CustomScrollView` + pinned-footer `Sliver` — built for scrollable forms with a bottom CTA. The boot screen needs a `Stack` with two independently-positioned overlays (bottom-left status block, full-bleed bottom-edge rail) — `WalletCreationScreen`'s simpler `Scaffold(body: GWMeshBackground(child: ...))` composition (no `AppScreenView`) is the correct precedent, not the onboarding flow's `AppScreenView`-wrapped screens.

### Pitfall 5: Removing only `PulsingSkeleton`, leaving `crypto_live_chart.dart`'s "Loading..." text behind

`crypto_live_chart.dart:310` (`_hasData ? formattedPrice : 'Loading...'`) and the `PulsingSkeleton` at line ~523 are both driven by the same `_hasData` getter (`_priceData.isNotEmpty`, line 72). E2 names only the skeleton; a plan that removes the skeleton widget but leaves the "Loading..." text branch untouched will still show a textual loading cue on a dashboard that's supposed to "present complete" (SC2). Treat both as one removal, gated the same way.

### Pitfall 6: Removing per-section loaders without also reaching their fetch's worst-case latency

If the per-section loader widgets are deleted (E2) but the underlying fetch calls (`fetchAllCoinGeckoCoins`, `fetchCoinsMarketData`, `fetchHistoricalPrices`) can still hang indefinitely on a degraded (not down) network, the dashboard would show nothing at all indefinitely instead of a spinner — arguably worse. Pattern 4's shared `.timeout()` must land in the SAME commit as E2's loader removal, not as a follow-up.

## Code Examples

Already embedded inline under Architecture Patterns 1–5 above (this repo's own files are the source — no external docs needed for this phase).

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|---------------|--------|
| `Splash` = bare `Scaffold` + `Loading()` spinner (a real but un-ticked `AnimationController`) | `Splash` = `GWMeshBackground` + logo + `STATUS` text + gradient rail, spinner removed entirely | This phase | Spinner never lied about motion it couldn't deliver; new design never claims motion during the frozen window either — it just doesn't attempt any |
| Draft design gated dashboard on `getInitializationStatus()` percentage | Retracted (sketch 015 finding #4) — gate never reads SDK percentage | Same session, before this phase started | Would have hung the app forever per M3; already corrected upstream of this research |
| Per-section `FutureBuilder`/`Loading()`/`PulsingSkeleton` each fetch independently | Single upstream gate (splash sequencer + widened dashboard gate) pre-warms the same cache all sections read | This phase | Dashboard renders as one complete unit rather than assembling section-by-section |

**Deprecated/outdated:** none — this is a first-time implementation of the sketch 015 design, not a migration from a prior implementation of the SAME design.

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | 3-second timeout is an appropriate value for the markets/chart `.timeout()` calls | Pattern 4 | Too short: a merely-slow (not down) network gets treated as failed and dashboard shows stale cache unnecessarily. Too long: a genuinely hung socket still stalls the boot noticeably past D7's 1.5s target. CONTEXT explicitly marks the exact value as Claude's Discretion — flagged here as the one number in this research that is a judgement call, not a measurement |
| A2 | The coins/holdings leg (`WalletDetailsCubit.getCoins()`, via `readSuperGeniusTokenAssets`/`readTokenAssets`) resolves fast enough to fold into the gate without its own dedicated status line | Pattern 3, Open Questions | Spike 002 measured wallets/transactions/balances (0/140/141ms) but never measured this leg specifically — if it's slow, the dashboard gate would wait on it silently with no user-visible status, unlike the three named legs in D5 |
| A3 | `GWMeshBackground`'s existing 36s drift controller does not need any code change for the freeze/resume jump (H3) | Pattern 1, Hazards | If the ~27% single-frame jump on resume is visually jarring rather than masked by the simultaneous dashboard handover, a fix (e.g. resetting the controller's animation value across the freeze) would be a genuinely new code change this research does not currently recommend building pre-emptively (YAGNI — CONTEXT marks it "unverified, must be checked on the walk") |

**All three assumptions above are explicitly named in 13-CONTEXT.md as Claude's Discretion or an unverified walk item** — none of them contradict a locked decision; they are the specific judgement calls the plan needs to make explicit rather than silently pick.

## Open Questions

1. **What is the coins/holdings leg's actual boot-time latency?**
   - What we know: M4 measured wallets (0ms), transactions (140ms), balances (141ms) — all via `spike 002`'s trace. `WalletDetailsCubit.getCoins()` (holdings, feeding `ContributionsDashboardView`/`CoinsScreen`) was never in that trace.
   - What's unclear: whether it's comparably fast (native/RPC read, likely similar order of magnitude) or meaningfully slower.
   - Recommendation: the plan should include a quick instrumented timing check (a debug print bracketing `getCoins()`, same technique spike 001/002 already used) as an early task, before committing to whether the coins leg needs its own status line in the sequencer or can silently fold into the defensive dashboard-gate addition (Pattern 3).

2. **Exact timeout value for the markets/chart network leg.**
   - What we know: it must exist (M5, D7); DNS-down fails fast via exception, so the timeout specifically protects against a hang, not a fast failure.
   - What's unclear: the precise duration — CONTEXT explicitly leaves this as a judgement call.
   - Recommendation: start with 3 seconds (comfortably longer than a normal CoinGecko round-trip, comfortably shorter than a user perceiving the closing run as stuck); revisit on the walk if it either fires on a healthy connection or fails to protect against a real hang.

## Environment Availability

| Dependency | Required By | Available | Version | Fallback |
|------------|------------|-----------|---------|----------|
| CoinGecko API (`api.coingecko.com`) | Markets/chart leg readiness | Network-dependent (not a local tool) | — | Existing Hive cache (`coin_gecko_api.dart`'s `cacheDuration = 3 min`) + this phase's new `.timeout()` |
| Flutter/Dart SDK | Everything in this phase | ✓ | Dart `^3.10.0` per `pubspec.yaml` (records syntax already used elsewhere in the repo) | — |

**Missing dependencies with no fallback:** none.

**Missing dependencies with fallback:** CoinGecko network access — already has a fallback (cache); this phase adds the missing timeout bound so that fallback is actually reachable on a hang, not just on a fast failure.

## Validation Architecture

### Test Framework

| Property | Value |
|----------|-------|
| Framework | `flutter_test` is present in `pubspec.yaml` but **does not compile** project-wide (`.planning/ROADMAP.md` § "Verification reality"; APP-02 defers the fix) |
| Config file | none functional for this phase |
| Quick run command | none reliable — see runnable-check recommendation below |
| Full suite command | Debug build + manual walk (`flutter run -d macos --dart-define=GW_DEV_TOOLS=true`, per spike 001's own "How to Run") |

### Phase Requirements → Test Map

| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|---------------------|--------------|
| SC1 | Boot screen never animates before freeze-lift | manual-only (visual, timing) | debug-build walk | N/A |
| SC2 | Dashboard presents complete, no per-section loaders | manual-only (visual) | debug-build walk | N/A |
| SC3 | App opens with network down, cache honoured | manual-only + one pure-Dart check | `dart run tool/boot_sequence_check.dart` (Pattern 2) covers the hold-vs-timeout race in isolation; the end-to-end cache fallback still needs a walk with DNS disabled, mirroring spike 001's own repro | ❌ Wave 0 — new script |
| SC4 | No `LateInitializationError` / double `initSDK` dispatch | manual (console-watch on cold start) + reasoning-level check | grep the console log for a second `Base path directory:` line during a cold-start walk (the exact symptom spike 001 recorded) | N/A — observation, not a script |
| SC5 | Contrast verified live in both themes | manual-only (visual, WCAG spot-check) | debug-build walk, both appearances | N/A |

### Sampling Rate

- **Per task commit:** `dart run tool/boot_sequence_check.dart` (the one piece of real branching — race logic — is cheap to run standalone)
- **Per wave merge / phase gate:** full cold-start debug-build walk in both appearances, once with network live and once with it disabled (mirrors spike 001's own repro protocol)

### Wave 0 Gaps

- [ ] `tool/boot_sequence_check.dart` — new, covers the minimum-hold-vs-timeout race (Pattern 2's runnable check); no existing file covers this
- [ ] No framework install needed — deliberately plain Dart (`dart run`), sidestepping the broken `flutter test` harness entirely, per CLAUDE.md's "no frameworks, no fixtures" instruction

## Security Domain

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-------------------|
| V2 Authentication | no | This phase touches boot UI and network caching, not auth |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | no | No new user input surface in this phase |
| V6 Cryptography | no | `initSDK`'s mnemonic/key handling is unchanged by the single-flight fix — the memoization wraps the EXISTING `_initSDK(storedKey)` call, it does not touch decryption or key material |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---------|--------|-----------------------|
| Double-init race causing an unhandled `LateInitializationError` | Denial of Service (crash-adjacent; caught today, but wastes a `prepareConfigFiles()` cycle and duplicates FFI init work) | Pattern 5's Future memoization — eliminates the race at its root rather than adding a second catch |
| Unbounded network wait blocking app usability | Denial of Service (self-inflicted, no attacker needed — a degraded network is enough) | Pattern 4's `.timeout()` + existing cache fallback |

No new attack surface is introduced — this phase does not add a network endpoint, does not change what's sent to CoinGecko, and does not touch mnemonic/key decryption paths (`decryptMnemonic` stays exactly where `_initSDK` already calls it, only the *dispatch guard around* the containing function changes).

## Sources

### Primary (HIGH confidence — all from this repository, verified by direct file read this session)

- `lib/screens/splash.dart`, `lib/components/splash.dart` — current boot screen + shadow hazard
- `lib/components/loading.dart`, `lib/screens/loading_screen.dart` — current spinner + dashboard fallback
- `lib/dashboard/home/view/dashboard_screen.dart` — existing gate (line 70), `MarketsDashboardView`, `ContributionsDashboardView`
- `lib/navigation/router.dart` — redirect logic, `InitializeSDK` dispatch (line 54-56)
- `lib/bloc/app_bloc.dart` — `_onInitializeSDK` (no intermediate `loading` state emitted)
- `packages/genius_api/lib/src/genius_api.dart` — `initSDK`/`_initSDK`/`_isSdkInitialized` (lines 100-267)
- `lib/components/effects/gw_mesh_background.dart` — `baseColor` default trap
- `lib/onboarding/view/wallet_creation_screen.dart` — composition precedent
- `lib/components/app_screen_view.dart` — why it's the wrong wrapper here
- `lib/components/coins/view/coins_screen.dart`, `lib/chart/crypto_live_chart.dart` — per-section loaders to remove
- `lib/services/coin_gecko/coin_gecko_api.dart`, `lib/dashboard/chart/dashboard_markets_util.dart` — cache + timeout fix location
- `lib/theme/genius_wallet_colors.dart`, `lib/theme/gw_colors.dart`, `lib/theme/gw_appearance.dart` — mode-aware vs mode-invariant token audit
- `lib/theme/genius_wallet_gradient.dart` — confirms no existing cyan→mint token
- `lib/wallets/cubit/wallet_details_cubit.dart` — `coinsStatus` / `getCoins()`
- `.planning/phases/13-.../13-CONTEXT.md`, `.planning/ROADMAP.md`, `.planning/sketches/015-boot-loading-sequence/README.md`, `.planning/spikes/001-.../README.md`, `.planning/spikes/002-.../README.md` — locked decisions and measurements
- `.planning/phases/03-gw-component-library/03-SHADOW-NAMES.md` — shadow-name hazard detail

### Secondary / Tertiary

None used — this phase required no external library research; every recommendation is Flutter/Dart core API grounded in existing repo patterns.

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — zero new dependencies; every API cited is either `dart:async`/Flutter core or an existing file in this repo
- Architecture: HIGH — every pattern is grounded in a specific file:line already read this session, not inferred
- Pitfalls: HIGH — Pitfall 1 (mode-aware getters + `GWMeshBackground.baseColor` default) was verified by reading the actual getter/const declarations, not assumed from naming
- Timeout value / coins-leg latency: MEDIUM — explicitly logged in Assumptions, both already marked as judgement calls or unmeasured in CONTEXT.md

**Research date:** 2026-07-22
**Valid until:** No expiry driver — this is closed-codebase research (no external library version drift risk). Re-check only if `genius_wallet_colors.dart`, `gw_mesh_background.dart`, or `genius_api.dart` change materially before this phase executes.
