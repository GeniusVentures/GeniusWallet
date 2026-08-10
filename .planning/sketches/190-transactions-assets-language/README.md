---
sketch: 190
name: transactions-assets-language
question: "How many panels does /transactions get in the language Assets just shipped, and what is in the first one?"
winner: null   # recommending C
tags: [mobile, ios, transactions, page-frame, panels, filters, kicker, count, summary-band, honesty, follows-187, follows-188]
---

# Sketch 190 - the Transactions page in the language Assets just shipped

http://localhost:8899/190-transactions-assets-language/

Jakub, 2026-08-09: *show me how the Transaction Page will look using similar components and approach to
the Asset Page.*

Sketch 188 asked "boxed or flat" and that is now settled by shipping: `af287d63` made `/assets` two
panels, dropped its back link and put it on the shared page frame. So this sketch asks the question
that is actually left - **how many boxes, and what is in the first one** - and it answers it against a
reference tab that draws `/assets` as it shipped, so "the same language" is something you can put side
by side rather than a phrase.

## The reference, piece by piece

Every scheme is scored against this. Anything a scheme does that is not here is a **deviation**, named
in that scheme's notes.

| # | Piece | Component | Source |
| --- | --- | --- | --- |
| 1 | Page title, no back link | `GWPageHeader` | `assets_screen.dart:395` |
| 2 | Title inset 15 at phone | `gwPageHeaderContentInset` | `1 + space3 + space4` |
| 3 | Frame: gutter 6, title gap 24 | `GeniusBreakpoints` | `:316-320` |
| 4 | **Panel 1**: kicker + the number | `DashboardScrollContainer` | `:400` |
| 5 | Gap between panels | `space3` = 6 | `:401` |
| 6 | **Panel 2**: search, kicker + control, rows | `DashboardScrollContainer` | `:406` |
| 7 | Search at FULL card width, no wall | `GWSearchField` | `:417` |
| 8 | Kicker + control at the `space4` wall | `GWKicker` dense | `:429-449` |
| 9 | Rows + hairline dividers | `kGWRowPadding`, `borderSubtle` | `gw_row_rhythm.dart` |

The one piece Transactions has and Assets does not is a **filter track**: Assets' panel 2 leads with a
search field, Transactions' leads with five 44px chips. That single difference is the whole sketch.

## The defect the boxing question does not touch

Assets always says how many things it is showing and whether a filter is narrowing them - `"3 of 11
assets"` (`:440-442`). **Transactions says nothing.** The footer count went in Phase 12, and sketch 023
gave the number to the wide rail's `All` row, which a phone never renders. So on a phone, filtering to
Mint and seeing four rows leaves you unable to tell four-of-four from four-of-forty without clearing
the filter.

Every scheme below fixes this the same way, with `GWKicker`. It is called out here so it is not
mistaken for a benefit of any one scheme.

## Variants

- **/assets - the reference** - not a candidate. The thing to match.
- **Today - as shipped** - the control: `transactions_slim_view.dart:445-490`, title, filter track flat
  on the canvas, list in one panel. Worth saying plainly: this page was designed, not defaulted - the
  comment at `:449-461` gives a real reason for the split (the track is a control, the card is
  content, and the bar gets its own row so its 44px targets clear the card wall). What changed is that
  the tab beside it stopped agreeing.
- **A: Two panels** - Assets' geometry taken literally: control in panel 1, content in panel 2,
  `space3` between. The track's left edge moves 6 -> 14, onto the row wall, so the page finally has one
  left edge. Carries a real objection: sketch 184 rejected boxed menu sections as *a box over one row*,
  and Assets' panel 1 is not analogous - it holds a kicker **and** a 24px number.
- **B: Assets twin** - panel 1 carries a number, with the number itself toggleable. This is the scheme
  Jakub asked to see both ways, and building it settled it. See below.
- **C: One panel** ★ **recommended** - Assets' *panel 2* and nothing else: track, kicker with the
  count, rows - one box, same order, same walls.

## What B proved

Toggle **NUMBER** under B's phone.

