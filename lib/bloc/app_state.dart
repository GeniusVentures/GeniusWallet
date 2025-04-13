part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final AppStatus subscribeToWalletStatus;

  final AppStatus loadUserStatus;

  final UserStatus userStatus;

  /// [double] used for testing FFI Bridge
  final String? ffiString;

  final Pointer<Void>? testWallet;

  final Account? account;

  final AppStatus accountStatus;

  const AppState(
      {this.wallets = const [],
      this.subscribeToWalletStatus = AppStatus.initial,
      this.loadUserStatus = AppStatus.initial,
      this.userStatus = UserStatus.initial,
      this.ffiString,
      this.testWallet,
      this.account,
      this.accountStatus = AppStatus.initial});

  AppState copyWith(
      {List<Wallet>? wallets,
      AppStatus? subscribeToWalletStatus,
      AppStatus? loadUserStatus,
      UserStatus? userStatus,
      String? ffiString,
      Pointer<Void>? testWallet,
      Account? account,
      AppStatus? accountStatus}) {
    return AppState(
        wallets: wallets ?? this.wallets,
        subscribeToWalletStatus:
            subscribeToWalletStatus ?? this.subscribeToWalletStatus,
        loadUserStatus: loadUserStatus ?? this.loadUserStatus,
        userStatus: userStatus ?? this.userStatus,
        ffiString: ffiString ?? this.ffiString,
        testWallet: testWallet,
        account: account ?? this.account,
        accountStatus: accountStatus ?? this.accountStatus);
  }

  @override
  List<Object?> get props => [
        wallets,
        subscribeToWalletStatus,
        loadUserStatus,
        userStatus,
        ffiString,
        testWallet,
        account,
        accountStatus
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
