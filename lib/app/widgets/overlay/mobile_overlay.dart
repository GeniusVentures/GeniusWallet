import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/reown/reown_connect_button.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_tabbar.dart';
import 'package:genius_wallet/app/widgets/overlay/selected_wallet_and_network.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final result = getSelectedWalletAndNetwork(context, state.wallets);
      final selectedWallet = result.wallet;
      final selectedNetwork = result.network;
      final walletDetailsCubit = WalletDetailsCubit(
          geniusApi: context.read<GeniusApi>(),
          networkTokensProvider: context.read<NetworkTokensProvider>(),
          initialState: WalletDetailsState(
              selectedWallet: selectedWallet,
              selectedWalletBalance: selectedWallet.balance.toString(),
              selectedNetwork: selectedNetwork));

      return BlocProvider(
          create: (context) => walletDetailsCubit,
          child: Scaffold(
            extendBody: true, // ✅ Allows content to be visible under the navbar
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const NetworkDropdownSelector(),
                        const Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: AccountDropdownSelector(),
                          ),
                        ),
                        ReownConnectButton(
                            walletAddress: selectedWallet.address,
                            geniusApi: context.read<GeniusApi>(),
                            walletDetailsCubit: walletDetailsCubit),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(child: child),
                ],
              ),
            ),
            bottomNavigationBar:
                const GeniusTabbar(), // ✅ Wrapped inside a container for transparency
          ));
    });
  }
}
