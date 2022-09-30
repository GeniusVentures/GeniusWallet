part of 'new_wallet_bloc.dart';

class NewWalletState {
  final NewWalletStep currentStep;
  final NewWalletStatus recoveryPhraseStatus;
  final NewWalletStatus recoveryPhraseCopied;
  final List<String> recoveryWords;

  const NewWalletState({
    this.currentStep = NewWalletStep.copyPhrase,
    this.recoveryPhraseStatus = NewWalletStatus.initial,
    this.recoveryPhraseCopied = NewWalletStatus.initial,
    this.recoveryWords = const [],
  });

  NewWalletState copyWith({
    NewWalletStep? currentStep,
    NewWalletStatus? recoveryPhraseStatus,
    NewWalletStatus? recoveryPhraseCopied,
    List<String>? recoveryWords,
  }) {
    return NewWalletState(
      currentStep: currentStep ?? this.currentStep,
      recoveryPhraseStatus: recoveryPhraseStatus ?? this.recoveryPhraseStatus,
      recoveryWords: recoveryWords ?? this.recoveryWords,
      recoveryPhraseCopied: recoveryPhraseCopied ?? this.recoveryPhraseCopied,
    );
  }
}

enum NewWalletStep {
  copyPhrase,
  verifyRecoveryPhrase,
}

/// Indicates the loading status of the screen
enum NewWalletStatus {
  initial,
  loading,
  loaded,
  error,
}
