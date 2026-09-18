---
phase: 29-fee-transparency
plan: 03
subsystem: testing
tags: [squidrouter, fee-transparency, built_value]
requires:
  - phase: 29-02
    provides: "SwapQuote.feeLines carries each route fee with its own name and amount to the screen"
provides: ["Typed and raw adapter paths proven unable to disagree on fee names/amounts; generic fee mapping proven on multi-entry, unrecognised-name and malformed input"]
affects: [29-04]
actuals: { tokens: 1063, tasks: 2, commits: 3 }
tech-stack: { added: [], patterns: [] }
key-files:
  modified: [test/squid_router/route_wrap_drift_test.dart, test/squid_router/route_fixture.dart, test/swap/squid_quote_mapping_test.dart]
key-decisions:
  - "FEE-02 stays unchecked — no production code shipped this plan; requirement closes at plan 04, per the precedent set in 29-01/29-02."
requirements-completed: []
coverage:
  - id: D1
    description: "The typed and raw adapter paths cannot silently disagree on a fee's name or amount"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_wrap_drift_test.dart#the raw mapper agrees with the generated one where both can read"
        status: pass
    human_judgment: false
  - id: D2
    description: "Multiple fee entries and an unrecognised fee name both map generically, in order"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/swap/squid_quote_mapping_test.dart#three fee entries map to three lines, in order"
        status: pass
      - kind: unit
        ref: "test/swap/squid_quote_mapping_test.dart#a fee name the wire schema does not list still renders verbatim"
        status: pass
    human_judgment: false
  - id: D3
    description: "A malformed fee collection or entry degrades to nothing, never a crash mid-swap"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/swap/squid_quote_mapping_test.dart#a fee collection that is not a list yields no lines, not a crash"
        status: pass
      - kind: unit
        ref: "test/swap/squid_quote_mapping_test.dart#an entry that is not a map is skipped"
        status: pass
      - kind: unit
        ref: "test/swap/squid_quote_mapping_test.dart#an unreadable amount still yields its named line, at zero"
        status: pass
    human_judgment: false
duration: 20min
completed: 2026-09-18
status: complete
---

# Phase 29 Plan 03: Generic mapping coverage Summary

**Typed/raw fee-line parity is now a permanent guard, and a synthetic three-entry body with one unrecognised fee name proves the raw mapper generic — no fabricated fixture added.**

## Accomplishments
- `route_wrap_drift_test.dart`'s existing parity case now asserts fee-line names and amounts match between the typed and raw paths for both real fixtures. Confirmed by temporarily reverting the typed path to the bare `.name` accessor — the new assertion failed as expected, then the revert was undone.
- `syntheticRouteWithFees` added to `route_fixture.dart`: the smallest body `squidQuoteFromJson` accepts, taking a caller-supplied fee list. No live route has two fee entries, so this is the only honest way to exercise multi-entry mapping.
- Five new cases in `squid_quote_mapping_test.dart`: three ordered entries (incl. `Wormhole relayer fee`, a name absent from the wire enum) map to three lines; a non-list `feeCosts` yields no lines; a non-map entry is skipped; an unreadable amount still renders its name at `0.0`.

## Task Commits
1. Task 1: Typed/raw fee-line parity — `bd35725e` (test)
2. Task 2: Synthetic multi-fee mapping — `b947a5e0` (test)
3. Fix: analyzer flagged `avoid_dynamic_calls` in the non-list case — `562d6a7d` (fix)

## Verification
`flutter test test/squid_router/route_wrap_drift_test.dart test/swap/squid_quote_mapping_test.dart`: 17/17 passing. Full `flutter test`: 1370 passed, 5 skipped, 0 failed (baseline 1365 + 5 new). `flutter analyze`: No issues found. `check_brace_style.sh` and `check_raw_colors.sh`: both exit 0. `ls test/squid_router/fixtures/ | wc -l`: 4, unchanged.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Analyzer flagged dynamic calls in a test case**
- **Found during:** Task 2 verification (`flutter analyze`)
- **Issue:** Chained dynamic indexing (`body['route']['estimate']['feeCosts'] = ...`) tripped `avoid_dynamic_calls`
- **Fix:** Cast `route` and `estimate` to `Map<String, dynamic>` before mutating
- **Files modified:** test/swap/squid_quote_mapping_test.dart
- **Committed in:** `562d6a7d`

## Next Phase Readiness
Plan 04 can rely on the parity guard and the synthetic-body helper for its own render tests (e.g. D-05 case-insensitive matching, D-06 empty-case). FEE-02 closes there. No blockers.

---
*Phase: 29-fee-transparency*
*Completed: 2026-09-18*

## Self-Check: PASSED
- FOUND: test/squid_router/route_wrap_drift_test.dart
- FOUND: test/squid_router/route_fixture.dart
- FOUND: test/swap/squid_quote_mapping_test.dart
- FOUND: bd35725e
- FOUND: b947a5e0
- FOUND: 562d6a7d
