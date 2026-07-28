# 260728-w3d · Three fixes from the 074-C2 walk

**Date:** 2026-07-28 · **Lane:** execution · **Commits:** none (CLAUDE.md)

Jakub walked the shipped coin page and raised three things, plus a Receive drawer screenshot.

## 1 · The Receive drawer was not on the shell's standard

Asked: *"czy ten drawer follows the base components?"* The **body** does - `CryptoAddressQR` is 034-A2
and already composes `GWWarningNote` and `GWDecorations`. **The call site had drifted.**

It wrapped the child in `Align(topCenter)` + `Padding(8)` + `SizedBox(width: small * 0.5)`. All three
are wrong now: `ResponsiveDrawer` applies `kDrawerBodyPadding` itself (so the 8 was a second inset on
top of 20/24), `CryptoAddressQR` is a `mainAxisSize.min` centred Column (so the Align did nothing),
and the 300px cap squeezed the warning note narrower than the panel around it. The other consumer,
`coins_screen.dart:170`, passes the component bare - now both do.

**And the header said "Receive null".** `"Receive ${selectedCoin?.name}"` interpolated a null straight
into the title, which is the state you land in arriving from Markets. Now the name comes from
`selectedCoin` **only, never `marketData`**, and falls back to a bare "Receive": the QR shows the
WALLET's address on the wallet's network, so titling it after the coin you were browsing would put
*"Receive Bitcoin"* over an Ethereum address. Pinned by a test.

**A defect in the component, found by that test's own log:** `embeddedImage: AssetImage(widget.iconPath ?? "")`
threw *"Unable to load asset"* on every build for every coin without artwork. `null` is the API's way
to say "no embedded logo"; the `??` was reaching for a non-nullable type that did not need one. Fixed
for all four consumers.

## 2 · The token icon before the coin name

*"Przed Genius AI powinna być ikona tokenu, zawsze."* `GWPageHeader` gained an optional **`leading`**,
centred against the whole identity block (title + subtitle), and the coin page passes
`buildTokenIcon` - the helper `markets_hero_card` and `markets_table` already use, which takes a URL
or an asset path and falls back to a placeholder circle, so *"zawsze"* holds even with no artwork.
Source order is CoinGecko's `imageUrl` then the wallet's own `iconPath`: the market record is what
names the coin in the title, so the glyph should come from the same place.

**One consumer, stated rather than hidden.** That is under the 3+ promotion bar. The alternative was
not a local widget - it was the coin page hand-rolling a title row again, which is what `GWPageHeader`
exists to stop and what 071-B deleted. Additive and defaulted to null, so every existing caller
renders an identical tree.

## 3 · The flat chart - the data was not flat, the ruler was wrong

*"ten chart jest bardzo płaski."* `LineChartData.minY/maxY` reduced over the **entire** `_priceData`
while `minX/maxX` showed only the **last 50 points** (`_fetchHistoricalData` sets that window). On
GNUS - 98.53% below its all-time high - the scale was therefore set by prices that were not on screen,
and the visible 24h range of $0.65-$0.79 occupied a sliver at the bottom of the card.

`chartYBounds(data, viewMinX:, viewMaxX:)` is now top-level and pure, computed over the **visible
slice**, with 8% headroom each side (the old `* 0.999` / `* 1.001` was effectively none, so the line
also ran edge to edge). A genuinely flat slice - one point, or a stablecoin - has zero span and cannot
be scaled, so it falls back to ±1% of the value and lands mid-card rather than dividing by zero. That
case is not hypothetical: it is every chart between first paint and the second live tick.

**Pure and top-level for the same reason `coinChartHeight` is:** a y-window bug renders a perfectly
good-looking chart. This one shipped that way and only a walk caught it.

## Checks

- `test/chart/chart_y_bounds_test.dart` - 5 tests, including the exact GNUS shape (50 points at the
  old high, 50 in today's range) asserting the window comes from the visible half; a flat slice at
  **zero**, where `value * 0.01` is 0 and the bug would repeat; and an empty series not throwing out
  of `reduce`.
- `test/tokens/coin_page_stat_rail_test.dart` - the Receive drawer never says "Receive null".

## Gates

`flutter analyze lib` **59** = baseline. `flutter test test/chart test/tokens` **19 pass**.

**Hot reload stopped completing** partway through - 6 requests, 3 completions, the log frozen - so the
app was quit and **relaunched**, which is why this is not reported as a reload.

## Not done

The walk. In particular the chart, which is the one of the three that cannot be checked from code:
the fix changes what the ruler measures, and only a real series says whether 8% headroom is the right
amount.

## Related

- `.planning/sketches/075-coin-actions-placement/` - the fourth thing Jakub asked for, drawn not built
- `.planning/todos/pending/2026-07-28-the-global-swap-fab-floats-over-every-drawer.md`
- `.planning/todos/pending/2026-07-28-receive-from-markets-shows-an-address-on-the-wrong-network.md`
