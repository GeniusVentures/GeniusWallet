import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:intl/intl.dart';

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
    final cs = Theme.of(context).colorScheme;
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this const-instanced widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final NumberFormat currencyFormatter = NumberFormat.currency(symbol: "\$");

    double totalValue = (marketData?.currentPrice ?? 0.0) * (balance ?? 0.0);
    double gainLoss =
        totalValue * ((marketData?.priceChangePercentage24h ?? 0.0) / 100);

    Color changeColor = (balance ?? 0) > 0
        ? (gainLoss >= 0 ? cs.primary : cs.error)
        : cs.onSurfaceVariant;

    final bool noBalance = (balance ?? 0.0) == 0.0;

    return ListTile(
      onTap: onTap,
      leading: buildTokenIcon(iconPath: iconPath, size: 38),
      title: Text(name),
      subtitle: AutoSizeText(
        noBalance
            ? "No balance yet"
            : "${WalletUtils.truncateToDecimals(balance.toString())} $symbol",
        maxLines: 1,
        minFontSize: 10,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontStyle: noBalance ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      trailing: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!noBalance)
            AutoSizeText(
              currencyFormatter.format(totalValue),
              maxLines: 1,
              minFontSize: 12,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: gw.textPrimary,
              ),
            ),
          if (!noBalance)
            AutoSizeText(
              currencyFormatter.format(gainLoss),
              maxLines: 1,
              minFontSize: 10,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: changeColor,
              ),
            ),
        ],
      ),
    );
  }
}
