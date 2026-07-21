---
quick_id: 260721-dws
type: execute
wave: 1
depends_on: [260720-uhe]
files_modified:
  - lib/chart/crypto_live_chart.dart
  - lib/dashboard/home/view/dashboard_screen.dart
autonomous: false
requirements:
  - sketch:006-bitcoin-chart-section-A-arrow
  - user-decision:drop-usd-delta-percent-pill-only
  - user-decision:timeframe-segment-visual-only-keep-zoom-pan

must_haves:
  truths:
    - "The Bitcoin Chart card header shows, on ONE row: a round ₿ coin mark + 'Bitcoin' (bold) + 'BTC' ticker on the left, pushed apart from a 1H·1D·1W·1M·1Y segmented control on the right."
    - "Tapping a timeframe visibly moves the selected chip, but the plotted series is UNCHANGED — the tabs are visual-only this task (real range wiring is a captured follow-up)."
    - "The centered hero price sits over a soft cyan glow; the only change indicator beneath it is a single green/red % pill — the absolute USD delta ('+$1,025.60') appears NOWHERE."
    - "The fl_chart area fills the card edge-to-edge in mint (brandSecondary) with a mint→transparent fill, independent of up/down trend (the trend color now only tints the % pill)."
    - "Hovering the chart on desktop shows a vertical crosshair + a mint dot on the curve and a tooltip carrying that point's date/time, price, and % change; it follows the cursor and flips/clamps to stay in the card."
    - "Zoom/pan still works; the compact-mode overflow guard (isCompact/priceFontSize/assert), the !isHeightBounded fallback, the live price stream, PulsingSkeleton loading branch, and currency formatting are all byte-for-byte preserved in behaviour."
    - "Both light and dark render at WCAG AA — the % pill and the selected timeframe label never use raw brand/greenAccent where light-mode contrast fails."
  artifacts:
    - lib/chart/crypto_live_chart.dart
    - lib/dashboard/home/view/dashboard_screen.dart
    - .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md
  key_links:
    - "The identity+timeframe header REPLACES GWSectionTitle but must reproduce its exact geometry (EdgeInsets.fromLTRB(space4, 2, space4, space8) + ConstrainedBox minHeight 44) or the chart card's title→body rhythm desyncs from the Assets/Markets/Transactions panels that still use GWSectionTitle."
    - "The % pill and the selected-timeframe label are the two AA pinch points: raw Colors.greenAccent/redAccent (pill) and raw brandPrimary/brandPrimaryStrong on white (TF label) both FAIL light-mode AA. The pill must read gw.statusSuccess/gw.statusError; the TF selected label must fall back to gw.textPrimary in light mode."
    - "The cyan glow is a layout-NEUTRAL Positioned/IgnorePointer overlay behind the price. If it enters the Column flow it re-opens the 6.3px compact overflow the 260720-uhe task just closed."
    - "The hover tooltip's per-point % is derived from the touched spot's y vs _oldestPrice — same _priceData series, NO new data source (styling an interaction fl_chart already supports)."
---

<objective>
Re-skin the dashboard Bitcoin Chart section to sketch 006's chosen winner **A→**: a coin-identity header (₿ · Bitcoin · BTC) on the left balanced against a 1H·1D·1W·1M·1Y timeframe segment on the right, a centered hero price over a cyan glow, a **% pill only** (the USD absolute delta is dropped), an edge-to-edge mint area chart, and a styled desktop hover crosshair + tooltip.

Purpose: today's card reads as a bland text title "Bitcoin Chart" (no coin mark, split alignment) with raw-color change values that fail light-mode AA. A→ gives it a real markets-card identity while staying inside the port's "re-skin, never restructure" rule.
Output: two lib files re-skinned (chart widget + the ChartDashboardView header), one captured follow-up todo, all existing chart behaviour preserved, AA-safe in both modes.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/STATE.md
@./CLAUDE.md
@.planning/sketches/006-bitcoin-chart-section/README.md
@.planning/sketches/006-bitcoin-chart-section/index.html
@lib/chart/crypto_live_chart.dart
@lib/dashboard/home/view/dashboard_screen.dart
@lib/components/cards/gw_section_title.dart
@lib/theme/genius_wallet_consts.dart
@lib/theme/genius_wallet_colors.dart
@lib/theme/gw_colors.dart

