import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
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
  double _latestPrice = 0.0;
  double _previousPrice = 0.0;
  Timer? _timer;

  bool _isHovering = false;
  double _hoveredPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchHistoricalData();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchHistoricalData() async {
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
      });
    }
  }

  void _startLiveUpdates() {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      final coinPrices =
          await fetchCoinsMarketData(coinIds: [widget.coinGeckoCoinId]);
      if (coinPrices.isNotEmpty) {
        double newPrice =
            coinPrices[widget.tokenSymbol.toLowerCase()]?.currentPrice ?? 0.0;
        _addNewPricePoint(newPrice);
      }
    });
  }

  void _addNewPricePoint(double newPrice) {
    setState(() {
      double newTime = _priceData.isEmpty ? 0 : _priceData.last.x + 1;
      _priceData.add(FlSpot(newTime, newPrice));
      _latestPrice = newPrice;

      if (_priceData.length > 50) {
        _priceData.removeAt(0);
      }
    });
  }

  double get priceChange =>
      (_isHovering ? _hoveredPrice : _latestPrice) - _previousPrice;

  double get priceChangePercent =>
      _previousPrice > 0 ? (priceChange / _previousPrice) * 100 : 0;

  Color get priceColor =>
      priceChange >= 0 ? Colors.greenAccent : Colors.redAccent;

  String _formatTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('h:mm a').format(dateTime);
  }

  void _onHover(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (touchResponse == null || touchResponse.lineBarSpots == null) {
      return;
    }

    final hoveredSpot = touchResponse.lineBarSpots!.first;
    setState(() {
      _isHovering = true;
      _hoveredPrice = hoveredSpot.y;
    });
  }

  void _onHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovering = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayPrice = _isHovering ? _hoveredPrice : _latestPrice;
    final tokenDecimalsToDisplay = displayPrice >= 1 ? 2 : 6;

    final formattedPrice = NumberFormat.currency(
            locale: "en_US",
            symbol: "\$",
            decimalDigits: tokenDecimalsToDisplay)
        .format(displayPrice);

    return MouseRegion(
      onExit: _onHoverExit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${priceChange >= 0 ? "+" : ""}\$${priceChange.toStringAsFixed(tokenDecimalsToDisplay)}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: priceColor,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: priceColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: priceColor,
                  ),
                ),
              ),
            ],
          ),
          if (widget.child != null) ...[
            const SizedBox(height: 24),
            widget.child!,
            const SizedBox(height: 24),
          ],
          const SizedBox(height: 24),
          ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.chartHeight ??
                    MediaQuery.of(context).size.height * .2,
              ),
              child: Row(children: [
                Expanded(
                  child: LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: _priceData,
                          isCurved: true,
                          color: priceColor,
                          barWidth: 2,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [
                                priceColor.withOpacity(0.3),
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
                      lineTouchData: LineTouchData(
                        touchTooltipData: LineTouchTooltipData(
                          tooltipBgColor: Colors.transparent,

                          fitInsideHorizontally: true, // Prevents clipping
                          getTooltipItems: (List<LineBarSpot> touchedSpots) {
                            return touchedSpots.map((spot) {
                              return LineTooltipItem(
                                _formatTime(spot.x.toInt()),
                                TextStyle(
                                  color: Colors.grey[400],
                                  fontWeight: FontWeight.normal,
                                ),
                              );
                            }).toList();
                          },
                        ),
                        touchCallback: _onHover,
                        handleBuiltInTouches: true,
                        getTouchedSpotIndicator:
                            (LineChartBarData barData, List<int> indicators) {
                          return indicators.map((index) {
                            return TouchedSpotIndicatorData(
                              FlLine(
                                color: Colors.grey[400]!,
                                strokeWidth: 1.5,
                              ),
                              const FlDotData(show: false),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                )
              ])),
        ],
      ),
    );
  }
}
