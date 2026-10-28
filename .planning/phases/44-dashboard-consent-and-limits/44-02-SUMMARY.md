---
phase: 44-dashboard-consent-and-limits
plan: 02
subsystem: gnus-bridge
tags: [consent, drawer, spend]
requires: [44-01]
provides: [showGnusSpendConfirm, self-closing prompts]
affects: [lib/main.dart]
key-files:
  modified: [lib/gnus_consent/gnus_prompts.dart, lib/main.dart]
status: complete
actuals: {tokens: 45000, tasks: 2, commits: 2}
---

# Phase 44 Plan 02: Spend confirm Summary

Every `gnus_submitJob` that reaches the confirm opens a drawer naming the site, the cost in GNUS, bridge gas, paying wallet and earning account; the app now wires it, replacing the rejecting default.

## Commits
- 4f861fde `showGnusSpendConfirm`, the self-closing wrapper, 12 prompt tests
- ab12bc17 `confirm: showGnusSpendConfirm` in `main.dart`, guard updated, end-to-end Reject and Approve

## Results
- `test/gnus_consent`: 15 passed (3 before). `test/gnus_bridge` + `test/gnus_consent`: 214 passed.
- Reject, a barrier tap and Escape each answer false; Reject through the handler answers 4001 with no burn and no intent. Approve burns once.
- Both prompts close at `kGnusConfirmTimeout` with `Navigator.removeRoute`, also under a route pushed on top.
- `textContrastGuideline` passes for both prompts in dark and light.

## Decisions
- A cost that is negative or does not parse declines without showing a drawer.
- Addresses use `GWCopyRow`: shown shortened, copied whole. The origin is whole on the wrapping site line.

## Deviations
None.

## Known Stubs
None.

## Self-Check: PASSED
