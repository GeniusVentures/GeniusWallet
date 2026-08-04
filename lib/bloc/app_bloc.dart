import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
// kDebugMode is required for the dev-only fault-injector gate below.
// package:flutter/rendering.dart (imported next) re-exports only
// DiagnosticLevel/ValueChanged/ValueGetter/ValueSetter/VoidCallback from
// foundation.dart — kDebugMode is not among them, so this explicit import is
// required and will not trip unnecessary_import.
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_fault_injector.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_sgnus.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce/hive.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GeniusApi api;
  final TransactionsCubit transactionsCubit;
  final WalletDetailsCubit walletDetailsCubit;
  final NetworkProvider networkProvider;

  Timer? _processingTimer;
  Timer? _initTimer;
  StreamSubscription<SGNUSConnection>? _sgnusConnectionSubscription;
  List<Wallet> _baseWallets = [];

  AppBloc({
    required this.api,
    required this.transactionsCubit,
    required this.walletDetailsCubit,
    required this.networkProvider,
  }) : super(const AppState()) {
    on<InitializeSDK>(_onInitializeSDK);
    on<LoadWallets>(_onLoadWallets);
    on<CheckIfUserExists>(_onCheckIfUserExists);
    on<FetchAccount>(_onFetchAccount);
    on<StartSGNUSTransactionsStream>(_onStartSGNUSTransactionsStream);
    on<RunFFITest>(_onRunFFITest);
    on<ProcessingStatusTicked>(_onProcessingStatusTicked);
    on<RetryProcessingStatus>(_onRetryProcessingStatus);
    on<InitializationStatusTicked>(_onInitializationStatusTicked);
    on<DeleteWallet>(_onDeleteWallet);
    on<RenameWallet>(_onRenameWallet);
    on<SgnusConnectionChanged>(_onSgnusConnectionChanged);
    on<SelectSDKAccount>(_onSelectSDKAccount);
    on<AddSDKAccountWithMnemonic>(_onAddSDKAccountWithMnemonic);
    on<AddSDKAccountWithPrivateKey>(_onAddSDKAccountWithPrivateKey);
    on<DeleteSDKAccount>(_onDeleteSDKAccount);
    on<RefreshSDKAccounts>(_onRefreshSDKAccounts);
    on<SetSDKPayoutAddress>(_onSetSDKPayoutAddress);

    // Starts as soon as `api` is available, mirroring
    // `sgnus_connection_widget.dart:30-35`'s `didChangeDependencies` start
    // point - initialization progress does not depend on wallets being
    // loaded (unlike `_processingTimer`, started from `_onLoadWallets`
    // below), so there is no later, more-correct point to start it from.
    _startInitPolling();
  }

  Future<void> _onInitializeSDK(
    InitializeSDK event,
    Emitter<AppState> emit,
  ) async {
    await api.initSDK();
    emit(state.copyWith(sdkStatus: AppStatus.loaded));
  }

  Future<void> _onLoadWallets(LoadWallets event, Emitter<AppState> emit) async {
    emit(state.copyWith(subscribeToWalletStatus: AppStatus.loading));

    final wallets = await api.getWallets().first;

    _baseWallets = wallets;

    if (_baseWallets.isEmpty) {
      final sdkState = _getSDKAccountState();
      emit(
        state.copyWith(
          wallets: [],
          subscribeToWalletStatus: AppStatus.loaded,
          selectedSDKAccount: sdkState.$1,
          sdkAccounts: sdkState.$2,
        ),
      );
      return;
    }

    _startSgnusConnectionListener();

    final mergedWallets = await _mergeSgnusWallet();
    final sdkState = _getSDKAccountState();

    final walletBox = Hive.box(walletBoxName);
    final selectedWalletAddress = walletBox.get(selectedWalletKey) as String?;

    final networkBox = Hive.box(networkBoxName);
    final chainId = networkBox.get(selectedNetworkKeyChainId) as int?;
    final rpcUrl = networkBox.get(selectedNetworkKeyRpcUrl) as String?;

    final networks = networkProvider.networks;

    final selectedNetwork = networks.firstWhere(
      (n) => n.chainId == chainId && n.rpcUrl == rpcUrl,
      orElse: () => networks.first,
    );

    final selectedWallet = mergedWallets.firstWhere(
      (w) => w.address == selectedWalletAddress,
      orElse: () => mergedWallets.first,
    );

    await transactionsCubit.loadInitial(selectedWallet.address);
    await walletDetailsCubit.loadInitial(
      selectedWallet: selectedWallet,
      selectedNetwork: selectedNetwork,
    );

    _startProcessingPolling();

    emit(
      state.copyWith(
        wallets: mergedWallets,
        subscribeToWalletStatus: AppStatus.loaded,
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
      ),
    );
  }

  void _startProcessingPolling() {
    _processingTimer?.cancel();

    _processingTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) {
      add(ProcessingStatusTicked());
    });
  }

  /// Maps the raw FFI status int (`GeniusProcessingStatusInfo.status`,
  /// `packages/genius_api/lib/ffi/genius_api_ffi.dart:1111-1119`) onto the
  /// pure [NodeProcessingReading] `compute_state.dart` deals in, so that
  /// module stays free of the genius_api/FFI dependency. `fromValue`
  /// throwing on an unrecognised int is intentional here - it is caught by
  /// the `catch` in [_onProcessingStatusTicked], which is the correct
  /// outcome for a status this build does not know how to interpret.
  NodeProcessingReading _toNodeProcessingReading(int rawStatus) {
    final geniusStatus = GeniusProcessingStatus.fromValue(rawStatus);
    return switch (geniusStatus) {
      GeniusProcessingStatus.GENIUS_PR_STATUS_DISABLED =>
        NodeProcessingReading.disabled,
      GeniusProcessingStatus.GENIUS_PR_STATUS_IDLE =>
        NodeProcessingReading.idle,
      GeniusProcessingStatus.GENIUS_PR_STATUS_PROCESSING =>
        NodeProcessingReading.processing,
    };
  }

  /// DEV-ONLY: the mock half of [_onProcessingStatusTicked], extracted out of
  /// it so that handler reads as the real FFI feed with one guarded call at
  /// the top. Returns `true` when a `DevMockSgnus` override was armed and
  /// this method has already emitted for the tick, `false` when nothing is
  /// armed and the caller should run the real feed.
  ///
  /// Only ever called behind `kDebugMode && kShowDevTools` at that one call
  /// site - do not call it from anywhere else, and do not fold that gate in
  /// here, because the gate at the call site is what lets the compiler drop
  /// this entirely from a release build.
  ///
  /// Covers all four sticky overrides (`processingOverride`,
  /// `initPercentageOverride`, `feedUnavailableOverride`,
  /// `jobCompleteOverride` - see `dev_mock_sgnus.dart`). All four must set
  /// `processingFeedStatus` correctly, or the mock renders a combination the
  /// real feed can never produce, and a walk against it proves nothing.
  bool _emitMockProcessingStatus(Emitter<AppState> emit) {
    final mock = DevMockSgnus.instance;
    if (mock.processingOverride == null &&
        mock.initPercentageOverride == null &&
        mock.feedUnavailableOverride != true &&
        mock.jobCompleteOverride != true &&
        !mock.initReleasePending &&
        !mock.staleCompletionPending) {
      return false;
    }

    // Consumed at the very TOP, before the feedUnavailableOverride early
    // return below, so a pending release can never be stranded behind that
    // return. `copyWith` cannot null `initPercentage`, and the real init
    // timer self-cancels once a reading reaches 1.0, so on a node that
    // already finished initialising there is no further poll to correct the
    // released value - 1.0 is the only value that releases the `< 1.0` gate,
    // and it is self-correcting: if the node is genuinely still
    // initialising, the real 3s poll resumes the tick after this and
    // overwrites it with the truth.
    final releasedInit = mock.consumeInitRelease();
    // Consumed here, alongside releasedInit, for the identical reason -
    // see DevMockSgnus.armReady's doc comment for what this defeats.
    final staleCompletion = mock.consumeStaleCompletion();

    if (mock.feedUnavailableOverride == true) {
      emit(
        state.copyWith(
          isProcessing: false,
          processingPercentage: 0.0,
          processingFeedStatus: ProcessingFeedStatus.unavailable,
          initPercentage: releasedInit ? 1.0 : mock.initPercentageOverride,
        ),
      );
      return true;
    }

    if (mock.jobCompleteOverride == true) {
      emit(
        state.copyWith(
          isProcessing: false,
          processingPercentage: 0.0,
          processingFeedStatus: ProcessingFeedStatus.live,
          // startingUp outranks jobComplete in resolveComputeState, and
          // copyWith cannot null initPercentage, so a leftover sub-1.0
          // reading would mask this state permanently. 1.0 is also the
          // only honest value for a node that has just finished a job.
          initPercentage: 1.0,
          // Refreshed on EVERY tick while armed - this is what makes the
          // override sticky in the same sense as the other three: the
          // walker holds the state while resizing and toggling
          // appearance. Once Clear releases the override, this timestamp
          // stops refreshing, the real 60s jobCompleteWindow runs out,
          // and wallet_overview.dart's 10s balance timer forces the
          // rebuild that lets the panel decay to Ready on its own.
          processingCompletedAt: DateTime.now(),
        ),
      );
      return true;
    }

    final isProcessing = mock.processingOverride ?? false;
    // This branch emits unconditionally and AppState is Equatable, so a
    // changing percentage is what produces a rebuild each tick and
    // therefore a bar that visibly moves - a constant value here would
    // emit an equal state and paint nothing.
    emit(
      state.copyWith(
        isProcessing: isProcessing,
        processingPercentage: isProcessing ? mock.processingPercentage : 0.0,
        processingFeedStatus: ProcessingFeedStatus.live,
        initPercentage: releasedInit ? 1.0 : mock.initPercentageOverride,
        // Only set when SGNUS ready's stale-completion flag was just
        // consumed - `copyWith`'s `?? this.x` means passing null here
        // (the ordinary case) leaves any existing value untouched, exactly
        // like every other field in this emit.
        processingCompletedAt: staleCompletion
            ? DateTime.now().subtract(jobCompleteWindow * 2)
            : null,
      ),
    );
    return true;
  }

  FutureOr<void> _onProcessingStatusTicked(
    ProcessingStatusTicked event,
    Emitter<AppState> emit,
  ) async {
    // DEV-ONLY, release-safe: kDebugMode and kShowDevTools are both
    // compile-time const bools and they lead this && chain, exactly as the
    // fault-injector guard in _onFetchAccount below does, so in a release
    // build (or any debug build without the GW_DEV_TOOLS define) the whole
    // condition constant-folds to false, _emitMockProcessingStatus is never
    // called, and this handler's executed behaviour is byte-for-byte the
    // real feed below.
    //
    // Placement is load-bearing and must NOT be moved inside the `try`
    // below, however tempting that looks:
    //   (1) it sits ahead of the `try` so `api.getProcessingStatus()` —
    //       which has NO `_isSdkInitialized` guard — is never reached while
    //       an override is armed;
    //   (2) the `catch` below cancels `_processingTimer` and flags the feed
    //       unavailable rather than cancelling it permanently with no way
    //       back, so the dev bubble dispatches `ProcessingStatusTicked()`
    //       itself rather than depending on a timer that may already be
    //       dead.
    //
    // Everything from `try` down is the real feed.
    if (kDebugMode && kShowDevTools && _emitMockProcessingStatus(emit)) {
      return;
    }

    try {
      final statusInfo = api.getProcessingStatus();

      final nodeReading = _toNodeProcessingReading(statusInfo.status);
      final isProcessing = nodeReading == NodeProcessingReading.processing;

      // Compare against state.isProcessing BEFORE the emit below - after
      // the emit the previous value is gone. didProcessingJustComplete is
      // the pure completion-edge rule pinned by
      // test/dashboard/compute_feed_state_test.dart, extracted to
      // compute_state.dart rather than inlined so it is testable without a
      // bloc harness.
      final justCompleted = didProcessingJustComplete(
        wasProcessing: state.isProcessing,
        isProcessingNow: isProcessing,
      );

      // Both this success path and the catch below funnel through the
      // same pure resolveProcessingFeedReading, so the "unavailable"
      // determination has exactly one implementation - see
      // compute_state.dart.
      final feedReading = resolveProcessingFeedReading(
        readThrew: false,
        nodeReading: nodeReading,
      );
      final feedStatus = feedReading == ProcessingFeedReading.unavailable
          ? ProcessingFeedStatus.unavailable
          : ProcessingFeedStatus.live;

      if (state.isProcessing != isProcessing ||
          state.nodeProcessingStatus != nodeReading ||
          state.processingFeedStatus != feedStatus) {
        emit(
          state.copyWith(
            isProcessing: isProcessing,
            nodeProcessingStatus: nodeReading,
            processingFeedStatus: feedStatus,
            processingCompletedAt: justCompleted ? DateTime.now() : null,
          ),
        );
      }

      if (isProcessing) {
        final double percentage = statusInfo.percentage;
        // Leftover percentage after processing stops is a known,
        // permanent trap here - copyWith cannot null this field (see the
        // doc comment on AppState.processingFeedStatus for why). The rule
        // that a non-processing state must never render a bar from it
        // lives in compute_state.dart's viewForComputeState (showBar is
        // derived from ComputeState alone), not here. Do not "fix" this
        // branch by trying to null the percentage on stop - fix the
        // resolver if this rule is ever violated.
        emit(state.copyWith(processingPercentage: percentage));
      }
    } catch (_) {
      // Cancel so a failing FFI call is not hammered once a second - but
      // unlike before this phase, the exception no longer kills the feed
      // permanently. RetryProcessingStatus (_onRetryProcessingStatus)
      // re-arms it. The unavailable flag is what lets the UI tell a dead
      // feed apart from a healthy idle node
      // (compute_state.dart's ComputeState.unavailable).
      _processingTimer?.cancel();
      final feedReading = resolveProcessingFeedReading(
        readThrew: true,
        nodeReading: null,
      );
      emit(
        state.copyWith(
          isProcessing: false,
          processingPercentage: 0.0,
          processingFeedStatus: feedReading == ProcessingFeedReading.unavailable
              ? ProcessingFeedStatus.unavailable
              : ProcessingFeedStatus.live,
        ),
      );
    }
  }

  /// Re-arms the poll the catch block above cancels on a throw.
  /// `_startProcessingPolling()` cancels before it re-creates (above), so
  /// it is idempotent by construction and cannot leak a timer - it already
  /// runs on every pull-to-refresh via `_onLoadWallets` (below),
  /// `dashboard_screen.dart:112`, which makes this call path load-bearing
  /// and proven in production, not merely inferred.
  ///
  /// **No backoff on repeated failure - settled, with evidence
  /// (`14-09-PLAN.md` Task 1f).** A hammering tap cannot happen: this
  /// handler only calls `_startProcessingPolling()`, which starts a single
  /// 1s timer; `_onProcessingStatusTicked`'s own `catch` cancels that timer
  /// immediately on the next throw. So one tap costs at most ONE further
  /// FFI call before the feed goes quiet again - there is no automatic
  /// retry loop for a backoff to rate-limit, because the cancel-on-throw
  /// above already is the most aggressive backoff possible (stop
  /// immediately, every time). Adding a failure counter would mean new
  /// `AppState`, a disabled/cooling-down rendering of the `Reconnect ›`
  /// link, and copy for a condition that cannot occur - and it would cost
  /// the one case that most plausibly recovers: a user who just brought
  /// the node back up tapping once, immediately.
  FutureOr<void> _onRetryProcessingStatus(
    RetryProcessingStatus event,
    Emitter<AppState> emit,
  ) {
    _startProcessingPolling();
    // Clears the unavailable flag back to its pre-read value so the UI
    // stops showing the error state before the first new tick lands.
    emit(
      state.copyWith(processingFeedStatus: ProcessingFeedStatus.neverTicked),
    );
  }

  /// Starts the 3s initialization poll. 3s matches
  /// `sgnus_connection_widget.dart:42`, the only shipped consumer of this
  /// feed and therefore the only measured cadence for it - deliberately
  /// NOT `_processingTimer`'s 1000ms, which belongs to a different feed.
  /// Self-cancels once initialization completes (see
  /// [_onInitializationStatusTicked]) and does not restart, mirroring
  /// `sgnus_connection_widget.dart:37-59`. Cancelled in [close] alongside
  /// `_processingTimer`.
  void _startInitPolling() {
    _initTimer?.cancel();
    _initTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      add(InitializationStatusTicked());
    });
  }

  /// DEV-ONLY: the mock half of [_onInitializationStatusTicked], extracted
  /// for the same reason as [_emitMockProcessingStatus] and subject to the
  /// same rule - the `kDebugMode && kShowDevTools` gate lives at the call
  /// site, not in here. Returns `true` when an override was armed and this
  /// method has already emitted for the tick.
  bool _emitMockInitPercentage(Emitter<AppState> emit) {
    final override = DevMockSgnus.instance.initPercentageOverride;
    if (override == null) {
      return false;
    }

    emit(state.copyWith(initPercentage: override));
    return true;
  }

  FutureOr<void> _onInitializationStatusTicked(
    InitializationStatusTicked event,
    Emitter<AppState> emit,
  ) {
    // DEV-ONLY, release-safe: same guard shape, same call-site gate and the
    // same reason as `_onProcessingStatusTicked` above - this handler's own
    // 3s poll has no dev guard of its own, so without this it would
    // overwrite an armed `initPercentageOverride` on its next tick,
    // re-emitting the real reading every 3s and flickering the walk between
    // the fixture and the real feed. The FFI read must not be reached while
    // the override is armed. Everything from `try` down is the real feed.
    if (kDebugMode && kShowDevTools && _emitMockInitPercentage(emit)) {
      return null;
    }

    try {
      final status = api.getInitializationStatus();
      emit(
        state.copyWith(
          initPercentage: status.percentage,
          initMessage: status.message,
        ),
      );
      if (status.percentage >= 1.0) {
        _initTimer?.cancel();
      }
    } catch (_) {
      // Swallow and retry next tick, mirroring
      // sgnus_connection_widget.dart:55-58. getInitializationStatus() is a
      // raw FFI call with no fail-soft wrapper - unlike getNodeState() and
      // getTransactionManagerState(), which route through mapping
      // functions with their own guards - so the caller is the only guard
      // there is. It also frees a native string on every call
      // (genius_api.dart:1219), so a throw between the read and the free
      // is a real path, not a theoretical one.
    }
  }

  Future<void> _onFetchAccount(
    FetchAccount event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(accountStatus: AppStatus.loading));

    try {
      // DEV-ONLY, release-safe: kDebugMode and kShowDevTools are both
      // compile-time const bools, and they lead this && chain, so in a
      // release build (or any debug build without the GW_DEV_TOOLS define)
      // the whole condition constant-folds to false and the compiler
      // eliminates this branch entirely — DevFaultInjector.consumeAccountLoadFailure()
      // is never called and this handler's executed behavior is
      // byte-for-byte what it is at HEAD. This is dev_flags.dart's
      // documented rule: always combine with kDebugMode at the call site.
      // Ordering is load-bearing: putting the impure consume call first
      // would defeat the constant-fold and would spend arms in builds that
      // should not have them.
      if (kDebugMode &&
          kShowDevTools &&
          DevFaultInjector.instance.consumeAccountLoadFailure()) {
        // Any throw type works — the catch below is untyped (catch (_)) and
        // swallows this identically to a real failure. Do not "improve"
        // this into a typed exception; it would not change catch behavior.
        throw Exception(
          'DEV-ONLY: injected by dev_fault_injector.dart (armed via the '
          'dev-tools bubble MOCK section) — not a real account-load failure.',
        );
      }
      final account = await api.getAccount();
      emit(state.copyWith(accountStatus: AppStatus.loaded, account: account));
    } catch (_) {
      emit(state.copyWith(accountStatus: AppStatus.error));
    }
  }

  FutureOr<void> _onCheckIfUserExists(
    CheckIfUserExists event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(loadUserStatus: AppStatus.loading));

    try {
      final exists = await api.userExists();
      emit(
        state.copyWith(
          loadUserStatus: AppStatus.loaded,
          userStatus: exists ? UserStatus.exists : UserStatus.nonExistent,
        ),
      );
    } catch (_) {
      emit(state.copyWith(loadUserStatus: AppStatus.error));
    }
  }

  void _onStartSGNUSTransactionsStream(
    StartSGNUSTransactionsStream event,
    Emitter emit,
  ) {
    api.streamSGNUSTransactions();
  }

  FutureOr<void> _onDeleteWallet(
    DeleteWallet event,
    Emitter<AppState> emit,
  ) async {
    await api.deleteWallet(event.address);
    _baseWallets = _baseWallets
        .where((w) => w.address != event.address)
        .toList();
    final sdkState = _getSDKAccountState();
    emit(
      state.copyWith(
        wallets: await _mergeSgnusWallet(),
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
      ),
    );
  }

  FutureOr<void> _onRenameWallet(
    RenameWallet event,
    Emitter<AppState> emit,
  ) async {
    await api.renameWallet(event.address, event.newName);
    _baseWallets = _baseWallets.map((w) {
      if (w.address.toLowerCase() == event.address.toLowerCase()) {
        return w.copyWith(walletName: event.newName);
      }
      return w;
    }).toList();
    final sdkState = _getSDKAccountState();
    emit(
      state.copyWith(
        wallets: await _mergeSgnusWallet(),
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
      ),
    );
  }

  void _startSgnusConnectionListener() {
    if (_sgnusConnectionSubscription != null) {
      return;
    }
    _sgnusConnectionSubscription = api.getSGNUSConnectionStream().listen((
      connection,
    ) {
      add(SgnusConnectionChanged(connection));
    });
  }

  FutureOr<void> _onSgnusConnectionChanged(
    SgnusConnectionChanged event,
    Emitter<AppState> emit,
  ) async {
    final sdkState = _getSDKAccountState();
    emit(
      state.copyWith(
        wallets: await _mergeSgnusWallet(),
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
      ),
    );
  }

  Future<List<Wallet>> _mergeSgnusWallet() async {
    final connection = await api.getSGNUSConnectionStream().first;
    if (!connection.isConnected) {
      return _baseWallets;
    }

    final accounts = api.getAvailableAccounts();
    final sgnusWallets = accounts.asMap().entries.map((entry) {
      final index = entry.key;
      final address = entry.value;
      return Wallet(
        walletName: accounts.length == 1
            ? 'Super Genius Wallet'
            : 'Super Genius Wallet ${index + 1}',
        walletType: WalletType.sgnus,
        address: address,
        currencySymbol: 'minions',
        coinType: TWCoinType.TWCoinTypeEthereum,
        balance: 0,
      );
    }).toList();

    return [...sgnusWallets, ..._baseWallets];
  }

  FutureOr<void> _onRunFFITest(RunFFITest event, Emitter<AppState> emit) {
    final result = api.mintTokens(500, "", "", "");
    debugPrint("FFI mintTokens result: $result");
  }

  /// Returns (selectedSDKAccount, sdkAccounts) tuple from the native SDK.
  (String?, List<String>) _getSDKAccountState() {
    final selected = api.getSelectedAccountAddress();
    final accounts = api.getAvailableAccounts();
    return (selected, accounts);
  }

  FutureOr<void> _onSelectSDKAccount(
    SelectSDKAccount event,
    Emitter<AppState> emit,
  ) async {
    final result = await api.selectGeniusAccountAsync(event.publicAddress);
    if (result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      final sdkState = _getSDKAccountState();
      emit(
        state.copyWith(
          wallets: await _mergeSgnusWallet(),
          selectedSDKAccount: sdkState.$1,
          sdkAccounts: sdkState.$2,
        ),
      );
    }
  }

  FutureOr<void> _onAddSDKAccountWithMnemonic(
    AddSDKAccountWithMnemonic event,
    Emitter<AppState> emit,
  ) async {
    final result = api.addAccountWithMnemonic(event.mnemonic);
    if (result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      final sdkState = _getSDKAccountState();
      emit(
        state.copyWith(
          wallets: await _mergeSgnusWallet(),
          selectedSDKAccount: sdkState.$1,
          sdkAccounts: sdkState.$2,
        ),
      );
    }
  }

  FutureOr<void> _onAddSDKAccountWithPrivateKey(
    AddSDKAccountWithPrivateKey event,
    Emitter<AppState> emit,
  ) async {
    final result = api.addAccountWithPrivateKey(event.privateKey);
    if (result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      final sdkState = _getSDKAccountState();
      emit(
        state.copyWith(
          wallets: await _mergeSgnusWallet(),
          selectedSDKAccount: sdkState.$1,
          sdkAccounts: sdkState.$2,
        ),
      );
    }
  }

  FutureOr<void> _onDeleteSDKAccount(
    DeleteSDKAccount event,
    Emitter<AppState> emit,
  ) async {
    final result = api.deleteAccount(event.publicAddress);
    if (result == GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      final sdkState = _getSDKAccountState();
      emit(
        state.copyWith(
          wallets: await _mergeSgnusWallet(),
          selectedSDKAccount: sdkState.$1,
          sdkAccounts: sdkState.$2,
        ),
      );
    }
  }

  FutureOr<void> _onRefreshSDKAccounts(
    RefreshSDKAccounts event,
    Emitter<AppState> emit,
  ) async {
    final sdkState = _getSDKAccountState();
    emit(
      state.copyWith(
        wallets: await _mergeSgnusWallet(),
        selectedSDKAccount: sdkState.$1,
        sdkAccounts: sdkState.$2,
      ),
    );
  }

  void _onSetSDKPayoutAddress(
    SetSDKPayoutAddress event,
    Emitter<AppState> emit,
  ) {
    final result = api.setPayoutAddress(event.publicAddress);
    // Always emit the result so the UI can display the actual SDK response.
    emit(state.copyWith(setPayoutAddressResult: result));
  }

  @override
  Future<void> close() {
    _processingTimer?.cancel();
    _initTimer?.cancel();
    _sgnusConnectionSubscription?.cancel();
    return super.close();
  }
}
