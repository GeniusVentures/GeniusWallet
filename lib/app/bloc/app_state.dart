part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final List<Transaction> transactions;

  final AppStatus subscribeToWalletStatus;

  ///TODO: Change these to the proper types and names if needed
  // final String ffiInformation;
  final bool? ffiInformation;

  final AppStatus ffiStatus;

  const AppState(
      {this.wallets = const [],
      this.subscribeToWalletStatus = AppStatus.initial,
      this.ffiStatus = AppStatus.initial,
      this.transactions = const [],
      this.ffiInformation});

  AppState copyWith({
    List<Wallet>? wallets,
    List<Transaction>? transactions,
    AppStatus? subscribeToWalletStatus,
    AppStatus? ffiStatus,
    bool? information,
    // String? information,
  }) {
    return AppState(
      wallets: wallets ?? this.wallets,
      subscribeToWalletStatus:
          subscribeToWalletStatus ?? this.subscribeToWalletStatus,
      transactions: transactions ?? this.transactions,
      ffiInformation: information ?? this.ffiInformation,
      ffiStatus: ffiStatus ?? this.ffiStatus,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        transactions,
        subscribeToWalletStatus,
        ffiStatus,
        ffiInformation,
      ];
}

enum AppStatus {
  initial,
  loading,
  loaded,
  error,
}
