---
sketch: 165
name: coin-page-schemes
question: "How should the coin page read once the breadcrumb, the bare action glyphs, the range-bar tile tax and the calculator-shaped Convert are all reconsidered together?"
winner: null
tags: [coin-page, token-info, stat-tiles, convert, info-card, breadcrumb, actions, whole-scheme]
---

# Sketch 165: Coin page schemes

## Design Question

Six problems on `/token-info` were raised together on 2026-07-30, and they are not
independent — fixing each one locally is how the page got here. So this sketch draws
**ten whole schemes**, each a coherent answer to all six at once, plus a control board
showing exactly what ships today at the same scale.

The six axes:

| # | Problem | Where it lives today |
|---|---------|----------------------|
| 1 | Receive/Swap are two bare glyphs wedged onto the title line | `token_info_screen.dart:359-374`, `_ActionGlyph` `:1362` |
| 2 | Subtitle carries `BTC · Ethereum` — the chain segment goes | `token_info_screen.dart:329-332` |
| 3 | The 24h-range bar makes **all six** tiles 77px, so five carry dead space | `_StatRail` `:1299` `IntrinsicHeight`, `_RangeTile` `:1435-1470` |
| 4 | A breadcrumb chip — the app uses breadcrumbs nowhere else | `_BackToMarkets` `:1092-1160` |
| 5 | Convert is a calculator; a buyer thinks in dollars, not coin fractions | `CoinConvertCard` `:672-841` |
| 6 | Info glyphs read weak since they collapsed to one accent colour | `CoinInfoCard._glyph` `:883` |

## How to View

```
open .planning/sketches/165-coin-page-schemes/index.html
```

Toolbar bottom-right: theme (dark/light), viewport (375 / 768 / 1280 / full), and
**Measure** — overlays the callouts that name what changed and by how much.

## Boards

**Board 0 · Today (control)** — what ships now, same scale. Start here, then compare.

| # | Scheme | Thesis | back | actions | stats | convert | info |
|---|--------|--------|------|---------|-------|---------|------|
| 1 | **Quiet** | Subtract, don't add. Nothing new is introduced anywhere. | kicker link | labelled pills | 6 flat | calculator | no icons |
| 2 | **Retail** | Somebody landing here wants to own some. | arrow | gradient CTA + outline | 6 flat | **Buy panel, USD** | no icons |
| 3 | **Terminal** | Density as the feature. Nine visits a day, reads numbers. | kicker link | pills | 6 flat | one-line | two-up grid |
| 4 | **Hero band** | Identity band owns the actions as a full-width row. | arrow | Receive/Send/Swap bar | 5 + range strip | Buy panel | kicker stacks |
| 5 | **Trader** | It's a swap surface with a chart attached. | arrow | CTA | 5, range → chart footer | You pay / You get | no icons |
| 6 | **Editorial** | Type does the work. | kicker link | labelled tiles | 6 flat | calculator | kicker stacks |
| 7 | **Compact** | Every block one notch tighter. | inline arrow | one menu button | 3×2 | one-line | two-up grid |
| 8 | **Gradient** | Brand-forward — CTA gradient in three coordinated places. | arrow | CTA | 6 flat | Buy panel | gradient glyphs |
| 9 | **Panelled** | Info and Convert stop competing; they become tabs. | arrow | action bar | 5 + range strip | tabbed | tabbed |
| 10 | **Overlay** | A detail view over Markets — it closes, it doesn't go back. | × top-right | labelled tiles | 5, range → chart footer | Buy panel | kicker stacks |

## The four answers to the tile problem

This is the axis with the most at stake, so all four options are drawn:

- **6 flat** — the bar is deleted; the range is text (`$117.20K – $119.88K`). Six identical
  65px tiles. Loses the at-a-glance position of price within the day.
- **5 + range strip** — five short tiles, then the range as a full-width strip that *earns*
  its bar with low/high labels and the live price. Keeps the information, stops the tax.
- **range → chart footer** — the bar becomes the chart's own axis footer, directly under the
  series it describes. Five tiles above stay short.
- **3×2** — six uniform tiles in two rows of three, for narrow-first layouts.

## What to Look For

1. **Board 0 vs everything else** — turn on **Measure** on board 0: five tiles stretched to
   77px by one. Does removing that read as tidier, or as information lost?
2. **Does the range bar earn its space anywhere?** Compare board 1 (deleted) against boards 4
   and 9 (own strip) and 5 and 10 (chart footer).
3. **Do labelled actions beat glyphs?** Boards 1, 3, 6 use labels; 2, 5, 8 use a filled CTA;
   4 and 9 use a full-width bar. The glyphs on board 0 are the thing being replaced.
4. **Buy vs Convert.** Boards 2, 4, 8, 10 reframe it in dollars with preset amounts. Type in
   the field — it's live. Is that the right mental model, or does it over-promise a flow the
   app doesn't have yet?
5. **Back navigation.** Four answers: kicker link (1, 3, 6), 40px arrow (2, 4, 5, 8, 9),
   inline arrow (7), × close (10). Which one looks like it belongs to this app?
6. **Light mode.** Flip the theme. The gradient boards (8) are where this is most likely to
   break — `brandCta`'s raw stops measure 1.65:1 and 2.28:1 on a light canvas.

## ★ Synthesis board (Jakub, 2026-07-30)

The `★ Synthesis` tab — it opens first — composes:

