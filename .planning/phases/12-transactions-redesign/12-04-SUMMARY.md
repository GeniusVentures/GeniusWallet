---
phase: 12-transactions-redesign
plan: 04
subsystem: dashboard/transactions
tags: [filters, coverage-bug, gradient, popup-menu, wcag, freeze-rule]
requires:
  - TransactionBadgeKind / badgeSpec / badgeGlyph (12-01)
  - TransactionRow (12-03)
  - GWSectionTitle trailing slot
  - GeniusWalletGradient.brandCta
provides:
  - Filters (10 values, primary/overflowTypes/overflowStatuses, isInOverflow)
  - filterCounts(List<Transaction>)
  - _TransactionFilterBar (private)
affects: [12-05 (panel assembly), 12-06 (walk)]
tech-stack:
  added: []
  patterns:
    - "Enum owns its own UI groupings, so a filter that exists but is in no group is a test failure"
    - "One layout-derived value per panel and it is a BOOLEAN (freeze rule 37639d5)"
    - "ShaderMask collapsed to a single repeated stop when the gradient fails AA on the surface"
key-files:
  created:
    - test/dashboard/transaction_filters_test.dart
  modified:
    - lib/dashboard/home/widgets/transactions_slim_view.dart
decisions:
  - "cancelled folds into the failed filter, mirroring escrowRelease folding into escrow"
  - "Light mode degrades the active menu label's shader to a flat brandPrimaryOnSurface — brandCta's own stops are 1.65:1/2.28:1 as light-mode text"
  - "PopupMenuDivider colour pinned to gw.borderSubtle rather than inherited from the app-wide dividerTheme"
  - "The bar is NOT wrapped in Flexible/FittedBox; compact mode is what makes it fit"
metrics:
  duration: ~75 min
  completed: 2026-07-22
requirements: [TX-03, TX-04]
status: complete
---

# Phase 12 Plan 04: Filter coverage + the F1 two-tier bar Summary

The five-value `Filters` enum became ten, closing the coverage bug where `swap`, `purchase`
and `process` were reachable by no filter at all, and the flat `SegmentedButton` became the
F1 two-tier control: four icon chips plus a `⋯` menu, gradient active state, live counts.
`transactions_slim_view.dart` went 169 → 469 lines (+395 / −98).

## What was built

### `Filters` — 10 values, groupings, and the predicate

Declared in UI order: `all`, then `sent · received · mint · jobs` (the locked title-row
order), then `escrow · swap · purchase`, then `pending · failed`. Two fields per value —
`label` and `badgeKind` (null only for `all`) — so a chip paints the same mark as the row
badge through 12-01's `badgeSpec`/`badgeGlyph`.

`matches()` stayed an exhaustive `switch` **expression**, so an eleventh value cannot compile
without a rule. New coverage: `jobs → process`, `swap`, `purchase`, `pending`, `failed`.
`escrow` still spans `escrow` + `escrowRelease`; `failed` spans `failed` + `cancelled`.

Three `static const List<Filters>` groupings (`primary`, `overflowTypes`, `overflowStatuses`)
plus `isInOverflow(f)` live on the enum. Top-level `filterCounts(txs)` returns a count for
every non-`all` value, computed once per build.

### `_TransactionFilterBar` — private, one call site

`Container(space2 pad, surfaceMenu, radiusMd, borderSubtle)` → `Row(min)` → four chips, a
1×20 `borderSubtle` rule, and the `⋯` trigger.

| State | Paint |
|---|---|
| Inactive chip | transparent, `textSecondary` glyph @15, `Tooltip` + `Semantics(selected:false)` |
| Active chip | `brandCta` **gradient fill**, `textOnBrand` glyph and label |
| Active + wide | expands to its label via `AnimatedSize` inside the `AnimatedContainer` |
| Active + compact | stays 32×32, icon-only |
| Trigger, overflow filter active | takes the same gradient + `textOnBrand`, tooltip `Filtered: {label}` |
| Menu item active | gradient **text on the label only**; the glyph is `textSecondary` @14 either way |

