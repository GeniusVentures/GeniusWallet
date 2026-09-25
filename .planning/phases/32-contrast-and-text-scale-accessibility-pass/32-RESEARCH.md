# Phase 32: Contrast and text-scale accessibility pass - Research

**Researched:** 2026-09-25
**Domain:** Flutter WCAG AA/1.4.11 contrast remediation + Dynamic Type overflow clamp + Material typography gap, on an existing design-token system (`lib/theme/`)
**Confidence:** HIGH (all four items grounded in code read this session; ratios computed, not estimated)

## Summary

This phase closes four independently-filed, already-diagnosed accessibility defects. None of
them require new libraries, new architecture, or exploration of alternatives — each todo already
names the fix shape; this research supplies the missing numbers (exact hex/alpha values, computed
ratios, exact call-site inventory) so the planner can write tasks with concrete diffs instead of
"measure it during execution."

The most consequential finding: **items 1 and 2 both reduce to the same mechanical pattern this
codebase already uses successfully** — an existing raw fill token (`statusSuccess`/`statusError`)
is unsafe as text/foreground, and an existing AA-safe partner token
(`statusSuccessText`/`statusErrorText`) already exists and is *already byte-identical to the raw
token in dark mode*. Item 2's fix is therefore a mechanical swap at TEXT/ICON call sites only,
zero-risk in dark mode, AA-fixing in light mode. Item 1 needs a new token (no existing one clears
3:1 against both switch tracks) but the exact alpha value is now computed, not guessed.

Item 3's remedy was pre-selected by Braian (2026-09-25, per ROADMAP.md): clamp `textScaler` on the
mobile bar, following `AppBar`'s own precedent. The exact ceiling has a clean closed form,
`17/13.846154 = 221/180 ≈ 1.2278x`, derived from the same constants
`mobile_nav_destinations_test.dart` already asserts.

Item 4 is the smallest fix in scope but the recommended action is *narrower* than the source todo
assumed: `TextButton`/`OutlinedButton`/`ElevatedButton` already read their own `ButtonThemeData`
override (`titleMd`), not `labelLarge` — so mapping `labelLarge` globally will NOT change those
three widget types' rendering at all. The real, currently-Roboto consumers are narrower:
`MenuItemButton` (already patched locally via `menuButtonTheme`), `ActionChip`/`Chip` (no
`chipTheme` exists — confirmed live on the onboarding recovery-phrase word chips), and any future
`SnackBarAction` (none exist in the codebase today, confirmed by grep).

**Primary recommendation:** four independent, low-risk token/config fixes — no new packages, no
UI restructuring. Ship as four separate plans (one per numbered item), each closing with its own
contrast/geometry test, since they touch unrelated files and unrelated review risk.

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Switch track outline colour | Design System (`lib/theme/gw_colors.dart`) | Component (`lib/components/inputs/gw_switch.dart`) | Token lives in theme; the resolver that picks it lives in the one component that paints it |
| statusSuccess/statusError text remediation | Design System (token choice) | ~40 call sites across Dashboard/Tokens/Swap/Banxa/Settings/Logs screens | The AA-safe token (`statusSuccessText`/`statusErrorText`) already exists in the theme layer; this phase only widens its consumer set |
| Mobile bar textScaler clamp | Component (`lib/components/overlay/responsive_overlay.dart`) | — | Purely a `MediaQuery` wrapper local to `_MobileTabBar.build`; no theme or router change |
| Material text-slot mapping | Design System (`lib/theme/genius_wallet_typography.dart`) | Components that render unstyled text (`ActionChip`, `MenuItemButton` already patched) | `toMaterialTextTheme()` is the single source Material widgets fall back to |

## Standard Stack

No new dependency. All four fixes are changes to existing first-party files:
`lib/theme/gw_colors.dart`, `lib/components/inputs/gw_switch.dart`, ~40 call sites already
importing `gw_colors.dart`, `lib/components/overlay/responsive_overlay.dart`, and
`lib/theme/genius_wallet_typography.dart`. `flutter_lints`/`flutter test` are already wired; no
new tooling.

## Package Legitimacy Audit

Not applicable — this phase installs no external packages.

<phase_requirements>
## Phase Requirements

No requirement IDs exist for this phase (`ROADMAP.md`: "**Requirements**: TBD" — backlog-driven,
not tied to REQUIREMENTS.md). The four numbered goals in ROADMAP.md's Phase 32 section are the
acceptance criteria; the table below maps each to what this research supplies.

| Goal | Description | Research Support |
|------|-------------|------------------|
| 1 | `GWSwitch` enabled track outline reaches 3:1 against ON and OFF tracks, both modes | Exact resolved hex/alpha values for both tracks in both modes; proof the current `borderControl` fails against the ON track; a computed alpha that clears 3:1 everywhere |
| 2 | ~40 `statusSuccess`/`statusError` text call sites move to an AA-safe token per real backdrop | Full call-site inventory with file:line, computed ratios for every plain-surface backdrop, and proof the existing `statusSuccessText`/`statusErrorText` tokens already clear AA universally |
| 3 | Mobile bar clamps `textScaler` at ~1.23x | Exact clamp location, exact ceiling formula matching the test's own printed constants, and the test extension pattern |
| 4 | Five unmapped Material text slots mapped or deliberately left with a comment | Confirmed 10/15 mapped; confirmed which widget types are ACTUALLY affected (narrower than the todo assumed) with file:line evidence |
</phase_requirements>

---

## Item 1: `GWSwitch` enabled track outline (WCAG 1.4.11, 3:1)

### Current code (verified this session)

`lib/components/inputs/gw_switch.dart:50-64`:
```dart
trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.disabled)) {
    return gw.surfaceMenu;
  }
  if (states.contains(WidgetState.selected)) {
    return context.gw.brandPrimaryStrong.withAlpha(140);
  }
  return gw.surfaceMenu;
}),
trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.disabled)) {
    return gw.borderControl;
  }
  return gw.borderSubtle;  // <-- the enabled/unselected AND enabled/selected branch, both broken
}),
```
`[VERIFIED: lib/components/inputs/gw_switch.dart:50-64]`

### Resolved token values (verified this session)

From `lib/theme/genius_wallet_colors.dart` and `lib/theme/gw_colors.dart` (read in full):

