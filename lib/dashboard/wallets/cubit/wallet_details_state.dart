part of 'wallet_details_cubit.dart';

class WalletDetailsState {
  final Wallet? selectedWallet;
  final WalletStatus copyAddressStatus;
  final WalletStatus gasFeesStatus;
  final WalletStatus fetchWalletsStatus;
  final List<Wallet> wallets;
  final int gasFees;

  const WalletDetailsState({
    this.selectedWallet,
    this.copyAddressStatus = WalletStatus.initial,
    this.gasFeesStatus = WalletStatus.initial,
    this.gasFees = 0,
    this.fetchWalletsStatus = WalletStatus.initial,
    this.wallets = const [],
  });

  WalletDetailsState copyWith({
    Wallet? selectedWallet,
    WalletStatus? copyAddressStatus,
    WalletStatus? gasFeesStatus,
    WalletStatus? fetchWalletsStatus,
    List<Wallet>? wallets,
    int? gasFees,
  }) {
    return WalletDetailsState(
      selectedWallet: selectedWallet ?? this.selectedWallet,
      copyAddressStatus: copyAddressStatus ?? this.copyAddressStatus,
      gasFees: gasFees ?? this.gasFees,
      gasFeesStatus: gasFeesStatus ?? this.gasFeesStatus,
      fetchWalletsStatus: fetchWalletsStatus ?? this.fetchWalletsStatus,
      wallets: wallets ?? this.wallets,
    );
  }
}

enum WalletStatus {
  initial,
  loading,
  successful,
  error,
}
