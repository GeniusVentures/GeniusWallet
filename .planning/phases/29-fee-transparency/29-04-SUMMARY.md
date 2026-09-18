---
phase: 29-fee-transparency
plan: 04
subsystem: testing
tags: [squidrouter, fee-transparency, wcag]
requires:
  - phase: 29-03
    provides: "syntheticRouteWithFees + squidQuoteFromJson for building a quote without a recorded fixture"
provides: ["Empty-route, fee/gas-distinctness, multi-fee, and both-appearance render coverage for RouteDetailsCard"]
affects: []
actuals: { tokens: 1523, tasks: 2, commits: 2 }
tech-stack: { added: [], patterns: [] }
key-files:
  modified: [test/squid_router/route_details_card_test.dart]
key-decisions:
  - "FEE-02 closes here, per the precedent set in 29-01/29-02/29-03."
requirements-completed: [FEE-02]
coverage:
  - id: D1
    description: "A same-chain route (no fee costs) renders no fee row and no $0.00 line -- the normal case, not an edge case"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#a same-chain route renders no fee row -- the normal case"
        status: pass
    human_judgment: false
  - id: D2
    description: "Fee and gas rows are never merged into one string; a synthetic three-entry body renders three separate rows"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#the route fee and the gas cost stay separately findable, never merged"
        status: pass
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#three fee entries each render as their own row"
        status: pass
    human_judgment: false
  - id: D3
    description: "Fee and gas rows render and clear 4.5:1 contrast in both appearances, with the global flag actually flipped"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#fee and gas rows stay legible in both appearances"
        status: pass
    human_judgment: false
duration: 25min
completed: 2026-09-18
status: complete
---

# Phase 29 Plan 04: Rendering coverage Summary

**Four new widget tests close FEE-02: the empty same-chain case, fee/gas distinctness, a synthetic multi-fee render, and a both-appearance case that flips the global `GWAppearance` flag rather than just constructing `GWColors.light()`.**

## Accomplishments
- `_pumpCard` now delegates to a new `_pumpQuote(tester, SwapQuote)`, so the synthetic three-entry body from plan 03 can be pumped without a fixture file.
- `_host`/pump helpers take an optional `GWColors?`; a new `_gwFor(mode)` flips `GWAppearance.instance.value`, restores dark on teardown, and returns colours built from that flag — avoiding the exact bug this repo shipped once (light instance read under a dark global).
- Both-appearance test asserts the flip took (`surfaceElevated` luminance > 0.5 in light) before checking rows render and clear 4.5:1 contrast, reusing `contrastRatio` from `test/theme/theme_contrast_test.dart` rather than a second implementation.

## Task Commits
1. Task 1: empty case + distinctness + multi-fee render — `f44e773d` (test)
2. Task 2: both-appearance coverage — `12cd2472` (test)

## Deviations from Plan
None - plan executed exactly as written.

## Verification
`flutter test test/squid_router/route_details_card_test.dart`: 7/7 passing (3 pre-existing + 4 new). Full `flutter test`: 1374 passed, 5 skipped, 0 failed (baseline 1370 + 4 new). `flutter analyze`: No issues found. `check_brace_style.sh`/`check_raw_colors.sh`: both exit 0. `grep -c 'GWColors.light()'`: 3. `toAmount -` and `supergenius|gnus.ai-wallet` greps: both empty.

## Next Phase Readiness
Phase 29 (Fee transparency) is fully executed, 4/4 plans. FEE-02 closes. Manual-only item carried to UAT: fee rows at phone width in the running app (not caught at default test surface size).

---
*Phase: 29-fee-transparency*
*Completed: 2026-09-18*

## Self-Check: PASSED
- FOUND: test/squid_router/route_details_card_test.dart
- FOUND: f44e773d
- FOUND: 12cd2472
