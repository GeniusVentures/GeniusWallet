---
phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash
plan: 01
subsystem: boot
tags: [flutter, dart-futures, genius_api, wallet_details_cubit, bloc, ffi]

requires:
  - phase: 05-dashboard
    provides: dashboard screen that will later host the widened gate (13-04)
provides:
  - "Memoized `GeniusApi.initSDK()` — router's repeated `InitializeSDK` dispatch during the ~9.6s freeze is now a no-op after the first call, eliminating the caught `LateInitializationError`"
  - "Truthful `WalletDetailsCubit.getCoins()` — completes only when the holdings read settles, and every reachable exit (including both bare-return early exits) now emits a terminal `coinsStatus`"
  - "Measured coins/holdings-leg boot latency (four `[boot-timing]` samples) feeding 13-03's timeout decision"
affects: [13-02, 13-03, 13-04, 13-05]

tech-stack:
  added: []
  patterns:
    - "Future memoization (`_initFuture ??= _doInitSDK()`) as the single-flight guard idiom for at-most-once async operations, in place of a boolean flag or Completer"
    - "Stopwatch + finally-block debugPrint as a temporary, greppable boot-timing instrument (deleted by a later plan, not gated behind kDebugMode)"

key-files:
  created: []
  modified:
    - packages/genius_api/lib/src/genius_api.dart
    - lib/wallets/cubit/wallet_details_cubit.dart

key-decisions:
  - "Memoized `_initFuture` permanently (never reset) — initSDK()'s only caller is router-gated on sdkStatus == AppStatus.initial, which goes permanently false after first completion, so no reset is ever needed"
  - "Left _initSDK's own _isSdkInitialized guard untouched — it independently protects the onboarding _registerWallet path, which bypasses initSDK() entirely and is out of this plan's scope"
  - "getCoins() now awaits its coinFuture inside the existing try/catch rather than a bare .then(), so a rejected read is caught and settles coinsStatus: error instead of stranding on loading forever"
  - "Coins leg does NOT need its own .timeout() in 13-03 — see Interpretation below"

requirements-completed: [BEH]

coverage:
  - id: D1
    description: "Single-flight guard on GeniusApi.initSDK() — native SDK init dispatched exactly once per cold start"
    requirement: BEH
    verification:
      - kind: manual_procedural
        ref: "Task 3 cold-start walk: `Base path directory` count across 4 runs"
        status: pass
    human_judgment: true
    rationale: "Requires reading a live console during a genuine cold start (quit-and-relaunch); not something a unit test can observe"
  - id: D2
    description: "getCoins() is a truthful, always-settling Future (awaits its read, catches rejections, closes both bare-return stranding exits)"
    requirement: BEH
    verification:
      - kind: other
        ref: "flutter analyze lib/wallets/cubit/wallet_details_cubit.dart (0 issues) + grep checks: await coinFuture present, coinFuture.then absent, >=3 coinsStatus: WalletStatus.error emits in getCoins()"
        status: pass
    human_judgment: false
  - id: D3
    description: "Coins/holdings-leg boot-time latency measured as an explicit number (four samples: three online, one offline)"
    requirement: BEH
    verification:
      - kind: manual_procedural
        ref: "Task 3 cold-start walk: four [boot-timing] console lines recorded verbatim by the coordinator"
        status: pass
    human_judgment: true
    rationale: "Latency figures come from live native SDK + network timing; must be read from a real console during real cold starts, not simulated"

# Metrics
duration: ~35min
completed: 2026-07-22
status: complete
---

# Phase 13 Plan 01: Boot-path single-flight guard + truthful getCoins() + measured coins latency Summary

**`GeniusApi.initSDK()` memoized to a single Future (killing the caught `LateInitializationError`), `WalletDetailsCubit.getCoins()` made a truthful always-settling Future, and the coins leg measured at ~9.2-9.6s connected / 137ms offline — confirming the leg's own work is fast and the connected figure is freeze-dominated, not coins-path latency.**

## Performance

- **Duration:** ~35 min (implementation + walk review)
- **Tasks:** 3/3 (2 auto, 1 checkpoint:human-verify)
- **Files modified:** 2

## Accomplishments

