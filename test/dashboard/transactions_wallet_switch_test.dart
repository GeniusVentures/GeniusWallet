import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

const _a = '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';
const _b = '0xBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

Wallet _wallet(String address) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: address.substring(0, 4),
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: address,
);

Transaction _tx(String address) => Transaction(
  hash: 'hash-$address',
  fromAddress: address,
  recipients: [TransferRecipients(toAddr: address, amount: '1')],
  timeStamp: DateTime(2026, 9, 1),
  transactionDirection: TransactionDirection.received,
  fees: '0',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: TransactionType.transfer,
  assetSymbol: 'ETH',
);

/// Each address's history resolves only when its completer is completed.
class _GatedStorage implements TransactionStorageService {
  final reads = <String, Completer<List<Transaction>>>{};
  var readCount = 0;

  @override
  Future<List<Transaction>> getTransactions(String walletAddress) {
    readCount++;
    return (reads[walletAddress] = Completer<List<Transaction>>()).future;
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Api implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  late _GatedStorage storage;
  late TransactionsCubit transactions;
  late WalletDetailsCubit walletDetails;
  late AppBloc appBloc;
  late Box box;

  setUp(() async {
    // Selecting a wallet persists it, so the wallet box has to be open.
    box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
    storage = _GatedStorage();
    transactions = TransactionsCubit(storage: storage);
    walletDetails = WalletDetailsCubit(
      geniusApi: _Api(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    appBloc = AppBloc(
      api: _Api(),
      transactionsCubit: transactions,
      walletDetailsCubit: walletDetails,
      networkProvider: NetworkProvider(),
    );
  });

  tearDown(() async {
    await appBloc.close();
    await box.close();
  });

  test('selecting another wallet shows that wallet\'s transactions', () async {
    await walletDetails.selectWallet(_wallet(_a));
    await pumpEventQueue();
    storage.reads[_a]!.complete([_tx(_a)]);
    await pumpEventQueue();
    expect(transactions.state.map((t) => t.fromAddress), [_a]);

    await walletDetails.selectWallet(_wallet(_b));
    await pumpEventQueue();

    expect(transactions.state, isEmpty, reason: 'old rows cleared at once');
    storage.reads[_b]!.complete([_tx(_b)]);
    await pumpEventQueue();

    expect(transactions.state.map((t) => t.fromAddress), [_b]);
  });

  test(
    'a slow read for the previous wallet cannot overwrite the new one',
    () async {
      await walletDetails.selectWallet(_wallet(_a));
      await pumpEventQueue();
      await walletDetails.selectWallet(_wallet(_b));
      await pumpEventQueue();

      storage.reads[_b]!.complete([_tx(_b)]);
      await pumpEventQueue();
      storage.reads[_a]!.complete([_tx(_a)]);
      await pumpEventQueue();

      expect(transactions.state.map((t) => t.fromAddress), [_b]);
    },
  );

  test(
    'after A -> B -> A, the first read for A cannot land on the newer one',
    () async {
      await walletDetails.selectWallet(_wallet(_a));
      await pumpEventQueue();
      final staleRead = storage.reads[_a]!;
      await walletDetails.selectWallet(_wallet(_b));
      await pumpEventQueue();
      await walletDetails.selectWallet(_wallet(_a));
      await pumpEventQueue();

      final current = _tx(_a);
      storage.reads[_a]!.complete([current]);
      await pumpEventQueue();
      staleRead.complete([_tx(_a)]);
      await pumpEventQueue();

      expect(transactions.state, [current]);
    },
  );

  test('a live row that lands during a load beats the stored copy', () async {
    final load = transactions.loadInitial(_a);
    final live = _tx(_a);
    transactions.replaceTransaction(_a, live);
    storage.reads[_a]!.complete([_tx(_a)]);
    await load;

    expect(transactions.state, [live]);
  });

  test('a failed read can be retried by showing the same wallet', () async {
    final failed = transactions.showWallet(_a);
    storage.reads[_a]!.completeError(StateError('disk'));
    await expectLater(failed, throwsStateError);

    final retry = transactions.showWallet(_a);
    storage.reads[_a]!.complete([_tx(_a)]);
    await retry;

    expect(transactions.state.map((t) => t.fromAddress), [_a]);
  });

  test('picking the same wallet again retries its failed read', () async {
    await walletDetails.selectWallet(_wallet(_a));
    await pumpEventQueue();
    storage.reads[_a]!.completeError(StateError('disk'));
    await pumpEventQueue();

    await walletDetails.selectWallet(_wallet(_a));
    await pumpEventQueue();
    storage.reads[_a]!.complete([_tx(_a)]);
    await pumpEventQueue();

    expect(transactions.state.map((t) => t.fromAddress), [_a]);
  });

  test(
    'showing a wallet whose read is in flight does not read again',
    () async {
      final first = transactions.showWallet(_a);
      final second = transactions.showWallet(_a);
      storage.reads[_a]!.complete([_tx(_a)]);
      await Future.wait([first, second]);

      expect(storage.readCount, 1);
    },
  );
}
