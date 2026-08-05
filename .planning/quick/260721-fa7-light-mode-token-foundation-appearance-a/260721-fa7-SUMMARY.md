---
phase: quick-260721-fa7
plan: 01
subsystem: theme / accessibility
status: complete
tags: [wcag, contrast, theme, tokens, tdd, accessibility, dark-mode, light-mode]
requirements: [Q3-1, Q3-2, Q3-3, Q3-4]
completed: 2026-07-21

key-files:
  created:
    - test/theme/theme_contrast_test.dart
  modified:
    - lib/theme/genius_wallet_colors.dart
    - lib/theme/nav_chip_style.dart
    - lib/theme/theme.dart
    - lib/components/buttons/gw_button.dart
    - lib/reown/reown_connect_button.dart
    - test/theme/nav_chip_style_test.dart

key-decisions:
  - "#0A6885 chosen over the audit's #0B6E8F for the light on-surface token: #0B6E8F measures 4.352:1 on surfaceBase (#DCE0E6), below the 4.5 AA text threshold, so the audit's 'clears AA on all three light surfaces' claim was false. #0A6885 clears 4.76:1 on the same surface with real margin (6.30/5.61/4.76 on surfaceElevated/surfaceMenu/surfaceBase)."
  - "textOnBrand (not textPrimary) is the correct foreground for content painted on brandPrimaryStrong fills — extends the pattern theme.dart:36-38 already applies to ColorScheme.onPrimary/onSecondary to three previously-unfixed sites (checkbox checkmark, datePicker header label, datePicker selected-day label), which were shipping at 2.56:1 (AA fail) in dark mode."
  - "New token lives on GeniusWalletColors as a static getter, not mirrored onto the GWColors ThemeExtension — getThemeData() has no BuildContext and is the primary consumer (6 of 8 repointed sites); GWColors is deliberately not extended for a token with zero non-theme consumers today (YAGNI, per AGENTS.md)."

patterns-established:
  - "brandPrimaryOnSurface: appearance-aware token for content painted ON a surface (foreground text, outlines, focus rings, indicators), explicitly distinct from brandPrimaryStrong which is a fill. Light = darker step (#0A6885); dark = reuses brandPrimaryStrong unchanged."
  - "RED-before-GREEN TDD cycle for theme contrast, proven against real getThemeData() output rather than isolated hex literals — test/theme/theme_contrast_test.dart is the first runnable guard against the white-on-brand-fill defect class that has now shipped three times."

coverage:
  - id: D1
    description: "Appearance-aware GeniusWalletColors.brandPrimaryOnSurface token added; nav_chip_style.dart's connectBrandColor delegates to it; two stale '~2.1:1' comments corrected to the recomputed 2.56:1"
    verification:
      - kind: unit
        ref: "test/theme/nav_chip_style_test.dart#Connect brand colors clear 4.5:1 AA in both modes"
        status: pass
    human_judgment: false
  - id: D2
    description: "Dark-mode AA failure fixed: checkbox checkmark, datePicker header label, datePicker selected-day label move from textPrimary (white, 2.56:1) to textOnBrand (7.74:1) against brandPrimaryStrong fills, in both modes"
    verification:
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 2: foreground-on-brand-fill pairings clear 4.5:1 (both modes) (6 tests)"
        status: pass
    human_judgment: false
  - id: D3
    description: "Five theme focus/selection properties (progress indicator, tab indicator, input focus ring, dropdown focus ring, checkbox side) and GWButton's secondary variant repointed to brandPrimaryOnSurface, clearing 4.5:1 on all three light surfaces in both modes"
    verification:
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 3: focus/selection states + GWButton secondary (6 tests)"
        status: pass
    human_judgment: false

metrics:
  duration: not precisely tracked (single continuous session)
  tasks: 3
  files: 7
---

# Quick 260721-fa7: Light-mode token foundation + dark-mode AA fix Summary

