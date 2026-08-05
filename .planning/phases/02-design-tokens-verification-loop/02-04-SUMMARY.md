---
phase: 02-design-tokens-verification-loop
plan: 04
subsystem: ui
tags: [flutter, theme, design-tokens, typography, motion, elevation, decorations]

# Dependency graph
requires:
  - phase: 02-01
    provides: "GWAppearance singleton, google_fonts dependency"
  - phase: 02-03
    provides: "GeniusWalletColors new semantic block (brandPrimary/brandSecondary/textPrimary/textSecondary/borderSubtle), GeniusWalletConsts radiusLg/radiusPill"
provides:
  - "GeniusWalletMotion: fast/base/slow durations, standard/emphasized decelerative curves"
  - "GeniusWalletFontSize: five raw size constants"
  - "GeniusWalletText: onboarding/wallet copy string constants"
  - "GeniusWalletElevation: card/dialog/glowBrand/glowGradient box shadows"
  - "GeniusWalletTypography: 13-style type scale as getters, tabular figures on numeric variants, toMaterialTextTheme() (unwired)"
  - "GWDecorations: surface()/pill()/actionCircle() BoxDecoration helpers, heroGlow, canvas/canvasTopLight/surfaceSheen gradients"
  - "GWCanvasBackground: ported as a dormant class, not instantiated anywhere (asset lands in Phase 3/DS-04)"
affects: [02-05 (probe surface consumes GeniusWalletTypography.headlineLg/bodyMd, GWDecorations.surface(), GeniusWalletGradient.brandCta, GeniusWalletColors.textOnBrand)]

# Tech tracking
tech-stack:
  added: []
  patterns: [byte-identical file port with diff -q gate, negative-instantiation grep for dormant classes, zero-diff gate on theme.dart/main.dart/pubspec.yaml]

key-files:
  created:
    - lib/theme/genius_wallet_motion.dart
    - lib/theme/genius_wallet_font_size.dart
    - lib/theme/genius_wallet_text.dart
    - lib/theme/genius_wallet_elevation.dart
    - lib/theme/genius_wallet_typography.dart
    - lib/theme/genius_wallet_decorations.dart
  modified: []

key-decisions:
  - "All six files ported byte-identical to the reference worktree (diff -q clean) — no adaptation needed, since none carries a Hive import or asset dependency that requires the two adaptation notes UI-SPEC section 1.3 flags for the other additive files (those were already handled in 02-01)."
  - "GWCanvasBackground ported as a class but instantiated nowhere in lib/ — verified by a negative grep. It references assets/images/textures/noise.png, which is not bundled this phase (owned by DS-04/d8db88c, Phase 3). Left dormant exactly as UI-SPEC 1.3 note 3 specifies."
  - "GeniusWalletTypography.toMaterialTextTheme() ships and compiles but is not wired into theme.dart this phase — theme.dart remains byte-identical to develop (zero diff, confirmed by git diff --numstat and a negative grep for GeniusWalletTypography inside it)."
  - "pubspec.yaml, lib/theme/theme.dart and lib/main.dart all confirmed zero diff across all three tasks — nothing in this plan touched the app's actual theme wiring."

patterns-established:
  - "Dormant-class proof pattern: a class can be ported (compiles, exists) while proven unconsumed via a negative instantiation grep across lib/, rather than omitting the file and re-porting it in a later phase."

requirements-completed: [DS-01]

