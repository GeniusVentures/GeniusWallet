import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/send/send_cubit.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:web3dart/web3dart.dart' show TransactionReceipt;

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _address = '0xSENDSENDSENDSENDSENDSENDSENDSENDSENDSEND';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Sender',
  currencySymbol: 'MATIC',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _address,
);

/// Answers receipt reads from [receipts] in order, repeating the last.
class _ReceiptApi implements GeniusApi {
  _ReceiptApi(this.receipts);

  final List<TransactionReceipt?> receipts;
  int reads = 0;

  @override
  Future<TransactionReceipt?> transactionReceipt({
    required String hash,
    required String rpcUrl,
  }) async => receipts[(reads++).clamp(0, receipts.length - 1)];

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

class _Networks extends NetworkProvider {
  @override
  List<Network> get networks => const [_amoy];
}

class _SeededWalletDetailsCubit extends WalletDetailsCubit {
  _SeededWalletDetailsCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
  }) {
    emit(state.copyWith(selectedWallet: _wallet));
  }
}

class _NoDisk implements TransactionStorageService {
  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async {}

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('pulling to refresh history settles a send that was still '
      'pending at startup', (tester) async {
    final api = _ReceiptApi([
      null,
      TransactionReceipt.fromMap({
        'transactionHash': _hash,
        'transactionIndex': '0x0',
        'blockHash': _hash,
        'cumulativeGasUsed': '0x5208',
        'gasUsed': '0x5208',
        'effectiveGasPrice': '30000000000',
        'status': '0x1',
      }),
    ]);
    final pending = Transaction(
      hash: _hash,
      fromAddress: _address,
      recipients: [TransferRecipients(toAddr: _address, amount: '0.5')],
      timeStamp: DateTime(2026, 9, 1),
      transactionDirection: TransactionDirection.sent,
      fees: '0.00063',
      coinSymbol: 'MATIC',
      transactionStatus: TransactionStatus.pending,
      type: TransactionType.transfer,
      assetSymbol: 'MATIC',
      chainId: 80002,
    );
    final transactions = TransactionsCubit(initial: [pending]);
    final walletDetails = _SeededWalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final appBloc = AppBloc(
      api: api,
      transactionsCubit: transactions,
      walletDetailsCubit: walletDetails,
      networkProvider: _Networks(),
    );
    // The startup settle: the transaction is not mined yet.
    await settlePendingSends(
      walletAddress: _address,
      rows: transactions.state,
      networks: const [_amoy],
      api: api,
      storage: _NoDisk(),
      transactions: transactions,
    );
    expect(
      transactions.state.single.transactionStatus,
      TransactionStatus.pending,
    );

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<WalletDetailsCubit>.value(value: walletDetails),
          BlocProvider<TransactionsCubit>.value(value: transactions),
          BlocProvider<AppBloc>.value(value: appBloc),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: const TransactionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.fling(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 400),
      1000,
    );
    await tester.pumpAndSettle();

    final rows = transactions.state.where((t) => t.hash == _hash).toList();
    expect(rows, hasLength(1));
    expect(rows.single.transactionStatus, TransactionStatus.completed);
    expect(api.reads, 2);

    // Cancels the bloc's periodic poll, which would otherwise fail the test.
    await tester.runAsync(appBloc.close);
    await walletDetails.close();
  });
}
