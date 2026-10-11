---
name: spike-findings-geniuswallet
description: Implementation blueprint from spike experiments. Requirements, proven patterns, and verified knowledge for building GeniusWallet. Auto-loaded during implementation work.
---

<context>
## Project: GeniusWallet

**honest-boot.** Make GeniusWallet's boot honest: one truthful loading state that stays up until
the app is actually ready, then a dashboard that appears complete. The measured cause is that
`GeniusSDKInitWithMnemonic` blocks the Dart main isolate for ~8.2 s at boot, so the splash
animation never ticks. The spikes asked whether that block can move off the UI thread and what can
honestly be reported while it runs.

**linux-inapp-webview.** Show external web content (Banxa checkout, Crypto News, the Web browser
page, legal pages, explorer links) inside the GeniusWallet window on Linux, as Windows/macOS/mobile
already do, instead of handing it to the system browser. Approach: a vendored, patched
webview_all_linux (WebKitGTK native widget) that loads WebKit at runtime.

Spike sessions wrapped: 2026-07 (001-002), 2026-10-11 (003-007)
</context>

<requirements>
## Requirements

### honest-boot

- Single-flight guard on SDK init: store the in-flight `_initSDK` Future and return it to
  concurrent callers (the router redirect dispatches `InitializeSDK` a second time today).
- Any network leg in the readiness gate needs a timeout with a cached-data fallback.
- `GeniusSDKInit*` returning is NOT "SDK ready", it is the 10% mark. Derive readiness from
  `getInitializationStatus()` reaching completion.
- No Dart-driven animation can be promised for the first ~8.2 s of boot.

### linux-inapp-webview

- One Linux bundle for every distro: no build-time WebKit link; load libwebkit2gtk-4.1, else 4.0,
  at runtime; no WebKit means the app still runs and links open in the system browser.
- Call isAvailable() before creating a web view; fall back to url_launcher and say so.
- Route every external link through launchWebSite (9 call sites today, incl. Privacy Policy/Terms,
  news, explorer links); Banxa's checkout fallback and support link stay deliberate exceptions.
- Nothing may draw over a web view and no rounded clip/transform may sit above one: hide the view
  while an overlay/route is above it.
- Plugin must hand keyboard focus back to Flutter.
- CI image needs webkit2gtk3-devel (headers only).
</requirements>

<findings_index>
## Feature Areas

| Area | Reference | Key Finding |
|------|-----------|-------------|
| Boot / SDK init | references/boot-sdk-init.md | Init blocks the platform main thread below Dart; `Isolate.spawn` does not help. Only the post-init phase (10% -> ready) can show real progress. |
| Linux web view plugin | references/linux-webview-plugin.md | dlopen/dlsym table over WebKitGTK 4.1 then 4.0 gives one EL8-built bundle that runs on Ubuntu 20.04-24.04, EL8 and no-WebKit systems. |
| Linux web view wallet integration | references/linux-webview-wallet-integration.md | Probe `isAvailable()` at startup, route all links through `launchWebSite`; must ship focus hand-back, overlay hiding and no rounded clips. |

## Source Files

Original spike source files are preserved in `sources/` for complete reference (READMEs, spike
apps' `lib/main.dart` and `pubspec.yaml`, scripts, Dockerfiles, diffs). Screenshots, logs and the
vendored plugin tree are not copied.
</findings_index>

<metadata>
## Processed Spikes

- 001-sdk-init-off-isolate
- 002-init-progress-polling
- 003-webkitgtk-40-embed
- 004-camera-permission-path
- 005-wallet-surfaces-in-app
- 006-almalinux8-build
- 007-webkit-runtime-loading
</metadata>
