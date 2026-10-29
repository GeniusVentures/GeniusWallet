---
phase: 45-hardened-bridge-transports
plan: 05
subsystem: gnus-bridge
tags: [android, webview, androidx-webkit, method-channel]
requires: [45-01 GnusWebBridge, 45-02 gnusNavigation]
provides: [GnusWebBridge.kt, GnusNativeBridgeChannel shared with iOS and macOS, GnusBridgeViewMobile]
status: complete
actuals: {tokens: 9500, tasks: 2, commits: 2}
key-files:
  created: [android/app/src/main/kotlin/ai/gnus/genius_wallet/GnusWebBridge.kt, lib/gnus_bridge/gnus_native_bridge_channel.dart, lib/gnus_bridge/gnus_bridge_view_mobile.dart, test/gnus_bridge/gnus_native_bridge_channel_test.dart]
  modified: [android/app/src/main/kotlin/ai/gnus/genius_wallet/MainActivity.kt, android/app/build.gradle, lib/dev/gnus_bridge_test_screen.dart]
key-decisions: [no page is loaded when install returns false]
---

# Phase 45 Plan 05: Android transport

`install {webViewId, origins, shim}` returns false for a missing WebView, a missing
`WEB_MESSAGE_LISTENER` or `DOCUMENT_START_SCRIPT` feature, an empty list or a bad origin rule.
The listener drops `!isMainFrame` and non-string messages and sends
`message {webViewId, message, source}` to Dart on the main thread. The Dart view never calls
`addJavaScriptChannel`.

## Android matrix row
- Test: `gnus_native_bridge_channel_test.dart`, 8 tests (install arguments, off-list source, allowed source, macOS-shaped source, malformed or unknown reports, refused install, missing installer, uninstall). `flutter analyze lib test` exit 0.
- Compile: `gradlew :app:compileReleaseKotlin` exit 0 and `GnusWebBridge.class` produced, run from the short-path copy with `-Xmx6g`. The first run died in Jetify with "Java heap space" at the project's 1.5 GB setting. No APK was built; native packaging stays pending PR CI.
- Walk: phase 48 on `GW_Test`. It needs a debug APK with the dev route, `adb reverse tcp:3000 tcp:3000` and cleartext localhost.

## Deviations
- The channel client and its test were written while the Windows build ran, so they sit in this plan's second commit rather than being split across plans.
- `build.gradle` gains `androidx.webkit:webkit:1.15.0`, the version `webview_flutter_android` already resolves.
- Not run on a device: whether the document-start script and the listener object are ready in the same order on every WebView version is unverified until the phase 48 walk. The shim falls back to a lazy lookup of `window.gnusBridge` if the object is not there at install.

## Known stubs
None.
