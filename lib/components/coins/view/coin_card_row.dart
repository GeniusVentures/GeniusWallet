import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:intl/intl.dart';

/// A2 · Market-forward Assets row (sketch 001). The subtitle carries MARKET
/// data (price + 24h% chip [+ · network]) at full strength regardless of
/// balance, so a zero-balance row still reads as alive; the trailing column
/// carries the HOLDING (fiat value over token amount) and is the only thing
/// dimmed (~38%) when the balance is zero.
// Text, not AutoSizeText: AutoSizeText searches for a font size that
// fits its box, so a drag-resize mints a distinct TextStyle — a distinct
// skia ParagraphCacheKey — per frame, per row. That is the cache thrash
// that freezes the macOS window (37639d5). Every one of these already
// carried `overflow: ellipsis`, so the swap only drops the shrink-to-fit
// step, which is precisely the part that could not be made safe.
class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double? balance;
  final CoinGeckoMarketData? marketData;
  final VoidCallback? onTap;

  const CoinCardRow({
    super.key,
    required this.iconPath,
    required this.name,
    this.balance,
    required this.symbol,
    this.marketData,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final NumberFormat currencyFormatter = NumberFormat.currency(symbol: "\$");

    final double price = marketData?.currentPrice ?? 0.0;
    final double pct = marketData?.priceChangePercentage24h ?? 0.0;
    final double fiatValue = price * (balance ?? 0.0);
    final bool noBalance = (balance ?? 0.0) == 0.0;

    // Up/down standardized on the status tokens (never cyan): positive =
    // success, negative = error. No longer balance-gated.
    final Color changeColor = pct >= 0 ? gw.statusSuccess : gw.statusError;

    final String amountText = noBalance
        ? "0.0000 $symbol"
        : "${WalletUtils.truncateToDecimals(balance.toString())} $symbol";

    return ListTile(
      onTap: onTap,
      // horizontal 8 matches the Assets header inset so row content (icon +
      // left text) and the trailing values share the header's left/right edge.
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: buildTokenIcon(iconPath: iconPath, size: 38),
      title: Text(
        name,
        style: GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary),
      ),
      subtitle: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Flexible(
            child: Text(
              currencyFormatter.format(price),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Filled 24h% chip — market data, always full strength.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: changeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: changeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            currencyFormatter.format(fiatValue),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.numericBody.copyWith(
              fontWeight: FontWeight.bold,
              color: noBalance ? gw.textPrimary38 : gw.textPrimary,
            ),
          ),
          Text(
            amountText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: noBalance ? gw.textPrimary38 : gw.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
