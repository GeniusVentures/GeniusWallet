import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

class CryptoSparkLineChart extends StatelessWidget {
  final String title;
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
      title: AutoSizeText(
        title,
        style: GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary),
        maxLines: 1,
      ),
      onTap: onTap,
      subtitle: Text(
        formattedPrice,
        style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
      ),
      titleAlignment: ListTileTitleAlignment.center,
      // 003-A: sparkline LEFT, % chip RIGHT — horizontal, "first the light
      // graph, then the growth %". No fixed height; the Row sizes to content.
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 20,
            child: LineChart(
              LineChartData(
                lineBarsData: [
                  LineChartBarData(
                    spots: getSparklineChartData(),
                    isCurved: true,
                    color: changeColor,
                    barWidth: 2,
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
