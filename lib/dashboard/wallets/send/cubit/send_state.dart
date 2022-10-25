part of 'send_cubit.dart';

class SendState extends Equatable {
  final Transaction currentTransaction;
  final SendFlowStep flowStep;

  /// Status on whether the user is allowed to perform the transaction.
  final SendStatus sendStatus;

  /// Status on posting the transaction
  final TransactionPostingStatus transactionPostingStatus;

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
    this.transactionPostingStatus = TransactionPostingStatus.initial,
  });

  SendState copyWith({
    SendFlowStep? flowStep,
    SendStatus? sendStatus,
    Transaction? currentTransaction,
    TransactionPostingStatus? transactionPostingStatus,
  }) {
    return SendState(
      flowStep: flowStep ?? this.flowStep,
      sendStatus: sendStatus ?? this.sendStatus,
      currentTransaction: currentTransaction ?? this.currentTransaction,
      transactionPostingStatus:
          transactionPostingStatus ?? this.transactionPostingStatus,
    );
  }

  @override
  List<Object?> get props =>
      [currentTransaction, flowStep, sendStatus, transactionPostingStatus];
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

enum TransactionPostingStatus {
  initial,
  loading,

  error,
  success,
}