Added one new appearance-aware token (`GeniusWalletColors.brandPrimaryOnSurface`), fixed a shipped dark-mode WCAG AA failure (white-on-brand-fill at 2.56:1 — the third recurrence of this exact defect class) by routing three sites through `textOnBrand` instead, and repointed eight theme properties plus `GWButton`'s secondary variant to the new token so every light-mode focus ring, indicator, and secondary CTA now clears 4.5:1 against all three light surfaces. All of it is now guarded by a runnable contrast test built against real `getThemeData()` output, proven RED before it was made GREEN.

## 1. RED evidence — the third recurrence, caught by a real test for the first time

Before touching `theme.dart`, `test/theme/theme_contrast_test.dart`'s Part 2 group was run against the **unmodified** code and failed on all three dark-mode assertions (checkbox `checkColor(selected)` vs `fillColor(selected)`; datePicker `headerForegroundColor` vs `headerBackgroundColor`; datePicker `dayForegroundColor(selected)` vs `dayBackgroundColor(selected)`), each measuring:

```
Actual: <2.5578684407329573>
```

That is `white` (`#FFFFFF`) on `brandPrimaryStrong` (`#0AAEE6`) — the exact defect `theme.dart:36-38` already rejects for `ColorScheme.onPrimary`/`onSecondary`, recurring at three more sites the color scheme doesn't cover. Light mode passed at 7.26:1 in the same RED run, matching the plan's prediction exactly. This is the strongest evidence available that the assertion measures the real defect rather than an artifact of the test itself — the coordinator independently recomputed the same figure to four decimals (2.5579) via WCAG relative luminance.

After the three `theme.dart` edits (`textPrimary` → `textOnBrand` in the selected/header branches only; fills and disabled/default branches untouched), the same six assertions (three pairings × two modes) went GREEN at **7.74:1** in both modes. Task 3 repeated the same RED→GREEN discipline for the five focus/selection properties and `GWButton`'s secondary variant: dark-mode `checkboxTheme.side` failed on RED (still `brandPrimary` not the token) while `GWButton` dark passed on RED (it already used `brandPrimaryStrong`, which coincides with the token's dark value) — both outcomes matched the plan's blast-radius table before any fix was applied.

## 2. The audit that commissioned this task was refuted, not confirmed

The originating audit claimed `#0B6E8F` "clears AA on all three light surfaces" (5.77 on white, 4.9 on `#EFF2F6`, 4.35 on `#DCE0E6`). Recomputed during planning and re-verified here: `#0B6E8F` on `#DCE0E6` — the plan's own luminance table labels this `surfaceBase`, not `surfaceSunken` — measures **4.3524:1**, below the 4.5 AA text threshold. The audit's summary sentence was false; only its raw numbers (mostly) checked out. `#0A6885` was chosen instead — a deliberate darkening that clears **4.7567:1** on the same surface with real margin, at the cost of nothing (the light pass had never been human-walked, per STATE.md, so no approved visual was disturbed). This was independently recomputed and confirmed before any code was touched, and is why the token's doc comment in `genius_wallet_colors.dart` records `#0B6E8F`'s miss explicitly rather than silently adopting the audit's figure.

## 3. Deviations from Plan

**1. Transient `flutter analyze lib` reading of 62 vs the 61 baseline.**
- **Found during:** Task 2 verification, immediately after the `theme.dart` textOnBrand edits.
- **Issue:** One `flutter analyze lib` run reported 62 issues; re-running immediately after (no code changes in between) reported 61.
- **Resolution:** Treated as an analyzer-server warm-up artifact, not a real regression — re-confirmed 61 on every subsequent run through the end of Task 3, including the final combined check.
- **Impact:** None. No code fix required.

