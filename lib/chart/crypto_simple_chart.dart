import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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
    this.iconSize = 28,
    this.iconPath,
    this.onTap,
  });

  /// Soft muted green/red colors
  static const Color _mutedGreen = GeniusWalletColors.mutedGreen;
  static const Color _mutedRed = Colors.red;

  Color get priceColor => priceChangePercent > 0
      ? _mutedGreen
      : priceChangePercent < 0
      ? _mutedRed
      : Colors.grey[500]!;

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
    final tokenDecimalsToDisplay = currentPrice >= 1 ? 2 : 6;

    final formattedPrice = NumberFormat.currency(
      symbol: "\$",
      decimalDigits: tokenDecimalsToDisplay,
    ).format(currentPrice);

    return ListTile(
      leading: buildTokenIcon(iconPath: iconPath, size: iconSize),
      title: AutoSizeText(
        title,
        style: TextStyle(fontSize: 16, color: gw.textSecondary),
        maxLines: 1,
      ),
      onTap: onTap,
      subtitle: Text(
        formattedPrice,
        style: TextStyle(
          fontSize: 14,
          color: currentPrice == 0 ? gw.textSecondary : gw.textPrimary,
        ),
      ),
      titleAlignment: ListTileTitleAlignment.center,
      trailing: SizedBox(
        height: 44,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 5.0,
          children: [
            Text(
              "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 16,
                color: priceChangePercent == 0 ? Colors.grey[500] : priceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(
              width: 80,
              height: 15,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: getSparklineChartData(),
                      isCurved: true,
                      color: priceColor,
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
          ],
        ),
      ),
    );
  }
}
