import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';
import 'package:go_router/go_router.dart';

class HorizontalWalletsScrollview extends StatelessWidget {
  const HorizontalWalletsScrollview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        return SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.wallets.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final currentWallet = state.wallets[index];
              return SizedBox(
                height: 100,
                width: 200,
                child: LayoutBuilder(builder: (context, constraints) {
                  return MaterialButton(
                    onPressed: () {
                      context.push('/wallets/${currentWallet.address}');
                    },
                    child: WalletPreview(
                      constraints,
                      ovrWalletBalance: currentWallet.balance.toString(),
                      ovrCoinType: currentWallet.currencyName,
                      ovrCoinSymbol: currentWallet.currencySymbol,
                      ovrCoinIcon: WalletUtils.currencySymbolToImage(
                          currentWallet.currencySymbol),
                    ),
                  );
                }),
              );
            },
          ),
        );
      },
    );
  }
}
