import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';
import 'package:go_router/go_router.dart';

class HorizontalWalletsScrollview extends StatelessWidget {
  const HorizontalWalletsScrollview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return () {
          if (state.wallets.isEmpty) {
            return const Center(
                child: AutoSizeText(
              "You Have No Wallets!",
              style: TextStyle(fontSize: 20),
            ));
          }
          return ListView.separated(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            itemCount: state.wallets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final currentWallet = state.wallets[index];
              return SizedBox(
                width: 350,
                child: LayoutBuilder(builder: (context, constraints) {
                  return MaterialButton(
                    shape: const ContinuousRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(
                            GeniusWalletConsts.borderRadiusCard))),
                    color: GeniusWalletColors.deepBlueCardColor,
                    onPressed: () {
                      context.push('/wallets/${currentWallet.address}');
                    },
                    child: WalletPreview(constraints,
                        ovrWalletBalance: currentWallet.balance == 0
                            ? '0'
                            : currentWallet.balance.toStringAsFixed(3),
                        walletAddress: currentWallet.address,
                        walletType: currentWallet.walletType,
                        ovrCoinSymbol: currentWallet.currencySymbol,
                        walletName: currentWallet.walletName),
                  );
                }),
              );
            },
          );
        }();
      },
    );
  }
}
