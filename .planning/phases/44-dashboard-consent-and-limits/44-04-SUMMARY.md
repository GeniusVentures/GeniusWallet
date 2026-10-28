---
phase: 44-dashboard-consent-and-limits
plan: 04
subsystem: settings
tags: [consent, settings, revoke]
requires: [44-01]
provides: [ConnectedSitesCubit, ConnectedSitesSection, Settings card]
affects: [lib/settings/settings_screen.dart]
key-files:
  created: [lib/settings/connected_sites_cubit.dart, lib/settings/connected_sites_section.dart, test/settings/connected_sites_test.dart]
  modified: [lib/settings/settings_screen.dart]
status: complete
actuals: {tokens: 35000, tasks: 2, commits: 2}
---

# Phase 44 Plan 04: Connected sites in Settings Summary

Every user sees a "Connected sites" card in Settings with one row per origin, the time it connected and a Revoke button; revoking makes that origin prompt again.

## Commits
- dff49ad9 cubit, section widgets and 7 tests
- 76efb042 the card below Advanced, outside the developer-mode block, and a screen test

## Results
- `test/settings`: 22 passed, including 8 new in `connected_sites_test.dart`.
- A handler over the same store records a second connect after Revoke.
- `textContrastGuideline` and `labeledTapTargetGuideline` pass in dark and light; the Revoke button's label names its origin.
- `SettingsScreen` is pumped for real with a faked `GeniusApi` and a seeded store, so no source-text fallback was needed.

## Decisions
- Widget to cubit to store; no Hive in `lib/settings`. The cubit also re-reads after its own revoke so the row goes at once.
- No confirmation dialog and no revoke-all.
- In tests, a handler that must share a runAsync zone with the store is built inside `tester.runAsync`; built outside, its first call deadlocked.

## Deviations
None.

## Known Stubs
None.

## Self-Check: PASSED
