---
sketch: 102
name: news-hero-band
question: "B2's Next up band fixes the first impression but not page length — how do two improved B2s fix both?"
winner: "B2 (reference)"
decided: "2026-07-23 — Jakub chose plain B2 (hero + Next up + full 3-col grid) over B2-I and B2-II. The shorter-page improvements were not taken; the full photo grid for all items is wanted."
tags: [news, magazine, next-up, hero, density, components]
lane: design-A
refines: 101
---

# Sketch 102: The Hero Band

## Design Question

Sketch 101 B2 introduced a **Next up** column beside the hero. It gives a strong front-page feel but only
fixes the first row — items 5-30 still scroll as full-size photo cards, so the page stays ~7 screens. This
sketch keeps B2 as a reference and offers two improvements that keep the band and also shorten the tail.

## What "Next up" is (and its usefulness)

Beside the big lead story sits a short **ranked list of the next headlines** — number, title, timestamp,
**no photo**. It is the newspaper front-page move: one splash, then "also today". It buys density above the
fold without giving every story its own photo card, and it preserves hierarchy (the lead is unmistakably
the lead). Its limit: it only decorates the top row. Both improvements below extend that idea into the
whole page.

## How to View

```
open .planning/sketches/102-news-hero-band/index.html
```

## Variants

- **B (parent, reference)** — hero + even 3-column grid. No Next up. The sketch-100 winner.
- **B2 (reference, from 101)** — hero + Next up (items 2-4), then a full 3-column grid for the rest.
  4 above the fold, ~7 screens.
- **B2-I: Front page** *(recommended)* — hero + Next up (items 2-5) is the entire photo treatment; below
  it one `GWSectionTitle('Earlier')` and every remaining story as a compact 88×60 row. **One photo card
  total, ~3 screens.** Fewest photo layouts, shortest page, most honest about how many stories earn a big
  photo.
- **B2-II: Featured trio** — tall hero + two medium photo sub-cards stacked beside it (items 2-3), so
  three stories get a photo. Under the band, Next up carries items 4-7, then the compact Earlier tail.
  **Three photos above the fold, ~4 screens.** The middle ground if B2-I reads too text-heavy.

## What to Look For

1. **Switch to 900, scroll each to the bottom** — the page-length comparison. B2 is long; I and II are not.
2. **Top row, I vs II** — is one big photo enough (I), or do you want three (II)?
3. **Hover** — card lift on the hero/photo cards vs the plainer list-row hover on Next up and tail rows.
4. **Switch to 420** — Next up drops below the hero, sub-cards stack, tail rows stay legible at 88×60.
5. **Search** — everything re-ranks live over the fetched list.

## Density Summary

| Variant | Above the fold | Total screens | Photo cards to lay out |
|---------|---------------|---------------|------------------------|
| B2 (ref) | 4 | ~7 | 30 |
| **B2-I** | 5 | **~3** | **1** |
| B2-II | 3 | ~4 | 3 |

## Components

Identical map to sketch 101. Only net-new widget is the compact tail row (~40 lines), shared by I and II.
The standing gap is unchanged and is the highest-leverage fix: **`GWCard` has no hover state**
(`gw_card.dart:62-71` wraps `onTap` in an `InkWell`, not the 008 D lift) — add a `hoverLift` flag once and
every card surface in the app inherits the standard hover. Next up and tail rows are plain `InkWell` list
rows and need nothing new.
