---
phase: 46-in-wallet-dashboard-screen
plan: 04
subsystem: gnus-bridge
tags: [windows, android, ios, macos, builds]
requires: [46-01, 46-02, phase 45 views]
provides: [onLoaded/onFailed/onNoBridge on the Windows and mobile views, one gnusBridgeHostKind chooser]
status: partial
actuals: {tokens: 12000, tasks: 2, commits: 1}
key-files:
  modified: [lib/gnus_bridge/gnus_bridge_view_windows.dart, lib/gnus_bridge/gnus_bridge_view_mobile.dart, lib/gnus_bridge/gnus_dashboard_screen.dart, lib/dev/gnus_bridge_test_screen.dart]
---

# Phase 46 Plan 04: Same screen on Windows and mobile

Both views take optional `onLoaded`, `onFailed`, `onNoBridge`; with all three null they behave as before. Windows:
`navigationCompleted` is loaded, `onLoadError` is failed (a cancelled redirect is not), a WebView2 start failure is
no-bridge (rethrown when no callback is given). Mobile: `onPageFinished`, a main-frame `onWebResourceError`, and an
install that returns false. The screen passes them for every kind. `/dev/gnus-bridge` now picks its view through
`gnusBridgeHostKind` (no `Platform.is` left in it).

## Build rows
| Platform | Result | Evidence |
|---|---|---|
| Windows | B | `flutter build windows --debug --dart-define=GW_DEV_TOOLS=true`, exit 0, `genius_wallet.exe` built, on the final head, from the short-path copy `GNUS\g45` (lib, test and android/app/src mirrored in) |
| Android | B | `gradlew :app:processDebugResources` exit 0; merged debug manifest carries the network config. No APK built; full APK pending CI |
| macOS | X | Tart VM unreachable: `ssh bwegmann@192.168.6.40` timed out on port 22 (WARP tunnel not up) |
| iOS | X | same VM, and the simulator cannot load the device-only SDK libs (phase 45) |
B build, X blocked. No walks here (phase 48). ATS with `http://localhost` on macOS debug: not checked.

## Verification
`flutter test test/gnus_bridge test/dev`: 427 passed, 4 skipped, 0 failed; the `gnusBridgeHostKind` table test (46-01)
covers all six cases and the phase 45 view tests pass unchanged. `flutter analyze lib test` exit 0.

## Deviations
- [Rule 2] The Windows view reports a WebView2 start failure through `onNoBridge`; the plan listed only load and failure.
- Not tested: the view callbacks. The repo has no fake `WebViewPlatform` (its package is only transitive), so the wiring
  is checked by build and analyze and by the phase 48 walks.
- g45 existed from phase 45 and was reused, not deleted; it now holds this head.
Known stubs: none.
