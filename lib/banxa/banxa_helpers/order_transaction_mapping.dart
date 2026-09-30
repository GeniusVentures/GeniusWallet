import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_status.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:intl/intl.dart';

/// The Banxa side of "a Buy GNUS order renders as a Transactions-tab row"
/// (quick task 260731-ope).
///
/// It lives HERE, in the banxa layer, because every fact it encodes is a Banxa
/// fact: which status strings exist, that the fees are denominated in FIAT,
/// that `externalId` is ours while `id` is theirs, that `transactionHash` may
/// be absent. None of that belongs in `transaction_utils.dart`, which stays
/// ignorant of orders - the row and the drawer take a pre-built record and a
/// list of data rows, and branch on nothing.
///
/// Pure functions, no widgets, no `livePricesBySymbol()` call: by D-03 an
/// order's value line is the fiat the order itself carries, so there is no
/// price lookup and therefore no Hive box and no binding needed to test any of
/// this.

/// Same shape as the drawer's own Date row (`transaction_displays.dart`).
/// Deliberately a second declaration rather than an export: two occurrences do
/// not justify a shared symbol (AGENTS.md's Rule of Three), and the drawer's
/// formatter is private to the file that owns the drawer.
final DateFormat _orderDateFormat = DateFormat("MMMM d, y 'at' h:mm a");

/// The shared row and drawer only know [TransactionStatus], so expired and
/// cancelled share its neutral paint; the enum label keeps them distinct.
TransactionStatus orderTransactionStatus(String status) =>
    switch (BanxaOrderStatus.parse(status)) {
      BanxaOrderStatus.complete => TransactionStatus.completed,
      BanxaOrderStatus.declined => TransactionStatus.failed,
      BanxaOrderStatus.cancelled ||
      BanxaOrderStatus.expired => TransactionStatus.cancelled,
      BanxaOrderStatus.refunded => TransactionStatus.refunded,
      _ => TransactionStatus.pending,
    };

/// A `<amount> <currency>` fiat string, or BLANK when the source is blank.
///
/// `formatTxAmount` and never `formatFiat`: the latter prefixes a dollar sign,
/// which is simply wrong for a EUR or AUD order. `formatTxAmount` also carries
/// the 37639d5 unbounded-string guard, and every raw Banxa number in this file
/// goes through it.
String _fiatText(String raw, String currency) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return '${formatTxAmount(trimmed)} $currency';
}

/// The row record for one order, built here rather than derived by
/// `txRowContent`.
///
/// Declined, expired and cancelled orders read `Not charged`; an unrecognised
/// status keeps its fiat, since nothing is known about the money.
/// [now] is injectable so the day label is testable.
TxRowContent orderRowContent(Order order, {DateTime? now}) {
  final banxa = order.banxaStatus;
  final statusLabel = order.status.trim().isEmpty ? null : banxa.shortLabel;
  final status = orderTransactionStatus(order.status);

  final TransactionBadgeKind badge = switch (banxa) {
    BanxaOrderStatus.declined => TransactionBadgeKind.failed,
    BanxaOrderStatus.complete ||
    BanxaOrderStatus.cancelled ||
    BanxaOrderStatus.expired ||
    BanxaOrderStatus.refunded ||
    BanxaOrderStatus.unknown => TransactionBadgeKind.purchase,
    _ => TransactionBadgeKind.pending,
  };

  final TxAmountTone amountTone = switch (banxa.tone) {
    OrderStatusTone.success || OrderStatusTone.warning => TxAmountTone.incoming,
    OrderStatusTone.error || OrderStatusTone.neutral => TxAmountTone.none,
  };

  final fiatPaid = _fiatText(order.fiatAmount, order.fiat);
  final valueLine = switch (banxa) {
    BanxaOrderStatus.declined ||
    BanxaOrderStatus.expired ||
    BanxaOrderStatus.cancelled => 'Not charged',
    BanxaOrderStatus.refunded => fiatPaid.isEmpty ? '' : '$fiatPaid refunded',
    _ => fiatPaid,
  };

  final sign = banxa.deliversNothing
      ? ''
      : banxa.isFinal
      ? '+ '
      : '+ ≈';

  // The rail renders at most four rows and orders arrive one at a time on
  // different days, so it does NOT group by day the way the tab does - eight
  // elements for four facts in a bounded card. The day therefore rides in the
  // row's own context line, using the same `·` separator and the same
  // `txDayLabel` the tab's headers use, so nothing is lost to `time` being
  // `HH:mm` only.
  final dayLabel = txDayLabel(order.createdAt, now ?? DateTime.now());
  // Banxa's own method name; 'Card purchase' is only the fallback for an order
  // that carries none.
  final method = order.paymentMethodName.trim();
  final subtitleBase =
      '$dayLabel · ${method.isEmpty ? 'Card purchase' : method}';
  final subtitle = (banxa == BanxaOrderStatus.complete || statusLabel == null)
      ? subtitleBase
      : '$subtitleBase · $statusLabel';

  return TxRowContent(
    badge: badge,
    title: order.crypto.id,
    action: 'Purchased',
    subtitle: subtitle,
    subtitleBase: subtitleBase,
    status: status,
    amount: '$sign${formatTxAmount(order.cryptoAmount)} ${order.crypto.id}',
    tone: amountTone,
    exactAmount: exactTxAmount(order.cryptoAmount),
    valueLine: valueLine.isEmpty ? null : valueLine,
    // Sanitised HERE, so the widget never sees a raw, attacker-chosen symbol
    // on its way into `assets/images/crypto/<symbol>.png`.
    iconSymbols: [sanitizeCoinAsset(order.crypto.id)],
    time: txTimeLabel(order.createdAt),
    statusLabel: statusLabel,
  );
}

