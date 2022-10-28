import 'package:equatable/equatable.dart';
import 'package:genius_api/genius_api.dart';

class WalletsOverviewState extends Equatable {
  final WalletsOverviewStatus fetchWalletsStatus;
  final WalletsOverviewStatus fetchTransactionsStatus;

  final List<Wallet> wallets;
  final List<Transaction> transactions;

  const WalletsOverviewState({
    this.fetchWalletsStatus = WalletsOverviewStatus.initial,
    this.fetchTransactionsStatus = WalletsOverviewStatus.initial,
    this.wallets = const [],
    this.transactions = const [],
  });

  WalletsOverviewState copyWith({
    WalletsOverviewStatus? fetchWalletsStatus,
    WalletsOverviewStatus? fetchTransactionsStatus,
    List<Wallet>? wallets,
    List<Transaction>? transactions,
  }) {
    return WalletsOverviewState(
      fetchWalletsStatus: fetchWalletsStatus ?? this.fetchWalletsStatus,
      fetchTransactionsStatus:
          fetchTransactionsStatus ?? this.fetchTransactionsStatus,
      wallets: wallets ?? this.wallets,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props =>
      [fetchWalletsStatus, fetchTransactionsStatus, wallets, transactions];
}

enum WalletsOverviewStatus {
  initial,
  loading,
  error,
  success,
}
