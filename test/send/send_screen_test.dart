// The tracer: form -> fee -> review -> sign -> pending -> completed, on a
// stubbed GeniusApi so no RPC, key or real Hive box is involved (real Hive
// I/O inside testWidgets hangs here, same reasoning as swap_submit_test.dart).
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/reown/utilities.dart' show parseHexToBigInt;
import 'package:genius_wallet/send/send_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:web3dart/web3dart.dart' show TransactionReceipt;

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _walletAddress = '0xSENDSENDSENDSENDSENDSENDSENDSENDSENDSEND';
const _recipient = '0x1234567890123456789012345678901234567890';

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _maticCoin = Coin(symbol: 'matic', balance: 10);

/// Records every write instead of touching Hive.
class _RecordingStorage implements TransactionStorageService {
  final List<Transaction> writes = [];

  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async =>
      writes.add(tx);

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Answers every send read with a fixed, positive fee and balance, and
/// settles the receipt on the first poll — no real RPC, no wait.
class _FakeApi implements GeniusApi {
  Map<String, dynamic>? signedTx;

  @override
  Future<BigInt> nativeBalance({
    required String address,
    required String rpcUrl,
  }) async => BigInt.parse('10000000000000000000');

  @override
  Future<SendFee> estimateSendFee({
    required String rpcUrl,
    required String sender,
    required String recipient,
    Uint8List? data,
  }) async => SendFee(
    maxFeePerGas: BigInt.from(30000000000),
    maxPriorityFeePerGas: BigInt.from(1500000000),
    gasLimit: BigInt.from(21000),
  );

  @override
  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async {
    signedTx = tx;
    return ApiResponse.success(_hash);
  }

  @override
  Future<TransactionReceipt?> transactionReceipt({
    required String hash,
    required String rpcUrl,
  }) async => TransactionReceipt.fromMap({
    'transactionHash': _hash,
    'transactionIndex': '0x0',
    'blockHash': _hash,
    'cumulativeGasUsed': '0x5208',
    'gasUsed': '0x5208',
    'effectiveGasPrice': '30000000000',
    'status': '0x1',
  });

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Send Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.mnemonic,
  balance: 0,
  address: _walletAddress,
);

class _SeededCubit extends WalletDetailsCubit {
  _SeededCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
  }) {
    emit(
      state.copyWith(
        selectedWallet: _wallet,
        selectedNetwork: _amoy,
        coins: const [_maticCoin],
        selectedWalletBalance: '10',
      ),
    );
  }
}

Future<void> _mount(
  WidgetTester tester,
  _FakeApi api,
  _RecordingStorage storage,
  TransactionsCubit transactionsCubit,
) async {
  tester.view.physicalSize = const Size(1200, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>(
          create: (_) => _SeededCubit(
            geniusApi: api,
            networkTokensProvider: NetworkTokensProvider(),
          ),
        ),
        BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
      ],
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: SendScreen(
          preselectSymbol: 'matic',
          preselectChainId: 80002,
          storage: storage,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'send 0.5 MATIC on Amoy: form, fee, review, sign, pending, completed',
    (tester) async {
      final api = _FakeApi();
      final storage = _RecordingStorage();
      final transactionsCubit = TransactionsCubit();
      await _mount(tester, api, storage, transactionsCubit);

      await tester.enterText(find.byType(TextField).at(0), _recipient);
      await tester.enterText(find.byType(TextField).at(1), '0.5');
      await tester.pump();

      await tester.tap(find.widgetWithText(GWButton, 'Review'));
      await tester.pumpAndSettle();

      // The review drawer shows the fee in the gas coin, before approval.
      expect(find.text('Gas Fee'), findsOneWidget);
      expect(find.textContaining('MATIC'), findsWidgets);

      await tester.tap(find.widgetWithText(GWButton, 'Send'));
      await tester.pumpAndSettle();

      // The signed map: the recipient, the raw amount, no calldata.
      final tx = api.signedTx;
      expect(tx, isNotNull);
      expect((tx!['to'] as String).toLowerCase(), _recipient.toLowerCase());
      expect(parseHexToBigInt(tx['value']), BigInt.parse('500000000000000000'));
      expect(tx.containsKey('data'), isFalse);
      expect(parseHexToBigInt(tx['maxFeePerGas']), isNot(BigInt.zero));

      // History: pending written before the resolved row, same hash.
      expect(storage.writes.length, 2);
      expect(storage.writes[0].transactionStatus, TransactionStatus.pending);
      expect(storage.writes[1].transactionStatus, TransactionStatus.completed);
      expect(storage.writes[0].hash, _hash);
      expect(storage.writes[1].hash, _hash);

      // TransactionsCubit gets the resolved row exactly once.
      expect(transactionsCubit.state.length, 1);
      expect(transactionsCubit.state.first.assetSymbol, 'MATIC');
      expect(transactionsCubit.state.first.chainId, 80002);
      expect(
        transactionsCubit.state.first.transactionStatus,
        TransactionStatus.completed,
      );
    },
  );
}
