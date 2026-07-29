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

  /// Health of the processing-status feed itself, independent of what the
  /// node last reported. [ProcessingFeedStatus.neverTicked] means no poll
  /// has landed yet; [ProcessingFeedStatus.live] means the last read
  /// succeeded; [ProcessingFeedStatus.unavailable] means the last read
  /// threw (`app_bloc.dart:192-195`'s catch), which is otherwise
  /// pixel-identical to a healthy idle node.
  ///
  /// Non-nullable with a default is not a style preference here.
  /// [copyWith] is `x ?? this.x` on every field, so passing `null` is a
  /// no-op rather than a clear - a nullable flag added now would inherit
  /// the exact stale-value trap this phase closes (the stale-percentage
  /// bug at `app_bloc.dart:184-191` is the same shape). State this reason
  /// on any future non-nullable field you add.
  final ProcessingFeedStatus processingFeedStatus;

  /// The node's own tri-state processing reading (disabled / idle /
  /// processing), carried as-is instead of collapsed into [isProcessing].
  /// [isProcessing] is kept too - it has other consumers
  /// (`sgnus_connection_widget.dart:123`) and removing it is out of this
  /// phase's fence.
  final NodeProcessingReading nodeProcessingStatus;

  /// When the processing feed last transitioned from processing to
  /// not-processing. `null` means no job has finished this session. This
  /// field is genuinely nullable (unlike the non-nullable-with-default
  /// rule above) because "no job has finished" is a real value - it is
  /// only ever written by the bloc, never cleared through [copyWith], so
  /// the no-op trap does not apply to it.
  final DateTime? processingCompletedAt;

  /// Initialization progress, 0.0-1.0
  /// (`packages/genius_api/lib/src/genius_api.dart:81-82`). `null` before
  /// the first poll of `getInitializationStatus()` lands.
  final double? initPercentage;

  /// The node's own human-readable initialization message
  /// (`packages/genius_api/lib/src/genius_api.dart:84-85`). `null` before
  /// the first poll lands. May be an empty string if the SDK reports one;
  /// the view layer (`compute_state.dart`'s `viewForComputeState`) is
  /// responsible for the fallback copy, not this field.
  final String? initMessage;

  /// The currently selected SDK account address (for processing/minting).
  final String? selectedSDKAccount;

  /// All available SDK account addresses.
  final List<String> sdkAccounts;

  /// The result of the last [SetSDKPayoutAddress] operation, or null if
  /// no operation has been performed yet.
  final GeniusNodeReturnValue? setPayoutAddressResult;

  const AppState({
    this.wallets = const [],
    this.sdkStatus = AppStatus.initial,
    this.subscribeToWalletStatus = AppStatus.initial,
    this.loadUserStatus = AppStatus.initial,
    this.userStatus = UserStatus.initial,
    this.ffiString,
    this.testWallet,
    this.isProcessing = false,
    this.account,
    this.processingPercentage,
    this.processingFeedStatus = ProcessingFeedStatus.neverTicked,
    this.nodeProcessingStatus = NodeProcessingReading.idle,
    this.processingCompletedAt,
    this.initPercentage,
    this.initMessage,
    this.selectedSDKAccount,
    this.sdkAccounts = const [],
    this.setPayoutAddressResult,
    this.accountStatus = AppStatus.initial,
  });

  AppState copyWith({
    List<Wallet>? wallets,
    AppStatus? sdkStatus,
    AppStatus? subscribeToWalletStatus,
    AppStatus? loadUserStatus,
    UserStatus? userStatus,
    String? ffiString,
    Pointer<Void>? testWallet,
    bool? isProcessing,
    Account? account,
    double? processingPercentage,
    ProcessingFeedStatus? processingFeedStatus,
    NodeProcessingReading? nodeProcessingStatus,
    DateTime? processingCompletedAt,
    double? initPercentage,
    String? initMessage,
    String? selectedSDKAccount,
    List<String>? sdkAccounts,
    GeniusNodeReturnValue? setPayoutAddressResult,
    AppStatus? accountStatus,
  }) {
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
      processingFeedStatus: processingFeedStatus ?? this.processingFeedStatus,
      nodeProcessingStatus: nodeProcessingStatus ?? this.nodeProcessingStatus,
      processingCompletedAt:
          processingCompletedAt ?? this.processingCompletedAt,
      initPercentage: initPercentage ?? this.initPercentage,
      initMessage: initMessage ?? this.initMessage,
      selectedSDKAccount: selectedSDKAccount ?? this.selectedSDKAccount,
      sdkAccounts: sdkAccounts ?? this.sdkAccounts,
      setPayoutAddressResult:
          setPayoutAddressResult ?? this.setPayoutAddressResult,
      accountStatus: accountStatus ?? this.accountStatus,
    );
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
    processingFeedStatus,
    nodeProcessingStatus,
    processingCompletedAt,
    initPercentage,
    initMessage,
    selectedSDKAccount,
    sdkAccounts,
    setPayoutAddressResult,
  ];
}

enum AppStatus { initial, loading, loaded, error }

enum UserStatus { initial, exists, nonExistent }

/// Health of the processing-status feed. See the doc comment on
/// [AppState.processingFeedStatus] for why this exists as its own field
/// rather than a derived boolean.
enum ProcessingFeedStatus {
  /// No poll has landed yet this session.
  neverTicked,

  /// The last read succeeded.
  live,

  /// The last read threw. `RetryProcessingStatus` clears this back to
  /// [neverTicked] and re-arms the timer that permanently cancelled on the
  /// throw (`app_bloc.dart:192-195`).
  unavailable,
}
