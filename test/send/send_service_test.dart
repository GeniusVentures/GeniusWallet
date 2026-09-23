// The send service is pure and network-free by injection, so it lives here
// rather than in genius_api's own test/ (that package declares no test
// dependency and CI runs only this root suite).
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
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

    test('returns null once attempts are exhausted', () async {
      var reads = 0;

      final result = await pollReceipt(
        hash: '0xhash',
        read: (hash) async {
          reads++;
          return null;
        },
        wait: (d) async {},
        attempts: 3,
      );

      expect(result, isNull);
      expect(reads, 3);
    });
  });
}
