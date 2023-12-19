import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  final GeniusApi api;
  AppBloc({
    required this.api,
  }) : super(const AppState()) {
    on<SubscribeToWallets>(_onSubscribeToWallets);

    on<CheckIfUserExists>(_onCheckIfUserExists);

    on<FFITestEvent>(_onFFITestEvent);
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
    final ffiString = api.getHRPStrideValue();
    final ffiWallet = api.createWalletWithSize(500);

    emit(state.copyWith(ffiString: ffiString));
    emit(state.copyWith(testWallet: ffiWallet));
  }
}
