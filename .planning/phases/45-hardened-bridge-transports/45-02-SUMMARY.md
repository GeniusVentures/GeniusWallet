---
phase: 45-hardened-bridge-transports
plan: 02
subsystem: gnus-bridge
tags: [navigation-lock, popups, user-agent, test-page, linux]
requires: [45-01 GnusWebBridge and gnusAllowedOrigins]
provides: [gnusNavigation, isNewWindow on the vendored Linux NavigationRequest, gnusUserAgentSuffix, tool/gnus_bridge_test_page]
status: complete
actuals: {tokens: 4600, tasks: 3, commits: 3}
key-files:
  created: [tool/gnus_bridge_test_page/index.html, tool/gnus_bridge_test_page/frame.html]
  modified: [lib/gnus_bridge/gnus_dashboard_origins.dart, lib/gnus_bridge/gnus_bridge_view_linux.dart, third_party/webview_all/webview_all_linux/linux/src/webview/linux_webview.cc, third_party/webview_all/webview_all_linux/lib/src/linux_webview_events.dart, third_party/webview_all/webview_platform_interface/lib/src/types/navigation_request.dart]
key-decisions: [a window.open() load is flagged by the URI the create signal saw, kept as GObject data, so no struct change]
---

# Phase 45 Plan 02: Navigation lock, popups, user agent, test page

`gnusNavigation` is one pure rule: main frame loads only allowlisted origins (off-list http(s) opens
the system browser), Linux frame-blind loads allow only the list plus `about:blank` and `about:srcdoc`,
new windows never load in the view, and nothing but http(s) leaves the app. The Linux view sends every
navigation request through it and reads no URL from the controller.

## Verification
- `flutter test test/gnus_bridge test/web test/banxa`: 587 passed, 0 failed (24 navigation table rows plus a non-http sweep).
- `flutter analyze lib test` exit 0; `tool/check_brace_style.sh` exit 0.
- `git diff --stat third_party` touches the three plan files only (vendored Linux C++, one Dart events file, one interface type).
- Test page: both scripts parse in node; no `<script src>`; rows C1 to C8 present.
- NOT run: the Linux native build and any walk of the page (plan 45-03, deferred by Braian). The C change was checked by reading against the WebKitGTK calls already used in the file.

## Deviations
- [Rule 1] A `window.open()` popup reaches the plugin through the `create` signal, which loaded the URL in place with a plain navigation decision, so the plan's new-window flag alone would miss it. The `create` handler now records the URI and the matching decision reports `isNewWindow`. If another load of the same URI races in between, it is also flagged: that sends one load to the browser at worst.
- The plan listed two page files; the srcdoc frame needs the same check as `frame.html`, so the function is pasted into both with a note to keep them equal.

## Known stubs
None.
