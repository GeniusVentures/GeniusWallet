---
created: 2026-07-18T10:52:39.825Z
title: Const widgets do not re-skin on live appearance toggle
area: ui
files:
  - lib/theme/genius_wallet_colors.dart:78
  - lib/theme/gw_appearance.dart:13
  - lib/components/cards/gw_token_row.dart:60
  - lib/components/cards/gw_wallet_card.dart:62
---

## Problem

Surfaced during the Phase 4 / 04-01 D-02 gallery re-walk (2026-07-18).

On a live appearance toggle (sun/moon in the Design Gallery, or the Preferences
Appearance row in the real app), `const` widgets that read colors from
`GeniusWalletColors.*` **static getters** keep their stale colors and do not
re-skin. Observed concretely: the `const GWTokenRow` and `const GWWalletCard`
demo instances stay with dark-mode text colors after toggling to light, making
their text unreadable (light text on the now-light canvas).

Root cause: `GWAppearance` + `GeniusWalletColors` are NOT an `InheritedWidget`.
The only reason a live toggle re-skins anything is that `main.dart`'s
`ValueListenableBuilder` rebuilds the entire `MaterialApp` subtree. But Flutter's
`Element.updateChild` short-circuits when the new child is `identical` to the old
one — which is exactly the case for canonicalized `const` widgets — so their
`build()` never re-runs and they render the previously-resolved static-getter
color.

Confirmed consistent within the same gallery walk: the **non-const**
`GWIcon.material(color: GeniusWalletColors.textPrimary)` flips correctly, while
`const` widgets do not. Non-const cards/surfaces also flipped (user confirmed).

IMPLICATION: this is NOT a gallery-only artifact. Any `const` component in the
real app that reads the static color getters will show stale colors after a live
toggle until it naturally rebuilds (e.g. navigation / setState higher up). This
undermines the whole point of 04-01 (live re-skin) for const subtrees.

## Solution

TBD — evaluate during Phase 4 planning. Candidate approaches:

1. **ThemeExtension (preferred, idiomatic):** move the appearance-aware colors
   into a `ThemeExtension<GWColors>` attached to `ThemeData`, and have components
   read them via `Theme.of(context).extension<GWColors>()`. Because `Theme` is an
   `InheritedWidget`, dependents rebuild on theme change even when the widget
   itself is `const`. This aligns with `theme.dart` already being appearance-aware.
2. **InheritedWidget/InheritedModel for GWAppearance:** wrap the app so reading
   the appearance registers a dependency; const dependents then rebuild.
3. (Weakest) drop `const` at call sites — fragile, easy to regress, doesn't fix
   the underlying architecture.

Cross-refs: relates to the existing todo
`2026-07-17-design-system-has-no-light-mode-treatment.md`. The sibling Inter-font
finding is resolved (moved to todos/completed/ by 04-02 Task 3).

## Status (2026-07-18)

**Mechanism FIXED by plan 04-02.** The `GWColors` ThemeExtension exists and is
attached in `getThemeData()`, and 11 gallery-const-instanced components were
migrated to `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` — the
D-02 re-walk confirmed they now re-skin on a live toggle. This todo stays open
only for the **~13 deferred appearance-aware readers** (gw_text_field's siblings,
gw_select, gw_card, gw_gradient_border_card, gw_spinner, gw_dialog,
gw_bottom_sheet, bottom_drawer, gw_screen, coin_card_container,
genius_wallet_decorations, genius_wallet_gradient, token_probe_screen) recorded in
04-02-PLAN.md's `migration_surface`. They are migrated opportunistically as the
re-skin plans 04-03..07 rebuild those surfaces (avoids touching a surface twice).
Close this todo when the deferred set is fully on GWColors.

**Shared-component gap (flagged during the 04-04..07 GWColors alignment,
2026-07-18):** `gw_card.dart`, `gw_dialog.dart`, and `bottom_drawer.dart` are
deferred readers used across MULTIPLE screens, so they are not in any single
re-skin plan's `files_modified` and would otherwise fall through the cracks —
their internal card/dialog/drawer chrome won't flip live until migrated in place.
Assign these three to plan 04-04 (which re-skins the drawer + delete dialog
surfaces): widen 04-04's scope to migrate them, OR handle as an explicit
follow-up before Phase 4 closes. Decide at 04-04 execution.
