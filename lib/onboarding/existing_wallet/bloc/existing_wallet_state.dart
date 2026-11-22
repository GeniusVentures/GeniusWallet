part of 'existing_wallet_bloc.dart';

class ExistingWalletState {
  final bool acceptedLegal;

  final ImportWalletStep currentStep;

  final String selectedWallet;

  final TWCoinType selectedCoinType;

  final ExistingWalletStatus importWalletStatus;

  /// The address the successful import added; the flow's completion reload
  /// passes it to the app bloc so the dashboard lands on this wallet.
  final String? importedAddress;

  const ExistingWalletState({
    this.acceptedLegal = false,
    this.currentStep = ImportWalletStep.legal,
    this.selectedWallet = '',
    this.selectedCoinType = TWCoinType.TWCoinTypeEthereum,
    this.importWalletStatus = ExistingWalletStatus.initial,
    this.importedAddress,
  });

  ExistingWalletState copyWith({
    bool? acceptedLegal,
    ImportWalletStep? currentStep,
    String? selectedWallet,
    TWCoinType? selectedCoinType,
    ExistingWalletStatus? importWalletStatus,
    String? importedAddress,
  }) {
    return ExistingWalletState(
      acceptedLegal: acceptedLegal ?? this.acceptedLegal,
      currentStep: currentStep ?? this.currentStep,
      selectedWallet: selectedWallet ?? this.selectedWallet,
      selectedCoinType: selectedCoinType ?? this.selectedCoinType,
      importWalletStatus: importWalletStatus ?? this.importWalletStatus,
      importedAddress: importedAddress ?? this.importedAddress,
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

enum ExistingWalletStatus { initial, loading, success, error }
