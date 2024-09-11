import 'dart:async';
import 'dart:ffi';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
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

    on<FetchAccount>(_onFetchAccount);
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
    // TODO: Remove this hardcoded list
    transactions.addAll([
      Transaction(
        hash:
            '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02',
        fromAddress: '0x0',
        toAddress: '0x1',
        timeStamp: DateTime.utc(2022, 10, 10, 13, 26),
        transactionDirection: TransactionDirection.sent,
        amount: '0.0002',
        fees: '',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.pending,
      ),
      Transaction(
          hash:
              '7f5979fb78f082e8b1c676635db8795c4ac6faba03525fb708cb5fd68fd40c5e',
          fromAddress: '0x2',
          toAddress: '0x0',
          timeStamp: DateTime.utc(2022, 10, 09, 15, 20),
          transactionDirection: TransactionDirection.received,
          amount: '0.0003',
          fees: '',
          coinSymbol: 'ETH',
          transactionStatus: TransactionStatus.cancelled),
      Transaction(
        hash:
            '6146ccf6a66d994f7c363db875e31ca35581450a4bf6d3be6cc9ac79233a69d0',
        fromAddress: '0x1',
        toAddress: '0x0',
        timeStamp: DateTime.utc(2022, 10, 10, 15, 22),
        transactionDirection: TransactionDirection.received,
        amount: '0.0023',
        fees: '0.000001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
      ),
    ]);
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
    api.mintTokens(500);
    Future.delayed(Duration(seconds: 5));
    api.requestAIProcess();
    final ffiString = "AI Process dispatched!";
    final ffiWallet = api.createWalletWithSize(500);

    emit(state.copyWith(ffiString: ffiString));
    emit(state.copyWith(testWallet: ffiWallet));
  }
}
