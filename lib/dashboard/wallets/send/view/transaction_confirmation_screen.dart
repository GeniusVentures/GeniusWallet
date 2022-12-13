import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/transaction_detail_tile.g.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: BlocBuilder<SendCubit, SendState>(
            builder: (context, state) {
              return Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return BackButtonHeader(
                          constraints,
                          ovrTitle: 'Transaction Summary',
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return TransactionDetailTile(
                          constraints,
                          ovrLeftfield: 'Amount',
                          ovrAmount:
                              '${state.currentTransaction.amount} ${context.read<WalletDetailsCubit>().state.selectedWallet!.currencySymbol}',
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return TransactionDetailTile(
                          constraints,
                          ovrLeftfield: 'Fees',
                          ovrAmount:
                              '${state.currentTransaction.fees} ${context.read<WalletDetailsCubit>().state.selectedWallet!.currencySymbol}',
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 40,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return TransactionDetailTile(
                          constraints,
                          ovrLeftfield: 'Wallet',
                          ovrAmount: state.currentTransaction.toAddress,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    height: 50,
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        return MaterialButton(
                          onPressed: () {
                            context.read<SendCubit>().transactionConfirmed();
                          },
                          child: IsactiveTrue(
                            constraints,
                            ovrContinue: 'Proceed',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