coverage:
  - id: T1
    description: "GeniusWalletMotion, GeniusWalletFontSize, GeniusWalletText, GeniusWalletElevation ported byte-identical; GeniusWalletElevation resolves brandPrimary/brandSecondary from 02-03; no linear/easeIn curves"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "diff -q against reference worktree (4/4 clean); grep for Curves.linear|Curves.easeIn (0 matches); flutter analyze lib (0 errors, 34 pre-existing baseline issues unchanged, none in new files)"
        status: pass
    human_judgment: false
  - id: T2
    description: "GeniusWalletTypography ported byte-identical: 13 styles as getters (not cached finals), tabular figures preserved on numeric variants, toMaterialTextTheme() compiles but unwired, theme.dart untouched"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "diff -q clean; grep gates (13 getters, tabular figures present, GoogleFonts.inter present); git diff --numstat -- lib/theme/theme.dart (0 lines); grep -rc GeniusWalletTypography lib/theme/theme.dart (0 matches); flutter analyze lib (0 errors)"
        status: pass
    human_judgment: false
  - id: T3-mechanical
    description: "GWDecorations + GWCanvasBackground ported byte-identical; GWCanvasBackground instantiated nowhere in lib/; pubspec.yaml/theme.dart/main.dart zero diff"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "diff -q clean; negative grep for GWCanvasBackground( outside its own declaration file (0 matches); git diff --numstat -- pubspec.yaml lib/theme/theme.dart lib/main.dart (0 lines); flutter analyze lib (0 errors, new files absent from issue list entirely)"
        status: pass
    human_judgment: false
  - id: T3-visual-walk
    description: "Full-app no-visual-change walk across every reachable route, confirming zero observable difference and no missing-asset placeholder anywhere (proof that GWCanvasBackground is dormant)"
    requirement: "DS-01"
    verification: []
    human_judgment: true
    rationale: "Requires launching and visually observing a native Windows GUI window, which this agent has no capability to do. flutter analyze is explicitly demoted to a gate in this plan (never evidence) per the same rationale as 02-03 — analyze-clean is exactly what masked the forward-port's 37 regressions. This is the plan's real acceptance test and remains OUTSTANDING pending the human walk described below."

# Metrics
duration: ~20min
completed: 2026-07-16
status: complete
---

# Phase 2 Plan 4: Remaining Additive Theme Files Summary

**Ported the six remaining redesign theme files (motion, font-size, copy-text, elevation, typography, decorations) byte-identical to their reference-worktree originals — zero adaptation needed, zero existing collision, GWCanvasBackground left dormant pending Phase 3's texture asset.**

## Performance

- **Duration:** ~20 min
- **Completed:** 2026-07-16T15:20:00Z
- **Tasks:** 3/3 completed (mechanical gates); Task 3's human visual walk is OUTSTANDING (see below)
- **Files modified:** 6 (all new files, 0 modifications to existing files)

## Accomplishments

- **Task 1 — motion, font-size, copy-text, elevation:** Copied `genius_wallet_motion.dart` (`GeniusWalletMotion`: fast/base/slow durations, standard/emphasized decelerative-only curves), `genius_wallet_font_size.dart` (`GeniusWalletFontSize`: 5 raw size constants), `genius_wallet_text.dart` (`GeniusWalletText`: onboarding/wallet copy constants), and `genius_wallet_elevation.dart` (`GeniusWalletElevation`: card/dialog/glowBrand/glowGradient shadows, resolving `brandPrimary`/`brandSecondary` from plan 02-03) — all four byte-identical to the reference worktree.
- **Task 2 — typography scale:** Copied `genius_wallet_typography.dart` (`GeniusWalletTypography`) byte-identical: all 13 styles as getters (display/headline/title/body/label/numeric variants), tabular figures preserved on the three numeric variants, `toMaterialTextTheme()` present but not wired into `theme.dart`.
- **Task 3 — decorations:** Copied `genius_wallet_decorations.dart` byte-identical, both classes: `GWDecorations` (`surface()`/`pill()`/`actionCircle()` BoxDecoration helpers, `heroGlow`, canvas/canvasTopLight/surfaceSheen gradients) and `GWCanvasBackground` (ported as a class, instantiated nowhere — its `assets/images/textures/noise.png` reference is a Phase-3/DS-04-owned asset not bundled this phase).

All six files are wholly new file paths with wholly new class names — grep confirmed zero existing references in `lib/` or `packages/` before this plan started, matching the plan's stated zero-collision risk profile.

## Task Commits

Each task was committed atomically:

1. **Task 1: Port motion, font sizes, copy constants, and elevation** - `c7273eb` (feat)
2. **Task 2: Port the typography scale** - `b63a0d2` (feat)
3. **Task 3: Port the decorations, then confirm nothing moved** - `3cb9d2c` (feat)

## Verification — Automated Gates (all observed, all PASS)

### File identity (the plan's mechanical proof)

| File | diff -q vs reference | Verdict |
|------|----------------------|---------|
| `lib/theme/genius_wallet_motion.dart` | clean | byte-identical — gate PASS |
| `lib/theme/genius_wallet_font_size.dart` | clean | byte-identical — gate PASS |
| `lib/theme/genius_wallet_text.dart` | clean | byte-identical — gate PASS |
| `lib/theme/genius_wallet_elevation.dart` | clean | byte-identical — gate PASS |
| `lib/theme/genius_wallet_typography.dart` | clean | byte-identical — gate PASS |
| `lib/theme/genius_wallet_decorations.dart` | clean | byte-identical — gate PASS |

