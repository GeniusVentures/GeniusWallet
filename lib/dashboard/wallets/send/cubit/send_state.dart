part of 'send_cubit.dart';

class SendState {
  final Transaction currentTransaction;
  final SendFlowStep flowStep;

  final SendStatus sendStatus;

  SendState({
    this.flowStep = SendFlowStep.enterAddress,
    this.sendStatus = SendStatus.initial,
    this.currentTransaction = const Transaction(
      hash: '',
      amount: '0',
      fromAddress: '',
      timeStamp: '',
      toAddress: '',
      transactionDirection: TransactionDirection.sent,
      fees: '',
    ),
  });

  SendState copyWith({
    SendFlowStep? flowStep,
    SendStatus? sendStatus,
    Transaction? currentTransaction,
  }) {
    return SendState(
      flowStep: flowStep ?? this.flowStep,
      sendStatus: sendStatus ?? this.sendStatus,
      currentTransaction: currentTransaction ?? this.currentTransaction,
    );
  }
}

enum SendStatus {
  initial,

  /// Allowed to perform the transaction
  allowed,

  /// Not enough balance to perform the transaction
  notEnoughBalance,
  invalidValue,
}

enum SendFlowStep {
  enterAddress,
  transactionDetails,
  transactionConfirmation,
  enterPin,
  transactionSummary,
}
