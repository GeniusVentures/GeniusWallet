---
sketch: 171
name: mobile-home-and-nav
question: "How should the home screen and the navigation read on iOS when the bar carries 8 items and three labels do not fit?"
winner: null
tags: [mobile, ios, navigation, bottom-nav, header, home, dashboard, sheet, contrast]
---

# Sketch 171: Mobile home + navigation

## Design Question

The home screen and the whole of navigation on a phone: bottom bar, header and menu. The first sketch
of this round after the move to **mobile-only** (Jakub, 2026-08-06 - iOS is his surface, Brian runs Android).

## How to View

```
open http://localhost:8899/171-mobile-home-and-nav/
```

Server: `python3 -m http.server 8899 --directory .planning/sketches`

Open it in **Jakub's browser**, not in the extension's narrow viewport - the phones render 1:1
at 390 px, side by side with a column of notes.

## Variants

- **Today (baseline)** - the actual state of the iPhone Sidney, with five problems described by `file:line`.
- **A: Curated Five ★** - the bar cut to 5 items, four overflowing into a "More" sheet. The header carries the wallet. FAB removed.
- **B: Center Action** - 4 items + a centre dock opening an action sheet (Send/Receive/Swap/Buy).
- **C: Wallet Header** - the AppBar removed entirely, wallet identity moved into the scrolling content, +56 px of vertical space.
- **D: Segmented Home** - the bar carries actions only; Assets/Compute/Markets/News become segments inside Home.

## What to Look For

1. **Bar tile width.** Today 48.7 px per item and three ellipses. A/B/C give 78 px, D gives 97.5 px.
2. **Where the overflow lands.** A sheet (A, C), a two-level sheet (B), segments in the content (D).
   All 8 destinations stay reachable - a hard condition from Phase 4 and from the 2026-07-18 todo.
3. **What the header does.** Today the words "Genius Wallet" plus the desktop control track in a horizontal scroll.
   The variants replace it with wallet identity; C drops the AppBar altogether.
4. **Zero balance.** Today `textPrimary38` = 3.54:1, below AA. Every variant lifts it to `textPrimary80` = 12.4:1.
5. **The "Inventory and contrast" tab** - an Existing/Adapted/New table with proof in the file, computed ratios
   and a numeric comparison (new components, routes touched, taps to target).

## Findings grounded in code

| # | Problem | Place |
|---|---|---|
| 1 | One list of 8 destinations for both desktop and mobile | `responsive_overlay.dart:38-75` |
| 2 | Active tab: a silent `return 0`, `/buy` and `/token-info` highlight Dashboard | `responsive_overlay.dart:82-92` |
| 3 | The desktop control track in `AppBar.actions` behind a horizontal scroll | `responsive_overlay.dart:470-500` |
| 4 | Zero balance painted `textPrimary38`, 3.54:1, below AA 4.5:1 | `coin_card_row.dart:126,134` |
| 5 | FAB at `bottom: 80` overlaps the asset list | `global_swap_fab_host.dart:124-128` |

## Recommendation

**A + the control-track shrink from C.** A delivers the solution already written down in the todo without
inventing a new navigation language - one `New` item, one route touched, so it can be verified on the phone
in a single cycle. Runner-up **C** (the best design, but removing the AppBar touches eight routes at once -
its own phase). Rejected **B** (the dock is a new widget and it breaks the one-filled-gradient-per-surface rule).

## Open

- The composition of the five is a guess, not based on usage data.
- Light mode not computed (the "dark first" rule).
- The mockups show a zero-balance wallet - with real amounts the right column needs checking for wrapping.
- Verification on a real phone screen is still ahead of us: the preview came from the Mac camera, not from a screen feed.
