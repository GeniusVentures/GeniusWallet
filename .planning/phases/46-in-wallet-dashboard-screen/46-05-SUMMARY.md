---
phase: 46-in-wallet-dashboard-screen
plan: 05
subsystem: gnus-bridge
tags: [android, back, file-picker, gate, matrix]
requires: [46-04]
provides: [PopScope over page history, gnusPickerExtensions, gnusPickerAllowed, debug cleartext localhost]
status: partial
actuals: {tokens: 10000, tasks: 3, commits: 2}
key-files:
  created: [test/gnus_bridge/gnus_file_picker_test.dart, android/app/src/debug/res/xml/network_security_config.xml]
  modified: [lib/gnus_bridge/gnus_bridge_view_mobile.dart, android/app/src/debug/AndroidManifest.xml]
---

# Phase 46 Plan 05: Back, file picker, cleartext, gate

The mobile view's `PopScope` follows `canGoBack`, refreshed on every URL change and page finish; a blocked pop calls
`goBack`. On Android, `setOnShowFileSelector` serves the picker only while the tracked top URL is allowlisted, filtered by
the input's `accept` extensions (any file when none). Only the debug source set allows cleartext, and only to `localhost`.
## Gate (phase head)
- `dart format --set-exit-if-changed lib test` and `flutter analyze lib test packages/genius_api` exit 0.
- `flutter test`: 3118 passed, 10 skipped, 0 failed (baseline 3056/10/0). Brace, raw-colour and key-logging
  `--scan-tree` checks exit 0; no CRLF in changed files; no phase text in source.
- Release door (D-18), read in code: the only release path to a bridge view is `/gnus-dashboard`; `/dev/gnus-bridge` stays
  behind `kDebugMode && kShowDevTools`; the entry is unlisted while the pinned origin is `.invalid`.
## Matrix
Criteria: 1 entry, `window.gnus`; 2 origin pin, nav lock; 3 dialogs above page; 4 Android picker, Back; 5 no WebKitGTK.
T test, B build, P pending walk (phase 48 or the combined Linux walk), X blocked, - n/a.

| Platform | 1 | 2 | 3 | 4 | 5 |
|---|---|---|---|---|---|
| Linux | T entry, contrast; P walk | T start rules, `gnusNavigation`; P walk | T gate with fake host; P walk | - | T browser launch and toast |
| Windows | T; B debug exe; P walk | T; B (`NavigationStarting`); P walk | texture composites inside Flutter; B; P walk | - | - |
| Android | T; B resources only; P walk | T; P walk | platform view; unchecked; P walk | T pure rules; B resources and manifest; P walk | - |
| iOS | T; X build; X walk | T; X | unchecked; X | Back is the edge swipe; X | - |
| macOS | T; X build (VM); P walk | T; X build; P walk | unchecked; X build; P walk | - | - |
## Deviations
- DWV-06 Back and the picker callback rest on analyze and the pure-rule tests; the repo has no fake web view platform.
- No Android APK built; resources and manifest merge passed. Full APK pending CI.
- SDK-CA: no live estimate or submit is walked anywhere; walks use the JOB fixture. Known stubs: none.
