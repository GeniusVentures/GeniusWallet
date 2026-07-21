import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

class DashboardMarkets extends StatefulWidget {
  final List<CoinGeckoCoin> coins;
  final String? title;

  const DashboardMarkets({super.key, required this.coins, this.title});

  @override
  State<DashboardMarkets> createState() => _DashboardMarketsState();
}

class _DashboardMarketsState extends State<DashboardMarkets> {
  late Future<Map<String, CoinGeckoMarketData?>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchCoinsMarketData(
      coinIds: widget.coins.map((coin) => coin.id).toList(),
    );
  }

  void _retry() {
    setState(() {
      _future = fetchCoinsMarketData(
        coinIds: widget.coins.map((coin) => coin.id).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
      future: _future,
      error: const Text("Failed to load market data"),
      onRetry: _retry,
      onData: (marketData) {
        if (marketData.isEmpty) {
          return const Center(child: Text("No market data available"));
        }

        final visibleCoins = widget.coins.where((coin) {
          return marketData[coin.symbol.toLowerCase()] != null;
        }).toList();

        // Real "Markets" panel header above the rows (003-A) via the shared
        // GWSectionTitle, not a title crammed into the first list item. The
        // list stays bounded via Column + Expanded (the panel already gives it
        // bounded height).
        return Column(
          children: [
            GWSectionTitle(
              title: widget.title ?? 'Markets',
              trailing: GWViewAllLink(onTap: () => context.go('/markets')),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: visibleCoins.length,
                separatorBuilder: (context, index) =>
                    Container(height: 1, color: gw.borderSubtle),
                itemBuilder: (context, index) {
                  final coin = visibleCoins[index];
                  final data = marketData[coin.symbol.toLowerCase()]!;

                  return CryptoSparkLineChart(
                    onTap: () {
                      context.push(
                        '/token-info',
                        extra: {
                          "isGnusWalletConnected": false,
                          "marketData": data,
                        },
                      );
                    },
                    title: coin.name,
                    iconPath: data.imageUrl,
                    currentPrice: data.currentPrice,
                    high24h: data.high24h,
                    low24h: data.low24h,
                    priceChangePercent: data.priceChangePercentage24h,
                    sparkline: data.sparkline,
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
