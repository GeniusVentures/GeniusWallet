part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  bool acceptedLegal;

  FlowStep currentStep;

  String selectedWallet;

  ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = FlowStep.legal,
    this.selectedWallet = '',
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    FlowStep? currentStep,
    String? selectedWallet,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
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
