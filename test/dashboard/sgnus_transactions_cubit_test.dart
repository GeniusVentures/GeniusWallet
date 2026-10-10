import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/sgnus_transactions_cubit.dart';

Transaction _tx(String hash) => Transaction(
  hash: hash,
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: DateTime.now(),
  transactionDirection: TransactionDirection.sent,
  fees: '0.001',
  coinSymbol: 'GNUS',
  transactionStatus: TransactionStatus.completed,
  isSGNUS: true,
  type: TransactionType.transfer,
);

void main() {
  test('mirrors the feed and stops listening on close', () async {
    final feed = StreamController<List<Transaction>>();
    addTearDown(feed.close);
    final cubit = SgnusTransactionsCubit(feed.stream);
    expect(cubit.state, isEmpty);

    final rows = [_tx('0xa')];
    feed.add(rows);
    await pumpEventQueue();
    expect(cubit.state, same(rows));

    await cubit.close();
    expect(feed.hasListener, isFalse);
  });
}
