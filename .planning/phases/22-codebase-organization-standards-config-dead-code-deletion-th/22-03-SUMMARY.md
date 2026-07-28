---
phase: 22-codebase-organization-standards-config-dead-code-deletion-th
plan: 03
subsystem: infra
tags: [dart, flutter, analyzer, lint, dead-code, security-gate, shadow-guard]

# Dependency graph
requires:
  - phase: 22-01
    provides: dead-code deletion baseline (300 issues entering this plan), deleted markets_search_bar.dart
  - phase: 22-02
    provides: brace-style gate (tool/check_brace_style.sh) already scanning these 9 files by exact-path exclusion, not *.g.dart glob
provides:
  - 9 hand-written production widgets renamed off the misleading .g.dart suffix, now fully covered by flutter analyze
  - tool/verify_additive_boundary.sh and tool/shadow-baseline.txt updated to pin the renamed WalletsOverview shadow path, proven to still enforce
  - Phase 22 analyzer ceiling recorded: 344 (up from 300, the one sanctioned rise in this phase)
  - GeniusWalletFontSize reduced from 5 to 2 members
affects: [22-04, 22-05, 22-06]

# Tech tracking
tech-stack:
  added: []
  patterns: [git mv for renames to preserve history, injected-then-reverted probe file to prove a security gate still enforces]

key-files:
  created:
    - .planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/deferred-items.md
  modified:
    - lib/components/continue_button/isactive_false.dart (renamed from .g.dart)
    - lib/components/continue_button/isactive_true.dart (renamed from .g.dart)
    - lib/components/genius_back_button.dart (renamed from .g.dart)
    - lib/components/incorrect_pin.dart (renamed from .g.dart)
    - lib/components/recoveryword.dart (renamed from .g.dart)
    - lib/components/registration_header.dart (renamed from .g.dart)
    - lib/components/wallet_information.dart (renamed from .g.dart)
    - lib/components/wallet_preview.dart (renamed from .g.dart)
    - lib/components/wallets_overview.dart (renamed from .g.dart)
    - lib/dev/generated_closure_canary.dart
    - tool/verify_additive_boundary.sh
    - tool/shadow-baseline.txt
    - lib/theme/genius_wallet_font_size.dart

key-decisions:
  - "Re-derived importer counts from the working tree instead of trusting the plan's stated numbers (per the plan's own instruction) -- only 2 of the 9 files had a second importer besides the canary: genius_back_button (also imported by registration_header) and none of the others; the plan's higher counts were stale."
  - "Fixed a stale Loading-baseline entry (dropped lib/dashboard/chart/markets_search_bar.dart, 18->17 importers) discovered while re-proving the shadow guard -- 22-01 deleted that file as genuine dead code without cross-referencing tool/verify_additive_boundary.sh, so the baseline silently drifted; corrected using the exact precedent format the script already documents for the 13-03 case."
  - "GeniusWalletFontSize could not be deleted in favor of GeniusWalletTypography: typography.dart only exposes full styled TextStyle getters (fontWeight/letterSpacing baked in), not bare fontSize doubles matching the 3 call sites' custom styling -- took the plan's fallback branch (reduce to the 2 used members, leave a legacy-holdout comment) instead of the preferred delete-entirely branch."
  - "Logged (not fixed) 2 pre-existing verify_additive_boundary.sh failures unrelated to this plan: Check 2's 6 private-class false positives (Phase 16 dashboard/chart work, Phase 8 splash work) and Check 3's 1 WIRE-02 false positive (a real ticket ID in Phase 8's global_swap_fab_host.dart, not one of Alex's Parabeac placeholder tags) -- both predate Phase 22 and are out of this task's scope per the Scope Boundary rule."

requirements-completed: [ORG-02, ORG-03]

