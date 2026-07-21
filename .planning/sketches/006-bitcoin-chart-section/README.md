# Sketch 006 — Bitcoin Chart section

**Design question:** How should the dashboard's *Bitcoin Chart* card read — coin identity,
price hierarchy, chart treatment, and controls — using the reference mockup's chart language?

Open `index.html`. Toggle **variant** (A/B/C) and **theme** (dark/light).

## Reference used

The mockup's **token-detail** screen (`gnus-mockups.html` on `ui-redesign-3.514`): a centered
hero price with a **cyan radial glow**, a **mint `#2BF5B4` gradient area chart** (fill 30%→0,
2.4px stroke), a mint `%` pill, and a muted centered zoom/pan row. All three concepts pull from
that language; where they diverge from the mockup it is a deliberate, noted choice.

## Today's section (what we're replacing)

`ChartDashboardView` (`lib/dashboard/home/view/dashboard_screen.dart:368`):
`DashboardScrollContainer` → `Column(spaceBetween)` of `GWSectionTitle('Bitcoin Chart')` +
`Expanded(CryptoLiveChart(priceHeight: 28))`. Inside `CryptoLiveChart`
(`lib/chart/crypto_live_chart.dart`): a **centered** price `AutoSizeText`, a centered change row
(+$ and a `%`), the `fl_chart` `LineChart`, then zoom/pan buttons.

**Two problems this sketch fixes:**
1. **No coin identity** — the section is a bland text title "Bitcoin Chart"; no ₿ mark, no `BTC`
   ticker, nothing tying the title to the price below it.
2. **Split alignment** — the title is top-left while the price + change are centered, so the
   header reads as two unrelated blocks.

(The card is hardcoded to `bitcoin` today. The concepts show BTC but are drawn to work for any coin.)

## The three concepts

| | Concept | Idea | Behaviour change | Best when |
|---|---------|------|------------------|-----------|
| **A** | **Mockup hero** | Port the reference straight: identity top-left, **centered hero price + cyan glow**, mint % pill, edge-to-edge area chart, centered zoom/pan row. | **None** — keeps today's zoom/pan; pure re-skin | You want the closest match to the approved mockup and the fastest, lowest-risk GSD port |
| **B** | **Trading header** | One aligned baseline: identity left, **price + % pill right**. A **1H·1D·1W·1M·1Y timeframe row** replaces zoom/pan; chart fills the card. | **New** — timeframe ranges must be wired (or shown visual-only) | You want a real markets-card feel and the densest, most legible header |
| **C** | **Chart-hero** | Chart dominates; compact identity + price top-left, tiny timeframe top-right, and a **live last-point marker + value flag** on the latest price. | **New** — timeframes + a last-point marker overlay | You want the most modern, most glanceable "where are we now" read |

## The behaviour flag that matters for GSD

**A is a pure re-skin.** **B and C introduce timeframe selectors** (and C adds a last-point
marker). The reference mockup itself uses **zoom/pan, not timeframes** — so B/C go *beyond* the
mockup. Wiring real 1H/1D/1W/1M/1Y ranges is a data change in `CryptoLiveChart` (it currently pulls
one series and offers zoom/pan), not a re-skin. A GSD task picking B or C must decide: wire real
ranges, or ship the tabs as visual-only first and defer the data wiring. Per the port's scope rule
(**re-skin, never restructure**), A is the in-scope option; B/C are enhancements that need an
explicit behaviour decision.

## Token discipline

Uses the shipped tokens via `../themes/default.css` (mint `brand-secondary #2BF5B4`, the
`radius-lg` card, `space3`=6 gaps, status-success for the up-tint). The chart fill/stroke mirror the
mockup's mint gradient. As with 005: the sketch theme darkens up/down colors in light mode for AA —
a Flutter port must keep AA-safe pairings, not raw brand on light fills.

## Chosen direction: the A family (+ hover crosshair)

Picked 2026-07-21. Base **A is a pure re-skin**. Two extensions were added because the timeframe
selector from C was wanted without leaving A's cleaner hero — **compare A vs A→ vs A↓ in the sketch**:

| Variant | Timeframe placement | Change value | Bottom row |
|---------|--------------------|--------------|------------|
| **A** | none (zoom/pan kept) | `+$1,025.60` + `+1.59%` | zoom/pan |
| **A→** | **segment top-right**, opposite the coin identity; hero stays centered | **% pill only** (USD dropped) | none |
| **A↓** | **vertical rail on the chart's right edge** ("z boku"); hero untouched | **% pill only** (USD dropped) | none |

Two deliberate calls baked into A→/A↓, both per the user (2026-07-21):
- **Drop the USD absolute delta** — the `%` pill alone carries the change. Cleaner hero, matches the
  mockup's pill emphasis.
- **Add a timeframe selector.** This is the one **new behaviour** in the A family (base A has none).
  See the behaviour flag below — 1H/1D/1W/1M/1Y ranges must be wired, or shipped visual-only first.

A→ is the recommendation if the header should stay symmetric (identity ← → timeframes, price
centered); A↓ if the timeframes should read as chart chrome and leave the hero completely alone.

**A is a pure re-skin** — the in-scope option per the port rule.

### Hover interaction (designed in-sketch — the mockup can't settle it)

The reference mockup defines **zero `:hover` rules** (it's a static mobile mockup), so the desktop
hover was designed here on our tokens. On the shipped concept A, **hovering the chart shows a
crosshair that snaps to the line plus a tooltip carrying that point's date + price + % change**:

- **Crosshair**: 1px vertical line at the cursor, `border-strong`.
- **Point dot**: mint (`brand-secondary`) dot on the actual curve with a soft glow ring.
- **Tooltip**: elevated-surface bubble, hairline border, `shadow-card`; two lines — muted date/time
  (`text-secondary`) and the price (`text-primary` bold) with a green/red % beside it. Flips below
  the point near the top edge and clamps horizontally so it never clips the card.

**For the GSD task:** this is *styling an interaction fl_chart already supports*, not new data.
`CryptoLiveChart` uses `fl_chart`'s `LineChart`, whose `LineTouchData.touchTooltipData` +
`getTooltipItems` provide the hover/touch hook and a built-in indicator line. The work is to style
that tooltip (`LineTooltipItem`) to match the bubble above and enable the touch indicator as the
crosshair — no change to the data series. Both light and dark must read AA.

## Not decided here

Pick a direction (or a hybrid — e.g. **A's** centered hero glow with **C's** last-point marker).
Implementation is a **separate GSD task**.
