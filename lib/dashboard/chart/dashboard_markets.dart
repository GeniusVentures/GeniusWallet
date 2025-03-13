import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:go_router/go_router.dart';

class DashboardMarkets extends StatelessWidget {
  final List<CoinGeckoCoin> coins;
  final String? title;

  const DashboardMarkets({Key? key, required this.coins, this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, CoinGeckoMarketData?>>(
      future:
          fetchCoinsMarketData(coinIds: coins.map((coin) => coin.id).toList()),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text("Failed to load market data",
                  style: TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("No market data available",
                  style: TextStyle(color: Colors.white)));
        }

        final marketData = snapshot.data!;

        return SizedBox(
            height: double.infinity,
            child: SingleChildScrollView(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (title != null) ...[
                      const SizedBox(height: 16),
                      AutoSizeText(
                        title!,
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: GeniusWalletFontSize.sectionHeader,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    ...coins.map((coin) {
                      final data = marketData[coin.symbol.toLowerCase()];

                      if (data == null) {
                        return const SizedBox
                            .shrink(); // Skip if data is missing
                      }

                      return Column(children: [
                        InkWell(
                          onTap: () {
                            context.push(
                              '/token-info',
                              extra: {
                                "isGnusWalletConnected": false,
                                "securityInfo": "Coming Soon",
                                "transactionHistory": ["Coming Soon"],
                                "marketData": data
                              },
                            );
                          }, // Call function when tapped
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CryptoSparkLineChart(
                              title: coin.name,
                              iconPath: data.imageUrl,
                              currentPrice: data.currentPrice,
                              high24h: data.high24h,
                              low24h: data.low24h,
                              priceChangePercent: data.priceChangePercentage24h,
                              sparkline: data.sparkline,
                            ),
                          ),
                        ),
                        Container(
                          height: 2,
                          color: GeniusWalletColors.deepBlueTertiary,
                        ),
                        const SizedBox(height: 12),
                      ]);
                    }).toList(),
                  ]),
            ));
      },
    );
  }
}