**2. `grep -c "textOnBrand" lib/theme/theme.dart` returned 8, not the plan's predicted 7 — and my own first attempt at explanatory comments made it worse (11), which is the exact self-inconsistent-gate failure mode this project has hit twice today.**
- **Found during:** Task 2 done-criteria verification.
- **Root cause (plan-side):** The plan's arithmetic ("4 pre-existing onPrimary/onSecondary uses... plus the 3 added" = 7) missed that `theme.dart:36` already carries a pre-existing **comment** containing the literal word "textOnBrand" (`// textOnBrand (near-black), matching the light scheme...`). Actual pre-existing count is 5 (lines 16, 18, 36-comment, 38, 40), not 4. My 3 new code sites (headerForegroundColor, selected dayForegroundColor, checkColor) are exactly the ones the plan specified — the true, minimal-consistent count is **8**.
- **Root cause (my-side, self-inflicted, now fixed):** My first draft of the explanatory comments at each of the 3 new sites *also* spelled out the literal identifier "textOnBrand" in prose (e.g., "textOnBrand moves it 2.56 -> 7.74:1"), which pushed the grep count to 11 — a `grep -c` gate is line-based, not occurrence-based, so a comment merely *mentioning* a token name inflates a check meant to count real usages. This is structurally the same hazard as the string-assertion trap the plan itself warned about for `focusedBorder.toString()`.
- **Fix:** Reworded every explanatory comment I added (in `theme.dart` and `genius_wallet_colors.dart`) to describe the token by its role ("the near-black on-brand foreground below", "the on-surface brand getter below") instead of repeating its literal identifier in prose. After the reword, `grep -c "brandPrimaryOnSurface" lib/theme/theme.dart` returns exactly the plan-predicted **5**, and `grep -c "floatingLabelBehavior: FloatingLabelBehavior.always"` returns the plan-predicted **1**. `grep -c "textOnBrand"` still returns **8** rather than 7 because the *plan's own count* was wrong about pre-existing content, not because of anything in this fix — that discrepancy is recorded here rather than "corrected" by editing a pre-existing, unrelated comment at `theme.dart:36` (which is out of this task's scope).
- **Verification:** All 16 test assertions across both files still pass after the reword; `flutter analyze lib` still 61.
- **Impact:** No functional impact. Improves the reliability of future `grep -c`-based done-criteria for this and other plans — a lesson worth carrying forward given this is (per the coordinator) the second time today a check counted comment text instead of real usage.

**Total deviations:** 2, both documentation/gate-accuracy issues, zero functional impact, zero scope creep.

## 4. Deliberately NOT done, and why (not oversights)

