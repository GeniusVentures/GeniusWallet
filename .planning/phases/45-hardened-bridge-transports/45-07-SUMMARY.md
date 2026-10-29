---
phase: 45-hardened-bridge-transports
plan: 07
subsystem: gnus-bridge
status: complete
actuals: {tokens: 3000, tasks: 2, commits: 1}
---

# Phase 45 Plan 07: Gate and verification matrix

Gate on the phase head: `dart format --set-exit-if-changed` exit 0; `flutter analyze lib test packages/genius_api` exit 0;
`flutter test` 3056 passed, 10 skipped, 0 failed (baseline 2998/10/0, +58 new); brace, raw-colour and key-logging
`--scan-tree` checks exit 0. No `45-0x` or "Phase 45" text in source. Release gate: the route exists only under
`kDebugMode && kShowDevTools` and the screen builds a view only under the same test, so a release build has none.
`git ls-files --eol lib test` lists two CRLF files (`gw_hoverable_test`, `theme_contrast_test`); both predate the phase.

Legend: T test, B build, W walk, P pending, X blocked. Tests: `wb` gnus_web_bridge_test, `or` gnus_dashboard_origins_test,
`ch` gnus_native_bridge_channel_test. Linux native build and walk were skipped by request (45-03), so no Linux cell is a walk.

| Row | Linux | Windows | Android | iOS | macOS |
|---|---|---|---|---|---|
| SC1 top frame only | T wb secret check; W P (45-03) | T wb secret check; frames W P | T ch malformed; Kotlin `!isMainFrame` B only, W P (48) | T ch; Swift not compiled; W X | T ch; Swift not compiled; W P |
| SC2 off-list gets 4100 | T wb off-list source; W P | T wb; `get_Source` B only | T ch off-list source; W P (48) | T ch; W X | T ch; W P |
| SC3 reply dropped | T wb page-moved group; W P | T wb; W P | T wb; W P (48) | T wb; W X | T wb; W P |
| SC4 builds | P: native build not run (45-03) | B debug exe, exit 0 | B Kotlin compile exit 0; APK P (PR CI) | P: VM unreachable | P: VM unreachable |
| Allowlist | T or | T or | T or; Kotlin rules B | T or | T or |
| Nav lock, popups | T or table; native flag unbuilt, W P | T or table; `NavigationStarting` B only | T or table; webview_flutter popups W P (48) | T or table; W X | T or table; W P |
| UA marker | T wb suffix; W P | T wb suffix; apply path B only | T wb suffix; W P (48) | T wb suffix; W X | T wb suffix; W P |
| Events via eventsFor | T wb events group; W P | T wb events | T wb events; W P (48) | T wb events; W X | T wb events; W P |

Deliberate Linux differences: frame posts stop at the secret check in Dart; cross-origin iframes do not load (about:blank and about:srcdoc do); origin is the tracked top-level URL.
Open for phase 46: the pinned origin is still `https://gnus-dashboard-staging.invalid`.
Open for phase 48: Android, iOS and macOS walks; a CI debug APK with the dev route; the Linux build and walk (45-03) and the VM builds.
Contract section 2: Android, iOS and macOS now inject at document start; the "after page start" line is stale.
REQUIREMENTS: DWV-02 and DWV-03 delivered in code; the DWV-01 shim timing and UA, and the DWV-04 allowlist, lock and popups, are delivered for the dev route only.
Changed tests: `gnus_rpc_guards_test` now lets `gnus_bridge_view_*.dart` import Flutter UI; `dev_gnus_bridge_test` expects a sixth button.
