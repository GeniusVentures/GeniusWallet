import 'dart:async';

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
}
