import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_scren.dart';

import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: screenHeight,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Column(
            children: [
              // Optional: Add a header or filter here
              Expanded(
                child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
                  builder: (context, walletState) {
                    final selectedWallet = walletState.selectedWallet;
                    final isSgnusWallet =
                        selectedWallet?.walletType == WalletType.sgnus;

                    return Container(
                        padding: const EdgeInsets.only(
                            left: 12, right: 12, bottom: 8),
                        child: isSgnusWallet
                            ? const SgnusTransactionsScreen()
                            : const TransactionsStream());
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
