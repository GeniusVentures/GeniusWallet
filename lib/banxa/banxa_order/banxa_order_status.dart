import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';

/// Every status Banxa reports for an order, parsed once. Anything the app does
/// not recognise is [unknown]: neutral and not final, so it is never mistaken
/// for a success and keeps being re-read.
enum BanxaOrderStatus {
  pendingPayment(
    'Waiting for payment',
    'Unpaid',
    'Finish paying in Banxa checkout. Unpaid orders expire.',
  ),
  waitingPayment(
    'Confirming payment',
    'Confirming',
    'Banxa is waiting for your bank or card to confirm the payment.',
  ),
  extraVerification(
    'Banxa needs more ID',
    'Needs ID',
    'Banxa asked for another document before it can take your payment. '
        'Nothing has been charged yet.',
  ),
  paymentReceived(
    'Payment received',
    'Paid',
    'Banxa has your payment. Your GNUS is not bought yet, so this is not '
        'final.',
  ),
  inProgress(
    'Buying your GNUS',
    'Buying',
    'Banxa is buying GNUS at the quoted rate.',
  ),
  cryptoTransferred(
    'Sending to your wallet',
    'Sending',
    'GNUS is on its way to your wallet. This usually takes a few minutes.',
  ),
  complete('Done', 'Done', 'GNUS is in your wallet.'),
  cancelled(
    'Cancelled',
    'Cancelled',
    'You left checkout before paying. You were not charged.',
  ),
  declined(
    'Payment declined',
    'Declined',
    'Your bank or card declined the payment. You were not charged.',
  ),
  expired(
    'Order expired',
    'Expired',
    'The payment was not completed in time. You were not charged.',
  ),
  refunded(
    'Refunded',
    'Refunded',
    'Banxa returned your payment to your card. Refunds take 3 to 10 '
        'business days to show.',
  ),
  unknown('Status unknown', 'Unknown', 'Banxa is checking this order.');

  const BanxaOrderStatus(this.label, this.shortLabel, this.description);

  final String label;
  final String shortLabel;
  final String description;

  // The coinTransferred spelling is seen in the wild but absent from the
  // published docs.
  static final Map<String, BanxaOrderStatus> _byWire = {
    for (final status in values) status.name.toLowerCase(): status,
    'cointransferred': cryptoTransferred,
  };

  static BanxaOrderStatus parse(String wire) =>
      _byWire[wire.toLowerCase()] ?? unknown;

  bool get isFinal => switch (this) {
    complete || declined || expired || cancelled || refunded => true,
    _ => false,
  };

  /// Final without any GNUS reaching the wallet.
  bool get deliversNothing => switch (this) {
    declined || expired || cancelled || refunded => true,
    _ => false,
  };

  bool get isPaid => switch (this) {
    paymentReceived || inProgress || cryptoTransferred || complete => true,
    _ => false,
  };

  OrderStatusTone get tone => switch (this) {
    complete => OrderStatusTone.success,
    declined => OrderStatusTone.error,
    expired || cancelled || refunded || unknown => OrderStatusTone.neutral,
    _ => OrderStatusTone.warning,
  };
}

extension BanxaOrderStatusOf on Order {
  BanxaOrderStatus get banxaStatus => BanxaOrderStatus.parse(status);
}
