---
phase: 32-contrast-and-text-scale-accessibility-pass
plan: 01
status: complete
requirements: []
key-files:
  created: [test/theme/enabled_control_contrast_test.dart, test/theme/material_text_slots_test.dart]
  modified: [lib/theme/genius_wallet_colors.dart, lib/theme/gw_colors.dart, lib/components/inputs/gw_switch.dart, test/theme/gw_colors_parity_test.dart, lib/theme/genius_wallet_typography.dart, lib/theme/theme.dart, lib/components/overlay/responsive_overlay.dart, test/components/mobile_nav_destinations_test.dart]
actuals: { tokens: 5970, tasks: 3, commits: 3 }
---

# Phase 32 Plan 01: switch outline, text slots, bar clamp

Closes goals 1, 3, 4: `GWSwitch`'s enabled outline now clears 3:1 against
both tracks via a new `borderControlOnBrand` token; every Material text slot
resolves to Inter via `GeniusWalletTypography.sansFamily` +
`ThemeData.fontFamily`; the phone bar clamps textScaler at
`kMobileBarMaxTextScale` (221/180) via `MediaQuery.withClampedTextScaling`.

## Baseline vs. after (measured)

`flutter test test/theme/ test/components/mobile_nav_destinations_test.dart`:
124/124 pass. `flutter analyze`: "No issues found!", exit 0. `dart format
--set-exit-if-changed` on all 10 touched files: exit 0. `check_brace_style.sh`:
exit 0. Both new test files are LF (`git ls-files --eol`). Each new test
failed before its fix and passed after (RED confirmed by running before the
token/theme/clamp edits landed).

## Deviations

None — plan executed exactly as written. Dark outline alpha used the plan's
corrected 58% (not research's original 56%), as the plan itself specified.

## Self-Check: PASSED

Commits 28115898, 9975717e, 5435ea68 verified present in `git log`; both new
test files verified present on disk.
