import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/chart/chart_axis.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/gw_timeframe_segment.dart';
import 'package:genius_wallet/components/pulsing_skeleton.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
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
  if (!isCompact) {
    return priceHeight;
  }
  // floor, never round: rounding up can exceed the 0.45 budget the caller's
  // overflow assert depends on.
  return min(priceHeight, maxHeight * 0.45).floorToDouble();
}

/// The chart's vertical window, as `(minY, maxY)`.
///
/// **It is computed over the points inside the CURRENT X view, and that is the
/// whole fix.** It used to reduce over the entire series while the X window
/// showed only the last 50 points (`_fetchHistoricalData` sets it that way), so
/// the ruler was set by prices that were not on screen. On a coin sitting 98%
/// below its all-time high, that turns the visible slice into a flat line
/// pinned to the bottom of the card - Jakub, 2026-07-28: *"ten chart jest
/// bardzo płaski"*. The data was not flat; the scale was wrong.
///
/// The old padding was `* 0.999` / `* 1.001`, which is effectively none, so the
/// line also ran edge to edge. 8% of the visible span on each side gives the
/// curve somewhere to move while still filling ~86% of the height.
///
/// A genuinely flat slice - one point, or a stablecoin that has not moved - has
/// zero span and cannot be scaled at all, so it falls back to ±1% of the value
/// and the line lands mid-card instead of fl_chart dividing by zero. That case
/// is not hypothetical: it is every chart between the first paint and the
/// second live tick.
///
/// Top-level and pure so the rule can be tested. A y-window bug looks like a
/// working chart in every screenshot - this one shipped that way.
(double, double) chartYBounds(
  List<FlSpot> data, {
  double? viewMinX,
  double? viewMaxX,
}) {
  if (data.isEmpty) {
    return (0, 1);
  }

  final lo = viewMinX ?? data.first.x;
  final hi = viewMaxX ?? data.last.x;

  var visible = data
      .where((s) => s.x >= lo && s.x <= hi)
      .map((s) => s.y)
      .toList();
  // Pan/zoom cannot empty this, but a bad window should degrade to the whole
  // series rather than throw out of `reduce`.
  if (visible.isEmpty) {
    visible = data.map((s) => s.y).toList();
  }

  final lowest = visible.reduce(min);
  final highest = visible.reduce(max);
  final span = highest - lowest;

  if (span <= 0) {
    final pad = highest.abs() * 0.01;
    return (lowest - (pad > 0 ? pad : 1), highest + (pad > 0 ? pad : 1));
  }
  return (lowest - span * 0.08, highest + span * 0.08);
}

class CryptoLiveChart extends StatefulWidget {
  final String coinGeckoCoinId;
  final String tokenSymbol;
  final Widget? child;
  final double priceHeight;

  /// When false, the chart renders its OWN compact header — price, %, the
  /// hovered sample's time, and the timeframe segment — above the plot,
  /// instead of the built-in hero price + 24h% pill. The rule is one
  /// sentence, and it holds at both call sites today: **either the host owns
  /// the chart's chrome, or the chart does.** The coin page passes
  /// `showPriceHeader: false` and has no chrome of its own
  /// (`token_info_screen.dart:416-423`); the dashboard leaves it true and its
  /// `_ChartSectionHeader` already carries both the identity and a timeframe
  /// segment, so it must NOT get a second one. Defaults to true so every
  /// existing caller renders byte-for-behavior identically.
  final bool showPriceHeader;

  const CryptoLiveChart({
    super.key,
    required this.coinGeckoCoinId,
    required this.tokenSymbol,
    this.priceHeight = 48,
    this.child,
    this.showPriceHeader = true,
  });

  @override
  CryptoLiveChartState createState() => CryptoLiveChartState();
}

class CryptoLiveChartState extends State<CryptoLiveChart> {
  List<FlSpot> _priceData = [];
  double _latestPrice = 0.0;
  double _oldestPrice = 0.0;
  double? _hoveredPrice;
  double? _hoveredX;
  bool _isHovering = false;
  Timer? _timer;

  // Set once the first fetch resolves (success, empty, or error) so the empty
  // state can distinguish "still loading" from "the fetch came back with
  // nothing" — before this flag, an empty/failed response pulsed the loading
  // skeleton forever.
  bool _loadAttempted = false;