### `flutter analyze lib`

**0 errors** after every task. 34 pre-existing info/warning-level issues remain — identical to plan 02-03's baseline — and none of the six new files appear anywhere in the analyzer's issue list (confirmed via a direct grep for each new filename against the analyzer output).

### Task 1 gates (all PASS)

All four files exist and are byte-identical; `grep -rEc 'Curves.linear|Curves.easeIn[,)]' lib/theme/genius_wallet_motion.dart` returns 0 (no forbidden easing curves); `flutter analyze lib` 0 errors, proving `GeniusWalletElevation` resolves `brandPrimary`/`brandSecondary` from 02-03.

### Task 2 gates (all PASS)

Byte-identical; `FontFeature.tabularFigures()` present (1 definition site, shared by 3 numeric getters); exactly 13 `static TextStyle get` declarations; `GoogleFonts.inter(` present exactly once (the shared `_inter` helper); `git diff --numstat -- lib/theme/theme.dart` returns 0 lines (untouched); `grep -rc 'GeniusWalletTypography' lib/theme/theme.dart` returns 0 (not referenced); `flutter analyze lib` 0 errors.

### Task 3 gates (all PASS)

Byte-identical; `grep -rEc 'GWCanvasBackground\(' --include=*.dart lib` excluding the declaration file itself returns 0 matches (never instantiated); `git diff --numstat -- pubspec.yaml lib/theme/theme.dart lib/main.dart` returns 0 lines (all three untouched); `flutter analyze lib` 0 errors.

### Deletion check (all 3 commits)

