---
phase: 02-design-tokens-verification-loop
plan: 01
subsystem: ui
tags: [flutter, hive, google_fonts, appearance, design-tokens]

# Dependency graph
requires: []
provides:
  - google_fonts pubspec dependency (^6.2.1, resolved 6.3.3)
  - preferencesBoxName / appearanceModeKey Hive constants
  - preferences Hive box opened at initHive()
  - GWAppearance singleton (lib/theme/gw_appearance.dart)
affects: [02-03 (token blocks), 02-04 (typography files), 02-05 (probe surface)]

# Tech tracking
tech-stack:
  added: [google_fonts ^6.2.1]
  patterns: [ValueNotifier-based appearance singleton, additive-only Hive box constants]

key-files:
  created: [lib/theme/gw_appearance.dart]
  modified: [pubspec.yaml, pubspec.lock, lib/hive/constants/cache.dart, lib/hive/init.dart]

key-decisions:
  - "google_fonts inserted next to go_router in pubspec.yaml (its nearest alphabetical neighbor) — the existing dependency block is not itself alphabetically sorted, so exact 'alphabetical position' per the plan wording was interpreted as closest-neighbor placement, not a full resort."
  - "gw_appearance.dart ported verbatim except the single Hive import line, per plan spec: hive_ce_flutter/hive_flutter.dart instead of classic hive_flutter."

patterns-established:
  - "GWAppearance.instance: ValueNotifier<GWAppearanceMode> singleton, defaults dark, persists via Hive.box(preferencesBoxName) — future phases wire this into main.dart/theme.dart (Phase 4), not this phase."

requirements-completed: [DS-01]

coverage:
  - id: D1
    description: "google_fonts ^6.2.1 dependency declared and resolved (6.3.3), pubspec.lock committed"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "flutter pub get; grep google_fonts pubspec.lock"
        status: pass
    human_judgment: false
  - id: D2
    description: "preferencesBoxName/appearanceModeKey Hive constants added; preferences box opened in initHive() before Transactions adapter cascade"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "grep checks (cache.dart, init.dart); flutter analyze lib/hive (0 errors)"
        status: pass
    human_judgment: false
  - id: D3
    description: "GWAppearance singleton compiles against hive_ce_flutter, defaults to dark, exposes load()/setMode()/isLight"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "flutter analyze lib (0 errors); grep import/enum checks"
        status: pass
    human_judgment: false
  - id: D4
    description: "App builds and runs from the standing debug recipe with zero observable visual change on every existing screen; preferences box opens without throwing at startup"
    requirement: "DS-01"
    verification: []
    human_judgment: true
    rationale: "Requires launching the Windows debug build and visually walking screens — an interactive GUI check this agent cannot perform. The user has their own debug session running with hot reload; a pubspec change (Task 1) requires a full restart, not hot reload, to pick up google_fonts and exercise the new Hive box open. Deferred to the user's next restart."

# Metrics
duration: ~10min
completed: 2026-07-16
status: complete
---

# Phase 2 Plan 1: Design Tokens Substrate Summary

**GWAppearance singleton with Hive-persisted dark/light mode, preferences Hive box, and google_fonts ^6.2.1 dependency — all additive, zero existing screen touched.**

## Performance

- **Duration:** ~10 min
- **Completed:** 2026-07-16T14:29:44Z
- **Tasks:** 3/3 completed
- **Files modified:** 4 (1 created, 4 touched: pubspec.yaml, pubspec.lock, lib/hive/constants/cache.dart, lib/hive/init.dart, lib/theme/gw_appearance.dart)

## Accomplishments
- Declared `google_fonts: ^6.2.1` in pubspec.yaml; `flutter pub get` resolved 6.3.3 and regenerated pubspec.lock
- Added `preferencesBoxName` / `appearanceModeKey` constants to `lib/hive/constants/cache.dart` (append-only, matches existing box/key naming convention)
- Opened the `preferences` box in `initHive()`, placed after the `networkBoxName` open and before the Transactions adapter cascade
- Created `lib/theme/gw_appearance.dart`: verbatim port of the design branch's `GWAppearance` `ValueNotifier<GWAppearanceMode>` singleton, adapted to import `hive_ce_flutter/hive_flutter.dart` instead of classic `hive_flutter` (develop's data layer)

## Task Commits

Each task was committed atomically:

1. **Task 1: Declare the google_fonts dependency** - `67e4eed` (feat)
2. **Task 2: Add the preferences Hive box constants and open the box at init** - `234497c` (feat)
3. **Task 3: Port gw_appearance.dart onto develop's Hive package** - `0561168` (feat)

_Note: A mid-execution index race with the concurrently-running 02-02 agent required a soft-reset-and-recommit on Task 1 — see Deviations below. No plan-metadata commit has been made yet; will follow after this summary is written._

