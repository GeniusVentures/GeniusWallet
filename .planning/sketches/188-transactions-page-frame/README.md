---
sketch: 188
name: transactions-page-frame
question: "Should /transactions be boxed or flat - and what does that force on /assets?"
winner: null
tags: [mobile, ios, transactions, page-frame, boxes, cards, filters, follows-187]
---

# Sketch 188 - the Transactions page: boxed or flat

http://localhost:8899/188-transactions-page-frame/

Jakub, 2026-08-08, before choosing between 187 C and 187 D: **build 188 for the transactions tab, I want
to see how it will look, and then I will pick which way we go.**

## The correction this sketch produced

Sketch 187 finding 3 says *no full page uses `DashboardScrollContainer` - not Transactions, not Markets,
not News*. **It is wrong.** `transactions_slim_view.dart:483`, the narrow-page branch of `_page()`,
wraps the transaction list in `DashboardScrollContainer` by name. The grep behind the original claim
searched the two files that define the panels and missed the one that consumes it from a page.

What every content surface actually does at 390pt:

| Surface | Boxed? | What draws the box | Where |
| --- | --- | --- | --- |
| Home | yes, one per panel | `DashboardScrollContainer` | `dashboard_screen.dart:395` |
| Activity / Transactions | yes, one around the list | `DashboardScrollContainer` | `transactions_slim_view.dart:483` |
| Markets | yes, one per coin | `GWCard` grid below `kMarketsTableMinWidth` | `markets_cards.dart:57` |
| News | yes, one per article | `GWCard` | `crypto_news_screen.dart:452`, `:591` |
| **Assets** | **no** | rows sit straight on `surfaceBase` | `assets_screen.dart:546` |

**Assets is the only unboxed list in the app.** That reverses 187's argument: boxing it is not importing
a dashboard device onto a page, it is stopping one page from being the exception. 187's HTML has been
annotated in place - the finding, A's verdict and C's verdict all carry the correction rather than
being silently rewritten.

## Variants

- **A: flat** - filter track and rows on the canvas. Assets' current language moved here. Widest rows
  (362 vs 348), but the day labels lose their container and read as three separate lists, and it is the
  one scheme that requires deleting working code.
- **B: as shipped** - page title flat, filter track flat on its own row, list in one panel. Drawn so the
  comparison has a baseline. The split is deliberate: the track is a control, the card is content, and
  the bar gets its own row on the phone so its 44px targets clear the card wall
  (`transactions_slim_view.dart:449-461`).
- **C: two panels** ★ recommended - track in its own panel, list in another, `space3` between them, the
  same rhythm `OneColumnDashBoardView:330` draws on Home. This is 187 scheme C's language on this page.

## What to look for

- **BUSY** first: three day groups. Compare how `Yesterday` and `7 Aug` read with and without a card
  around them.
- Tap a filter chip; tap it again to clear back to All (the shipped `emptySelectionAllowed` behaviour).
  Set **QUIET** then filter to Mint for the filtered-empty state, which quotes the real total.
- **EMPTY** hides the filter bar entirely - the same `scoped.isEmpty` rule the panel and the wide rail
  use (15-03).
- **RULER** on C: the track's left edge lands on the row wall (14), where in A it starts at 6.

## Provenance

Row anatomy from the shipped tree: title is the coin symbol, token-first (010-A, `transaction_utils.dart:421-429`);
the action leads the subtitle and never shrinks (179-C); the amount is **neutral ink in both directions**
(`_toneColor`, `transaction_displays.dart:182-185` - sketch 186 scheme A, shipped) and the value line is
never empty, falling back to `No price` (`:366`). Empty-state strings are `filteredEmptyTitle` /
`filteredEmptyMessage` verbatim (`transactions_slim_view.dart:159-166`). Filter set is `Filters.primary`
= Sent, Received, Mint, Jobs, then a 1x20 divider and the overflow trigger (`:112-118`), at
`touchChipSize` 44 (`:836`). Colours from `gw_colors.dart` dark(); spacing from `genius_wallet_consts.dart`;
row rhythm from `gw_row_rhythm.dart` (wall 8, icon 38, icon-to-text 8, separator 12/1/12). Inter inlined
from the shipping TTFs. `node --check` clean; div balance 0; rendered in jsdom with zero script errors
across all three schemes and all four states.
