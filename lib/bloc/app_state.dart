part of 'app_bloc.dart';

class AppState extends Equatable {
  //? Maybe we can add a bool to easily see if the user is authenticated in the state.
  final List<Wallet> wallets;

  final AppStatus sdkStatus;

  final AppStatus subscribeToWalletStatus;

  final AppStatus loadUserStatus;

  final UserStatus userStatus;

  /// [double] used for testing FFI Bridge
  final String? ffiString;

  final Pointer<Void>? testWallet;

  final Account? account;

  final AppStatus accountStatus;
  final bool isProcessing;
  final double? processingPercentage;

  /// The currently selected SDK account address (for processing/minting).
  final String? selectedSDKAccount;

  /// All available SDK account addresses.
  final List<String> sdkAccounts;

  /// The result of the last [SetSDKPayoutAddress] operation, or null if
  /// no operation has been performed yet.
  final GeniusNodeReturnValue? setPayoutAddressResult;

  const AppState(
      {this.wallets = const [],
      this.sdkStatus = AppStatus.initial,
      this.subscribeToWalletStatus = AppStatus.initial,
      this.loadUserStatus = AppStatus.initial,
      this.userStatus = UserStatus.initial,
      this.ffiString,
      this.testWallet,
      this.isProcessing = false,
      this.account,
      this.processingPercentage,
      this.selectedSDKAccount,
      this.sdkAccounts = const [],
      this.setPayoutAddressResult,
      this.accountStatus = AppStatus.initial});

  AppState copyWith(
      {List<Wallet>? wallets,
      AppStatus? sdkStatus,
      AppStatus? subscribeToWalletStatus,
      AppStatus? loadUserStatus,
      UserStatus? userStatus,
      String? ffiString,
      Pointer<Void>? testWallet,
      bool? isProcessing,
      Account? account,
      double? processingPercentage,
      String? selectedSDKAccount,
      List<String>? sdkAccounts,
      GeniusNodeReturnValue? setPayoutAddressResult,
      AppStatus? accountStatus}) {
    return AppState(
        wallets: wallets ?? this.wallets,
        sdkStatus: sdkStatus ?? this.sdkStatus,
        subscribeToWalletStatus:
            subscribeToWalletStatus ?? this.subscribeToWalletStatus,
        loadUserStatus: loadUserStatus ?? this.loadUserStatus,
        userStatus: userStatus ?? this.userStatus,
        ffiString: ffiString ?? this.ffiString,
        testWallet: testWallet,
        account: account ?? this.account,
        processingPercentage: processingPercentage ?? this.processingPercentage,
        isProcessing: isProcessing ?? this.isProcessing,
        selectedSDKAccount: selectedSDKAccount ?? this.selectedSDKAccount,
        sdkAccounts: sdkAccounts ?? this.sdkAccounts,
        setPayoutAddressResult:
            setPayoutAddressResult ?? this.setPayoutAddressResult,
        accountStatus: accountStatus ?? this.accountStatus);
  }

  @override
  List<Object?> get props => [
        wallets,
        sdkStatus,
        subscribeToWalletStatus,
        loadUserStatus,
        userStatus,
        ffiString,
        testWallet,
        account,
        accountStatus,
        isProcessing,
        processingPercentage,
        selectedSDKAccount,
        sdkAccounts,
        setPayoutAddressResult,
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
