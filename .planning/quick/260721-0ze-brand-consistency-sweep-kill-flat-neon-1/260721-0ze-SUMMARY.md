---
phase: quick-260721-0ze
plan: 01
subsystem: theme / components / navigation
status: complete
tags: [brand, theme, cta, navigation, gradient, tokens]
requirements: []
completed: 2026-07-21
key-files:
  created: []
  modified:
    - lib/components/buttons/gw_button.dart
    - lib/components/overlay/responsive_overlay.dart
    - lib/theme/theme.dart
    - lib/dashboard/home/widgets/transactions_slim_view.dart
    - lib/components/wallet_overview.dart
    - lib/account/account_dropdown_selector.dart
    - lib/account/sdk_account_manager.dart
    - lib/components/inputs/gw_switch.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/components/inputs/gw_select.dart
    - lib/components/inputs/gw_checkbox.dart
decisions:
  - "Primary CTA gradient applied via one central _palette() edit (mirrors the .gradient case); no per-call-site churn."
  - "brandPrimaryStrong (#0AAEE6) reused directly at every solid-highlight site — zero new tokens, zero alias."
  - "Desktop nav underline uses gradient/color mutual-exclusion per selected state to avoid Flutter's both-set BoxDecoration assert."
metrics:
  duration: ~12min
  tasks: 3
  files: 11
---

# Quick 260721-0ze: App-wide brand-consistency sweep — kill flat neon Summary

Replaced the flat neon cyan `brandPrimary` (#14C8FF) app-wide: filled primary CTAs now paint the `brandCta` green→blue gradient (single central `GWButton` edit), the desktop nav active state is a gradient underline + solid deep-cyan `brandPrimaryStrong` text/icon, and every other enumerated highlight/selection site swaps to solid `brandPrimaryStrong` (#0AAEE6). Pure token/decoration swaps — no new tokens, deps, or files.

## Tasks

### Task 1 — Primary CTA → brandCta gradient (central) + header Buy GNUS fill
- `gw_button.dart` `_palette()` primary case: `background` → `gradientBlue`, added `gradient: GeniusWalletGradient.brandCta`, kept `textOnBrand` foreground / null border (now identical to the `.gradient` case). Propagates to every primary CTA app-wide.
- `gw_button.dart` `_overlay()`: added `case GWButtonVariant.primary:` sharing the gradient body (hover 0.12 / press 0.18) so primary gets the same white brighten wash. Pointer cursor was already variant-agnostic — untouched.
- `responsive_overlay.dart` header "Buy GNUS": `secondary` (outline) → `gradient` (filled), matching the coins-screen Buy GNUS.

### Task 2 — Nav active state: gradient underline + brandPrimaryStrong text/icon
- Added `import '.../genius_wallet_gradient.dart'`.
- Desktop active text/icon `color`: selected branch → `brandPrimaryStrong`.
- Desktop underline `AnimatedContainer` `BoxDecoration`: selected → `gradient: brandCta` (color null); unselected → `color: Colors.transparent` (gradient null). Mutual exclusion avoids the both-set assert; height/width/radius unchanged.
- Mobile bottom nav: `selectedItemColor`, `selectedIconTheme.color`, `selectedLabelStyle.color` → `brandPrimaryStrong`. Unselected + surfaceSheen background untouched.

### Task 3 — theme.dart + per-widget highlight sites → brandPrimaryStrong
- `theme.dart` (11 sites): tabBar `indicatorColor`; datePicker `headerBackgroundColor`, today-selected + day-selected background returns; inputDecoration `focusedBorder`; dropdownMenu `focusedBorder`; navigationRail `selectedLabelTextStyle` + `selectedIconTheme`; bottomNav `selectedItemColor` + `selectedIconTheme`; checkbox `fillColor` selected return.
- Per-widget: `transactions_slim_view` SegmentedButton `selectedBackgroundColor`; `wallet_overview` ToggleButtons `fillColor`; `account_dropdown_selector` `selectedTileColor` + avatar `backgroundColor`; `sdk_account_manager` `accentColor` selected branch + selected border; `gw_switch` `activeColor` + `activeTrackColor`; `gw_text_field` focused `_border`; `gw_select` focused `_border`; `gw_checkbox` side border selected + fill selected return.

## Deliberately left untouched (per plan scope)
- `theme.dart`: colorScheme `primary`/`outline`, `progressIndicatorTheme` (spinner), datePicker enabled-border / today-border / range + drag tints, elevatedButton border, `cursorColor`, checkbox `side` border.
- `gw_text_field.dart:100` `cursorColor`.
- Out-of-scope widgets (gw_swap_fab, gw_spinner, qr_scanner, sgnus_connection_widget, reown_connect_button, gw_mesh_background, elevation), Assets panel (coins_screen/coin_card_row), *.g.dart, /banxa, /squidrouter.

## Regression check — Assets panel
Confirmed by grep: `coins_screen.dart` / `coin_card_row.dart` use `GWButtonVariant.gradient` and `.gradientOutline` (not `.primary`), so the central primary→gradient change does not touch them.

## Deviations from Plan
None — plan executed exactly as written (Rules 1-4 not triggered).

## Verification
`flutter analyze` across all 11 changed files: **2 issues, both pre-existing `info`-level deprecations not introduced by this task** — `gw_select.dart:47` (`value` param deprecated, untouched line) and `gw_switch.dart:36` (`activeColor` *property* deprecated; the swap only changed the color value, not the property). No new warnings/errors.

```
Analyzing 11 items...
   info • 'value' is deprecated ... • lib/components/inputs/gw_select.dart:47:7 • deprecated_member_use
   info • 'activeColor' is deprecated ... • lib/components/inputs/gw_switch.dart:36:7 • deprecated_member_use
2 issues found. (ran in 4.9s)
```

Grep audit confirmed: 11 `brandPrimaryStrong` sites in theme.dart, all nav tokens + underline gradient in responsive_overlay, and every per-widget swap landed; no enumerated site still references the flat `brandPrimary`.

## Deferred (recorded, not addressed here)
Light-mode WCAG AA: `brandPrimaryStrong` (#0AAEE6) ~2.9:1 on the white canvas for text/small elements — dark-first, deferred to the dedicated light-mode contrast pass.

## Git
No commits, no `git add` — all 11 edits left UNSTAGED per task constraint (CLAUDE.md forbids commits; main session owns git). STATE.md and ROADMAP.md not touched.

## Self-Check: PASSED
- All 11 modified files exist and contain the swaps (grep-verified).
- No commits created (per constraint) — nothing to verify in git log.
