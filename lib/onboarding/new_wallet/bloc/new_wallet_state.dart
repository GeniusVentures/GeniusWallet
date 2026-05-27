part of 'new_wallet_bloc.dart';

class NewWalletState extends Equatable {
  final NewWalletStep currentStep;
  final NewWalletStatus recoveryPhraseStatus;

  final List<String> recoveryWords;
  final List<String> shuffledWords;
  final List<String> selectedWords;

  final VerificationStatus verificationStatus;

  final bool acceptedWarning;

  final NewWalletStatus walletSaveStatus;

  const NewWalletState({
    this.currentStep = NewWalletStep.agreement,
    this.recoveryPhraseStatus = NewWalletStatus.initial,
    this.recoveryWords = const [],
    this.shuffledWords = const [],
    this.selectedWords = const [],
    this.verificationStatus = VerificationStatus.intial,
    this.acceptedWarning = false,
    this.walletSaveStatus = NewWalletStatus.initial,
  });

  NewWalletState copyWith({
    NewWalletStep? currentStep,
    NewWalletStatus? recoveryPhraseStatus,
    List<String>? recoveryWords,
    List<String>? shuffledWords,
    List<String>? selectedWords,
    VerificationStatus? verificationStatus,
    bool? acceptedWarning,
    NewWalletStatus? walletSaveStatus,
  }) {
    return NewWalletState(
      currentStep: currentStep ?? this.currentStep,
      recoveryPhraseStatus: recoveryPhraseStatus ?? this.recoveryPhraseStatus,
      recoveryWords: recoveryWords ?? this.recoveryWords,
      shuffledWords: shuffledWords ?? this.shuffledWords,
      selectedWords: selectedWords ?? this.selectedWords,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      acceptedWarning: acceptedWarning ?? this.acceptedWarning,
      walletSaveStatus: walletSaveStatus ?? this.walletSaveStatus,
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        recoveryPhraseStatus,
        recoveryWords,
        shuffledWords,
        selectedWords,
        verificationStatus,
        acceptedWarning,
        walletSaveStatus,
      ];
}

enum NewWalletStep {
  agreement,
  copyPhrase,
  verifyRecoveryPhrase,
  createPin,
  confirmPin,
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
