---
sketch: 078
name: chart-restyle
question: "The price chart 'looks really clunky'. What is actually wrong with it in code, and which of four whole positions - sparkline, trading frame, baseline band, or price rail - should the app take?"
winner: "B · Trading frame (chosen 2026-07-29 by Jakub). Line takes the TREND colour - green up, red down - after an intra-session reversal of an 'always green' call, so one rule covers the hero chart and the Markets sparklines alike. Rollout rule: B wherever the plot clears 220px, A below it, DECIDED AT RUNTIME from the box the chart is handed - because the dashboard chart has three call sites under three height regimes and one of them has no minimum at all. Coin wide/stacked are free. The Markets hero is NOT: the "73px of Spacer slack" was my arithmetic and a measurement falsified it (card 619 -> 692, it grew by the full 73), so the hero chart STAYS AT 180 and takes only the trend colour and the contrast fix. Coin mobile stays on A permanently; the dashboard's 2-column layout is a filed, unfixed RenderFlex overflow and should get its floor height before anyone trims its padding."
tags: [chart, fl-chart, coin-detail, dashboard, markets, timeframe-segment, contrast, wcag-1-4-1, wcag-1-4-11, dark-mode, interactive, follows-070, follows-071]
lane: execution
---

# Sketch 078: The price chart, restyled

Jakub, 2026-07-29: the price charts *"look really clunky"*.

```
open .planning/sketches/078-chart-restyle/index.html
```

Four schemes x five data states x seven surface sizes x two themes, plus a fifth "X - shipped today"
scheme that reproduces the current build so the comparison is direct rather than remembered.
Everything renders at 1:1 - the card is drawn at its real pixel width and height, and the
`Measurements` toggle prints those numbers on the frame.

---

## 1. What is actually in the code

Read from `lib/`, not from a planning doc. Every claim below has a file:line.

### The library

**`fl_chart` `^1.2.0`** (`pubspec.yaml:36`), resolved to exactly **1.2.0**
(`pubspec.lock:428-434`, sha `b938f77d…`). It is the only charting dependency and no scheme here
needs another one. Capabilities were read off the installed package at
`~/.pub-cache/hosted/pub.dev/fl_chart-1.2.0/`, not recalled - the full table is in the sketch page
under "What fl_chart 1.2.0 can actually do". The short version: horizontal-only gridlines with a
custom stroke, right-hand axis titles with arbitrary widgets, a full-height crosshair
(`getTouchLineStart` / `getTouchLineEnd`), suppressible tooltips (`GetLineTooltipItems` returns
`List<LineTooltipItem?>` - nulls draw nothing), dashed reference lines with their own labels
(`extraLinesData` -> `HorizontalLine.label`), and a two-tone fill split at a baseline
(`BarAreaData.cutOffY` + `applyCutOffY`). All four schemes are buildable on what is already
installed.

### Every chart surface in the app

| # | Surface | Where | Shape |
|---|---|---|---|
| 1 | Coin page price chart | `lib/tokens/token_info_screen.dart:416-423` -> `lib/chart/crypto_live_chart.dart:451-577` | `CryptoLiveChart` with `showPriceHeader: false`; live series, zoom/pan, tooltip |
| 2 | Dashboard "Bitcoin Chart" card | `lib/dashboard/home/view/dashboard_screen.dart:555-561` | the SAME `CryptoLiveChart`, hardcoded to `bitcoin`/`btc`, `priceHeight: 28`, header shown |
| 3 | Markets hero card backdrop | `lib/dashboard/chart/markets_hero_card.dart:293-427` (`_HeroChart`) | its own 7d area chart on the brand gradient, touch tooltip, no axes |
| 4 | Markets table 7d column | `lib/dashboard/chart/markets_table.dart:333-341` | 72x32 inline `LineChart`, `barWidth` 1.6, no touch |
| 5 | Dashboard markets list rows | `lib/chart/crypto_simple_chart.dart:110-143` (`CryptoSparkLineChart`), used at `lib/dashboard/chart/dashboard_markets.dart:78` | 72x32, deliberately identical geometry to #4 (`crypto_simple_chart.dart:106-109`) |

