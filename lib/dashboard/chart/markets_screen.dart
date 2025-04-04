import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/chart/markets_search_bar.dart'; // 🔥 Import your search bar
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer.dart';
import 'package:genius_wallet/widgets/components/sliding_drawer_button.dart';
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
    return cardWidth / 100; // Ensures 100px height
  }

  @override
  Widget build(BuildContext context) {
    final SlidingDrawerController searchDrawerController =
        SlidingDrawerController();
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header and SearchBar
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Markets",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(FontAwesomeIcons.magnifyingGlass),
                  onPressed: searchDrawerController.openDrawer,
                )
              ],
            ),

            const SizedBox(height: 24),

            // Expanded to take the remaining space for grid view
            Expanded(
              child: FutureBuilder<List<CoinGeckoCoin>>(
                future: getMarketCoins(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(
                      child: Text(
                        "Failed to load market coins",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        "No market data available",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final coins = snapshot.data!;

                  return FutureBuilder<Map<String, CoinGeckoMarketData?>>(
                    future: fetchCoinsMarketData(
                      coinIds: coins.map((coin) => coin.id).toList(),
                    ),
                    builder: (context, marketSnapshot) {
                      if (marketSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (marketSnapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Failed to load market data",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      } else if (!marketSnapshot.hasData ||
                          marketSnapshot.data!.isEmpty) {
                        return const Center(
                          child: Text(
                            "No market data available",
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      final marketData = marketSnapshot.data!;

                      return GridView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: getCrossAxisCount(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 16,
                          childAspectRatio: getChildAspectRatio(context),
                        ),
                        itemCount: coins.length,
                        itemBuilder: (context, index) {
                          final coin = coins[index];
                          final data = marketData[coin.symbol.toLowerCase()];

                          if (data == null) {
                            return const SizedBox
                                .shrink(); // Skip if data is missing
                          }

                          return _buildMarketChartCard(data, coin);
                        },
                      );
                    },
                  );
                },
              ),
            ),
            SlidingDrawer(
              controller: searchDrawerController,
              title: "Search Coins",
              content: MarketSearchBar(
                  onCoinPressed: () => searchDrawerController.closeDrawer()),
            )
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
                    "coin": coin, // Make sure coin is passed
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
                padding: const EdgeInsets.all(16),
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
