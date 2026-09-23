// SendCubit in isolation: no widget, no RPC, no real Hive box -- a
// configurable fake GeniusApi drives every case.
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/send/send_cubit.dart';
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

SendFee _fee() => SendFee(
  maxFeePerGas: BigInt.from(30000000000),
  maxPriorityFeePerGas: BigInt.from(1500000000),
  gasLimit: BigInt.from(21000),
);

TransactionReceipt _completedReceipt() => TransactionReceipt.fromMap({
  'transactionHash': _hash,
  'transactionIndex': '0x0',
  'blockHash': _hash,
  'cumulativeGasUsed': '0x5208',
  'gasUsed': '0x5208',
  'effectiveGasPrice': '30000000000',
  'status': '0x1',
});

class _RecordingStorage implements TransactionStorageService {
  _RecordingStorage({this.failWrites = false});

  final bool failWrites;
  final List<Transaction> writes = [];

  @override
  Future<void> addTransaction(String walletAddress, Transaction tx) async {
    if (failWrites) {
      throw StateError('disk full');
    }
    writes.add(tx);
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Every response is configurable per test; every call is counted so a test
/// can assert "signs once" without inspecting cubit internals.
class _ConfigurableApi implements GeniusApi {
  _ConfigurableApi({
    BigInt? balance,
    this.estimateError,
    this.signResponse,
    this.signError,
    List<TransactionReceipt?>? receiptSequence,
    List<SendFee>? feeSequence,
    BigInt? tokenBalance,
  }) : balance = balance ?? BigInt.parse('10000000000000000000'),
       tokenBalance = tokenBalance ?? BigInt.zero,
       _receiptSequence = receiptSequence ?? [_completedReceipt()],
       _feeSequence = feeSequence ?? [_fee()];

  final BigInt balance;
  final BigInt tokenBalance;
  Exception? estimateError;
  ApiResponse<String>? signResponse;
  Exception? signError;
  final List<TransactionReceipt?> _receiptSequence;
  int _receiptCalls = 0;
  final List<SendFee> _feeSequence;
  int _feeCalls = 0;

  int signCalls = 0;
  final List<Map<String, dynamic>> signedTxs = [];
  final List<BigInt?> feeValues = [];
  final List<int?> feeChainIds = [];

  @override
  Future<BigInt> readTokenBalance({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async => tokenBalance;

  @override
  Future<BigInt> nativeBalance({
    required String address,
    required String rpcUrl,
  }) async => balance;

  @override
  Future<SendFee> estimateSendFee({
    required String rpcUrl,
    required String sender,
    required String recipient,
    Uint8List? data,
    BigInt? value,
    int? chainId,
  }) async {
    feeValues.add(value);
    feeChainIds.add(chainId);
    if (estimateError != null) {
      throw estimateError!;
    }
    // A geth-family node refuses to estimate a value beyond the balance.
    if (value != null && value > balance) {
      throw Exception('insufficient funds for gas * price + value');
    }
    // A later call reads past the end of a shorter sequence by repeating its
    // last entry -- the same convention the receipt sequence above uses, so
    // a "grown fee" test only has to name the two fees that matter.
    final index = _feeCalls < _feeSequence.length
        ? _feeCalls
        : _feeSequence.length - 1;
    _feeCalls++;
    return _feeSequence[index];
  }

  @override
  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async {
    signCalls++;
    signedTxs.add(tx);
    if (signError != null) {
      throw signError!;
    }
    return signResponse ?? ApiResponse.success(_hash);
  }

  @override
  Future<TransactionReceipt?> transactionReceipt({
    required String hash,
    required String rpcUrl,
  }) async {
    final index = _receiptCalls < _receiptSequence.length
        ? _receiptCalls
        : _receiptSequence.length - 1;
    _receiptCalls++;
    return _receiptSequence[index];
  }

  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

SendCubit _cubit({
  required _ConfigurableApi api,
  required TransactionsCubit transactions,
  required _RecordingStorage storage,
  Future<void> Function(Duration)? wait,
  Network? coinsLoadedFor = _amoy,
}) => SendCubit(
  api: api,
  walletAddress: _walletAddress,
  network: _amoy,
  transactions: transactions,
  storage: storage,
  coinsLoadedFor: () => coinsLoadedFor,
  initialCoin: _maticCoin,
  wait: wait ?? (d) async {},
);

void main() {
  group('review', () {
    test(
      'a coin list still loaded for another network builds nothing',
      () async {
        final api = _ConfigurableApi();
        final cubit = _cubit(
          api: api,
          transactions: TransactionsCubit(),
          storage: _RecordingStorage(),
          coinsLoadedFor: const Network(
            name: 'Ethereum',
            symbol: 'eth',
            chainId: 1,
            rpcUrl: 'https://rpc.invalid',
          ),
        );
        cubit.setRecipient(_recipient);
        cubit.setAmount('0.5');

        await cubit.review();

        expect(cubit.state.review, isNull);
        expect(cubit.state.error, contains('still loading'));
        expect(api.feeValues, isEmpty);
      },
    );

    test('a thrown estimate shows "Couldn\'t estimate the network fee." and '
        'opens no review', () async {
      final api = _ConfigurableApi(estimateError: Exception('rpc down'));
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');

      await cubit.review();

      expect(cubit.state.error, "Couldn't estimate the network fee.");
      expect(cubit.state.review, isNull);
    });

    test('a thrown SendFeeUnavailable shows the same message', () async {
      final api = _ConfigurableApi(estimateError: const SendFeeUnavailable());
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');

      await cubit.review();

      expect(cubit.state.error, "Couldn't estimate the network fee.");
      expect(cubit.state.review, isNull);
    });

    test(
      'an edit while review reads are in flight drops the stale review',
      () async {
        final api = _ConfigurableApi();
        final cubit = _cubit(
          api: api,
          transactions: TransactionsCubit(),
          storage: _RecordingStorage(),
        );
        cubit.setRecipient(_recipient);
        cubit.setAmount('0.5');

        final pending = cubit.review();
        cubit.setAmount('0.6');
        await pending;

        expect(cubit.state.review, isNull);
        expect(cubit.state.busy, isFalse);
        expect(cubit.state.amount, '0.6');
      },
    );

    test('a checksum typo or the zero address never reaches review', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setAmount('0.5');

      for (final bad in [
        '0x71c7656EC7ab88b098defB751B7401B5f6d8976F',
        '0x0000000000000000000000000000000000000000',
      ]) {
        cubit.setRecipient(bad);
        await cubit.review();

        expect(cubit.state.review, isNull, reason: bad);
        expect(cubit.state.recipientError, isNotNull, reason: bad);
      }
    });

    test('a native send is priced with its value attached', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');

      await cubit.review();

      expect(api.feeValues.single, BigInt.parse('500000000000000000'));
      // The chain id is what decides whether an L1 data fee is read.
      expect(api.feeChainIds.single, 80002);
    });

    test('amount plus fee above balance names the gas coin', () async {
      final api = _ConfigurableApi(balance: BigInt.zero);
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');

      await cubit.review();

      expect(cubit.state.amountError, contains('MATIC'));
      expect(cubit.state.review, isNull);
    });
  });

  group('submit', () {
    test('a failed signature writes nothing, keeps the form and shows the '
        'returned reason', () async {
      final api = _ConfigurableApi(
        signResponse: ApiResponse.error('User rejected'),
      );
      final storage = _RecordingStorage();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: storage,
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      final result = await cubit.submit();

      expect(result, isNull);
      expect(cubit.state.error, 'User rejected');
      expect(cubit.state.recipient, _recipient);
      expect(cubit.state.amount, '0.5');
      expect(storage.writes, isEmpty);
    });

    test('a thrown sign call frees the form and says so', () async {
      final api = _ConfigurableApi(signError: Exception('keychain locked'));
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      final result = await cubit.submit();

      expect(result, isNull);
      expect(cubit.state.busy, isFalse);
      expect(cubit.state.error, isNotNull);
    });

    test(
      'a failed history write after broadcast still records the send',
      () async {
        final api = _ConfigurableApi();
        final transactionsCubit = TransactionsCubit();
        final cubit = _cubit(
          api: api,
          transactions: transactionsCubit,
          storage: _RecordingStorage(failWrites: true),
        );
        cubit.setRecipient(_recipient);
        cubit.setAmount('0.5');
        await cubit.review();

        final result = await cubit.submit();

        expect(result, isNotNull);
        expect(transactionsCubit.state.single.hash, _hash);
        expect(cubit.state.busy, isFalse);
      },
    );

    test('an unanswered broadcast is tracked by its hash, not reported as '
        'unsent', () async {
      final api = _ConfigurableApi(
        signResponse: ApiResponse.unconfirmed(_hash, 'connection reset'),
        receiptSequence: [null],
      );
      final storage = _RecordingStorage();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: storage,
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      final result = await cubit.submit();

      expect(result?.hash, _hash);
      expect(result?.transactionStatus, TransactionStatus.pending);
      expect(storage.writes.map((w) => w.hash), everyElement(_hash));
      expect(cubit.state.amount, '');
      expect(cubit.state.error, contains('pending'));
    });

    test(
      'an unanswered broadcast that later mines resolves normally',
      () async {
        final api = _ConfigurableApi(
          signResponse: ApiResponse.unconfirmed(_hash, 'connection reset'),
        );
        final cubit = _cubit(
          api: api,
          transactions: TransactionsCubit(),
          storage: _RecordingStorage(),
        );
        cubit.setRecipient(_recipient);
        cubit.setAmount('0.5');
        await cubit.review();

        final result = await cubit.submit();

        expect(result?.transactionStatus, TransactionStatus.completed);
        expect(cubit.state.error, isNull);
      },
    );

    test('cancelReview then submit signs nothing', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();
      cubit.cancelReview();

      final result = await cubit.submit();

      expect(result, isNull);
      expect(api.signCalls, 0);
    });

    test('two overlapping submits sign once', () async {
      final api = _ConfigurableApi();
      final storage = _RecordingStorage();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: storage,
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      final first = cubit.submit();
      final second = cubit.submit();
      await Future.wait([first, second]);

      expect(api.signCalls, 1);
    });

    test('closing the cubit mid-poll still produces both writes and the '
        'single TransactionsCubit add', () async {
      final api = _ConfigurableApi(
        receiptSequence: [null, _completedReceipt()],
      );
      final storage = _RecordingStorage();
      final transactionsCubit = TransactionsCubit();
      late SendCubit cubit;
      cubit = _cubit(
        api: api,
        transactions: transactionsCubit,
        storage: storage,
        // The poll's own wait -- closes the cubit exactly once, between
        // the first (null) read and the second (settled) one.
        wait: (d) async => cubit.close(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      await cubit.submit();

      expect(storage.writes.length, 2);
      expect(storage.writes[0].transactionStatus, TransactionStatus.pending);
      expect(storage.writes[1].transactionStatus, TransactionStatus.completed);
      expect(transactionsCubit.state.length, 1);
    });
  });

  group('useMax', () {
    test('native MAX equals the balance minus maxCost, to the wei', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );

      await cubit.useMax();

      expect(cubit.state.amount, '9.99937');
      expect(cubit.state.error, isNull);
    });

    test('native MAX also leaves room for an L1 data fee', () async {
      final api = _ConfigurableApi(
        feeSequence: [
          SendFee(
            maxFeePerGas: BigInt.from(30000000000),
            maxPriorityFeePerGas: BigInt.from(1500000000),
            gasLimit: BigInt.from(21000),
            l1Fee: BigInt.parse('100000000000000'), // 0.0001
          ),
        ],
      );
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );

      await cubit.useMax();

      expect(cubit.state.amount, '9.99927');
    });

    test(
      'a balance that cannot cover the fee sets the message, never negative',
      () async {
        final api = _ConfigurableApi(balance: BigInt.from(629999999999999));
        final cubit = _cubit(
          api: api,
          transactions: TransactionsCubit(),
          storage: _RecordingStorage(),
        );

        await cubit.useMax();

        expect(cubit.state.amountError, contains('MATIC'));
        expect(cubit.state.amount, '');
      },
    );

    test(
      'a fee that grows between MAX and review refuses rather than signing',
      () async {
        final small = _fee();
        final grown = SendFee(
          maxFeePerGas: small.maxFeePerGas * BigInt.from(1000),
          maxPriorityFeePerGas: small.maxPriorityFeePerGas,
          gasLimit: small.gasLimit,
        );
        final api = _ConfigurableApi(feeSequence: [small, grown]);
        final cubit = _cubit(
          api: api,
          transactions: TransactionsCubit(),
          storage: _RecordingStorage(),
        );
        cubit.setRecipient(_recipient);

        await cubit.useMax();
        expect(cubit.state.amount, isNotEmpty);

        await cubit.review();

        expect(cubit.state.amountError, contains('MATIC'));
        expect(cubit.state.review, isNull);
        expect(api.signCalls, 0);
      },
    );
  });

  group('settlePendingSends', () {
    Transaction row({
      required String hash,
      TransactionStatus status = TransactionStatus.pending,
      int? chainId = 80002,
      String from = _walletAddress,
    }) => Transaction(
      hash: hash,
      fromAddress: from,
      recipients: [TransferRecipients(toAddr: _recipient, amount: '0.5')],
      timeStamp: DateTime(2026, 9, 1),
      transactionDirection: TransactionDirection.sent,
      fees: '0.00063',
      coinSymbol: 'MATIC',
      transactionStatus: status,
      type: TransactionType.transfer,
      assetSymbol: 'MATIC',
      chainId: chainId,
    );

    test('a pending send that has since mined is rewritten settled', () async {
      final storage = _RecordingStorage();
      final pending = row(hash: _hash);
      final transactionsCubit = TransactionsCubit(initial: [pending]);

      await settlePendingSends(
        walletAddress: _walletAddress,
        rows: [pending],
        networks: const [_amoy],
        api: _ConfigurableApi(),
        storage: storage,
        transactions: transactionsCubit,
      );

      final settled = storage.writes.single;
      expect(settled.hash, _hash);
      expect(settled.transactionStatus, TransactionStatus.completed);
      expect(settled.fees, '0.00063');
      expect(settled.assetSymbol, 'MATIC');
      expect(
        transactionsCubit.state.single.transactionStatus,
        TransactionStatus.completed,
      );
    });

    test(
      'settled rows, unmined sends and chainless rows are left alone',
      () async {
        final storage = _RecordingStorage();
        final api = _ConfigurableApi(receiptSequence: [null]);

        await settlePendingSends(
          walletAddress: _walletAddress,
          rows: [
            row(hash: '0x01', status: TransactionStatus.completed),
            row(hash: '0x02'),
            row(hash: '0x03', chainId: null),
          ],
          networks: const [_amoy],
          api: api,
          storage: storage,
          transactions: TransactionsCubit(),
        );

        expect(storage.writes, isEmpty);
      },
    );

    test(
      "another wallet's pending send is never settled into this one",
      () async {
        final storage = _RecordingStorage();
        final other = row(
          hash: _hash,
          from: '0x9999999999999999999999999999999999999999',
        );
        final transactionsCubit = TransactionsCubit(initial: [other]);

        await settlePendingSends(
          walletAddress: _walletAddress,
          rows: [other],
          networks: const [_amoy],
          api: _ConfigurableApi(),
          storage: storage,
          transactions: transactionsCubit,
        );

        expect(storage.writes, isEmpty);
        expect(
          transactionsCubit.state.single.transactionStatus,
          TransactionStatus.pending,
        );
      },
    );

    test('the sender matches regardless of address case', () async {
      final storage = _RecordingStorage();
      final pending = row(hash: _hash, from: _walletAddress.toUpperCase());

      await settlePendingSends(
        walletAddress: _walletAddress.toLowerCase(),
        rows: [pending],
        networks: const [_amoy],
        api: _ConfigurableApi(),
        storage: storage,
        transactions: TransactionsCubit(initial: [pending]),
      );

      expect(
        storage.writes.single.transactionStatus,
        TransactionStatus.completed,
      );
    });
  });

  group('selectCoin', () {
    test('clears the amount and any review', () async {
      final api = _ConfigurableApi();
      final cubit = _cubit(
        api: api,
        transactions: TransactionsCubit(),
        storage: _RecordingStorage(),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();
      expect(cubit.state.review, isNotNull);

      cubit.selectCoin(const Coin(symbol: 'usdc', address: '0xtoken'));

      expect(cubit.state.coin?.symbol, 'usdc');
      expect(cubit.state.amount, '');
      expect(cubit.state.review, isNull);
    });
  });

  test(
    'a history reload during the poll leaves one row for the send',
    () async {
      final transactions = TransactionsCubit();
      final storage = _RecordingStorage();
      final api = _ConfigurableApi(
        receiptSequence: [null, _completedReceipt()],
      );
      final cubit = _cubit(
        api: api,
        transactions: transactions,
        storage: storage,
        // What a wallet reload does while the poll waits: stored rows come
        // back into the live history, the pending one included.
        wait: (d) async =>
            transactions.addTransactions(List.of(storage.writes)),
      );
      cubit.setRecipient(_recipient);
      cubit.setAmount('0.5');
      await cubit.review();

      await cubit.submit();

      final rows = transactions.state.where((t) => t.hash == _hash).toList();
      expect(rows, hasLength(1));
      expect(rows.single.transactionStatus, TransactionStatus.completed);
    },
  );

  test('the send is in history as pending while the poll waits', () async {
    final transactions = TransactionsCubit();
    List<Transaction>? duringPoll;
    final cubit = _cubit(
      api: _ConfigurableApi(receiptSequence: [null, _completedReceipt()]),
      transactions: transactions,
      storage: _RecordingStorage(),
      wait: (d) async => duringPoll ??= transactions.state
          .where((t) => t.hash == _hash)
          .toList(),
    );
    cubit.setRecipient(_recipient);
    cubit.setAmount('0.5');
    await cubit.review();

    await cubit.submit();

    expect(duringPoll, hasLength(1));
    expect(duringPoll!.single.transactionStatus, TransactionStatus.pending);
    final rows = transactions.state.where((t) => t.hash == _hash).toList();
    expect(rows, hasLength(1));
    expect(rows.single.transactionStatus, TransactionStatus.completed);
  });
}