- `brandPrimaryStrong` = `#0AAEE6` — mode-invariant `[VERIFIED: lib/theme/genius_wallet_colors.dart:64]` (`static const Color _brandPrimaryStrong = Color(0xFF0AAEE6);`)
- ON track = `brandPrimaryStrong.withAlpha(140)` → **55% alpha** teal, composited over whatever canvas the switch sits on (the fill is translucent, so its *rendered* colour is backdrop-dependent — see below)
- OFF track = `gw.surfaceMenu` (opaque): dark `#171A21`, light `#EFF2F6` `[VERIFIED: lib/theme/genius_wallet_colors.dart:134-139]`
- `borderSubtle`: dark `rgba(255,255,255,0.12)`, light `rgba(16,19,26,0.12)` `[VERIFIED: lib/theme/genius_wallet_colors.dart:193-198]`
- `borderControl`: dark `rgba(255,255,255,0.36)`, light `rgba(16,19,26,0.48)` `[VERIFIED: lib/theme/genius_wallet_colors.dart:229-231]`
- canvas candidates the switch is used against: `surfaceElevated` (dark `#0C0E14`, light `#FFFFFF`), `surfaceBase` (dark `#0B0D12`, light `#DCE0E6`), `surfaceMenu` (dark `#171A21`, light `#EFF2F6`) `[VERIFIED: lib/theme/genius_wallet_colors.dart:119-146]`

`GWSwitch` is a generic, reused `StatelessWidget` (used from `settings_screen.dart:403` and the dev
gallery `design_gallery_screen.dart:584/591/597`) — it is not pinned to one canvas, so its outline
must clear 3:1 regardless of which surface sits behind it. `[VERIFIED: lib/settings/settings_screen.dart:403, lib/dev/design_gallery_screen.dart:584-600]`

### Computed contrast (this session, WCAG relative-luminance formula, not estimated)

**Finding 1 — the disabled-state fix's `borderControl` does NOT clear 3:1 against the ON track:**

| Comparison | Dark | Light |
|---|---:|---:|
| ON track composited over `surfaceElevated` | `#0B6687` | `#78D3F1` |
| `borderControl` on that ON track | **2.14:1** ✗ | **2.90:1** ✗ |
| `borderControl` on OFF track (`surfaceMenu`, opaque) | 3.32:1 ✓ | 3.21:1 ✓ |

So the todo's own suggested "likely the same `borderControl` token" does **not** work — it clears
3:1 against the OFF track (matching the already-shipped disabled-state fix, which only needed to
clear the OFF track) but fails against the ON track in both modes.

**Finding 2 — the ON track's rendered colour is backdrop-dependent** (it is a 55%-alpha fill, not
opaque), so the outline must clear 3:1 against the ON track *for every canvas the switch can sit
on*. Computed ON-track composites:

| Backdrop | Dark ON track | Light ON track |
|---|---|---|
| `surfaceBase` | `#0A6586` | `#69C5E6` |
| `surfaceElevated` | `#0B6687` | `#78D3F1` |
| `surfaceMenu` | `#106B8D` | `#71CDED` |

**Finding 3 — a computed alpha clears 3:1 against every ON-track backdrop AND the OFF track, in
both modes:**

| Mode | Outline colour | Alpha | Ratio vs ON/surfaceBase | vs ON/surfaceElevated | vs ON/surfaceMenu | vs OFF (surfaceMenu) |
|---|---|---:|---:|---:|---:|---:|
| Dark | white | **56% (144/255)** | 3.20 | 3.17 | 3.03 | 6.26 |
| Light | ink `#10131A` | **52% (132/255)** | 3.07 | 3.20 | 3.14 | 3.58 |

These are the *minimum* alphas (found by scanning 4%-alpha steps) that clear 3:1 on every
candidate backdrop simultaneously — computed with the same relative-luminance formula
`test/theme/theme_contrast_test.dart`'s `contrastRatio()` helper already implements
`[VERIFIED: test/theme/theme_contrast_test.dart:16-27]`.

### Recommendation

`borderControl` (36%/48%) is already load-bearing elsewhere at a tight margin (its own doc comment
says light-mode 48% is "the first 2-point step that clears 3:1" on its four existing consumers —
`lib/theme/genius_wallet_colors.dart:203-231`) — do not raise its global alpha; that risks
regressing its other consumers' now-documented margins. Instead, add a **new** appearance-aware
token (e.g. `borderControlOnBrand`, following the exact doc-comment convention `borderControl`
itself uses) with dark=white-56%, light=ink-52%, and point `GWSwitch`'s enabled/unselected AND
enabled/selected branches at it, leaving the disabled branch on `borderControl` untouched:

```dart
trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((states) {
  if (states.contains(WidgetState.disabled)) {
    return gw.borderControl;         // unchanged
  }
  return gw.borderControlOnBrand;    // new token — clears 3:1 vs ON *and* OFF track, both modes
}),
```
`[CITED: computed this session from lib/theme/genius_wallet_colors.dart's verified hex/alpha values]`

### Test extension

`test/theme/disabled_control_contrast_test.dart` already tests the **disabled** switch outline
against the OFF track only, using `Color.alphaBlend` `[VERIFIED: test/theme/disabled_control_contrast_test.dart:73-84]`.
Add a parallel `enabled_control_contrast_test.dart` (or a new group in the same file) that:
1. Composites the ON track (`Color.alphaBlend(brandPrimaryStrong.withAlpha(140), surface)`) for
   each of `surfaceBase`/`surfaceElevated`/`surfaceMenu`.
2. Composites the new outline token on top of each, asserts `contrastRatio(...) >= 3.0`.
3. Repeats for the OFF track (`surfaceMenu`, already opaque).

---

## Item 2: `statusSuccess`/`statusError` as text (WCAG AA, 4.5:1, light mode)

### The existing AA-safe tokens already solve this — verified this session

`lib/theme/gw_colors.dart:316-317, 367-368` (light) and `:487-488, 535-536` (dark):

```dart
// GWColors.light()
statusSuccess: const Color(0xFF07875F), // 4.5:1 on white
statusError: const Color(0xFFD92D2D),   // 4.8:1 on white
...
statusSuccessText: const Color(0xFF065F46),
statusErrorText: const Color(0xFF991B1B),

// GWColors.dark()
statusSuccess: const Color(0xFF0AD89C),
statusError: const Color(0xFFFF4D4D),
...
statusSuccessText: const Color(0xFF0AD89C),   // IDENTICAL to statusSuccess in dark
statusErrorText: GeniusWalletColors._statusError, // IDENTICAL to statusError in dark (#FF4D4D)
```
`[VERIFIED: lib/theme/gw_colors.dart:316-317, 367-368, 487-488, 535-536]`

