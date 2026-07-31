# DECISION — Coin page (`/token-info`) · APPROVED

**Status:** ✅ **APPROVED by Jakub, 2026-07-30.** Ready to plan and execute.
**Design source:** `.planning/sketches/165-coin-page-schemes/index.html` → tab **★ Synthesis**
**Not yet executed.** No Dart has been written for this. Nothing in `lib/` has changed.

> **Why this file exists.** Jakub approved this while a second session (Braian) was mid-PR on
> the same repo. This file is deliberately self-contained and lives inside the sketch
> directory so it could be written without touching `STATE.md`, `ROADMAP.md` or `MANIFEST.md`
> — the three shared GSD files an execution session writes to. **Whoever picks this up should
> fold it into `ROADMAP.md` as a phase at that point, not before.**

---

## What was approved

The **Synthesis** board: Quiet's back-link, Retail's action CTAs, Trader's range placement,
on today's chart.

| # | Axis | Approved answer | Replaces |
|---|------|-----------------|----------|
| 1 | Back to Markets | 11px uppercase **kicker link** (`‹ MARKETS`), no chip, no border, no background. Hover lifts to `textPrimary`. | The breadcrumb chip in `_BackToMarkets` — the app uses breadcrumbs nowhere else |
| 2 | Subtitle | **Ticker only** (`BTC`). The `  ·  <chain>` segment is removed. | `BTC  ·  Ethereum` |
| 3 | Actions | **Filled gradient `Swap` + outline `Receive`**, 40px, on their own row under the identity block. Labels, not bare glyphs. | Two 32px `_ActionGlyph`s wedged onto the title line behind a hairline |
| 4 | Stat rail | **Five tiles** (Rank, 24h change, Volume 24h, Market cap, From ATH), all equal height. The `24h range` tile is gone. | Six tiles all stretched to 77px by the one carrying a range bar |
| 5 | 24h low/high | Moves to a **footer under the chart**: hairline, `24H LOW` / `24H HIGH` kickers, the 4px position track, then the two values. | The range bar inside a stat tile |
| 6 | Chart | **Unchanged.** Reproduced in the mockup only so the footer can be judged in place. | nothing |
| 7 | Convert | **Unchanged.** Stays the current calculator (Token price / Token amount / Total). | nothing |
| 8 | Info card | **No icons.** Label left, value right. The 22px glyph slot and its 12px gap are removed. | Six `SketchIcon`s all painted `brandPrimaryOnSurface` |

`Ethereum` still appears **once** — as the `Network` row inside Info. That is correct and
deliberate: the chain is a fact about the token, and Info is where facts live. What was
removed is the chain *impersonating part of the coin's name* directly under the title.

---

## Constraints that must survive execution

1. **One fill per surface (CTA weight rule).** The filled gradient `Swap` is the coin page's
   single filled control. It is legal **only because Convert stays a calculator with no button
   of its own.** If Convert is ever changed to a Buy panel with a gradient CTA, that is a
   second fill on the same surface and one of the two must give. Do not change Convert and the
   header CTA in the same phase without re-deciding this.

2. **The 48px tap target stays.** The action buttons keep a 48px hit area (WCAG 2.5.5). Moving
   them off the title line onto their own row means the `titleTrailing` overhang problem
   disappears on its own — see item 4 below.

3. **Two differently-scoped high/low readouts.** The chart already draws in-plot `H`/`L` plates
   at the extremes of the **selected timeframe** (`crypto_live_chart.dart:1042-1083`). The new
   footer is a fixed **24h** window (`low_24h` / `high_24h`). They agree on `1D` and diverge on
   `1W`/`1Y`.

   **RESOLVED 2026-07-30 by Jakub: the footer stays a fixed 24h window, labelled `24H LOW` /
   `24H HIGH` exactly as the mockup draws it.**

   Tracking the selected timeframe was investigated first and rejected on design grounds, not on
   cost. It is cheap: `visibleExtremes` (`chart_axis.dart:156`) is a pure function already called
   by `_SparklineChart` (`crypto_live_chart.dart:906`), and `_TradingFrameChart` holds `data`,
   `viewMinX` and `viewMaxX` as its own fields and already returns a `Column`, so a
   timeframe-scoped footer would have been one extra child and one call to a function that
   already ships. Zero new logic.

   It was rejected because the footer's only contribution over the chart is a *different window*.
   The in-plot `H`/`L` plates already state the selected timeframe's extremes. A footer scoped to
   the same window restates those two numbers in a larger font; a footer fixed at 24h is a second
   reference the plot does not carry. The divergence on `1W`/`1Y` is the feature, not a defect.

   Consequence for execution: the labels stay static (`24H LOW` / `24H HIGH`), and the footer
   reads `low_24h` / `high_24h` off the coin model - the same source `_RangeTile` uses today at
   `token_info_screen.dart:1257` - not off the chart series.

4. **The `titleTrailing` subtitle gap is superseded.** A separate fix was scoped on 2026-07-30
   for the 8px tap-target overhang inflating the title→subtitle gap to ~24px optically
   (`gw_page_header.dart:114`, pinned by `test/components/gw_page_header_subtitle_gap_test.dart:133`).
   **Do not execute that fix separately.** Moving the actions off the title line removes the
   overhang at its source, so `titleTrailing` becomes null on this call site and the gap falls
   back to the documented `space2`. The test's `space2 + overhang` assertion still holds for
   any other caller; it simply stops applying here.

---

## Files this will touch

| File | Change |
|------|--------|
| `lib/tokens/token_info_screen.dart` | `_BackToMarkets` → kicker link · subtitle drops the chain (`:329-332`) · actions move off `titleTrailing` into their own row (`:359-374`) · `_StatRail` drops `_RangeTile` (`:1272`) · `_RangeTile` becomes the chart footer · `CoinInfoCard` drops the glyph slot (`:904-929`) |
| `lib/components/scaffold/gw_page_header.dart` | `titleTrailing` becomes unused by this caller. **Do not delete the parameter** — check for other callers first. |
| `lib/chart/crypto_live_chart.dart` | additive only: the 24h low/high footer |
| `test/tokens/coin_page_range_tile_test.dart` | currently untracked; its claims move with the range widget |

Everything else on the page is unchanged: chart, Convert, price block, layout breakpoints.

---

## Rejected, and why (so it is not re-proposed)

- **Buy panel for Convert** (board 2 · Retail) — good idea, but it collides with the header CTA
  under the one-fill rule. Revisit as its own decision.
- **`Actions ▾` menu** (board 7 · Compact) — turns two one-tap operations into two-tap to save
  ~90px on a page that scrolls.
- **Gradient glyphs in Info** (board 8 · Gradient) — three gradient surfaces on one page is the
  repetition the CTA weight rule exists to prevent, and `brandCta`'s raw stops measure 1.65:1
  and 2.28:1 on a light canvas.
- **Deleting 24h low/high outright** (board 1 · Quiet) — Jakub kept it; it moves rather than dies.
