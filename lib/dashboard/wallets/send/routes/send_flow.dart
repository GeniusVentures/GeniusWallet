import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/screens/verify_pin_screen.dart';
import 'package:genius_wallet/dashboard/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/cubit/send_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/enter_wallet_address_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/not_enough_balance_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_details_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_confirmation_screen.dart';
import 'package:genius_wallet/dashboard/wallets/send/view/transaction_summary_screen.dart';
import 'package:go_router/go_router.dart';

class SendFlow extends StatelessWidget {
  const SendFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        switch (state.flowStep) {
          case SendFlowStep.noFunds:
            return [
              const MaterialPage(child: NotEnoughBalanceScreen()),
            ];
          case SendFlowStep.transactionSummary:
            return [
              const MaterialPage(child: DashboardScreen()),
              MaterialPage(
                child: TransactionSummaryScreen(
                  transaction: state.currentTransaction,
                  wallet:
                      context.watch<WalletDetailsCubit>().state.selectedWallet!,
                ),
              ),
            ];
          case SendFlowStep.enterPin:
            return [
              const MaterialPage(child: EnterWalletAddressScreen()),
              const MaterialPage(child: TransactionDetailsScreen()),
              const MaterialPage(child: TransactionConfirmationScreen()),
              MaterialPage(
                child: BlocBuilder<SendCubit, SendState>(
                  builder: (context, state) {
                    return VerifyPinScreen(
                      onPass: () {
                        context.read<SendCubit>().verificationPassed(context
                            .read<WalletDetailsCubit>()
                            .state
                            .selectedWallet!);
                      },
                    );
                  },
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
      onComplete: (state) {
        GoRouter.of(context).go('/dashboard');
      },
    );
  }

  void appBlocListener(BuildContext context, dynamic state) {
    /// TODO: Need to check if wallet reflects balance
    /// Once wallets are fetched successfully, we want to update the selected wallet
    /// to reflect the new balance.
    // if (state.fetchWalletsStatus == WalletsOverviewStatus.success &&
    //     context.read<SendCubit>().state.transactionPostingStatus ==
    //         TransactionPostingStatus.success) {
    //   final walletCubit = context.read<WalletDetailsCubit>();

    //   final wallet = walletCubit.state.selectedWallet!;

    //   final updatedWallet = state.wallets
    //       .firstWhere((element) => element.address == wallet.address);

    //   /// Update wallet to reflect new balance information.
    //   walletCubit.selectWallet(updatedWallet);

    //   context.read<SendCubit>().walletsUpdatedSuccessfully();
    // }
  }
}
