import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CryptoMinimalChart extends StatelessWidget {
  final double high24h;
  final double low24h;
  final double currentPrice;
  final double priceChangePercent;
  final double width;
  final double height;

  const CryptoMinimalChart({
    Key? key,
    required this.high24h,
    required this.low24h,
    required this.currentPrice,
    required this.priceChangePercent,
    this.width = 100, // Default width
    this.height = 50, // Default height
  }) : super(key: key);

  Color get priceColor =>
      priceChangePercent >= 0 ? Colors.greenAccent : Colors.redAccent;

  List<FlSpot> getGeneratedChartData() {
    Random random = Random();
    List<FlSpot> spots = [];
    double range = high24h - low24h;
    double basePrice = low24h;

    // **Steepness Factor**: Scales with percentage change
    double steepnessFactor = (priceChangePercent.abs() / 100).clamp(0.1, 1.5);

    for (int i = 0; i < 24; i++) {
      double time = i.toDouble();

      // **Fluctuation Scaling**: Increased variation based on steepness
      double fluctuation =
          (random.nextDouble() - 0.5) * range * 0.2 * steepnessFactor;

      // **Price Change Scaling**: More movement for higher percentage change
      double price = basePrice +
          ((range * (i / 24.0)) *
              steepnessFactor *
              (priceChangePercent >= 0 ? 1 : -1)) +
          fluctuation;

      spots.add(FlSpot(time, price));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
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
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData:
              const LineTouchData(enabled: false), // No interactivity
        ),
      ),
    );
  }
}