/// The order as the `Transaction` the shared row and drawer take.
///
/// Two fields are deliberately BLANK, and both are D-01's absent-not-empty rule
/// in practice - the drawer's own blank-skip guard drops the rows they would
/// have filled:
///   - `fees`: Banxa's `networkFee` and `processingFee` are FIAT line items on
///     a card receipt, and the base Network Fee row would print them suffixed
///     with the coin symbol ("1.00 BTC"), which is false. They go in as their
///     own two fiat rows instead ([orderTransactionRows]).
///   - `fromAddress`: Banxa provides no source address. The DESTINATION goes in
///     as an extra row with the right label.
Transaction orderAsTransaction(Order order) => Transaction(
  // Blank until Banxa settles the purchase on chain - the Hash row and the
  // View on Explorer footer both vanish, which is the honest state.
  hash: order.transactionHash ?? '',
  fromAddress: '',
  recipients: [
    TransferRecipients(toAddr: order.walletAddress, amount: order.cryptoAmount),
  ],
  timeStamp: order.createdAt,
  transactionDirection: TransactionDirection.received,
  fees: '',
  coinSymbol: order.crypto.id,
  transactionStatus: orderTransactionStatus(order.status),
  type: TransactionType.purchase,
);

/// The TRANSACTION-group extras: everything a `Transaction` has no slot for.
///
/// A value Banxa did not provide is emitted BLANK rather than guarded here -
/// the drawer's `add()`/`addCopy()` return early on a blank value, so it
/// becomes no row at all (D-01).
///
/// Deliberately EXCLUDED, because D-01 asks for what Banxa provides and an
/// internal id soup is not that: `externalCustomerId` (our customer key - it
/// tells the user nothing and widens the PII surface of a screenshot),
/// `paymentMethodId` (the machine key for a name already shown), `externalId`
/// (our app-side reference; `id` is the one Banxa support quotes),
/// `orderStatusUrl` (a URL is not a value - it is what Complete Payment
/// opens), `orderType` (constant `CRYPTO-BUY` for every order this screen can
/// produce), `country` (Banxa's KYC jurisdiction for the account, not a fact
/// about this purchase) and `metadata` (an untyped, attacker-influenced map
/// from an external API reaching text layout - the 37639d5 freeze class).
List<TxDetailRow> orderTransactionRows(Order order) => [
  // The destination. The base counterparty row is empty for an order, and this
  // is the one address a person eyeball-verifies.
  TxDetailRow('To', order.walletAddress, copy: true),
  // A wrong memo/destination tag loses funds on the chains that use one. Null
  // on most, and then blank-skipped.
  TxDetailRow('Address tag', order.walletAddressTag ?? '', copy: true),
  // The figure to compare against a bank statement, and the thing the two fee
  // rows are fees ON. Labelled "Order amount", NOT "Amount paid": for a
  // declined order the hero already reads `Not charged`, and "paid" would
  // contradict it.
  TxDetailRow('Order amount', _fiatText(order.fiatAmount, order.fiat)),
  // Both fees stay in THIS group rather than one being exiled to NETWORK: they
  // are two components of one fiat charge, and splitting them across two
  // groups makes neither readable.
  TxDetailRow('Processing fee', _fiatText(order.processingFee, order.fiat)),
  TxDetailRow('Network fee', _fiatText(order.networkFee, order.fiat)),
  // How it was paid - the most-asked question about a purchase.
  TxDetailRow('Payment method', order.paymentMethodName),
  // What Banxa support asks for, and the reason this drawer gets opened.
  TxDetailRow('Order ID', order.id, copy: true),
  // For a pending order this is the only signal that anything moved. Equal to
  // Date on a fresh order, where a second date row would be noise.
  if (order.updatedAt != order.createdAt)
    TxDetailRow(
      'Last updated',
      _orderDateFormat.format(order.updatedAt.toLocal()),
    ),
];

/// The NETWORK-group extras. Blank in sandbox, so usually nothing renders;
/// when present the chain disambiguates the same symbol on two networks.
List<TxDetailRow> orderNetworkRows(Order order) =>
    order.crypto.network.trim().isEmpty
    ? const []
    : [TxDetailRow('Chain', order.crypto.network)];