- **`theme.dart:318,323,339,342`** (`navigationRailTheme`/`bottomNavigationBarTheme` selected label + icon) paint raw `brandPrimaryStrong` on light's `surfaceElevated` at the same 2.5579:1 defect class. A 4-line fix with the identical token and **zero** dark-mode delta — but it is not in this task's enumerated brief, and STATE.md records "Navbar = FINAL" as a pending human decision. Expanding into it unasked would be exactly the silent scope drift this project keeps getting bitten by. Left alone; raised for a human decision instead.
- **Light-mode `statusWarning`.** Today's `#FFC42E` measures 1.59:1 on white and 1.42:1 on `surfaceMenu` — genuinely broken — but has zero consumers in this task's scope. The audit's Q4b workstream adds a token beside its first consumer in a single coherent commit; adding it here with no consumer would violate AGENTS.md's YAGNI rung with no offsetting benefit.
- **`wallet_overview.dart:142-144`'s stale 1.96:1/10.12:1 ratio comment.** The plan explicitly deferred this "disjoint, comment-only edit" because the concurrent Phase 05 executor's B1 fix restructures the exact widget region (`_buildToggle()`) this comment sits in — two agents whole-file-writing the same file in one working tree is a lost-update, not a merge. The correction (the real fill is `brandPrimaryStrong`, giving 2.5579:1 rejected / 7.7375:1 shipped, not the comment's stale `brandPrimary`-based figures) is recorded in the plan's `<deferred>` section for whoever next edits that file.

## 5. Verification status — machine-checked, no human walk needed

- `flutter test test/theme/theme_contrast_test.dart` — **12/12 pass** (6 Part 2 + 6 Part 3, both modes).
- `flutter test test/theme/nav_chip_style_test.dart` — **4/4 pass**, still green, now token-backed instead of a duplicated hex literal.
- `flutter analyze lib` — **61 issues**, matching baseline exactly, never exceeded.
- `git diff --stat` on this task's 7 files matches `files_modified` exactly; `reown_connect_button.dart` shows exactly 1 insertion/1 deletion (comment only); `gw_button.dart`'s 6 other variants (`primary`, `tertiary`, `ghost`, `destructive`, `icon`, `gradient`, `gradientOutline`) are byte-unchanged; no fill color (`:102`/`headerBackgroundColor`, `:110`/`todayBackgroundColor`, `:125`/`dayBackgroundColor`, `:361`/`fillColor`) was touched; no theme *shape* property (padding, size, radius, density, typography) changed anywhere.

**This task needs no human walk of its own.** Every `must_haves.truths` claim in the plan frontmatter is proven by a passing, RED-before-GREEN assertion against real `getThemeData()`/`GWButton` output — not asserted, not eyeballed. This is the first task on this project able to make that claim plainly, now that `flutter test` (per-file invocation) is confirmed to work. If a fourth recurrence of the white-on-brand-fill defect is ever introduced, `theme_contrast_test.dart` fails a check instead of shipping.

## Task Commits

No commits — **not staged, not committed**, per this task's COMMIT_POLICY. A concurrent executor is running on disjoint files in the same working tree; the orchestrator batch-commits all work once both executors finish. STATE.md, ROADMAP.md, and REQUIREMENTS.md were not touched.

## Files Created/Modified

- `test/theme/theme_contrast_test.dart` (new) — RED-before-GREEN contrast guard against real `getThemeData()`/`GWButton` output; 12 assertions across 3 groups (Part 2 foreground-on-fill pairings, Part 3 focus/selection identity + ratio checks, Part 3 `GWButton` secondary).
- `lib/theme/genius_wallet_colors.dart` — added `brandPrimaryOnSurface` (light `#0A6885` / dark `brandPrimaryStrong`) with doc comment recording measured ratios and the `#0B6E8F` rejection.
- `lib/theme/nav_chip_style.dart` — `connectBrandColor` delegates to the shared token; dropped now-unused `gw_appearance.dart` import; corrected the "~2.1:1" doc comment to 2.56:1.
- `lib/theme/theme.dart` — 8 property repoints (`progressIndicatorTheme.color`, `tabBarTheme.indicatorColor`, `datePickerTheme.headerForegroundColor`, `dayForegroundColor` selected branch, `inputDecorationTheme.focusedBorder`, `dropdownMenuTheme` nested `focusedBorder`, `checkboxTheme.side`, `checkboxTheme.checkColor` selected branch) plus 4 `const` drops where a getter replaced a literal.
- `lib/components/buttons/gw_button.dart` — `secondary` variant's `foreground`/`border` repointed to the token; all 6 other variants untouched.
- `lib/reown/reown_connect_button.dart` — comment-only correction (1 insertion/1 deletion), no code or color logic touched (owned by the concurrent Q4b workstream).
- `test/theme/nav_chip_style_test.dart` — light-mode assertion now reads the token (not a duplicated hex literal) and covers all three light surfaces, not white alone.

## Decisions Made

See `key-decisions` in frontmatter — summarized: chose `#0A6885` over the audit's `#0B6E8F` (which fails AA on `surfaceBase`); routed the dark-mode fix through `textOnBrand` rather than a new token (extends an existing, already-correct pattern); kept the new token on `GeniusWalletColors` rather than mirroring it onto `GWColors` (no `BuildContext` available in `getThemeData()`, zero non-theme consumers today).

## Deviations from Plan

See section 3 above (RED/GREEN evidence integrated there per coordinator request) — 2 deviations, both documentation/gate-accuracy issues with zero functional impact.

## Issues Encountered

None beyond the two deviations documented above (both self-resolved during verification, no external blockers).

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- The `brandPrimaryOnSurface` token and `theme_contrast_test.dart` guard are ready for reuse by any future light-mode contrast work, including the deferred navRail/bottomNav sites and Q4b's `statusWarning` addition.
- Pending human decision, not a blocker: whether to extend this same token to `theme.dart:318,323,339,342` (navRail/bottomNav), currently held back only by STATE.md's "Navbar = FINAL" status.
- `wallet_overview.dart:142-144`'s comment correction is queued for whoever next touches that file (concurrent executor's B1 fix region).

---
*Phase: quick-260721-fa7*
*Completed: 2026-07-21*
