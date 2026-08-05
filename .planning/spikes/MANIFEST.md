# Spike Manifest

> NOTE (2026-07-23): the later 9.6 s / 52.5%-stall / 141 ms-data-ready figures cited by sketch 015 and Phase 13 come from a subsequent 40 s / 161-poll cold-start trace, NOT from this spike. This spike measured ~8.2 s freeze; the 52.5% stall curve was UNMEASURED here (see spike 002). Treat the Phase-13 trace as authoritative for those three numbers.

## Idea

Make GeniusWallet's boot honest. Today the app shows the Genius logo with a loading
animation that is visibly frozen, then drops the user onto a dashboard whose sections
each flash their own skeleton loaders. The goal: one truthful loading state that stays
up until the app is actually ready, then a dashboard that appears complete.

The measured cause is not a design problem. `GeniusSDKInitWithMnemonic` blocks the Dart
main isolate for ~8.2 s at boot, so Flutter cannot pump a frame and the splash's
`LoadingAnimationWidget.flickr` never gets ticked. These spikes explore whether that
block can be moved off the UI thread, and what can honestly be reported while it runs.

## Requirements

Design decisions that emerged during spiking. Non-negotiable for the real build.

- **Single-flight guard on SDK init.** `_initSDK` currently runs twice at boot — the
  router redirect (`lib/navigation/router.dart:56`) dispatches `InitializeSDK` before
  `sdkStatus` leaves `AppStatus.initial`, and `_isSdkInitialized` is only set at the
  *end* of `_initSDK`. Today this throws a caught `LateInitializationError`; with a
  longer-running init the race window widens. Store the in-flight `Future` and return
  it to concurrent callers.
- **Any network leg in the readiness gate needs a timeout with a cached-data
  fallback.** Observed live: a full run with DNS down (`Failed host lookup:
  api.coingecko.com`). The app booted only because market sections fail soft onto
  cache. Gating boot on them without a timeout would hang the app outright.
- **`GeniusSDKInit*` returning is NOT "SDK ready" — it is the 10% mark.** Readiness
  must be derived from `getInitializationStatus()` reaching completion, not from the
  init call returning.
- **No Dart-driven animation can be promised for the first ~8.2 s of boot.** Spinner,
  blur, progress bar — all render on the main isolate, which is frozen. Any design that
  claims live feedback from second zero cannot be built on the SDK as it stands.

## Spikes

| # | Name | Type | Validates | Verdict | Tags |
|---|------|------|-----------|---------|------|
| 001 | [sdk-init-off-isolate](001-sdk-init-off-isolate/) | standard | Init inside `Isolate.spawn` frees the main isolate and leaves the SDK usable from it | ✗ INVALIDATED | ffi, isolate, boot, sgns-sdk, splash |
| 002 | [init-progress-polling](002-init-progress-polling/) | standard | `getInitializationStatus()` yields advancing progress while init runs | ⚠ PARTIAL | ffi, progress, splash, sgns-sdk |

### Verdict summary

**001 — INVALIDATED.** The init *does* run correctly from a spawned isolate (returns
OK; the main isolate afterwards reads a valid 130-char address through its own handle,
so cross-isolate visibility of native state is fine). But the main isolate still stalls
~8.2 s. A control run whose timer made no SDK call at all recorded **zero** ticks
across the window, and the bindings are all non-leaf (0 × `isLeaf: true` across 41
`asFunction` calls), ruling out the textbook leaf-FFI safepoint bug. The block is below
Dart — most plausibly the native init contending for the platform main thread that the
Dart main isolate runs on. No arrangement of Dart isolates routes around it; a fix
would have to land in GeniusSDK/SuperGenius C++.

Reusable positives: `decryptMnemonic` on the main isolate costs only 209–361 ms, so it
never needed moving.

**002 — PARTIAL.** Progress is unreportable during the ~8.2 s blocking phase (no Dart
runs), but fully reportable *after* it, where `getInitializationStatus()` returns
instantly with real staged messages such as `"Migrating database (step 1 of 5): v0.2.0
-> v1.0.0"`. So a determinate progress bar is feasible for the post-block phase only.

## Open Questions

- Does the phase-2 percentage actually reach 1.0, how long does it take, and does it
  ever stall? Every observation so far was a single sample at the instant init
  returned. Cheap to measure now that the main isolate is known responsive there.
- Is the ~8.2 s block reproducible in a profile/release build, or is some of it a
  debug-JIT artifact? All runs so far were debug.
- Can GeniusSDK expose a non-blocking init entry point? That is the only route to a
  genuinely animated first 8 seconds.