| axis | taken from | what it is |
|------|-----------|------------|
| back to Markets | **1 · Quiet** | 11px uppercase kicker link, no chip, no border |
| Receive / Swap | **2 · Retail** | filled gradient `Swap` + outline `Receive`, 40px, under the identity |
| 24h low/high | **5 · Trader** | leaves the stat rail, becomes the chart's axis footer; rail drops to 5 tiles |
| subtitle | (all boards) | ticker only — the `·  Ethereum` segment is gone |
| Convert | 1 · Quiet | calculator, unchanged |
| Info | 1 · Quiet | no icons |

**The control board was wrong and is fixed.** Board 0 claimed "the chain still sits in the
subtitle" but rendered ticker-only like every other board, so axis 2 had no visible delta.
Board 0 now renders `BTC  ·  Ethereum`; every other board renders `BTC`. Turn on **Measure**
and the callout names which side of the change you are looking at.

`Ethereum` still appears once on the synthesis board — as the **Network** row inside Info.
That is deliberate: the chain is a fact about the token and Info is where facts live. What was
removed is the chain *impersonating part of the coin's name* directly under the title.

### The chart is reproduction, not proposal

Jakub, 2026-07-30: *"jeśli chodzi o price chart, to chcę, żeby został ten sam system, który
jest obecnie w aplikacji"* — so the chart card on every board is now drawn to the shipped
spec rather than to a generic mockup. The first pass got this wrong: it invented a
`24H/1W/1M/1Y/ALL` tab row and put the `Price` kicker inside the card. Corrected against the
live code:

| element | shipped spec | source |
|---------|--------------|--------|
| `Price` kicker | **above** the card, then `space4` | `token_info_screen.dart:233-237` |
| header row | price 17px bold tabular, signed % 12px bold in trend colour, hovered-sample time 11px | `crypto_live_chart.dart:591-640` |
| timeframe | `1H · 1D · 1W · 1M · 1Y`, **1D** default, recessed `surfaceSunken` track, selected chip = `brandCta` gradient, hover = lift chip | `gw_timeframe_segment.dart:47, 62-75, 144-166` |
| series | 2px line in trend colour, area `.18 → 0` fading at **62%** | `crypto_live_chart.dart:706-728`, `chart_axis.dart:38` |
| gridlines | horizontal only, `borderSubtle` at 6% | `crypto_live_chart.dart:732-745` |
| Y axis | right side, 62px gutter, 11px `textSecondary` | `crypto_live_chart.dart:762-784`, `chart_axis.dart:23` |
| H/L plates | pinned in-plot at the visible series' extremes | `crypto_live_chart.dart:1042-1083` |

**The 24h low/high footer is the only new element on this card.** Turn on **Measure** — its
callout says so.

One thing to decide during execution, not now: the in-plot H/L plates mark the extremes of
**whatever timeframe is selected**, while the new footer is a fixed **24h** window from
CoinGecko's `low_24h` / `high_24h`. On the 1D tab they agree. On 1W or 1Y they will not, and
two differently-scoped high/low readouts on one card can read as a bug. Options are to scope
the footer to the selected timeframe, or to label it explicitly (`24H LOW` / `24H HIGH`, which
is what the mockup does). Flagged here so it is a decision rather than a surprise.

**One composition risk, and it currently holds.** The CTA weight rule allows one fill per
surface. Retail's filled `Swap` is that fill, and it only stays legal because Quiet's Convert
is a calculator with no button of its own. **If Convert later becomes Retail's Buy panel, its
gradient `Buy` button is a second fill on the same surface and one of the two has to give.**
That is the open axis on this board — flagged now rather than discovered during execution.

## Recommendation

★ **Board 4 · Hero band**, with board 2's Buy panel grafted in (it already is — 4 uses it).

It is the only scheme that answers all six without trading one problem for another. The
action bar settles axis 1 properly: Receive/Send/Swap as a labelled row under the identity
stops them reading as labels *about the coin*, which is the actual complaint, and it does it
without a fill on the title line. The range strip is the honest answer to axis 3 — the bar
was never the problem, the bar sitting inside a tile that had to match five others was, so
giving it its own full-width strip keeps the information and hands 12px back to the other
five. And the 40px arrow for axis 4 is the treatment with the fewest new ideas: it is
`GWButton.icon` at a size the app already ships.

**Runner-up: board 5 · Trader.** Moving the range under the chart is arguably more correct
than a strip — it is an axis annotation and it finally sits next to the series it annotates.
The You pay / You get panel also reuses a mental model the Swap tab already teaches, which is
worth more than any new layout. It loses to 4 only because it puts a filled CTA on the header
line, and the CTA weight rule allows one fill per surface — spending it there means Convert's
own button cannot have it.

**Rejected: board 7 · Compact.** Collapsing both actions behind an `Actions ▾` menu is the one
move here that makes the page objectively worse: it takes two one-tap operations and makes
them two-tap, to save roughly 90px on a page that scrolls anyway. It is included because
"hide them" is a real option and deserved to be drawn, not because it should win.

Also worth stating: **board 8 · Gradient is the risk board.** Three gradient surfaces on one
page is exactly the repetition the CTA weight rule exists to prevent, and light mode is where
it will show first. Drawn so the decision is made by looking rather than by argument.

## Notes

- Every measurement in the mockup is lifted from the shipped Dart, not invented — the header
  comment in `index.html` lists each one with its source line.
- `MANIFEST.md` is deliberately **not** updated yet: a second session is running execution on
  this repo, and the manifest is the one shared file in `.planning/sketches/`. It gets its row
  when a winner is picked.