- `GeniusApi.initSDK()` is now a one-line `_initFuture ??= _doInitSDK()`; the router's repeated `InitializeSDK` dispatch during the ~9.6s frozen window returns the same in-flight Future instead of re-entering `_doInitSDK`/`_initSDK`, which used to reassign the `late final _basePath` field and throw a caught `LateInitializationError`. `_initSDK`'s own `_isSdkInitialized` guard was left untouched — it still independently protects the onboarding `_registerWallet` path, confirmed to call `_initSDK` directly and never `initSDK()`.
- `WalletDetailsCubit.getCoins()` now `await`s `coinFuture` inside its existing try/catch instead of dispatching it with a bare `.then()` and returning immediately. This makes two things true that weren't before: (1) `getCoins()` completes when the holdings read has actually settled — a precondition 13-03's splash and 13-04's gate both need; (2) a rejected `readTokenAssets`/`readSuperGeniusTokenAssets` is now caught and emits `coinsStatus: WalletStatus.error` instead of leaving the status stranded on `loading` forever.
- Both previously-silent early-return paths inside `getCoins()` (`walletAddress == null`, missing `rpcUrl`/`networkSymbol`) now also emit `coinsStatus: WalletStatus.error` before returning, so every reachable exit settles the status.
- A temporary `[boot-timing]` instrument (Stopwatch + a single `finally`-block debugPrint) was added, explicitly commented as removed by plan 13-05. It answered 13-RESEARCH's open question 1 / assumption A2 with a real measurement (below).
- A dedicated cold-start walk (Task 3, human-run per project policy — not self-certified) confirmed: `Base path directory` appears exactly once per boot (was twice before this plan), `LateInitializationError` is gone entirely (was present on every prior boot this session), and zero `RenderFlex overflowed`/`Unhandled` across four runs.

## Task Commits

No commits were created for this plan. Per `CLAUDE.md` ("Do not create commits"), all changes were left staged in the working tree:

1. **Task 1: Single-flight guard on initSDK** — `packages/genius_api/lib/src/genius_api.dart` (uncommitted)
2. **Task 2: Truthful getCoins() + boot-timing instrumentation** — `lib/wallets/cubit/wallet_details_cubit.dart` (uncommitted)
3. **Task 3: Cold-start walk** — no code changes; verification only

## Files Created/Modified

- `packages/genius_api/lib/src/genius_api.dart` — added `Future<void>? _initFuture` field with a permanent-memoization rationale comment; `initSDK()` reduced to `_initFuture ??= _doInitSDK()`; former `initSDK()` body moved verbatim into new private `_doInitSDK()` with the redundant top-of-function `_isSdkInitialized` check removed (subsumed by the memoized Future); `_initSDK`'s own guard and its one `_isSdkInitialized = true` assignment untouched.
- `lib/wallets/cubit/wallet_details_cubit.dart` — `getCoins()`: `coinFuture.then(...)` replaced by `final coinList = await coinFuture;` followed by the unchanged success-emit block, now inside the existing try/catch; both bare-return early exits (`walletAddress == null`, missing `rpcUrl`/`networkSymbol`) now emit `coinsStatus: WalletStatus.error` before returning; added a `Stopwatch` started right after the `mockMode` guard and a `finally` block printing one `[boot-timing]` line with elapsed ms and terminal `coinsStatus`, commented as temporary and named for removal in plan 13-05.

## Decisions Made

- **Permanent memoization, no reset.** `_initFuture` is never cleared after completion. `initSDK()`'s only caller (`AppBloc._onInitializeSDK`) is gated by `router.dart`'s `sdkStatus == AppStatus.initial`, which is permanently false once `_onInitializeSDK` completes (success or failure) — the operation is already architecturally run-at-most-once per session, so the cached Future only closes the race window, it doesn't need to expire.
- **`_initSDK`'s own guard stays.** It's the only protection for the onboarding `_registerWallet` path (`_registerWallet` → `_initSDK(storedKey)` directly, confirmed by grep, never through the now-memoized `initSDK()`), so removing it would have been an out-of-scope behavior change to Phase 6's in-progress flow.
- **No `.timeout()` added to the coins leg in this plan** — Task 3's measurement is what decides that question for 13-03, not a guess made here.
- **Coins leg does not need its own `.timeout()` in 13-03** (recommendation, backed by measurement below): it settled `successful` in all four cold-start runs, in both network conditions; its own work is ~137ms when not masked by the freeze; and its network calls are already bounded by 13-02's 3s `requestTimeout`. A second timeout would be unrequested complexity on top of an already-bounded, already-succeeding path.

## Deviations from Plan

None — plan executed exactly as written. No Rule 1/2/3 auto-fixes were needed; the two bare-return-to-error-emit changes and the `finally`-block instrument were explicitly specified by the plan's Task 2, not discovered deviations.

## Issues Encountered

None during implementation. The Task 3 walk surfaced one console anomaly, assessed and recorded, not fixed (correctly out of scope for this plan):

- **Run 1 only:** one `EXCEPTION CAUGHT` from Flutter's `hardware_keyboard.dart:516` assertion (`'!_pressedKeys.containsKey(event.physicalKey)'`, a duplicate `KeyDownEvent` for physical key "O"). This is a framework-level terminal/FIFO keyboard-state artifact, unrelated to this plan's changes, and did not recur in runs 2-4. Not investigated further — noted per Task 3's instruction to "record anything that appears even if it looks pre-existing," not fix it here.