coverage:
  - id: D1
    description: "9 hand-written widgets renamed off the misleading .g.dart suffix; analyzer now covers them"
    requirement: "ORG-02"
    verification:
      - kind: other
        ref: "find lib/components -name '*.g.dart' returns nothing; flutter analyze --no-pub exits with 0 errors"
        status: pass
    human_judgment: false
  - id: D2
    description: "Shadow-class guard (tool/verify_additive_boundary.sh) moved to the renamed WalletsOverview path and proven to still genuinely enforce"
    requirement: "ORG-03"
    verification:
      - kind: other
        ref: "injected a probe second-importer of wallets_overview.dart, confirmed the script FAILs and names the offender, then reverted the probe and confirmed a clean git status"
        status: pass
    human_judgment: false
  - id: D3
    description: "GeniusWalletFontSize reduced to its 2 used members without changing any rendered font size"
    verification:
      - kind: unit
        ref: "flutter test --no-pub (512 passing / 0 failing, unchanged from entering baseline)"
        status: pass
    human_judgment: false
  - id: D4
    description: "verify_additive_boundary.sh's remaining 2 pre-existing, unrelated failures (Check 2 private-class false positives, Check 3 WIRE-02 false positive)"
    verification: []
    human_judgment: true
    rationale: "These predate Phase 22 (traced to Phase 16 and Phase 8 commits) and are out of this task's scope per the Scope Boundary rule; a human/future-plan decision is needed on whether to baseline them or fix the underlying check logic. See deferred-items.md."

duration: 10min
completed: 2026-07-28
status: complete
---

# Phase 22 Plan 03: Rename misleadingly-named .g.dart widgets Summary

**Renamed 9 hand-written production widgets off the `.g.dart` suffix that hid them from `flutter analyze`, moved the WalletsOverview shadow-class guard onto the new path and proved it still enforces by injecting a violation, and trimmed the now-visible `GeniusWalletFontSize` class from 5 to 2 members with zero rendered-size change. Analyzer count: 300 -> 344 (0 errors), the one sanctioned rise for Phase 22.**

## Performance

- **Duration:** ~10 min (11:24-11:34 local, commit timestamps)
- **Tasks:** 3
- **Files modified:** 13 (9 renamed + generated_closure_canary.dart + 2 guard artifacts + genius_wallet_font_size.dart), 1 file created (deferred-items.md)

## Accomplishments
- All 9 hand-written widgets under `lib/components/` now carry a plain `.dart` extension; `find lib -name '*.g.dart'` returns only genuinely generated files (Hive models, `hive_registrar.g.dart`, `token_model.g.dart`).
- `wallets_overview.dart` still has exactly one importer (`lib/dev/generated_closure_canary.dart`) after the rename, verified by grep and by injecting/removing a probe second importer.
- `tool/verify_additive_boundary.sh`'s Check 1 (the shadow-import-boundary logic this plan's threat model targets) passes cleanly across all three pairs (Loading, Splash, WalletsOverview).
- `GeniusWalletFontSize` reduced from 5 members (2 with zero call sites, 2 identical-value aliases) to the 2 actually used, with a comment pointing at the unified type scale for future migration.

## Task Commits

Each task was committed atomically:

1. **Task 1: Rename the nine files and repoint every importer** - `a9502ab` (feat)
2. **Task 2: Move the shadow guard with the rename and re-prove it** - `1c66e98` (fix)
3. **Task 3: Retire the standalone font-size class and record the new analyzer ceiling** - `b128604` (refactor)

**Plan metadata:** (this commit, docs: complete plan)

