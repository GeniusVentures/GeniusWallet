---
phase: 02-design-tokens-verification-loop
plan: 03
subsystem: ui
tags: [flutter, theme, design-tokens, coexistence]

# Dependency graph
requires: [02-01 (GWAppearance singleton)]
provides:
  - "GeniusWalletColors new semantic block: brand primary/secondary/tertiary families, gradient stops, appearance-aware surfaces (surfaceBase/Elevated/Menu/Sunken/Overlay), text ladder (textPrimary + alpha steps, textSecondary/Tertiary/Disabled/OnBrand), borders (borderSubtle/Strong/Brand), status tokens (statusSuccess/Error/Warning/Info)"
  - "GeniusWalletConsts space2-space32 (10-value 4-pt spacing scale) and radiusXs-radiusPill (9 radius tokens)"
  - "GeniusWalletGradient brandCta / brandBorder / heroWash"
affects: [02-04 (typography/elevation/motion/decorations files), 02-05 (probe surface consumes all these tokens)]

# Tech tracking
tech-stack:
  added: []
  patterns: [additive-only token append (insertion-only diff as mechanical proof of no-repoint), verified-identical alias re-pointing with paired-value grep gates]

key-files:
  created: []
  modified:
    - lib/theme/genius_wallet_colors.dart
    - lib/theme/genius_wallet_consts.dart
    - lib/theme/genius_wallet_gradient.dart

key-decisions:
  - "colors.dart and gradient.dart ported as pure insertions (0 deletions each), proven mechanically via git diff --numstat plus a clean flutter analyze (duplicate member names would be a compile error)."
  - "consts.dart's 6 legacy aliases (horizontalPadding, horizontalDesktopPadding, verticalDesktopPadding, itemSpacing, borderRadiusCard, borderRadiusButton) were re-pointed at the new space*/radius* tokens after verifying each target holds develop's exact current literal (20/40/40/16/15/48) — the only intentional deletions in this plan, each paired-value-gated per the plan's method."
  - "appBarHeight excluded and left at develop's 60 (design branch's 65 NOT ported) — this is a real, deliberate visual change owned by Phase 4's shell re-skin, not a token rename. Gated both positively (= 60 present exactly once) and negatively (never 65/aliased)."
  - "greenBlueGreenGradient left as develop's own vertical (topCenter->bottomCenter) btnGradientBlue->btnGradientGreen definition — the design branch's legacy alias (horizontal, gradientGreen->gradientBlue) was explicitly NOT ported, since it would visibly re-skin the two live call sites (swap_settings_drawer.dart:68, banxa_buy_screen.dart:318)."
  - "theme.dart and main.dart confirmed byte-identical (zero diff) — the single file where new-vs-old cannot be separated symbol-by-symbol stays untouched this phase, per UI-SPEC section 1."

patterns-established:
  - "Mechanical additivity proof: 0 deletions (git diff --numstat) + clean compile (flutter analyze 0 errors) together are sufficient to prove no existing symbol was repointed or shadowed, without needing a working test harness."
  - "For files where the port genuinely re-points an existing line (consts.dart's 6 aliases), gate each alias with a paired grep: the alias line AND its target token's literal value, so the repoint is proven a no-op rather than merely reviewed."

requirements-completed: [DS-01]

