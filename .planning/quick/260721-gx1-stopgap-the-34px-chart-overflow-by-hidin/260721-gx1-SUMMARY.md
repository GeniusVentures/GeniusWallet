---
quick_id: 260721-gx1
status: abandoned
abandoned: 2026-07-21T00:00:00.000Z
files_modified: []
one_liner: >-
  Planned stopgap (hide the chart's zoom/pan Row below a 112px slot threshold) — ABANDONED before
  execution by explicit user decision; recorded as a Phase 5 override instead.
---

# Quick 260721-gx1: Stopgap the 34px chart overflow — ABANDONED

## What happened

This quick task was **planned in full** (see `260721-gx1-PLAN.md` in this directory) but was
**never executed**. Zero lines of `lib/`, `test/`, or any other source changed as a result of this
task. `files_modified` above is empty and accurate.

The plan proposed hiding the Bitcoin Chart card's zoom/pan `IconButton` row whenever its slot falls
below a derived `zoomPanMinSlotHeight = 112px` (64px minimum chart + 48px row,
`kMinInteractiveDimension`), via a `LayoutBuilder` + a pure `showZoomPanControls(double)` predicate
on `CryptoLiveChartState`, backed by two tests (the predicate's boundaries, and a widget test
proving 48px is a real upper bound on the rendered `IconButton` height under both compact and
standard `VisualDensity`).

## Why it was abandoned

The user inspected the running app directly on 2026-07-21 and rejected the stopgap outright:

> "it's just that the current size of the app being opened it does not have space for the bitcoin
> chart, we may want to drop that size, but again that is a todo item for later, let's close the
> phase 5 and set it as valid and continue."

The plan's own text had already named the honest cost of what it was about to do: hiding the row
would clear the `RenderFlex overflowed` console line, but on the dashboard's measured 6.5px slot the
card would still render nothing but a chart hairline underneath the header — "a non-overflowing
broken card, not a fixed one." That is a worse outcome than the visible failure it would replace: it
converts an honest, walk-detectable defect into a cosmetically clean one that still delivers nothing
useful. The user's own read of the running app confirmed the plan's own risk assessment and chose
not to take it.

**Disposition instead:** the 34px overflow is recorded as an explicit, user-authorized override in
`05-VERIFICATION.md` (frontmatter `overrides:` block + `## Acknowledged Gaps` section), not hidden
by a layout patch. The actual root cause — the dashboard's Bitcoin Chart card has no vertical budget
at the app's ordinary window size — is filed as its own todo:
`.planning/todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`. The
original chart-overflow todo
(`.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md`) was updated in place to
record this outcome, without disturbing its own three-way convergence analysis.

## What should not be lost from this plan

The planning work in `260721-gx1-PLAN.md` is genuinely good analysis and is preserved verbatim in
that file (not deleted, not rewritten) for reuse if the product decision ever goes the other way:

- The precise threshold derivation (`64` chart floor + `48` density-independent `IconButton` box =
  `112`), including why `48` and not the observed `~40` (ambient desktop `VisualDensity.compact`
  subtracts 8 — the same effect quick `260721-ed9` measured on `navChipShell`).
- The two call-site comparison (`dashboard_screen.dart` below threshold vs.
  `token_info_screen.dart:130` comfortably above it), which is the same evidence that grounds the
  new root-cause todo.
- The explicit rejection of `ClipRect` as a "fix" — clipping would hide already-lost content rather
  than surface it, which is the same reasoning that led to abandoning the whole stopgap once the
  user weighed in.
- The three-way convergence this file's own reasoning pointed at (this overflow + the raw
  `Colors.white` icons + the zoom/pan-redundancy question) — still live, still tracked, still the
  likely eventual answer if the row is deleted rather than resized around.

If a future plan revisits "does zoom/pan survive," this plan's threshold math and test design are a
ready-made starting point and should be reused rather than re-derived.

## Verification

Not applicable — no code changed. `git status` / `git diff` show zero touched files under `lib/` or
`test/` attributable to this task.

## Self-Check: PASSED

- `260721-gx1-PLAN.md` exists in this directory (pre-existing, unmodified): CONFIRMED
- No `lib/chart/crypto_live_chart.dart` changes: CONFIRMED (file untouched by this task)
- No `test/chart/crypto_live_chart_layout_test.dart`: CONFIRMED (never created)
- `.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` updated in place, still
  in `todos/pending/`: CONFIRMED
