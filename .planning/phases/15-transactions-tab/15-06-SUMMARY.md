---
phase: 15-transactions-tab
plan: 06
subsystem: dashboard/transactions
tags: [transactions-tab, filter-rail, empty-state, amount-honesty, human-walk, dark-only]
type: checkpoint:human-verify
requires:
  - "15-01 (amount honesty strings)"
  - "15-02 (anchored GWEmptyState, maxHeight 480)"
  - "15-03 (sync_alt never-transacted icon + filter hidden when nothing to filter)"
  - "15-04 (filter rail, 022-B2 active mark)"
  - "15-05 (page frame, unified xxl cap)"
provides:
  - "observed DARK verdict for TT-01..TT-06 - the gate that closes Phase 15"
affects: []
key-files:
  modified: []
walk:
  date: 2026-07-24
  walker: Jakub
  build: flutter run -d macos --dart-define=GW_DEV_TOOLS=true (Flutter 3.41.9)
  mode: DARK ONLY (light deferred to the app-wide light pass)
  fixture: dev-bubble MOCK "Mock txns" (extended batch) and "Clear" (never-transacted)
decisions:
  - "022-B2 active mark (bold-white label + 2px word-width gradient rule, glyph untouched) APPROVED as loud enough in the live rail - the one thing sketch 022 said only the live app could settle. Variant D (regild the label) NOT needed."
  - "Light NOT walked (Jakub's standing dark-first call). Recorded as deferred, not passed."
status: complete
---

# Phase 15 Plan 06: Transactions-tab walk - Summary

The redesigned `/transactions` page was walked on a real macOS screen with the extended mock
batch, in dark, at wide and narrow widths and short heights, across the page and the dashboard
panel and the shared-component call sites. **All three checkpoints APPROVED, no defects.**

**No commits created.** `./CLAUDE.md` holds the commit gate.

## Precondition (Task 1)

- Scoped `flutter analyze lib/dashboard/transactions lib/dashboard/home/widgets lib/components/feedback` = **"No issues found!"** (clean).
- `flutter analyze lib` = 61, at baseline (delta 0).
- `flutter test` deferred (app holds the Hive lock; a parallel run collides). Non-blocking.

## Console evidence (dark walk)

Zero `RenderFlex overflowed`, zero `EXCEPTION CAUGHT`, zero HardwareKeyboard assertions across
Checkpoints A and B. (One mid-walk `Lost connection to device` was a clean window close, no crash
signature.)

## Per-criterion verdict (TT-01..TT-06)

| Req | What | Verdict | Evidence |
|-----|------|---------|----------|
| TT-01 | Page frame (one 24px title, two cards, unified cap) | **PASS** (dark) | A1/A2 - single page title, rail+list as separate cards, content caps at the unified ~1536 frame (NOT the retired 740) |
| TT-02 | Filter rail (order + live counts) | **PASS** (dark) | A2/A3 - All + Type(7) + Status(2) in order, each with a count, All = total, no footer count |
| TT-03 | Rail states (active mark, hover, counts, no-toggle) | **PASS** (dark) | A4-A8 - hover lift reads as one control; active = bold-white label + 2px gradient rule, glyph unchanged; active row ignores hover fill; counts stable under filtering; re-click stays active. Loudness judged sufficient live (022-B2 holds) |
| TT-04 | Empty-state anchor (upper portion, 480 cap only in tall slot) | **PASS** (dark) | B1/B5 - never-transacted sits in the upper quarter on the tall page; dashboard short-slot behaviour unchanged |
| TT-05 | Empty icon + filter hidden when nothing to filter | **PASS** (dark) | B1 - sync_alt icon, no rail/chips/`⋯` on an empty wallet; filtered-empty keeps the rail + "Show all"; the two states read as different situations |
| TT-06 | Amount honesty (job / failed / cancelled as sentences) | **PASS** (dark) | C1-C7 - job prints a real negative fee at full weight; failed/cancelled print the real signed amount quietly with `Not charged`; no em dash in any amount column; dashboard panel (no Status column) still reads from amount+context; drawer does not contradict the row |

All six criteria **observed** in dark. None marked PASS on analyze/unit-test strength alone.
Shared-component blast radius (Assets panel, Markets card compact tier, design gallery) walked
under Checkpoint B with no regressions.

## Light mode - DEFERRED (recorded, not a pass)

Not walked, per the standing dark-first policy and
`.planning/todos/pending/2026-07-22-light-mode-verification-backlog.md`. Carried to the dedicated
light pass, element by element, UNVERIFIED: rail rest/active/gradient in light; empty-state
contrast; amount-honesty grey (`textSecondary`) legibility in light.

## Walk-driven fixes

None. All three dark checkpoints passed clean.

## Session note (not a Phase 15 defect)

A parallel session was building/running the app in the same tree during this walk; one executor
relaunch failed on an Xcode `build.db` lock ("two concurrent builds"). The walk was completed on
the already-running instance (same on-disk code). Flagged as the parallel-session build collision
`./CLAUDE.md` warns about, not a phase defect.
