import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
  AppBloc({
    required this.api,
    required this.transactionsCubit,
    required this.walletDetailsCubit,
    required this.networkProvider,
  }) : super(const AppState()) {
    on<SubscribeToWallets>(_onSubscribeToWallets);

    on<CheckIfUserExists>(_onCheckIfUserExists);

    on<FFITestEvent>(_onFFITestEvent);

    on<FetchAccount>(_onFetchAccount);

    on<StreamSGNUSTransactions>(_onStreamSGNUSTransactions);
  }

  Future<void> _onFetchAccount(FetchAccount event, Emitter emit) async {
    emit(state.copyWith(
      accountStatus: AppStatus.loading,
    ));
    try {
      final account = await api.getAccount();
      emit(state.copyWith(
        accountStatus: AppStatus.loaded,
        account: account,
      ));
    } catch (e) {
      emit(state.copyWith(accountStatus: AppStatus.error));
    }
  }

  Future<void> _onSubscribeToWallets(
      SubscribeToWallets event, Emitter<AppState> emit) async {
    emit(state.copyWith(subscribeToWalletStatus: AppStatus.loading));

    final wallets = await api.getWallets().first;

    // Pick selected wallet and network
    final result = getSelectedWalletAndNetwork(networkProvider, wallets);
    final selectedWallet = result.wallet;
    final selectedNetwork = result.network;

    // Initialize other Cubits
    await transactionsCubit.loadInitial(selectedWallet.address);
    await walletDetailsCubit.loadInitial(
      selectedWallet: selectedWallet,
      selectedNetwork: selectedNetwork,
    );

    emit(state.copyWith(
        wallets: wallets, subscribeToWalletStatus: AppStatus.loaded));
  }

  Future<void> _onStreamSGNUSTransactions(
      StreamSGNUSTransactions event, Emitter emit) async {
    api.streamSGNUSTransactions();
    //debugPrint('🎞️ Streaming SGNUS transactions...');
  }

  FutureOr<void> _onCheckIfUserExists(
      CheckIfUserExists event, Emitter<AppState> emit) async {
    emit(state.copyWith(loadUserStatus: AppStatus.loading));

    try {
      final userExists = await api.userExists();
      emit(state.copyWith(
        loadUserStatus: AppStatus.loaded,
        userStatus: userExists ? UserStatus.exists : UserStatus.nonExistent,
      ));
    } catch (e) {
      emit(state.copyWith(loadUserStatus: AppStatus.error));
    }
  }

  FutureOr<void> _onFFITestEvent(FFITestEvent event, Emitter<AppState> emit) {
    //NOTE: No asyncs/awaits here since this method is synchronous.
    //NOTE: If they were async, we'd need to have a loading status
    api.mintTokens(500, "", "", "");
    // Future.delayed(Duration(seconds: 5));
    // api.requestAIProcess();
    // final ffiString = "AI Process dispatched!";
    // final ffiWallet = api.createWalletWithSize(500);

    // emit(state.copyWith(ffiString: ffiString));
    // emit(state.copyWith(testWallet: ffiWallet));
  }
}
