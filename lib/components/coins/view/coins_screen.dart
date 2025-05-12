import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/coins/view/coin_card_container.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:go_router/go_router.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;
  final bool? isUseDivider;
  final bool? isGnusWalletConnected;

  const CoinsScreen(
      {Key? key,
      this.onCoinSelected,
      this.filterCoins,
      this.isGnusWalletConnected,
      this.isUseDivider})
      : super(key: key);

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  Map<String, CoinGeckoMarketData?> _marketData = {};
  bool _isFetchingMarketData = false;

  Future<void> _fetchMarketData(List<Coin> coins) async {
    if (_isFetchingMarketData || coins.isEmpty) return;
    setState(() => _isFetchingMarketData = true);

    final coinGeckoCoinsList = await fetchAllCoinGeckoCoins();

    List<String> coinGeckoIds = coins
        .map((walletCoin) {
          // if there is a coin gecko id set use that instead of trying to match ( trying to match can have issues as symbols are not unique and the names may not match )
          if (walletCoin.coinGeckoId != null) {
            return walletCoin.coinGeckoId!;
          }
          final matchingCoin = coinGeckoCoinsList.firstWhere(
            (coin) =>
                coin.symbol.toLowerCase() == walletCoin.symbol?.toLowerCase(),
            orElse: () =>
                CoinGeckoCoin(id: '', symbol: '', name: 'Unknown Token'),
          );
          return matchingCoin.id.isNotEmpty ? matchingCoin.id : null;
        })
        .whereType<String>()
        .toList();

    if (coinGeckoIds.isNotEmpty) {
      final marketData = await fetchCoinsMarketData(coinIds: coinGeckoIds);

      if (!mounted) return;

      setState(() {
        _marketData = marketData;
        _isFetchingMarketData = false;
      });

      _calculateTotalValue(coins);
    } else {
      setState(() => _isFetchingMarketData = false);
    }
  }

  void _calculateTotalValue(List<Coin> coins) {
    double totalValue = 0.0;

    for (var coin in coins) {
      final marketData = _marketData[coin.symbol?.toLowerCase()];
      if (marketData != null) {
        totalValue += (coin.balance ?? 0.0) * marketData.currentPrice;
      }
    }

    final formattedTotal = totalValue.toStringAsFixed(2);

    // ✅ Set it in the cubit
    context.read<WalletDetailsCubit>().setSelectedWalletBalance(formattedTotal);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();

        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
        }

        if (state.coinsStatus == WalletStatus.successful) {
          _fetchMarketData(state.coins);
        }
      },
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          final walletCubit = context.read<WalletDetailsCubit>();

          if (state.coinsStatus == WalletStatus.loading) {
            return const Card(
              color: GeniusWalletColors.deepBlueCardColor,
              shadowColor: Colors.transparent,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.coins.isEmpty) {
            return const Card(
              color: GeniusWalletColors.deepBlueCardColor,
              shadowColor: Colors.transparent,
              child: AutoSizeText(
                'No Coins Detected',
                style: TextStyle(
                    fontSize: 24, color: GeniusWalletColors.btnTextDisabled),
              ),
            );
          }

          final filteredCoins = state.coins
              .where((coin) =>
                  widget.filterCoins?.contains(coin) == false ||
                  widget.filterCoins == null)
              .toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                for (int i = 0; i < filteredCoins.length; i++) ...[
                  CoinCardRow(
                    onTap: () {
                      final coin = filteredCoins[i];
                      if (widget.onCoinSelected != null) {
                        widget.onCoinSelected!(coin);
                      } else {
                        walletCubit.selectCoin(coin);
                        context.push(
                          '/token-info',
                          extra: {
                            "isGnusWalletConnected":
                                widget.isGnusWalletConnected,
                            "securityInfo": "Coming Soon",
                            "transactionHistory": ["Coming Soon"],
                            "marketData":
                                _marketData[coin.symbol?.toLowerCase()]
                          },
                        );
                      }
                    },
                    iconPath: filteredCoins[i].iconPath ?? "",
                    balance: filteredCoins[i].balance ?? 0.0,
                    name: filteredCoins[i].name ?? "",
                    symbol: filteredCoins[i].symbol ?? "",
                    marketData:
                        _marketData[filteredCoins[i].symbol?.toLowerCase()],
                  ),
                  if ((widget.isUseDivider ?? false) &&
                      i != filteredCoins.length - 1)
                    const Divider(
                      thickness: 2.0,
                      color: GeniusWalletColors.deepBlueTertiary,
                      height: 1,
                    ),
                  if (!(widget.isUseDivider ?? false) &&
                      i != filteredCoins.length - 1)
                    const SizedBox(height: 8),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
