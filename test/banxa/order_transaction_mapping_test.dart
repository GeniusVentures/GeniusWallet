import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_transaction_mapping.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';

import 'fixtures.dart';

/// Locks 260731-ope's Banxa-to-transactions mapping: the status fold (D-01's
/// "one census" rule), the row record the Buy GNUS rail hands to
/// `TransactionRow` (D-03: the fiat PAID is the value line), and the drawer's
/// extra detail rows (D-01's "everything Banxa provides, and nothing it does
/// not").
///
/// No `TestWidgetsFlutterBinding`, no pump and no Hive: every function under
/// test is pure, and `orderRowContent` deliberately makes no
/// `livePricesBySymbol()` call - by D-03 an order's value line is the fiat
/// the order itself carries, never a price lookup.
void main() {
  // Same instant the fixture's default `createdAt` sits on, so the day label
  // is deterministic instead of wall-clock dependent.
  final now = DateTime.utc(2026, 1, 1, 12);
  final today = txDayLabel(DateTime.utc(2026, 1, 1, 12), now);

  group('orderTransactionStatus', () {
    test('complete maps to completed, in any case', () {
      expect(orderTransactionStatus('complete'), TransactionStatus.completed);
      expect(orderTransactionStatus('COMPLETE'), TransactionStatus.completed);
    });

    test('every in-flight status maps to pending', () {
      for (final status in [
        'pendingPayment',
        'waitingPayment',
        'extraVerification',
        'paymentReceived',
        'inProgress',
        'cryptoTransferred',
      ]) {
        expect(
          orderTransactionStatus(status),
          TransactionStatus.pending,
          reason: status,
        );
      }
    });

    test('declined is failed; expired and cancelled are neutral', () {
      expect(orderTransactionStatus('declined'), TransactionStatus.failed);
      expect(orderTransactionStatus('expired'), TransactionStatus.cancelled);
      expect(orderTransactionStatus('cancelled'), TransactionStatus.cancelled);
    });

    test('refunded maps to refunded', () {
      expect(orderTransactionStatus('refunded'), TransactionStatus.refunded);
    });

    test('an order that only looks paid is never completed', () {
      for (final status in ['paymentReceived', 'inProgress', 'completed', '']) {
        expect(
          orderTransactionStatus(status),
          isNot(TransactionStatus.completed),
          reason: status,
        );
      }
    });
  });

  group('orderRowContent', () {
    test('a complete order carries the exact crypto amount and the fiat', () {
      final content = orderRowContent(testOrder(status: 'complete'), now: now);

      expect(content.amount, '+ 0.0025 BTC');
      expect(content.tone, TxAmountTone.incoming);
      expect(content.valueLine, '100.00 USD');
      expect(content.action, 'Purchased');
      expect(content.title, 'BTC');
      expect(content.statusLabel, 'Done');
      expect(content.statusTail, isNull);
      expect(content.badge, TransactionBadgeKind.purchase);
      expect(content.status, TransactionStatus.completed);
      expect(content.iconSymbols, ['btc']);
      expect(content.subtitle, startsWith(today));
      expect(content.subtitle, contains('Card purchase'));
      expect(content.subtitle, content.subtitleBase);
    });

    test('a declined order reads Not charged and drops the green', () {
      final content = orderRowContent(testOrder(status: 'declined'), now: now);

      expect(content.valueLine, 'Not charged');
      expect(content.tone, TxAmountTone.none);
      expect(content.badge, TransactionBadgeKind.failed);
      expect(content.statusTail, 'Declined');
      expect(content.subtitle, endsWith(' · Declined'));
      expect(content.subtitleBase, isNot(contains('Declined')));
    });

    test('an unpaid order keeps its fiat and shows an approximate amount', () {
      final content = orderRowContent(
        testOrder(status: 'pendingPayment'),
        now: now,
      );

      expect(content.valueLine, '100.00 USD');
      expect(content.badge, TransactionBadgeKind.pending);
      expect(content.statusTail, 'Unpaid');
      expect(content.tone, TxAmountTone.incoming);
      expect(content.amount, '+ ≈0.0025 BTC');
    });

    test('every in-flight status uses its short tail and an approx amount', () {
      const tails = {
        'pendingPayment': 'Unpaid',
        'waitingPayment': 'Confirming',
        'extraVerification': 'Needs ID',
        'paymentReceived': 'Paid',
        'inProgress': 'Buying',
        'cryptoTransferred': 'Sending',
      };
      tails.forEach((wire, tail) {
        final content = orderRowContent(testOrder(status: wire), now: now);
        expect(content.statusTail, tail, reason: wire);
        expect(content.amount, startsWith('+ ≈'), reason: wire);
        expect(content.status, TransactionStatus.pending, reason: wire);
      });
    });

    test('expired and cancelled read Not charged in the neutral paint', () {
      for (final entry in {
        'expired': 'Expired',
        'cancelled': 'Cancelled',
      }.entries) {
        final content = orderRowContent(testOrder(status: entry.key), now: now);

        expect(content.status, TransactionStatus.cancelled);
        expect(content.statusTail, entry.value);
        expect(content.valueLine, 'Not charged');
        expect(content.tone, TxAmountTone.none);
        expect(content.amount, isNot(contains('≈')));
      }
    });

    test('an order that delivered nothing shows no incoming sign', () {
      for (final wire in ['declined', 'expired', 'cancelled', 'refunded']) {
        final content = orderRowContent(testOrder(status: wire), now: now);

        expect(content.amount, '0.0025 BTC', reason: wire);
      }
    });

    test('a refunded order says how much came back', () {
      final content = orderRowContent(testOrder(status: 'refunded'), now: now);

      expect(content.status, TransactionStatus.refunded);
      expect(content.statusTail, 'Refunded');
      expect(content.valueLine, '100.00 USD refunded');
      expect(content.tone, TxAmountTone.none);
    });

    test('an unrecognised status makes no claim about settlement', () {
      final content = orderRowContent(
        testOrder(status: 'someFutureBanxaStatus'),
        now: now,
      );

      expect(content.valueLine, '100.00 USD');
      expect(content.tone, TxAmountTone.none);
      expect(content.statusLabel, 'Unknown');
      expect(content.badge, TransactionBadgeKind.purchase);
    });

    test('a blank status carries no label at all', () {
      final content = orderRowContent(testOrder(status: ''), now: now);

      expect(content.statusLabel, isNull);
      expect(content.subtitle, content.subtitleBase);
    });

    test('the value line is the order own fiat, never a dollar prefix', () {
      final content = orderRowContent(
        testOrder(fiat: 'EUR', fiatAmount: '100.00'),
        now: now,
      );

      expect(content.valueLine, '100.00 EUR');
      expect(content.valueLine, isNot(contains('\$')));
    });

    test('the icon symbol is sanitised before it reaches an asset path', () {
      final content = orderRowContent(
        testOrder(cryptoId: '../../etc/passwd'),
        now: now,
      );

      expect(content.iconSymbols.single, 'etcpasswd');
    });
  });

  group('orderAsTransaction', () {
    test('leaves the two fields Banxa cannot fill honestly blank', () {
      final tx = orderAsTransaction(testOrder());

      // Banxa's fees are FIAT line items; the base Network Fee row would
      // suffix them with the coin symbol.
      expect(tx.fees, '');
      // Banxa provides no source address; the destination is an extra row.
      expect(tx.fromAddress, '');
    });

    test('carries the order identity across', () {
      final order = testOrder(status: 'complete', transactionHash: '0xabc123');
      final tx = orderAsTransaction(order);

      expect(tx.hash, '0xabc123');
      expect(tx.transactionDirection, TransactionDirection.received);
      expect(tx.type, TransactionType.purchase);
      expect(tx.coinSymbol, 'BTC');
      expect(tx.timeStamp, order.createdAt);
      expect(tx.transactionStatus, TransactionStatus.completed);
      expect(tx.recipients, hasLength(1));
      expect(tx.recipients.first.toAddr, order.walletAddress);
      expect(tx.recipients.first.amount, order.cryptoAmount);
    });

    test('a missing transaction hash becomes a blank the drawer skips', () {
      expect(orderAsTransaction(testOrder()).hash, '');
    });
  });

  group('orderTransactionRows', () {
    String valueFor(List<TxDetailRow> rows, String label) =>
        rows.firstWhere((r) => r.label == label).value;

    test('carries every Banxa detail the Transaction has no slot for', () {
      final rows = orderTransactionRows(testOrder());

      expect(valueFor(rows, 'Payment method'), 'Credit Card');
      expect(valueFor(rows, 'Order amount'), '100.00 USD');
      expect(valueFor(rows, 'Processing fee'), '2.50 USD');
      expect(valueFor(rows, 'Network fee'), '1.00 USD');
      expect(valueFor(rows, 'Order ID'), 'ord_0001');
      expect(
        valueFor(rows, 'To'),
        'bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh',
      );
    });

    test('the two identifiers a person copies are copy rows', () {
      final rows = orderTransactionRows(testOrder());
      final copyLabels = rows.where((r) => r.copy).map((r) => r.label).toSet();

      expect(copyLabels, containsAll(<String>['To', 'Order ID']));
      // A fiat figure is read, not copied.
      expect(copyLabels, isNot(contains('Order amount')));
    });

    test('renders no internal key and no untyped external map', () {
      final order = testOrder(
        country: 'AUS',
        metadata: const {'internalRoutingKey': 'zzz'},
      );
      final rows = orderTransactionRows(order);
      final blob = rows.map((r) => '${r.label} ${r.value}').join('\n');

      for (final forbidden in [
        order.externalCustomerId, // our customer key
        order.paymentMethodId, // the machine key for a name already shown
        order.externalId, // our app-side reference
        order.orderStatusUrl, // a URL is not a value
        order.orderType, // constant for every order this screen makes
        'AUS', // Banxa's KYC jurisdiction, not a fact about the purchase
        'internalRoutingKey', // an untyped map from an external API
      ]) {
        expect(
          blob,
          isNot(contains(forbidden)),
          reason: '$forbidden must not reach the drawer',
        );
      }
    });

    test('a null address tag becomes no row on screen', () {
      final rows = orderTransactionRows(testOrder());
      final tag = rows.where((r) => r.label == 'Address tag');

      // Either shape is D-01 compliant: absent, or blank for the drawer's own
      // blank-skip guard to drop. What must never happen is a dash.
      expect(tag.every((r) => r.value.trim().isEmpty), isTrue);
    });

    test(
      'a real address tag is a copy row, because a wrong memo loses funds',
      () {
        final rows = orderTransactionRows(testOrder(walletAddressTag: '99213'));
        final tag = rows.firstWhere((r) => r.label == 'Address tag');

        expect(tag.value, '99213');
        expect(tag.copy, isTrue);
      },
    );

    test('Last updated appears only when it says something new', () {
      final moved = orderTransactionRows(testOrder());
      expect(
        moved.where((r) => r.label == 'Last updated'),
        hasLength(1),
        reason: 'the fixture updated an hour after it was created',
      );

      final fresh = orderTransactionRows(
        testOrder(
          createdAt: DateTime.utc(2026, 1, 1, 12),
          updatedAt: DateTime.utc(2026, 1, 1, 12),
        ),
      );
      expect(
        fresh.where((r) => r.label == 'Last updated'),
        isEmpty,
        reason: 'a second date row equal to Date is noise',
      );
    });

    test('a blank fee prints no half-row', () {
      final rows = orderTransactionRows(
        testOrder(processingFee: '', networkFee: ''),
      );

      expect(valueFor(rows, 'Processing fee'), '');
      expect(valueFor(rows, 'Network fee'), '');
    });
  });

  group('orderNetworkRows', () {
    test('a real chain is disambiguated', () {
      final rows = orderNetworkRows(testOrder(network: 'Bitcoin'));

      expect(rows.single.label, 'Chain');
      expect(rows.single.value, 'Bitcoin');
    });

    test('the sandbox blank chain emits nothing', () {
      expect(orderNetworkRows(testOrder(network: '')), isEmpty);
    });
  });
}
