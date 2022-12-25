part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final FlowStep currentStep;

  final String selectedWallet;

  final ExistingWalletStatus importWalletStatus;

  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = FlowStep.legal,
    this.selectedWallet = '',
    this.importWalletStatus = ExistingWalletStatus.initial,
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    FlowStep? currentStep,
    String? selectedWallet,
    ExistingWalletStatus? importWalletStatus,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      importWalletStatus: importWalletStatus ?? this.importWalletStatus,
    );
  }
}

enum FlowStep {
  legal,
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
