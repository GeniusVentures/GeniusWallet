import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';

import 'fixtures.dart';

void main() {
  const wire = {
    'pendingPayment': BanxaOrderStatus.pendingPayment,
    'waitingPayment': BanxaOrderStatus.waitingPayment,
    'extraVerification': BanxaOrderStatus.extraVerification,
    'paymentReceived': BanxaOrderStatus.paymentReceived,
    'inProgress': BanxaOrderStatus.inProgress,
    'cryptoTransferred': BanxaOrderStatus.cryptoTransferred,
    'complete': BanxaOrderStatus.complete,
    'cancelled': BanxaOrderStatus.cancelled,
    'declined': BanxaOrderStatus.declined,
    'expired': BanxaOrderStatus.expired,
    'refunded': BanxaOrderStatus.refunded,
  };

  test('each wire status parses to its own value, ignoring case', () {
    wire.forEach((text, status) {
      expect(BanxaOrderStatus.parse(text), status);
      expect(BanxaOrderStatus.parse(text.toUpperCase()), status);
    });
  });

  test('coinTransferred is an alias of cryptoTransferred', () {
    expect(
      BanxaOrderStatus.parse('coinTransferred'),
      BanxaOrderStatus.cryptoTransferred,
    );
  });

  test('anything else is unknown and never throws', () {
    for (final text in ['', 'completed', 'someFutureStatus', ' complete']) {
      expect(BanxaOrderStatus.parse(text), BanxaOrderStatus.unknown);
    }
  });

  test('final means done for good; paymentReceived is not final', () {
    final finals = {
      BanxaOrderStatus.complete,
      BanxaOrderStatus.declined,
      BanxaOrderStatus.expired,
      BanxaOrderStatus.cancelled,
      BanxaOrderStatus.refunded,
    };
    for (final status in BanxaOrderStatus.values) {
      expect(status.isFinal, finals.contains(status), reason: '$status');
    }
    expect(BanxaOrderStatus.paymentReceived.isFinal, isFalse);
    expect(BanxaOrderStatus.unknown.isFinal, isFalse);
  });

  test('paid means Banxa holds the money', () {
    final paid = {
      BanxaOrderStatus.paymentReceived,
      BanxaOrderStatus.inProgress,
      BanxaOrderStatus.cryptoTransferred,
      BanxaOrderStatus.complete,
    };
    for (final status in BanxaOrderStatus.values) {
      expect(status.isPaid, paid.contains(status), reason: '$status');
    }
  });

  test('tone: only complete is success and only declined is an error', () {
    for (final status in BanxaOrderStatus.values) {
      final expected = switch (status) {
        BanxaOrderStatus.complete => OrderStatusTone.success,
        BanxaOrderStatus.declined => OrderStatusTone.error,
        BanxaOrderStatus.expired ||
        BanxaOrderStatus.cancelled ||
        BanxaOrderStatus.refunded ||
        BanxaOrderStatus.unknown => OrderStatusTone.neutral,
        _ => OrderStatusTone.warning,
      };
      expect(status.tone, expected, reason: '$status');
    }
  });

  test('every value has copy, and the labels match the design table', () {
    const labels = {
      BanxaOrderStatus.pendingPayment: ('Waiting for payment', 'Unpaid'),
      BanxaOrderStatus.waitingPayment: ('Confirming payment', 'Confirming'),
      BanxaOrderStatus.extraVerification: ('Banxa needs more ID', 'Needs ID'),
      BanxaOrderStatus.paymentReceived: ('Payment received', 'Paid'),
      BanxaOrderStatus.inProgress: ('Buying your GNUS', 'Buying'),
      BanxaOrderStatus.cryptoTransferred: ('Sending to your wallet', 'Sending'),
      BanxaOrderStatus.complete: ('Done', 'Done'),
      BanxaOrderStatus.cancelled: ('Cancelled', 'Cancelled'),
      BanxaOrderStatus.declined: ('Payment declined', 'Declined'),
      BanxaOrderStatus.expired: ('Order expired', 'Expired'),
      BanxaOrderStatus.refunded: ('Refunded', 'Refunded'),
      BanxaOrderStatus.unknown: ('Status unknown', 'Unknown'),
    };
    expect(labels.keys.toSet(), BanxaOrderStatus.values.toSet());
    for (final status in BanxaOrderStatus.values) {
      expect(status.label, labels[status]!.$1);
      expect(status.shortLabel, labels[status]!.$2);
      expect(status.description, isNotEmpty, reason: '$status');
    }
    expect(BanxaOrderStatus.complete.description, 'GNUS is in your wallet.');
    expect(
      BanxaOrderStatus.unknown.description,
      'Banxa is checking this order.',
    );
  });

  test('an Order reads its status through banxaStatus', () {
    expect(
      testOrder(status: 'coinTransferred').banxaStatus,
      BanxaOrderStatus.cryptoTransferred,
    );
    expect(testOrder(status: 'nope').banxaStatus, BanxaOrderStatus.unknown);
  });
}
