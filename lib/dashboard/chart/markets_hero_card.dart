import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

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
          SizedBox(height: 180, child: _HeroChart(sparkline: data.sparkline)),
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

/// 7d sparkline drawn large as a brand-gradient area chart. No axes, no touch
/// (a static hero backdrop). Falls back to a quiet placeholder when the
/// sparkline is missing.
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
    const gradient = LinearGradient(
      colors: [
        GeniusWalletColors.gradientGreen,
        GeniusWalletColors.gradientBlue,
      ],
    );

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

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: gradient,
            barWidth: 2.5,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  GeniusWalletColors.gradientGreen.withValues(alpha: 0.24),
                  GeniusWalletColors.gradientGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          enabled: true,
          handleBuiltInTouches: true,
          getTouchedSpotIndicator: (barData, spotIndexes) {
            return spotIndexes.map((index) {
              return TouchedSpotIndicatorData(
                FlLine(color: gw.borderStrong, strokeWidth: 1),
                FlDotData(
                  getDotPainter: (spot, percent, bar, i) => FlDotCirclePainter(
                    radius: 4,
                    color: GeniusWalletColors.gradientGreen,
                    strokeWidth: 3,
                    strokeColor: GeniusWalletColors.gradientGreen.withValues(
                      alpha: 0.26,
                    ),
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

class _TimeframeTab extends StatefulWidget {
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
  State<_TimeframeTab> createState() => _TimeframeTabState();
}

class _TimeframeTabState extends State<_TimeframeTab> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final Color labelColor = selected
        ? GeniusWalletColors.textOnBrand
        : (_hovered ? widget.hoverTextColor : widget.unselectedColor);
    final bool lifted = _hovered && !selected;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
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
                : (lifted ? widget.hoverColor : Colors.transparent),
            borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
            boxShadow: (selected || lifted) ? GeniusWalletElevation.card : null,
          ),
          child: Text(
            widget.label,
            style: TextStyle(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}
