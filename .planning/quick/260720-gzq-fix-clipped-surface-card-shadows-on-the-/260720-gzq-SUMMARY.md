---
phase: quick
plan: 260720-gzq
subsystem: ui
tags: [flutter, layout, spacing, shadow, gridview, listview]

# Dependency graph
requires:
  - phase: 05-dashboard (05-04)
    provides: markets grid + mobile dashboard screens whose card shadows were found clipped in the walk
provides:
  - Widened markets GridView spacing/padding so elevated surface-card shadows render fully
  - Widened mobile OneColumnDashBoardView ListView padding + inter-section spacing for the same reason
affects: [phase-05-dashboard, todo-2026-07-20-surface-card-shadows-clipped]

tech-stack:
  added: []
  patterns:
    - "Give box-shadow room via layout spacing/padding rather than disabling child Clip.hardEdge"

key-files:
  created: []
  modified:
    - lib/dashboard/chart/markets_screen.dart
    - lib/dashboard/home/view/dashboard_screen.dart

key-decisions:
  - "Used GeniusWalletConsts token values (space6=12, space8=16, space10=20) instead of raw pixel literals, matching the shadow's blurRadius/offset reach"
  - "Left per-card Clip.hardEdge and GWDecorations.surface/GeniusWalletElevation.card untouched — the fix is spacing/padding only, not shadow definition or clip behavior"

patterns-established:
  - "Shadow-clipping fixes: widen crossAxisSpacing/mainAxisSpacing and add viewport padding (GridView), or add ListView padding + inter-section spacing (ListView) — never switch to Clip.none"

requirements-completed: [todo:2026-07-20-surface-card-shadows-clipped]

coverage:
  - id: D1
    description: "Markets grid (desktop): crossAxisSpacing 8->16, mainAxisSpacing 8->20, padding only-bottom-16 -> fromLTRB(16,12,16,20) so every card's soft shadow clears neighbours and viewport edges"
    requirement: "todo:2026-07-20-surface-card-shadows-clipped"
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/dashboard/chart/markets_screen.dart"
        status: pass
    human_judgment: true
    rationale: "Whether the shadow visually renders fully (not sliced) in both light and dark mode is a visual judgment call that flutter analyze cannot verify — requires the blocking human-verify walk (Task 3 of the plan)."
  - id: D2
    description: "Mobile one-column dashboard: ListView padding symmetric(h:16, v:12) added, inter-section spacing 6px->20px so stacked section shadows clear the ListView's Clip.hardEdge and each other"
    requirement: "todo:2026-07-20-surface-card-shadows-clipped"
    verification:
      - kind: automated_ui
        ref: "flutter analyze lib/dashboard/home/view/dashboard_screen.dart"
        status: pass
    human_judgment: true
    rationale: "Whether the shadow visually renders fully (not sliced) at the mobile breakpoint in both light and dark mode is a visual judgment call that flutter analyze cannot verify — requires the blocking human-verify walk (Task 3 of the plan)."

duration: 8min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-gzq: Fix Clipped Surface-Card Shadows Summary

**Widened GridView spacing/padding (markets) and ListView padding/inter-section spacing (mobile dashboard) using GeniusWalletConsts spacing tokens so elevated surface-card shadows (blurRadius 16, offset (0,4)) render fully instead of being sliced by neighbours or viewport clip edges.**

## Performance

- **Duration:** 8 min
- **Started:** 2026-07-20T13:15:00Z (approx.)
- **Completed:** 2026-07-20T13:23:00Z (approx.)
- **Tasks:** 2 of 3 (auto tasks complete; Task 3 is a blocking human-verify checkpoint, not executed by this agent)
- **Files modified:** 2

