import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/continue_button/isactive_true.g.dart';
import 'package:genius_wallet/widgets/components/text_entry_field_widget.g.dart';
import 'package:genius_wallet/widgets/components/transaction_detail_tile.g.dart';
import 'package:genius_wallet/widgets/text_form_field_logic.g.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<WalletCubit>().getCurrentFees();
    final formKey = GlobalKey<FormState>();
    return Scaffold(
      body: Form(
        key: formKey,
        child: AppScreenView(
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return BackButtonHeader(
                        constraints,
                        ovrTitle: 'Transaction details',
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
                        ovrLeftfield: 'Available Balance',
                        ovrAmount: context
                            .read<WalletCubit>()
                            .state
                            .selectedWallet!
                            .balance
                            .toString(),
                      );
                    },
                  ),
                ),
                SizedBox(
                  height: 40,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return BlocBuilder<WalletCubit, WalletState>(
                        builder: (context, state) {
                          if (state.gasFeesStatus == WalletStatus.successful) {
                            return TransactionDetailTile(
                              constraints,
                              ovrLeftfield: 'Gas Fee',
                              ovrAmount: context
                                  .watch<WalletCubit>()
                                  .state
                                  .gasFees
                                  .toString(),
                            );
                          }
                          return Container();
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text('Enter Amount'),
                ),
                const SizedBox(height: 20),
                TextEntryFieldWidget(
                  logic: TextFormFieldLogic(
                    context,
                    hintText: 'Enter Amount',
                    keyboardType: const TextInputType.numberWithOptions(),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d*)?')),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter an amount to send';
                      }

                      context.read<SendCubit>().amountConfirmed(
                            value,
                            context.read<WalletCubit>().state.gasFees,
                            context
                                .read<WalletCubit>()
                                .state
                                .selectedWallet!
                                .balance,
                          );

                      final state = context.read<SendCubit>().state;

                      switch (state.sendStatus) {
                        case SendStatus.notEnoughBalance:
                          return 'You have insufficient funds';
                        case SendStatus.invalidValue:
                          return 'Invalid value';
                        default:
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  height: 50,
                  child: LayoutBuilder(
                    builder:
                        (BuildContext context, BoxConstraints constraints) {
                      return MaterialButton(
                        onPressed: () {
                          formKey.currentState!.validate();
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
            ),
          ),
        ),
      ),
    );
  }
}