Tapping the active chip (or re-selecting the active menu item) clears back to `all` — the old
`emptySelectionAllowed` behaviour.

### Mounting

`LayoutBuilder` inside the existing `ConstrainedBox`, deriving exactly one value:
`final bool compact = constraints.maxWidth < 420`. The old
`Flexible > FittedBox(scaleDown) > SegmentedButton` is deleted, not moved — `scaleDown`
derives a continuous scale, which is the 37639d5 freeze class. A new `scopedTransactions`
getter holds the SGNUS scoping so counts describe the pre-filter list (counts taken after the
filter would read 0 for everything but the active one).

## Measurements (what 12-06's walk needs)

Measured with `tester.getSize` in `test/dashboard/transaction_filters_test.dart`.

| Thing | Harness | On screen (est.) |
|---|---|---|
| Resting bar (icon-only), all widths, both appearances | **179 × 42** | same — no text in it |
| Expanded bar (active chip showing "Sent") | **243 × 42** | ~217 |
| `"Transactions"` title, 18px | 213.6 | ~110 |

Bar height 42 = 32 chip + 2×`space2` + 2×1px border. Width 179 = 4×32 chips + `space2` +
1px rule + `space2` + 32 trigger + shell.

**Headroom at the narrowest real panel — this is the thin number.** The title row is
`space4` + title + bar. At a 320px panel that is 16 + ~110 + 179 = **~305px, about 15px of
headroom**. It fits, but barely, and there is no longer a `FittedBox` to absorb anything.
Raise the OS text scale, or lengthen the title, and 320 overflows. Worth an eye during the
walk at the narrowest the dashboard right column actually gets.

The test harness's fallback font draws one em per character, so `"Transactions"` measures
213.6 there instead of ~110 — under that font the row needs ≥409px and a 320px case
"overflows" by 89px for a reason that does not exist on screen. That is why the fit tests run
at 419/420/900 and pin the bar's own (font-independent) width instead.

## Deviations from plan

**1. [Rule 2 — accessibility] The active menu label's gradient fails AA in light mode.**

The plan specifies `ShaderMask(brandCta)` on the selected label. Measured against the light
`surfaceMenu` (`#EFF2F6`) the two stops are **1.65:1 (`#0AD89C`) and 2.28:1 (`#0AAEE6`)** —
the same class of defect the plan's own threat register (T-12-13) says must not be reused.
Dark is fine: 9.38:1 and 6.81:1.

Fix: `_activeLabelShader(gw)` keeps the real `brandCta` stops when the menu surface is dark
and collapses the shader to a single repeated `brandPrimaryOnSurface` (`#0A6885`, **5.61:1**)
when it is light. Collapsing a `ShaderMask` to one repeated stop is the pattern
`gw_view_all_link.dart:67` already uses, so there is still one paint path and no branch in
the widget tree. Keyed off `gw.surfaceMenu.computeLuminance()` — the surface actually being
painted on — rather than the global appearance flag, so it cannot disagree with the
`GWColors` in scope (the `badgeGlyphColor` precedent from 12-01).

No new palette token was invented. The app ships no brand green dark enough for light-mode
body text: light `statusSuccess` `#07875F` measures 4.03:1 on `surfaceMenu`, under AA, so a
two-stop light gradient was not available without a new colour — which is Jakub's decision,
not the executor's.

**2. [Rule 3 — blocking/consistency] `PopupMenuDivider` colour pinned.**

A bare `PopupMenuDivider()` inherits the app-wide `dividerTheme`
(`colorScheme.surfaceContainerHighest`, `theme.dart:401`), which would make it the one
hairline in this control not drawn in `gw.borderSubtle`. Now
`PopupMenuDivider(thickness: 1, color: gw.borderSubtle)` — same rule as the list separators.

## Contrast audit (all pairings, both appearances)

