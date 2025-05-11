import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/selected_wallet_and_network.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class WalletCubitsInitializer extends StatelessWidget {
  final Widget child;

  const WalletCubitsInitializer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (context, state) {
        // Wait until wallets are available
        if (state.wallets.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

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
          future: TransactionStorageService()
              .getTransactions(selectedWallet.address),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final existingTransactions = snapshot.data!;

            return MultiBlocProvider(
              providers: [
                BlocProvider(create: (_) => walletDetailsCubit),
                BlocProvider(
                  create: (_) =>
                      TransactionsCubit(initial: existingTransactions),
                ),
              ],
              child: child,
            );
          },
        );
      },
    );
  }
}
