part of 'new_wallet_bloc.dart';

class NewWalletState {
  final NewWalletStep currentStep;
  final NewWalletStatus recoveryPhraseStatus;
  final NewWalletStatus recoveryPhraseCopied;

  final List<String> recoveryWords;
  final List<String> shuffledWords;
  final List<String> selectedWords;

  final VerificationStatus verificationStatus;

  final bool acceptedWarning;

  const NewWalletState({
    this.currentStep = NewWalletStep.agreement,
    this.recoveryPhraseStatus = NewWalletStatus.initial,
    this.recoveryPhraseCopied = NewWalletStatus.initial,
    this.recoveryWords = const [],
    this.shuffledWords = const [],
    this.selectedWords = const [],
    this.verificationStatus = VerificationStatus.intial,
    this.acceptedWarning = false,
  });

  NewWalletState copyWith({
    NewWalletStep? currentStep,
    NewWalletStatus? recoveryPhraseStatus,
    NewWalletStatus? recoveryPhraseCopied,
    List<String>? recoveryWords,
    List<String>? shuffledWords,
    List<String>? selectedWords,
    VerificationStatus? verificationStatus,
    bool? acceptedWarning,
  }) {
    return NewWalletState(
      currentStep: currentStep ?? this.currentStep,
      recoveryPhraseStatus: recoveryPhraseStatus ?? this.recoveryPhraseStatus,
      recoveryWords: recoveryWords ?? this.recoveryWords,
      recoveryPhraseCopied: recoveryPhraseCopied ?? this.recoveryPhraseCopied,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      selectedWords: selectedWords ?? this.selectedWords,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      acceptedWarning: acceptedWarning ?? this.acceptedWarning,
    );
  }
}

enum NewWalletStep {
  agreement,
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

enum VerificationStatus {
  intial,
  inProgress,
  passed,
  failed,
}
