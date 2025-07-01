part of 'new_wallet_bloc.dart';

abstract class NewWalletEvent {}

class LoadRecoveryPhrase extends NewWalletEvent {}

class RecoveryPhraseContinue extends NewWalletEvent {}

class RecoveryWordTapped extends NewWalletEvent {
  final String wordTapped;

  RecoveryWordTapped({
    required this.wordTapped,
  });
}

class RecoveryWordAssign extends NewWalletEvent {
  final List<String> recoverywords;
  RecoveryWordAssign({
    required this.recoverywords,
  });
}

/// Event thrown when the user acknowledges the recovery phrase they received
class RecoveryVerificationContinue extends NewWalletEvent {}

class RecoveryVerificationContinueForMobile extends NewWalletEvent {}

class ToggleCheckbox extends NewWalletEvent {}

class AddWallet extends NewWalletEvent {
  final HDWallet wallet;

  AddWallet({required this.wallet});
}

class AgreementAccepted extends NewWalletEvent {
  final bool userExists;

  AgreementAccepted({required this.userExists});
}

class PinCreated extends NewWalletEvent {}

class PinConfirmPassed extends NewWalletEvent {}

class PinConfirmFailed extends NewWalletEvent {}
