part of 'wallet_details_cubit.dart';

class WalletDetailsState {
  final Wallet? selectedWallet;
  final Network? selectedNetwork;
  final WalletStatus copyAddressStatus;
  final WalletStatus gasFeesStatus;
  final WalletStatus fetchWalletsStatus;
  final WalletStatus coinsStatus;
  final WalletStatus balanceStatus;
  final WalletStatus fetchNetworksStatus;
  final WalletStatus fetchTransactionsStatus;
  final List<Transaction> transactions;
  final List<Network> networks;
  final List<Wallet> wallets;
  final int gasFees;
  final List<Coin> coins;
  final double balance;

  const WalletDetailsState(
      {this.selectedWallet,
      this.copyAddressStatus = WalletStatus.initial,
      this.gasFeesStatus = WalletStatus.initial,
      this.gasFees = 0,
      this.fetchWalletsStatus = WalletStatus.initial,
      this.fetchNetworksStatus = WalletStatus.initial,
      this.networks = const [],
      this.selectedNetwork,
      this.wallets = const [],
      this.coinsStatus = WalletStatus.initial,
      this.coins = const [],
      this.balanceStatus = WalletStatus.initial,
      this.balance = 0,
      this.transactions = const [],
      this.fetchTransactionsStatus = WalletStatus.initial});

  WalletDetailsState copyWith(
      {Wallet? selectedWallet,
      Network? selectedNetwork,
      WalletStatus? copyAddressStatus,
      WalletStatus? gasFeesStatus,
      WalletStatus? fetchWalletsStatus,
      WalletStatus? coinsStatus,
      WalletStatus? balanceStatus,
      WalletStatus? fetchNetworksStatus,
      WalletStatus? fetchTransactionsStatus,
      List<Network>? networks,
      List<Wallet>? wallets,
      int? gasFees,
      List<Coin>? coins,
      double? balance,
      List<Transaction>? transactions}) {
    return WalletDetailsState(
        selectedWallet: selectedWallet ?? this.selectedWallet,
        copyAddressStatus: copyAddressStatus ?? this.copyAddressStatus,
        gasFees: gasFees ?? this.gasFees,
        gasFeesStatus: gasFeesStatus ?? this.gasFeesStatus,
        fetchWalletsStatus: fetchWalletsStatus ?? this.fetchWalletsStatus,
        wallets: wallets ?? this.wallets,
        selectedNetwork: selectedNetwork ?? this.selectedNetwork,
        coinsStatus: coinsStatus ?? this.coinsStatus,
        coins: coins ?? this.coins,
        balanceStatus: balanceStatus ?? this.balanceStatus,
        balance: balance ?? this.balance,
        fetchNetworksStatus: fetchNetworksStatus ?? this.fetchNetworksStatus,
        networks: networks ?? this.networks,
        transactions: transactions ?? this.transactions,
        fetchTransactionsStatus:
            fetchNetworksStatus ?? this.fetchTransactionsStatus);
  }
}

enum WalletStatus {
  initial,
  loading,
  successful,
  error,
}