## Files Created/Modified
- `pubspec.yaml` - added `google_fonts: ^6.2.1` dependency (1 line, 0 deletions)
- `pubspec.lock` - regenerated to include google_fonts and its transitive deps
- `lib/hive/constants/cache.dart` - appended `preferencesBoxName`/`appearanceModeKey` constants under a new `// preferences` section comment
- `lib/hive/init.dart` - added `await Hive.openBox(preferencesBoxName);` after the `networkBoxName` open
- `lib/theme/gw_appearance.dart` (new) - `GWAppearance` singleton, dark-default, Hive-persisted

## Decisions Made
- **pubspec insertion point:** the plan's action text asked for "the existing alphabetical position among the other direct dependencies," but the current `dependencies:` block is not itself alphabetically ordered (e.g. `flutter, auto_size_text, flutter_svg, go_router, flutter_bloc, ...`). Inserted `google_fonts` immediately after `go_router` (its closest alphabetical neighbor: `go_router` < `google_fonts` < `hive_ce`) rather than resorting the whole block, since resorting was out of scope and would have produced a much larger, non-additive diff.
- No other deviations from the plan's specified content — `gw_appearance.dart` is byte-identical to the reference source except the one Hive import line, as instructed.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 3 - Blocking] Mid-execution git index race with concurrent 02-02 agent**
- **Found during:** Task 1 commit
- **Issue:** This plan and 02-02 (dev_flags.dart / responsive_overlay.dart) execute concurrently on the same shared working tree/index (no worktree isolation — `branching_strategy: none`, single checkout). When I ran `git add pubspec.yaml pubspec.lock && git commit`, the 02-02 agent had already `git add`-ed its own new file (`lib/dev/dev_flags.dart`) into the shared index moments earlier, and it was swept into my commit alongside my two files.
- **Fix:** `git reset --soft HEAD~1` (non-destructive — moves HEAD back one commit, working tree and index content preserved), then `git restore --staged lib/dev/dev_flags.dart` to return it to the other agent's untracked/staged state without altering its content, then recommitted with only `pubspec.yaml`/`pubspec.lock` explicitly named.
- **Files modified:** none beyond the plan's own scope; `lib/dev/dev_flags.dart` content was never read, edited, or altered — only briefly present in a since-corrected commit that was reset before any push.
- **Verification:** `git show --stat HEAD` after recommit confirmed exactly `pubspec.lock` and `pubspec.yaml`, 9 insertions, 0 deletions. Subsequent Task 2 and Task 3 commits used explicit `git add <file>` (never `git add .`/`-A`) and were manually stat-checked before proceeding, so no repeat occurred.
- **Committed in:** `67e4eed` (corrected Task 1 commit)

---

**Total deviations:** 1 auto-fixed (1 blocking — shared-index race with a concurrent agent, no content impact)
**Impact on plan:** No scope creep, no unintended file changes shipped. The race was purely a git-index sequencing issue from running two agents on one non-isolated checkout; caught and corrected before any push.

## Issues Encountered
None beyond the deviation above.

## User Setup Required

**Action needed: restart your running debug session.** You have a Windows debug build running with hot reload — this plan added a new pubspec dependency (`google_fonts`) and a new Hive box open in `initHive()`, neither of which hot reload picks up. To pick these up and complete this plan's human verification:

1. Stop your current `flutter run -d windows --debug` session.
2. Re-launch with the standing recipe:
   ```
   CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug
   ```
3. Confirm the app reaches the dashboard with no startup exception (proves `initHive()`'s new `preferences` box open succeeds).
4. Walk 2-3 existing screens (dashboard, settings, swap) and confirm no color/spacing/font change from before this plan.

This is the plan's Task 3 human-check, deferred here because it requires an interactive GUI walk I cannot perform, and because launching a second Windows build instance alongside your running one risks a Hive file-lock conflict on the shared data directory.

## Next Phase Readiness
- `GWAppearance.instance` exists and compiles; its Hive box is wired at `initHive()` time — precondition for plan 02-05's runtime probe satisfied at the code level (pending the user's restart-and-walk above for live confirmation).
- `google_fonts: ^6.2.1` resolves — precondition for `GeniusWalletTypography` (plan 02-04) satisfied.
- `theme.dart` and `main.dart` have zero diff (verified via `git diff --numstat`), confirming this plan stayed additive-only.
- **Blocker for phase sign-off:** the plan's full verification gate (`flutter analyze lib` = 0 errors) passed automatically, but the visual no-change walk is still pending the user's restart per above — do not consider Phase 2's success criterion 2 fully closed until that walk is confirmed.

---
*Phase: 02-design-tokens-verification-loop*
*Completed: 2026-07-16*

## Self-Check: PASSED

All created/modified files found on disk; all 3 task commits (`67e4eed`, `234497c`, `0561168`) found in git log.
