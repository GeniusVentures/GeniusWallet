import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/utils/wallet_utils.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/transaction_detail_tile.g.dart';

class TransactionConfirmationScreen extends StatelessWidget {
  const TransactionConfirmationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueSecondary,
      body: AppScreenView(
        body: BlocBuilder<SendCubit, SendState>(
          builder: (context, state) {
            return Column(children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: 'Transaction Summary',
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(children: [
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
                              '${state.currentTransaction.recipients.first.amount} ${context.read<WalletDetailsCubit>().state.selectedWallet!.currencySymbol}',
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
                          ovrLeftfield: 'From Wallet',
                          ovrAmount: WalletUtils.getAddressForDisplay(
                              state.currentTransaction.fromAddress),
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
                          ovrLeftfield: 'To Wallet',
                          ovrAmount: WalletUtils.getAddressForDisplay(
                              state.currentTransaction.recipients.first.amount),
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
                ]),
              )
            ]);
          },
        ),
      ),
    );
  }
}
