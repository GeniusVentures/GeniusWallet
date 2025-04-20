import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/reown_connect_button.dart';
import 'package:genius_wallet/components/overlay/genius_tabbar.dart';
import 'package:genius_wallet/components/overlay/selected_wallet_and_network.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/account/account_dropdown_selector.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class MobileOverlay extends StatelessWidget {
  final Widget child;
  const MobileOverlay({Key? key, required this.child}) : super(key: key);

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
          selectedNetwork: selectedNetwork,
        ),
      );

      return FutureBuilder<List<Transaction>>(
        future:
            TransactionStorageService().getTransactions(selectedWallet.address),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final existingTransactions = snapshot.data!;

          TransactionsCubit transactionCubit =
              TransactionsCubit(initial: existingTransactions);

          return MultiBlocProvider(
            providers: [
              BlocProvider(create: (_) => walletDetailsCubit),
              BlocProvider(
                create: (_) => transactionCubit,
              ),
            ],
            child: Scaffold(
              extendBody: true,
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
                              walletDetailsCubit: walletDetailsCubit,
                              transactionsCubit: transactionCubit),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(child: child),
                  ],
                ),
              ),
              bottomNavigationBar: const GeniusTabbar(),
            ),
          );
        },
      );
    });
  }
}
