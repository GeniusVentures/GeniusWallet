---
phase: 07-token-screens
plan: 04
subsystem: ui
tags: [flutter, token-detail, responsive, breakpoints, convert, read-only, sketch-152]

# Dependency graph
requires:
  - phase: 07-token-screens
    provides: sketch 152 (locked responsive design for token-detail), 07-03 human-walk gap findings 1 and 2
provides:
  - "token_info_screen.dart layout switches desktop/mobile at GeniusBreakpoints.medium (768) instead of .large (1024)"
  - "mobile (<768) Convert card renders directly below the chart, above Info, per sketch 152 D"
  - "Convert 'Token Price' TextField is read-only (display of marketData.currentPrice); only 'Token Amount' is editable"
affects: [07-05, 07-06, 07-07, 07-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "_buildActionSection split into standalone _buildInfoSection/_buildConvertSection helpers so mobile can interleave Convert between the chart and Info while desktop still renders them paired"
    - "Read-only TextField pattern mirrored from bridge_screen.dart:664 (readOnly: true + no onChanged), styled with gw.surfaceSunken fill and a bordered 'READ-ONLY' chip in InputDecoration.label"

key-files:
  created: []
  modified:
    - lib/tokens/token_info_screen.dart

key-decisions:
  - "Reordered the mobile Column to static-actions -> chart -> Convert -> Info per the plan's explicit target order (matches sketch 152 README's D-stack description), not just moving Convert above Info in place"
  - "Used InputDecoration.label (widget) instead of labelText (String) on the price field so a 'READ-ONLY' chip could sit next to the label text, matching sketch 152's .field.ro pattern"

patterns-established:
  - "Read-only display field = readOnly:true + no onChanged + surfaceSunken fill + textPrimary value color (full contrast, not dimmed) — reusable for any future read-only field in this screen family"

requirements-completed: [SCR-03]

coverage:
  - id: D1
    description: "Token-detail layout switches desktop/mobile at 768px (GeniusBreakpoints.medium) instead of 1024"
    requirement: "SCR-03"
    verification:
      - kind: other
        ref: "grep -q \"constraints.maxWidth > GeniusBreakpoints.medium\" lib/tokens/token_info_screen.dart && ! grep -q \"> GeniusBreakpoints.large\" lib/tokens/token_info_screen.dart"
        status: pass
    human_judgment: true
    rationale: "Visual layout correctness at the breakpoint (two-panel at >=768, unified stack at <768) requires human eyes on a real window resize — grep only proves the threshold constant changed, not that the rendered layout looks right. Confirmed by 07-08 human re-walk."
  - id: D2
    description: "Mobile (<768) Convert card renders directly below the chart and above the Info card"
    requirement: "SCR-03"
    verification:
      - kind: other
        ref: "manual code read: token_info_screen.dart mobile Column children order = _buildStaticActions, _buildGraphSection, _buildConvertSection, _buildInfoSection"
        status: pass
    human_judgment: true
    rationale: "Visual stacking order and spacing on a real narrow viewport requires human confirmation — code inspection proves widget order, not rendered appearance. Confirmed by 07-08 human re-walk."
  - id: D3
    description: "Convert 'Token Price' field is read-only display; only 'Token Amount' is editable and still drives the Total"
    requirement: "SCR-03"
    verification:
      - kind: other
        ref: "grep -Eq \"readOnly:\\s*true\" lib/tokens/token_info_screen.dart"
        status: pass
    human_judgment: true
    rationale: "Whether the read-only field is legibly a display (not an active input) and whether typing in it truly does nothing, in both dark and light, requires interactive human verification. Confirmed by 07-08 human re-walk."

duration: 25min
completed: 2026-07-24
status: complete
---

# Phase 07 Plan 04: Token-detail responsive layout + read-only Convert price Summary

**Token-detail page now switches desktop/mobile at 768px (not 1024) with Convert directly below the chart on mobile, and the Convert "Token Price" field is a read-only display — only "Token Amount" is editable.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-07-24T12:43:05Z
- **Tasks:** 2
- **Files modified:** 1

## Accomplishments
- Layout breakpoint changed from `GeniusBreakpoints.large` (1024) to `GeniusBreakpoints.medium` (768), matching sketch 152's locked design and the code's own `ResponsiveDrawer`/`useDesktopLayout` threshold.
- Mobile (<768) stack reordered to: static actions row → chart (carries hero price/% pill) → Convert card → Info card, closing gap 1 from the 07-03 walk.
- Desktop (>=768) two-panel layout unchanged in shape (chart + actions left, Info + Convert right) — only the switch point moved.
- `_buildActionSection` split into standalone `_buildInfoSection`/`_buildConvertSection` helpers, reused by both the desktop paired call and the mobile interleaved calls (no duplicated widget-construction logic).
- Convert "Token Price" TextField is now `readOnly: true` with its `onChanged` price-edit hook removed; styled with a sunken fill (`gw.surfaceSunken`) and a bordered "READ-ONLY" chip next to the label, mirroring `bridge_screen.dart:664`'s read-only pattern. Value text stays full-contrast `gw.textPrimary` for WCAG legibility in both appearance modes.
- "Token Amount" TextField remains fully editable; `onChanged` still recomputes `_totalValue` (Total = price × amount, price fixed), closing gap 2.
- No timeframe tabs added, no invented data fields, chart widget untouched — data-honesty constraints from sketch 152 held.

## Task Commits

Each task was committed atomically:

1. **Task 1: Responsive layout to sketch 152 — switch at 768, Convert below chart on mobile** - `942569f` (fix)
2. **Task 2: Make Convert "Token Price" read-only (only Token Amount editable)** - `2817d2f` (fix)

**Plan metadata:** (this commit)

## Files Created/Modified
- `lib/tokens/token_info_screen.dart` - Layout breakpoint moved to `GeniusBreakpoints.medium`; mobile Column reordered (actions → chart → Convert → Info) via new `_buildInfoSection`/`_buildConvertSection` helpers; Convert's "Token Price" field made read-only with sunken-fill + "READ-ONLY" chip styling.

## Decisions Made
- Followed the plan's explicit target order for the mobile stack (static actions row first, then chart, then Convert, then Info) rather than only moving Convert above Info in the existing composition — this matches both the plan's `<action>` text and sketch 152 README's D-stack description ("identity+price → actions → chart → Convert → Info", where identity+price is folded into the chart's hero).
- Used `InputDecoration.label` (a `Widget`) instead of `labelText` (a `String`) on the read-only price field so the "Token Price" text and a small bordered "READ-ONLY" chip could render together in the label row — no existing helper (e.g. `GWTextField`) supported this, and the plan scoped changes to `token_info_screen.dart` only, so a new shared component was out of scope.

