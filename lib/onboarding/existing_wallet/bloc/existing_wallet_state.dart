part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final FlowStep currentStep;

  final String selectedWallet;

  final String createdPin;


  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = FlowStep.legal,
    this.selectedWallet = '',
    this.createdPin = '',
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    FlowStep? currentStep,
    String? selectedWallet,
    String? createdPin,
    ExistingWalletStatus? savePinStatus,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      createdPin: createdPin ?? this.createdPin,
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

enum ExistingWalletStatus {
  initial,
  loading,
  success,
  error,
}
