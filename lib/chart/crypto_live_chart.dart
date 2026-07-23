import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/pulsing_skeleton.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

/// Price font size for the compact (height-starved) chart card, snapped to
/// whole pixels.
///
/// The snapping is the point, not a rounding nicety. Derived straight from the
/// available height, this size changes with every pixel the window moves, so a
/// drag-resize hands skia's ParagraphCache a distinct TextStyle — a distinct
/// cache key — on every single frame. That cache is a fixed-size LRU: it then
/// misses on every lookup, evicts on every insert, and the layout never
/// settles. On macOS the frame is never committed, the platform thread stays
/// blocked in ResizeSynchronizer.beginResize, and the app freezes for good
/// (100% of one core, isolate past any safepoint) until it is killed.
/// Whole-pixel steps bound the number of distinct keys a drag can produce.
///
/// ponytail: whole pixels are the coarsest step that is still visually
/// continuous, so the price nudges in 1px jumps mid-drag. If that ever reads
/// as janky, the upgrade path is a small set of named sizes (28/20/14) chosen
/// by height band — fewer keys still, at the cost of visible steps.
double compactPriceFontSize({
  required double maxHeight,
  required double priceHeight,
  required bool isCompact,
}) {
  if (!isCompact) return priceHeight;
  // floor, never round: rounding up can exceed the 0.45 budget the caller's
  // overflow assert depends on.
  return min(priceHeight, maxHeight * 0.45).floorToDouble();
}

class CryptoLiveChart extends StatefulWidget {
  final String coinGeckoCoinId;
  final String tokenSymbol;
  final Widget? child;
  final double priceHeight;

  const CryptoLiveChart({
    super.key,
    required this.coinGeckoCoinId,
    required this.tokenSymbol,
    this.priceHeight = 48,
    this.child,
  });

  @override
  CryptoLiveChartState createState() => CryptoLiveChartState();
}

class CryptoLiveChartState extends State<CryptoLiveChart> {
  List<FlSpot> _priceData = [];
  double _latestPrice = 0.0;
  double _oldestPrice = 0.0;
  double? _hoveredPrice;
  bool _isHovering = false;
  Timer? _timer;

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
    final historicalPrices = await fetchHistoricalPrices(
      widget.coinGeckoCoinId,
    );

