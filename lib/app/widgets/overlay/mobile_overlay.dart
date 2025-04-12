import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/widgets/hamburger_menu.dart';
import 'package:genius_wallet/app/widgets/overlay/genius_tabbar.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      final wallets = [...state.wallets];
      final walletBox = Hive.box(walletBoxName);
      final address = walletBox.get(selectedWalletKey) as String?;

      final networkBox = Hive.box(networkBoxName);
      final chainId = networkBox.get(selectedNetworkKeyChainId) as int?;
      final rpcUrl = networkBox.get(selectedNetworkKeyRpcUrl) as String?;

      final networks = Provider.of<NetworkProvider>(context).networks;

      // Fallback to first available network if no match or no saved network
      final selectedNetwork = networks.firstWhere(
          (n) => n.chainId == chainId && n.rpcUrl == rpcUrl,
          orElse: () => networks.first);

      // Fallback to first available wallet if no match or no saved address
      final selectedWallet = wallets.firstWhere(
        (w) => w.address == address,
        orElse: () => wallets.first,
      );

      return BlocProvider(
          create: (context) => WalletDetailsCubit(
                geniusApi: context.read<GeniusApi>(),
                networkTokensProvider: context.read<NetworkTokensProvider>(),
                initialState: WalletDetailsState(
                    selectedWallet: selectedWallet,
                    selectedNetwork: selectedNetwork),
              ),
          child: Scaffold(
            extendBody: true, // ✅ Allows content to be visible under the navbar
            backgroundColor: GeniusWalletColors.deepBlueTertiary,
            body: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        NetworkDropdownSelector(),
                        Expanded(
                          child: Align(
                            alignment: Alignment.center,
                            child: AccountDropdownSelector(),
                          ),
                        ),
                        HamburgerMenu(),
                      ],
                    ),
                  ),
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
