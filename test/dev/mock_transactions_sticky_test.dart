import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/controllers/sgnus_transactions_controller.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dev/dev_mock_transactions.dart';

/// Reproduces the DISAPPEARANCE, not merely the moment after injection.
///
/// `Mock txns` writes SGNUS fixtures into `SGNUSTransactionsController` via
/// `addTransaction` (`dev_tools_bubble.dart:405-409`). On an SGNUS wallet,
/// `SgnusTransactionsScreen`'s `Timer.periodic(const Duration(seconds: 10))`
/// (`sgnus_transactions_screen.dart:32-34`) - and `router.dart:61` on every
/// navigation - dispatches `StartSGNUSTransactionsStream()`, which ends at
/// `genius_api.dart:879` on `getSGNUSTransactionsController().setTransactions(ret)`.
/// `setTransactions` (`sgnus_transactions_controller.dart:24-30`) opened with
/// `_transactions.clear()`, so the fixtures lived at most ten seconds, and
/// were gone the instant the user navigated. A test asserting only that
/// injection worked would have passed against that broken build; every case
/// below instead simulates the poll by calling `setTransactions` directly,
/// which is the one line the SDK stream ends on and needs no SDK, no node
/// and no widget tree to reach.
///
/// Two planning claims, confirmed cheaply rather than assumed:
/// - `grep -n "operator ==\|hashCode\|Equatable"
///   packages/genius_api/lib/models/transaction.dart` returns NOTHING -
///   `Transaction` is a plain Hive class with no value equality, which is
///   what makes the no-duplicate-on-second-press case fail today.
/// - `grep -rn "\.clear()" lib/ --include=*.dart | grep -i
///   transactionscubit` shows only `dev_tools_bubble.dart` as a caller,
///   confirming hypothesis (d) (persistence asymmetry via a wallet reload)
///   is not the live cause - nothing else clears that cubit either.
void main() {
  late SGNUSTransactionsController controller;

  setUp(() {
    controller = SGNUSTransactionsController();
  });

  tearDown(() {
    controller.dispose();
  });

  Transaction realTransaction() => Transaction(
    hash: '0xreal01',
    fromAddress: '0xRealFrom',
    recipients: [TransferRecipients(toAddr: '0xRealTo', amount: '1.0')],
    timeStamp: DateTime.now(),
    transactionDirection: TransactionDirection.received,
    fees: '0.001',
    coinSymbol: 'ETH',
    transactionStatus: TransactionStatus.completed,
    isSGNUS: true,
    type: TransactionType.transfer,
  );

  // Raw emitted list, not pre-collapsed into a Set<String> - counting on a
  // set of hashes would hide the very duplication case 5 checks for, since
  // 22 identity-distinct `Transaction`s with only 11 unique hash values
  // still map down to a Set<String> of length 11 either way. Callers assert
  // on `.length` against this list for counts, and on
  // `.map((tx) => tx.hash).toSet()` only for hash membership - never on
  // list order, which is not the render order (see file header).
  Future<List<Transaction>> emittedOf(SGNUSTransactionsController c) async {
    return c.stream.first;
  }

  test(
    'fixtures survive an SDK refresh that returns nothing (FAILS today)',
    () async {
      for (final tx in DevMockTransactions.instance.batch(isSgnus: true)) {
        controller.addTransaction(tx);
      }

      // Simulates the 10-second poll finding no SDK-side transactions.
      controller.setTransactions([]);

      final emitted = await emittedOf(controller);
      final hashes = emitted.map((tx) => tx.hash).toSet();
      expect(
        emitted.length,
        11,
        reason:
            'all 11 fixtures should still be emitted after an empty SDK '
            'refresh; got: $hashes',
      );
    },
  );

  test('fixtures survive an SDK refresh that returns a real transaction '
      '(FAILS today)', () async {
    for (final tx in DevMockTransactions.instance.batch(isSgnus: true)) {
      controller.addTransaction(tx);
    }

    controller.setTransactions([realTransaction()]);

    final emitted = await emittedOf(controller);
    final hashes = emitted.map((tx) => tx.hash).toSet();
    expect(
      emitted.length,
      12,
      reason:
          '11 fixtures plus the real transaction should both be emitted; '
          'got: $hashes',
    );
    expect(hashes.contains('0xreal01'), isTrue);
  });

  test('a real transaction from the SDK is still replaced by the next SDK '
      'refresh (PASSES today, must keep passing)', () async {
    controller.setTransactions([realTransaction()]);
    expect(
      (await emittedOf(controller)).map((tx) => tx.hash).contains('0xreal01'),
      isTrue,
    );

    // Next poll: the SDK no longer reports that transaction.
    controller.setTransactions([]);
    final hashes = (await emittedOf(controller)).map((tx) => tx.hash);
    expect(
      hashes.contains('0xreal01'),
      isFalse,
      reason:
          'the SDK feed set must still be replaced wholesale by '
          'setTransactions - only locally-added transactions are sticky',
    );
  });

  test(
    'Clear releases the fixtures (PASSES today, must keep passing)',
    () async {
      for (final tx in DevMockTransactions.instance.batch(isSgnus: true)) {
        controller.addTransaction(tx);
      }

      controller.clear();

      final emitted = await emittedOf(controller);
      expect(emitted, isEmpty);
    },
  );

  test('two presses of the button do not duplicate: 11 rows, not 22 '
      '(FAILS today)', () async {
    for (final tx in DevMockTransactions.instance.batch(isSgnus: true)) {
      controller.addTransaction(tx);
    }
    for (final tx in DevMockTransactions.instance.batch(isSgnus: true)) {
      controller.addTransaction(tx);
    }

    final emitted = await emittedOf(controller);
    final hashes = emitted.map((tx) => tx.hash).toSet();
    expect(
      emitted.length,
      11,
      reason:
          'a second press should replace the 11 fixtures by hash, not '
          'append a second identity-distinct copy; got '
          '${emitted.length} entries, ${hashes.length} unique hashes: '
          '$hashes',
    );
  });
}
