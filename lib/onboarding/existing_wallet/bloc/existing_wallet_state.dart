part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final bool failedPinVerification;

  final FlowStep currentStep;

  final String selectedWallet;

  final String createdPin;

  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = FlowStep.legal,
    this.selectedWallet = '',
    this.createdPin = '',
    this.failedPinVerification = false,
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    bool? failedPinVerification,
    FlowStep? currentStep,
    String? selectedWallet,
    String? createdPin,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      createdPin: createdPin ?? this.createdPin,
      failedPinVerification:
          failedPinVerification ?? this.failedPinVerification,
    );
  }
}

enum FlowStep {
  legal,
  createPasscode,
  confirmPasscode,
  importWallet,
  importWalletSecurity,
  createPin,
  confirmPin,
}
