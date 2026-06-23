import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:hive_ce/hive.dart';

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
    on<SelectSDKAccount>(_onSelectSDKAccount);
    on<AddSDKAccountWithMnemonic>(_onAddSDKAccountWithMnemonic);
    on<AddSDKAccountWithPrivateKey>(_onAddSDKAccountWithPrivateKey);
    on<DeleteSDKAccount>(_onDeleteSDKAccount);
    on<RefreshSDKAccounts>(_onRefreshSDKAccounts);
    on<SetSDKPayoutAddress>(_onSetSDKPayoutAddress);
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

  FutureOr<void> _onProcessingStatusTicked(
    ProcessingStatusTicked event,
    Emitter<AppState> emit,
  ) async {
    try {
      final statusInfo = api.getProcessingStatus();

      final isProcessing =
          statusInfo.status ==
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
    if (_sgnusConnectionSubscription != null) return;
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
    _sgnusConnectionSubscription?.cancel();
    return super.close();
  }
}
