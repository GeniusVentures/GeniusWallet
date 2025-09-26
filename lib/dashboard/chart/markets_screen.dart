import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/chart/markets_search_bar.dart'; // 🔥 Import your search bar
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:go_router/go_router.dart';

class MarketsScreen extends StatelessWidget {
  const MarketsScreen({Key? key}) : super(key: key);

  int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width >= 1300) return 4; // Desktop: 4 per row
    if (width >= 1050) return 3; // Tablet: 3 per row
    if (width >= 550) return 2; // Small Tablet: 2 per row
    return 1; // Mobile: 1 per row
  }

  double getChildAspectRatio(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    int columns = getCrossAxisCount(context);
    double cardWidth = screenWidth / columns - 8; // Account for padding
    return cardWidth / 80; // Ensures 100px height
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          children: [
            // Header and SearchBar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Markets",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  onPressed: () {
                    ResponsiveDrawer.show<void>(
                      context: context,
                      title: "Search Coins",
                      children: [
                        MarketSearchBar(
                          onCoinPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            Expanded(
              child: FutureStateWidget<List<CoinGeckoCoin>>(
                future: getMarketCoins(),
                error: const Center(
                  child: Text(
                    "Failed to load market coins",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                onData: (coins) {
                  if (coins.isEmpty) {
                    return const Center(
                      child: Text(
                        "No market data available",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }
                  return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
                    future: fetchCoinsMarketData(
                      coinIds: coins.map((coin) => coin.id).toList(),
                    ),
                    error: const Center(
                      child: Text(
                        "Failed to load market data",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    onData: (marketData) {
                      if (marketData.isEmpty) {
                        return const Center(
                          child: Text(
                            "No market data available",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      // Grid with robust lookup
                      return GridView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getCrossAxisCount(context),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: getChildAspectRatio(context),
                        ),
                        itemCount: coins.length,
                        itemBuilder: (context, index) {
                          final coin = coins[index];
                          final data = marketData[coin.id] ??
                              marketData[coin.symbol.toLowerCase()];

                          if (data == null) {
                            // Optional: visually debug missing data
                            return Container(
                              color: Colors.red,
                              child: Center(
                                child: Text(
                                  '${coin.symbol}\n${coin.id}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            );
                            // Or just: return const SizedBox.shrink();
                          }

                          return _buildMarketChartCard(data, coin);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketChartCard(CoinGeckoMarketData data, CoinGeckoCoin coin) {
    return Builder(
        builder: (context) => InkWell(
              onTap: () {
                context.push(
                  '/token-info',
                  extra: {
                    "isGnusWalletConnected": false,
                    "securityInfo": "Coming Soon",
                    "transactionHistory": ["Coming Soon"],
                    "marketData": data,
                    "coin": coin,
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: GeniusWalletColors.deepBlueCardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Center(
                  child: CryptoSparkLineChart(
                    title: coin.name,
                    iconPath: data.imageUrl,
                    currentPrice: data.currentPrice,
                    high24h: data.high24h,
                    low24h: data.low24h,
                    priceChangePercent: data.priceChangePercentage24h,
                    iconSize: 32,
                    sparkline: data.sparkline,
                  ),
                ),
              ),
            ));
  }
}
