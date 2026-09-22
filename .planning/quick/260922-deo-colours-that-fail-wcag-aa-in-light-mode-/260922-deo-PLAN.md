---
quick_id: 260922-deo
slug: colours-that-fail-wcag-aa-in-light-mode
date: 2026-09-22
mode: quick
branch: fix/light-mode-contrast
files_modified:
  - lib/theme/gw_colors.dart
  - lib/theme/genius_wallet_colors.dart
  - lib/banxa/banxa_components/order_status_style.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - lib/components/inputs/gw_checkbox.dart
  - lib/components/inputs/gw_switch.dart
  - test/theme/theme_contrast_test.dart
  - test/theme/disabled_control_contrast_test.dart
  - test/theme/gw_colors_parity_test.dart
must_haves:
  truths:
    - A success or error status pill label is legible at WCAG AA in light mode on every surface it appears on.
    - A disabled GWCheckbox is visible against the canvas in dark mode instead of vanishing.
    - A disabled GWSwitch is visibly different from a switch that is merely off, in both appearances.
    - A disabled label on either control is legible in dark mode.
  artifacts:
    - lib/theme/gw_colors.dart carries statusSuccessText and statusErrorText
    - test/theme/disabled_control_contrast_test.dart
  key_links:
    - The two pill palettes (orderStatusPaint, txStatusColors) stay byte-identical in shape, so Part 8's single loop keeps covering both.
    - borderControl stays the ONE control-edge token; the disabled treatments read it rather than inventing a disabled-only colour.
estimate:
  tokens: 70000
  raw_tokens: 50000
  tasks: 3
  confidence: low
---

# Quick task: the two colour groups that still fail AA in light mode

Both defects have the same shape and the same fix precedent already in the tree.

**Group 1 — status pill text.** `orderStatusPaint()` and `txStatusColors()` paint the pill label in
the *same* token they use for the translucent wash behind it. Because the wash is a tint of that
same hue, darkening the label lightens its backdrop by the same move, so the pair never separates.
The warning tone was fixed this way on 2026-07-29 by adding a second, foreground-purposed token
(`statusWarningText`) and leaving the fill token alone. Success and error get the identical
treatment. Measured light-mode label-on-its-own-wash today: success 3.77 / 3.39 / **2.91**, error
3.89 / 3.49 / **2.99** (elevated / menu / base) — two of those are under even the 3:1 non-text floor.

