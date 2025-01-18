import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_container.dart';
import 'package:genius_wallet/app/widgets/coins/view/coin_card_row.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;

  const CoinsScreen({Key? key, this.onCoinSelected, this.filterCoins})
      : super(key: key);

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();

        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
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
                        // Navigate to TokenInfoScreen
                        context.push(
                          '/token-info',
                          extra: {
                            "tokenName": coin.name ?? "Unknown",
                            "tokenIconPath": coin.iconPath ?? "",
                            "currentPrice":
                                100.0, // Replace with actual price data
                            "priceChange":
                                5.0, // Replace with actual price change
                            "priceChangePercent":
                                2.5, // Replace with actual percentage
                            "userBalance": coin.balance ?? 0.0,
                            "tokenSymbol": coin.symbol ?? "",
                            "tokenAddress": coin.address ?? "",
                            "securityInfo": "Secure Token",
                            "transactionHistory": [
                              "Tx1",
                              "Tx2"
                            ], // Replace with actual history
                          },
                        );
                      }
                    },
                    iconPath: coin.iconPath ?? "",
                    balance: coin.balance ?? 0.0,
                    name: coin.name ?? "",
                    symbol: coin.symbol ?? "",
                  ),
            ],
          );
        },
      ),
    );
  }
}