## Deviations from Plan

None — plan executed exactly as written. Both tasks matched their `<action>` instructions and acceptance criteria; no Rule 1-4 fixes were needed.

## Issues Encountered

None.

## User Setup Required

None - no external service configuration required.

## Verification Evidence

- **Grep gate (Task 1):** `grep -q "constraints.maxWidth > GeniusBreakpoints.medium" ... && ! grep -q "> GeniusBreakpoints.large" ...` → `PASS`.
- **Grep gate (Task 2):** `grep -Eq "readOnly:\s*true" lib/tokens/token_info_screen.dart` → `PASS`.
- **`flutter analyze lib/tokens/token_info_screen.dart`:** 4 issues found — all pre-existing `strict_top_level_inference` info-level notices on `_buildStaticActions`'s untyped params (lines 143-146), unrelated to this plan's changes and present identically before this plan's edits (verified via `git stash`). Zero new issues introduced.
- **`bash tool/verify_additive_boundary.sh`:** FAILED on "duplicate public class name census" — but this failure is pre-existing and unrelated to `token_info_screen.dart` (verified via `git stash`: the same six duplicate names — `_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`, `_TimeframeTabState` — fail identically with this plan's changes reverted). Checks 1 (shadow import boundary) and 3 (WIRE- tripwire) both PASS. No regression introduced by this plan.
- **Visual/behavioral truth is NOT settled by this plan** — per the plan's own `<verification>` section, the 07-08 human re-walk is the source of truth for the rendered layout at both breakpoints, the mobile stacking order, and the read-only field's legibility/behavior in dark and light. This SUMMARY documents code-level verification only; `human_judgment: true` is set on all three coverage deliverables above precisely because a human re-walk is still required.

## Known Stubs

None.

## Threat Flags

None — no new network endpoints, auth paths, file access patterns, or schema changes were introduced. This plan only reorders existing widgets and changes a `TextField`'s editability.

## Next Phase Readiness
- `lib/tokens/token_info_screen.dart` is ready for the 07-08 human re-walk to confirm the visual/behavioral truth of both changes (breakpoint switch + read-only price) in dark and light, at both narrow (<768) and wide (>=768) window widths.
- No blockers for 07-05 (crypto_address_qr.dart), 07-06 (responsive_drawer.dart), or 07-07 (More drawer) — this plan touched only `lib/tokens/token_info_screen.dart` and did not modify any file those plans depend on.

---
*Phase: 07-token-screens*
*Completed: 2026-07-24*

## Self-Check: PASSED

- FOUND: `lib/tokens/token_info_screen.dart`
- FOUND: `.planning/phases/07-token-screens/07-04-SUMMARY.md`
- FOUND commit `942569f` (Task 1)
- FOUND commit `2817d2f` (Task 2)
