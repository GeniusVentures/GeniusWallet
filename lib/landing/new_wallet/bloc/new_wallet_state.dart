part of 'new_wallet_bloc.dart';

class NewWalletState {
  final NewWalletStep currentStep;

  const NewWalletState({
    this.currentStep = NewWalletStep.copyPhrase,
  });

  NewWalletState copyWith({
    NewWalletStep? currentStep,
  }) {
    return NewWalletState(
      currentStep: currentStep ?? this.currentStep,
    );
  }
}

enum NewWalletStep {
  copyPhrase,
  verifyRecoveryPhrase,
}
