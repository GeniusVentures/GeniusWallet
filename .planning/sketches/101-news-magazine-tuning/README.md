---
sketch: 101
name: news-magazine-tuning
question: "B won — now how does the magazine layout carry 30 items without becoming eight screens of scrolling?"
winner: "B2"
tags: [news, magazine, density, components, hover, gw-card]
lane: design-A
supersedes: null
refines: 100
---

# Sketch 101: Magazine, Tuned

## Design Question

Sketch 100 B (magazine) won on identity — the photo-led feel is worth keeping. It lost the argument on
density: the live feed returns **30 items**, and B shows roughly four per screen. This sketch keeps B
and asks only how it carries thirty stories.

Secondary brief from Jakub: *lean on existing components as much as possible.*

## How to View

```
open .planning/sketches/101-news-magazine-tuning/index.html
```

## Variants

- **B1: Tight** — nothing structural moves. Hero 280→230px, grid 3→4 columns at ≥1200px with 130px
  photos, dek cut to one line. ~7 stories on the first screen, ~5 screens total. Zero new widgets.
- **B2: Hero + Next up** — the hero keeps its size but shares the first row with a **Next up** column of
  three headline-only rows. First screen carries 4 stories with one still clearly the lead. Best front
  page; barely touches the page length (~7 screens).
- **B3: Head & tail** *(recommended)* — hero + 6 cards is one magazine screen, then a
  `GWSectionTitle('Earlier')` and the remaining 23 items as compact 88×60 rows. **~3 screens instead of
  eight**, photos still leading. The row is the one already drawn in sketch 100 A.

## What to Look For

1. **Hover any card.** This is the 008 D lift chip applied to a card — the treatment `GWCard` would
   gain. Compare against today's black scrim.
2. **Switch to 900 and scroll each variant to the bottom.** That is the real comparison: page length.
3. **Switch to 420.** B1's grid collapses to one column, B2's Next up column drops below the hero,
   B3's tail rows stay legible at 88×60.
4. **In B1, find the longest headline in the 4-column grid.** At 1280 each card is ~296px; the measured
   max title is 102 chars. Decide whether that is too tight.

## The Component Gap

The sketch's component table maps every part to a real widget. One entry is not a mapping but a gap:

> **`GWCard` has no hover state.** Passing `onTap` wraps the card in an `InkWell`
> (`gw_card.dart:62-71`), which paints Material's grey highlight — not the lift chip that sketch 008 D
> made the design-system standard. Today's news card works around this with its own `MouseRegion` plus
> a black scrim (`crypto_news_screen.dart:110-126, 154-185`).

Adding a `hoverLift` flag to `GWCard` is the highest-leverage line in this sketch: every card surface
in the app — Assets, Markets, Transactions, News — gets the standard hover from one change, and the
News screen stops hand-rolling it.

Everything else maps cleanly to something that already ships:

| Part | Component | Note |
|------|-----------|------|
| Page title + Refresh | `GWPageHeader(title:, trailing:)` | `trailing` slot already exists; it owns the `space8` gap |
| Hero / news card | `GWCard(onTap:, radius: radiusLg)` | Sheen + hairline + `elevation.card` for free; today's card hand-rolls all three |
| "Earlier" / "Next up" | `GWSectionTitle(title:, trailing:)` | 18px `titleLg`, reserves the shared 44px header height |
| Search | `GWTextField(hint:, prefix:, onChanged:)` | Leave `label` null so no label row renders |
| Refresh | `GWButton(variant: ghost, size: sm)` | Both already in the enums |
| Photo | `CachedNetworkImage` | Already the dependency in use |
| Loading | `PulsingSkeleton` | Arrangement drawn in sketch 102 |
| Empty / error | `GWEmptyState` / `GWErrorState` | Today the screen uses bare `Text` |
| Grid | `GridView` + `SliverGridDelegateWithMaxCrossAxisExtent` | **Drops the `flutter_staggered_grid_view` dependency** |
| Tail row (B3) | new, ~40 lines | Same anatomy as the transaction row; not worth generalising yet |

## Density, Against the Real Feed

| Variant | First screen | Total screens | Cost |
|---------|-------------|---------------|------|
| B1 | ~7 | ~5 | Metric change only |
| B2 | ~4 | ~7 | One `GWSectionTitle` + a headline-row |
| B3 | ~5 | **~3** | One `GWSectionTitle` + a tail-row widget |

Measured from the live feed on 2026-07-23: 30 items spanning ~27 hours, titles 36/68/102 chars
(min/avg/max). See sketch 100's "The live feed, measured" table.
