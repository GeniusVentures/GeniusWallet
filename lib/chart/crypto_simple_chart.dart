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
    Key? key,
    required this.title,
    required this.high24h,
    required this.low24h,
    required this.currentPrice,
    required this.priceChangePercent,
    this.sparkline,
    this.iconSize,
    this.iconPath,
  }) : super(key: key);

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

    return ListTile(
      minVerticalPadding: 0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
      leading: buildTokenIcon(iconPath: iconPath ?? "", size: iconSize ?? 28),
      title: AutoSizeText(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: GeniusWalletColors.gray500,
        ),
        maxLines: 1,
      ),
      subtitle: Text(
        formattedPrice,
        style: TextStyle(
          fontSize: 14,
          color: currentPrice == 0 ? Colors.grey[600] : Colors.white,
        ),
      ),
      trailing: SizedBox(
        height: 44, // Fix for overflow, ensures everything fits
        child: Column(
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
      ),
    );
  }
}
