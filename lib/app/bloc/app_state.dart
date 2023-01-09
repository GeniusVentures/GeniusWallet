part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final List<Transaction> transactions;

  final AppStatus subscribeToWalletStatus;

  final AppStatus loadUserStatus;

  final UserStatus userStatus;
  final AppStatus ffiStatus;
  final bool? ffiInformation;

  const AppState(
      {this.wallets = const [],
      this.subscribeToWalletStatus = AppStatus.initial,
      this.transactions = const [],
      this.ffiStatus = AppStatus.initial,
      this.loadUserStatus = AppStatus.initial,
      this.userStatus = UserStatus.initial,
      this.ffiInformation});

  AppState copyWith({
    List<Wallet>? wallets,
    AppStatus? subscribeToWalletStatus,
    List<Transaction>? transactions,
    AppStatus? ffiStatus,
    AppStatus? loadUserStatus,
    UserStatus? userStatus,
    bool? information,
  }) {
    return AppState(
      wallets: wallets ?? this.wallets,
      subscribeToWalletStatus:
          subscribeToWalletStatus ?? this.subscribeToWalletStatus,
      transactions: transactions ?? this.transactions,
      loadUserStatus: loadUserStatus ?? this.loadUserStatus,
      userStatus: userStatus ?? this.userStatus,
      ffiStatus: ffiStatus ?? this.ffiStatus,
      ffiInformation: information ?? ffiInformation,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        transactions,
        subscribeToWalletStatus,
        loadUserStatus,
        userStatus,
        ffiStatus
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
