import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/components/overlay/gw_bottom_nav.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Mobile shell. Owns the persistent chrome (network selector, wallet
/// selector, WalletConnect button + bottom nav). Each screen renders its
/// own content below.
class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: GeniusWalletColors.surfaceBase,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const DevToolsWidget(),
            const _OverlayTopBar(),
            Expanded(child: child),
          ],
        ),
      ),
      bottomNavigationBar: const GWBottomNav(),
    );
  }
}

class _OverlayTopBar extends StatelessWidget {
  const _OverlayTopBar();

  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletDetailsCubit>();
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: GeniusWalletConsts.space2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NetworkDropdownSelector(),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space4,
              ),
              child: const AccountDropdownSelector(),
            ),
          ),
          ReownConnectButton(
            walletAddress: walletCubit.state.selectedWallet?.address ??
                '0x0000000000000000000000000000000000000000',
            geniusApi: context.read<GeniusApi>(),
            walletDetailsCubit: walletCubit,
            transactionsCubit: context.read<TransactionsCubit>(),
          ),
        ],
      ),
    );
  }
}
