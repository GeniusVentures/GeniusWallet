import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_row_rhythm.dart';
import 'package:genius_wallet/components/effects/gw_hover_row.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
// hide TextDirection — intl also declares one, which would shadow the
// flutter/ui TextDirection used by the trailing Row below (needs .rtl).
import 'package:intl/intl.dart' hide TextDirection;

class CryptoSparkLineChart extends StatelessWidget {
  final String title;
  final String? symbol;
  final String? iconPath;
  final double high24h;
  final double low24h;
  final double currentPrice;
  final double priceChangePercent;
  final List<double>? sparkline;
  final void Function()? onTap;

  const CryptoSparkLineChart({
    super.key,
    required this.title,
    this.symbol,
    required this.high24h,
    required this.low24h,
    required this.currentPrice,
    required this.priceChangePercent,
    this.sparkline,
    this.iconPath,
    this.onTap,
  });

  List<FlSpot> getSparklineChartData() {
    if (sparkline == null || sparkline!.isEmpty) {
      return [const FlSpot(0, 0)];
    }

    return List.generate(
      sparkline!.length,
      (index) => FlSpot(index.toDouble(), sparkline![index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Assets-mirror up/down: status green/red (never the legacy muted green).
    final Color changeColor = priceChangePercent >= 0
        ? gw.statusSuccess
        : gw.statusError;
    final tokenDecimalsToDisplay = currentPrice >= 1 ? 2 : 6;

    final formattedPrice = NumberFormat.currency(
      symbol: "\$",
      decimalDigits: tokenDecimalsToDisplay,
    ).format(currentPrice);

    // The dashboard Markets panel is the FOURTH tappable list, and it went
    // missing from the 2026-07-30 hover sweep: the Markets *page* table and
    // this panel look like one feature but are two widgets, and only the table
    // was migrated. Same `ListTile` failure as Assets - the tile draws its
    // highlight on the nearest ancestor `Material`, which on the dashboard sits
    // beneath the panel's own background, so it was painted and then covered.
    //
    // `GWHoverRow` brings its own transparent `Material` above that paint and
    // clips to `radiusMd`. The tile keeps its layout and gives up only its tap:
    // two ink responses stacked on one row would double the highlight.
    // ROW RHYTHM, 2026-08-07 (260807-wbu). `ListTile` snapped this row to
    // Material's default two-line 72px tile with NO `contentPadding` declared
    // anywhere, so 100% of its 13.25 / 16.75 slack and its 16px wall were the
    // tile's own centring default, not a choice made in this repo - see
    // `gw_row_rhythm.dart`. `Padding(kGWRowPadding)` + `Row` replaces the
    // tile with the same shape `transaction_displays.dart:390-627` ships, so
    // the four numbers Jakub named come from one file instead of a Material
    // default nobody wrote down.
    return GWHoverRow(
      onTap: onTap,
      semanticLabel: title,
      child: Padding(
        padding: kGWRowPadding,
        child: Row(
          children: [
            buildTokenIcon(iconPath: iconPath, size: kGWRowIconSize),
            const SizedBox(width: kGWRowIconToText),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // NAME is primary (titleMd / textPrimary), price secondary
                  // (bodySm / textSecondary) — mirrors the Assets CoinCardRow
                  // hierarchy.
                  // A FIXED style with an ellipsis, never AutoSizeText.
                  // AutoSizeText searches for a font size that fits the box,
                  // so as the window is drag-resized it emits a different
                  // size — and therefore a different TextStyle, and therefore
                  // a different skia ParagraphCacheKey — on essentially every
                  // frame. With one of these per market row, that fills and
                  // evicts the fixed-size cache continuously, layout never
                  // settles, no frame is ever committed, and the macOS
                  // embedder blocks forever in
                  // ResizeSynchronizer.beginResize. That is the freeze commit
                  // 37639d5 diagnosed; 37639d5 only quantised the OTHER
                  // site's height-derived font size and left this
                  // width-driven search in place.
                  Text(
                    title,
                    style: GeniusWalletTypography.titleMd.copyWith(
                      color: gw.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: GeniusWalletConsts.space2),
                  // Ticker · price when a symbol is given (Jakub 2026-07-24 —
                  // "add the ticker if there's room"); ellipsis so a long
                  // pair degrades gracefully in the narrow dashboard panel
                  // rather than overflowing.
                  Text(
                    symbol != null && symbol!.isNotEmpty
                        ? '${symbol!.toUpperCase()} · $formattedPrice'
                        : formattedPrice,
                    style: GeniusWalletTypography.bodySm.copyWith(
                      color: gw.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: kGWRowIconToText),
            // NON-FLEX, unlike `coin_card_row.dart`'s `Flexible` trailing -
            // deliberate, and the largest obstacle to a future shared
            // component (see `gw_row_rhythm.dart`'s upgrade-path note), so
            // written down here rather than left to look like an oversight.
            // This trailing's width is bounded BY CONSTRUCTION: a fixed
            // 72x32 `LineChart`, a fixed `space6` gap, and a chip whose
            // longest label is a signed three-digit percentage - there is no
            // unbounded text in it, so it cannot raise a `RenderFlex`
            // overflow the way an unbounded `Text` could. Giving it flex
            // would only shrink the sparkline for no benefit, which is why
            // Assets' trailing (two unbounded `Text`s that must ellipsise)
            // and this one do not share a flex model.
            //
            // Order: % chip, then the sparkline as the LAST (rightmost)
            // column (Jakub 2026-07-24). textDirection.rtl flips the child
            // order without moving the big LineChart block: the first child
            // (sparkline) lays out on the right, the last (% chip) on the
            // left. Each child's own text keeps the app's LTR
            // Directionality, so "+2.4%" renders normally.
            Row(
              textDirection: TextDirection.rtl,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 72x32, barWidth 1.6 - Jakub, 2026-07-25, matched to the
                // Markets page's own table-column sparkline so the two
                // renderings of the same data read as one component instead of
                // the dashboard's being a visibly shrunk 56x20 copy. The
                // Markets page dropped its table (and that sparkline) for cards
                // in quick 260807-bxs; this one is unaffected and keeps the
                // same geometry.
                SizedBox(
                  width: 72,
                  height: 32,
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: getSparklineChartData(),
                          isCurved: true,
                          color: changeColor,
                          barWidth: 1.6,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineTouchData: const LineTouchData(enabled: false),
                    ),
                  ),
                ),
                // space6 = 12
                const SizedBox(width: 12),
                // Filled % chip (status tint + status fg), like Assets.
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
