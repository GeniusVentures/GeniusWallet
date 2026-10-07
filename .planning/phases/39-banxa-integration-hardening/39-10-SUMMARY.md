---
phase: 39-banxa-integration-hardening
plan: 10
subsystem: banxa-checkout
tags: [banxa, checkout, kyc, camera, permissions, webview]
requires: [39-09]
provides:
  - "Camera, microphone, file upload and inline media for Banxa's ID step inside the in-app checkout"
  - "androidPermissionsFor: pure map from a page's permission request to OS permissions"
key-files:
  created: [test/banxa/checkout_platform_config_test.dart]
  modified: [pubspec.yaml, pubspec.lock, android/app/src/main/AndroidManifest.xml, ios/Runner/Info.plist, macos/Runner/Info.plist, macos/Runner/DebugProfile.entitlements, macos/Runner/Release.entitlements, lib/banxa/checkout/checkout_webview.dart, lib/banxa/checkout/checkout_rules.dart, test/banxa/checkout_rules_test.dart]
status: complete
actuals: {tokens: 14000, tasks: 2, commits: 2}
---
# Phase 39 Plan 10: ID step inside the checkout Summary

Banxa's ID step can now use the camera, microphone and file upload inside the in-app checkout on Android, iOS and macOS; Windows keeps its own rule from plan 09.

## Result
- Full `flutter test`: 2335 passed, 6 skipped, 0 failed (plan 09 ended at 2328). `flutter analyze lib test` exit 0. Format, brace, raw-colour and key-logging (`--scan-tree`) scripts exit 0. ID gate printed 0 on both commits. No trailers, email braianwegmann@hotmail.com. STATE.md and ROADMAP.md untouched; no flutter_tester left running. No checkpoints or tracer tasks.
- Commits: 2378c177 (declarations and config test), 40f37ead (webview wiring and `androidPermissionsFor`).
- `pubspec.lock` diff is three `dependency:` lines (transitive to direct main) and no version line, as planned. All edited platform files stayed LF.
- Not run: the Android OS prompt, the file chooser and the WebKit inline-media flag run only on a device. A live KYC walk on Android and iOS/macOS is owed; the tests cover the pure rule and the declarations only.

## Decisions
- The Android grant runs `androidPermissionsFor(types)` through permission_handler, then re-checks that the page is still a Banxa page before granting, since the OS prompt can outlive the page that asked.
- The file chooser also refuses (returns no files) when the current page is not a Banxa page, matching the camera rule. Accepted extensions are fixed: jpg, jpeg, png, heic, pdf.
- Platform is chosen by the registered `WebViewPlatform` and the controller's runtime type, not `Platform.isX`, so widget tests with a fake platform are unaffected.
- iOS and macOS camera strings now also name the ID check; microphone string is the planned sentence.

## Deviations from Plan
- Direct constraints are caret ranges on the locked versions (`^4.12.0`, `^3.25.1`, `^12.0.3`), not exact pins; the lock does not move.
- File picking and the OS request sit in the widget State, as the plan specifies, rather than behind a repository. The webview plugin is already driven from that widget.

## Self-Check: PASSED
Both commits are in `git log`, the new test file exists, and no message carries a trailer. Known stubs: none.
