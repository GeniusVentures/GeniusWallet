import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_wallet/components/overlay/selected_wallet_and_network.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
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

  AppBloc({
    required this.api,
    required this.transactionsCubit,
    required this.walletDetailsCubit,
    required this.networkProvider,
  }) : super(const AppState()) {
    on<SubscribeToWallets>(_onSubscribeToWallets);
    on<CheckIfUserExists>(_onCheckIfUserExists);
    on<FetchAccount>(_onFetchAccount);
    on<StreamSGNUSTransactions>(_onStreamSGNUSTransactions);
    on<FFITestEvent>(_onFFITestEvent);
    on<ProcessingStatusTicked>(_onProcessingStatusTicked);
  }

  Future<void> _onSubscribeToWallets(
    SubscribeToWallets event,
    Emitter<AppState> emit,
  ) async {
    emit(state.copyWith(subscribeToWalletStatus: AppStatus.loading));

    // Check if wallets exist, then initialize SDK (splash screen is now visible)
    var wallets = await api.getWallets().first;
    
    if (wallets.isNotEmpty) {
      await api.initSDK();
      // Refresh wallets after SDK initialization
      wallets = await api.getWallets().first;
    }

    if (wallets.isEmpty) {
      emit(state.copyWith(
        wallets: wallets,
        subscribeToWalletStatus: AppStatus.loaded,
      ));
      return;
    }

    final result = getSelectedWalletAndNetwork(networkProvider, wallets);
    final selectedWallet = result.wallet;
    final selectedNetwork = result.network;

    await transactionsCubit.loadInitial(selectedWallet.address);
    await walletDetailsCubit.loadInitial(
      selectedWallet: selectedWallet,
      selectedNetwork: selectedNetwork,
    );

    _startProcessingPolling();

    emit(state.copyWith(
      wallets: wallets,
      subscribeToWalletStatus: AppStatus.loaded,
    ));
  }

  void _startProcessingPolling() {
    _processingTimer?.cancel();

    _processingTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        add(ProcessingStatusTicked());
      },
    );
  }

  FutureOr<void> _onProcessingStatusTicked(
    ProcessingStatusTicked event,
    Emitter<AppState> emit,
  ) {
    try {
      final statusInfo = api.getProcessingStatus();

      final isProcessing =
          statusInfo.status == GeniusProcessingStatus.GENIUS_PR_STATUS_PROCESSING;

      if (state.isProcessing != isProcessing) {
        emit(state.copyWith(isProcessing: isProcessing));
      }
    } catch (_) {
      _processingTimer?.cancel();
      emit(state.copyWith(isProcessing: false));
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

  Future<void> _onStreamSGNUSTransactions(
    StreamSGNUSTransactions event,
    Emitter emit,
  ) async {
    api.streamSGNUSTransactions();
  }

  FutureOr<void> _onFFITestEvent(
    FFITestEvent event,
    Emitter<AppState> emit,
  ) {
    final result = api.mintTokens(500, "", "", "");
    print("FFI mintTokens result: $result");
  }

  @override
  Future<void> close() {
    _processingTimer?.cancel();
    return super.close();
  }
}
