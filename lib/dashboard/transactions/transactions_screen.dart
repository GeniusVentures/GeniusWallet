import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';

import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletDetailsCubit>().getCoins();
          },
          child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            builder: (context, walletState) {
              final selectedWallet = walletState.selectedWallet;
              final isSgnusWallet =
                  selectedWallet?.walletType == WalletType.sgnus;

              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: isSgnusWallet
                      ? const SgnusTransactionsScreen()
                      : const TransactionsStream(),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
