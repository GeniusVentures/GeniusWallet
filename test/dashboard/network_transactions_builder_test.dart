import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Transaction _tx(String hash, int chainId, TransactionType type) => Transaction(
  hash: hash,
  fromAddress: '0x1',
  recipients: const [],
  timeStamp: DateTime(2026),
  transactionDirection: TransactionDirection.sent,
  fees: '0',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: type,
  chainId: chainId,
);

void main() {
  testWidgets('filter counts see only the selected network', (tester) async {
    late Map<Filters, int> counts;
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => TransactionsCubit(
              initial: [
                _tx('eth', 1, TransactionType.transfer),
                _tx('base', 8453, TransactionType.swap),
              ],
            ),
          ),
          BlocProvider(
            create: (_) => WalletDetailsCubit(
              initialState: const WalletDetailsState(
                selectedNetwork: Network(chainId: 1),
              ),
              geniusApi: _UnusedApi(),
              networkTokensProvider: NetworkTokensProvider(),
            ),
          ),
        ],
        child: MaterialApp(
          home: NetworkTransactionsBuilder(
            builder: (_, txs) {
              counts = filterCounts(txs);
              return const SizedBox();
            },
          ),
        ),
      ),
    );

    expect(counts[Filters.swap], 0);
  });
}
