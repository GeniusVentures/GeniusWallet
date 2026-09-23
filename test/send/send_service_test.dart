// The send service is pure and network-free by injection, so it lives here
// rather than in genius_api's own test/ (that package declares no test
// dependency and CI runs only this root suite).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart' show TransactionStatus;
import 'package:genius_api/web3/send_service.dart';
import 'package:web3dart/web3dart.dart';

SendFee _fee({
  BigInt? maxFeePerGas,
  BigInt? maxPriorityFeePerGas,
  BigInt? gasLimit,
}) => SendFee(
  maxFeePerGas: maxFeePerGas ?? BigInt.from(100),
  maxPriorityFeePerGas: maxPriorityFeePerGas ?? BigInt.from(10),
  gasLimit: gasLimit ?? BigInt.from(21000),
);

void main() {
  group('buildSendTx', () {
    test(
      'map shape: to/value/gas/maxFeePerGas/maxPriorityFeePerGas, no data',
      () {
        final tx = buildSendTx(
          from: '0xfrom',
          recipient: '0xrecipient',
          amount: BigInt.from(500000000000000000), // 0.5 in wei
          fee: _fee(
            maxFeePerGas: BigInt.from(30000000000),
            maxPriorityFeePerGas: BigInt.from(1500000000),
            gasLimit: BigInt.from(21000),
          ),
        );

        expect(tx['from'], '0xfrom');
        expect(tx['to'], '0xrecipient');
        expect(
          tx['value'],
          '0x${BigInt.from(500000000000000000).toRadixString(16)}',
        );
        expect(tx['gas'], '0x5208'); // 21000
        expect(tx['maxFeePerGas'], '0x6fc23ac00');
        expect(tx['maxPriorityFeePerGas'], '0x59682f00');
        expect(tx.containsKey('data'), isFalse);
      },
    );

    test('every numeric field is lowercase hex with a 0x prefix', () {
      final tx = buildSendTx(
        from: '0xfrom',
        recipient: '0xrecipient',
        amount: BigInt.parse('2748779069440'), // has A-F digits in hex
        fee: _fee(
          maxFeePerGas: BigInt.parse('2748779069440'),
          maxPriorityFeePerGas: BigInt.parse('2748779069440'),
          gasLimit: BigInt.parse('2748779069440'),
        ),
      );

      for (final key in [
        'value',
        'gas',
        'maxFeePerGas',
        'maxPriorityFeePerGas',
      ]) {
        final value = tx[key] as String;
        expect(value, startsWith('0x'));
        expect(value, value.toLowerCase());
      }
    });
  });

  group('chooseFeePerGas', () {
    test('uses the EIP-1559 answer as given when it is usable', () async {
      final fee = await chooseFeePerGas(
        eip1559: () async => (
          maxFeePerGas: BigInt.from(200),
          maxPriorityFeePerGas: BigInt.from(20),
        ),
        gasPrice: () async => fail('legacy fallback must not run'),
      );

      expect(fee.maxFeePerGas, BigInt.from(200));
      expect(fee.maxPriorityFeePerGas, BigInt.from(20));
    });

    test('a thrown EIP-1559 read falls back to the legacy price for both '
        'fields', () async {
      final fee = await chooseFeePerGas(
        eip1559: () async => throw Exception('eth_feeHistory unsupported'),
        gasPrice: () async => BigInt.from(50),
      );

      expect(fee.maxFeePerGas, BigInt.from(50));
      expect(fee.maxPriorityFeePerGas, BigInt.from(50));
    });

    test(
      'a zero max fee falls back to the legacy price for both fields',
      () async {
        final fee = await chooseFeePerGas(
          eip1559: () async =>
              (maxFeePerGas: BigInt.zero, maxPriorityFeePerGas: BigInt.zero),
          gasPrice: () async => BigInt.from(50),
        );

        expect(fee.maxFeePerGas, BigInt.from(50));
        expect(fee.maxPriorityFeePerGas, BigInt.from(50));
      },
    );

    test('a priority fee above the max is clamped to the max', () async {
      final fee = await chooseFeePerGas(
        eip1559: () async => (
          maxFeePerGas: BigInt.from(100),
          maxPriorityFeePerGas: BigInt.from(150),
        ),
        gasPrice: () async => fail('legacy fallback must not run'),
      );

      expect(fee.maxFeePerGas, BigInt.from(100));
      expect(fee.maxPriorityFeePerGas, BigInt.from(100));
    });

    test('both the fee market and the legacy price failing throws '
        'SendFeeUnavailable', () async {
      await expectLater(
        chooseFeePerGas(
          eip1559: () async => throw Exception('no fee market'),
          gasPrice: () async => throw Exception('no legacy price either'),
        ),
        throwsA(isA<SendFeeUnavailable>()),
      );
    });

    test('a zero legacy price throws SendFeeUnavailable', () async {
      await expectLater(
        chooseFeePerGas(
          eip1559: () async => throw Exception('no fee market'),
          gasPrice: () async => BigInt.zero,
        ),
        throwsA(isA<SendFeeUnavailable>()),
      );
    });
  });

  group('pollReceipt', () {
    test('settles on the receipt it reads', () async {
      final waits = <Duration>[];
      var reads = 0;
      final receipt = TransactionReceipt(
        transactionHash: Uint8List(0),
        transactionIndex: 0,
        blockHash: Uint8List(0),
        cumulativeGasUsed: BigInt.zero,
        status: true,
      );

      final result = await pollReceipt(
        hash: '0xhash',
        read: (hash) async {
          reads++;
          return reads < 2 ? null : receipt;
        },
        wait: (d) async => waits.add(d),
      );

      expect(result, same(receipt));
      expect(reads, 2);
      expect(waits, [const Duration(seconds: 3)]);
    });

    test('returns null once attempts are exhausted, exactly attempts reads '
        'and attempts - 1 waits', () async {
      var reads = 0;
      final waits = <Duration>[];

      final result = await pollReceipt(
        hash: '0xhash',
        read: (hash) async {
          reads++;
          return null;
        },
        wait: (d) async => waits.add(d),
        attempts: 3,
      );

      expect(result, isNull);
      expect(reads, 3);
      expect(waits.length, 2);
    });

    test('a throwing read is not terminal -- it keeps polling like a null '
        'read', () async {
      var reads = 0;
      final receipt = TransactionReceipt(
        transactionHash: Uint8List(0),
        transactionIndex: 0,
        blockHash: Uint8List(0),
        cumulativeGasUsed: BigInt.zero,
        status: true,
      );

      final result = await pollReceipt(
        hash: '0xhash',
        read: (hash) async {
          reads++;
          if (reads == 1) {
            throw Exception('not indexed yet');
          }
          return receipt;
        },
        wait: (d) async {},
      );

      expect(result, same(receipt));
      expect(reads, 2);
    });

    test('a status-false receipt returns at once -- a settled failure is '
        'terminal, not a reason to keep polling', () async {
      var reads = 0;
      final failed = TransactionReceipt(
        transactionHash: Uint8List(0),
        transactionIndex: 0,
        blockHash: Uint8List(0),
        cumulativeGasUsed: BigInt.zero,
        status: false,
      );

      final result = await pollReceipt(
        hash: '0xhash',
        read: (hash) async {
          reads++;
          return failed;
        },
        wait: (d) async => fail('a settled receipt must not wait again'),
      );

      expect(result, same(failed));
      expect(reads, 1);
    });
  });

  group('settledStatus', () {
    test('no receipt is pending', () {
      expect(settledStatus(null), TransactionStatus.pending);
    });

    test('a status-true receipt is completed', () {
      final receipt = TransactionReceipt(
        transactionHash: Uint8List(0),
        transactionIndex: 0,
        blockHash: Uint8List(0),
        cumulativeGasUsed: BigInt.zero,
        status: true,
      );
      expect(settledStatus(receipt), TransactionStatus.completed);
    });

    test('a status-false receipt is failed', () {
      final receipt = TransactionReceipt(
        transactionHash: Uint8List(0),
        transactionIndex: 0,
        blockHash: Uint8List(0),
        cumulativeGasUsed: BigInt.zero,
        status: false,
      );
      expect(settledStatus(receipt), TransactionStatus.failed);
    });
  });

  group('feePaid', () {
    test('gasUsed times effectiveGasPrice', () {
      final receipt = TransactionReceipt.fromMap({
        'transactionHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'transactionIndex': '0x0',
        'blockHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'cumulativeGasUsed': '0x5208',
        'gasUsed': '0x5208',
        'effectiveGasPrice': '30000000000',
      });

      expect(feePaid(receipt), BigInt.from(21000) * BigInt.from(30000000000));
    });

    test('null when the receipt is null', () {
      expect(feePaid(null), isNull);
    });

    test('null when gasUsed is missing', () {
      final receipt = TransactionReceipt.fromMap({
        'transactionHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'transactionIndex': '0x0',
        'blockHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'cumulativeGasUsed': '0x5208',
        'effectiveGasPrice': '30000000000',
      });

      expect(feePaid(receipt), isNull);
    });

    test('null when effectiveGasPrice is missing', () {
      final receipt = TransactionReceipt.fromMap({
        'transactionHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'transactionIndex': '0x0',
        'blockHash': '0xfeedfacefeedfacefeedfacefeedfacefeedface',
        'cumulativeGasUsed': '0x5208',
        'gasUsed': '0x5208',
      });

      expect(feePaid(receipt), isNull);
    });
  });
}