**This is the load-bearing fact for this item's fix:** `statusSuccessText`/`statusErrorText` are
**byte-identical** to `statusSuccess`/`statusError` in dark mode. Swapping every TEXT/ICON call
site from the raw token to its `*Text` partner is therefore a **zero-repaint change in dark mode**
and an AA fix in light mode only — exactly the "no live re-skin, no visual regression in the mode
that already works" shape this codebase's plans consistently prefer.

### Computed ratios (light mode, this session — not estimated)

Raw tokens as text/icon, against every plain surface in the palette:

| Token | surfaceElevated (`#FFFFFF`) | surfaceMenu (`#EFF2F6`) | surfaceBase (`#DCE0E6`) | surfaceSunken (`#CFD4DB`) |
|---|---:|---:|---:|---:|
| `statusSuccess` `#07875F` | 4.53 (barely ✓) | 4.03 ✗ | 3.42 ✗ | 3.04 ✗ |
| `statusError` `#D92D2D` | 4.81 ✓ | 4.29 ✗ | 3.63 ✗ | 3.23 ✗ |

The AA-safe partners, against the same four surfaces:

| Token | surfaceElevated | surfaceMenu | surfaceBase | surfaceSunken |
|---|---:|---:|---:|---:|
| `statusSuccessText` `#065F46` | 7.68 | 6.84 | 5.80 | 5.16 |
| `statusErrorText` `#991B1B` | 8.31 | 7.40 | 6.27 | 5.58 |

**`statusSuccessText`/`statusErrorText` clear the 4.5:1 body-text floor on every surface in the
app's palette, with margin.** This means the fix does not need per-site backdrop-specific tuning —
one mechanical swap is AA-safe everywhere a plain surface is the backdrop. `[VERIFIED: computed from lib/theme/genius_wallet_colors.dart's read hex values, using test/theme/theme_contrast_test.dart:16-27's relative-luminance formula]`

Icons are a separate WCAG clause (1.4.11 non-text, 3:1 floor, not 4.5:1): every icon-only site
already clears 3:1 comfortably with the *raw* token (4.03-4.81 range above), so **icon-only sites
are not defects under 1.4.11** — the defect is specifically TEXT (multi-character labels/values)
painted in the fill-tuned token. This narrows true scope below "every call site."

### Call-site inventory (grep + read, this session)

`grep -n '\.statusSuccess\b|\.statusError\b' lib/` found 43 files. Classified by paint target:

**IN SCOPE — TEXT foreground on a plain (non-wash) surface. Swap to the `*Text` partner:**

