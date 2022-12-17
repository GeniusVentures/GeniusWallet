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

class RecoveryVerificationContinue extends NewWalletEvent {}

class ToggleCheckbox extends NewWalletEvent {}

class AddWallet extends NewWalletEvent {
  final Wallet wallet;

  AddWallet({required this.wallet});
}

class ChangeStep extends NewWalletEvent {
  final NewWalletStep step;

  ChangeStep({
    required this.step,
  });
}
