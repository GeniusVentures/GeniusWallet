import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/chart/markets_search_bar.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late Future<List<CoinGeckoCoin>> _coinsFuture;
  List<String>? _cachedCoinIds;
  Future<Map<String, CoinGeckoMarketData?>>? _marketDataFuture;

  @override
  void initState() {
    super.initState();
    _coinsFuture = getMarketCoins();
  }

  void _retryCoins() {
    setState(() {
      _coinsFuture = getMarketCoins();
      _marketDataFuture = null;
      _cachedCoinIds = null;
    });
  }

  void _retryMarketData() {
    if (_cachedCoinIds == null || _cachedCoinIds!.isEmpty) return;
    setState(() {
      _marketDataFuture = fetchCoinsMarketData(coinIds: _cachedCoinIds!);
    });
  }

  int getCrossAxisCount(BuildContext context) {
    double width = MediaQuery.sizeOf(context).width;
    if (width >= GeniusBreakpoints.large) return 4; // Desktop: 4 per row
    if (width >= GeniusBreakpoints.medium) return 3; // Tablet: 3 per row
    if (width >= GeniusBreakpoints.small) return 2; // Small Tablet: 2 per row
    return 1; // Mobile: 1 per row
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
          child: Column(
            spacing: 16.0,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                spacing: 12.0,
                children: [
                  const Text(
                    "Markets",
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const FaIcon(FontAwesomeIcons.magnifyingGlass),
                    onPressed: () {
                      ResponsiveDrawer.show<void>(
                        context: context,
                        title: "Search Coins",
                        child: ListView(
                          children: [
                            MarketSearchBar(
                              onCoinPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              FutureStateWidget<List<CoinGeckoCoin>>(
                future: _coinsFuture,
                onRetry: _retryCoins,
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
                  _cachedCoinIds = coins.map((coin) => coin.id).toList();
                  return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
                    future:
                        _marketDataFuture ??
                        (_marketDataFuture = fetchCoinsMarketData(
                          coinIds: _cachedCoinIds!,
                        )),
                    onRetry: _retryMarketData,
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

                      return Expanded(
                        child: GridView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: getCrossAxisCount(context),
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                mainAxisExtent: 80,
                              ),
                          itemCount: coins.length,
                          itemBuilder: (context, index) {
                            final coin = coins[index];
                            final data =
                                marketData[coin.id] ??
                                marketData[coin.symbol.toLowerCase()];

                            if (data == null) {
                              return Container(
                                color: Colors.red,
                                child: Center(
                                  child: Text(
                                    '${coin.symbol}\n${coin.id}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              );
                            }

                            return Card(
                              clipBehavior: Clip.hardEdge,
                              child: CryptoSparkLineChart(
                                onTap: () {
                                  context.push(
                                    '/token-info',
                                    extra: {
                                      "isGnusWalletConnected": false,
                                      "marketData": data,
                                      "coin": coin,
                                    },
                                  );
                                },
                                title: coin.name,
                                iconPath: data.imageUrl,
                                currentPrice: data.currentPrice,
                                high24h: data.high24h,
                                low24h: data.low24h,
                                priceChangePercent:
                                    data.priceChangePercentage24h,
                                iconSize: 32,
                                sparkline: data.sparkline,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
