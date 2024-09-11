import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'send_state.dart';

class SendCubit extends Cubit<SendState> {
  final GeniusApi geniusApi;
  SendCubit({
    required SendState initialState,
    required this.geniusApi,
  }) : super(initialState);

  void addressUpdated(String address) {
    emit(state.copyWith(
      currentTransaction: state.currentTransaction.copyWith(toAddress: address),
      flowStep: SendFlowStep.enterAddress,
    ));
  }

  void addressConfirmed() {
    // TODO: Do we need to do verification for the address here?
    emit(state.copyWith(flowStep: SendFlowStep.transactionDetails));
  }

  void amountConfirmed(String amountToSend, num gasFees, num availableBalance) {
    final amountParsed = num.tryParse(amountToSend);

    if (amountParsed == null) {
      emit(state.copyWith(
        sendStatus: SendStatus.invalidValue,
        // flowStep: SendFlowStep.transactionDetails,
      ));
    }

    /// Verify whether the user can send [amountParsed]
    final totalAmountToSend = amountParsed! + gasFees;
    if (totalAmountToSend > availableBalance) {
      emit(state.copyWith(
        sendStatus: SendStatus.notEnoughBalance,
        flowStep: SendFlowStep.transactionDetails,
      ));
    } else {
      final transaction = state.currentTransaction.copyWith(
        timeStamp: DateTime.now(),
        amount: amountParsed.toString(),
        fees: gasFees.toString(),
      );
      emit(state.copyWith(
        sendStatus: SendStatus.allowed,
        currentTransaction: transaction,
        flowStep: SendFlowStep.transactionConfirmation,
      ));
    }
  }

  void transactionConfirmed() {
    emit(state.copyWith(flowStep: SendFlowStep.enterPin));
  }

  Future<void> verificationPassed(Wallet fromWallet) async {
    emit(state.copyWith(
      transactionPostingStatus: TransactionPostingStatus.loading,
    ));

    try {
      final transactionResult =
          await geniusApi.postTransaction(state.currentTransaction);
      emit(state.copyWith(
        currentTransaction: transactionResult,
        transactionPostingStatus: TransactionPostingStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        transactionPostingStatus: TransactionPostingStatus.error,
      ));
    }
  }

  /// Method to be called once wallets are updated in order to be able to display
  /// up-to-date information in the transaction summary screen.
  void walletsUpdatedSuccessfully() {
    emit(state.copyWith(flowStep: SendFlowStep.transactionSummary));
  }
}
