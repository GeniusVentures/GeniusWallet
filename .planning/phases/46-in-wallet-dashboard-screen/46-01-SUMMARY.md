---
phase: 46-in-wallet-dashboard-screen
plan: 01
subsystem: gnus-bridge
tags: [dashboard, route, entry, linux]
requires: [phase 45 bridge views and gnusAllowedOrigins]
provides: [GnusDashboardScreen, openGnusDashboard, gnusBridgeHostKind, gnusDashboardStart, gnusDashboardListed, /gnus-dashboard]
status: complete
actuals: {tokens: 24000, tasks: 3, commits: 3}
key-files:
  created: [lib/gnus_bridge/gnus_dashboard_screen.dart, test/gnus_bridge/gnus_dashboard_screen_test.dart]
  modified: [lib/gnus_bridge/gnus_dashboard_origins.dart, lib/navigation/router.dart, lib/dashboard/compute/compute_panel.dart, lib/components/wallet_overview.dart]
---

# Phase 46 Plan 01: Entry, route and start rules

"Jobs and earnings" on the Earning panel pushes `/gnus-dashboard`, a root-level screen that resolves the start from
the network and build mode and hands it to the platform's bridge view. The route reads no `state.extra` or `state.uri`
(a test greps for it). Without in-app web (Linux, no WebKitGTK) the entry launches the start in the system browser.

## Baseline (before the first change)
`flutter test`: 3056 passed, 10 skipped, 0 failed.

## Verification
- `flutter test test/gnus_bridge test/dashboard test/theme`: 1013 passed, 0 failed.
- `flutter analyze lib test` exit 0; `dart format --set-exit-if-changed lib test` exit 0; brace check exit 0.
- Mutation: `gnusDashboardStart` ignoring `hosted` fails 1 origins test (dev and hosted gives the pinned origin). Restored.
- Contrast and tap-target guidelines pass on the entry in light and dark (panel in the `ready` state, where the CTA is enabled).
- Live proof on the Linux rig: pending (46-03 walk skipped by request; one combined walk for phases 45-47 later).

## Deviations
- [Rule 3] `gnus_rpc_guards_test` forbade Flutter UI under `lib/gnus_bridge` except the platform views. It now also
  exempts `gnus_dashboard_screen.dart`; the handler, stores and session stay UI-free.
- [Rule 1] The entry overflowed by 174 px at 320 px and 1.3x text. The trailing is now a `Flexible` at the call site, so
  the label shortens; `GWSectionTitle` is untouched.
- `wallet_overview` gates the entry on `gnusDashboardListed` in the first commit, not the second, so no commit lists a
  release entry that can only fail. `openGnusDashboard` returns a `Future` (the browser path awaits the network).
- The unlisted check covers `ComputePanel` with a null callback; the `wallet_overview` conditional has no test.

Known stubs: none. A release build lists no entry while the pinned origin is `.invalid` (D-05).
