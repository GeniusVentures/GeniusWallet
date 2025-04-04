import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

class CryptoSparkLineChart extends StatelessWidget {
  final String title;
  final String? iconPath;
  final double high24h;
  final double low24h;
  final double currentPrice;
  final double priceChangePercent;
  final List<double>? sparkline; // New data source
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

  Color get priceColor =>
      priceChangePercent >= 0 ? Colors.greenAccent : Colors.redAccent;

  /// Converts sparkline data into FlSpot points for the chart
  List<FlSpot> getSparklineChartData() {
    if (sparkline == null || sparkline!.isEmpty) {
      return [FlSpot(0, 0)];
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

    final iconSizing = iconSize ?? 24;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTokenIcon(iconPath: iconPath ?? "", size: iconSizing)
          ],
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            children: [
              // First Row: Title and % Change
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: AutoSizeText(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: GeniusWalletColors.gray500,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  AutoSizeText(
                    "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 16,
                      color: priceColor,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
              const SizedBox(height: 2),
              // Second Row: Price and Chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedPrice,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
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
                          leftTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
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
          ),
        ),
      ],
    );
  }
}
