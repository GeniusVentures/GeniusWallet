import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_font_size.dart';
import 'package:go_router/go_router.dart';

class DashboardMarkets extends StatefulWidget {
  final List<CoinGeckoCoin> coins;
  final String? title;

  const DashboardMarkets({Key? key, required this.coins, this.title})
      : super(key: key);

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

        return SizedBox(
          height: double.infinity,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.title != null) ...[
                  Center(
                    child: AutoSizeText(
                      widget.title!,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: GeniusWalletFontSize.sectionHeader,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ...widget.coins.map((coin) {
                  final data = marketData[coin.symbol.toLowerCase()];

                  if (data == null) {
                    return const SizedBox.shrink(); // Skip if data is missing
                  }

                  return Column(
                    children: [
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
                        },
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
                    ],
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}
