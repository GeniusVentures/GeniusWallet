import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:intl/intl.dart';

class CryptoSparkLineChart extends StatelessWidget {
  final String title;
  final String? iconPath;
  final double high24h;
  final double low24h;
  final double currentPrice;
  final double priceChangePercent;
  final List<double>? sparkline;
  final double? iconSize;

  const CryptoSparkLineChart({
    super.key,
    required this.title,
    required this.high24h,
    required this.low24h,
    required this.currentPrice,
    required this.priceChangePercent,
    this.sparkline,
    this.iconSize,
    this.iconPath,
  });

  /// Soft muted green/red colors
  static const Color _mutedGreen = GeniusWalletColors.mutedGreen;
  static const Color _mutedRed = GeniusWalletColors.mutedRed;

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
    final tokenDecimalsToDisplay = currentPrice >= 1 ? 2 : 6;

    final formattedPrice = NumberFormat.currency(
            locale: "en_US",
            symbol: "\$",
            decimalDigits: tokenDecimalsToDisplay)
        .format(currentPrice);

    // Manually-centered Row (replaces a ListTile, whose internal title/subtitle
    // metrics left more space above the content than below it).
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        buildTokenIcon(iconPath: iconPath ?? "", size: iconSize ?? 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AutoSizeText(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: GeniusWalletColors.gray500,
                ),
                maxLines: 1,
              ),
              Text(
                formattedPrice,
                style: TextStyle(
                  fontSize: 14,
                  color: currentPrice == 0
                      ? Colors.grey[600]
                      : GeniusWalletColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 16,
                color: priceChangePercent == 0 ? Colors.grey[500] : priceColor,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 70,
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
                    leftTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