| Pairing | Dark | Light |
|---|---|---|
| Inactive chip / trigger glyph — `textSecondary` on `surfaceMenu` | 5.39 ✓ | 5.61 ✓ |
| Active chip glyph + label — `textOnBrand` on the two gradient stops | 10.66 / 7.74 ✓ | same ✓ |
| Menu header + count — `textSecondary` on `surfaceMenu` | 5.39 ✓ | 5.61 ✓ |
| Menu label inactive — `textPrimary` on `surfaceMenu` | 17.41 ✓ | 16.55 ✓ |
| Menu label ACTIVE — shader stops on `surfaceMenu` | 9.38 / 6.81 ✓ | 5.61 ✓ (after the fix) |

## Outstanding / flagged for the walk

1. **Active-chip FILL vs the bar surface in light mode is 1.65:1 / 2.28:1.** WCAG 1.4.11 asks
   3:1 for the visual information identifying a component's state. Not fixed here: "active
   chip = the `brandCta` gradient" is a locked design decision, and the state is also carried
   by the glyph flipping to `#000B18` ink (10.66:1 on the fill), which is a strong,
   non-luminance-only signal. Judge it live; if it reads weak, that is a design call for
   Jakub, not a silent executor change.
2. **`PopupMenuButton` styling that does NOT come from `gw` tokens** — check these live:
   `color` and `shape` (surfaceMenu + borderSubtle side) are honoured, and the divider is now
   pinned. Still ambient: the menu's **elevation shadow** (Material default 8 — quick task
   260720-lyn softened card/dialog shadows and this popup was not in that pass, so it may be
   the hard one), the **item hover/highlight overlay**, and the menu's 112px minimum width.
3. **~15px of title-row headroom at a 320px panel** (see Measurements). No `FittedBox` safety
   net remains.
4. **`GWSectionTitle`'s title `Text` is unwrapped**, so any overflow there is a hard
   RenderFlex overflow rather than an ellipsis. Out of this plan's file scope; noted for
   whoever owns that component.

## Verification actually run

| Check | Result |
|---|---|
| `flutter analyze lib/dashboard/home/widgets/transactions_slim_view.dart test/dashboard/transaction_filters_test.dart` | **No issues found!** |
| `flutter analyze lib/dashboard/transactions` (the mount points) | **No issues found!** |
| `flutter analyze` (whole project) | 409 issues, all pre-existing infos/warnings, **zero errors**; none in the touched files |
| `flutter test test/dashboard/transaction_filters_test.dart` | **33 passed** |
| `flutter test` (full suite) | **177 passed, 1 failed** |
| `grep -c 'GeniusWalletGradient.brandCta' …slim_view.dart` | **3** (chip fill, trigger fill, dark-mode label shader) |
| `grep FittedBox\|AutoSizeText` in the title-row path | none — the only `AutoSizeText` left is the pre-existing count footer |
| Contrast maths | computed from the real token values for all pairings above |

**Baseline was 144 passed / 1 failed.** Ending state: **177 passed / 1 failed** — 33 new
tests, no regressions. The single red is still the pre-existing
`test/local_wallet_storage_test.dart` → `Missing definition of 'main' method` (the file is
fully commented out); it was red before this plan and is untouched by it.

### What was NOT verified

**Nothing was rendered on screen.** The app was not launched on macOS. The 10 widget tests do
perform real Flutter layout and paint of the bar — in both appearances, at 419/420/900px,
including opening the popup and selecting an overflow filter — but headlessly, with the
harness's substitute font. Live appearance, the popup's shadow, hover states and the real
Inter metrics are 12-06's walk.

## Compliance

- **No commits created.** Nothing staged. `./CLAUDE.md` holds the commit gate.
- Shared-tree files left alone: `cmake/*.cmake`, the Apple-signing files, sketches 015,
  `.planning/spikes/`. `STATE.md` / `ROADMAP.md` not touched — the phase is not finished
  (12-05, 12-06 remain).
- `lib/theme/theme.dart` not touched.
- Freeze rule: the one layout-derived value in the panel is the `compact` **boolean**. Every
  other dimension is a fixed literal or a `genius_wallet_consts` token. No `FittedBox`, no
  `AutoSizeText`, no `textScale`-derived sizing added.