# ---------------------------------------------------------------------------
# SCOPE FENCE — read before touching anything.
# ---------------------------------------------------------------------------
# TOUCH ONLY: lib/chart/crypto_live_chart.dart AND the ChartDashboardView class
# (dashboard_screen.dart ~line 368-390). Do NOT edit _threeColumnLayout /
# _twoColumnLayout / OneColumnDashBoardView, theme.dart, responsive_overlay.dart,
# or any navbar file — a parallel session owns those and the working tree is dirty
# with their in-progress changes. If a small header widget is needed, define it
# PRIVATELY inside dashboard_screen.dart; do not add a new shared file.
#
# NEVER `git add -A` / `git add .` / `git commit`. CLAUDE.md: "Do not create
# commits." This task WRITES FILES ONLY. If staging is ever needed, stage the two
# declared lib paths explicitly — never broadly.
#
# The A→ target markup lives in the sketch: index.html CARD.Ar (line ~163) is
# `<div class="head">${IDENT}${TF()}</div>` + centered hero + `${PILL}` (%-only)
# + edge chart. IDENT (line 152), the .tf styles (44-47), .glow (40), the % pill
# (.pill 34-35), and the hover crosshair/dot/tip (.chart .cross/.hoverdot/.tip
# 61-69) are the visual contract. Port those onto Flutter tokens, keeping AA.
</context>

<tasks>

<task type="auto">
  <name>Task 1: Re-skin CryptoLiveChart — cyan-glow hero, %-pill-only, mint chart, styled hover crosshair + tooltip</name>
  <files>lib/chart/crypto_live_chart.dart</files>
  <action>
Re-skin the visuals of CryptoLiveChart to sketch 006 A→. This is a re-skin: change how it LOOKS, never how it behaves. PRESERVE verbatim — the live price Timer/stream, `_addNewPricePoint`, the `LayoutBuilder` compact-mode guard (`isHeightBounded`/`isCompact`/`priceFontSize` and its `assert`), the `!isHeightBounded` SizedBox fallback, the PulsingSkeleton loading branch, zoom/pan (`_zoomIn/_zoomOut/_panLeft/_panRight` and their IconButton row), `_onHover`/`_onHoverExit`, and the NumberFormat currency formatting.

Read appearance-aware colors the shipped way: `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();`. No hardcoded hex or EdgeInsets — use GWColors tokens and GeniusWalletConsts spacing/radius.

1. Split the trend color from the chart color. Introduce a `trendColor` = `isUptrend ? gw.statusSuccess : gw.statusError` (these are the AA-tuned per-mode tokens — they REPLACE the current raw `Colors.greenAccent`/`Colors.redAccent` `fillColor`). The chart itself is always MINT, decoupled from trend.

2. Hero price + cyan glow. Wrap the price `AutoSizeText` in a `Stack` so a soft cyan glow sits BEHIND it. The glow is a `Positioned`/`IgnorePointer` overlay (layout-neutral — it must NOT add height to the Column, or it re-opens the compact overflow that 260720-uhe closed): a blurred box using a radial gradient of `GeniusWalletColors.brandPrimary` at ~22% alpha fading to transparent, softened with an `ImageFiltered` gaussian blur (sigma ~8), roughly centered under the price. Keep the price `AutoSizeText` and its compact-mode `priceFontSize`/maxLines/tabular styling exactly as-is on top (z-order above the glow). Prefer `FontFeature.tabularFigures` for the price so digits don't jitter.

