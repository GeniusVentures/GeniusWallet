part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final FlowStep currentStep;

  final String selectedWallet;

  final int selectedCoinType;

  final ExistingWalletStatus importWalletStatus;

  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = FlowStep.legal,
    this.selectedWallet = '',
    this.selectedCoinType = TWCoinType.TWCoinTypeEthereum,
    this.importWalletStatus = ExistingWalletStatus.initial,
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    FlowStep? currentStep,
    String? selectedWallet,
    int? selectedCoinType,
    ExistingWalletStatus? importWalletStatus,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      selectedCoinType: selectedCoinType ?? this.selectedCoinType,
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
