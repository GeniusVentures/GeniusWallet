import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';

class CryptoLiveChart extends StatefulWidget {
  /// Coin Gecko Coin Id
  final String coinGeckoCoinId;
  final String tokenSymbol;
  final Widget? child;
  final double? chartHeight;
  final double? priceHeight;

  const CryptoLiveChart(
      {Key? key,
      required this.coinGeckoCoinId,
      required this.tokenSymbol,
      this.chartHeight,
      this.priceHeight,
      this.child})
      : super(key: key);

  @override
  CryptoLiveChartState createState() => CryptoLiveChartState();
}

class CryptoLiveChartState extends State<CryptoLiveChart> {
  List<FlSpot> _priceData = [];
  double? _latestPrice; // Nullable to track uninitialized state
  double? _previousPrice;
  Timer? _timer;
  bool _isLoading = true; // New loading state

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
    _startPeriodicHistoricalUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startPeriodicHistoricalUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      await _fetchHistoricalData();
    });
  }

  Future<void> _fetchHistoricalData() async {
    setState(() => _isLoading = true); // Show loader while fetching

    final historicalPrices =
        await fetchHistoricalPrices(widget.coinGeckoCoinId);

    if (historicalPrices.isNotEmpty) {
      List<FlSpot> historicalData = historicalPrices.entries
          .map((entry) => FlSpot(
                entry.key.toDouble(),
                entry.value,
              ))
          .toList();

      setState(() {
        _priceData = historicalData;
        _latestPrice = _priceData.last.y;
        _previousPrice = _priceData.first.y;
        _isLoading = false; // Hide loader once data is available
      });
    } else {
      setState(() => _isLoading = false); // Hide loader even on failure
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokenDecimalsToDisplay =
        (_latestPrice != null && _latestPrice! >= 1) ? 2 : 6;

    final formattedPrice = _latestPrice != null
        ? NumberFormat.currency(
                locale: "en_US",
                symbol: "\$",
                decimalDigits: tokenDecimalsToDisplay)
            .format(_latestPrice)
        : "--"; // Show placeholder while loading

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _isLoading
            ? const CircularProgressIndicator() // Show loader when fetching
            : AutoSizeText(
                formattedPrice,
                maxLines: 1,
                style: TextStyle(
                  fontSize: widget.priceHeight ?? 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
        const SizedBox(height: 8),
        _isLoading
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${_latestPrice != null && _previousPrice != null ? (_latestPrice! - _previousPrice!).toStringAsFixed(tokenDecimalsToDisplay) : "--"}",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _latestPrice != null &&
                              _previousPrice != null &&
                              (_latestPrice! - _previousPrice!) >= 0
                          ? Colors.greenAccent
                          : Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ),
        const SizedBox(height: 24),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight:
                widget.chartHeight ?? MediaQuery.of(context).size.height * .2,
          ),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator()) // Show loading spinner
              : LineChart(
                  LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        spots: _priceData,
                        isCurved: true,
                        color: (_latestPrice != null &&
                                _previousPrice != null &&
                                (_latestPrice! - _previousPrice!) >= 0)
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        barWidth: 2,
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              (_latestPrice != null &&
                                      _previousPrice != null &&
                                      (_latestPrice! - _previousPrice!) >= 0)
                                  ? Colors.greenAccent.withOpacity(0.3)
                                  : Colors.redAccent.withOpacity(0.3),
                              Colors.transparent,
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
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
    );
  }
}
