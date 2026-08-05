---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 01
subsystem: dead-code-deletion
tags: [flutter, dart, dead-code, pubspec, google_fonts, theme-tokens]

# Dependency graph
requires: []
provides:
  - "512/0 green test baseline for every later Phase 22/23 plan to verify against"
  - "17 never-imported lib/ files removed (1,486 LOC)"
  - "google_fonts dependency removed, pubspec.lock regenerated clean"
  - "duplicate radius3xl token alias collapsed into radiusXl"
affects: [22-02, 22-03, 22-04, 22-05, 22-06, 22-07, 22-08]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Two-way reference check (package-path import AND bare basename) as the deletion-safety gate"

key-files:
  created:
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-01-DELETIONS.md
  modified:
    - lib/main.dart
    - pubspec.yaml
    - pubspec.lock
    - lib/theme/genius_wallet_consts.dart
    - lib/components/bottom_drawer/responsive_drawer.dart

key-decisions:
  - "All three one-reference adjudication files (custom_drop_down.dart, sgnus_wallet.dart, markets_search_bar.dart) were deleted: their single reference in each case was a prose comment, not a live import"
  - "Deleted the dead test rather than repairing it — repair is REQUIREMENTS.md APP-02, out of this phase's organisation-only boundary"
  - "Kept radiusXl as the canonical name (3 pre-existing call sites) and repointed radius3xl's 2 call sites to it, moving the gnus.ai provenance comment onto radiusXl"

patterns-established:
  - "22-01-DELETIONS.md as the per-file evidence record format for future dead-code deletion plans"

requirements-completed: [ORG-02]

coverage:
  - id: D1
    description: "Delete 17 never-imported lib/ files (14 zero-reference + 3 adjudicated comment-only references), evidenced in 22-01-DELETIONS.md"
    requirement: "ORG-02"
    verification:
      - kind: automated_ui
        ref: "flutter analyze --no-pub && flutter test --no-pub (post-Task-1 run)"
        status: pass
    human_judgment: false
  - id: D2
    description: "Delete the fully-commented-out test/local_wallet_storage_test.dart and remove the now-unused google_fonts dependency, regenerating pubspec.lock"
    requirement: "ORG-02"
    verification:
      - kind: unit
        ref: "flutter test --no-pub -> 512 passing, 0 failing"
        status: pass
    human_judgment: false
  - id: D3
    description: "Collapse the duplicate radius3xl token alias into radiusXl, repointing both call sites in responsive_drawer.dart"
    requirement: "ORG-02"
    verification:
      - kind: unit
        ref: "grep -rn radius3xl lib test -> 0 matches; flutter test --no-pub -> 512/0"
        status: pass
    human_judgment: false

# Metrics
duration: 4min (across 3 commits, 10:54:31-10:57:55 -03:00)
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 01: Dead Code Deletion Summary

**Deleted 17 never-imported lib/ files (1,486 LOC), removed the dead google_fonts dependency and the fully-commented-out failing test, and collapsed a duplicate radius token alias — landing the suite at 512 passing / 0 failing and the analyzer at 300 issues (down from 319).**

## Performance

- **Duration:** ~4 min of committed work (three atomic commits between 10:54:31 and 10:57:55 -03:00), plus verification runs (analyze/test/build) around them
- **Tasks:** 3/3 completed
- **Files modified:** 23 (17 deleted lib/ files, 1 deleted test file, 1 new evidence doc, 4 modified files)

## Accomplishments
- Deleted 14 zero-reference files and adjudicated 3 one-reference files (all three references were prose comments, not live imports) — 17 files, 1,486 LOC total, all recorded with reference counts in `22-01-DELETIONS.md`.
- Deleted `test/local_wallet_storage_test.dart` (240 lines, fully commented out, no `main`) — the single pre-existing failing test. Suite moved from 512/1 to **512 passing, 0 failing**.
- Removed the `google_fonts` dependency from `pubspec.yaml`, deleted its import and the runtime-fetch-disable line + explanatory comment in `lib/main.dart`, and regenerated `pubspec.lock` via `flutter pub get` — diff shows only the `google_fonts` lockfile entry removed, no other package version changed.
- Collapsed `genius_wallet_consts.dart`'s duplicate `radius3xl` alias (24.0) into `radiusXl` (24.0, its existing 3 call sites), repointed the 2 call sites in `responsive_drawer.dart`, and moved the `gnus.ai --radius-3xl` provenance note onto the surviving symbol.

