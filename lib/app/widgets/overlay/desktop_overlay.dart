import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/overlay/desktop_tab_bar.dart';
import 'package:genius_wallet/app/widgets/overlay/selected_wallet_and_network.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class DesktopOverlay extends StatelessWidget {
  final Widget child;
  const DesktopOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          backgroundColor: GeniusWalletColors.deepBlueTertiary,
          body: BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final result =
                  getSelectedWalletAndNetwork(context, state.wallets);
              final selectedWallet = result.wallet;
              final selectedNetwork = result.network;
              return BlocProvider(
                  create: (context) => WalletDetailsCubit(
                        geniusApi: context.read<GeniusApi>(),
                        networkTokensProvider:
                            context.read<NetworkTokensProvider>(),
                        initialState: WalletDetailsState(
                            selectedWallet: selectedWallet,
                            selectedWalletBalance:
                                selectedWallet.balance.toString(),
                            selectedNetwork: selectedNetwork),
                      ),
                  child: Column(
                    children: [
                      const DesktopTopBar(),
                      Expanded(child: child),
                    ],
                  ));
            },
          )),
    );
  }
}
