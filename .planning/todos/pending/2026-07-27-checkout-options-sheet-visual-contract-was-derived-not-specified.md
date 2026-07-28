---
created: 2026-07-27T00:00:00.000Z
title: Checkout options sheet's visual contract was derived, not specified
area: ui
files:
  - lib/banxa/handle_banxa_drawer.dart
---

## Problem

`09-CONTEXT.md` D-07 (dated after `09-UI-SPEC.md` was finalised) brought
`lib/banxa/handle_banxa_drawer.dart` INTO Phase 9's scope — reversing
`09-UI-SPEC.md`'s own "Checkout options sheet — Boundary Note", which had
explicitly fenced this file OUT as "not authorized" this phase. D-07 wins
(it is the later decision), but the practical consequence is that
`handle_banxa_drawer.dart` is the ONE file in the whole phase re-skinned
with **no per-file Component Inventory row** in `09-UI-SPEC.md` — unlike
every other in-scope Banxa surface, which had an approved, checker-signed
visual contract to build against.

Phase 9 (plan `09-05`, Task 2) therefore **derived** this file's treatment
rather than implementing a specified one:

- Typography: the ad-hoc 16px/w600 title retyped to
  `GeniusWalletTypography.titleLg` on `gw.textPrimary` — the app-wide token
  rule, not a contract line written for this file.
- Buttons: the three raw `ElevatedButton`s mapped onto the `GWButton`
  variant vocabulary by analogy with 09-UI-SPEC's "Accent reserved for"
  rule (none of the three routes to the same checkout is the singular
  money-moving action) — `secondary` for "Open in Browser" / "Show QR",
  `tertiary` for "Copy checkout link". This mapping is Claude's
  extrapolation from the rule's spirit, not a line item that named this
  sheet.
- Sheet background: `gw.surfaceElevated` was added explicitly at the
  `showModalBottomSheet` call site after confirming the Material default
  (a computed tonal container derived from `ColorScheme.surface`) does not
  literally resolve to the same token.

**The presentation mechanism was deliberately left unchanged.** This sheet
is architecturally a strong candidate for the shared drawer archetype (the
`ResponsiveDrawer.show` shell already used by `swap_settings_drawer.dart`
and `transaction_displays.dart`'s `showTransactionDetails`), but that
helper switches to a centred dialog at/above `GeniusBreakpoints.medium`
(`lib/components/bottom_drawer/responsive_drawer.dart:21,40,72`).
Adopting it here would silently change this sheet's presentation from a
bottom sheet to a centred dialog on every desktop window — a
restructuring change under `PROJECT.md` §65, not a re-skin, and therefore
out of bounds for a `D-01` re-skin-only phase. `showModalBottomSheet`, its
`showDragHandle: true`, its builder shape and the `parentContext` plumbing
were all kept byte-identical.

## Ask

Phase 21 (the drawer-language rollout, which already owns plan `21-04`
for the four Phase-9-adjacent `buy_success_drawer.dart` /
`buy_cancelled_drawer.dart` drawers under `09-CONTEXT.md` D-05) should
explicitly claim `handle_banxa_drawer.dart` if/when it wants this sheet
migrated onto the real `ResponsiveDrawer` archetype. That migration needs
its own reviewed contract for:

1. Whether the sheet becomes a centred dialog on desktop (an intentional
   presentation change) or `ResponsiveDrawer` grows a bottom-sheet-only
   mode for this call site.
2. A reviewed Component Inventory row confirming the button-variant
   mapping this todo's author (09-05) chose by analogy, rather than by
   spec.

A reviewer auditing `handle_banxa_drawer.dart`'s current re-skin should
judge it against this derived basis, not assume it passed the same
per-file checker gate every other Phase 9 surface did.
