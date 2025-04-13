import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/image_utils.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:intl/intl.dart';

class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double? balance;
  final CoinGeckoMarketData? marketData;
  final VoidCallback? onTap;

  const CoinCardRow({
    Key? key,
    required this.iconPath,
    required this.name,
    this.balance,
    required this.symbol,
    this.marketData,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NumberFormat currencyFormatter =
        NumberFormat.currency(locale: "en_US", symbol: "\$");

    // **Calculate Total Value**
    double totalValue = (marketData?.currentPrice ?? 0.0) * (balance ?? 0.0);

    // **Calculate 24h Gain/Loss**
    double gainLoss =
        totalValue * ((marketData?.priceChangePercentage24h ?? 0.0) / 100);

    // **Determine Color (Green = Positive, Red = Negative, Gray for Zero Balance)**
    Color changeColor = (balance ?? 0) > 0
        ? (gainLoss >= 0
            ? GeniusWalletColors.lightGreenPrimary
            : GeniusWalletColors.red)
        : GeniusWalletColors.gray500;

    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity, // Ensures the row fits within the screen
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: GeniusWalletColors.deepBlueCardColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            // **Icon**
            buildTokenIcon(iconPath: iconPath, size: 38),
            const SizedBox(width: 12),

            // **Name & Balance Column**
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // **Coin Name**
                  AutoSizeText(
                    name,
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  // **Balance & Symbol**
                  if (balance != null)
                    AutoSizeText(
                      "${balance == 0 ? '0' : WalletUtils.truncateToDecimals(balance.toString())} $symbol",
                      maxLines: 1,
                      minFontSize: 10,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: GeniusWalletColors.gray500,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 12),

            // **Right Column - Price & Gain/Loss**
            if (balance != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // **Total Value in USD**
                  AutoSizeText(
                    currencyFormatter.format(totalValue),
                    maxLines: 1,
                    minFontSize: 12,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  // **24h Gain/Loss**
                  Row(
                    children: [
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
                ],
              ),
          ],
        ),
      ),
    );
  }
}