## Files Created/Modified
- `lib/components/continue_button/isactive_false.dart` - renamed from `isactive_false.g.dart`
- `lib/components/continue_button/isactive_true.dart` - renamed from `isactive_true.g.dart`
- `lib/components/genius_back_button.dart` - renamed from `genius_back_button.g.dart`
- `lib/components/incorrect_pin.dart` - renamed from `incorrect_pin.g.dart`
- `lib/components/recoveryword.dart` - renamed from `recoveryword.g.dart`
- `lib/components/registration_header.dart` - renamed from `registration_header.g.dart`; its own internal import of `genius_back_button.g.dart` repointed
- `lib/components/wallet_information.dart` - renamed from `wallet_information.g.dart`
- `lib/components/wallet_preview.dart` - renamed from `wallet_preview.g.dart`
- `lib/components/wallets_overview.dart` - renamed from `wallets_overview.g.dart` (the WalletsOverview shadow)
- `lib/dev/generated_closure_canary.dart` - all 9 imports repointed; header comment rewritten to state what's true post-rename
- `tool/verify_additive_boundary.sh` - pinned WalletsOverview path updated; rationale comments corrected; stale Loading-baseline entry dropped (18->17)
- `tool/shadow-baseline.txt` - WalletsOverview row's path string updated
- `lib/theme/genius_wallet_font_size.dart` - reduced from 5 to 2 members (`medium`, `title`); deleted `base`, `sectionHeader`, `sectionHeaderLarge` (zero call sites / duplicate-value aliases)
- `.planning/phases/22-codebase-organization-standards-config-dead-code-deletion-th/deferred-items.md` - created; logs 2 pre-existing, unrelated `verify_additive_boundary.sh` failures found while re-proving the guard

## Decisions Made
- Re-derived all importer counts from the working tree rather than trusting the plan's stated numbers, per the plan's own explicit instruction ("22-01 deleted files and may have changed a count"). Actual: only `genius_back_button` had a second real importer (`registration_header.dart`'s internal import); the other 8 files' only importer was the canary.
- Took the plan's fallback branch for `GeniusWalletFontSize` (reduce, don't delete): `GeniusWalletTypography` only exposes fully-styled `TextStyle` getters, not bare fontSize doubles at 16.0/20.0 that match the 3 call sites' custom `fontWeight`/`letterSpacing`/`color` combinations, so repointing would have required either changing rendered output (forbidden) or an awkward `.fontSize!` extraction from an unrelated getter. Kept the two used constants (`medium`=16.0, `title`=20.0) with a legacy-holdout comment.
- Fixed a stale Loading canonical-importer baseline entry discovered while re-running the guard: 22-01 deleted `lib/dashboard/chart/markets_search_bar.dart` (correctly, as genuine dead code) without cross-referencing `tool/verify_additive_boundary.sh`'s pinned list, so a real `Loading` importer silently left the baseline. Corrected using the exact documented precedent format already in the script (the 13-03 note) — same phase, in-scope, not a check-weakening.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed stale `Loading` canonical-importer baseline entry**
- **Found during:** Task 2, re-running `tool/verify_additive_boundary.sh` after the WalletsOverview path fix
- **Issue:** `LOADING_CANONICAL_EXPECTED` still listed `lib/dashboard/chart/markets_search_bar.dart`, which 22-01 had already deleted as dead code (verified: zero live importers of it, but it itself was a real `Loading` importer). The mismatch made Check 1's Loading pair FAIL, unrelated to this plan's rename.
- **Fix:** Dropped the entry (18 -> 17), documented with a comment following the existing 13-03 precedent format in the same file.
- **Files modified:** `tool/verify_additive_boundary.sh`
- **Verification:** `bash tool/verify_additive_boundary.sh` Check 1 now passes all three pairs cleanly.
- **Committed in:** `1c66e98` (Task 2 commit)

**2. [Rule 1 - Bug] Rewrote the canary's header comment**
- **Found during:** Task 1
- **Issue:** The file's header claimed "the analyzer will not check inside the 9 generated files directly" -- false the moment the rename lands.
- **Fix:** Rewrote the paragraph to state what's true post-rename (analyzer now covers them directly; the canary still proves entry-point resolution and forces real compilation via the dev-gated design gallery).
- **Files modified:** `lib/dev/generated_closure_canary.dart`
- **Verification:** `flutter analyze --no-pub` 0 errors; canary still compiles.
- **Committed in:** `a9502ab` (Task 1 commit)

---

