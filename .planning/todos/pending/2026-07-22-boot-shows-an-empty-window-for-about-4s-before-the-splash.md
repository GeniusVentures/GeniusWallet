# Boot shows an empty window for ~4s before the splash paints

**Raised:** 2026-07-22, during the Phase 13 walk (13-03)
**Status:** deferred by Jakub to a separate discussion — likely owner **Brian**
**Not** part of Phase 13's scope. Logged so the measurements are not lost.

## Symptom

Launching the app on macOS shows a bare window for roughly four seconds before
the Genius logo and the boot screen appear. Jakub: *"Czarny ekran i dopiero po
chwili się odpala Genius i ładowanie."*

## Measured, not estimated

Instrumented `main()`'s `appRunner` on a debug macOS build. Stopwatch starts at
the top of `appRunner`, so Flutter engine boot and `SentryFlutter.init` happen
*before* t=0 here:

```
Hive.initFlutter()      1251 ms   <-- single largest cost
box opens (parallel)     685 ms   (was ~810 ms sequential)
rest of appRunner        385 ms
------------------------------
first frame schedulable 2323 ms
+ engine boot + Sentry init, ahead of the stopwatch   ~1.5 s
                                    ≈ 3.8 s total, matching the reported ~4 s
```

`Hive.initFlutter()` is ~54% of the measured window. It resolves the app
documents directory through `path_provider`, which is the process's **first
platform-channel call** — so it also pays for bringing the plugin bridge up.

## What was already done (shipped with Phase 13, keep)

1. **Removed `await fetchAllCoinGeckoCoins()` from before `runApp()`**
   (`main.dart`). It was a *network* call on the critical path — up to the full
   3 s `requestTimeout` on a cold or expired cache. Safe to delete rather than
   defer: the function self-caches and every real consumer awaits it itself
   (`dashboard_markets_util.dart:71`/`:87`, `coins_screen.dart:87`,
   `coin_gecko_api.dart:247`), and the splash's closing run now warms the same
   cache. Firing it unawaited would have raced the splash into a duplicate fetch.
2. **Set the native macOS window background** to the boot canvas colour
   (`MainFlutterWindow.swift`), so the pre-first-frame window is no longer pure
   black. Must stay in sync with `_kBootCanvas` in `lib/screens/splash.dart`.
3. **Parallelised the Hive box opens** (`lib/hive/init.dart`) — all adapters
   register first (synchronous), then the nine boxes open via `Future.wait`.
   Worth ~125 ms. Honest assessment: marginal. Kept because the code is clearer
   and strictly safer on adapter ordering, not because it solved anything.

## What would actually fix it — needs a decision, not a patch

**Call `runApp()` first, bootstrap underneath it.** Today `main()` completes the
entire initialisation and only then calls `runApp()`, so the whole 2.3 s is spent
with nothing rendered. Inverting that would show the boot screen almost
immediately and let Hive / secure storage / providers initialise behind it.

The cost is real: `networkProvider`, `networkTokensProvider` and `geniusApi` are
constructed **before** `runApp()` and injected into the widget tree, so the app
would need to tolerate a "not yet initialised" state — new failure modes on
every screen that reads them, not just the splash.

That is why this was not done inline during a walk.

## Open question for whoever picks this up

Is 1.25 s for `Hive.initFlutter()` normal on this machine, or is something in the
Hive setup pathological? It was measured once, on one machine, in debug. Worth a
second data point (release build, and a second machine) before designing around
the number.
