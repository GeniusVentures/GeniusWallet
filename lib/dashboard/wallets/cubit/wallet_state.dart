part of 'wallet_cubit.dart';

class WalletState {
  final Wallet? selectedWallet;
  final WalletStatus copyAddressStatus;
  final WalletStatus gasFeesStatus;
  final int gasFees;

  const WalletState({
    this.selectedWallet,
    this.copyAddressStatus = WalletStatus.initial,
    this.gasFeesStatus = WalletStatus.initial,
    this.gasFees = 0,
  });

  WalletState copyWith({
    Wallet? selectedWallet,
    WalletStatus? copyAddressStatus,
    WalletStatus? gasFeesStatus,
    int? gasFees,
  }) {
    return WalletState(
      selectedWallet: selectedWallet ?? this.selectedWallet,
      copyAddressStatus: copyAddressStatus ?? this.copyAddressStatus,
      gasFees: gasFees ?? this.gasFees,
      gasFeesStatus: gasFeesStatus ?? this.gasFeesStatus,
    );
  }
}

enum WalletStatus {
  initial,
  loading,
  successful,
  error,
}
