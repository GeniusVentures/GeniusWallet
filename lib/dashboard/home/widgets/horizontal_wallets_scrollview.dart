import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/view/wallet_details_screen.dart';
import 'package:genius_wallet/widgets/components/wallet_preview.g.dart';

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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => WalletCubit(
                              initialState: WalletState(
                                selectedWallet: currentWallet,
                              ),
                              geniusApi: context.read<GeniusApi>(),
                            ),
                            child: const WalletDetailsScreen(),
                          ),
                        ),
                      );
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