So: **two full charts (1 and 2 are the same widget), one hero, two sparklines.** Nothing else in
`lib/` constructs a `LineChart`.

### The line-colour logic, exactly as it stands

**`lib/chart/crypto_live_chart.dart:316-320`:**

```dart
final bool isUptrend = _latestPrice >= _oldestPrice;
// Trend tints the % pill only; the chart itself is always mint
// (see `mintColor` below), decoupled from up/down.
final Color trendColor = isUptrend ? gw.statusSuccess : gw.statusError;
const Color mintColor = GeniusWalletColors.brandSecondary;
```

`brandSecondary` is `#2BF5B4` (`lib/theme/genius_wallet_colors.dart:76`). `mintColor` is what the
line (`:464`), the below-bar gradient (`:470`) and the touched-spot dot (`:512-515`) all use.
`trendColor` reaches only the `%` pill at `:430,440`. **This is not a bug that slipped in - the
comment states the intent.** It is nonetheless why a coin at `-1.70%` draws a green line.

The two sparklines already do it right: `crypto_simple_chart.dart:53-55` and
`markets_table.dart` both pick `statusSuccess` / `statusError` off the sign. So the full chart is the
odd one out, not the convention.

The Markets hero is a third rule again - `markets_hero_card.dart:322-325` paints the line on a fixed
`gradientGreen -> gradientBlue` gradient regardless of direction. Three surfaces, three answers.

### The other four defects, confirmed

- **No reference frame.** `gridData: FlGridData(show: false)` (`:480`), `borderData:
  FlBorderData(show: false)` (`:481`), and all four `AxisTitles` at `showTitles: false` (`:482-495`).
  Nothing on the card carries a number except the tooltip.
- **Zoom/pan instead of timeframes.** Four default `IconButton`s at `:579-617`, each 48x48, each
  `color: Colors.white` hardcoded. Three separate open todos land on these same four buttons:
  the 34px `RenderFlex` overflow, the raw whites, and "is zoom/pan redundant once ranges are wired".
- **The tooltip is a floating box over the data.** `:521-574`. It works, but it sits under the
  cursor at the exact point you are trying to read, and fl_chart cannot give it a shadow
  (the `ponytail:` note at `:530-535` says so).
- **The empty state never resolves.** `_fetchHistoricalData` only calls `setState` when the response
  is non-empty (`:159`), and the `else` branch of `_hasData` renders a `PulsingSkeleton` (`:621-624`).
  An empty or failed fetch pulses forever, with no error and no retry. The "No data" state in the
  sketch proposes the honest version.

### One new finding of my own

**The touched-spot indicator line is under the WCAG 1.4.11 threshold.**
`crypto_live_chart.dart:504` uses `FlLine(color: gw.borderStrong, strokeWidth: 1)`. `borderStrong`
is white 24% (`genius_wallet_colors.dart:174-176`), which composites to **2.10:1** on
`surfaceElevated` `#0C0E14` and **1.70:1** on a white card. That line is what tells you *which* point
you are reading, so it is "a part of a graphic required to understand the content" and wants 3:1.
The palette already has the right token: `borderControl` (white 36% dark / ink 46% light,
`genius_wallet_colors.dart:179-203`) measures **3.30:1** and **3.10:1**. The existing doc comment on
`borderControl` derives 36% as "the first step that clears 3:1" for exactly this reason.

### What sketches 070/071 fixed, re-checked

`chartYBounds` at `crypto_live_chart.dart:66-97` still reduces over the **visible** slice
(`:78-86`) and pads 8% each side (`:96`), and it is still wired to the view window at `:458-459`.
`test/chart/chart_y_bounds_test.dart` has five tests including the GNUS `-98.53%` case.
**Intact - nothing in this sketch changes it,** and the sketch's own JS ports the same rule verbatim
so the proposals are drawn on the shipped scale rather than a flattering one.

