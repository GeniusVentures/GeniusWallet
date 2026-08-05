---
created: 2026-07-20T12:55:00.000Z
title: Surface-card shadows are clipped (markets grid + mobile dashboard sections)
area: ui
files:
  - lib/dashboard/chart/markets_screen.dart
  - lib/theme/genius_wallet_decorations.dart
  - lib/dashboard/home/view/dashboard_screen.dart
  - lib/components/overlay/responsive_overlay.dart
---

## Problem

Found during the 05-04 markets walk (2026-07-20). The redesign's elevated surface cards
(`GWDecorations.surface(elevated: true)` → `boxShadow: GeniusWalletElevation.card`,
genius_wallet_decorations.dart:88-103) render with their **soft card shadow visibly cut
off**. Two places:

1. **Markets view (desktop grid)** — main occurrence. `markets_screen.dart`'s
   `GridView.builder` packs the surface cards with `mainAxisSpacing: 8` / `crossAxisSpacing: 8`,
   `mainAxisExtent: 80`, `padding: EdgeInsets.only(bottom: 16)` (no horizontal/top padding),
   and each card Container is `clipBehavior: Clip.hardEdge`. The card fills its whole cell, so
   the downward/outward card shadow (blur > 8px) immediately hits the cell boundary — it's
   overlapped by the adjacent card's opaque surface and clipped by the scroll viewport at the
   grid edges. Result: shadows look sliced.
2. **Mobile / narrow layout** — the WHOLE set of dashboard card sections shows the same
   clipped-shadow behavior (per the walk). The desktop dashboard card is fine; only the
   mobile/responsive arrangement clips. Likely the same root cause in the mobile section
   stacking (tight spacing / a clip boundary in DashboardScrollContainer or the mobile
   dashboard layout leaving no room for the shadow).

Note: `Clip.hardEdge` on the card clips the CHILD to the rounded rect (correct for corners);
it does NOT itself clip the shadow. The real cause is insufficient room/margin around the
shadowed surfaces + viewport/grid clip boundaries.

## Solution

TBD — give the elevated surface cards enough breathing room for their shadow to render, and
keep clip boundaries off the shadow:
- Markets grid: increase grid spacing (≥ the shadow's effective extent) and/or wrap each card
  in a small `Padding` margin inside its cell; add horizontal + top padding to the GridView so
  edge cards' shadows aren't clipped by the viewport.
- Mobile dashboard sections: give each section margin so its shadow clears the next section /
  the container clip; verify against the narrow/MobileOverlay layout (resize the desktop window
  to the mobile breakpoint — Android build is separately blocked).
Needs a desktop + mobile-breakpoint walk in both modes. Re-skin/layout only; keep behavior.
Route via GSD (dedicated quick task — cross-cutting across markets + dashboard container).