## Verification Results (Task 3 cold-start walk)

Run by the coordinator directly (not self-certified), four genuine cold starts with a full quit between each, per this plan's `autonomous: false` gate and the standing instruction not to self-certify a human walk.

| | Run 1 | Run 2 | Run 3 | Run 4 (offline) |
|---|---|---|---|---|
| `Base path directory` count | 1 | 1 | 1 | 1 |
| `LateInitializationError` count | 0 | 0 | 0 | 0 |
| `_basePath` (error string) count | 0 | 0 | 0 | 0 |
| `EXCEPTION CAUGHT` count | 1 (unrelated, see above) | 0 | 0 | 0 |
| `RenderFlex overflowed` count | 0 | 0 | 0 | 0 |
| `Unhandled` count | 0 | 0 | 0 | 0 |

**SC4 confirmed:** `Base path directory` now appears exactly ONCE per cold start (it was TWICE before this plan) and `LateInitializationError` no longer appears at all (it was present on every prior boot this session before the fix). E1 is closed.

### Measured coins/holdings-leg boot latency (four samples, required input to 13-03)

| Run | Network | Elapsed | Terminal status |
|---|---|---|---|
| 1 | connected | **9558 ms** | `WalletStatus.successful` |
| 2 | connected | **9207 ms** | `WalletStatus.successful` |
| 3 | connected | **9556 ms** | `WalletStatus.successful` |
| 4 | disconnected (Wi-Fi off) | **137 ms** | `WalletStatus.successful` |

Disconnected run (4) log evidence: 10× `Failed host lookup`, 1× `TimeoutException after 0:00:03.000000` (13-02's 3s `requestTimeout` firing as designed), 4× cache fallback (`Returning cached` / `Returning old cached`). The app reached a usable, successful `coinsStatus` state offline with zero exceptions.

### Interpretation — stated with its uncertainty, not overstated

The connected figures (~9.2-9.6s) are **strongly believed to be freeze-dominated, not coins-path work**, but this was **not isolated** in the walk and must not be read as established fact:

- `getCoins()` is invoked fire-and-forget from `loadInitial` (`wallet_details_cubit.dart:88`), and a prior spike measured `loadInitial`'s wallet/network setup completing at ~141ms — so the `[boot-timing]` Stopwatch starts at ~141ms into boot and spans the entire native freeze.
- `141ms + ~9558ms ≈ 9699ms`, landing just past the independently measured freeze-lift at `9594ms` (spike 001/M1). The arithmetic is consistent with "the timer mostly measures the freeze," but consistency is not isolation.
- The 137ms offline result (a ~70× drop) supports that reading and surfaces a secondary finding worth flagging forward: **the native freeze itself appears to be largely network-bound** — both logs show the same ~120 SDK/IPFS/bitswap log lines, but offline the SDK evidently fails fast (most plausibly peer discovery / bitswap bootstrap failing immediately with no network) rather than blocking for seconds.

**Residual risk for 13-04 to watch:** if any non-trivial portion of the connected ~9.5s is genuine coins-path latency rather than freeze overlap, folding the coins leg into the boot gate would add real seconds to boot time on top of the freeze. This plan did not rule that out — it only shows the leg's own work is ~137ms when the freeze isn't present to mask it.

### Recommendation to 13-03

**The coins leg does not need its own `.timeout()`.** It settled `successful` in all four runs, under both network conditions; its own work is ~137ms when unmasked by the freeze; and its network calls are already bounded by 13-02's 3s `requestTimeout`. A second, coins-specific timeout would be unrequested complexity layered on an already-bounded, already-succeeding path.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

13-02 (CoinGecko timeout + `BootSequence` engine), 13-03 (Signal Edge splash), and 13-04 (widened dashboard gate) can proceed. 13-03 has the measured coins-leg latency and the "no separate timeout needed" recommendation it was blocked on. 13-05 has its removal target: the `[boot-timing]` Stopwatch/debugPrint/finally block in `wallet_details_cubit.dart`, clearly commented at both insertion points.

No blockers. The one unresolved residual risk (freeze-vs-coins-path attribution, above) is explicitly flagged for 13-04's dashboard-entry walk to watch, not a blocker to this plan's own completion.

## Self-Check: PASSED

- FOUND: `packages/genius_api/lib/src/genius_api.dart` (contains `_initFuture ??=`)
- FOUND: `lib/wallets/cubit/wallet_details_cubit.dart` (contains `await coinFuture`)
- FOUND: `.planning/phases/13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash/13-01-SUMMARY.md`
- No commits to verify — per `CLAUDE.md` ("Do not create commits"), all changes remain uncommitted in the working tree, as instructed.

---
*Phase: 13-boot-loading-sequence-signal-edge-splash-and-one-shared-dash*
*Completed: 2026-07-22*