  // The visible X window. No zoom/pan controls drive this anymore (the four
  // buttons were replaced by the timeframe segment, 078-S1) — it still
  // initialises to "the last 50 points" and moves with each live tick, which
  // is what `chartYBounds`, `minX` and `maxX` read.
  double? _viewMinX, _viewMaxX;

  bool get _hasData => _priceData.isNotEmpty;

  (double, double) _yBounds() =>
      chartYBounds(_priceData, viewMinX: _viewMinX, viewMaxX: _viewMaxX);

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
    try {
      final historicalPrices = await fetchHistoricalPrices(
        widget.coinGeckoCoinId,
      );

      if (historicalPrices.isNotEmpty) {
        final historicalData = historicalPrices.entries
            .map((entry) => FlSpot(entry.key.toDouble(), entry.value))
            .toList();

        if (!mounted) {
          return;
        }
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
    } catch (_) {
      // The user-visible state is a fixed "No price history" string (see
      // `_loadAttempted` below) — nothing about the caught error is rendered
      // or logged. No key, mnemonic or seed-derived value is anywhere near
      // this code path, but the rule holds regardless: never log a caught
      // network error into anything that could later carry wallet data.
    } finally {
      if (mounted) {
        setState(() {
          _loadAttempted = true;
        });
      }
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
    if (!mounted) {
      return;
    }
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
  /// reused by the header readout so the hovered point gets its own %.
  double _percentAt(double price) =>
      _oldestPrice > 0 ? ((price - _oldestPrice) / _oldestPrice) * 100 : 0;

  String _formatTime(int timestamp) {
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('h:mm a').format(dateTime);
  }

  /// The hovered sample's time, or `Latest` when nothing is hovered — the
  /// header readout's third field on both the built-in and the chart-owned
  /// header.
  String get _hoverTimeLabel => _isHovering && _hoveredX != null
      ? _formatTime(_hoveredX!.round())
      : 'Latest';

  void _onHover(FlTouchEvent event, LineTouchResponse? touchResponse) {
    if (touchResponse == null ||
        touchResponse.lineBarSpots == null ||
        touchResponse.lineBarSpots!.isEmpty) {
      setState(() {
        _isHovering = false;
        _hoveredPrice = null;
        _hoveredX = null;
      });
      return;
    }

    final hoveredSpot = touchResponse.lineBarSpots!.first;
    setState(() {
      _isHovering = true;
      _hoveredPrice = hoveredSpot.y;
      _hoveredX = hoveredSpot.x;
    });
  }

  void _onHoverExit(PointerExitEvent event) {
    setState(() {
      _isHovering = false;
      _hoveredPrice = null;
      _hoveredX = null;
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

    final bool isUptrend = _latestPrice >= _oldestPrice;
    // Trend colour now reaches the line, its gradient AND the touched dot
    // (078-S2) — not just the % pill. Reversed from an earlier "always mint"
    // call, made the same session it was proposed: mint was picked because
    // the % pill already states direction, but the Markets sparklines colour
    // by sign ON PURPOSE, to mirror the Assets panel
    // (`crypto_simple_chart.dart:53-55`, "Assets-mirror up/down"). An
    // always-mint line here would have sat directly above red sparklines
    // reporting the same fact. One rule now covers every surface.
    final Color trendColor = isUptrend ? gw.statusSuccess : gw.statusError;

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
              isHeightBounded &&
              constraints.maxHeight < widget.priceHeight * 3.5;
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
              // Either the host owns the chart's chrome (showPriceHeader
              // true — the built-in hero price + % pill below), or the chart
              // does (showPriceHeader false — its own compact header row).
              // Never both.
              if (widget.showPriceHeader) ...[
                // Hero price over a soft cyan glow. The glow is a Positioned/
                // IgnorePointer overlay behind the price — layout-neutral, so
                // it adds no height to this Column and cannot re-open the
                // compact overflow the 260720-uhe task closed.
                Stack(
                  alignment: Alignment.center,
                  // Without Clip.none the Stack clips to the price text's
                  // tight bounds and cuts the blurred glow halo — the reason
                  // it read as absent. Clip.none lets the glow bleed out
                  // behind the price.
                  clipBehavior: Clip.none,
                  children: [
                    // Positioned.fill keeps this layer at the price's size
                    // (so it adds NO height — the uhe overflow guard stays
                    // intact), while OverflowBox lets the glow paint larger
                    // (280x96) and CENTERED behind the price. A bare
                    // Positioned(width,height) did not reliably center and
                    // the glow rendered off the price.
                    Positioned.fill(
                      child: IgnorePointer(
                        child: OverflowBox(
                          maxWidth: 280,
                          maxHeight: 96,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: 14,
                              sigmaY: 14,
                            ),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: RadialGradient(
                                  colors: [
                                    context.gw.brandPrimary.withValues(
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
                    // Text, not AutoSizeText. `priceFontSize` is already
                    // snapped to a bounded set by [compactPriceFontSize]
                    // (37639d5), but that only bounded the HEIGHT-derived
                    // input: AutoSizeText then ran its own search to fit the
                    // available WIDTH, which a drag-resize also varies
                    // continuously — so it kept minting a distinct TextStyle
                    // per frame and the ParagraphCache thrash the commit set
                    // out to kill survived. The regression guard missed it
                    // because it tests the pure function, not this widget.
                    // Ellipsis over shrink-to-fit.
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
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
                      // The hovered sample's time — or `Latest` — as a
                      // sibling in the SAME row as the pill, so it adds ZERO
                      // height: this card is height-starved (files
                      // RenderFlex overflows at boot) and the `isCompact`
                      // assert above depends on the header's existing
                      // budget.
                      const SizedBox(width: GeniusWalletConsts.space4),
                      Text(
                        _hoverTimeLabel,
                        style: TextStyle(fontSize: 11, color: gw.textSecondary),
                      ),
                    ],
                  ),
              ] else
                _ChartHeaderRow(
                  hasData: _hasData,
                  formattedPrice: _hasData ? formattedPrice : 'Loading...',
                  percentChange: _percentAt(_displayPrice),
                  trendColor: trendColor,
                  timeLabel: _hoverTimeLabel,
                ),
              if (widget.child != null) widget.child!,
              if (_hasData)
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, plotConstraints) {
                      final (yLo, yHi) = _yBounds();
                      // The box THIS measures is the PLOT box, not the card:
                      // the card's padding and header row are already spent
                      // by the time this builder runs. A measurement, not a
                      // per-surface parameter (078-S4) — `ChartDashboardView`
                      // is rendered at dashboard_screen.dart:223
                      // (two-column), :273 (three-column) and :303
                      // (one-column, capped at 350); the two-column call site
                      // is `(viewport - 324) / 2` with no floor at all, so a
                      // parameter would silently re-break the moment a layout
                      // moved.
                      if (chartUsesFrame(plotConstraints.maxHeight)) {
                        return _TradingFrameChart(
                          data: _priceData,
                          viewMinX: _viewMinX,
                          viewMaxX: _viewMaxX,
                          yBounds: (yLo, yHi),
                          trendColor: trendColor,
                          gw: gw,
                          onHover: _onHover,
                          formatTime: _formatTime,
                          plotHeight: plotConstraints.maxHeight,
                        );
                      }
                      return _SparklineChart(
                        data: _priceData,
                        viewMinX: _viewMinX,
                        viewMaxX: _viewMaxX,
                        yBounds: (yLo, yHi),
                        trendColor: trendColor,
                        gw: gw,
                        onHover: _onHover,
                        plotHeight: plotConstraints.maxHeight,
                      );
                    },
                  ),
                )
              else if (_loadAttempted)
                const Expanded(
                  child: GWEmptyState(
                    icon: Icons.show_chart,
                    title: 'No price history',
                    message:
                        'The market data provider returned no series for '
                        'this range.',
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

/// The chart's OWN compact header (used when `showPriceHeader` is false —
/// today, the coin page). Replaces the old zoom/pan button row, which is
/// where this used to sit visually (below the plot); this sits ABOVE it.
/// Left to right: price, signed %, the hovered sample's time (or `Latest`),
/// then the timeframe segment. A `StatelessWidget`, never a `_buildFoo()`
/// helper (`AGENTS.md`).
class _ChartHeaderRow extends StatelessWidget {
  const _ChartHeaderRow({
    required this.hasData,
    required this.formattedPrice,
    required this.percentChange,
    required this.trendColor,
    required this.timeLabel,
  });

  final bool hasData;
  final String formattedPrice;
  final double percentChange;
  final Color trendColor;
  final String timeLabel;

  // Below this card width, the five-tab timeframe segment and a six-figure
  // price cannot both fit alongside every readout field, so the hovered
  // timestamp drops and the price steps down one size — the same rule
  // `.chartcard.narrow` codifies in the sketch, measured there at the 366px
  // mobile card (`.planning/sketches/078-chart-restyle/index.html:65-71`).
  static const double _narrowWidth = 420;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool narrow = constraints.maxWidth < _narrowWidth;
        // The readouts take ONE `Expanded`; the segment takes what is left.
        //
        // This was a loose `Flexible` for the price followed by a `Spacer`, and
        // that is the identical defect `gw_page_header.dart` was fixed for on
        // 2026-07-29: both default to `flex: 1`, so they split the row's free
        // space 50/50. A price that does not spend its half does not hand the
        // remainder back — `RenderFlex` distributes the shortfall by
        // `MainAxisAlignment`, which defaults to `start`, so it lands AFTER the
        // last child. The segment was therefore parked short of the right edge
        // with a band of dead space beyond it, which is exactly what the walk
        // caught ("time frame to the right"). One flex child cannot mis-split
        // anything.
        return Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  Flexible(
                    child: Text(
                      formattedPrice,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: narrow ? 15 : 17,
                        fontWeight: FontWeight.bold,
                        color: gw.textPrimary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                  if (hasData) ...[
                    const SizedBox(width: GeniusWalletConsts.space4),
                    Text(
                      "${percentChange >= 0 ? "+" : ""}${percentChange.toStringAsFixed(2)}%",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: trendColor,
                      ),
                    ),
                    if (!narrow) ...[
                      const SizedBox(width: GeniusWalletConsts.space4),
                      Flexible(
                        child: Text(
                          timeLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: gw.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space4),
            const GWTimeframeSegment(),
          ],
        );
      },
    );
  }
}

/// Scheme B, the trading frame (078-S1): a right Y axis on nice-rounded
/// ticks, horizontal-only gridlines on those same values, and a bottom time
/// row. Chosen at runtime by `chartUsesFrame` — see the `LayoutBuilder` in
/// [CryptoLiveChartState.build]. Kept as its own `StatelessWidget` (rather
/// than a branch in one build method) so the DevTools inspector can tell it
/// apart from [_SparklineChart] and neither rebuilds the other.
class _TradingFrameChart extends StatelessWidget {
  const _TradingFrameChart({
    required this.data,
    required this.viewMinX,
    required this.viewMaxX,
    required this.yBounds,
    required this.trendColor,
    required this.gw,
    required this.onHover,
    required this.formatTime,
    required this.plotHeight,
  });

  final List<FlSpot> data;
  final double? viewMinX;
  final double? viewMaxX;
  final (double, double) yBounds;
  final Color trendColor;
  final GWColors gw;
  final void Function(FlTouchEvent, LineTouchResponse?) onHover;
  final String Function(int) formatTime;
  final double plotHeight;

  @override
  Widget build(BuildContext context) {
    final (yLo, yHi) = yBounds;
    final minX = viewMinX ?? (data.isNotEmpty ? data.first.x : 0);
    final maxX = viewMaxX ?? (data.isNotEmpty ? data.last.x : 1);
    var visible = data.where((s) => s.x >= minX && s.x <= maxX).toList();
    if (visible.isEmpty) {
      visible = data;
    }

    // Grid lines and side titles BOTH iterate from the axis baseline by
    // `interval` (`axis_chart_helper.dart`, `side_titles_widget.dart:161`),
    // so handing them the SAME step makes every label land on a gridline by
    // construction — no tick values are drawn by hand.
    final (_, step) = chartTickStep(
      yLo,
      yHi,
      chartYTickCount(plotHeight - kChartTimeRowHeight),
    );

    return Column(
      children: [
        Expanded(
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              minX: minX,
              maxX: maxX,
              minY: yLo,
              maxY: yHi,
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: false,
                  color: trendColor,
                  barWidth: 2,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        trendColor.withValues(alpha: 0.18),
                        trendColor.withValues(alpha: 0.0),
                      ],
                      // fl_chart shades this gradient over
                      // `belowBarLargestRect` (top of the highest spot -> the
                      // plot floor) — the SAME box the sketch's SVG
                      // `objectBoundingBox` gradient spanned, so 0.62 ports
                      // 1:1. Do not "fix" this stop later without re-deriving
                      // that equivalence.
                      stops: const [0.0, kChartFillFadeStop],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  dotData: const FlDotData(show: false),
                ),
              ],
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: step,
                getDrawingHorizontalLine: (_) => FlLine(
                  // 6% is a legitimate choice, not a shortcut: WCAG 1.4.11's
                  // own Understanding document exempts graduated (grid)
                  // lines from the 3:1 gate, and no design system publishes
                  // a numeric dark-mode gridline opacity. Derived from the
                  // token rather than a colour literal so it stays correct
                  // in both appearance modes.
                  color: gw.borderSubtle.withValues(alpha: 0.06),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                // On the RIGHT because on a time series the newest value sits
                // at the right edge and would otherwise be furthest from its
                // own scale — a strong de-facto convention, NOT a documented
                // standard (Highcharts still defaults yAxis to the left).
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: kChartAxisGutter,
                    interval: step,
                    // MUST be false, or fl_chart ALSO prints the raw
                    // 8%-padded minY/maxY, which are not on the nice-number
                    // ladder — an off-ladder label nobody could explain.
                    minIncluded: false,
                    maxIncluded: false,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(
                        axisMoneyLabel(value, step),
                        style: TextStyle(
                          fontSize: 11,
                          color: gw.textSecondary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                enabled: true,
                handleBuiltInTouches: true,
                touchCallback: onHover,
                // Full-height crosshair: the line runs floor to ceiling
                // instead of stopping at the touched spot.
                getTouchLineStart: (barData, index) => yLo,
                getTouchLineEnd: (barData, index) => yHi,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      // borderControl (3.30:1 dark / 3.10:1 light) clears
                      // WCAG 1.4.11's 3:1 gate for a meaningful graphical
                      // object; borderStrong (2.10:1) did not.
                      FlLine(color: gw.borderControl, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              // Same radius/strokeWidth as the shipped dot —
                              // only the colour changes, mint -> trendColor,
                              // ring alpha unchanged (078-S2).
                              radius: 5,
                              color: trendColor,
                              strokeWidth: 4,
                              strokeColor: trendColor.withValues(alpha: 0.26),
                            ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  // The floating bubble is replaced by the card's own header
                  // readout — no box should paint over the data at all.
                  getTooltipColor: (touchedSpot) => Colors.transparent,
                  tooltipBorder: BorderSide.none,
                  tooltipPadding: EdgeInsets.zero,
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.map((_) => null).toList(),
                ),
              ),
            ),
          ),
        ),
        // A plain Row of Texts, NOT fl_chart's bottom titles — fl_chart
        // anchors its x intervals to `baselineX`, which cannot be made to
        // line up with epoch-second sample positions without fighting the
        // library.
        SizedBox(
          height: kChartTimeRowHeight,
          child: Padding(
            padding: const EdgeInsets.only(right: kChartAxisGutter),
            child: LayoutBuilder(
              builder: (context, rowConstraints) {
                final int count = chartXLabelCount(
                  plotWidth: rowConstraints.maxWidth,
                  sampleCount: visible.length,
                );
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(count, (b) {
                    final int ix = count > 1
                        ? ((b / (count - 1)) * (visible.length - 1)).round()
                        : 0;
                    final spot = visible[ix];
                    return Text(
                      formatTime(spot.x.round()),
                      style: TextStyle(
                        fontSize: 11,
                        color: gw.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

/// Scheme A, the axis-free fallback (078-S4, 078-S5): today's geometry, plus
/// reserved 17px label bands so the line can never reach the H/L labels.
///
/// **This is the SECOND attempt at the label-overlap defect, and the first
/// one was wrong.** An opaque plate alone was tried and rejected by Jakub,
/// because the line still ran through the plate — the plate merely hid that
/// stretch of the series. Hiding data behind a caption is not a fix. The
/// bands (`chartBandedBounds`) reserve the gutter in the Y window itself, so
/// no data shape can ever reach a label.
class _SparklineChart extends StatelessWidget {
  const _SparklineChart({
    required this.data,
    required this.viewMinX,
    required this.viewMaxX,
    required this.yBounds,
    required this.trendColor,
    required this.gw,
    required this.onHover,
    required this.plotHeight,
  });

  final List<FlSpot> data;
  final double? viewMinX;
  final double? viewMaxX;
  final (double, double) yBounds;
  final Color trendColor;
  final GWColors gw;
  final void Function(FlTouchEvent, LineTouchResponse?) onHover;
  final double plotHeight;

  @override
  Widget build(BuildContext context) {
    final (bandedLo, bandedHi) = chartBandedBounds(yBounds, plotHeight);
    final minX = viewMinX ?? (data.isNotEmpty ? data.first.x : 0);
    final maxX = viewMaxX ?? (data.isNotEmpty ? data.last.x : 1);

    final extremes = visibleExtremes(
      data,
      viewMinX: viewMinX,
      viewMaxX: viewMaxX,
    );
    // Precision for the H/L labels: derived from the (unbanded) window, the
    // same window-derived rule the axis itself uses — never from the
    // value's magnitude.
    final (yLo, yHi) = yBounds;
    final double labelStep = (yHi - yLo) / 4;

    double fractionOf(double x) {
      if (maxX <= minX) {
        return 0;
      }
      return (((x - minX) / (maxX - minX)) * 2 - 1).clamp(-1.0, 1.0);
    }

    return Stack(
      children: [
        Positioned.fill(
          child: LineChart(
            LineChartData(
              clipData: const FlClipData.all(),
              minX: minX,
              maxX: maxX,
              minY: bandedLo,
              maxY: bandedHi,
              lineBarsData: [
                LineChartBarData(
                  spots: data,
                  isCurved: false,
                  color: trendColor,
                  barWidth: 2.4,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        trendColor.withValues(alpha: 0.18),
                        trendColor.withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, kChartFillFadeStop],
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
                touchCallback: onHover,
                getTouchLineStart: (barData, index) => bandedLo,
                getTouchLineEnd: (barData, index) => bandedHi,
                getTouchedSpotIndicator: (barData, spotIndexes) {
                  return spotIndexes.map((index) {
                    return TouchedSpotIndicatorData(
                      FlLine(color: gw.borderControl, strokeWidth: 1),
                      FlDotData(
                        getDotPainter: (spot, percent, bar, index) =>
                            FlDotCirclePainter(
                              // Same radius/strokeWidth as the shipped dot —
                              // only the colour changes, mint -> trendColor,
                              // ring alpha unchanged (078-S2).
                              radius: 5,
                              color: trendColor,
                              strokeWidth: 4,
                              strokeColor: trendColor.withValues(alpha: 0.26),
                            ),
                      ),
                    );
                  }).toList();
                },
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) => Colors.transparent,
                  tooltipBorder: BorderSide.none,
                  tooltipPadding: EdgeInsets.zero,
                  getTooltipItems: (touchedSpots) =>
                      touchedSpots.map((_) => null).toList(),
                ),
              ),
            ),
          ),
        ),
        if (extremes != null) ...[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: kChartLabelBand,
            child: IgnorePointer(
              child: _HighLowPlate(
                glyph: 'H',
                value: axisMoneyLabel(extremes.$1.y, labelStep),
                fx: fractionOf(extremes.$1.x),
                gw: gw,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: kChartLabelBand,
            child: IgnorePointer(
              child: _HighLowPlate(
                glyph: 'L',
                value: axisMoneyLabel(extremes.$2.y, labelStep),
                fx: fractionOf(extremes.$2.x),
                gw: gw,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// One H/L label plate, pinned proportionally along its own reserved band
/// (`Align` positions it AND keeps it inside the box for free — the sketch's
/// clamp at `index.html:1086`, with no text measurement needed). The plate
/// stays even though the bands now prevent overlap, because the area fill
/// still runs under the bottom band and bare text over a chart has no
/// defined background — its contrast ratio cannot even be computed.
class _HighLowPlate extends StatelessWidget {
  const _HighLowPlate({
    required this.glyph,
    required this.value,
    required this.fx,
    required this.gw,
  });

  final String glyph;
  final String value;
  final double fx;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(fx, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        decoration: BoxDecoration(
          color: gw.surfaceElevated.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          '$glyph $value',
          style: TextStyle(
            fontSize: 10,
            color: gw.textSecondary,
            height: 1,
            letterSpacing: 0.6,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}
