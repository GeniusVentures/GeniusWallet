part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final List<Transaction> transactions;

  final AppStatus subscribeToWalletStatus;

  final AppStatus loadUserStatus;

  final UserStatus userStatus;

  const AppState({
    this.wallets = const [],
    this.subscribeToWalletStatus = AppStatus.initial,
    this.transactions = const [],
    this.loadUserStatus = AppStatus.initial,
    this.userStatus = UserStatus.initial,
  });

  AppState copyWith(
      {List<Wallet>? wallets,
      List<Transaction>? transactions,
      AppStatus? subscribeToWalletStatus,
      AppStatus? loadUserStatus,
      UserStatus? userStatus}) {
    return AppState(
      wallets: wallets ?? this.wallets,
      subscribeToWalletStatus:
          subscribeToWalletStatus ?? this.subscribeToWalletStatus,
      transactions: transactions ?? this.transactions,
      loadUserStatus: loadUserStatus ?? this.loadUserStatus,
      userStatus: userStatus ?? this.userStatus,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        transactions,
        subscribeToWalletStatus,
        loadUserStatus,
        userStatus,
      ];
}

enum AppStatus {
  initial,
  loading,
  loaded,
  error,
}

enum UserStatus {
  initial,
  exists,
  nonExistent,
}
