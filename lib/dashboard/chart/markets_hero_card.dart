import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/chart_axis.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart' show chartYBounds;
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// The hero chart's height in the WIDE (`IntrinsicHeight` row) layout.
///
/// **253, and the "falsification" that kept it at 180 was itself wrong.**
/// 078-S6 derived that growing this from 180 to 253 costs the wide card no
/// height, because the `Spacer` at [_MarketsHeroCardState.build] absorbs the
/// difference inside an `IntrinsicHeight` row driven by the taller LEFT column
/// (301 = 46 icon + 20 + 48 price + 16 + 24 pill + 24 + 1 rule + 24 + 39 stat
/// + 20 + 39 stat). `markets_hero_height_test.dart` appeared to refute that:
/// it measured 619.0 at 180 and 692.0 at 253, the full 73px of growth, and the
/// hypothesis was recorded as dead.
///
/// **That test never reached the wide layout.** Its host wraps the card in
/// `SizedBox(width: 1200)` and its comments claim the width exercises the
/// `IntrinsicHeight` branch - but it never set the test surface, which
/// defaults to 800x600, so the `SizedBox` was clamped and the card rendered
/// **stacked**. The stacked branch passes `fill: false`, which omits the
/// `Spacer` and the `IntrinsicHeight` entirely, so of course the card grew by
/// exactly the chart's delta. It was measuring the one layout where the claim
/// was never made.
///
/// Re-measured 2026-07-30 with `tester.view.physicalSize` actually set to
/// 1400x1000: the `IntrinsicHeight` row reports **301.0** - the derivation to
/// the pixel - and the card holds **367.0** at both 180 and 253, with the
/// chart's lower edge landing on the stat row at y=334 either way. The
/// original arithmetic was right; the instrument was wrong.
const double kMarketsHeroChartHeight = 253;

/// The height used when the card STACKS (below `GeniusBreakpoints.medium`).
///
/// Stays at 180 deliberately. The wide layout's 73px is free because a `Spacer`
/// gives it back; the stacked layout has neither `Spacer` nor
/// `IntrinsicHeight`, so every pixel added here is a pixel the card grows on
/// the narrowest screens. 180 is also below `kChartFrameMinHeight`, so the
/// stacked hero keeps the axis-free chart - the same runtime A/B rule the coin
/// page already follows, arrived at by measuring the box rather than by
/// flagging the surface.
const double kMarketsHeroChartHeightStacked = 180;

/// Markets hero (sketch 103 · H1 "Refined split"): identity + oversized price
/// + a 2×2 stat block on the left, the 7d chart with a timeframe selector on
/// the right. All data is read off the already-fetched [CoinGeckoMarketData];
/// nothing here triggers a new request.
class MarketsHeroCard extends StatefulWidget {
  final CoinGeckoCoin coin;
  final CoinGeckoMarketData data;
  final VoidCallback? onTap;

  const MarketsHeroCard({
    super.key,
    required this.coin,
    required this.data,
    this.onTap,
  });

  @override
  State<MarketsHeroCard> createState() => _MarketsHeroCardState();
}

