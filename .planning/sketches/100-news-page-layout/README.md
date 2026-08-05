---
sketch: 100
name: news-page-layout
question: "What is the Crypto News tab for — fast scanning, visual browsing, or a filterable feed?"
winner: "B"
tags: [news, page-layout, feed, rail, cointelegraph]
lane: design-A
---

# Sketch 100: News Page Layout

## Design Question

The `/news` tab currently renders a staggered grid of 300px photo tiles, every fifth one arbitrarily
double-wide, each 220px tall, with the headline burned into a black gradient at the bottom. It answers
no question about what the page is *for*. This sketch forces that choice.

## How to View

```
open .planning/sketches/100-news-page-layout/index.html
```

## Variants

- **A: Dense feed** — headline is the hero, photo demotes to a 104×72 thumbnail, `description` finally
  renders as a one-line dek. Ten stories per screen instead of four. Cheapest: drops
  `flutter_staggered_grid_view` for a `ListView.separated`.
- **B: Magazine** — the newest story as a full-width hero, the rest as an even 3-column grid. Closest to
  today's photo-led identity, but with an actual reading order. Loses on density.
- **C: Feed + topic rail** — ~~recommended~~ **withdrawn 2026-07-23 after measuring the live feed.**
  A's feed plus the left filter rail the Transactions tab already won (sketch 021 B) with the active
  mark already chosen (sketch 022 B2). Rail rows were to come from the RSS `<category>` element the
  parser drops. The feed returns **three** categories — `Latest News` ×25, `Markets` ×4, `Magazine` ×1.
  The rail in the sketch is drawn against six *invented* topics, which is the only reason it looked
  viable. Kept visible so the shape stays on record; the topic axis does not.

**Recommendation was A** (density + it removes a dependency). **Jakub chose B on 2026-07-23** — the
photo-led identity is worth keeping, and the density objection is a tuning problem, not a structural
one. Refined in sketch **101**.

All three replace the black-scrim hover with the lift chip from sketch 008 D, and all three put a
Refresh chip in the header — today the only refresh is `RefreshIndicator`, which a mouse cannot reach.

## What to Look For

1. **Density vs. identity.** A shows ten stories where the current screen shows four. B keeps the
   photo-forward look. Which matters more for a tab people open to check what happened?
2. **Hover.** Move over a row/card in each. Today hover *removes* information (`Colors.black87` covers
   the photo and reprints the same title). Every variant here adds instead.
3. **Narrow.** Hit `420` in the toolbar. A and C become the same single-column list; C's rail becomes a
   horizontal chip strip. B's hero still eats the first screen for one story.
4. **Search.** Type into the search box in any variant — it filters live over the already-fetched list.
   No network, no new state, just a `where()`.
5. **C's rail.** Compare it against the Transactions tab. If it reads as the same component, News stops
   being the one page in the app that looks foreign.

## Code-Grounded Findings

Seven findings are tabulated in the sketch itself with file:line evidence. Three are behavioural bugs
that need fixing regardless of which variant wins:

| # | Finding | Evidence |
|---|---------|----------|
| 1 | Hover covers the card in `Colors.black87` and reprints the same title — it subtracts information | `crypto_news_screen.dart:154-185` |
| 2 | `description` is fetched, unescaped, cached in Hive, and never rendered | `news_article.dart:12`, no read in the view |
| 3 | `pubDate` is a **frozen string** — `timeago.format()` runs at fetch time and the result is persisted, so a cached article says "2 hours ago" indefinitely | `coin_telegraph_api.dart:63-65, 94` |
| 4 | Empty/error states are bare `Text` while `GWEmptyState`/`GWErrorState` exist | `crypto_news_screen.dart:55-70` |
| 5 | Only refresh path is pull-to-refresh — unreachable on desktop | `crypto_news_screen.dart:72` |
| 6 | Fixed 220px tiles at `maxCrossAxisExtent: 300`, every 5th double-wide — ~20 equal-weight photos at 1280px | `crypto_news_screen.dart:75-86` |
| 7 | RSS `<category>` is parsed past and dropped — but the feed only carries 3 categories, 25 of 30 items in one of them, so there was nothing worth keeping | `coin_telegraph_api.dart:45-90` |
| 8 | All 30 items carry `<enclosure>`, so `imageUrl` always resolves there — the `<img>` regex fallback is **dead code** | `coin_telegraph_api.dart:75-81` |

Finding 2 carries a trap: the raw `description` begins with an `<img src="…"/>` tag. Rendering it
directly prints markup at the user — it needs stripping before it can be a dek.

## Cost

| Variant | Cost |
|---------|------|
| A | Negative — removes the `flutter_staggered_grid_view` dependency. Search is a local `where()`. |
| B | Neutral — also drops the staggered grid for a hero + `GridView`. |
| C | Withdrawn. Cost was real (parsing + Hive field + rail widget); benefit measured to zero. |

## Live Feed Measurement (2026-07-23)

Fetched `https://cointelegraph.com/rss` and counted, rather than assuming:

| Measurement | Value | Consequence |
|---|---|---|
| Items per fetch | 30 | ~3 screens in A. Nothing here needs filtering. |
| Span, newest → oldest | ~27 h | One day of news, not an archive. A scan list, not a corpus. |
| Distinct `<category>` | 3 — Latest News 25, Markets 4, Magazine 1 | **Killed C.** |
| Items with `<enclosure>` | 30 / 30 | Finding 8 — the `<img>` regex fallback is dead code. |
| `description` length | 421 chars of HTML | Confirms finding 2's `<img>` trap; ~250 chars survive stripping. |
| Title length min/avg/max | 36 / 68 / 102 | 102 chars needs 2 lines at 16px/22px — fits A's row, truncates in today's tile. |
