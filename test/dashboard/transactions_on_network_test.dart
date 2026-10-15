import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';

Transaction _tx(String hash, int? chainId) => Transaction(
  hash: hash,
  fromAddress: '0x1',
  recipients: const [],
  timeStamp: DateTime(2026),
  transactionDirection: TransactionDirection.sent,
  fees: '0',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  chainId: chainId,
);

void main() {
  test('history follows the selected network and keeps chainless rows', () {
    final txs = [_tx('base', 8453), _tx('eth', 1), _tx('old', null)];

    expect(transactionsOnNetwork(txs, 1).map((t) => t.hash), ['eth', 'old']);
    expect(transactionsOnNetwork(txs, null), txs);
  });
}