| File:line | What | Backdrop |
|---|---|---|
| `lib/chart/crypto_simple_chart.dart:179,219` (`changeColor`, defined :55-56) | % change `Text` | dashboard market row `[VERIFIED: lib/chart/crypto_simple_chart.dart:54-56]` |
| `lib/chart/crypto_live_chart.dart:445,616` (`trendColor`, defined :321) | price/% `Text` labels | chart card `[VERIFIED: lib/chart/crypto_live_chart.dart:321]` |
| `lib/dashboard/chart/markets_table.dart:231` | % change `Text` | markets table row |
| `lib/dashboard/chart/markets_cards.dart:254` | % change `Text` | market card |
| `lib/dashboard/chart/markets_hero_card.dart:238,663,809-810` | % change `Text` (×3 call sites) | hero card |
| `lib/tokens/token_info_screen.dart:1274,1362,1377` | % change `Text` / `GWStatTile.valueColor` | token detail screen |
| `lib/components/coins/view/coin_card_row.dart:55` (`changeColor`) | % change `Text` | assets list row `[VERIFIED: lib/components/coins/view/coin_card_row.dart:45-55]` |
| `lib/components/coins/assets_total_band.dart:109` | % change `Text` | assets header band `[VERIFIED: lib/components/coins/assets_total_band.dart:106-111]` |
| `lib/squid_router/route_details_card.dart:69` | `_DetailRow.valueColor` `Text` | swap route card, `surfaceElevated` — **borderline pass today (4.53:1), swap anyway for margin/consistency** `[VERIFIED: lib/squid_router/route_details_card.dart:49-70]` |
| `lib/dashboard/home/widgets/transaction_displays.dart:381` | "Not charged" value `Text` (ternary against `textSecondary`) | receipt row — note this file's *other* two statusSuccess/statusError uses (`:85,:99`) are already correct (`wash:`, feeding the pill fill, `fg:` already `statusSuccessText/statusErrorText`) — only line 381 is the residual raw use `[VERIFIED: lib/dashboard/home/widgets/transaction_displays.dart:83-100,379-382]` |
| `lib/logs/submit_logs_screen.dart:530,795` | status message `Text` / rail value `Text` | dev logs screen |
| `lib/screens/pin_screen.dart:103` | "Incorrect PIN" `Text` | PIN screen (own comment already explains *why* `gw.statusError` not the static — same AA intent, just needs the `*Text` partner too) `[VERIFIED: lib/screens/pin_screen.dart:96-104]` |
| `lib/screens/banxa_buy_screen.dart:647` | error `Text` | Banxa buy form |
| `lib/account/sdk_account_manager.dart:292` | menu item label `Text`/icon `fg` | SDK account menu, `surfaceMenu` (Material `surfaceContainerHighest` theme mapping, `lib/theme/theme.dart:28`) |
| `lib/account/account_drawer.dart:459,464` | `MenuItemButton` icon + `Text('Delete')` | account drawer menu, `surfaceMenu` `[VERIFIED: lib/account/account_drawer.dart:454-466]` |
| `lib/components/wallet_information.dart:92` | "No funds available" `Text` | wallet card `[VERIFIED: lib/components/wallet_information.dart:89-94]` |
| `lib/components/wallets_overview.dart:90` | "No funds available" `Text` | wallets overview |
| `lib/components/inputs/gw_text_field.dart:232` | `errorStyle` `Text` | any form field (border use at :223/226/261 is a FILL/edge — see below) |
| `lib/components/inputs/gw_select.dart:105` | `errorStyle` `Text` | any select field (border use at :100/101 is an edge — see below) |
| `lib/components/qr/crypto_address_qr.dart:166` | "Copied"/"Copy" `Text` | receive drawer (icon use at :156 already clears 3:1 as icon; text use needs the swap) |
| `lib/dashboard/bridge/bridge_screen.dart:735` | CTA `foreground` `Text` | bridge CTA banner — sits on its OWN 12%-alpha wash (`:733`), same shape the pill fix already solved; swap foreground to `statusErrorText` the same way `transaction_displays.dart`'s pill already does |
| `lib/squid_router/swap_screen.dart:693-716,789` | error icon+`Text` (×3), CTA `foreground` | swap screen — line 693's `Icon` is fine at 3:1; lines 704/714 `Text` and line 789's CTA foreground (same wash shape as bridge_screen above) are in scope |
| `lib/squid_router/swap_settings_drawer.dart:149,318` | slippage edge colour `Text`/border | :149 feeds a `Text` colour via `switch`; :318 likewise — verify at execution which of the two `switch` results is a `Text` vs a `Border` |
| `lib/settings/settings_screen.dart:368,370` | debug status line `Text` | settings screen |
| `lib/components/feedback/gw_error_state.dart:40,94,100,107` | icon (:40,94,107 — already clear 3:1, no change needed) + message `Text` (:100) | both sit on the widget's OWN 12%/~39% alpha wash (`:37,88,90`) — same shape the pill fix solved; swap the `Text` foreground only |
| `lib\components\toast\toast_widget.dart:52,54` | icon-only accent (confirmed by reading the file: title/message always stay on `textPrimary`/`textSecondary`, "the toast never depends on a status colour for legibility" — file's own doc comment) | **OUT of scope** — icon only, backdrop `surfaceElevated`, already clears 3:1 `[VERIFIED: lib/components/toast/toast_widget.dart:18-28,49-58]` |

**OUT OF SCOPE — fill, wash, dot, or border (needs only 3:1, already comfortably clear at 3.4-4.8):**

| File:line | What |
|---|---|
| `lib/dashboard/home/widgets/transaction_badge.dart:52,89,101` | badge `fill:` |
| `lib/dashboard/compute/compute_panel.dart:195,199` | feeds `GWStatusDot.color` (dot fill) — already covered by `test/theme/disabled_control_contrast_test.dart`-style 3:1 dot test in `compute_contrast_test.dart` |
| `lib/banxa/banxa_components/order_status_style.dart:46,62` | `bg:` wash only — `fg:` on these two is already `statusSuccessText`/`statusErrorText` (correct, shipped pattern) |
| `lib/dashboard/home/widgets/transaction_displays.dart:85,99` | `wash:` only (see note above — this file's pattern is the model to copy) |
| `lib/submit_job/view/widgets/job_step_list.dart:200`, `job_steps.dart:204,540,611` | `GWStatusDot` fill / circle `decoration.color` |
| `lib/components/incorrect_pin.dart:45` | filled pill `decoration.color` |
| `lib/components/inputs/gw_text_field.dart:223,226,261`, `gw_select.dart:100,101` | border/edge colour (3:1 floor, not 4.5:1) |
| `lib/components/buttons/gw_button.dart:164` (comment only, already fixed 23-03) | destructive button fill; foreground is `textPrimary`, not this token |
| `lib/web/web_view_windows.dart:394`, `web_view_mobile.dart:727` | lock icon only, 13px, already ≥3:1 |
| `lib/components/custom_future_builder.dart:42` | icon only |
| `lib/reown/reown_connect_button.dart:547,559` | `stateColor` — verify at execution whether consumed as icon or text (both a `Text` and an `Icon` read `stateColor` further down; grep did not resolve which controls which within budget) |
| `lib/dev/design_gallery_screen.dart:226-227` | dev-only colour swatch |

**Total distinct in-scope TEXT/foreground call sites found: ~24 across ~19 files** — under the
todo's "~40" estimate because a meaningful fraction of the original 43-file grep hit is icon-only
(already 3:1-compliant) or fill/wash/dot/border (never needed 4.5:1). The remaining uncertain ones
(`swap_settings_drawer.dart:149/318`, `reown_connect_button.dart:547/559`) should be confirmed by
the executor with one `Read` each before editing — flagged rather than guessed, per this file's own
provenance rules.

### Recommendation

Mechanical swap: everywhere the token is read via `.color:` on a `Text`/`TextStyle`/`Icon` painted
on a plain (non-wash) surface, replace `gw.statusSuccess` → `gw.statusSuccessText` and
`gw.statusError` → `gw.statusErrorText`. Everywhere it feeds a `wash:`/`bg:`/fill/border, leave it
unchanged. No new token needed — reuse fully covers every measured case.

### Test extension

Add a source-scanning test (same pattern as `drawer_padding_invariant_test.dart` /
`freeze_rule_test.dart`, which already grep `lib/` for a banned pattern) asserting that no file
outside an explicit allowlist (the wash/fill/border/dot sites above) contains
`color: gw.statusSuccess` or `color: gw.statusError` inside a `Text(`/`TextStyle(`/`Icon(` call —
this is the kind of regression test this codebase already favours over a golden/pixel test.

---

## Item 3: mobile bar `textScaler` clamp (~1.23x)

### Exact overflow geometry (verified this session)

`lib/components/overlay/responsive_overlay.dart:97-105` (constants) and `:149-240` (`_MobileTabBar.build`):

```dart
const kMobileNavIconSize = 23.0;      // :97
const double kMobileBarHeight = 60.0; // :105
```
`[VERIFIED: lib/components/overlay/responsive_overlay.dart:97,105]`

`lib/theme/genius_wallet_consts.dart:19,27`: `space2 = 4.0`, `space4 = 8.0` `[VERIFIED: lib/theme/genius_wallet_consts.dart:19,27]`

`lib/theme/genius_wallet_typography.dart:124-125`: `labelMd => _inter(fontSize: 13, height: 18/13, ...)` — the bar overrides `fontSize` to 10 but the `height` MULTIPLIER (18/13) is unchanged by that override `[VERIFIED: lib/theme/genius_wallet_typography.dart:124-125]`, matching `responsive_overlay.dart:320-321`'s `labelMd.copyWith(fontSize: 10, ...)`.

`test/components/mobile_nav_destinations_test.dart:283-314` computes and asserts, at real Inter:
```
padding      = 2 * space4        = 16.00
icon         = kMobileNavIconSize = 23.00
gap          = space2             =  4.00
labelLine    = 10 * (18/13)       = 13.846154
total                              = 56.846154
slack = kMobileBarHeight - total  =  3.153846   (test asserts moreOrLessEquals(3.15, epsilon: 0.01))
```
`[VERIFIED: test/components/mobile_nav_destinations_test.dart:283-314 — values quoted verbatim above]`

Only `labelLine` scales with `textScaler` (icon, padding, gap are fixed px). Overflow begins once:
```
13.846154 * s > 13.846154 + 3.153846 = 17.0
s > 17 / 13.846154 = 17*13/180 = 221/180 = 1.227778
```
So the exact, closed-form ceiling is **`221/180 ≈ 1.2278`** — matching the todo's "roughly 1.23x"
and derivable from the same four named constants the test already prints, rather than a new
literal.

### Where the clamp belongs

`_MobileTabBar.build` (`lib/components/overlay/responsive_overlay.dart:152-240`) is the single
place that lays out the icon+label `Column` (`:311-327`) and owns `kMobileBarHeight` (`:187,194`).
Precedent cited by the todo, **independently re-verified this session** against a local Flutter
engine checkout found at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/` (a sibling
project's Flutter source tree, not this repo's pinned SDK, but the same framework code):

```dart
// Source: flutter/flutter/packages/flutter/lib/src/material/app_bar.dart:44-45
const double _kMaxTitleTextScaleFactor =
    1.34; // TODO(perc): Add link to Material spec when available, ...

// :1094-1101 (SliverAppBar.medium/.large title, one of two call sites):
title = MediaQuery.withClampedTextScaling(
  maxScaleFactor: _kMaxTitleTextScaleFactor,
  child: title,
);
```
`[VERIFIED: flutter/flutter/packages/flutter/lib/src/material/app_bar.dart:44-45,1094-1101 — quoted verbatim]`

`MediaQuery.withClampedTextScaling` is a public static helper (not a hand-rolled `copyWith`) —
`packages/flutter/lib/src/widgets/media_query.dart:1368-1393`, confirmed to do exactly the
`data.textScaler.clamp(minScaleFactor:, maxScaleFactor:)` + rewrap that a manual version would,
but as the framework's own named API:
```dart
// Source: flutter/flutter/packages/flutter/lib/src/widgets/media_query.dart:1368-1393
static Widget withClampedTextScaling({
  Key? key,
  double minScaleFactor = 0.0,
  double maxScaleFactor = double.infinity,
  required Widget child,
}) { ... }
```
`[VERIFIED: flutter/flutter/packages/flutter/lib/src/widgets/media_query.dart:1368-1393]`

Recommended shape, wrapping the returned `SizedBox` (or just the `Row`/`Column` subtree) in `_MobileTabBar.build` — using the framework's own helper rather than a hand-rolled `MediaQuery`/`copyWith`, per this codebase's "don't hand-roll" preference and matching `AppBar`'s exact idiom:

```dart
// Mirrors AppBar's own title-scale clamp (app_bar.dart:44-45,
// _kMaxTitleTextScaleFactor, applied via MediaQuery.withClampedTextScaling) --
// the bar's label is the only term that scales (icon/padding/gap are fixed
// px; see kMobileBarHeight's own doc comment), and clamping keeps the bar's
// fixed 60px slot from overflowing vertically. Ceiling derived from the same
// constants mobile_nav_destinations_test.dart prints:
// 17 / (10 * GeniusWalletTypography.labelMd.height!) = 221/180.
const double _kMaxMobileBarTextScaleFactor = 221 / 180; // ≈1.2278

return MediaQuery.withClampedTextScaling(
  maxScaleFactor: _kMaxMobileBarTextScaleFactor,
  child: SizedBox(/* existing subtree, unchanged */),
);
```

Using the exact fraction (rather than a rounded `1.23`) keeps zero slack at the ceiling by
construction and keeps the constant self-documenting the way the test file's own inline math
already is. `[VERIFIED: precedent API; CITED: ceiling computed this session from lib/components/overlay/responsive_overlay.dart:97-105,149-329 and lib/theme/genius_wallet_typography.dart:124-125 — all quoted verbatim above]`

### Test extension

`test/components/mobile_nav_destinations_test.dart`'s existing "the slot stack fits the bar
height" test (`:283-314`) only measures at 1.0x. Add a new test in the same `group` that pumps the
bar (or replicates its geometry math) at `textScaler: TextScaler.linear(1.30)` — deliberately
**above** the new clamp — and asserts the RENDERED label's line-box height still equals the 1.0x
value (proving the clamp, not just the ceiling math, is wired). A second test at `1.20` (below the
clamp) should show the label scaling normally, proving the clamp does not fire prematurely and
rob users below the ceiling of the Dynamic Type they are owed.

---

## Item 4: five unmapped Material text slots

### Confirmed current state (read in full this session)

`lib/theme/genius_wallet_typography.dart:150-161`:
```dart
static TextTheme toMaterialTextTheme() => TextTheme(
  displayLarge: displayLg,
  displayMedium: displayMd,
  headlineLarge: headlineLg,
  headlineMedium: headlineMd,
  titleLarge: titleLg,
  titleMedium: titleMd,
  bodyLarge: bodyLg,
  bodyMedium: bodyMd,
  bodySmall: bodySm,
  labelMedium: labelMd,
);
```
`[VERIFIED: lib/theme/genius_wallet_typography.dart:150-161 — quoted verbatim]`

Confirmed unmapped: **`displaySmall`, `headlineSmall`, `titleSmall`, `labelLarge`, `labelSmall`** —
matching the todo exactly, and confirmed there is no `displaySm`/`headlineSm`/`titleSm`/`labelLg`/
`labelSm` getter anywhere in the class to map them to (a genuinely new style would be needed for
any that get mapped, not just a rename).

### Correction to the todo's scope: which widgets are ACTUALLY affected

`lib/theme/theme.dart:166-179, 198-213, 256-271` — `outlinedButtonTheme`, `elevatedButtonTheme`,
and `textButtonTheme` **all** already set `textStyle` explicitly:
```dart
outlinedButtonTheme: OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(..., textStyle: GeniusWalletTypography.titleMd, ...),
),
elevatedButtonTheme: ElevatedButtonThemeData(
  style: ButtonStyle(textStyle: WidgetStatePropertyAll(GeniusWalletTypography.titleMd), ...),
),
textButtonTheme: TextButtonThemeData(
  style: ButtonStyle(textStyle: WidgetStatePropertyAll(GeniusWalletTypography.titleMd), ...),
),
```
`[VERIFIED: lib/theme/theme.dart:166-179,198-213,256-271 — quoted verbatim]`

**This means bare `TextButton`/`OutlinedButton`/`ElevatedButton` do NOT read `labelLarge` at all**
in this app — they already render in `titleMd` (Inter) via their own `ButtonThemeData`. Mapping
`labelLarge` globally would therefore have **zero visual effect** on any of the 10 bare-button call
sites found by grep (`lib/dev/token_probe_screen.dart:99`, `lib/banxa/banxa_orders_history.dart:248`,
`lib/reown/reown_connect_button.dart:402,587`, `lib/network/network_dropdown_selector.dart:271`,
`lib/account/account_dropdown_selector.dart:83`, `lib/account/sdk_account_manager.dart:51`,
`lib/components/disclaimer_dialogue.dart:56`, `lib/components/sliding_drawer_button.dart:26`,
`lib/components/action_button.dart:117`) — the todo's own claim on this point does not hold given
these three theme overrides already exist. This narrows the real, live `labelLarge` consumers to:

- **`MenuItemButton`** — already patched locally via `menuButtonTheme` (`lib/theme/theme.dart:425-429`,
  `style: ButtonStyle(textStyle: WidgetStatePropertyAll(GeniusWalletTypography.bodySm))`) — no gap remains here `[VERIFIED: lib/theme/theme.dart:416-429]`.
- **`ActionChip`/`Chip`** — no `chipTheme`/`ChipThemeData` exists anywhere in `theme.dart` (grepped,
  zero matches). Confirmed live consumer:
  `lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart:346-349`:
  ```dart
  return ActionChip(
    label: Text(word),
    onPressed: () => _onWordClick(word),
  );
  ```
  `[VERIFIED: lib/onboarding/new_wallet/view/verify_recovery_phrase_screen.dart:346-349 — quoted verbatim]`
  — no inline style at all, so this chip's label falls through to Material 3's default, confirmed
  this session against the local Flutter engine checkout
  (`flutter/flutter/packages/flutter/lib/src/material/chip.dart:2504-2505`,
  `_ChipDefaultsM3.labelStyle => _textTheme.labelLarge?.copyWith(...)`)
  `[VERIFIED: flutter/flutter/packages/flutter/lib/src/material/chip.dart:2499-2509 — quoted verbatim]`
  — i.e. genuinely `labelLarge` (Roboto today, confirmed, not assumed). This is a **visible,
  high-traffic onboarding screen** (the recovery-phrase verification step's word bank).
- **`SnackBarAction`** — grepped across `lib/`, **zero matches**. No live consumer exists today;
  a `snackBarTheme`/`SnackBarThemeData` gap exists but has nothing currently rendering through it.
- **`ListTile`** (grepped 11 call sites across `web_view_windows.dart`, `network_page.dart` ×4,
  `banxa_components/order_details_card.dart` ×6) — confirmed this session against the local Flutter
  engine checkout (this app sets `useMaterial3: true`, `lib/theme/theme.dart:62`, so the active
  defaults class is `_LisTileDefaultsM3`):
  ```dart
  // Source: flutter/flutter/packages/flutter/lib/src/material/list_tile.dart:1785-1791
  TextStyle? get titleTextStyle => _textTheme.bodyLarge!.copyWith(color: _colors.onSurface);
  TextStyle? get subtitleTextStyle => _textTheme.bodyMedium!.copyWith(color: _colors.onSurfaceVariant);
  TextStyle? get leadingAndTrailingTextStyle => _textTheme.labelSmall!.copyWith(color: _colors.onSurfaceVariant);
  ```
  `[VERIFIED: flutter/flutter/packages/flutter/lib/src/material/list_tile.dart:1759-1791,useMaterial3 confirmed at lib/theme/theme.dart:62 — quoted verbatim]`
  `title`/`subtitle` default to `bodyLarge`/`bodyMedium` (both mapped) — confirming the earlier
  inference. **New finding this default-source read surfaced:** a bare (unstyled) `Text` placed in
  `ListTile.leading`/`.trailing` would default to `labelSmall` — one of the five unmapped slots —
  which none of the earlier grep/reasoning had located. Checked all 11 live call sites individually
  this session: `order_details_card.dart`'s 6 tiles set an explicit `style:` on every `title`/
  `trailing` `Text` (`[VERIFIED: lib/banxa/banxa_components/order_details_card.dart:54-115 — quoted verbatim above]`);
  `network_page.dart`'s 4 tiles use `leading: Icon(...)` (not `Text`) with unstyled `title`/
  `subtitle` (which resolve to the already-mapped `bodyLarge`/`bodyMedium`)
  `[VERIFIED: lib/network/network_page.dart:116-157]`; `web_view_windows.dart`'s 1 tile sets an
  explicit `style:` on its `title` `Text`
  `[VERIFIED: lib/web/web_view_windows.dart:466-476]`. **Conclusion: `ListTile` has zero live
  consumers of the unmapped slots today** — confirmed, not inferred — but the `labelSmall` →
  `leadingAndTrailingTextStyle` linkage is worth a one-line comment in
  `toMaterialTextTheme()` if `labelSmall` is left deliberately unmapped, so a future bare
  `ListTile(trailing: Text(...))` doesn't reintroduce this silently.

### Recommendation

1. Map `labelLarge` to a new `GeniusWalletTypography.labelLg` getter (14px, `w500`, matching the
   todo's own "obvious answer" and the value `menuButtonTheme` independently converged on via
   `bodySm`) — this fixes the `ActionChip` gap directly and gives any future bare `Chip`/
   `SnackBarAction` a correct Inter default without a second per-widget theme patch.
2. For `displaySmall`, `headlineSmall`, `titleSmall`, `labelSmall`: grep found **no live consumer**
   of any of the four in the app's own widget tree today (nothing in `lib/` reads
   `Theme.of(context).textTheme.{displaySmall,headlineSmall,titleSmall,labelSmall}` directly, and
   no unstyled Material widget in this app defaults to any of the four — confirmed by the
   `ListTile`/`Chip`/button audit above). Per the todo's own explicitly-sanctioned option, leave
   these four **deliberately unmapped**, with a comment in `toMaterialTextTheme()` naming that this
   was checked and is intentional, so the next contributor auditing a font gap does not have to
   re-derive this audit.
3. Once `labelLarge` is mapped globally, re-check `menuButtonTheme` (`lib/theme/theme.dart:425-429`):
   if the new `labelLg` getter and the existing local `bodySm` value happen to coincide, the local
   override becomes redundant and can be removed with a comment explaining why; if they diverge
   (menus should stay smaller than a chip label), keep both and comment why the local override
   still needs to win over the new global default.

### Test extension

A `flutter_test` widget test pumping a bare `ActionChip` (and, if `SnackBarAction` ever gains a
consumer, that too) under `getThemeData()`, asserting `find.text('word').evaluate().single` widget's
resolved `DefaultTextStyle.fontFamily == 'Inter'` — mirrors the existing pattern of testing theme
resolution rather than pixels.

---

## Runtime State Inventory

Not applicable — this phase is a pure code/token change; no rename, refactor, or migration of
stored/external state.

## Common Pitfalls

### Pitfall 1: measuring the switch outline against the track's *declared* colour instead of its *composited* colour
**What goes wrong:** `brandPrimaryStrong.withAlpha(140)` is not itself a colour you can run through
`computeLuminance()` — its alpha channel makes the bare hex meaningless for contrast math.
**Why it happens:** `Color.computeLuminance()` silently ignores alpha, so a naive port of
`disabled_control_contrast_test.dart`'s pattern (which already does this correctly via
`Color.alphaBlend`) that skips the alphaBlend step will produce numbers that look plausible but
are wrong.
**How to avoid:** always `Color.alphaBlend(fg, backdrop)` before measuring, exactly as
`disabled_control_contrast_test.dart:29,47,75` already does.
**Warning signs:** a computed ratio that doesn't move when the backdrop surface changes — alpha
compositing was skipped.

### Pitfall 2: assuming `statusSuccessText`/`statusErrorText` are new tokens that need adding
**What goes wrong:** re-deriving new hex values for a "text-safe status colour" when one already
exists, doubling the token surface AGENTS.md's raw-colour gate exists to prevent.
**Why it happens:** the todo's own "Out of scope for the pill fix" section warns these tokens are
"tuned for the fill's own translucent wash... not for a plain opaque surface" — which reads as a
caution against reuse, but the actual computed ratios (5.16-8.31:1 across all four plain surfaces)
show they clear AA with wide margin on plain surfaces too.
**How to avoid:** trust the computed ratio table above rather than the todo's cautious framing;
verify with the ratio, not the prose.

### Pitfall 3: mapping `labelLarge` and expecting the app's buttons to visibly change
**What goes wrong:** a plan/executor "fixes" `labelLarge`, runs the visual walk, sees zero change
on any `TextButton`/`OutlinedButton`, and concludes the fix didn't take effect (wasted debugging).
**Why it happens:** all three button `ButtonThemeData`s already hard-set `textStyle`, which
overrides whatever `TextTheme.labelLarge` supplies — confirmed by reading `theme.dart` this
session.
**How to avoid:** verify on `ActionChip` (recovery-phrase screen) or a widget test, not on a bare
button.

## Code Examples

### The existing pill pattern this phase's item 2 generalises
```dart
// Source: lib/dashboard/home/widgets/transaction_displays.dart:83-100 (read this session)
TransactionStatus.completed => (
  fg: gw.statusSuccessText,
  wash: gw.statusSuccess.withValues(alpha: 0.14),
),
...
TransactionStatus.failed => (
  fg: gw.statusErrorText,
  wash: gw.statusError.withValues(alpha: 0.14),
),
```
This fg/wash split is the exact shape `gw_error_state.dart`, `bridge_screen.dart`'s CTA banner, and
`swap_screen.dart`'s CTA banner should converge on for their own wash-backed text.

### The existing disabled-outline contrast test pattern to mirror for the enabled fix
```dart
// Source: test/theme/disabled_control_contrast_test.dart:73-84 (read this session)
test('disabled switch outline clears 3:1 against its track -- $mode', () {
  final gw = themeFor(mode).extension<GWColors>()!;
  final composited = Color.alphaBlend(gw.borderControl, gw.surfaceMenu);
  final ratio = contrastRatio(composited, gw.surfaceMenu);
  expect(ratio, greaterThanOrEqualTo(uiFloor), reason: '...');
});
```

## State of the Art

Not applicable — no library/framework version drift is involved; this is a first-party token and
layout fix on an already-current Flutter/Material 3 setup.

## Assumptions Log

All three assumptions originally logged here were resolved during this same research session once
a local Flutter engine checkout was located at `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/`
(found by a background search that completed after the initial pass). None remain open.

| # | Claim | Section | Status |
|---|-------|---------|--------|
| ~~A1~~ | ~~`AppBar._kMaxTitleTextScaleFactor` exists at `app_bar.dart:44`~~ | Item 3 | **RESOLVED — verified.** Confirmed at `app_bar.dart:44-45` (value `1.34`), applied via the public `MediaQuery.withClampedTextScaling` helper (`media_query.dart:1368-1393`), not a hand-rolled wrapper. |
| ~~A2~~ | ~~Material 3's default `ListTile` title/subtitle styles read `titleMedium`/`bodyMedium`~~ | Item 4 | **RESOLVED — verified, and corrected.** The active M3 defaults class (`_LisTileDefaultsM3`, confirmed active since this app sets `useMaterial3: true` at `lib/theme/theme.dart:62`) actually maps title→`bodyLarge`, subtitle→`bodyMedium` (both mapped, as inferred) — but ALSO surfaced a previously-unknown sub-slot, `leadingAndTrailingTextStyle`→`labelSmall` (unmapped). Checked all 11 live `ListTile` call sites individually: none place a bare, unstyled `Text` in `leading`/`trailing`, so **zero live impact today** — confirmed by reading each site, not inferred. |
| ~~A3~~ | ~~Material 3's default `Chip`/`ActionChip` label style reads `labelLarge`~~ | Item 4 | **RESOLVED — verified exactly as assumed.** `_ChipDefaultsM3.labelStyle => _textTheme.labelLarge?.copyWith(...)` (`chip.dart:2504-2505`). |

## Open Questions

1. **Exact backdrop for `swap_settings_drawer.dart:149,318` and `reown_connect_button.dart:547,559`**
   - What we know: each feeds a `switch`-expression result into either a `Text` colour or a
     `Border`, and the file's surrounding code was not fully traced this session.
   - What's unclear: whether these specific two sites are TEXT (in scope) or edge/border (out of
     scope, 3:1 floor).
   - Recommendation: one `Read` each at plan/execute time before deciding whether to swap; both are
     small, low-risk, single-line changes either way.

2. **Whether `borderControlOnBrand` (item 1's proposed new token) should stay switch-only or
   generalise**
   - What we know: no other component today paints an outline against a translucent brand-tinted
     fill the way `GWSwitch`'s ON track does.
   - What's unclear: whether `GWCheckbox`'s selected/checked state (not audited this session — out
     of this phase's four named goals) has the same shape and would want the same token.
   - Recommendation: name the token generically enough (`borderControlOnBrand`, not
     `switchOutlineOn`) that a future consumer can reuse it without a rename, but do not go looking
     for that consumer in this phase — out of the four named goals.

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | `flutter_test` (bundled with the pinned Flutter 3.41.9 SDK) |
| Config file | none — no `dart_test.yaml`; tests run via `flutter test` |
| Quick run command | `flutter test test/theme/ test/components/mobile_nav_destinations_test.dart` |
| Full suite command | `flutter test` |

### Phase Requirements → Test Map
| Goal | Behavior | Test Type | Automated Command | File Exists? |
|------|----------|-----------|-------------------|-------------|
| 1 | Enabled switch outline ≥3:1 vs ON and OFF track, both modes | unit (contrast math) | `flutter test test/theme/disabled_control_contrast_test.dart` (extend) or a new `enabled_control_contrast_test.dart` | ❌ Wave 0 — new test/group needed |
| 2 | Every in-scope call site clears 4.5:1 text floor, light mode | unit (source-scan + spot contrast) | `flutter test test/theme/` (extend `theme_contrast_test.dart` or add a source-scan test) | ❌ Wave 0 — new source-scan test needed |
| 3 | Mobile bar never overflows vertically above the clamp; scales normally below it | unit (widget/geometry) | `flutter test test/components/mobile_nav_destinations_test.dart` (extend existing group) | ✅ file exists, extend with 2 new tests |
| 4 | `ActionChip`/any newly-mapped slot renders Inter, not Roboto | unit (widget) | `flutter test test/theme/` (new test) | ❌ Wave 0 — new test needed |

### Sampling Rate
- **Per task commit:** `flutter test test/theme/ test/components/mobile_nav_destinations_test.dart`
- **Per wave merge:** `flutter test` (full suite)
- **Phase gate:** Full suite green before `/gsd-verify-work`, plus a visual walk in both appearance
  modes (per this project's standing `BLD-02` convention: verify by running the app, not `flutter
  analyze` alone) — confirm the switch outline, the four categories of text-colour swap, the bar at
  a large Dynamic Type setting, and the recovery-phrase word chips.

### Wave 0 Gaps
- [ ] `test/theme/enabled_control_contrast_test.dart` (or a new group in `disabled_control_contrast_test.dart`) — covers Goal 1
- [ ] A source-scanning test (pattern: `test/components/drawer_padding_invariant_test.dart`) asserting no un-allowlisted `Text`/`Icon` site reads raw `gw.statusSuccess`/`gw.statusError` — covers Goal 2
- [ ] A new widget test for `ActionChip`'s resolved font family — covers Goal 4
- Framework install: none — `flutter_test` already present and wired.

## Security Domain

`security_enforcement: true`, `security_asvs_level: 1` (`.planning/config.json`). This phase is a
pure presentation/token/layout change with no new input handling, auth, session, or cryptography
surface — ASVS V2/V3/V4/V6 do not apply. The only marginally relevant category:

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---------------|---------|-----------------|
| V2 Authentication | no | — |
| V3 Session Management | no | — |
| V4 Access Control | no | — |
| V5 Input Validation | no — no new input surface | — |
| V6 Cryptography | no | — |

No STRIDE-relevant threat pattern applies — this phase touches no trust boundary, no user input,
no secret. (Note: `gw_switch.dart` and the status-colour call sites are UI-only; none of the
touched files handle keys, mnemonics, or PINs directly — `pin_screen.dart:103`'s change is a label
*colour* only, not the PIN-handling logic itself.)

## Sources

### Primary (HIGH confidence — read directly this session)
- `lib/theme/genius_wallet_colors.dart` (full file) — every hex/alpha value cited above
- `lib/theme/gw_colors.dart` (full file) — `GWColors.light()`/`.dark()` factories, all field values
- `lib/components/inputs/gw_switch.dart` (full file)
- `lib/components/overlay/responsive_overlay.dart` (relevant sections)
- `lib/theme/genius_wallet_typography.dart` (full file)
- `lib/theme/theme.dart` (button/menu theme sections)
- `test/theme/theme_contrast_test.dart`, `disabled_control_contrast_test.dart`, `compute_contrast_test.dart`
- `test/components/mobile_nav_destinations_test.dart` (full file)
- `~35 individual call-site files` grepped and spot-read for backdrop context (see Item 2 table)
- `C:/Users/User/Documents/Projects/GNUS/flutter/flutter/packages/flutter/lib/src/material/app_bar.dart`
  (a sibling project's local Flutter engine checkout, found mid-session) — `_kMaxTitleTextScaleFactor`
  and its two `MediaQuery.withClampedTextScaling` call sites
- `.../packages/flutter/lib/src/widgets/media_query.dart:1368-1393` — `withClampedTextScaling`'s
  implementation
- `.../packages/flutter/lib/src/material/list_tile.dart:1759-1791` — `_LisTileDefaultsM3`'s
  title/subtitle/leadingAndTrailing text-style defaults
- `.../packages/flutter/lib/src/material/chip.dart:2499-2509` — `_ChipDefaultsM3.labelStyle`

### Secondary (MEDIUM confidence)
None remaining — the one item originally logged here (the `AppBar` clamp citation) was upgraded to
Primary once the local Flutter checkout was found and read (see Assumptions Log A1).

### Tertiary (LOW confidence)
None remaining — the two items originally logged here (`ListTile`/`Chip` Material 3 defaults) were
upgraded to Primary once the local Flutter checkout was found and read (see Assumptions Log A2/A3).

## Metadata

**Confidence breakdown:**
- Standard stack: N/A — no new dependency
- Architecture: HIGH — every file/line cited was read this session, including the three
  originally-assumed Flutter-framework claims, all resolved against actual SDK source found
  mid-session
- Pitfalls: HIGH — grounded in the codebase's own existing test patterns and doc comments
- Contrast math: HIGH — computed with the same WCAG relative-luminance formula the project's own
  `test/theme/theme_contrast_test.dart` already implements, not estimated
- Framework defaults (item 3's clamp API, item 4's `ListTile`/`Chip` fallback slots): HIGH —
  verified against Flutter engine source this session (see Sources, Primary)

**Research date:** 2026-09-25
**Valid until:** effectively indefinite for the token/geometry facts (they are code, not external
API surface) — re-verify only if `lib/theme/` or `responsive_overlay.dart` change before this phase
is planned/executed.
