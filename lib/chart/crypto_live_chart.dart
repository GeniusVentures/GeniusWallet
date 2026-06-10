import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/pulsing_skeleton.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:intl/intl.dart';

class CryptoLiveChart extends StatefulWidget {
  final String coinGeckoCoinId;
  final String tokenSymbol;
  final Widget? child;
  final double? chartHeight;
  final double? priceHeight;

  const CryptoLiveChart({
    Key? key,
    required this.coinGeckoCoinId,
    required this.tokenSymbol,
    this.chartHeight,
    this.priceHeight,
    this.child,
  }) : super(key: key);

  @override
  CryptoLiveChartState createState() => CryptoLiveChartState();
}

class CryptoLiveChartState extends State<CryptoLiveChart> {
  List<FlSpot> _priceData = [];
  double _latestPrice = 0.0;
  double _previousPrice = 0.0;
  double? _hoveredPrice;
  bool _isHovering = false;
  Timer? _timer;
  bool _hasError = false;

  // For zoom/pan
  double? _viewMinX, _viewMaxX;

  bool get _hasData => _priceData.isNotEmpty;

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
    final historicalPrices = await fetchHistoricalPrices(widget.coinGeckoCoinId)
        .catchError((Object _) => <int, double>{});

    if (historicalPrices.isNotEmpty) {
      final historicalData = historicalPrices.entries
          .map(
            (entry) => FlSpot(entry.key.toDouble(), entry.value),
          )
          .toList();

      setState(() {
        _priceData = historicalData;
        _latestPrice = _priceData.last.y;
        _previousPrice = _priceData.first.y;

        // Set initial zoom window (show last 30 points)
        final totalPoints = _priceData.length;
        _viewMinX = totalPoints > 30
            ? _priceData[totalPoints - 30].x
            : _priceData.first.x;
        _viewMaxX = _priceData.last.x;
        _hasError = false;
      });
    } else {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _startLiveUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final coinPrices =
          await fetchCoinsMarketData(coinIds: [widget.coinGeckoCoinId]);

      if (coinPrices.isNotEmpty) {
        final newPrice =
            coinPrices[widget.tokenSymbol.toLowerCase()]?.currentPrice ?? 0.0;
        _addNewPricePoint(newPrice);
      }
    });
  }

  void _addNewPricePoint(double newPrice) {
    setState(() {
      final newTime = _priceData.isEmpty ? 0 : _priceData.last.x + 60;
      _priceData.add(FlSpot(newTime.toDouble(), newPrice));
      _latestPrice = newPrice;

      // Keep the latest 50 points for display
      if (_priceData.length > 50) {
        _priceData.removeAt(0);
      }
      // Move view window with new points (keep last 30 in view)
      final totalPoints = _priceData.length;
      _viewMinX = totalPoints > 30
          ? _priceData[totalPoints - 30].x
          : _priceData.first.x;
      _viewMaxX = _priceData.last.x;
    });
  }

  double get _displayPrice =>
      _isHovering && _hoveredPrice != null ? _hoveredPrice! : _latestPrice;

  double get priceChange => _displayPrice - _previousPrice;

  double get priceChangePercent =>
      _previousPrice > 0 ? (priceChange / _previousPrice) * 100 : 0;

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('h:mm a').format(dateTime);
  }

  void _onHover(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (touchResponse == null ||
        touchResponse.lineBarSpots == null ||
        touchResponse.lineBarSpots!.isEmpty) {
      setState(() {
        _isHovering = false;
        _hoveredPrice = null;
      });
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
      _hoveredPrice = null;
    });
  }

  // --- ZOOM/PAN ---
  void _zoomIn() {
    if (!_hasData) return;
    final range = (_viewMaxX! - _viewMinX!) * 0.8;
    final mid = (_viewMaxX! + _viewMinX!) / 2;
    setState(() {
      _viewMinX = max(_priceData.first.x, mid - range / 2);
      _viewMaxX = min(_priceData.last.x, mid + range / 2);
    });
  }

  void _zoomOut() {
    if (!_hasData) return;
    final range = (_viewMaxX! - _viewMinX!) / 0.8;
    final mid = (_viewMaxX! + _viewMinX!) / 2;
    setState(() {
      _viewMinX = max(_priceData.first.x, mid - range / 2);
      _viewMaxX = min(_priceData.last.x, mid + range / 2);
    });
  }

  void _panLeft() {
    if (!_hasData) return;
    final step = (_viewMaxX! - _viewMinX!) * 0.2;
    setState(() {
      _viewMinX = max(_priceData.first.x, _viewMinX! - step);
      _viewMaxX = max(_viewMinX! + 1, _viewMaxX! - step);
    });
  }

  void _panRight() {
    if (!_hasData) return;
    final step = (_viewMaxX! - _viewMinX!) * 0.2;
    setState(() {
      _viewMinX = min(_priceData.last.x - 1, _viewMinX! + step);
      _viewMaxX = min(_priceData.last.x, _viewMaxX! + step);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokenDecimals = _displayPrice >= 1 ? 2 : 6;
    final formattedPrice = NumberFormat.currency(
      locale: "en_US",
      symbol: "\$",
      decimalDigits: tokenDecimals,
    ).format(_displayPrice);

    bool isUptrend = _latestPrice >= _previousPrice;
    Color fillColor = isUptrend
        ? GeniusWalletColors.brandGreen
        : GeniusWalletColors.statusError;

    return MouseRegion(
      onExit: _onHoverExit,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AutoSizeText(
            _hasData ? formattedPrice : 'Loading...',
            maxLines: 1,
            style: TextStyle(
              fontSize: widget.priceHeight ?? 48,
              fontWeight: FontWeight.bold,
              color: GeniusWalletColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          if (_hasData)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${priceChange >= 0 ? "+" : ""}\$${priceChange.toStringAsFixed(tokenDecimals)}",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: fillColor,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GeniusWalletConsts.space4,
                      vertical: GeniusWalletConsts.space2),
                  decoration: BoxDecoration(
                    color: fillColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: fillColor,
                    ),
                  ),
                ),
              ],
            ),
          if (widget.child != null) ...[
            const SizedBox(height: GeniusWalletConsts.space12),
            widget.child!,
            const SizedBox(height: GeniusWalletConsts.space12),
          ],
          const SizedBox(height: GeniusWalletConsts.space12),
          _hasData
              ? Column(
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: widget.chartHeight ??
                            MediaQuery.of(context).size.height * 0.25,
                        minHeight: 120,
                      ),
                      child: LineChart(
                        LineChartData(
                          minX: _viewMinX ?? 0,
                          maxX: _viewMaxX ??
                              (_priceData.isNotEmpty ? _priceData.last.x : 1),
                          minY: _priceData.map((e) => e.y).reduce(min) * 0.99,
                          maxY: _priceData.map((e) => e.y).reduce(max) * 1.01,
                          lineBarsData: [
                            LineChartBarData(
                              spots: _priceData,
                              isCurved: true,
                              curveSmoothness: 0.22,
                              color: GeniusWalletColors.textPrimary,
                              barWidth: 2.5,
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    fillColor.withValues(alpha: 0.2),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              dotData: const FlDotData(show: false),
                            ),
                          ],
                          gridData: const FlGridData(show: false),
                          borderData: FlBorderData(show: false),
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
                          lineTouchData: LineTouchData(
                            enabled: true,
                            handleBuiltInTouches: true,
                            touchCallback: _onHover,
                            getTouchedSpotIndicator: (barData, spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: GeniusWalletColors.textSecondary,
                                    strokeWidth: 1.2,
                                    dashArray: [8, 4],
                                  ),
                                  const FlDotData(show: false),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              fitInsideHorizontally: true,
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  return LineTooltipItem(
                                    '${_formatTime(spot.x.toInt())}\n\$${spot.y.toStringAsFixed(tokenDecimals)}',
                                    TextStyle(
                                        color: GeniusWalletColors.textPrimary,
                                        fontWeight: FontWeight.bold),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    // --- ZOOM/PAN BUTTONS ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.zoom_in,
                              color: GeniusWalletColors.textPrimary),
                          onPressed: _zoomIn,
                          tooltip: "Zoom In",
                        ),
                        IconButton(
                          icon: Icon(Icons.zoom_out,
                              color: GeniusWalletColors.textPrimary),
                          onPressed: _zoomOut,
                          tooltip: "Zoom Out",
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios,
                              color: GeniusWalletColors.textPrimary, size: 18),
                          onPressed: _panLeft,
                          tooltip: "Pan Left",
                        ),
                        IconButton(
                          icon: Icon(Icons.arrow_forward_ios,
                              color: GeniusWalletColors.textPrimary, size: 18),
                          onPressed: _panRight,
                          tooltip: "Pan Right",
                        ),
                      ],
                    ),
                  ],
                )
              : _hasError
                  ? SizedBox(
                      height: widget.chartHeight ??
                          MediaQuery.of(context).size.height * 0.25,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.show_chart_outlined,
                                color: GeniusWalletColors.textSecondary,
                                size: 28),
                            const SizedBox(height: GeniusWalletConsts.space4),
                            const Text(
                              "Couldn't load chart",
                              style: TextStyle(
                                  color: GeniusWalletColors.textSecondary),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() => _hasError = false);
                                _fetchHistoricalData();
                              },
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox(
                      height: widget.chartHeight ??
                          MediaQuery.of(context).size.height * 0.25,
                      child: Center(
                        child: PulsingSkeleton(
                          height: widget.chartHeight ??
                              MediaQuery.of(context).size.height * 0.25,
                          width: double.infinity,
                        ),
                      ),
                    ),
        ],
      ),
    );
  }
}
