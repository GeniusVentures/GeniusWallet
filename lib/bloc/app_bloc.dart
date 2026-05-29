import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:hive_ce/hive.dart';
import 'package:rxdart/rxdart.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GeniusApi api;
  final TransactionsCubit transactionsCubit;
  final WalletDetailsCubit walletDetailsCubit;
  final NetworkProvider networkProvider;

  Timer? _processingTimer;
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
    on<DeleteWallet>(_onDeleteWallet);
    on<RenameWallet>(_onRenameWallet);
    on<SgnusConnectionChanged>(_onSgnusConnectionChanged);
  }

  Future<void> _onInitializeSDK(
    InitializeSDK event,
    Emitter<AppState> emit,
  ) async {
    await api.initSDK();
    emit(state.copyWith(sdkStatus: AppStatus.loaded));
  }

  Future<void> _onLoadWallets(
    LoadWallets event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(subscribeToWalletStatus: AppStatus.loading));

    final wallets = await api.getWallets().first;

    _baseWallets = wallets;
    _startSgnusConnectionListener();

    if (_baseWallets.isEmpty) {
      emit(state.copyWith(
        wallets: _mergeSgnusWallet(),
        subscribeToWalletStatus: AppStatus.loaded,
      ));
      return;
    }

    final mergedWallets = _mergeSgnusWallet();

    final walletBox = Hive.box(walletBoxName);
    final address = walletBox.get(selectedWalletKey) as String?;

    final networkBox = Hive.box(networkBoxName);
    final chainId = networkBox.get(selectedNetworkKeyChainId) as int?;
    final rpcUrl = networkBox.get(selectedNetworkKeyRpcUrl) as String?;

    final networks = networkProvider.networks;

    final selectedNetwork = networks.firstWhere(
      (n) => n.chainId == chainId && n.rpcUrl == rpcUrl,
      orElse: () => networks.first,
    );

    final selectedWallet = mergedWallets.firstWhere(
      (w) => w.address == address,
      orElse: () => mergedWallets.first,
    );

    await transactionsCubit.loadInitial(selectedWallet.address);
    await walletDetailsCubit.loadInitial(
      selectedWallet: selectedWallet,
      selectedNetwork: selectedNetwork,
    );

    _startProcessingPolling();

    emit(state.copyWith(
      wallets: mergedWallets,
      subscribeToWalletStatus: AppStatus.loaded,
    ));
  }

  void _startProcessingPolling() {
    _processingTimer?.cancel();

    _processingTimer = Timer.periodic(
      const Duration(milliseconds: 1000),
      (_) {
        add(ProcessingStatusTicked());
      },
    );
  }

  FutureOr<void> _onProcessingStatusTicked(
    ProcessingStatusTicked event,
    Emitter<AppState> emit,
  ) async {
    try {
      final statusInfo = api.getProcessingStatus();

      final isProcessing = statusInfo.status ==
          GeniusProcessingStatus.GENIUS_PR_STATUS_PROCESSING.value;

      if (state.isProcessing != isProcessing) {
        emit(state.copyWith(isProcessing: isProcessing));
      }

      if (isProcessing) {
        double percentage = statusInfo.percentage;
        emit(state.copyWith(processingPercentage: percentage));
      }
    } catch (_) {
      _processingTimer?.cancel();
      emit(state.copyWith(isProcessing: false, processingPercentage: 0.0));
    }
  }

  Future<void> _onFetchAccount(
    FetchAccount event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(accountStatus: AppStatus.loading));

    try {
      final account = await api.getAccount();
      emit(state.copyWith(
        accountStatus: AppStatus.loaded,
        account: account,
      ));
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
      emit(state.copyWith(
        loadUserStatus: AppStatus.loaded,
        userStatus: exists ? UserStatus.exists : UserStatus.nonExistent,
      ));
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
    _baseWallets =
        _baseWallets.where((w) => w.address != event.address).toList();
    emit(state.copyWith(wallets: _mergeSgnusWallet()));
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
    emit(state.copyWith(wallets: _mergeSgnusWallet()));
  }

  void _startSgnusConnectionListener() {
    if (_sgnusConnectionSubscription != null) return;
    _sgnusConnectionSubscription =
        api.getSGNUSConnectionStream().listen((connection) {
      add(SgnusConnectionChanged(connection));
    });
  }

  void _onSgnusConnectionChanged(
    SgnusConnectionChanged event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(wallets: _mergeSgnusWallet()));
  }

  /// Returns the current SGNUS connection value directly from the
  /// BehaviorSubject, bypassing any cached field timing issues.
  SGNUSConnection _getSgnusConnection() {
    final stream = api.getSGNUSConnectionStream();
    if (stream is ValueStream<SGNUSConnection>) {
      return stream.value;
    }
    return const SGNUSConnection(
        sgnusAddress: '', walletAddress: '', isConnected: false);
  }

  List<Wallet> _mergeSgnusWallet() {
    final connection = _getSgnusConnection();
    if (!connection.isConnected) {
      return _baseWallets;
    }
    return [
      Wallet(
        walletName: 'Super Genius Wallet',
        walletType: WalletType.sgnus,
        address: connection.sgnusAddress,
        currencySymbol: 'minions',
        coinType: TWCoinType.TWCoinTypeEthereum,
        balance: 0,
      ),
      ..._baseWallets,
    ];
  }

  FutureOr<void> _onRunFFITest(
    RunFFITest event,
    Emitter<AppState> emit,
  ) {
    final result = api.mintTokens(500, "", "", "");
    debugPrint("FFI mintTokens result: $result");
  }

  @override
  Future<void> close() {
    _processingTimer?.cancel();
    _sgnusConnectionSubscription?.cancel();
    return super.close();
  }
}
