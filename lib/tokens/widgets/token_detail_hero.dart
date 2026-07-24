import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// Token-detail hero — a faithful Flutter port of sketch 152's `.heroblock`
/// (variant A). On the LEFT: the token icon + coin name + "SYMBOL · Network"
/// subtitle. On the RIGHT: the big tabular price + a sign-colored 24h % pill
/// (green [GWColors.statusSuccess] when ≥ 0, red [GWColors.statusError]
/// otherwise) filled at ~15% alpha, matching the sketch `.pill`.
///
/// Layout is responsive: at a comfortable width it renders as a single Row
/// (identity beside the price block); when the available width is narrow it
/// stacks the identity above the price block so nothing overflows.
class TokenDetailHero extends StatelessWidget {
  const TokenDetailHero({
    super.key,
    required this.marketData,
    required this.selectedNetwork,
  });

  final CoinGeckoMarketData? marketData;
  final Network? selectedNetwork;

  /// Below this width the hero stacks vertically instead of sitting in one Row.
  static const double _stackBreakpoint = 360.0;

  /// Diameter of the round token icon (sketch `.icn.big` = 52px).
  static const double _iconSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final GWColors colors =
        Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final TextTheme textTheme = Theme.of(context).textTheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool stack = constraints.maxWidth < _stackBreakpoint;

        final Widget identity = _Identity(
          marketData: marketData,
          selectedNetwork: selectedNetwork,
          colors: colors,
          textTheme: textTheme,
        );

        final Widget priceBlock = _PriceBlock(
          marketData: marketData,
          colors: colors,
          textTheme: textTheme,
          alignEnd: !stack,
        );

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              identity,
              const SizedBox(height: GeniusWalletConsts.space6),
              priceBlock,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: identity),
            const SizedBox(width: GeniusWalletConsts.space8),
            priceBlock,
          ],
        );
      },
    );
  }
}

/// LEFT side: round icon + name + "SYMBOL · Network" subtitle.
class _Identity extends StatelessWidget {
  const _Identity({
    required this.marketData,
    required this.selectedNetwork,
    required this.colors,
    required this.textTheme,
  });

  final CoinGeckoMarketData? marketData;
  final Network? selectedNetwork;
  final GWColors colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final String name =
        (marketData?.name.isNotEmpty ?? false) ? marketData!.name : 'unknown';
    final String symbol = (marketData?.symbol ?? '').toUpperCase();
    final String? networkName =
        (selectedNetwork?.name?.isNotEmpty ?? false) ? selectedNetwork!.name : null;

    final String subtitle = <String>[
      if (symbol.isNotEmpty) symbol,
      if (networkName != null) networkName,
    ].join(' · ');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        buildTokenIcon(iconPath: marketData?.imageUrl, size: _iconSize),
        const SizedBox(width: GeniusWalletConsts.space6),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: (textTheme.titleLarge ?? const TextStyle()).copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: GeniusWalletConsts.space2 / 2),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
                    color: colors.textSecondary,
                    letterSpacing: 0.4,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static const double _iconSize = TokenDetailHero._iconSize;
}

/// RIGHT side: big tabular price stacked over the sign-colored 24h % pill.
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({
    required this.marketData,
    required this.colors,
    required this.textTheme,
    required this.alignEnd,
  });

  final CoinGeckoMarketData? marketData;
  final GWColors colors;
  final TextTheme textTheme;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final double price = marketData?.currentPrice ?? 0.0;
    final String priceLabel =
        NumberFormat.currency(symbol: '\$').format(price);

    final double changePct = marketData?.priceChangePercentage24h ?? 0.0;

    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          priceLabel,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            fontSize: 22,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space3),
        _ChangePill(
          changePct: changePct,
          colors: colors,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

/// The 24h % delta pill — green/up or red/down, filled at ~15% alpha.
class _ChangePill extends StatelessWidget {
  const _ChangePill({
    required this.changePct,
    required this.colors,
    required this.textTheme,
  });

  final double changePct;
  final GWColors colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final bool up = changePct >= 0;
    final Color tone = up ? colors.statusSuccess : colors.statusError;
    final String sign = up ? '+' : '';
    final String label =
        '${up ? '▲' : '▼'} $sign${changePct.toStringAsFixed(2)}%';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space2 / 2,
      ),
      decoration: BoxDecoration(
        // ~15% alpha fill mirroring the sketch `.pill` status-*-fill token.
        color: tone.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
      ),
      child: Text(
        label,
        style: (textTheme.bodySmall ?? const TextStyle()).copyWith(
          color: tone,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