- **b1 - counts.** "24 transactions, 30 days" with the sent / received / mint / jobs split. Every term
  is a `length` over a list the page already holds, and `filterCounts()` already runs on this screen
  (`transactions_slim_view.dart:129`). Nothing can be stale, and it is true for a wallet with no price
  feed at all.
- **b2 - net fiat flow.** "+ $1,842.19 in 30 days" in `numericHeadline`, the same type as Assets'
  total. It reads better and it **cannot be computed correctly**: the row's value line falls back to
  `No price` when a token has no market data (`transaction_displays.dart:366`) - the BTC row in the
  sketch shows exactly that. Set NUMBER to b2 with data on BUSY and the band prints a total while a row
  below it says `No price`. The footnote ("excludes 1 unpriced") is the mitigation, and a summary that
  needs a footnote explaining what it left out has not earned its panel.

The deeper finding is not about honesty. Assets' total answers a question a user actually has - *what
is my wallet worth* - and it is the same number as the dashboard's, which is why `7b2fd474` promoted
`AssetsTotalBand` so the two could not drift. **There is no equivalent question for an activity feed.**
Neither b1 nor b2 is a number anyone opens this tab to read, and both spend ~92px of a 628px viewport
saying it.

**So: reject B, and keep b1's count - but as a kicker, not a band.** It costs 16px instead of 92 and
sits next to the thing it counts. B's contribution is proving that the number Transactions was missing
is a kicker, not a hero.

## Why C is the recommendation

A and B both read "the same language as Assets" as "the same number of boxes". What actually makes
Assets read the way it does is the **inside** of panel 2 - a control at the top, a kicker counting what
is below it, then rows at a shared wall. C takes that and drops the ceremony:

| Position | /assets | C |
| --- | --- | --- |
| Panel top | `GWSearchField`, full card width | filter track, the page's primary control |
| then `space6` | 12 | 12 |
| Kicker at wall 8 | "11 assets" / "3 of 11 assets" | "24 transactions" / "4 of 24 transactions" |
| then `space4` | 8 | 8 |
| Rows | `CoinCardRow` + divider | transaction row + divider |

Cost against today: **+20px** of vertical and one `space3` gap saved by not having a second panel.
Against A: **-14px** and one fewer container. Row content width is 348 in all three - the boxing
already happened when the list got its panel.

## What to look for

- **RULER** on, then flip A -> B -> C and watch the vertical dashed line. In Today the track starts at
  6, on the canvas; in all three schemes it starts at 14, on the row wall.
- Tap a filter chip and read the kicker: it becomes "3 of 8 transactions". Tap it again to clear back
  to All - the shipped `emptySelectionAllowed` behaviour.
- **EMPTY** hides the filter track entirely in every scheme - the same `scoped.isEmpty` rule the panel
  and the wide rail use (15-03).
- B with **NUMBER = b2** and data **BUSY**: the band and the `No price` row on the same screen.
- The one thing this sketch cannot answer: inside the panel the track sits 6px nearer the card's
  rounded corner than it does on the canvas. At `radiusLg` 15 with a 44px chip it measured clean here,
  but corner clearance reads differently on glass. First thing to check on the device.

## Provenance

Row anatomy from the shipped tree: title is the coin symbol, token-first (010-A); the action leads the
subtitle and never shrinks (179-C); the amount is **neutral ink in both directions** (`_toneColor`,
`transaction_displays.dart:182-185` - sketch 186 scheme A, shipped) and the value line is never empty,
falling back to `No price` (`:366`). Empty-state strings are `emptyTransactionsTitle` /
`filteredEmptyTitle` / `filteredEmptyMessage` verbatim (`transactions_slim_view.dart:159-196`). Filter
set is `Filters.primary` = Sent, Received, Mint, Jobs, then a 1x20 divider and the overflow trigger
(`:112-118`), at `touchChipSize` 44 (`:836`). Count string shape from `assets_screen.dart:440-442`.
Colours from `gw_colors.dart` dark(); spacing from `genius_wallet_consts.dart`; row rhythm from
`gw_row_rhythm.dart`. Inter inlined from the shipping TTFs. `node --check` clean; div balance 0;
rendered in jsdom with **zero script errors** across all five tabs, every control exercised (43 clicks),
and the count string verified under all four filters in schemes A and C.
