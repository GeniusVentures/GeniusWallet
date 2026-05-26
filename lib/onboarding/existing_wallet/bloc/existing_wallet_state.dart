part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final ImportWalletStep currentStep;

  final String selectedWallet;

  final TWCoinType selectedCoinType;

  final ExistingWalletStatus importWalletStatus;

  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = ImportWalletStep.legal,
    this.selectedWallet = '',
    this.selectedCoinType = TWCoinType.TWCoinTypeEthereum,
    this.importWalletStatus = ExistingWalletStatus.initial,
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    ImportWalletStep? currentStep,
    String? selectedWallet,
    TWCoinType? selectedCoinType,
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

enum ImportWalletStep {
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
