import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
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
    return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
      future: _future,
      error: const Text(
        "Failed to load market data",
        style: TextStyle(color: Colors.white),
      ),
      onRetry: _retry,
      onData: (marketData) {
        if (marketData.isEmpty) {
          return const Center(
            child: Text(
              "No market data available",
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        final visibleCoins = widget.coins.where((coin) {
          return marketData[coin.symbol.toLowerCase()] != null;
        }).toList();

        return ListView.separated(
          itemCount: visibleCoins.length,
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index) {
            final coin = visibleCoins[index];
            final data = marketData[coin.symbol.toLowerCase()]!;

            final item = CryptoSparkLineChart(
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

            if (index == 0 && widget.title != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title!,
                    maxLines: 1,
                    style: Theme.of(context).textTheme.headlineMedium
                  ),
                  item,
                ],
              );
            }

            return item;
          },
        );
      },
    );
  }
}
