---
phase: 45-hardened-bridge-transports
plan: 01
subsystem: gnus-bridge
tags: [webview, window.gnus, allowlist, linux]
requires:
  - phase: 44-dashboard-consent-and-limits
    provides: GnusRpcHandler, GnusOrigin
provides:
  - GnusWebBridge session shared by every web view platform
  - gnusAllowedOrigins and the pinned dashboard origin per SgnsNet
  - Linux bridge view and the dev route /dev/gnus-bridge
status: complete
actuals: {tokens: 9600, tasks: 3, commits: 3}
key-files:
  created: [lib/gnus_bridge/gnus_web_bridge.dart, lib/gnus_bridge/gnus_dashboard_origins.dart, lib/gnus_bridge/gnus_bridge_view_linux.dart, lib/dev/gnus_bridge_test_screen.dart]
  modified: [lib/navigation/router.dart, lib/dev/dev_tools_bubble.dart, lib/gnus_bridge/gnus_rpc_handler.dart]
key-decisions:
  - Allowed origin from the message source only; a missing source answers 4100 into the page tracked from page starts
  - GnusRpcHandler.readSgnsNet made public so widgets reach the net through the handler
---

# Phase 45 Plan 01: Linux tracer and the shared session

One session per web view: shim with per-view secret and per-document request ids, source parsed by
`GnusOrigin.tryParse(GnusTransport.webview, source)`, allowlist, generation guard, events through
`eventsFor`. The Linux view feeds it the tracked top-level URL.

## Baseline (before the first change)
`flutter test`: 2998 passed, 10 skipped, 0 failed.

## Verification
- `flutter test test/gnus_bridge test/dev`: 349 passed, 4 skipped, 0 failed.
- `flutter analyze lib test` exit 0; `tool/check_brace_style.sh` exit 0.
- The shim was run in node against a mocked window: request, reply, error, event, frozen `window.gnus`.
- Mutation: replacing the generation check with `false` fails 2 tests (reply dropped after a page start; handler not reached after a page start). Restored.
- The route is added only under `kDebugMode && kShowDevTools`; the screen checks it again.

## Deviations
- [Rule 3] `test/gnus_bridge/gnus_rpc_guards_test.dart` forbade Flutter UI under `lib/gnus_bridge`. It now exempts `gnus_bridge_view_*.dart`; the rule still holds for the handler, stores and session.
- [Rule 2] The shim installs `on` and `removeListener` in task 1 instead of stubs; the session also gained `allowedOrigins()` and `dispose()`.
- My first edits wrote CRLF into three LF files. Rewrote the three local commits to LF before moving on.

## Pending
Linux live walk is deferred with plan 45-03.