    if (historicalPrices.isNotEmpty) {
      final historicalData = historicalPrices.entries
          .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
          .toList();

      if (!mounted) return;
      setState(() {
        _priceData = historicalData;
        _latestPrice = _priceData.last.y;
        _oldestPrice = _priceData.first.y;

        // Set initial zoom window (show last 50 points)
        final totalPoints = _priceData.length;
        _viewMinX = totalPoints > 50
            ? _priceData[totalPoints - 50].x
            : _priceData.first.x;
        _viewMaxX = _priceData.last.x;
      });
    }
  }

  void _startLiveUpdates() {
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) async {
      final coinPrices = await fetchCoinsMarketData(
        coinIds: [widget.coinGeckoCoinId],
      );

      if (coinPrices.isNotEmpty) {
        final newPrice =
            coinPrices[widget.tokenSymbol.toLowerCase()]?.currentPrice ?? 0.0;
        _addNewPricePoint(newPrice);
      }
    });
  }

  void _addNewPricePoint(double newPrice) {
    if (!mounted) return;
    setState(() {
      final newTime = DateTime.now().millisecondsSinceEpoch / 1000.0;
      _priceData.add(FlSpot(newTime.toDouble(), newPrice));
      _latestPrice = newPrice;

      // Keep the latest 50 points for display
      if (_priceData.length > 50) {
        _priceData.removeAt(0);
      }
      // Move view window with new points (keep last 50 in view)
      final totalPoints = _priceData.length;
      _viewMinX = totalPoints > 50
          ? _priceData[totalPoints - 50].x
          : _priceData.first.x;
      _viewMaxX = _priceData.last.x;
    });
  }

  double get _displayPrice =>
      _isHovering && _hoveredPrice != null ? _hoveredPrice! : _latestPrice;

  double get priceChange => _displayPrice - _oldestPrice;

  double get priceChangePercent =>
      _oldestPrice > 0 ? (priceChange / _oldestPrice) * 100 : 0;

  /// Per-point % change vs [_oldestPrice] — same series the hero price uses,
  /// reused by the hover tooltip so each touched point gets its own %.
  double _percentAt(double price) =>
      _oldestPrice > 0 ? ((price - _oldestPrice) / _oldestPrice) * 100 : 0;

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
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final tokenDecimals = _displayPrice >= 1 ? 2 : 6;
    final formattedPrice = NumberFormat.currency(
      symbol: "\$",
      decimalDigits: tokenDecimals,
    ).format(_displayPrice);

    bool isUptrend = _latestPrice >= _oldestPrice;
    // Trend tints the % pill only; the chart itself is always mint
    // (see `mintColor` below), decoupled from up/down.
    final Color trendColor = isUptrend ? gw.statusSuccess : gw.statusError;
    final Color mintColor = GeniusWalletColors.brandSecondary;

    return MouseRegion(
      onExit: _onHoverExit,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isHeightBounded = constraints.maxHeight != double.infinity;

          // ponytail: one fixed threshold (priceHeight * 3.5) decides compact
          // mode, instead of measuring the actual header height, so the
          // change row pops in/out abruptly at exactly that boundary rather
          // than shrinking continuously. Upgrade path: measure the price +
          // change row with a TextPainter and branch on the real height.
          final bool isCompact =
              isHeightBounded && constraints.maxHeight < widget.priceHeight * 3.5;
          final double priceFontSize = compactPriceFontSize(
            maxHeight: constraints.maxHeight,
            priceHeight: widget.priceHeight,
            isCompact: isCompact,
          );
          assert(
            !isCompact || priceFontSize * 1.5 <= constraints.maxHeight,
            'Compact price font must leave room for its own line metrics '
            'within the available height, or the Column can overflow.',
          );

          final chartContent = Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: isCompact ? 0 : 2,
            children: [
              // Hero price over a soft cyan glow. The glow is a Positioned/
              // IgnorePointer overlay behind the price — layout-neutral, so it
              // adds no height to this Column and cannot re-open the compact
              // overflow the 260720-uhe task closed.
              Stack(
                alignment: Alignment.center,
                // Without Clip.none the Stack clips to the price text's tight
                // bounds and cuts the blurred glow halo — the reason it read as
                // absent. Clip.none lets the glow bleed out behind the price.
                clipBehavior: Clip.none,
                children: [
                  // Positioned.fill keeps this layer at the price's size (so it
                  // adds NO height — the uhe overflow guard stays intact), while
                  // OverflowBox lets the glow paint larger (280x96) and CENTERED
                  // behind the price. A bare Positioned(width,height) did not
                  // reliably center and the glow rendered off the price.
                  Positioned.fill(
                    child: IgnorePointer(
                      child: OverflowBox(
                        maxWidth: 280,
                        maxHeight: 96,
                        child: ImageFiltered(
                          imageFilter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: RadialGradient(
                                colors: [
                                  GeniusWalletColors.brandPrimary.withValues(
                                    alpha: 0.42,
                                  ),
                                  Colors.transparent,
                                ],
                                stops: const [0.0, 0.75],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Text, not AutoSizeText. `priceFontSize` is already snapped
                  // to a bounded set by [compactPriceFontSize] (37639d5), but
                  // that only bounded the HEIGHT-derived input: AutoSizeText
                  // then ran its own search to fit the available WIDTH, which
                  // a drag-resize also varies continuously — so it kept
                  // minting a distinct TextStyle per frame and the
                  // ParagraphCache thrash the commit set out to kill survived.
                  // The regression guard missed it because it tests the pure
                  // function, not this widget. Ellipsis over shrink-to-fit.
                  Text(
                    _hasData ? formattedPrice : 'Loading...',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: priceFontSize,
                      fontWeight: FontWeight.bold,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (_hasData && !isCompact)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GeniusWalletConsts.space4,
                    vertical: GeniusWalletConsts.space2,
                  ),
                  decoration: BoxDecoration(
                    color: trendColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(
                      GeniusWalletConsts.radiusXs,
                    ),
                  ),
                  child: Text(
                    "${priceChangePercent >= 0 ? "+" : ""}${priceChangePercent.toStringAsFixed(2)}%",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                ),
              if (widget.child != null) widget.child!,
              if (_hasData)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: LineChart(
                          LineChartData(
                            clipData: const FlClipData.all(),
                            minX: _viewMinX ?? 0,
                            maxX:
                                _viewMaxX ??
                                (_priceData.isNotEmpty ? _priceData.last.x : 1),
                            minY:
                                _priceData.map((e) => e.y).reduce(min) * 0.999,
                            maxY:
                                _priceData.map((e) => e.y).reduce(max) * 1.001,
                            lineBarsData: [
                              LineChartBarData(
                                spots: _priceData,
                                isCurved: false,
                                color: mintColor,
                                barWidth: 2.4,
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    colors: [
                                      mintColor.withValues(alpha: 0.3),
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
                            lineTouchData: LineTouchData(
                              enabled: true,
                              handleBuiltInTouches: true,
                              touchCallback: _onHover,
                              getTouchedSpotIndicator: (barData, spotIndexes) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: gw.borderStrong,
                                      strokeWidth: 1,
                                    ),
                                    FlDotData(
                                      getDotPainter:
                                          (spot, percent, bar, index) =>
                                              FlDotCirclePainter(
                                                radius: 5,
                                                color: mintColor,
                                                strokeWidth: 4,
                                                strokeColor: mintColor
                                                    .withValues(alpha: 0.26),
                                              ),
                                    ),
                                  );
                                }).toList();
                              },
                              touchTooltipData: LineTouchTooltipData(
                                fitInsideHorizontally: true,
                                fitInsideVertically: true,
                                tooltipBorderRadius: BorderRadius.circular(10),
                                tooltipBorder: BorderSide(
                                  color: gw.borderSubtle,
                                ),
                                getTooltipColor: (touchedSpot) =>
                                    gw.surfaceElevated,
                                // ponytail: fl_chart's LineTouchTooltipData has
                                // no first-class drop-shadow like the sketch's
                                // .tip bubble (only color + border + radius).
                                // Ceiling: no shadow under the bubble. Upgrade
                                // path: a custom overlay-positioned tooltip
                                // widget if the shadow is ever needed.
                                getTooltipItems: (touchedSpots) {
                                  return touchedSpots.map((spot) {
                                    final pointPercent = _percentAt(spot.y);
                                    final pointTrendColor = pointPercent >= 0
                                        ? gw.statusSuccess
                                        : gw.statusError;
                                    return LineTooltipItem(
                                      '${_formatTime(spot.x.toInt())}\n',
                                      TextStyle(
                                        color: gw.textSecondary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: NumberFormat.currency(
                                            symbol: "\$",
                                            decimalDigits: tokenDecimals,
                                          ).format(spot.y),
                                          style: TextStyle(
                                            color: gw.textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              '  ${pointPercent >= 0 ? "+" : ""}${pointPercent.toStringAsFixed(2)}%',
                                          style: TextStyle(
                                            color: pointTrendColor,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList();
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.zoom_in,
                              color: Colors.white,
                            ),
                            onPressed: _zoomIn,
                            tooltip: "Zoom In",
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.zoom_out,
                              color: Colors.white,
                            ),
                            onPressed: _zoomOut,
                            tooltip: "Zoom Out",
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: _panLeft,
                            tooltip: "Pan Left",
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 18,
                            ),
                            onPressed: _panRight,
                            tooltip: "Pan Right",
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                const Expanded(
                  child: Center(child: PulsingSkeleton(width: double.infinity)),
                ),
            ],
          );

          // When height is unbounded (e.g. inside a ListView), use a
          // sensible default height so the chart has room to render.
          if (!isHeightBounded) {
            return SizedBox(
              height: constraints.maxWidth * 0.6,
              child: chartContent,
            );
          }

          return chartContent;
        },
      ),
    );
  }
}
