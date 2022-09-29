part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  bool acceptedLegal;

  FlowStep currentStep;

  String selectedWallet;

  String createdPin;

  ExistingWalletState({
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
