---
phase: 45-hardened-bridge-transports
plan: 04
subsystem: gnus-bridge
tags: [windows, webview2, vendored-plugin]
requires:
  - phase: 45-hardened-bridge-transports
    provides: GnusWebBridge, gnusNavigation (plans 01, 02)
provides:
  - third_party/webview_windows (0.4.0, unchanged copy then additive patches)
  - GnusBridgeViewWindows, shown by the dev screen on Windows
status: complete
actuals: {tokens: 14000, tasks: 3, commits: 4}
key-files:
  created: [third_party/webview_windows/, lib/gnus_bridge/gnus_bridge_view_windows.dart]
  modified: [pubspec.yaml, pubspec.lock, lib/dev/gnus_bridge_test_screen.dart]
key-decisions:
  - A page start is the plugin's Loading state; the reply and event scripts also check location.origin in the page, which covers the gap before it
---

# Phase 45 Plan 04: Windows transport

Commits: vendor unchanged (101bfefb), native and Dart patches (d542db8e), the view (dcc1334f).
The origin of every message is the `get_Source()` WebView2 reports, delivered on a new
`webMessageWithSource` stream; the view never subscribes to the source-less `webMessage` stream.
`NavigationStarting` cancels a top-level load unless the Chromium-canonical URI equals an allowed origin or
continues it with `/`, so `https://host.evil` does not match `https://host`. A suppressed popup's URI and a
cancelled load go through `gnusNavigation`; `external` opens with `launchUrl`.

## Windows matrix row
- Test: `flutter test test/gnus_bridge test/web test/banxa test/dev` 696 passed, 4 skipped, 0 failed. No widget test drives the WebView2 view.
- Build: `flutter build windows --debug` exit 0, `genius_wallet.exe` produced, from a short-path copy (see deviations).
- Walk: not run. The optional CDP read of rows C1 to C8 needs a `GW_DEV_TOOLS` build and Braian's mouse; it is not a gate.

## Deviations
- [Rule 3] Building in the worktree path fails: a plugin include path reaches 260 characters and the sentry-native submodule checkout hits "Filename too long". The passing build ran on a copy of the tree at `C:\Users\User\Documents\Projects\GNUS\g45` (junction removed, plain copy), which also shares the real `GNUS\thirdparty` and SDK folders. The copy is untracked and outside the repo.
- My first two attempts downloaded the SDK folders into `.claude\worktrees\` and the worktree root. I deleted those eight folders and `build\windows`.
- The bridge emits the sourced message event for every message (an extra event type the old Dart ignores), so "off unless asked" holds for behaviour, not for event traffic.
- The allowlist patch sits in `NavigationStarting`, which is main-frame only in WebView2; frames are not checked there.

## Known stubs
None.