**Group 2 — disabled controls.** `GWCheckbox` paints its disabled side and fill in `borderSubtle`,
which measures **1.27–1.43:1** against every surface in both modes — that is the "invisible" in the
todo, and it is not a dark-only defect. `GWSwitch` has no disabled branch at all: Flutter's
`Switch` resolves the legacy `inactiveThumbColor` / `activeTrackColor` shorthands *without*
consulting `WidgetState.disabled` (`switch.dart`'s `_widgetTrackColor`), so a disabled switch paints
exactly like an off one. The only way to get a disabled branch is the stateful `thumbColor:` /
`trackColor:` parameters, which Flutter checks first. Both controls also paint their disabled label
in `textTertiary` (`#35363D`, mode-invariant ink) — **1.45–1.62:1** on the dark canvas.

## Three decisions, each already measured

**1. Two new foreground tokens, seeded per mode, mirroring `statusWarningText` exactly.**
`statusSuccessText` light `#065F46` (emerald-800 — a hue-exact darker step of `statusSuccess`
`#07875F`), `statusErrorText` light `#991B1B` (red-800 — the direct mirror of `statusWarningText`'s
amber-800). Dark keeps `statusSuccess` / `statusError` unchanged, exactly as `statusWarningText`
dark keeps `statusWarning`. Both are omitted from the `GWColors.light()` / `.dark()`
value-preservation asserts for the same reason the other divergent tokens are. The washes do **not**
change — they are genuine fills and those tokens are tuned for it.

**2. `borderControl` is the disabled-chrome token; its light alpha goes 0.46 → 0.48.** Do not invent
a disabled-only colour — `borderControl` exists precisely as "the edge of a control whose fill
cannot identify it", at 3:1. But its own doc records that light's 46% was derived against **white
only**; on the other light surfaces it measures 3.03 / 2.92 / 2.84 (menu / base / sunken) and misses
its own promise. The onboarding legal checkbox sits on the bare Scaffold canvas, so base is a real
case, not a hypothetical. 0.48 is the first 2-point step that clears 3:1 on **all four** light
surfaces (3.29 / 3.21 / 3.09 / 3.00) — the same "first step that clears 3:1" reasoning the token's
doc used to arrive at 36% in dark, which is untouched. A darker hairline can only raise contrast, so
Part 4's existing `>= 3:1` drawer-edge assertion strengthens rather than breaks.

**3. Disabled must stay *distinct*, not merely visible.** Checkbox disabled side and fill →
`borderControl` (3.09–3.29 light / 3.23–3.33 dark vs the surface), checkmark stays `textPrimary`
(4.54–5.65 light / 5.22–6.21 dark vs that fill — the 3:1 non-text floor applies, it is a glyph).
Switch disabled → thumb `textSecondary`, track `surfaceMenu`, outline `borderControl`: thumb-vs-track
5.61 light / 5.39 dark, outline-vs-track 3.21 / 3.33, and disabled thumb vs the enabled-off thumb
(`textPrimary`) separates by 2.95 / 3.23 — dimmer ink plus a defined ring, never a look-alike of off.
Disabled label on both → `textSecondary` (4.75–6.30 light / 5.39–6.01 dark).

<tasks>

<task type="tracer" tdd="true">
  <name>Task 1: statusSuccessText / statusErrorText, and the two fg slots that read them</name>
  <files>lib/theme/gw_colors.dart, lib/banxa/banxa_components/order_status_style.dart, lib/dashboard/home/widgets/transaction_displays.dart, test/theme/theme_contrast_test.dart, test/theme/gw_colors_parity_test.dart</files>
  <read_first>lib/theme/gw_colors.dart:226-261 (statusWarningText and textMutedOnSunken — copy this token shape, including the omission from the light()/dark() asserts), test/theme/theme_contrast_test.dart Part 8 (:624-710)</read_first>
  <behavior>
    - Part 8's light-mode test covers all three tones, not warning alone, and fails if either fg slot is pointed back at the fill token.
    - success label on its wash, light: >= 4.5:1 (expect 6.39 / 5.75 / 4.94 on elevated / menu / base).
    - error label on its wash, light: >= 4.5:1 (expect 6.72 / 6.03 / 5.17).
    - Dark mode is unchanged and still passes: the new tokens resolve to statusSuccess / statusError there.
  </behavior>
  <action>Add `statusSuccessText` and `statusErrorText` to `GWColors` — field, constructor param, `copyWith`, and both factories — following `statusWarningText` in every respect: light gets the literal, dark reads the matching `GeniusWalletColors` fill, and neither appears in the value-preservation asserts. Light values are `#065F46` and `#991B1B`. Doc comment each in 3 lines max, saying what the token is FOR and why the fill token cannot serve; no plan, phase or quick ids, no test filenames. Then repoint `orderStatusPaint`'s success and error `fg:` slots and `txStatusColors`'s success and error `fg:` — foreground only, the `bg:`/`wash:` stay on `statusSuccess`/`statusError`. Delete the now-obsolete `ponytail:` block in `transaction_displays.dart` around :120-130 and the matching exclusion note in Part 8, and fold the two tones into the existing light-mode loop so one test covers all three. `gw_colors_parity_test.dart` constructs every field by name and will need the two additions; `flutter analyze` names any other call site.</action>
  <verify>
    <automated>export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" && flutter test test/theme/</automated>
  </verify>
  <done>Part 8 asserts all three tones at >= 4.5:1 in both modes and passes; no exclusion note remains in the test or in `transaction_displays.dart`.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: visible, distinct disabled states for checkbox and switch</name>
  <files>lib/theme/genius_wallet_colors.dart, lib/components/inputs/gw_checkbox.dart, lib/components/inputs/gw_switch.dart, test/theme/disabled_control_contrast_test.dart</files>
  <read_first>lib/theme/genius_wallet_colors.dart:203-227 (_borderControl and its measurement table), test/theme/control_track_contrast_test.dart (copy this file's whole idiom — the `contrastRatio`/`themeFor` import, the per-mode loop, and the closing test that pins the defect so the fix can be deleted when it is no longer needed)</read_first>
  <behavior>
    - Disabled checkbox fill and side clear 3:1 against surfaceElevated / surfaceMenu / surfaceBase in both modes.
    - The checkmark clears 3:1 against that disabled fill in both modes.
    - Disabled switch thumb clears 3:1 against its track, and the disabled outline clears 3:1 against the track, in both modes.
    - Disabled switch thumb differs from the enabled-off thumb by >= 2.9:1, so disabled cannot be mistaken for off.
    - A closing test pins `borderSubtle` below 3:1 on every surface, so if it ever becomes AA-safe this fix can be reverted rather than kept forever.
  </behavior>
  <action>In `genius_wallet_colors.dart`, change `_borderControl`'s light branch from ink at 0.46 to ink at 0.48 and update the measurement table in its doc to record that 46% cleared 3:1 on white alone while 48% clears it on every light surface. In `gw_checkbox.dart`, swap both `borderSubtle` reads (the `side` disabled arm and the `fillColor` disabled arm) to `gw.borderControl`, and change the disabled label colour from `textTertiary` to `gw.textSecondary`. In `gw_switch.dart`, replace the four legacy shorthands with stateful `thumbColor:` and `trackColor:` resolvers whose FIRST branch is `WidgetState.disabled` — thumb `gw.textSecondary`, track `gw.surfaceMenu` — keeping the existing selected/unselected values on the later branches; add the same disabled branch to the existing `trackOutlineColor` resolver returning `gw.borderControl`; and change its disabled label colour to `gw.textSecondary` too. Brace every `if` with the body on its own line. Then write `test/theme/disabled_control_contrast_test.dart` asserting the pairs above by reading the tokens through `themeFor(mode).extension&lt;GWColors&gt;()!`, compositing the translucent ones with `Color.alphaBlend` before measuring. Write that file with LF endings.</action>
  <verify>
    <automated>export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" && flutter test test/theme/ && bash tool/check_brace_style.sh && bash tool/check_raw_colors.sh && git ls-files --eol test/theme/disabled_control_contrast_test.dart</automated>
  </verify>
  <done>The new test passes in both modes; the brace and raw-colour gates pass; `git ls-files --eol` reports `lf` for the new file.</done>
</task>

<task type="auto">
  <name>Task 3: close the todos and run the full gates</name>
  <files>.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md, .planning/todos/pending/2026-07-18-dark-mode-disabled-state-visibility-checkbox-switch.md</files>
  <precondition>Neither todo file appears in `git diff --name-only origin/develop...origin/docs/close-resolved-todos -- .planning/todos/`; that branch owns 33 files there and a `git mv` of a file it also touches will collide. If either IS listed, append the `## Closed` note in place and leave the move to the owning branch.</precondition>
  <action>Append a `## Closed 2026-09-22 (quick 260922-deo)` section to each, matching `.planning/todos/completed/2026-07-18-no-user-facing-appearance-toggle.md`: what changed, the measured ratios, and what the guard is. Then `git mv` the status-pill todo to `completed/`. The disabled-state todo is only PARTLY closed — its two named defects are fixed, but its last paragraph also asks to bake the WCAG contrast rule into the UI-SPEC design contract, and that is untouched here; leave that file in `pending/` with a dated note saying which part remains, and trim its Problem section to the surviving item. Record two findings the measurements surfaced but this task deliberately does not chase: `statusSuccess`/`statusError` read as plain-surface TEXT (~40 call sites) measure 4.03 / 3.42 and 4.29 / 3.63 on light menu / base and fail AA the same way the pill did, and an ENABLED switch's track outline is `borderSubtle` at 1.28–1.43:1 while the track itself is only 1.15–1.33:1 from its canvas, so nothing identifies the component. File each as its own new file in `.planning/todos/pending/` — one file per item, never a shared list.</action>
  <verify>
    <automated>export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH" && dart format --set-exit-if-changed lib test && flutter analyze; echo "analyze exit=$?" && flutter test && bash tool/check_brace_style.sh && bash tool/check_raw_colors.sh</automated>
  </verify>
  <done>Full suite is at the 1550 pass / 5 skip / 0 fail baseline plus the new tests, with real output quoted in the summary; `analyze` is at its known baseline; both gates pass.</done>
</task>

</tasks>

## Out of scope

- The ~40 call sites that read `statusSuccess` / `statusError` as text on a plain surface. Repointing
  them is a separate, much larger pass; Task 3 files it.
- The enabled switch's track outline (a real 1.4.11 gap, filed by Task 3, not fixed here).
- `transaction_displays.dart:389`'s direct `gw.statusError` on the receipt Status row — same family
  as the previous bullet.
- Any light-mode visual walk. Project policy is dark ships and gets walked; light is backlog. This
  task is the measurable half and lands entirely in unit tests.
- `lib/theme/gw_appearance.dart`, `lib/theme/theme.dart`, `lib/settings/settings_screen.dart` — owned
  by `feat/appearance-control`. `gw_colors.dart` and `genius_wallet_colors.dart` are not.
- Commits are per task, no Claude attribution. No push, no PR, no merge.
