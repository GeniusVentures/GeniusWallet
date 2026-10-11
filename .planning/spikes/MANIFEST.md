# Spike Manifest

> NOTE (2026-07-23): the later 9.6 s / 52.5%-stall / 141 ms-data-ready figures cited by sketch 015 and Phase 13 come from a subsequent 40 s / 161-poll cold-start trace, NOT from this spike. This spike measured ~8.2 s freeze; the 52.5% stall curve was UNMEASURED here (see spike 002). Treat the Phase-13 trace as authoritative for those three numbers.

## Ideas

### honest-boot
Make GeniusWallet's boot honest. Today the app shows the Genius logo with a loading
animation that is visibly frozen, then drops the user onto a dashboard whose sections
each flash their own skeleton loaders. The goal: one truthful loading state that stays
up until the app is actually ready, then a dashboard that appears complete.

The measured cause is not a design problem. `GeniusSDKInitWithMnemonic` blocks the Dart
main isolate for ~8.2 s at boot, so Flutter cannot pump a frame and the splash's
`LoadingAnimationWidget.flickr` never gets ticked. These spikes explore whether that
block can be moved off the UI thread, and what can honestly be reported while it runs.

**Requirements:**

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

### linux-inapp-webview
Show external web content (Banxa checkout, Crypto News, the Web browser page, legal pages, explorer links) inside the GeniusWallet window on Linux, as Windows/macOS/mobile already do, instead of handing it to the system browser. Approach: a vendored, patched webview_all_linux (WebKitGTK native widget) that loads WebKit at runtime.

**Requirements:**

- One Linux bundle for every distro: no build-time WebKit link; load libwebkit2gtk-4.1, else 4.0, at runtime; no WebKit means the app still runs and links open in the system browser.
- Call isAvailable() before creating a web view; fall back to url_launcher and say so.
- Route every external link through launchWebSite (9 call sites today, incl. Privacy Policy/Terms, news, explorer links); Banxa's checkout fallback and support link stay deliberate exceptions.
- Nothing may draw over a web view and no rounded clip/transform may sit above one: hide the view while an overlay/route is above it.
- Plugin must hand keyboard focus back to Flutter.
- CI image needs webkit2gtk3-devel (headers only).

## Spikes

| # | Idea | Name | Type | Validates | Verdict | Tags |
|---|------|------|------|-----------|---------|------|
| 001 | honest-boot | [sdk-init-off-isolate](001-sdk-init-off-isolate/) | standard | Init inside `Isolate.spawn` frees the main isolate and leaves the SDK usable from it | ✗ INVALIDATED | ffi, isolate, boot, sgns-sdk, splash |
| 002 | honest-boot | [init-progress-polling](002-init-progress-polling/) | standard | `getInitializationStatus()` yields advancing progress while init runs | ⚠ PARTIAL | ffi, progress, splash, sgns-sdk |
| 003 | linux-inapp-webview | webkitgtk-40-embed | standard | Given Ubuntu 20.04 WebKitGTK 4.0, when a Flutter app uses patched webview_all_linux, then pages render in-app and survive resize | VALIDATED | linux, webview, webkitgtk |
| 004 | linux-inapp-webview | camera-permission-path | standard | Given the embedded view, when getUserMedia is called, then the Dart permission callback fires | PARTIAL | linux, webview, permissions |
| 005 | linux-inapp-webview | wallet-surfaces-in-app | standard | Given the wallet Linux build, when news, Web and Banxa checkout open, then they render in-app | PARTIAL | linux, webview, banxa, ux |
| 006 | linux-inapp-webview | almalinux8-build | standard | Given the AlmaLinux 8 CI image, when the patched plugin builds and runs, then it links and the permission path works on 2.54 | PARTIAL | linux, ci, almalinux |
| 007 | linux-inapp-webview | webkit-runtime-loading | standard | Given one EL8-built bundle, when run on Ubuntu 20.04/22.04/24.04, EL8 and no-WebKit, then it always launches and renders or falls back | VALIDATED | linux, webview, dlopen, portability |

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
