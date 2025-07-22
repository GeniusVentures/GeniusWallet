import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/components/overlay/genius_tabbar.dart';
import 'package:genius_wallet/test/dev_tools_widget.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final walletCubit = context.read<WalletDetailsCubit>();

    return BlocBuilder<AppBloc, AppState>(builder: (context, state) {
      return Scaffold(
        extendBody: true,
        backgroundColor: GeniusWalletColors.deepBlueTertiary,
        body: SafeArea(
          child: Column(
            children: [
              const DevToolsWidget(),
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
                        walletAddress:
                            // by everston fix
                            walletCubit.state.selectedWallet?.address ??
                                '0x0000000000000000000000000000000000000000',
                        geniusApi: context.read<GeniusApi>(),
                        walletDetailsCubit: walletCubit,
                        transactionsCubit: context.read<TransactionsCubit>()),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
            ],
          ),
        ),
        bottomNavigationBar: const GeniusTabbar(),
      );
    });
  }
}
