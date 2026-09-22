---
phase: quick-260922-chs
plan: 01
subsystem: ui
tags: [flutter, appearance, theming, hive, widgets-binding-observer]

requires:
  - phase: 04-design-tokens-verification-loop
    provides: GWAppearance singleton, GWColors ThemeExtension, GWSelect component
provides:
  - GWAppearancePreference (system/light/dark) split from the resolved GWAppearanceMode
  - Settings screen Appearance card, first section, calling GWAppearance.instance.setPreference
  - Mid-session OS brightness tracking via WidgetsBindingObserver while preference is system
affects: [any future phase touching gw_appearance.dart, settings_screen.dart, or the deferred GWColors readers todo]

actuals:
  tokens: 3805
  tasks: 3
  commits: 4

tech-stack:
  added: []
  patterns:
    - "Preference vs. resolved-state split: a 3-valued user intent enum resolved into an existing 2-valued rendering enum, so all downstream readers of the rendering enum stay untouched"
    - "WidgetsBindingObserver registration guarded by a private bool, not idempotent framework state, so a second load() call never double-registers"

key-files:
  created:
    - test/theme/gw_appearance_preference_test.dart
  modified:
    - lib/theme/gw_appearance.dart
    - lib/settings/settings_screen.dart

key-decisions:
  - "OS brightness read via WidgetsBinding.instance.platformDispatcher, not PlatformDispatcher.instance -- package:flutter/widgets.dart re-exports only Brightness/UniqueKey from foundation, not PlatformDispatcher itself"
  - "_buildSectionCard's action param loosened to Widget? with a collection-if guard, so the new Appearance card can omit a footer button entirely"

requirements-completed: []

coverage:
  - id: D1
    description: "Light/Dark/Follow system picker on /settings, backed by GWAppearancePreference; setPreference persists and resolves live"
    verification:
      - kind: unit
        ref: "test/theme/gw_appearance_preference_test.dart (5 cases)"
        status: pass
      - kind: other
        ref: "flutter analyze"
        status: pass
    human_judgment: true
    rationale: "The picker's visual placement, focus/keyboard operability, and live re-skin on selection were not walked in a running app this session -- automated coverage proves the state machine, not the rendered UI."
  - id: D2
    description: "Follow-system preference tracks a mid-session OS brightness flip via WidgetsBindingObserver, with no relaunch"
    verification:
      - kind: unit
        ref: "test/theme/gw_appearance_preference_test.dart#preference system: an OS brightness flip changes value with no reload"
        status: pass
    human_judgment: false

duration: ~35min
completed: 2026-09-22
status: complete
---

# Quick Task 260922-chs: Add a user-facing appearance control Summary

**Settings screen gets a real Light/Dark/Follow-system picker (`GWSelect<GWAppearancePreference>`), and `GWAppearance` now tracks OS brightness flips live via `WidgetsBindingObserver` — closing the todo that previously required navigating to a dev screen to test appearance changes at all.**

## Performance
- **Tasks:** 3/3
- **Files modified:** 2 lib files, 1 test file, 2 todo files

## Accomplishments
- `GWAppearancePreference { system, light, dark }` added, resolved into the existing `GWAppearanceMode` via `_resolve()` — `isLight`, `getThemeData()`, `main.dart`'s `ValueListenableBuilder`, and both dev call sites (`setMode`) needed zero edits.
- `settings_screen.dart` gains an Appearance card as the first section, backed by `_AppearanceControl` (a `StatelessWidget`, `ValueListenableBuilder<GWAppearanceMode>` on the singleton).
- `didChangePlatformBrightness()` re-resolves `value` live while `system` is selected; registration is guarded by `_observing` so a second `load()` call (dev token probe) never double-registers; `dispose()` tears it down for tests.
- Closed `.planning/todos/pending/2026-07-18-no-user-facing-appearance-toggle.md` → `completed/`; left the sibling const-staleness todo open with a dated note.

## Task Commits
1. **Task 1 (tracer): pick Light/Dark/Follow system on /settings** — `a19a51f3` (feat)
2. **Task 2: OS mid-session tracking (TDD)** — `6e560301` (test, RED) → `a4a545e7` (feat, GREEN)
3. **Task 3: close the todo** — `bf7e725f` (docs)

## Decisions Made
See `key-decisions` above (PlatformDispatcher access path; `action` param loosened to `Widget?`).

## Deviations from Plan
**1. [Test-design fix, Task 2] `setPreference` round-trip test rewritten to move off the tearDown default first**
- **Found during:** Task 2 RED verification
- **Issue:** the tearDown resets the singleton to `dark`; the round-trip test's first `setPreference(dark)` was therefore a same-value no-op and never wrote to the box, failing for a test-harness reason unrelated to the missing observer.
- **Fix:** the test now calls `setPreference(light)` first to move off the default before exercising the dark/system writes.
- **Files modified:** `test/theme/gw_appearance_preference_test.dart`
- **Committed in:** `6e560301` (part of the RED commit)

No production-code deviations — plan executed as written otherwise.

## Verification (actual output)
- `dart format lib test` → 427 files, 0 changed
- `flutter analyze` → `No issues found!`, exit 0
- `flutter test` → **1555 pass / 5 skip / 0 fail**, exit 0
- `bash tool/check_brace_style.sh` / `check_raw_colors.sh` → no output, exit 0
- `git ls-files --eol lib test | grep i/crlf` → only the two known files

**Test count note:** the plan's done-criteria target was "≥1556" (assumed 1551 baseline + 5 new). Isolating the new test file confirmed the true baseline on this branch (with Task 1's non-test changes present, before the new file) is **1550**, not 1551 — a pre-existing one-off in the stated baseline, not something introduced here. 1550 + 5 new = 1555, matching the actual run. All 5 new tests pass individually and in the full suite; 0 failures either way.

## Issues Encountered
None beyond the test-design fix above.

## Next Phase Readiness
Code is analyze-clean and committed on `appearance-toggle`; no live-app walk was performed this session (no running instance). A human walk of `/settings` (picker renders, selection persists, live OS-flip re-skin) is recommended before merge but is not a blocker for further code work.

---
*Quick task: 260922-chs-add-a-user-facing-appearance-control-lig*
*Completed: 2026-09-22*

## Self-Check: PASSED
- FOUND: lib/theme/gw_appearance.dart
- FOUND: lib/settings/settings_screen.dart
- FOUND: test/theme/gw_appearance_preference_test.dart
- FOUND: .planning/todos/completed/2026-07-18-no-user-facing-appearance-toggle.md
- FOUND: a19a51f3
- FOUND: 6e560301
- FOUND: a4a545e7
- FOUND: bf7e725f
