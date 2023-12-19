part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final List<Transaction> transactions;

  final AppStatus subscribeToWalletStatus;

  final AppStatus loadUserStatus;

  final UserStatus userStatus;

  /// [double] used for testing FFI Bridge
  final String? ffiString;

  final Pointer<Void>? testWallet;

  const AppState({
    this.wallets = const [],
    this.subscribeToWalletStatus = AppStatus.initial,
    this.transactions = const [],
    this.loadUserStatus = AppStatus.initial,
    this.userStatus = UserStatus.initial,
    this.ffiString,
    this.testWallet,
  });

  AppState copyWith({
    List<Wallet>? wallets,
    AppStatus? subscribeToWalletStatus,
    List<Transaction>? transactions,
    AppStatus? loadUserStatus,
    UserStatus? userStatus,
    String? ffiString,
    Pointer<Void>? testWallet,
  }) {
    return AppState(
      wallets: wallets ?? this.wallets,
      subscribeToWalletStatus:
          subscribeToWalletStatus ?? this.subscribeToWalletStatus,
      transactions: transactions ?? this.transactions,
      loadUserStatus: loadUserStatus ?? this.loadUserStatus,
      userStatus: userStatus ?? this.userStatus,
      ffiString: ffiString ?? this.ffiString,
      testWallet: testWallet,
    );
  }

  @override
  List<Object?> get props => [
        wallets,
        transactions,
        subscribeToWalletStatus,
        loadUserStatus,
        userStatus,
        ffiString,
        testWallet,
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