class _MarketsHeroCardState extends State<MarketsHeroCard> {
  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final data = widget.data;
    final up = data.priceChangePercentage24h >= 0;
    final changeColor = up ? gw.statusSuccess : gw.statusError;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // identity
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTokenIcon(iconPath: data.imageUrl, size: 46),
            const SizedBox(width: GeniusWalletConsts.space6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.coin.name,
                  style: GeniusWalletTypography.titleLg.copyWith(
                    color: gw.textPrimary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        // oversized price — a FIXED style (never AutoSizeText): a width-driven
        // font search re-keys skia's ParagraphCache every resize frame and
        // freezes the macOS embedder (see crypto_simple_chart.dart's note).
        Text(
          _price(data.currentPrice),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 48,
            height: 1,
            fontWeight: FontWeight.w700,
            letterSpacing: -2,
            color: gw.textPrimary,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        // % pill + absolute 24h change
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChangePill(
              percent: data.priceChangePercentage24h,
              color: changeColor,
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Flexible(
              child: Text(
                '${_absChange(data)} · 24h',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        Container(height: 1, color: gw.borderSubtle),
        const SizedBox(height: GeniusWalletConsts.space12),
        // 2×2 stat block
        Row(
          children: [
            Expanded(
              child: GWStatTile(label: 'Rank', value: '#${data.marketCapRank}'),
            ),
            Expanded(
              child: GWStatTile(
                label: 'Market Cap',
                value: _compact(data.marketCap),
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        Row(
          children: [
            Expanded(
              child: GWStatTile(
                label: 'Volume 24h',
                value: _compact(data.totalVolume),
              ),
            ),
            Expanded(
              child: GWStatTile(
                label: 'All-Time High',
                value: _price(data.ath),
              ),
            ),
          ],
        ),
      ],
    );

    // Wide layout drops the chart to the BOTTOM of the row so its lower edge
    // lines up with the Volume 24h / All-Time High stat row on the left
    // (Jakub 2026-07-24). A plain `Spacer()` above the fixed-height chart
    // absorbs the extra height the IntrinsicHeight row inherits from the taller
    // `left` column. The Spacer is the ONLY flex child and it is an empty box —
    // intrinsic height 0 — so fl_chart is never intrinsic-measured (that is
    // what froze the embedder when the chart itself was the Expanded child).
    // Narrow layout stacks in an unbounded Column where a Spacer would throw,
    // so it is omitted there.
    Widget buildRight({required bool fill}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: _TimeframeSegment(),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          if (fill) const Spacer(),
          SizedBox(
            height: fill
                ? kMarketsHeroChartHeight
                : kMarketsHeroChartHeightStacked,
            child: _HeroChart(sparkline: data.sparkline),
          ),
        ],
      );
    }

    final content = LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= GeniusBreakpoints.medium;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              const SizedBox(height: GeniusWalletConsts.space12),
              buildRight(fill: false),
            ],
          );
        }
        // IntrinsicHeight is load-bearing: this Row lives inside the page's
        // vertical SingleChildScrollView, so its incoming height is unbounded.
        // `CrossAxisAlignment.stretch` then has nothing to stretch to and the
        // Expanded children collapse to zero size — fl_chart renders into a
        // 0-height box and throws "Cannot hit test a render box with no size",
        // blanking the whole Markets page. IntrinsicHeight gives the Row a
        // concrete height (the taller of left/right) so stretch resolves. This
        // is exactly what the News hero does (crypto_news_screen.dart).
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: left),
              const SizedBox(width: GeniusWalletConsts.space16),
              Expanded(flex: 7, child: buildRight(fill: true)),
            ],
          ),
        );
      },
    );

    // RepaintBoundary: this card holds an fl_chart (expensive to repaint) and a
    // 1px hairline border at ~12% alpha. Without isolation, scrolling the page
    // re-rasterises the whole card every frame, and at fractional sub-pixel
    // scroll offsets the hairline edge (esp. the right/vertical border, next to
    // the chart) drops below visibility on some frames — the flicker Jakub saw.
    // Boundary → the card rasters once and just translates as a cached layer.
    return RepaintBoundary(
      child: Semantics(
        button: widget.onTap != null,
        label: '${widget.coin.name} market detail',
        child: InkWell(
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
          onTap: widget.onTap,
          child: Container(
            decoration: GWDecorations.surface(
              radius: GeniusWalletConsts.radiusLg,
            ),
            padding: const EdgeInsets.all(GeniusWalletConsts.space16),
            child: content,
          ),
        ),
      ),
    );
  }

  String _price(double v) {
    final decimals = v >= 1 ? 2 : 6;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimals,
    ).format(v);
  }

  String _absChange(CoinGeckoMarketData d) {
    final v = d.priceChange24h;
    final decimals = d.currentPrice >= 1 ? 2 : 4;
    return '${v >= 0 ? '+' : '−'}\$${v.abs().toStringAsFixed(decimals)}';
  }

  String _compact(double v) {
    if (v >= 1e12) {
      return '\$${(v / 1e12).toStringAsFixed(2)}T';
    }
    if (v >= 1e9) {
      return '\$${(v / 1e9).toStringAsFixed(1)}B';
    }
    if (v >= 1e6) {
      return '\$${(v / 1e6).toStringAsFixed(1)}M';
    }
    if (v >= 1e3) {
      return '\$${(v / 1e3).toStringAsFixed(1)}K';
    }
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(v);
  }
}

