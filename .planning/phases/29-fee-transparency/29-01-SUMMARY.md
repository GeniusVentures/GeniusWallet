---
phase: 29-fee-transparency
plan: 01
subsystem: testing
tags: [built_value, squidrouter, fee-type, serializer]
requires: []
provides: ["FeeType.name is the Dart constant; wire label needs standardSerializers.serializeWith(FeeType.serializer, ...)"]
affects: [29-02, 29-03, 29-04]
actuals: { tokens: 207, tasks: 1, commits: 1 }
tech-stack: { added: [], patterns: [] }
key-files:
  modified: [test/squid_router/route_wrap_drift_test.dart]
key-decisions:
  - "FEE-02 left unchecked — no production code shipped; requirement closes at plan 04."
requirements-completed: []
coverage:
  - id: D1
    description: "FeeType.name yields the Dart constant, not the wire label; label only reachable via the built_value serializer"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_wrap_drift_test.dart#the generated fee enum hides the wire name behind its serializer"
        status: pass
    human_judgment: false
duration: 12min
completed: 2026-09-18
status: complete
---

# Phase 29 Plan 01: Fee enum name vs wire label Summary

**Proved by running assertion: `FeeType.GAS_RECEIVER_FEE.name` is `'GAS_RECEIVER_FEE'`; the human label `'Gas receiver fee'` only reaches you through `standardSerializers.serializeWith(FeeType.serializer, ...)`.**

## Accomplishments
- Settled the phase's one open unknown before any mapper is written: the typed adapter path must
  go through the serializer, never the bare `.name` accessor, to reach the wire label.
- Confirmed with an executed test, not inference from generated source.

## Task Commits
1. **Task 1: Pin how the generated enum exposes a fee name** - `7e2253ad` (test)

## Files Modified
- `test/squid_router/route_wrap_drift_test.dart` - new case, 7/7 tests passing

## Decisions Made
FEE-02's checkbox stays unchecked — this plan ships no production code, only answers a
precondition; marking it complete now would misrepresent progress before plans 02-04 land.

## Deviations from Plan
None - plan executed exactly as written.

## Next Phase Readiness
Plan 02's adapter can call the serializer against a proven fact, not an assumption. No blockers.

---
*Phase: 29-fee-transparency*
*Completed: 2026-09-18*

## Self-Check: PASSED
- FOUND: test/squid_router/route_wrap_drift_test.dart
- FOUND: .planning/phases/29-fee-transparency/29-01-SUMMARY.md
- FOUND: 7e2253ad
