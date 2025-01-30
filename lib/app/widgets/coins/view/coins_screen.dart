import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/models/coin_gecko_coin.dart';
import 'package:genius_wallet/providers/coin_gecko_coin_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;
  final bool? isGnusWalletConnected;

  const CoinsScreen({
    Key? key,
    this.onCoinSelected,
    this.filterCoins,
    this.isGnusWalletConnected,
  }) : super(key: key);

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  /// Store market data including current price, 24h price change & percentage
  Map<String, Map<String, double>> _marketData = {};
  bool _isFetchingMarketData = false;

  /// **Fetches market prices for all coins in the wallet**
  Future<void> _fetchMarketData(List<Coin> coins) async {
    if (_isFetchingMarketData || coins.isEmpty)
      return; // Prevent duplicate calls
    setState(() => _isFetchingMarketData = true);

    final coinGeckoCoinsList =
        Provider.of<CoinGeckoCoinProvider>(context, listen: false).coins;

    // Extract CoinGecko IDs for wallet coins
    List<String> coinGeckoIds = coins
        .map((walletCoin) {
          final matchingCoin = coinGeckoCoinsList.firstWhere(
            (coin) =>
                coin.symbol.toLowerCase() == walletCoin.symbol?.toLowerCase(),
            orElse: () =>
                CoinGeckoCoin(id: '', symbol: '', name: 'Unknown Token'),
          );
          return matchingCoin.id.isNotEmpty ? matchingCoin.id : null;
        })
        .whereType<String>()
        .toList(); // Remove nulls

    if (coinGeckoIds.isNotEmpty) {
      final marketData = await fetchCoinsMarketData(coinIds: coinGeckoIds);
      setState(() {
        _marketData = marketData.map((id, data) => MapEntry(
              data['symbol'].toLowerCase(),
              {
                'current_price': data['current_price'] ?? 0.0,
                'price_change_24h': data['price_change_24h'] ?? 0.0,
                'price_change_percentage_24h':
                    data['price_change_percentage_24h'] ?? 0.0,
              },
            ));
        _isFetchingMarketData = false;
      });
    } else {
      setState(() => _isFetchingMarketData = false);
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

        // Only fetch market data when coins have been successfully loaded
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
                          },
                        );
                      }
                    },
                    iconPath: coin.iconPath ?? "",
                    balance: coin.balance ?? 0.0,
                    name: coin.name ?? "",
                    symbol: coin.symbol ?? "",
                    price: _marketData[coin.symbol?.toLowerCase()]
                            ?['current_price'] ??
                        0.0,
                    priceChange24h: _marketData[coin.symbol?.toLowerCase()]
                            ?['price_change_24h'] ??
                        0.0,
                    priceChangePercentage24h:
                        _marketData[coin.symbol?.toLowerCase()]
                                ?['price_change_percentage_24h'] ??
                            0.0,
                  ),
            ],
          );
        },
      ),
    );
  }
}
