---
phase: 46-in-wallet-dashboard-screen
plan: 02
subsystem: gnus-bridge
tags: [dashboard, states, dialogs, a11y, dev-tools]
requires: [46-01 GnusDashboardScreen]
provides: [GWNotice, loading/failed/no-bridge states, Close and Reload, Linux popup gate, dev Hosted switch]
status: complete
actuals: {tokens: 40000, tasks: 3, commits: 4}
key-files:
  created: [lib/components/gw_notice.dart]
  modified: [lib/gnus_bridge/gnus_dashboard_screen.dart, lib/gnus_bridge/gnus_bridge_view_linux.dart, lib/banxa/checkout/checkout_screen.dart, lib/dev/dev_gnus_bridge.dart, lib/dev/dev_tools_bubble.dart]
---

# Phase 46 Plan 02: Screen states, chrome and Hosted switch

Checkout's notice moved unchanged to `GWNotice` (own refactor commit, `test/banxa` 269 green) before the screen used it.
The host builder now takes `onLoaded`, `onFailed` and `onNoBridge`. A failed or no-bridge state replaces the host
(it is disposed, not stacked), so the Linux page cannot paint over it. Try again and Reload bump a key: fresh page,
fresh bridge session. Close pops, or goes to `/dashboard` when nothing can pop. On Linux the host sits in
`WebOverlayGate`. The Linux view gained optional `onPageFinished` and `onLoadFailed` (main-frame errors only).

## Verification
- `flutter test test/gnus_bridge test/dev test/banxa`: all green; `flutter analyze lib test` exit 0; format and brace checks exit 0.
- Mutation: replacing the Linux gate condition with `false` fails the Linux dialog test. Restored.
- Contrast and tap-target guidelines pass on the loading, loaded and failed screens in light and dark.
- Tested: bar and its live region, failed copy and live region, Try again and Reload fresh host on the same start,
  unreadable network fails the screen, no-bridge notice and Open in browser, Close with and without PopScope,
  dialog hides Linux only, header, labels, Hosted rows (dev and release, switch on and off).
- Live Linux behaviour of these states: pending (46-03 walk skipped by request).

## Deviations
- `GWNotice` gained an additive `liveRegion` flag (merges title and message into one live node); checkout does not use it.
- Not tested: that a sub-frame error is ignored. The filter is `isForMainFrame == true` in the Linux view, and the repo has
  no fake `WebViewPlatform`. Whether a navigation the lock blocks also raises a main-frame error on WebKitGTK is unknown until the walk.
- The Hosted switch sits above the button wrap, not inside it: `GWSwitch` with a label needs a bounded width.
- An unreadable network (`readNet` throws) is treated as a load failure (failed notice), which the plan did not specify.

## Known stubs
None.
