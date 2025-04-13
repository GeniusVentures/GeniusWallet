part of 'wallet_details_cubit.dart';

class WalletDetailsState {
  final Wallet? selectedWallet;
  final Network? selectedNetwork;
  final Coin? selectedCoin;
  final WalletStatus copyAddressStatus;
  final WalletStatus gasFeesStatus;
  final WalletStatus fetchWalletsStatus;
  final WalletStatus coinsStatus;
  final WalletStatus fetchTransactionsStatus;
  final List<Transaction> transactions;
  final List<Wallet> wallets;
  final double gasFees;
  final List<Coin> coins;
  final String? selectedWalletBalance;

  const WalletDetailsState(
      {this.selectedWallet,
      this.copyAddressStatus = WalletStatus.initial,
      this.gasFeesStatus = WalletStatus.initial,
      this.gasFees = 0,
      this.fetchWalletsStatus = WalletStatus.initial,
      this.selectedNetwork,
      this.wallets = const [],
      this.coinsStatus = WalletStatus.initial,
      this.coins = const [],
      this.transactions = const [],
      this.fetchTransactionsStatus = WalletStatus.initial,
      this.selectedCoin,
      this.selectedWalletBalance});

  WalletDetailsState copyWith(
      {Wallet? selectedWallet,
      Network? selectedNetwork,
      Coin? selectedCoin,
      WalletStatus? copyAddressStatus,
      WalletStatus? gasFeesStatus,
      WalletStatus? fetchWalletsStatus,
      WalletStatus? coinsStatus,
      WalletStatus? fetchTransactionsStatus,
      List<Wallet>? wallets,
      double? gasFees,
      List<Coin>? coins,
      List<Transaction>? transactions,
      String? selectedWalletBalance}) {
    return WalletDetailsState(
        selectedWallet: selectedWallet ?? this.selectedWallet,
        selectedCoin: selectedCoin ?? this.selectedCoin,
        copyAddressStatus: copyAddressStatus ?? this.copyAddressStatus,
        gasFees: gasFees ?? this.gasFees,
        gasFeesStatus: gasFeesStatus ?? this.gasFeesStatus,
        fetchWalletsStatus: fetchWalletsStatus ?? this.fetchWalletsStatus,
        wallets: wallets ?? this.wallets,
        selectedNetwork: selectedNetwork ?? this.selectedNetwork,
        coinsStatus: coinsStatus ?? this.coinsStatus,
        coins: coins ?? this.coins,
        transactions: transactions ?? this.transactions,
        fetchTransactionsStatus:
            fetchTransactionsStatus ?? this.fetchTransactionsStatus,
        selectedWalletBalance:
            selectedWalletBalance ?? this.selectedWalletBalance);
  }
}

enum WalletStatus {
  initial,
  loading,
  successful,
  error,
}
