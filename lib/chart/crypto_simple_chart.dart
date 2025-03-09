import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/image_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

class CryptoSimpleChart extends StatelessWidget {
  final String title;
  final String? iconPath;
  final double high24h;
  final double low24h;
  final double currentPrice;
  final double priceChangePercent;
  final double? iconSize;

  const CryptoSimpleChart({
    Key? key,
    required this.title,
    required this.high24h,
    required this.low24h,
    required this.currentPrice,
    required this.priceChangePercent,
    this.iconSize,
    this.iconPath,
  }) : super(key: key);

  Color get priceColor =>
      priceChangePercent >= 0 ? Colors.greenAccent : Colors.redAccent;

  List<FlSpot> getGeneratedChartData() {
    Random random = Random();
    List<FlSpot> spots = [];
    double range = high24h - low24h;
    double basePrice = low24h;

    for (int i = 0; i < 24; i++) {
      double time = i.toDouble();
      double fluctuation =
          (random.nextDouble() - 0.5) * range * 0.2; // ±10% fluctuation
      double price = basePrice +
          ((range * (i / 24.0)) * (priceChangePercent >= 0 ? 1 : -1)) +
          fluctuation;
      spots.add(FlSpot(time, price));
    }
    return spots;
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
        // Icon centered vertically for both rows
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTokenIcon(iconPath: iconPath ?? "", size: iconSizing)
          ],
        ),
        const SizedBox(width: 8),

        // Chart & text content
        Expanded(
          child: Column(
            children: [
              // First Row: Title on the left, Change Percentage on the right
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
                  )),
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

              // Second Row: Current Price on the left, Chart on the right
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
                    width: 70, // Adjust as needed
                    height: 15,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            spots: getGeneratedChartData(),
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
                        lineTouchData: const LineTouchData(
                            enabled: false), // No interactivity
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