`git diff --diff-filter=D --name-only 4494b93..HEAD` (the range spanning all three of this plan's commits) returns no output — pure insertions, zero files deleted or modified. All 3 files created cleanly as new files (`git status --short` showed `A` for each, and `git log` confirms the commits landed as expected).

## Verification — OUTSTANDING (human required)

**Task 3's full-app visual walk was NOT performed by this agent** — same limitation as 02-03: it requires launching and visually observing a native Windows GUI window, which this agent cannot do. `flutter analyze` is explicitly a gate in this plan, never evidence, per the same rationale as 02-03 (the forward-port was analyze-clean and still shipped 37 regressions).

### What to do when you reload

Your running debug session should pick this up with **hot reload (`r`)**. All six changes are brand-new files with zero collision to anything already imported — nothing in the app's currently-executing code path references any of the six new classes, so there is no incremental-compile risk beyond the normal "new file added" case, which hot reload handles cleanly. If `r` produces any analyzer/incremental-compile error, fall back to `R` (hot restart) to be safe — same fallback guidance as 02-03's summary gave for its own changes.

### The walk to perform (from the plan's Task 3 human-check)

1. Close the reference Release exe at `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` if running — it shares the Hive data dir with your build and the two deadlock on lock files.
2. Run the standing recipe with **no define** (normal build, not the dev-tools define):
   ```
   CMAKE_ARGUMENTS="-DCMAKE_BUILD_TYPE=Release -DGENIUS_DEPENDENCY_BRANCH=develop -Dc-ares_DIR=C:/Users/User/Documents/Projects/GNUS/thirdparty/build/Windows/Release/cares/lib/cmake/c-ares" flutter run -d windows --debug
   ```
3. Walk the app top to bottom again — splash → onboarding → dashboard → transactions → token detail → send → swap → bridge → markets → news → buy → settings. Confirm no visual change from the 02-03 walk and no startup exception.
4. Confirm **no missing-asset placeholder** (a grey box or broken-image icon) appears anywhere. Its absence is the evidence that `GWCanvasBackground` is dormant and its unbundled `noise.png` reference is never actually resolved at runtime.

**Expected result: zero observable difference.** These six classes are consumed by nothing yet, so anything you see differ here is a real defect — most likely evidence that something accidentally instantiates `GWCanvasBackground`, which the negative grep above says does not happen, but the grep only covers `lib/`; a runtime-only reflection/dynamic path (unlikely in Dart, but not impossible via a generated route table) would not be caught by it.

## Files Created/Modified

- `lib/theme/genius_wallet_motion.dart` - `GeniusWalletMotion` durations/curves (new file, 12 lines)
- `lib/theme/genius_wallet_font_size.dart` - `GeniusWalletFontSize` raw size constants (new file, 7 lines)
- `lib/theme/genius_wallet_text.dart` - `GeniusWalletText` copy constants (new file, 28 lines)
- `lib/theme/genius_wallet_elevation.dart` - `GeniusWalletElevation` box shadows (new file, 43 lines)
- `lib/theme/genius_wallet_typography.dart` - `GeniusWalletTypography` 13-style type scale (new file, 145 lines)
- `lib/theme/genius_wallet_decorations.dart` - `GWDecorations` + `GWCanvasBackground` (new file, 181 lines)

## Decisions Made

- No adaptation notes applied — unlike `gw_appearance.dart` (02-01, Hive import swap) or the four token-block appends (02-03), none of these six files import Hive or reference a develop-specific constants file that needed rewriting. UI-SPEC section 1.3's two adaptation notes were already fully handled in earlier plans; this plan's only file-specific note (note 3, `GWCanvasBackground`) is a "leave dormant" instruction, not an edit.
- `GWCanvasBackground` ported as written, dormant, per UI-SPEC 1.3 note 3 — no asset added, no pubspec.yaml `flutter:` assets block touched, no stub or deletion of the image reference. This is explicitly a Phase-3/DS-04 concern, not this plan's to solve.
- No other deviations from the plan's specified content. All three tasks ported exactly the members the plan named, verbatim, with the one exclusion (no instantiation of `GWCanvasBackground`) exactly as specified.

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-4 auto-fixes were needed; no architectural questions arose; all six files required zero adaptation (confirmed byte-identical via `diff -q`, not just "equivalent").

## Issues Encountered

None. `flutter analyze` required the pinned Flutter SDK on `PATH` (`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on the default shell PATH) — a known environment note carried from 02-03, not a code issue.

## User Setup Required

**Action needed: reload your running debug session and perform the visual walk above.** This plan's mechanical gates (byte-identity diffs, grep proofs, `flutter analyze`) all pass, but per this phase's verification philosophy that is proof of *additivity*, not proof of *no visual change* — only the human walk closes that loop. See "Verification — OUTSTANDING" above for the full walk.

Note: this plan's blast radius is smaller than 02-03's. 02-03 modified 3 files develop's screens already import and consume (`genius_wallet_colors.dart`, `genius_wallet_consts.dart`, `genius_wallet_gradient.dart`), so its walk was checking "did an append accidentally repoint a live symbol." This plan's six files are brand-new paths with brand-new class names that nothing imports yet, so its walk is checking a narrower, lower-risk claim: "did adding unconsumed files somehow perturb anything" (it structurally cannot, short of a build-system-level issue) — plus the specific missing-asset-placeholder check for `GWCanvasBackground`.

## Next Phase Readiness

- DS-01's vocabulary is now complete on develop: colors, typography, spacing, radius, elevation, gradients, motion, decorations and copy constants all exist and compile.
- Plan 02-05's probe surface has everything it needs: `GeniusWalletTypography.headlineLg`/`bodyMd`, `GWDecorations.surface()`, `GeniusWalletGradient.brandCta` (from 02-03), `GeniusWalletColors.textOnBrand` (from 02-03).
- `theme.dart`, `main.dart` and `pubspec.yaml` remain byte-identical to before this plan (verified via `git diff --numstat` after every task), confirming this plan stayed strictly additive per UI-SPEC section 1.
- `toMaterialTextTheme()` is unwired, pending the shell re-skin (Phase 4, where `theme.dart` itself becomes the design's version).
- `GWCanvasBackground` is dormant, pending DS-04's texture asset bundling (Phase 3).
- **Blocker for phase sign-off:** the Task 3 visual walk is pending the user's reload-and-walk above, same as 02-03's outstanding item. Do not consider ROADMAP Phase 2 success criterion 2 fully closed until both this plan's and 02-03's walks are confirmed — 02-05 (the probe surface + full BLD-02 verification protocol) is the last plan in the phase and depends on both.

---
*Phase: 02-design-tokens-verification-loop*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 6 new theme files found on disk; SUMMARY.md found on disk; all 3 task commits (`c7273eb`, `b63a0d2`, `3cb9d2c`) found in git log.