3. Change row → % pill ONLY. DROP the absolute USD `Text` ("+$…"). Keep only the pill, still gated by the existing `if (_hasData && !isCompact)` compact rule, still centered. Pill = a rounded (`GeniusWalletConsts.radiusXs`≈`space3`-ish; match the sketch's 6px) container filled with `trendColor` at ~20% alpha, label text = `trendColor` (NOT raw brand), showing `"${percent >= 0 ? "+" : ""}${percent.toStringAsFixed(2)}%"`. Because `trendColor` is `gw.statusSuccess/statusError` (light = #07875F / #D92D2D on a light tint, dark = #0AD89C / #FF4D4D on a dark tint) this reads AA in BOTH modes — the raw-accent version did not.

4. Mint edge chart. On the `LineChartBarData`: set `color` to `GeniusWalletColors.brandSecondary` (mint) — NOT white, NOT trend. Set `barWidth` to 2.4 (sketch stroke). Change the `belowBarData` gradient to mint→transparent: `brandSecondary` at ~30% alpha at top → `Colors.transparent` at bottom. Keep `isCurved: false`, grid/border/titles hidden, `clipData` as-is.

5. Hover crosshair + dot. In `getTouchedSpotIndicator`, return a `TouchedSpotIndicatorData` whose `FlLine` is a 1px solid line in `gw.borderStrong` (drop the grey dashArray), and whose `FlDotData` now SHOWS a mint dot via `getDotPainter` → `FlDotCirclePainter(radius: 5, color: brandSecondary, strokeWidth: 4, strokeColor: brandSecondary.withValues(alpha: 0.26))` — the glowing mint hover-dot from the sketch (.hoverdot).

6. Tooltip bubble. Restyle `LineTouchTooltipData`: set the tooltip surface to `gw.surfaceElevated` via `getTooltipColor`, keep `fitInsideHorizontally: true` and add `fitInsideVertically: true` (the sketch flips the bubble near the top edge), round the corners (`tooltipBorder`/`tooltipRoundedRadius` ~10). In `getTooltipItems`, build a two-part `LineTooltipItem`: main text = the point's date/time (reuse `_formatTime`, styled `gw.textSecondary`, ~11px) then a newline with the price (`gw.textPrimary`, bold, ~14px), and append a `TextSpan` child for that point's % change colored `gw.statusSuccess`/`gw.statusError`. Compute the per-point % from the touched `spot.y` vs `_oldestPrice` — same series, NO new data source. (ponytail: fl_chart's tooltip has no first-class hairline-border/shadow like the sketch's .tip bubble; getTooltipColor + rounded radius is the closest built-in. Ceiling: no border/shadow. Upgrade path: a custom overlay-positioned tooltip widget if the bubble ever needs the hairline.)

Mark any intentional shortcut with a `ponytail:` comment naming the ceiling + upgrade path.
  </action>
  <verify>
    <automated>flutter analyze lib 2>&1 | tail -3   # DELTA only vs baseline ~61 issues / 0 errors; ANY new error is blocking. flutter test does not compile on this branch — do not use it.</automated>
  </verify>
  <done>Price sits over a cyan glow with no USD delta; a single trend-tinted % pill remains; the area chart is mint edge-to-edge; hovering shows a border-strong crosshair + glowing mint dot + a surface-elevated tooltip with date/price/colored-%; zoom/pan, the compact guard, live updates, and loading branch are untouched; analyze reports 0 new errors.</done>
</task>

<task type="auto">
  <name>Task 2: ChartDashboardView header — coin identity + visual-only timeframe segment; capture the range-wiring follow-up</name>
  <files>lib/dashboard/home/view/dashboard_screen.dart, .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md</files>
  <action>
Replace `GWSectionTitle(title: 'Bitcoin Chart')` in `ChartDashboardView` (ONLY this class, ~line 368-390 — do not touch the layout methods) with the A→ header row: coin identity on the left, a timeframe segment on the right, one row, pushed apart.

1. Define the header PRIVATELY inside dashboard_screen.dart (no new shared file, per the scope fence). It must reproduce GWSectionTitle's exact geometry so the chart card's title→body rhythm still matches the Assets/Markets/Transactions panels: wrap in `Padding(EdgeInsets.fromLTRB(GeniusWalletConsts.space4, 2, GeniusWalletConsts.space4, GeniusWalletConsts.space8))` + `ConstrainedBox(BoxConstraints(minHeight: 44))` + a `Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: center)`. Read `gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();`.

2. Identity (left) — mirror the sketch IDENT (index.html:152): a 30px round coin avatar (`brandPrimary`? no — Bitcoin orange #F7931A, the recognizable coin mark) containing a ₿ glyph, then a small column/row with "Bitcoin" (bold, `gw.textPrimary`, ~15px, letterSpacing -0.2) and "BTC" ticker (muted, `gw.textSecondary`, ~11px, letterSpacing +0.5). Gap between avatar and text = `GeniusWalletConsts.space3` (6). (ponytail: the ₿-on-#F7931A coin avatar is the recognizable Bitcoin brand LOGO mark — WCAG's logo exemption applies, so its glyph/fill contrast does not gate AA; it stays the canonical white-₿-on-orange. Ceiling: hardcoded to bitcoin. Upgrade path: a coin-agnostic avatar when the card stops being hardcoded to `coinGeckoCoinId: 'bitcoin'`.)

3. Timeframe segment (right) — a VISUAL-ONLY 1H·1D·1W·1M·1Y segmented control (sketch .tf, lines 44-47 + TFS line 149). Define a small PRIVATE StatefulWidget holding its own selected index (default 1 = '1D', matching the sketch's `i===1?'on'`). Track styling: a pill-radius (`GeniusWalletConsts.radiusPill`) container in `gw.surfaceMenu` with ~3px padding; each tab a tappable pill; the SELECTED chip = `gw.surfaceElevated` fill + a soft card shadow + the label brand-tinted; unselected label = `gw.textSecondary`. AA for the selected label: dark = `GeniusWalletColors.brandPrimary` (#14C8FF passes on the dark elevated chip), light = fall back to `gw.textPrimary` — because both brandPrimary (#14C8FF) and brandPrimaryStrong (#0AAEE6) FAIL AA on the white light-mode chip. Detect mode via `Theme.of(context).brightness == Brightness.light` (or `GWAppearance.isLight`). (ponytail: the segment ONLY changes its own selected state — it does not re-fetch or re-window the series. The plotted data is unchanged this task. Ceiling: non-functional tabs. Upgrade path: the captured follow-up todo wires real 1H/1D/1W/1M/1Y ranges into CryptoLiveChart, at which point a later task decides whether the kept zoom/pan row is still needed.)

4. Keep the `Expanded(child: CryptoLiveChart(coinGeckoCoinId: 'bitcoin', tokenSymbol: 'btc', priceHeight: 28))` below the header exactly as-is (Task 1 re-skins its internals). Do NOT generalise the coin.

5. Capture the follow-up. Write `.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md` recording: the A→ timeframe segment ships VISUAL-ONLY (user decision 2026-07-21); wiring real 1H/1D/1W/1M/1Y ranges is a data change in CryptoLiveChart (new behaviour, out of scope for a re-skin); and once wired, a later task decides whether the still-present zoom/pan row is redundant. Note in the SUMMARY that zoom/pan was deliberately KEPT (deleting working behaviour violates the port rule) even though A→ visually replaced it with timeframes.
  </action>
  <verify>
    <automated>flutter analyze lib 2>&1 | tail -3   # DELTA only vs baseline ~61 issues / 0 errors; ANY new error is blocking.</automated>
  </verify>
  <done>ChartDashboardView shows the ₿·Bitcoin·BTC identity on the left and a 1H·1D·1W·1M·1Y segment on the right at the SAME header geometry as the other panels; tapping a tab moves the selected chip without changing the series; the CryptoLiveChart below is unchanged in wiring; the follow-up todo file exists; analyze reports 0 new errors.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
The dashboard Bitcoin Chart card re-skinned to sketch 006 A→: coin-identity header + top-right timeframe segment (visual-only), centered hero price over a cyan glow, %-pill-only change (USD delta dropped), edge-to-edge mint area chart, styled hover crosshair + tooltip, with zoom/pan and the overflow guard preserved, AA in both themes.
  </what-built>
  <how-to-verify>
Run on macOS (the planning docs' `-d windows` recipes are stale):

  flutter run -d macos --dart-define=GW_DEV_TOOLS=true

Use the dev-tools bubble: **MOCK** to populate holdings/transactions offline, **Appearance** to flip light/dark in place. The Bitcoin Chart card is the chart cell (bottom-left in the 3-column dashboard). Check:

1. Header: round ₿ coin mark + "Bitcoin" bold + "BTC" muted on the LEFT; a 1H·1D·1W·1M·1Y segment pushed to the RIGHT, on one row, aligned like the Assets/Markets/Transactions titles.
2. Tap the timeframe tabs — the selected chip visibly moves (the series is intentionally unchanged this task).
3. Centered price with a soft cyan glow behind it; a SINGLE green/red % pill below it and NO "+$1,025.60" USD delta anywhere.
4. The area chart is mint, edge-to-edge, mint→transparent fill.
5. Hover the chart with the mouse — a vertical crosshair snaps to the line, a mint dot sits on the curve, and a tooltip shows that point's date/time + price + % change and FOLLOWS the cursor (flips/clamps near edges).
6. Zoom/pan buttons still work.
7. Shrink to the two-column breakpoint (~800x500) — NO RenderFlex overflow stripes (the 260720-uhe guard still holds).
8. Repeat 1-7 in BOTH light and dark — the % pill and selected timeframe label are legible (AA) in both.
  </how-to-verify>
  <resume-signal>Type "approved" or describe what's off (per screen area).</resume-signal>
</task>

</tasks>

<verification>
- `flutter analyze lib` reports 0 new ERRORS vs the ~61-issue / 0-error baseline (analyze is a gate, not evidence; the walk is the evidence).
- Only the two declared lib files + the one todo .md changed; no commit created; no broad `git add`.
- Zoom/pan, live updates, compact-mode guard, loading skeleton, and currency formatting behave exactly as before.
</verification>

<success_criteria>
The Bitcoin Chart card matches sketch 006 A→ (identity header + top-right visual-only timeframe segment, cyan-glow hero, %-pill-only, mint edge chart, styled hover crosshair/tooltip), preserves all existing chart behaviour, passes AA in light and dark, and the human walk is approved.
</success_criteria>

<output>
Create `.planning/quick/260721-dws-bitcoin-chart-section-reskin-a-arrow/260721-dws-SUMMARY.md` when done. In it: flag that the timeframe segment shipped VISUAL-ONLY with the range-wiring follow-up captured, and that zoom/pan was deliberately KEPT (working behaviour is not deleted) pending that follow-up.
</output>
