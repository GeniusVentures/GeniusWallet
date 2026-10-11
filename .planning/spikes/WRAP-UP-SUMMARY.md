# Spike Wrap-Up Summary

**Date:** 2026-10-11
**Spikes processed:** 7
**Feature areas:** boot-sdk-init, linux-webview-plugin, linux-webview-wallet-integration
**Skill output:** `./.claude/skills/spike-findings-geniuswallet/`

## Processed Spikes
| # | Name | Type | Verdict | Feature Area |
|---|------|------|---------|--------------|
| 001 | sdk-init-off-isolate | standard | INVALIDATED | boot-sdk-init |
| 002 | init-progress-polling | standard | PARTIAL | boot-sdk-init |
| 003 | webkitgtk-40-embed | standard | VALIDATED | linux-webview-plugin |
| 004 | camera-permission-path | standard | PARTIAL | linux-webview-plugin |
| 005 | wallet-surfaces-in-app | standard | PARTIAL | linux-webview-wallet-integration |
| 006 | almalinux8-build | standard | PARTIAL | linux-webview-plugin |
| 007 | webkit-runtime-loading | standard | VALIDATED | linux-webview-plugin |

## Key Findings

- **Boot.** `GeniusSDKInitWithMnemonic` freezes the main isolate ~8.2 s whichever isolate calls it;
  the block is native. Init returning means 10%, not ready. Progress is real and pollable only
  after init returns.
- **Plugin.** Vendored `webview_all_linux` with a dlopen/dlsym table (4.1, else 4.0; API by symbol
  presence) gives one EL8-built bundle that launches on Ubuntu 20.04/22.04/24.04, AlmaLinux 8 and
  no-WebKit systems. CI needs only `webkit2gtk3-devel`. Promise JS results need `; undefined` on
  WebKit >= 2.40. getUserMedia needs `enable_media_stream(TRUE)` and is absent on Ubuntu 20.04.
- **Wallet.** News, the Web page and Banxa checkout render in-app; no-WebKit falls back cleanly.
  Blocking issues for a real phase: keyboard focus stays in WebKit, Flutter overlays are cut by the
  page, rounded clips hide it. External links all go through `launchWebSite`; two Banxa
  `launchUrl` calls are deliberate exceptions.
- **Open.** Phase-2 boot progress curve; profile/release boot timing; `GDK_GL=gles` and
  compositing env on real Linux hardware; fresh Banxa sandbox order to the email screen.