class _ChangePill extends StatelessWidget {
  final double percent;
  final Color color;
  const _ChangePill({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%',
        style: GeniusWalletTypography.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The 7d hero chart, on the SAME runtime A/B rule as the coin page: scheme B's
/// trading frame when the box it is handed clears [kChartFrameMinHeight],
/// today's axis-free chart below it.
///
/// Until 2026-07-30 this surface only ever got 078's colour rules - trend
/// colour and the `borderControl` contrast fix - because it sat at 180px and
/// the frame needs 220. It is 253 in the wide layout now (see
/// [kMarketsHeroChartHeight] for why that is free), so the frame applies where
/// there is room and does not where there is not.
///
/// **One widget with a `framed` bool rather than the two `StatelessWidget`s
/// `crypto_live_chart.dart` splits into.** That file's split earns itself: its
/// two schemes differ in their Y-window handling (`chartBandedBounds`) and in
/// carrying `_HighLowPlate`s, so they are genuinely two charts. Here the line,
/// the fill, the touch behaviour and the tooltip are byte-identical between
/// branches and only the frame parts differ, so two widgets would be one widget
/// copied twice.
class _HeroChart extends StatelessWidget {
  final List<double>? sparkline;
  const _HeroChart({required this.sparkline});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final data = sparkline;
    if (data == null || data.isEmpty) {
      return Center(
        child: Text(
          'Chart unavailable',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
        ),
      );
    }
    final spots = List<FlSpot>.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );
    // One trend-colour rule now covers every chart surface (078-S2). Before
    // this, the hero ran a THIRD rule of its own — a fixed
    // gradientGreen -> gradientBlue regardless of direction — while
    // `CryptoLiveChart` was always mint and the two sparklines (
    // `crypto_simple_chart.dart:53-55`) colour by sign. Uses the LOCAL `up`
    // (first vs last point of the plotted 7d sparkline), not
    // `data.priceChangePercentage24h`: the series on screen is 7 days, so a
    // 24h-signed colour on a 7d line would be the same class of lie this
    // whole task is removing.
    final bool up = data.last >= data.first;
    final Color trend = up ? gw.statusSuccess : gw.statusError;

    // Hover tooltip (same effect as the dashboard's CryptoLiveChart): a touched
    // point shows its time, price, and % change vs the window start. The
    // sparkline carries no timestamps, so map each index onto the last 7 days —
    // CoinGecko's `sparkline_in_7d` IS an evenly-spaced 7d series, and 7D is the
    // only range wired (the timeframe tabs are visual-only), so this is honest
    // for what is plotted.
    // ponytail: assumes a 7d window because that is the only series fetched.
    // Ceiling: wrong labels if a non-7d range is ever plotted here. Upgrade
    // path: pass the real [start,end] in once timeframe ranges are wired
    // (.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md).
    final double first = data.first;
    final int n = data.length;
    final DateTime now = DateTime.now();
    const double windowMs = 7 * 24 * 60 * 60 * 1000;
    final double stepMs = n > 1 ? windowMs / (n - 1) : 0;
    DateTime timeAt(double x) =>
        now.subtract(Duration(milliseconds: ((n - 1 - x) * stepMs).round()));

    return LayoutBuilder(
      builder: (context, c) {
        // Measured off the box actually handed to the plot, never off a
        // per-surface flag — 078-S4's whole point. `c.maxHeight` is the
        // `SizedBox` in `buildRight`, so the stacked layout's 180 lands below
        // the threshold and the wide layout's 253 above it.
        final bool framed = chartUsesFrame(c.maxHeight);
        final (yLo, yHi) = chartYBounds(spots);

        // Grid lines and right-axis labels BOTH iterate from the axis baseline
        // by `interval`, so handing them the SAME step is what makes every
        // label land on a gridline by construction.
        final (_, step) = chartTickStep(
          yLo,
          yHi,
          chartYTickCount(c.maxHeight - kChartTimeRowHeight),
        );

        final chart = LineChart(
          LineChartData(
            minY: framed ? yLo : null,
            maxY: framed ? yHi : null,
            gridData: FlGridData(
              show: framed,
              drawVerticalLine: false,
              horizontalInterval: step,
              getDrawingHorizontalLine: (_) => FlLine(
                color: gw.borderSubtle.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: framed,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: framed,
                  reservedSize: kChartAxisGutter,
                  interval: step,
                  // MUST stay false, or fl_chart also prints the raw padded
                  // min/max, which are not on the nice-number ladder.
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
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: trend,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      trend.withValues(alpha: 0.18),
                      trend.withValues(alpha: 0.0),
                    ],
                    // Same non-zero-baseline honesty as the main chart
                    // (`crypto_live_chart.dart`): the scale never claims a zero
                    // floor, so an edge-to-edge fill would run to one it does not
                    // have. Unchanged by the frame - `kChartFillFadeStop` is
                    // derived from `belowBarLargestRect`, which is the highest
                    // spot to the plot floor either way.
                    stops: const [0.0, kChartFillFadeStop],
                  ),
                ),
              ),
            ],
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    // borderControl (3.30:1 dark / 3.10:1 light) clears WCAG
                    // 1.4.11's 3:1 gate; borderStrong (2.10:1) did not — same
                    // token, same reason as the main chart's crosshair.
                    FlLine(color: gw.borderControl, strokeWidth: 1),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, i) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: trend,
                            strokeWidth: 3,
                            strokeColor: trend.withValues(alpha: 0.26),
                          ),
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipBorderRadius: BorderRadius.circular(10),
                tooltipBorder: BorderSide(color: gw.borderSubtle),
                getTooltipColor: (touchedSpot) => gw.surfaceElevated,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final double pct = first > 0
                        ? ((spot.y - first) / first) * 100
                        : 0;
                    final Color pctColor = pct >= 0
                        ? gw.statusSuccess
                        : gw.statusError;
                    final int decimals = spot.y >= 1 ? 2 : 6;
                    return LineTooltipItem(
                      '${DateFormat('MMM d, h:mm a').format(timeAt(spot.x))}\n',
                      GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: NumberFormat.currency(
                            symbol: '\$',
                            decimalDigits: decimals,
                          ).format(spot.y),
                          style: GeniusWalletTypography.numericBody.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              '  ${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                          style: GeniusWalletTypography.labelMd.copyWith(
                            color: pctColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );

        if (!framed) {
          return chart;
        }

        // A plain Row of Texts, NOT fl_chart's bottom titles — fl_chart anchors
        // its x intervals to `baselineX`, which cannot be lined up with the
        // sparkline's index positions without fighting the library. Same
        // reasoning, same constants as `crypto_live_chart.dart`'s frame.
        //
        // The labels are DATES, not times. The coin chart prints clock times
        // because its window can be an hour; this series is always the 7d
        // `sparkline`, where six identical `h:mm a` labels would be the exact
        // class of lie the timeframe work is removing.
        return Column(
          children: [
            Expanded(child: chart),
            SizedBox(
              height: kChartTimeRowHeight,
              child: Padding(
                padding: const EdgeInsets.only(right: kChartAxisGutter),
                child: LayoutBuilder(
                  builder: (context, rowConstraints) {
                    final int count = chartXLabelCount(
                      plotWidth: rowConstraints.maxWidth,
                      sampleCount: spots.length,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(count, (b) {
                        final int ix = count > 1
                            ? ((b / (count - 1)) * (spots.length - 1)).round()
                            : 0;
                        return Text(
                          DateFormat('MMM d').format(timeAt(spots[ix].x)),
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
      },
    );
  }
}

/// Visual-only 24H·7D·30D·1Y selector. Only 7d data exists on the card today,
/// so tapping moves the chip but does not re-window the series.
///
/// ponytail: cosmetic selector — the plotted series is always the 7d
/// `sparkline`. Ceiling: non-functional tabs. Upgrade path: the same captured
/// follow-up that wires real ranges into `CryptoLiveChart`
/// (.planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-
/// live-chart.md) would feed this once markets adopts the live chart.
class _TimeframeSegment extends StatefulWidget {
  const _TimeframeSegment();

  @override
  State<_TimeframeSegment> createState() => _TimeframeSegmentState();
}

class _TimeframeSegmentState extends State<_TimeframeSegment> {
  static const _labels = ['24H', '7D', '30D', '1Y'];
  int _selected = 1; // 7D — the range the sparkline actually covers.

  // VISUALLY IDENTICAL to the dashboard's _TimeframeSegment/_TimeframeTab
  // (dashboard_screen.dart): surfaceMenu "baton" with 2px-gapped tabs, the
  // selected tab on the brandCta gradient, unselected tabs lifting onto
  // surfaceElevated on hover. Only the labels differ (markets ranges).
  // ponytail: still visual-only — the chart under it is a fixed 7d sparkline, so
  // 24H/30D/1Y select but change nothing. Ceiling: no range data. Upgrade path:
  // .planning/todos/pending/2026-07-21-wire-real-timeframe-ranges-in-crypto-live-chart.md
  // The two copies of this widget SHOULD be one shared GWTimeframeSegment —
  // .planning/todos/pending/2026-07-24-unify-timeframe-segment-component.md
  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: gw.surfaceMenu,
        border: Border.all(color: gw.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _labels.length; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            _TimeframeTab(
              label: _labels[i],
              selected: i == _selected,
              unselectedColor: gw.textSecondary,
              hoverColor: gw.surfaceElevated,
              hoverTextColor: gw.textPrimary,
              onTap: () => setState(() => _selected = i),
            ),
          ],
        ],
      ),
    );
  }
}

/// Hover plumbing moved into `GWHoverable` (23-05); this widget held no other
/// state, so it is a `StatelessWidget` now.
class _TimeframeTab extends StatelessWidget {
  const _TimeframeTab({
    required this.label,
    required this.selected,
    required this.unselectedColor,
    required this.hoverColor,
    required this.hoverTextColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color unselectedColor;
  final Color hoverColor;
  final Color hoverTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GWHoverable(
      builder: (hovered) {
        final Color labelColor = selected
            ? context.gw.textOnBrand
            : (hovered ? hoverTextColor : unselectedColor);
        final bool lifted = hovered && !selected;
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            transformAlignment: Alignment.center,
            transform: lifted
                ? Matrix4.translationValues(0, -1, 0)
                : Matrix4.identity(),
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space4,
              vertical: GeniusWalletConsts.space3,
            ),
            decoration: BoxDecoration(
              gradient: selected ? GeniusWalletGradient.brandCta : null,
              color: selected
                  ? null
                  : (lifted ? hoverColor : Colors.transparent),
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.radiusPill,
              ),
              boxShadow: (selected || lifted)
                  ? GeniusWalletElevation.card
                  : null,
            ),
            child: Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
        );
      },
    );
  }
}
