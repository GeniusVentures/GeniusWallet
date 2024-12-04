import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/app/widgets/loading/loading.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

class CoinsScreen extends StatelessWidget {
  final Function(Coin)? onCoinSelected;

  /// Coins you wish to filter out from the list of coins
  final List<Coin?>? filterCoins;

  const CoinsScreen({Key? key, this.onCoinSelected, this.filterCoins})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
      builder: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();
        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
          return const SizedBox();
        }
        if (state.coinsStatus == WalletStatus.loading) {
          return const CoinCardContainer(
              child: Center(child: Loading(text: 'Loading Coins')));
        }
        if (state.coins.isEmpty) {
          return const CoinCardContainer(
              child: Center(
                  child: AutoSizeText('No Coins Detected',
                      style: TextStyle(
                          fontSize: 24,
                          color: GeniusWalletColors.btnTextDisabled))));
        }

        return Wrap(
          runSpacing: 8,
          children: [
            for (var coin in state.coins)
              if (filterCoins?.contains(coin) == false || filterCoins == null)
                GestureDetector(
                  onTap: () {
                    if (onCoinSelected != null) {
                      onCoinSelected!(coin);
                    }
                  },
                  child: CoinCardContainer(
                      child: CoinCardRow(
                          iconPath: coin.iconPath ?? "",
                          balance: coin.balance ?? 0.0,
                          name: coin.name ?? "",
                          symbol: coin.symbol ?? "",
                          additionalCardWidget: coin.symbol?.toLowerCase() ==
                                  'gnus'
                              ? TextButton(
                                  onPressed: coin.balance == 0
                                      ? null
                                      : () {
                                          context.push('/bridge',
                                              extra: context
                                                  .read<WalletDetailsCubit>());
                                        },
                                  child: const Text("Bridge Tokens"))
                              : null)),
                ),
          ],
        );
      },
    );
  }
}

class CoinCardRow extends StatelessWidget {
  final String iconPath;
  final String name;
  final String symbol;
  final double balance;
  final Widget? additionalCardWidget;
  const CoinCardRow(
      {Key? key,
      required this.iconPath,
      required this.name,
      required this.balance,
      required this.symbol,
      this.additionalCardWidget})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            iconPath,
            height: 48,
            width: 48,
            errorBuilder: (context, error, stackTrace) {
              return const SizedBox(height: 48, width: 48);
            },
          ),
          const SizedBox(width: 12),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AutoSizeText(name),
                ],
              ),
              Row(
                children: [
                  AutoSizeText(
                    style: const TextStyle(color: GeniusWalletColors.gray500),
                    balance == 0 ? '0' : balance.toDouble().toStringAsFixed(5),
                  ),
                  const SizedBox(width: 8),
                  AutoSizeText(
                    style: const TextStyle(color: GeniusWalletColors.gray500),
                    symbol,
                  )
                ],
              )
            ],
          ),
        ],
      ),
      Container(child: additionalCardWidget ?? additionalCardWidget)
    ]);
  }
}

class CoinCardContainer extends StatelessWidget {
  final Widget child;
  const CoinCardContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
      decoration: const BoxDecoration(
        color: GeniusWalletColors.deepBlueCardColor,
        borderRadius: BorderRadius.all(
          Radius.circular(GeniusWalletConsts.borderRadiusCard),
        ),
      ),
      child: child,
    );
  }
}