**Total deviations:** 2 auto-fixed (both Rule 1 - bug fixes to stale documentation/baseline directly touching this task's own artifacts)
**Impact on plan:** Both necessary for the shadow guard to genuinely enforce rather than pass on stale or vacuous state. No scope creep — both fixes are in the same two files Task 2 was already charged with editing.

## Issues Encountered

`tool/verify_additive_boundary.sh` does **not** exit 0 as a whole. After the fixes above, Check 1 (the shadow-import-boundary logic — Loading, Splash, WalletsOverview — which is what this plan's threat model T-22-07/T-22-08 actually cover) passes cleanly, and is proven non-vacuous for WalletsOverview specifically (injected a probe second-importer via a throwaway file, confirmed the script FAILs and names the offender, reverted the probe, confirmed clean git status). Check 2 and Check 3 fail for two reasons that predate Phase 22 and are unrelated to this plan's changes:

- **Check 2:** 6 new "duplicate public class name" hits are all private (`_`-prefixed) classes — `_Section`, `_SplashState`, `_TimeframeSegment`, `_TimeframeSegmentState`, `_TimeframeTab`, `_TimeframeTabState` — structurally incapable of the import-substitution hazard this check exists to catch (Dart privacy is library-scoped). Traces to Phase 16 (`markets_hero_card.dart`, `dashboard_screen.dart`) and pre-existing `splash.dart`/`design_gallery_screen.dart` pairs.
- **Check 3:** 1 "WIRE-" marker hit is `lib/components/overlay/global_swap_fab_host.dart:21`'s reference to internal ticket "WIRE-02" — not one of Alex's Parabeac placeholder demo tags this tripwire targets. Traces to Phase 8 (`43ff62e`).

Per the executor's Scope Boundary rule ("only auto-fix issues directly caused by the current task's changes"), both were logged to `deferred-items.md` rather than fixed — fixing Check 2 would require baselining 6 unrelated entries or changing the census regex; fixing Check 3 has no allowlist mechanism and would require either weakening the tripwire's logic or editing an unrelated file's prose, both outside this task's stated charge (updating the WalletsOverview pin and re-proving it).

The other two `tool/*.sh` gates (`check_no_new_key_logging.sh`, `check_onboarding_seed_safety.sh`) both pass. `check_no_new_key_logging.sh` requires a file-path argument (usage error on bare invocation, as the plan's `<verify>` block calls it) — ran it against the two files Task 2 actually changed instead, both clean.

## Known Stubs

None.

## Threat Flags

None — this plan's file changes stay within the threat model's already-declared surface (renames, guard-artifact path updates, a theme-constants class reduction). No new network endpoint, auth path, file-access pattern, or schema change introduced.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

- **Analyzer ceiling for 22-04/05/06 to drive to 0:** **344** (up from 300 entering this plan; 0 errors both before and after). This is the phase's one sanctioned rise, from un-hiding 9 previously-excluded files.
- **Brace-style baseline (`tool/check_brace_style.sh --count`):** unchanged at **192**. 22-02's script already scanned these 9 files by exact-path exclusion (deliberately not using a `*.g.dart` glob), so the rename didn't shift this count — confirmed by re-running after the rename.
- **Windows debug build:** succeeds (`flutter build windows --debug`, `Built build\windows\x64\runner\Debug\genius_wallet.exe`).
- **Tests:** 512 passing / 0 failing throughout all 3 tasks — unchanged from entering baseline.
- **Outstanding, unrelated to this plan:** `deferred-items.md` records 2 pre-existing `verify_additive_boundary.sh` false positives (Check 2's 6 private-class duplicates, Check 3's WIRE-02 ticket reference) that a future plan should either baseline (with justification) or fix at the check-logic level.

## Self-Check: PASSED

All 15 claimed files verified present on disk (9 renamed widgets + canary + 2 guard artifacts +
font-size file + deferred-items.md + this SUMMARY). All 3 task commit hashes (`a9502ab`,
`1c66e98`, `b128604`) verified present in `git log --oneline --all`.

---
*Phase: 22-codebase-organization-standards-config-dead-code-deletion-th*
*Completed: 2026-07-28*
