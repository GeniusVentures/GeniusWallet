import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:go_router/go_router.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;
  final bool? isGnusWalletConnected;
  final Function(double)? onTotalValueCalculated;

  const CoinsScreen({
    Key? key,
    this.onCoinSelected,
    this.filterCoins,
    this.isGnusWalletConnected,
    this.onTotalValueCalculated,
  }) : super(key: key);

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
    if (widget.onTotalValueCalculated != null) {
      widget.onTotalValueCalculated!(totalValue);
    }
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
            return const CoinCardContainer(
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (state.coins.isEmpty) {
            return const CoinCardContainer(
              child: Center(
                child: AutoSizeText(
                  'No Coins Detected',
                  style: TextStyle(
                      fontSize: 24, color: GeniusWalletColors.btnTextDisabled),
                ),
              ),
            );
          }

          return Wrap(
            runSpacing: 8,
            children: [
              for (var coin in state.coins)
                if (widget.filterCoins?.contains(coin) == false ||
                    widget.filterCoins == null)
                  CoinCardRow(
                      onTap: () {
                        if (widget.onCoinSelected != null) {
                          widget.onCoinSelected!(coin);
                        } else {
                          walletCubit.selectCoin(coin);
                          context.push(
                            '/token-info',
                            extra: {
                              "walletDetailsCubit": walletCubit,
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
                      iconPath: coin.iconPath ?? "",
                      balance: coin.balance ?? 0.0,
                      name: coin.name ?? "",
                      symbol: coin.symbol ?? "",
                      marketData: _marketData[coin.symbol?.toLowerCase()]),
            ],
          );
        },
      ),
    );
  }
}
