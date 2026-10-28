---
phase: 45-hardened-bridge-transports
plan: 06
subsystem: gnus-bridge
tags: [ios, macos, wkwebview, swift]
requires:
  - phase: 45-hardened-bridge-transports
    provides: GnusNativeBridgeChannel, GnusBridgeViewMobile (plan 05)
provides:
  - Swift installer in AppDelegate.swift (iOS) and MainFlutterWindow.swift (macOS)
  - iOS and macOS enabled in the shared view and the dev screen
status: complete
actuals: {tokens: 5200, tasks: 2, commits: 2}
key-files:
  modified: [ios/Runner/AppDelegate.swift, macos/Runner/MainFlutterWindow.swift, lib/dev/gnus_bridge_test_screen.dart]
key-decisions:
  - The two Swift copies stay separate (Rule of Three); no new Swift file, so no Xcode project edit
---

# Phase 45 Plan 06: iOS and macOS transport

`install` adds a `WKUserScript` at document start for the main frame only, plus a `gnusBridge` message handler
that returns unless `frameInfo.isMainFrame` and the body is a string. The source is
`securityOrigin` protocol, host and a non-zero port; Dart canonicalises it. Method names and argument keys match
the Kotlin side. `uninstall` removes the handler; the handler holds the channel weakly.

## iOS and macOS matrix rows
- Test: the channel tests cover both, including a macOS-shaped source with no port. `flutter analyze lib test` exit 0.
- Build: pending, VM unreachable. `ssh bwegmann@192.168.6.40` with `gw_tart_ed25519` timed out on port 22 (the Cloudflare One tunnel is not up from this PC). Swift was reviewed against the plugin source, not compiled.
- Walk: iOS blocked (the simulator cannot load the device-only SDK libraries). macOS pending (a debug build stops at "Secure storage is unavailable" without Braian's certificate).

## Deviations
- The plugin's class is `FWFWebViewFlutterWKWebViewExternalAPI` in webview_flutter_wkwebview 3.25.1, not `WebViewFlutterWKWebViewExternalAPI`. The Swift uses the real name.
- Both files take the messenger from the plugin registrar rather than the window, so the same code works with or without a root view controller.
- `WKUserContentController` cannot remove one script, so a second install on the same view adds a second copy of the shim (marked `ponytail:`). It installs once per document, so the copy does nothing.
- The first Swift compile may need a fix. Anything the VM build finds goes into AppDelegate.swift and MainFlutterWindow.swift only.

## Known stubs
None.