coverage:
  - id: T1
    description: "New semantic color block (brand families, gradient stops, appearance-aware surfaces/text/borders, status tokens) appended to GeniusWalletColors; all 16 of develop's existing members byte-identical"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "git diff --numstat (127 insertions, 0 deletions); 8 grep gates (4 spot-checked legacy members intact, no excluded alias/legacy names present, brandPrimary + gw_appearance.dart import present exactly once); flutter analyze lib (0 errors)"
        status: pass
    human_judgment: false
  - id: T2
    description: "space2-space32 spacing scale and radiusXs-radiusPill radius scale appended to GeniusWalletConsts; 6 legacy aliases re-pointed at value-identical targets; appBarHeight excluded and unchanged at 60"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "git diff --numstat (34 insertions, 6 deletions — the 6 alias re-points); 14 grep gates (appBarHeight=60 positive+negative, 6 paired alias/target-value checks, pinCount intact); flutter analyze lib (0 errors)"
        status: pass
    human_judgment: false
  - id: T3-mechanical
    description: "brandCta/brandBorder/heroWash appended to GeniusWalletGradient; greenBlueGreenGradient left at develop's own definition (not aliased to brandCta); theme.dart/main.dart zero diff"
    requirement: "DS-01"
    verification:
      - kind: other
        ref: "git diff --numstat (33 insertions, 0 deletions); 7 gates (0-deletion, no legacy-alias pattern, develop's greenBlueGreenGradient declaration intact, all 3 new members present, theme.dart/main.dart empty diff); flutter analyze lib (0 errors); live call-site grep confirms swap_settings_drawer.dart:68 and banxa_buy_screen.dart:318 still reference greenBlueGreenGradient unmodified"
        status: pass
    human_judgment: false
  - id: T3-visual-walk
    description: "Full-app no-visual-change walk across every reachable route, with explicit confirmation the swap-drawer/Banxa gradients still run top-to-bottom blue-to-green and the shell header height is unchanged"
    requirement: "DS-01"
    verification: []
    human_judgment: true
    rationale: "Requires launching the Windows debug build and visually observing rendered screens — an interactive GUI check this agent cannot perform (no way to observe a native Windows window). flutter analyze is explicitly demoted to a gate in this plan (never evidence) because the forward-port was analyze-clean and still shipped 37 regressions. This is the single most consequential outstanding item in the phase — see 'User Setup Required' below for the exact walk to perform."

# Metrics
duration: ~25min
completed: 2026-07-16
status: complete
---

# Phase 2 Plan 3: Design Tokens Coexistence Summary

**Appended the redesign's new semantic color/spacing/gradient vocabulary to develop's 3 colliding theme files as pure insertions (127+34+33 lines added, only 6 deletions — all 6 provably no-op alias re-points) — zero existing symbol repointed, theme.dart untouched, appBarHeight deliberately held at 60.**

## Performance

- **Duration:** ~25 min
- **Completed:** 2026-07-16T14:54:37Z
- **Tasks:** 3/3 completed (mechanical gates); Task 3's human visual walk is OUTSTANDING (see below)
- **Files modified:** 3 (lib/theme/genius_wallet_colors.dart, lib/theme/genius_wallet_consts.dart, lib/theme/genius_wallet_gradient.dart)

## Accomplishments

- **Task 1 — `genius_wallet_colors.dart`:** Appended the `_isLight` getter and the full new semantic block (brand primary/secondary/tertiary families with Strong/Bright/Muted/Subtle variants, the two gradient stop colors, five appearance-aware surface getters with private dark/light backing constants, the appearance-aware `textPrimary` alpha ladder, fixed secondary/tertiary/disabled/on-brand text colors, three border tokens, four status tokens). Added the `gw_appearance.dart` import. **127 insertions, 0 deletions.** Stopped copying at the reference file's line 130 — did NOT port the "Backwards-compatibility aliases" or "Legacy constants" blocks (lines 132-226), which is what would have silently repointed develop's 16 existing symbols.
- **Task 2 — `genius_wallet_consts.dart`:** Appended the 10-value 4-pt spacing scale (`space2`=4.0 through `space32`=64.0) and 9 radius tokens (`radiusXs`=4.0 through `radiusPill`=48.0). Re-pointed develop's 6 existing layout aliases (`horizontalPadding`, `horizontalDesktopPadding`, `verticalDesktopPadding`, `itemSpacing`, `borderRadiusCard`, `borderRadiusButton`) onto the new tokens, each independently verified value-identical to develop's prior raw literal before editing. **34 insertions, 6 deletions** — the 6 deletions are exactly the 6 alias re-points, each gated with a paired grep proving both the alias line and its target's value. `appBarHeight` excluded, stays `= 60` (not 65).
- **Task 3 — `genius_wallet_gradient.dart`:** Appended `brandCta` (CTA gradient, centerLeft→centerRight, `gradientGreen`→`gradientBlue`), `brandBorder` (centerLeft→centerRight, `brandPrimary`→`brandSecondaryBright`), and `heroWash` (topCenter→bottomCenter, `surfaceBase`→`surfaceElevated`). Did NOT port the reference file's legacy alias that repoints `greenBlueGreenGradient` at `brandCta` — develop's own vertical, `btnGradientBlue`→`btnGradientGreen` definition was left completely untouched. **33 insertions, 0 deletions.**

