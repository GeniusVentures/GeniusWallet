part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final List<Transaction> transactions;

  final AppStatus subscribeToWalletStatus;

  const AppState({
    this.wallets = const [],
    this.subscribeToWalletStatus = AppStatus.initial,
    this.transactions = const [],
  });

  AppState copyWith({
    List<Wallet>? wallets,
    List<Transaction>? transactions,
    AppStatus? subscribeToWalletStatus,
  }) {
    return AppState(
      wallets: wallets ?? this.wallets,
      subscribeToWalletStatus:
          subscribeToWalletStatus ?? this.subscribeToWalletStatus,
      transactions: transactions ?? this.transactions,
    );
  }

  @override
  List<Object?> get props => [wallets, transactions, subscribeToWalletStatus];
}

enum AppStatus {
  initial,
  loading,
  loaded,
  error,
}
