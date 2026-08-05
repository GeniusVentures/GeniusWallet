---
phase: quick-260720-ipg
plan: 01
subsystem: ui
tags: [flutter, design-system, typography, page-header]

requires: []
provides:
  - "GWPageHeader shared in-body page-title component (lib/components/scaffold/gw_page_header.dart)"
  - "Markets/News/Swap in-body titles unified onto GWPageHeader"
affects: [dashboard, squid_router, ui-redesign-port]

tech-stack:
  added: []
  patterns:
    - "GWPageHeader: left-aligned headlineLg/gw.textPrimary title + optional trailing action via Spacer + header-owned space8 bottom gap"

key-files:
  created:
    - lib/components/scaffold/gw_page_header.dart
  modified:
    - lib/dashboard/chart/markets_screen.dart
    - lib/dashboard/news/view/crypto_news_screen.dart
    - lib/squid_router/swap_screen.dart

key-decisions:
  - "GWPageHeader placed in lib/components/scaffold/ next to gw_screen.dart (screen-level layout primitive, same family)"

patterns-established:
  - "GWPageHeader: header owns its own bottom gap (space8); migrated screens drop their own spacer to avoid double gaps"

requirements-completed: []

coverage:
  - id: D1
    description: "GWPageHeader component created (left-aligned headlineLg/gw.textPrimary title + optional trailing + space8 gap)"
    verification:
      - kind: other
        ref: "flutter analyze lib/components/scaffold/gw_page_header.dart -- 0 issues"
        status: pass
    human_judgment: false
  - id: D2
    description: "Markets, News, Swap in-body titles migrated onto GWPageHeader (unified size/weight/alignment, trailing IconButtons preserved verbatim, double-gaps reconciled)"
    verification:
      - kind: other
        ref: "flutter analyze lib/dashboard/chart/markets_screen.dart lib/dashboard/news/view/crypto_news_screen.dart lib/squid_router/swap_screen.dart -- 0 issues"
        status: pass
    human_judgment: true
    rationale: "Visual consistency (size/weight/alignment/spacing) and both-mode legibility can only be judged by a human looking at the running app; the blocking human-verify walk task in the plan is OUTSTANDING."

duration: 12min
completed: 2026-07-20
status: complete
---

# Quick Task 260720-ipg: Shared GWPageHeader Summary

**New GWPageHeader component unifies Markets/News/Swap in-body page titles onto headlineLg/gw.textPrimary, left-aligned, with a single header-owned bottom gap.**

## Performance

- **Duration:** 12 min
- **Started:** 2026-07-20T16:22:00Z
- **Completed:** 2026-07-20T16:34:00Z
- **Tasks:** 2 of 3 (both `type="auto"` tasks complete; Task 3 is a blocking human-verify checkpoint, OUTSTANDING)
- **Files modified:** 4 (1 created, 3 modified)

## Accomplishments
- Added `GWPageHeader` — a shared in-body page-title header (left-aligned `headlineLg`/`gw.textPrimary` title, optional trailing action via `Spacer`, header-owned `space8` bottom gap, fail-soft `GWColors` theme-extension read for live appearance-toggle support).
- Migrated Markets' title `Row` (Text + search `IconButton`) onto `GWPageHeader`, dropping the now-redundant `Column(spacing: 16.0)` (header owns the gap).
- Migrated News' `Text('Crypto News', style: Theme.of(context).textTheme.displaySmall)` + `SizedBox(height: 24)` onto `GWPageHeader(title: 'Crypto News')` (no trailing) — removes the unmapped-`displaySmall` oversized-title outlier.
- Migrated Swap's raw centered `Colors.white` title `Row` (balance `SizedBox` + `Center` + settings `IconButton`) onto `GWPageHeader(title: 'Swap', trailing: ...)` — title is now left-aligned and tokenized; dropped the redundant trailing `SizedBox(height: 16)`.
- All three original trailing `IconButton.onPressed` handlers (Markets search drawer, Swap settings drawer) preserved verbatim, byte-for-byte.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Create the shared GWPageHeader component** - `ce0679b` (feat)
2. **Task 2: Migrate Markets, News, and Swap titles onto GWPageHeader** - `905a2a9` (feat)

Task 3 (`checkpoint:human-verify`, gate="blocking") was NOT executed — execution stopped there per plan instructions. No plan-metadata commit has been made (docs/state updates deferred to the orchestrator).

## Files Created/Modified
- `lib/components/scaffold/gw_page_header.dart` - New shared GWPageHeader StatelessWidget
- `lib/dashboard/chart/markets_screen.dart` - Title Row -> GWPageHeader; dropped Column spacing:16.0
- `lib/dashboard/news/view/crypto_news_screen.dart` - displaySmall Text + SizedBox(24) -> GWPageHeader
- `lib/squid_router/swap_screen.dart` - Raw white centered title Row -> GWPageHeader; dropped trailing SizedBox(16)

## Decisions Made
- GWPageHeader placed in `lib/components/scaffold/` beside `gw_screen.dart` (same family of screen-level layout primitives), not in a new `headers/` directory.
- Swap's trailing `IconButton`'s icon `color: Colors.white` argument was kept exactly as it was (plan-specified: only the title text is retokenized, the passed-through trailing widget is otherwise unchanged).

## Deviations from Plan

None - plan executed exactly as written for both auto tasks. One trivial lint (`use_null_aware_elements`, info-level, not a plan deviation) was cleaned up in `gw_page_header.dart` by using `?trailing` instead of `if (trailing != null) trailing!` in the children list — same behavior, cleaner idiom, still 0 raw-color/hex/px violations.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Next Phase Readiness

Code changes are complete and `flutter analyze` is clean (0 issues) across all four files. **The blocking human-verify walk (plan Task 3) is OUTSTANDING** — a human must, on the already-running debug build, using the dev-tools bubble's light/dark toggle:

1. Navigate to Markets, News, and Swap and confirm all three titles render at the same size/weight (24/semibold), left-aligned (News no longer oversized, Swap no longer centered).
2. Confirm a single consistent gap below each title (no double gap, no cramped title).
3. Markets: tap the search icon — "Search Coins" drawer still opens and search works.
4. Swap: tap the settings/tune icon — the slippage settings drawer still opens and works.
5. Repeat 1-4 in LIGHT mode (all titles legible dark-on-light, no white-on-white).
6. Flip back to DARK and confirm titles are legible light-on-dark.

Until this walk is approved, this quick task is not fully done — only its two automated code tasks are.

---
*Quick task: 260720-ipg*
*Completed (code tasks): 2026-07-20*

## Self-Check: PASSED

- FOUND: lib/components/scaffold/gw_page_header.dart
- FOUND: lib/dashboard/chart/markets_screen.dart
- FOUND: lib/dashboard/news/view/crypto_news_screen.dart
- FOUND: lib/squid_router/swap_screen.dart
- FOUND: .planning/quick/260720-ipg-add-a-shared-gwpageheader-and-unify-the-/260720-ipg-SUMMARY.md
- FOUND commit: ce0679b (Task 1)
- FOUND commit: 905a2a9 (Task 2)