## Accomplishments
- Markets grid (`markets_screen.dart`): `crossAxisSpacing` 8→`GeniusWalletConsts.space8` (16), `mainAxisSpacing` 8→`GeniusWalletConsts.space10` (20), `GridView` padding `EdgeInsets.only(bottom: 16)` → `EdgeInsets.fromLTRB(space8, space6, space8, space10)` (16/12/16/20).
- Mobile one-column dashboard (`dashboard_screen.dart`, `OneColumnDashBoardView.build`): added `ListView` padding `EdgeInsets.symmetric(horizontal: space8, vertical: space6)` (16/12); changed inter-section `spacing` `SizedBox(height: gridSpacing / 2)` (6px) → `SizedBox(height: GeniusWalletConsts.space10)` (20px).
- Confirmed via diff that `GWDecorations.surface`, `GeniusWalletElevation.card`, `DashboardScrollContainer`, and the desktop `_twoColumnLayout`/`_threeColumnLayout` methods were not touched.

## Task Commits

Each task was committed atomically:

1. **Task 1: Give the markets grid room for the card shadow (spacing + viewport padding)** - `bb172da` (feat)
2. **Task 2: Give the mobile one-column dashboard sections room for their shadows** - `655aa93` (feat)

Task 3 (`checkpoint:human-verify`, gate="blocking") was NOT executed — per plan/orchestrator instructions this agent stops at the blocking walk for a human to perform.

_Plan metadata commit and STATE.md/ROADMAP.md updates are handled by the orchestrator, not this agent (per task instructions: "Do NOT commit docs artifacts or update ROADMAP.md")._

## Files Created/Modified
- `lib/dashboard/chart/markets_screen.dart` - GridView crossAxisSpacing/mainAxisSpacing widened to space8/space10; padding changed to fromLTRB(space8, space6, space8, space10)
- `lib/dashboard/home/view/dashboard_screen.dart` - OneColumnDashBoardView's ListView gained symmetric(horizontal: space8, vertical: space6) padding; inter-section spacing widened from 6px to space10 (20px)

## Decisions Made
- Used `GeniusWalletConsts` token values (space6=12, space8=16, space10=20) rather than raw pixel literals, matching the shadow's blurRadius(16)/offset(0,4) reach as specified in the plan.
- Kept per-card `Clip.hardEdge` and did not touch `GWDecorations.surface`/`GeniusWalletElevation.card` — spacing/padding room is the fix, not the shadow definition or clip behavior.

## Deviations from Plan

None - plan executed exactly as written for both auto tasks.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Outstanding: Blocking Human-Verify Walk

Task 3 of the plan (`checkpoint:human-verify`, `gate="blocking"`) is OUTSTANDING and was deliberately NOT performed by this agent. It requires a human to use the already-running debug build to:

1. **Desktop markets grid** — confirm every grid card's full soft shadow renders (no slicing by neighbours, no viewport-edge cuts) in BOTH light and dark mode, with no console overflow warnings.
2. **Mobile breakpoint (OneColumnDashBoardView)** — resize the window narrow to the single-column layout; confirm all five stacked sections' shadows render fully (no horizontal ListView-edge clipping, no vertical clipping between sections, including first/last section) in BOTH light and dark mode.
3. **Regression check** — widen back to desktop 2-/3-column layout and confirm it is visually unchanged; confirm no new RenderFlex overflow banners at any width in either mode.

Resume signal: "approved", or a description of what still clips / what regressed.

## Next Phase Readiness
- Both source-code changes are committed (`bb172da`, `655aa93`) and `flutter analyze` is clean on both files.
- Not ready to close the todo (`.planning/todos/pending/2026-07-20-surface-card-shadows-clipped.md`) until the human-verify walk above is approved.

---
*Quick task: 260720-gzq*
*Completed: 2026-07-20 (auto tasks only; walk pending)*

## Self-Check: PASSED

- FOUND: lib/dashboard/chart/markets_screen.dart
- FOUND: lib/dashboard/home/view/dashboard_screen.dart
- FOUND: .planning/quick/260720-gzq-fix-clipped-surface-card-shadows-on-the-/260720-gzq-SUMMARY.md
- FOUND commit: bb172da
- FOUND commit: 655aa93
