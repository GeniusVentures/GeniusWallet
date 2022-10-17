import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_cubit.dart';
import 'package:genius_wallet/app/bloc/verification_cubit.dart';
import 'package:genius_wallet/app/screens/pin_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/enter_wallet_address_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_details_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_confirmation_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_summary_screen.dart';

class SendFlow extends StatelessWidget {
  const SendFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.flowStep) {
          case SendFlowStep.transactionSummary:
            return [
              const MaterialPage(child: TransactionSummaryScreen()),
            ];
          case SendFlowStep.enterPin:
            return [
              const MaterialPage(child: EnterWalletAddressScreen()),
              const MaterialPage(child: TransactionDetailsScreen()),
              const MaterialPage(child: TransactionConfirmationScreen()),
              MaterialPage(
                child: BlocProvider(
                  create: (context) => PinCubit(pinMaxLength: 6),
                  child: BlocListener<VerificationCubit, VerificationState>(
                    listener: (context, state) {
                      if (state == VerificationState.fail) {
                        context.read<PinCubit>().pinConfirmFailed();
                      } else if (state == VerificationState.pass) {
                        context.read<SendCubit>().verificationPassed();
                      }
                    },
                    child: PinScreen(
                      text: 'Enter your pin',
                      onCompleted: context.read<VerificationCubit>().verifyPin,
                    ),
                  ),
                ),
              ),
            ];
          case SendFlowStep.transactionConfirmation:
            return [
              const MaterialPage(child: EnterWalletAddressScreen()),
              const MaterialPage(child: TransactionDetailsScreen()),
              const MaterialPage(child: TransactionConfirmationScreen())
            ];
          case SendFlowStep.transactionDetails:
            return [
              const MaterialPage(child: EnterWalletAddressScreen()),
              const MaterialPage(child: TransactionDetailsScreen()),
            ];
          case SendFlowStep.enterAddress:
          default:
            return [
              const MaterialPage(child: EnterWalletAddressScreen()),
            ];
        }
      },
      state: context.watch<SendCubit>().state,
    );
  }
}
