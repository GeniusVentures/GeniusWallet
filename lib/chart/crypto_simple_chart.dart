import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
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
  final double iconSize;
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
    this.iconSize = 34,
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
    final Color changeColor =
        priceChangePercent >= 0 ? gw.statusSuccess : gw.statusError;
    final tokenDecimalsToDisplay = currentPrice >= 1 ? 2 : 6;

    final formattedPrice = NumberFormat.currency(
      symbol: "\$",
      decimalDigits: tokenDecimalsToDisplay,
    ).format(currentPrice);

    return ListTile(
      leading: buildTokenIcon(iconPath: iconPath, size: iconSize),
      // NAME is primary (titleMd / textPrimary), price secondary (bodySm /
      // textSecondary) — mirrors the Assets CoinCardRow hierarchy.
      // A FIXED style with an ellipsis, never AutoSizeText. AutoSizeText
      // searches for a font size that fits the box, so as the window is
      // drag-resized it emits a different size — and therefore a different
      // TextStyle, and therefore a different skia ParagraphCacheKey — on
      // essentially every frame. With one of these per market row, that fills
      // and evicts the fixed-size cache continuously, layout never settles,
      // no frame is ever committed, and the macOS embedder blocks forever in
      // ResizeSynchronizer.beginResize. That is the freeze commit 37639d5
      // diagnosed; 37639d5 only quantised the OTHER site's height-derived
      // font size and left this width-driven search in place.
      title: Text(
        title,
        style: GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: onTap,
      // Ticker · price when a symbol is given (Jakub 2026-07-24 — "add the
      // ticker if there's room"); ellipsis so a long pair degrades gracefully
      // in the narrow dashboard panel rather than overflowing.
      subtitle: Text(
        symbol != null && symbol!.isNotEmpty
            ? '${symbol!.toUpperCase()} · $formattedPrice'
            : formattedPrice,
        style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      titleAlignment: ListTileTitleAlignment.center,
      // Order: % chip, then the sparkline as the LAST (rightmost) column
      // (Jakub 2026-07-24). textDirection.rtl flips the child order without
      // moving the big LineChart block: the first child (sparkline) lays out on
      // the right, the last (% chip) on the left. Each child's own text keeps
      // the app's LTR Directionality, so "+2.4%" renders normally.
      trailing: Row(
        textDirection: TextDirection.rtl,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Same sparkline geometry as the Markets TAB's table column
          // (markets_table.dart:310-318 — 72x32, barWidth 1.6) so the two
          // renderings of the same data read as one component instead of the
          // dashboard's being a visibly shrunk 56x20 copy. Jakub, 2026-07-25.
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
    );
  }
}
