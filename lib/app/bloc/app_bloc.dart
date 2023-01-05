import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';

import 'package:genius_api/genius_api.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GeniusApi api;
  AppBloc({
    required this.api,
  }) : super(const AppState()) {
    on<SubscribeToWallets>(_onSubscribeToWallets);
    on<FFIOnInit>(_onFFIInit);
  }

  Future<void> _onSubscribeToWallets(
      SubscribeToWallets event, Emitter emit) async {
    emit(state.copyWith(
      subscribeToWalletStatus: AppStatus.loading,
    ));

    await emit.forEach(
      api.getWallets(),
      onData: (wallets) {
        return state.copyWith(
          wallets: wallets,
          subscribeToWalletStatus: AppStatus.loaded,
          transactions: getTransactionsFrom(wallets),
        );
      },
    );
  }

  /// Iterates through [wallets] and returns an aggregate lists of all [Transactions]
  List<Transaction> getTransactionsFrom(List<Wallet> wallets) {
    final transactions = <Transaction>[];
    for (var wallet in wallets) {
      transactions.addAll(wallet.transactions);
    }
    return transactions;
  }

  FutureOr<void> _onFFIInit(FFIOnInit event, Emitter<AppState> emit) async {
    emit(state.copyWith(ffiStatus: AppStatus.loading));
    try {
      final ffiBridgePrebuilt = await api.loadFFIBridgePrebuilt();
      emit(state.copyWith(
          information: ffiBridgePrebuilt, ffiStatus: AppStatus.loaded));
    } catch (e) {
      emit(state.copyWith(ffiStatus: AppStatus.error));
    }
  }
}