Worth noting for whoever picks this up: the two sparkline surfaces (#4, #5) and the hero (#3) set no
`minY`/`maxY` at all. That is correct there, because the whole series *is* the view.

---

## 2. The measured geometry

Derived, not inherited. Re-check these if the page layout moves.

| Surface | Card | Where the number comes from |
|---|---|---|
| Coin page, wide (>=1024) | **997 x ?** | `1536` (`GeniusBreakpoints.xxl`) - `24` gutter (`token_info_screen.dart:240`) - `16` row spacing (`:262`) = `1496`, split `flex: 2` : `flex: 1` (`:264-266`) -> `997.33`. **The height is NOT statically derivable** - the wide branch wraps the chart in `IntrinsicHeight` (`:260`) so the Info+Convert column sets it. The sketch uses 530 as a placeholder and says so. |
| Coin page, stacked (768-1023) | **876 x 558** | `coinChartHeight(viewportHeight: 900, isDesktop: true)` = `max(300, 900 - 342)` = `558` (`:76-81`, `_kChromeAboveChart` at `:59`). Width `900 - 24`. |
| Coin page, mobile (<=768) | **366 x 260** | `coinChartHeight(..., isDesktop: false)` = fixed `260` (`:81`). Width `390 - 24`. |
| Dashboard card | **597 x 220** | `597` is a **real measured** constraint from the live `RenderFlex` dump in `.planning/todos/pending/2026-07-21-chart-zoom-pan-row-overflows-34px.md` (`BoxConstraints(0.0<=w<=597.0, h=6.5)`). `220` is a plausible slot, not a measurement. |

Card chrome is real: `GWCard(radius: radiusMd = 12, padding: EdgeInsets.all(space8 = 16))`
(`token_info_screen.dart:386-388`), on `surfaceElevated` with a `borderSubtle` hairline.

**Vertical chrome, compared.** Today the card spends **48px** below the plot on the zoom/pan row
(Flutter's default `IconButton` is 48x48 - that arithmetic is the whole of the 34px overflow). All
four proposals spend **44px** above it instead (32px header + 12px gap). **The restyle costs 4px
less vertical chrome than what ships.**

**Caution:** another session is editing `lib/tokens/token_info_screen.dart` right now (the page
header's trailing block, moving the title line from 62px to 48px). `_kChromeAboveChart = 342` is a
measured constant that includes that header, so it may be ~14px stale by the time this is built.
Re-measure it; do not trust the 558.

---

## 3. The timeframe segment - the contested bit, settled on evidence

Two copies exist and they disagree on **both** axes:

| | Labels | Track |
|---|---|---|
| `dashboard_screen.dart:678, 697-706` | `1H · 1D · 1W · 1M · 1Y` | `surfaceSunken` + `borderSubtle` |
| `markets_hero_card.dart:449, 462-470` | `24H · 7D · 30D · 1Y` | `surfaceMenu` + `borderSubtle` |

**The track is already settled by the repo's own convention** - `dashboard_screen.dart:697-700`
quotes `CONVENTIONS.md` ("Control track"): recessed well = `surfaceSunken`, raised chip =
`surfaceMenu`. A segmented control is a track. **The dashboard is right; the markets copy drifted.**

**The labels are settled by the only documented external reference I could find.** Robinhood
publishes its set: `1H / 1D / 1W / 1M / 3M / 1Y / 5Y`
(<https://www.robinhood.com/eu/en/support/articles/using-charts>) - the "1X" grammar, not
"24H/7D/30D". **So the dashboard's array wins there too**, and the markets card is the one that
changes. The sketch uses `1H · 1D · 1W · 1M · 1Y` throughout.

That resolves `.planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md` with a
decision rather than a coin flip: extract `GWTimeframeSegment` with the dashboard's labels and the
dashboard's track, and delete both private copies. Both are still visual-only
(`2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md`); this sketch does not change that,
but it does answer that todo's open step 3 - **once ranges are wired, zoom/pan goes**, because every
scheme here replaces it.

---

## 4. The four schemes

All four fix the three things that are simply wrong (line colour, zoom/pan, tooltip placement).
They differ on **how much reference frame the chart owes the reader.**

### A · Honest sparkline - no axes

Keeps the axis-free plot and fixes only the lies. Trend-coloured line, timeframe segment where the
zoom buttons were, header readout instead of a floating bubble, and the high and low labelled
directly on their own points.

- **Fixes** the colour, the controls and the tooltip. Fits every surface including the 220px
  dashboard card.
- **Costs** everything else: you still cannot read an arbitrary point without hovering, and there is
  no time reference until you do.
- **Suits** the dashboard card, the Markets hero, and the coin page at mobile 260px.

### B · Trading frame - axes and grid

A real reference frame. Right-aligned Y axis with nice-rounded ticks (4-6 at these heights),
horizontal-only gridlines at white 6%, time labels along the bottom, trend-coloured line, area fill
that fades out before the baseline, full-height crosshair with the value read out in the card header.

- **Fixes** all four things Jakub named. You can read a price off the card without touching it.
- **Costs** a 62px right gutter and a 22px bottom gutter, and needs a documented reduction to A below
  about 220px of plot height.
- **Suits** the coin page at 997 and 876. The Markets hero if it is ever given real height.

*Honesty note on the right-hand axis:* the rationale is good - on a time series the newest value sits
at the right edge and would otherwise be furthest from its scale
(<https://data.europa.eu/apps/data-visualisation-guide/axes-grids-and-legends>) - but it is **not** a
documented standard. Highcharts still defaults `yAxis.opposite` to `null` and its docs say "the
normal is on the left side for vertical axes"
(<https://api.highcharts.com/highstock/yAxis.opposite>). Strong de-facto convention, not a rule.

### C · Baseline band - shape, not hue

One reference: the window's opening price, drawn as a dashed baseline. The area fills green above it
and red below it, so **direction is carried by which side of a line the shape sits on**, not only by
hue. Two floated price labels in the right corners, two time labels at the ends.

- **Fixes** the colour problem in the strongest available way, and does it for free: `_oldestPrice`
  (`crypto_live_chart.dart:128, 221-224`) is already the number the percentage is computed against.
- **Costs** the full scale - two anchored prices, not five - and a series that crosses the open
  repeatedly turns into stripes.
- **Suits** the coin page, and it is the strongest candidate for the Markets hero, which is
  decorative anyway.

### D · Last-price rail - the TradingView idiom

No gridlines. A 64px rail down the right edge carries the tick labels, and the current price rides it
as a filled chip with a dashed extension line across the plot.

- **Fixes** the "what is it right now" question emphatically, and feels live, which suits a chart
  that ticks every 60s (`crypto_live_chart.dart:183`).
- **Costs** 64px of a 965px plot, and puts the price in a **third** place: the page header
  (`_PriceBlock`), the card header, and now the rail.
- **Suits** the coin page on desktop only. Actively bad below 600px.

---

## 5. Contrast, measured, both themes

WCAG 2.x relative luminance, alpha composited over the card it sits on. Dark card `#0C0E14`, light
card `#FFFFFF`.

| Element | Dark value | on `#0C0E14` | Light value | on `#FFFFFF` | Gate |
|---|---|---|---|---|---|
| Line, up | `statusSuccess #0AD89C` | **10.39:1** ✓ | `statusSuccess #07875F` | **4.53:1** ✓ | 1.4.11, 3:1 |
| Line, down | `statusError #FF4D4D` | **5.90:1** ✓ | `statusError #D92D2D` | **4.81:1** ✓ | 1.4.11, 3:1 |
| Line, shipped today | `brandSecondary #2BF5B4` | 13.62:1 | `brandSecondary #2BF5B4` | **1.86:1** ✗ | passes dark, fails light, means nothing in either |
| Axis label | `textSecondary #8A8F9D` | **5.97:1** ✓ | `textSecondary #5A606E` | **6.30:1** ✓ | 1.4.3, 4.5:1 |
| Header readout price | `textPrimary #FFFFFF` | 19.29:1 ✓ | ink `#10131A` | 18.58:1 ✓ | 1.4.3, 4.5:1 |
| Crosshair, **proposed** | `borderControl` white 36% | **3.30:1** ✓ | `borderControl` ink 46% | **3.10:1** ✓ | 1.4.11, 3:1 |
| Crosshair, today | `borderStrong` white 24% | **2.10:1** ✗ | `borderStrong` ink 24% | **1.70:1** ✗ | 1.4.11, 3:1 |
| Gridline | white 6% | 1.14:1 | ink 8% | 1.18:1 | decorative, not gated |
| Area fill peak | success 18% over card | 1.39:1 | success 18% over white | 1.27:1 | decorative, not gated |
| Last-price chip text (D) | `#04121A` on `#0AD89C` | **10.23:1** ✓ | `#FFFFFF` on `#07875F` | **4.53:1** ✓ | 1.4.3, 4.5:1 |

Three things worth stating plainly:

1. **`#0AD89C` is 1.86:1 on white** - it cannot be the light-mode line. `#07875F` is, at 4.53:1.
2. **Gridlines are genuinely exempt.** SC 1.4.11's Understanding document works a line chart
   explicitly: *"The lines should have 3:1 contrast against their background, but as there is little
   overlap with other lines they do not need to contrast with each other or the graduated lines."*
   (<https://www.w3.org/WAI/WCAG22/Understanding/non-text-contrast.html>). So 6% is a legitimate
   choice, not a shortcut - and no design system publishes a numeric dark-mode gridline opacity, so
   there is nothing to copy anyway.
3. **Hue alone must not carry direction** (SC 1.4.1,
   <https://www.w3.org/WAI/WCAG22/Understanding/use-of-color.html>). Roughly 8% of men are
   colour-blind, ~98% of those red-green
   (<https://www.colourblindawareness.org/colour-blindness/>). The **signed percentage in the card
   header** is the compliance path for A, B and D. **C is the only scheme that carries direction
   redundantly in the graphic itself.**

**Not adopted, deliberately:** the Wong CVD-safe palette (blue `#0072B2` / orange `#E69F00` etc.,
<https://www.nceas.ucsb.edu/sites/default/files/2022-06/Colorblind%20Safe%20Color%20Schemes.pdf>).
Using it would mean new tokens and a break with the `%` pill, the transaction badges and the Assets
rows, all of which already run on `statusSuccess`/`statusError`. C solves the same problem with shape
and zero new tokens.

**Also recorded, not acted on:** in China, Japan, Korea and Taiwan the convention inverts - red is
up, green is down. Only relevant if the wallet localises for those markets, but it should be a
decision rather than an omission.

---

## 6. The fill, and the one thing I nearly got wrong

A filled area reads as sitting on ground level, so **any base-aligned chart with a solid fill should
start at zero** (<https://flowingdata.com/2024/03/06/line-chart-baselines/>). This chart's Y domain is
emphatically *not* zero-based - `chartYBounds` fits it to the visible slice with 8% headroom, which
is the correct behaviour for a price chart and was the whole point of the 070/071 fix.

Today's fill runs edge to edge at 30% alpha (`crypto_live_chart.dart:466-476`). On a non-zero axis
that is the documented misleading case. **In every scheme here the fill ramps to zero alpha at 62% of
the plot height**, so it stays decoration that cannot be measured. Switch to scheme X in the sketch
to see the difference at 1:1.

Scheme C is the exception and does not need the ramp: its fill is bounded by the **open price line**,
which is a real reference the reader can see, not an invented floor.

---

## 7. Recommendation

### ★ Favourite: **B · Trading frame**

Because it is the only one of the four that answers the actual complaint. "Clunky" is four separate
problems, and three of them (green line on a red day, magnifier buttons, a bubble parked over the
data) are fixed by all four schemes. The fourth - *you cannot read a value off it* - is fixed only by
B. A 997x530 card is an enormous amount of screen to spend on a graphic with no numbers on it, and at
that size the 62px gutter is 6% of the width. Every capability it needs is in fl_chart 1.2.0 today,
and it costs 4px **less** vertical chrome than the zoom/pan row it replaces.

**A is not a competitor, it is B's documented reduction.** Below roughly 220px of plot height the
ticks crowd and the frame stops earning its gutters - so the dashboard card, the Markets hero and
mobile 260 all get A, from the same widget, on a height threshold. That is one component with two
modes, not two components.

### Runner-up: **C · Baseline band**

The best *idea* here and the weaker *answer*. It is the only scheme that makes direction survive a
monochrome or colour-blind read without leaning on the `+`/`-` in the header, and its reference line
costs literally nothing because `_oldestPrice` is already computed. It loses to B only because two
anchored prices is not a scale, and the coin page has the room for a real one. **Worth building
anyway on the Markets hero card**, which is a decorative backdrop where a full axis would be
overbearing and where the current fixed green-to-blue gradient is the least honest chart in the app.

### Rejected: **D · Last-price rail**

It looks the most like a trading product and it is the wrong shape for this app. It spends 64px on a
rail whose labels float free of any gridline, and the last-price chip makes the current price appear
in **three** places on one screen - `_PriceBlock` in the page header, the card header readout, and the
chip. On the coin page the price is already the largest thing above the chart. It also degrades worst:
64px of a 334px mobile plot is a fifth of the chart given to a number that is printed twice above it.
B gets the same scale for the same gutter and puts gridlines under it.

### Not a scheme, but do it anyway

Whichever wins, three fixes are unconditional and cheap:

1. `crypto_live_chart.dart:320` - the line takes `trendColor`, not `mintColor`. One line.
2. `crypto_live_chart.dart:504` - the touched-spot indicator moves from `borderStrong` (2.10:1) to
   `borderControl` (3.30:1). One token.
3. `crypto_live_chart.dart:621-624` - distinguish "loading" from "the fetch returned nothing".
   `_fetchHistoricalData` never sets state on an empty response, so today the card pulses forever.

---

## Verification of this sketch

- `node --check` on the extracted script: **passes**.
- Driven in a real browser across **400 combinations** (5 schemes x 5 data states x 4 sizes x 2
  themes x measurements on/off): **zero JS errors, zero card overflows, zero clipped labels, zero
  header collisions**, Y-label count inside the 2-to-8 band the EU guide asks for, hover and the
  timeframe tabs both functional.
- That sweep found four real defects **in this sketch** that looking at it would not have:
  a 1-2-5-10 tick ladder that collapsed a 6-tick request to 2 labels; an axis formatter that printed
  a stablecoin as `$1.00 / $1.00 / $1.00 / $1.00`; duplicate time labels in the 4-point state; and
  the scheme-C "OPEN" label clipping off the top of the 366px card on every down trend. All fixed,
  each with the reason written at the site.
- Every contrast figure in this file was computed, not recalled.

---

## DECIDED and OPEN - 2026-07-29

### Decided

**Scheme B · Trading frame.** Chosen by Jakub.

**The line takes the trend colour - green rising, red falling.** This reverses an "always green" call
taken earlier the same session. The reversal is the interesting part, so it is recorded rather than
overwritten: always-green was proposed on the grounds that the % pill already states direction, so
the line was free to carry brand identity. It was reversed once the consequence was put on screen -
the Markets sparklines colour by sign **on purpose**, to mirror the Assets panel
(`crypto_simple_chart.dart:53-55`, comment: *"Assets-mirror up/down: status green/red"*). An
always-green hero chart would have sat directly above red sparklines reporting the same fact. One
rule now covers every surface.

### Resolved 2026-07-29 - and the shape of the fix changed on the way

The open question was whether B fits the surfaces it has to live on. Checking it turned up something
that matters more than the answer: **the dashboard chart does not have *a* height.**
`ChartDashboardView` has three call sites under three different height regimes
(`dashboard_screen.dart:223`, `:273`, `:303`), and only one of them is the 350 cap the earlier
analysis used. "Does B fit the dashboard" therefore has no single answer, and no per-surface setting
can give it one.

The floor is **220px of plot**: B spends 22px on the time-label row, and below roughly 198px of
remaining graph the tick ladder collapses to 3 labels across an 8%-padded window, at which point the
axis stops being a reference frame.

| Surface | Plot | Verdict | What has to happen |
|---|---|---|---|
| Coin page, wide 997x530 | 454 | B, free | nothing |
| Coin page, stacked 876x558 | 482 | B, free | nothing |
| Markets hero, wide | **180, unchanged** | B | ~~spend 73px of `Spacer` slack~~ **FALSIFIED - measured, the card grows by the full 73px. Chart stays at 180.** |
| Coin page, mobile 366x260 | 184 | **A, permanently** | nothing, and nothing possible |
| Dashboard, 3-column >1536 | **232+** | B, free | nothing - `minHeight: 380` already covers it |
| Dashboard, 1-column | 202 | B after 32px | release 32 of the 48px override |
| Dashboard, 2-column | **140** | **broken already** | fix the filed bug first, see below |

**The Markets hero is NOT free. My arithmetic was wrong, and a measurement caught it.**

~~Left column = 301, right column fixed = 228, so the `Spacer` at `markets_hero_card.dart:168` holds
73px of slack and the chart can grow 180 -> 253 for nothing.~~ **Falsified 2026-07-29** by
`test/dashboard/markets_hero_height_test.dart`, which pins the card height at a real pumped width of
1200 (so the wide `IntrinsicHeight` branch, not the stacked one):

| Chart height | Measured card height |
|---|---|
| 180 (shipped) | **619.0** |
| 253 (proposed) | **692.0** |

It grew by **exactly 73px** - the entire amount the `Spacer` was supposed to absorb. Growing by
exactly the chart's delta means the RIGHT column is what drives the `IntrinsicHeight`, so there was
never any slack to spend.

Both of my column figures were wrong: the row measures 585 (619 minus 32 padding and 2 border), not
the 301 I derived. **I do not yet know where the other 284px comes from**, and I am not going to
invent a mechanism for it - `IntrinsicHeight` asks children for `getMaxIntrinsicHeight`, which is not
the same question as "how tall did you lay out", and that gap is the likeliest place to look. What is
settled is the decision, not the explanation: **the hero chart stays at 180.**

The trend colour and the `borderControl` contrast fix shipped on the hero anyway - neither depended
on the height claim.

The lesson is the one this session keeps re-learning: a derived number is a hypothesis. The plan was
written to measure before trusting it, and that is the only reason this did not ship as a silently
taller card.

**The dashboard's 2-column layout is already broken, and it is already filed - twice.** The chart is
`(viewport - 324) / 2` with no floor at all, so at a 900px-tall window the plot is 140 and 32px of
reclaim only lifts it to 172. In the wild it goes much further: the filed traces have the chart's
Column handed **h=6.5** and throwing *"RenderFlex overflowed by 33 pixels"* at every boot
(`todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`,
`2026-07-24-dashboard-bitcoin-chart-renderflex-overflow.md`). Both todos reach the same conclusion:
**the slot is broken, not the chart**, and the fix is a floor height on the dashboard side.

**Mobile is out and should be.** `coinChartHeight` returns a hard 260 below 768 on purpose - *"the
chart is a station on the way down, not the page"* (`token_info_screen.dart:72-80`) - and on a 366px
card B's 62px gutter is 17% of the width.

### Recommendation

**★ Ship the free surfaces, make the rest automatic, leave the dashboard's padding alone for now.**

1. **B on the coin page (wide and stacked) and the Markets hero.** All three are free, none is
   blocked, and they are where somebody actually goes to read a chart.
2. **Make A-versus-B a runtime rule, not a per-surface setting.** The chart reads the box it was
   handed and picks B above 220px of plot, A below. Not invented here - it is already B's own
   documented reduction (*"below about 220px of plot height the ticks crowd - needs a documented
   reduction to A"*). It makes the dashboard correct at every window size without anyone choosing a
   number, and it is the only form of the fix that survives a layout with no minimum height.
3. **Do not trim the dashboard's 48px yet.** Polishing padding on a card that files RenderFlex
   overflows at boot is fixing the wrong layer. Once that card gets the floor height both todos ask
   for, rule 2 gives it B for free, and the 32px drops from "a decision" to "moves the window height
   at which B kicks in from 1060 to 996".

**Runner-up: a cut-down B** - drop the time-label row, narrow the gutter to 46, floor ticks at 3 - so
every surface keeps the frame. Rejected because it produces a second chart language that *looks* like
B but cannot be read like B, and it would ship exactly on the surfaces where a misread costs most.

**Rejected: B on the coin page only**, leaving the dashboard and hero on today's always-mint chart.
That keeps three chart languages in one product and leaves the failing `borderStrong` touched-spot
indicator (2.10:1 against a 3:1 gate) in place.

### One defect fixed on Jakub's read, 2026-07-29 - in two passes, because the first was wrong

He walked the before/after pairs and flagged the same thing on pair 3 (coin mobile) and pair 4
(dashboard 2-column): *"te oznaczenia HIGH/LOW overlapują z wykresem"*. Correct, and it was a known
defect rather than a surprise - scheme A's own cost list said *"high/low labels collide on a
whipsawing series at small widths"* and nobody had acted on it.

**First attempt, insufficient:** put every label on an opaque plate. That fixed legibility - bare 10px
text over a line and a gradient fill has no defined background, so its contrast ratio cannot even be
computed - but it did not fix the overlap. The line still ran straight through the plate; the plate
just hid that stretch of the series. Jakub pushed back and was right: **hiding a chunk of the data
behind a caption is not a fix, it is erasing data to make room for text.** Measured afterwards rather
than argued: the series entered *both* plates on the mobile, dashboard and hero surfaces in almost
every data state.

**The actual fix: the labels get their own gutters, the way B's axis already has one.** 17px is
reserved at the top of the plot and 17px at the bottom; the line is drawn only between them. H is
pinned to the top strip, L to the bottom strip, each still tracking its own point's x so you can see
which sample it refers to. No data shape can reach a label, because the label rows are not part of
the line's box.

- **Cost:** 34px of line travel. On a 140px dashboard plot that is real, but it buys two anchored
  numbers and it costs **no card height**, which is exactly what these surfaces do not have.
- **Verified, not eyeballed:** the line path is sampled against both label rects across every
  surface x data state x theme. **0 intersections**, down from an intersection in nearly every
  small-surface combination.
- The plates stay: the area fill still runs under the bottom band.

In Flutter this is an overlay computed from the same series plus a reduced `minY`/`maxY` range, not
an `fl_chart` feature - `HorizontalLineLabel` takes a text style but no background, and nothing in
the library reserves a label gutter for you.

### What this does not break

Checked rather than assumed, at `8ed02e78`:

- **`MarketsHeroCard` has exactly one consumer** (`markets_screen.dart:197`), in a
  `SingleChildScrollView` with no `maxHeight`. Growing the chart cannot squeeze a sibling.
- **`_ChartSectionHeader` has exactly one consumer** (`dashboard_screen.dart:555`). Its padding is
  not shared with `GWSectionTitle`; restoring `space8` moves this panel *towards* the shared rhythm,
  not away from it.
- **No test asserts either number.** `test/chart/compact_price_font_size_test.dart` pins the price
  block's font search against `priceHeight: 28`, which nothing here changes;
  `test/tokens/coin_page_stat_rail_test.dart` does not touch chart height.
- **`test/freeze_rule_test.dart`'s `AutoSizeText`/`FittedBox` ban** covers `lib/components/cards/`.
  None of the chart files live there.
- **Contrast is unchanged in kind.** B's gridlines are decoration, not meaningful graphical objects,
  so 1.4.11 does not bind them; the axis labels are `textSecondary`, a shipped token that already
  passes AA on `surfaceElevated` in both themes. The one contrast *fix* in scope is the touched-spot
  indicator moving off `borderStrong` (2.10:1).
- **The one real cost** is the Markets hero's narrow (stacked) layout, where the +73px is paid rather
  than absorbed.

Still open and unscheduled: the Markets hero runs its **own** colour rule today - a fixed
`gradientGreen -> gradientBlue` at `markets_hero_card.dart:312-315` - which the trend-colour decision
above supersedes but nobody has scheduled.
