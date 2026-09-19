---
phase: 29-fee-transparency
plan: 02
subsystem: swap
tags: [squidrouter, fee-transparency, built_value]
requires:
  - phase: 29-01
    provides: "FeeType.name is the Dart constant; wire label needs standardSerializers.serializeWith"
provides: ["SwapQuote.feeLines carries each route fee with its own name and amount to the screen"]
affects: [29-03, 29-04]
actuals: { tokens: 2230, tasks: 2, commits: 1 }
tech-stack: { added: [], patterns: [] }
key-files:
  modified: [lib/swap/swap_quote.dart, lib/squid_router/squid_swap_provider.dart, lib/squid_router/route_details_card.dart, test/squid_router/route_details_card_test.dart]
key-decisions:
  - "Checkpoint (option-a): the merged cost row is dropped entirely, not relabelled Total cost."
requirements-completed: []
coverage:
  - id: D1
    description: "A cross-chain route's own fee renders as its own row, chain gas as a separate Network gas row, no merged figure survives"
    requirement: "FEE-02"
    verification:
      - kind: unit
        ref: "test/squid_router/route_details_card_test.dart#a second real quote renders itemized fee and gas"
        status: pass
    human_judgment: false
duration: 25min
completed: 2026-09-18
status: complete
---

# Phase 29 Plan 02: End-to-end fee itemization Summary

**One real route fee (`Gas receiver fee`, $0.48) reaches the screen on its own row, chain gas ($0.02) on a separate `Network gas` row, both from the `crossChainRoute` fixture with zero fee arithmetic.**

## Checkpoint Decision
Task 1 (answered pre-run): **option-a** — drop the merged cost row entirely. No "Total cost" row added; a same-chain route still shows gas alone.

## Accomplishments
- `FeeLine` (plain `const` class, `name`/`amountUsd`) added to `swap_quote.dart`; `SwapQuote.feeLines` defaults to `const []`, so `swap_submit_test.dart`'s direct construction stays unbroken.
- `squid_swap_provider.dart` gained `_feeLine`/`_feeLines`/`_feeLinesRaw`, filled at both the typed and raw call sites. The typed path reads the label through `standardSerializers.serializeWith(FeeType.serializer, ...)` per 29-01's finding — never the bare `.name` accessor.
- `route_details_card.dart`'s `_row` helper is now a private `_DetailRow` `StatelessWidget` (reads `GWColors` inside its own `build`, not as a field). The merged `Fees` row is replaced by one row per `feeLines` entry plus a `Network gas` row; no fee-name comparisons anywhere.

## Task Commits
1. Task 1 (checkpoint, pre-answered) — no commit, decision only.
2. Task 2: End-to-end fee itemization — `803717c4` (feat)

## Verification
`flutter test test/squid_router/route_details_card_test.dart test/swap/squid_quote_mapping_test.dart`: 8/8 passing. Full `flutter test`: 1365 passed, 5 skipped, 0 failed. `flutter analyze`: no issues found. `check_brace_style.sh` and `check_raw_colors.sh`: both exit 0. All acceptance-criteria greps (`toAmount -`, hard-coded fee labels, squidrouter import fence, helper-widget count) return clean.

## Deviations from Plan
None - plan executed exactly as written.

## Next Phase Readiness
Plans 03-04 widen coverage (more fixtures, D-05 case-insensitive matching guard, D-06 empty-case tests) on top of this proven path. No blockers.

---
*Phase: 29-fee-transparency*
*Completed: 2026-09-18*

## Self-Check: PASSED
- FOUND: lib/swap/swap_quote.dart
- FOUND: lib/squid_router/squid_swap_provider.dart
- FOUND: lib/squid_router/route_details_card.dart
- FOUND: test/squid_router/route_details_card_test.dart
- FOUND: 803717c4
