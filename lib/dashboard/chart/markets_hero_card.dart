import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
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
                  style: GeniusWalletTypography.titleLg
                      .copyWith(color: gw.textPrimary, letterSpacing: -0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                const _NativeChip(),
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
            _ChangePill(percent: data.priceChangePercentage24h, color: changeColor),
            const SizedBox(width: GeniusWalletConsts.space6),
            Flexible(
              child: Text(
                '${_absChange(data)} · 24h',
                style: GeniusWalletTypography.bodySm
                    .copyWith(color: gw.textSecondary),
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
            Expanded(child: _Stat(label: 'Rank', value: '#${data.marketCapRank}')),
            Expanded(child: _Stat(label: 'Market Cap', value: _compact(data.marketCap))),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        Row(
          children: [
            Expanded(child: _Stat(label: 'Volume 24h', value: _compact(data.totalVolume))),
            Expanded(child: _Stat(label: 'All-Time High', value: _price(data.ath))),
          ],
        ),
      ],
    );

    final right = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Align(alignment: Alignment.centerRight, child: _TimeframeSegment()),
        const SizedBox(height: GeniusWalletConsts.space8),
        SizedBox(
          height: 180,
          child: _HeroChart(sparkline: data.sparkline),
        ),
      ],
    );

    final content = LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= GeniusBreakpoints.medium;
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [left, const SizedBox(height: GeniusWalletConsts.space12), right],
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
              Expanded(flex: 7, child: right),
            ],
          ),
        );
      },
    );

    return Semantics(
      button: widget.onTap != null,
      label: '${widget.coin.name} market detail',
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        onTap: widget.onTap,
        child: Container(
          decoration: GWDecorations.surface(radius: GeniusWalletConsts.radiusLg),
          padding: const EdgeInsets.all(GeniusWalletConsts.space16),
          child: content,
        ),
      ),
    );
  }

  String _price(double v) {
    final decimals = v >= 1 ? 2 : 6;
    return NumberFormat.currency(symbol: '\$', decimalDigits: decimals).format(v);
  }

  String _absChange(CoinGeckoMarketData d) {
    final v = d.priceChange24h;
    final decimals = d.currentPrice >= 1 ? 2 : 4;
    return '${v >= 0 ? '+' : '−'}\$${v.abs().toStringAsFixed(decimals)}';
  }

  String _compact(double v) {
    if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(v);
  }
}

class _NativeChip extends StatelessWidget {
  const _NativeChip();

  @override
  Widget build(BuildContext context) {
    // Native token accent: brand fill + brand text (mint on dark, strong cyan
    // on light — both clear the surface for AA at this weight).
    final text = GWAppearance.isLight
        ? GeniusWalletColors.brandPrimaryStrong
        : GeniusWalletColors.brandSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: GeniusWalletColors.brandPrimary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
      ),
      child: Text(
        'NATIVE TOKEN',
        style: GeniusWalletTypography.labelMd.copyWith(
          color: text,
          fontSize: 9,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
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
        style: GeniusWalletTypography.labelMd
            .copyWith(color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: GeniusWalletTypography.labelMd.copyWith(
            color: gw.textSecondary,
            fontSize: 10,
            height: 14 / 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GeniusWalletTypography.numericBody.copyWith(
            color: gw.textPrimary,
            fontSize: 15,
            height: 20 / 15,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
          style: GeniusWalletTypography.bodySm.copyWith(color: gw.textSecondary),
        ),
      );
    }
    final spots = List<FlSpot>.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );
    const gradient = LinearGradient(
      colors: [GeniusWalletColors.gradientGreen, GeniusWalletColors.gradientBlue],
    );
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
        lineTouchData: const LineTouchData(enabled: false),
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

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: gw.surfaceMenu,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
        border: Border.all(color: gw.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_labels.length, (i) {
          final on = i == _selected;
          return GestureDetector(
            onTap: () => setState(() => _selected = i),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
              decoration: on
                  ? GWDecorations.surface(
                      radius: GeniusWalletConsts.radiusPill,
                      elevated: false,
                    )
                  : null,
              child: Text(
                _labels[i],
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: on ? gw.textPrimary : gw.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
