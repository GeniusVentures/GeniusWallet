import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_receipt.dart';

/// One expectation per `<behavior>` bullet in 08-06-PLAN.md's Task 1, for both
/// outcomes. `bridgeReceiptTransaction` is a PURE factory — no BuildContext,
/// no Flutter UI import, no cubit/storage call — so every field is asserted
/// directly against the returned `Transaction`, with an injected timestamp so
/// the test is deterministic.
void main() {
  final fixedTimestamp = DateTime(2026, 7, 27, 12, 0, 0);

  group('bridgeReceiptTransaction — success', () {
    test('maps every field per the success behavior bullet', () {
      final tx = bridgeReceiptTransaction(
        isSuccess: true,
        txHash: '0xabc123',
        walletAddress: '0xWallet',
        amount: '42.5',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(tx.transactionStatus, TransactionStatus.completed);
      expect(tx.hash, '0xabc123');
      expect(tx.coinSymbol, 'GNUS');
      expect(tx.recipients.length, 1);
      expect(tx.recipients.first.amount, '42.5');
      expect(tx.recipients.first.toAddr, '0xWallet');
      expect(tx.fromAddress, '0xWallet');
      expect(tx.type, TransactionType.mint);
      expect(tx.transactionDirection, TransactionDirection.received);
      expect(tx.fees, '');
      expect(tx.exchangeRate, isNull);
      expect(tx.timeStamp, fixedTimestamp);
    });

    test('a null response hash becomes the empty string, never "null"', () {
      final tx = bridgeReceiptTransaction(
        isSuccess: true,
        txHash: null,
        walletAddress: '0xWallet',
        amount: '1',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(tx.hash, '');
      expect(tx.hash, isNot('null'));
    });

    test('a blank response hash becomes the empty string', () {
      final tx = bridgeReceiptTransaction(
        isSuccess: true,
        txHash: '   ',
        walletAddress: '0xWallet',
        amount: '1',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(tx.hash, '');
    });
  });

  group('bridgeReceiptTransaction — failure', () {
    test('identical shape but status is failed', () {
      final tx = bridgeReceiptTransaction(
        isSuccess: false,
        txHash: '0xdef456',
        walletAddress: '0xWallet',
        amount: '10',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(tx.transactionStatus, TransactionStatus.failed);
      expect(tx.hash, '0xdef456');
      expect(tx.coinSymbol, 'GNUS');
      expect(tx.recipients.length, 1);
      expect(tx.recipients.first.amount, '10');
      expect(tx.recipients.first.toAddr, '0xWallet');
      expect(tx.fromAddress, '0xWallet');
      expect(tx.type, TransactionType.mint);
      expect(tx.transactionDirection, TransactionDirection.received);
      expect(tx.fees, '');
      expect(tx.exchangeRate, isNull);
    });

    test('hash is the empty string when the response carries no data', () {
      final tx = bridgeReceiptTransaction(
        isSuccess: false,
        txHash: null,
        walletAddress: '0xWallet',
        amount: '10',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(tx.hash, '');
      expect(tx.hash, isNot('null'));
    });
  });

  group('bridgeReceiptTransaction — fees always blank', () {
    test('fees is the empty string regardless of outcome', () {
      final successTx = bridgeReceiptTransaction(
        isSuccess: true,
        txHash: '0x1',
        walletAddress: '0xWallet',
        amount: '1',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );
      final failureTx = bridgeReceiptTransaction(
        isSuccess: false,
        txHash: '0x2',
        walletAddress: '0xWallet',
        amount: '1',
        coinSymbol: 'GNUS',
        timestamp: fixedTimestamp,
      );

      expect(successTx.fees, '');
      expect(failureTx.fees, '');
    });
  });

  group('bridgeReceiptTransaction — default timestamp', () {
    test('defaults to roughly now when no timestamp is injected', () {
      final before = DateTime.now();
      final tx = bridgeReceiptTransaction(
        isSuccess: true,
        txHash: '0x1',
        walletAddress: '0xWallet',
        amount: '1',
        coinSymbol: 'GNUS',
      );
      final after = DateTime.now();

      expect(
        tx.timeStamp.isAfter(before.subtract(const Duration(seconds: 1))),
        isTrue,
      );
      expect(
        tx.timeStamp.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
