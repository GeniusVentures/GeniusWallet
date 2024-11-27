import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/loading/loading.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class CoinsScreen extends StatelessWidget {
  const CoinsScreen({Key? key}) : super(key: key);

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
          return const CardContainer(
              child: Center(child: Loading(text: 'Loading Coins')));
        }
        if (state.coins.isEmpty) {
          return const CardContainer(
              child: Center(
                  child: AutoSizeText('No Coins Detected',
                      style: TextStyle(
                          fontSize: 24,
                          color: GeniusWalletColors.btnTextDisabled))));
        }

        return Wrap(runSpacing: 8, children: [
          for (var coin in state.coins)
            CardContainer(
                child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Image.asset(coin.iconPath ?? "", height: 48, width: 48,
                      errorBuilder: (context, error, stackTrace) {
                    return const SizedBox(height: 48, width: 48);
                  }),
                  const SizedBox(width: 12),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          AutoSizeText(coin.name ?? ""),
                        ]),
                        Row(children: [
                          AutoSizeText(
                              style: const TextStyle(
                                  color: GeniusWalletColors.gray500),
                              coin.balance?.toDouble().toStringAsFixed(5) ??
                                  ""),
                          const SizedBox(width: 8),
                          AutoSizeText(
                              style: const TextStyle(
                                  color: GeniusWalletColors.gray500),
                              coin.symbol ?? "")
                        ])
                      ]),
                ])),
        ]);
      },
    );
  }
}

class CardContainer extends StatelessWidget {
  final Widget child;
  const CardContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 80,
        width: MediaQuery.of(context).size.width,
        padding:
            const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 12),
        decoration: const BoxDecoration(
            color: GeniusWalletColors.deepBlueCardColor,
            borderRadius: BorderRadius.all(
                Radius.circular(GeniusWalletConsts.borderRadiusCard))),
        child: child);
  }
}