## Task Commits

Each task was committed atomically:

1. **Task 1: Append new semantic color block to GeniusWalletColors** - `a88945f` (feat)
2. **Task 2: Append spacing/radius scale to GeniusWalletConsts, exclude appBarHeight** - `b415243` (feat)
3. **Task 3: Append brand gradients to GeniusWalletGradient** - `75c8505` (feat)

## Verification — Automated Gates (all observed, all PASS)

### Deletion counts (the plan's mechanical proof)

| File | Insertions | Deletions | Verdict |
|------|-----------|-----------|---------|
| `lib/theme/genius_wallet_colors.dart` | 127 | **0** | Pure insertion — gate PASS |
| `lib/theme/genius_wallet_consts.dart` | 34 | **6** | 6 verified-identical alias re-points (documented exception) — gate PASS |
| `lib/theme/genius_wallet_gradient.dart` | 33 | **0** | Pure insertion — gate PASS |

### `flutter analyze lib`

**0 errors.** 34 pre-existing info/warning-level issues remain, none in the 3 modified files and none newly introduced by this plan (identical issue list before and after each task's edit, spot-checked via `grep -i "genius_wallet_colors\|genius_wallet_consts\|genius_wallet_gradient"` against the analyze output — no hits).

### Task 1 gates (8/8 PASS)
0-deletion count; no excluded alias/legacy names present (`blue500|foundationWhite|containerGray|deepBlueSecondary|btnCopyBorder|rowFilterBlue|currencyBackground|mutedRed|brandGreen|darkGreen|successGreen|gray900` — 0 matches); `lightGreenPrimary`, `deepBlueCardColor`, `btnGradientBlue`, `borderGrey` all byte-identical to develop's originals; `brandPrimary = Color(0xFF14C8FF)` present; `gw_appearance.dart` import present exactly once.

### Task 2 gates (14/14 PASS)
`appBarHeight = 60` present exactly once; never `65` or aliased to a `space`/`radius` token; each of the 6 aliases paired with its target's exact value (`horizontalPadding=space10`+`space10=20.0`, `horizontalDesktopPadding=space20`+`verticalDesktopPadding=space20`+`space20=40.0`, `itemSpacing=space8`+`space8=16.0`, `borderRadiusCard=radiusLg`+`radiusLg=15.0`, `borderRadiusButton=radiusPill`+`radiusPill=48.0`); `pinCount = 4` intact.

### Task 3 gates (7/7 PASS)
0-deletion count; `greenBlueGreenGradient = brandCta` (the legacy alias) absent; develop's own `static LinearGradient greenBlueGreenGradient = const LinearGradient(` declaration present exactly once, unmodified; `brandCta`/`brandBorder`/`heroWash` all present; `lib/theme/theme.dart` and `lib/main.dart` show zero diff.

### Live call-site confirmation (additional check beyond the plan's literal gate)
`grep -rn greenBlueGreenGradient lib/` confirms exactly 3 hits: the declaration in `genius_wallet_gradient.dart:5`, and the two live consumers `lib/squid_router/swap_settings_drawer.dart:68` and `lib/screens/banxa_buy_screen.dart:318` — both call sites unmodified by this plan.

## Verification — OUTSTANDING (human required)

**Task 3's full-app visual walk was NOT performed by this agent** — it requires launching and visually observing a native Windows GUI window, which this agent has no capability to do. `flutter analyze` is explicitly a gate in this plan, never evidence (the forward-port was analyze-clean and still shipped 37 regressions), so this walk is the plan's real acceptance test and is not yet complete.

### What to do when you reload

Your running debug session should pick this up with **hot reload (`r`)** — all three changes are pure Dart const/static additions plus 6 value-identical re-points, no new imports beyond `gw_appearance.dart` (which plan 02-01 already required a hot **restart** to establish; if your session has been continuously running since before 02-01 without a restart, use `R` instead to be safe). If `r` produces any analyzer/incremental-compile error, fall back to `R`.

### The walk to perform (from the plan's Task 3 human-check)

1. Close the reference Release exe at `GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe` if running (shares the Hive data dir with your build — the two deadlock on lock files).
2. With your app reloaded, walk every currently-reachable route: splash → onboarding → dashboard → transactions → token detail → send → swap → bridge → markets → news → buy → settings → logs. Confirm no color shift, no spacing shift, no font change, no startup exception, no crash on any route transition.
3. **Specifically check the two `greenBlueGreenGradient` call sites:**
   - The swap settings drawer (open swap, then its settings drawer — `swap_settings_drawer.dart:68`)
   - The Banxa buy screen (`banxa_buy_screen.dart:318`)
   - **The gradient on both must still run TOP-TO-BOTTOM, blue at the top, green at the bottom.** If it now runs left-to-right, or looks brighter, the legacy alias was accidentally ported — this would be a Rule-1 bug requiring revert of Task 3.
4. Check the shell header height looks identical to before (`appBarHeight` = 60, unchanged).
5. Open any existing screen with a text field and confirm the label sits pinned ABOVE the field, not inside it as placeholder text (finding 36) — this holds for free since `theme.dart` is untouched, confirmed by the zero-diff gate above; the visual check exists only to catch a regression.

**Expected result: literally zero observable difference anywhere.** Please confirm back (or report anything that looks different) so this plan's human-check can be marked complete before Phase 2 proceeds to 02-04/02-05, which build on these tokens.

## Files Created/Modified

- `lib/theme/genius_wallet_colors.dart` — appended new semantic color block (127 insertions, 0 deletions)
- `lib/theme/genius_wallet_consts.dart` — appended space*/radius* scales, re-pointed 6 aliases (34 insertions, 6 deletions)
- `lib/theme/genius_wallet_gradient.dart` — appended brandCta/brandBorder/heroWash (33 insertions, 0 deletions)

## Decisions Made

- `appBarHeight` deferral: develop's `appBarHeight = 60` was kept untouched. The design branch's `65` is a real, deliberate visual change (not a token rename) and is still read twice by `responsive_overlay.dart` (toolbar `Size` and container height) — changing it here would re-skin the shell header, violating ROADMAP criterion 2. Recorded for Phase 4 (Navigation shell & chrome), which is the phase that re-skins the header consuming it.
- No other deviations from the plan's specified content. All three files ported exactly the members the plan named, in the order and shape specified, with the exact exclusions (compatibility-alias/legacy-constants block in colors.dart; the `greenBlueGreenGradient` legacy alias in gradient.dart) called out.

## Deviations from Plan

None — plan executed exactly as written. No Rule 1-4 auto-fixes were needed; no architectural questions arose. The only "deletions" in this plan (consts.dart's 6 alias lines) were the plan's own documented, pre-verified exception, not a deviation.

## Issues Encountered

None. `flutter analyze` required locating the pinned Flutter SDK (`C:/Users/User/Documents/Projects/GNUS/flutter/flutter/bin`, not on the default shell PATH) — a tooling/environment note, not a code issue.

## User Setup Required

**Action needed: reload your running debug session and perform the visual walk above.** This plan's mechanical gates (deletion counts, grep proofs, `flutter analyze`) all pass, but per this plan's own verification philosophy, that is proof of *additivity*, not proof of *no visual change* — only the human walk closes that loop. See "Verification — OUTSTANDING" above for the full walk and the exact gradient-direction check that would catch the one failure mode this plan exists to prevent.

## Next Phase Readiness

- All new token names 02-04 (typography/elevation/motion/decorations files) and 02-05 (probe surface) depend on now exist and compile: brand/surface/text/border/status colors, the gradient stops, the `space*`/`radius*` scale, and `brandCta`/`brandBorder`/`heroWash`.
- `theme.dart` and `main.dart` remain byte-identical to before this plan (verified via `git diff --numstat`), confirming this plan stayed additive-only per UI-SPEC section 1.
- **Blocker for phase sign-off:** the Task 3 visual walk (this plan's real acceptance test) is pending the user's reload-and-walk above. Do not consider ROADMAP Phase 2 success criterion 2 closed for this plan's scope until that walk is confirmed — this is the highest-severity outstanding item in the whole phase given what this plan guards against (T-02-09 in the threat register: an undetected re-skin passing as "verified").

---
*Phase: 02-design-tokens-verification-loop*
*Completed: 2026-07-16*

## Self-Check: PASSED

All 3 modified theme files found on disk; SUMMARY.md found on disk; all 3 task commits (`a88945f`, `b415243`, `75c8505`) found in git log.