## Task Commits

Each task was committed atomically:

1. **Task 1: Delete the never-imported files under lib/** - `564f0bc` (feat)
2. **Task 2: Delete the dead test file and the unused font dependency** - `d0e036d` (fix)
3. **Task 3: Collapse the duplicate radius alias** - `82810b4` (refactor)

_No plan-metadata commit yet — STATE.md/ROADMAP.md updates follow this SUMMARY per the execute-plan workflow._

## Files Created/Modified
- `.planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/22-01-DELETIONS.md` - per-file deletion evidence record (path, LOC, measured reference count, adjudication)
- `lib/main.dart` - removed `google_fonts` import and the runtime-fetch-disable call + its now-obsolete explanatory comment
- `pubspec.yaml` - removed the `google_fonts: ^6.2.1` dependency line
- `pubspec.lock` - regenerated via `flutter pub get`; only the `google_fonts` entry removed
- `lib/theme/genius_wallet_consts.dart` - removed the `radius3xl` alias, moved its provenance comment onto `radiusXl`
- `lib/components/bottom_drawer/responsive_drawer.dart` - repointed 2 `Radius.circular(GeniusWalletConsts.radius3xl)` call sites to `radiusXl`
- 17 `lib/` files deleted (listed in full in `22-01-DELETIONS.md`)
- `test/local_wallet_storage_test.dart` deleted (240 lines, fully commented out)

## Decisions Made
- All three one-reference adjudication files were deleted, not kept: `custom_drop_down.dart`'s only hit is a prose comment in `lib/tokens/token_info_screen.dart:671`; `sgnus_wallet.dart`'s only hit is a prose comment in `lib/theme/genius_wallet_colors.dart:156` (the documented `gray500` alias rationale note); `markets_search_bar.dart`'s only hit is a prose comment in `lib/components/sliding_drawer_button.dart:11`. None is a live `import` or symbol usage.
- The plan text's file-to-referencing-file pairing for the three adjudication cases did not exactly match what the re-verified grep found (it swapped `custom_drop_down.dart` and `markets_search_bar.dart`'s referencing files relative to what was measured). This is noted in `22-01-DELETIONS.md` — it does not change the adjudication outcome since all three references are comment-only regardless of pairing.
- Deleted the dead test rather than attempting any repair, per the plan's explicit instruction (repair is a separate v2 item, REQUIREMENTS.md APP-02).
- Kept `radiusXl` as the canonical radius name over `radius3xl` because it already had 3 call sites vs. the alias's 2, matching the plan's instruction.

## Deviations from Plan

None - plan executed exactly as written. The only discrepancy found (the adjudication file-pairing order noted above) was a documentation-accuracy issue in the plan's prose, not a functional deviation — the actual adjudication outcome (delete all three, all comment-only references) matches what the plan directed.

## Issues Encountered
None.

## User Setup Required
None - no external service configuration required.

## Verification Evidence

- `flutter test --no-pub`: **512 passing, 0 failing** (quoted from the final Task 3 run: `00:12 +511: ... toggling decoration null <-> non-null remounts the field` / `00:12 +512: All tests passed!`).
- `flutter analyze --no-pub`: **300 issues found**, 0 `error`-severity diagnostics, at every task gate (Task 1: 300, Task 2: 300, Task 3: 300) — down from the 319 baseline, never rose.
- `git diff --stat dce2525 HEAD -- lib/ test/ pubspec.yaml pubspec.lock`: **23 files changed, 4 insertions(+), 1748 deletions(-)** — net -1,744 LOC, well past the plan's -1,200 target.
- `flutter build windows --debug` (no `genius_wallet.exe` running beforehand): succeeded — `√ Built build\windows\x64\runner\Debug\genius_wallet.exe`.

## Next Phase Readiness
- The 512/0 test baseline and 300-issue analyzer baseline are now the reference numbers for plans 22-02 through 22-08 (and Phase 23) to verify against.
- No blockers. `lib/web/*` and `lib/dev/*` were left untouched as required.

## Self-Check: PASSED

- `22-01-DELETIONS.md` exists on disk.
- `22-01-SUMMARY.md` exists on disk.
- `test/local_wallet_storage_test.dart` confirmed absent.
- Commits `564f0bc`, `d0e036d`, `82810b4` all found in `git log`.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*
