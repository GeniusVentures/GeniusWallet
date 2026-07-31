import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_helpers/banxa_helpers.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
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

/// The Banxa status string as a [TransactionStatus], routed THROUGH
/// [orderStatusTone] rather than around it.
///
/// The two colour ladders are already the same four paints - `orderStatusPaint`
/// is a verbatim copy of `txStatusColors` and says so in its own doc - so the
/// tone buckets and the transaction statuses are in exact bijection. Going
/// through the tone function makes two things structural instead of a promise:
/// not one order changes colour, and there stays exactly ONE census of Banxa
/// status strings in the repo.
///
/// The switch is exhaustive over [OrderStatusTone] with no `default` arm, so a
/// future tone is a compile error rather than a silent fallback.
///
/// Two results look odd in isolation and are correct for that reason:
/// `cancelled` and `expired` map to `failed` because they are RED today (and
/// the rail's Issues chip counts them). [TransactionStatus.cancelled] is
/// reached ONLY by the unrecognised-status fallback, which is slate today.
///
/// Nothing is lost by the 8-into-4 fold: the LABEL never comes from the enum
/// (see [orderRowContent]'s `statusLabel`), so an expired order still reads
/// "Expired" in the error paint.
TransactionStatus orderTransactionStatus(String status) {
  switch (orderStatusTone(status)) {
    case OrderStatusTone.success:
      return TransactionStatus.completed;
    case OrderStatusTone.warning:
      return TransactionStatus.pending;
    case OrderStatusTone.error:
      return TransactionStatus.failed;
    case OrderStatusTone.neutral:
      return TransactionStatus.cancelled;
  }
}

/// The display label for a Banxa status, or NULL when the status is blank.
///
/// `BanxaHelpers.getOrderStatusLabel` already renders `pendingPayment` as
/// "Pending Payment" and `inProgress` as "In Progress"; when it passes a string
/// through unchanged (an unrecognised future status) the raw value takes a
/// capital letter so it reads as a word rather than as a wire value.
String? _orderStatusLabel(String status) {
  final raw = status.trim();
  if (raw.isEmpty) {
    return null;
  }
  final mapped = BanxaHelpers.getOrderStatusLabel(raw);
  if (mapped != raw) {
    return mapped;
  }
  return raw[0].toUpperCase() + raw.substring(1);
}

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
/// `txRowContent` (D-03).
///
/// The value line is the fiat actually PAID, which is a different FACT from
/// the price map's estimate rather than an override of it - for a card purchase
/// the fiat IS the value.
///
/// Tone and value line follow the TONE, not the mapped enum, and this is the
/// one place the mapping deliberately diverges from `txRowContent`'s `isDead`
/// rule. `txRowContent` treats failed and cancelled alike as dead; here `error`
/// is exactly the set of statuses where we KNOW no money moved, so it takes the
/// tab's own `Not charged` treatment verbatim, while `neutral` is the
/// UNRECOGNISED bucket, where printing `Not charged` would be a fabricated
/// claim - it keeps the order's own fiat and drops only the green.
///
/// [now] is injectable so the day label is testable without wall-clock
/// dependence.
TxRowContent orderRowContent(Order order, {DateTime? now}) {
  final tone = orderStatusTone(order.status);
  final statusLabel = _orderStatusLabel(order.status);
  final status = orderTransactionStatus(order.status);

  // Badge mirrors `txRowContent`'s "status wins over type" rule.
  final TransactionBadgeKind badge;
  switch (tone) {
    case OrderStatusTone.warning:
      badge = TransactionBadgeKind.pending;
    case OrderStatusTone.error:
      badge = TransactionBadgeKind.failed;
    case OrderStatusTone.success:
    case OrderStatusTone.neutral:
      badge = TransactionBadgeKind.purchase;
  }

  final TxAmountTone amountTone = switch (tone) {
    OrderStatusTone.success || OrderStatusTone.warning => TxAmountTone.incoming,
    OrderStatusTone.error || OrderStatusTone.neutral => TxAmountTone.none,
  };

  final valueLine = tone == OrderStatusTone.error
      ? 'Not charged'
      : _fiatText(order.fiatAmount, order.fiat);

  // The rail renders at most four rows and orders arrive one at a time on
  // different days, so it does NOT group by day the way the tab does - eight
  // elements for four facts in a bounded card. The day therefore rides in the
  // row's own context line, using the same `·` separator and the same
  // `txDayLabel` the tab's headers use, so nothing is lost to `time` being
  // `HH:mm` only.
  final dayLabel = txDayLabel(order.createdAt, now ?? DateTime.now());
  // The literal 'Card purchase' is `txRowContent`'s own purchase-arm string,
  // so the row is the tab's anatomy verbatim. The payment method is a detail
  // and gets its own drawer row.
  final subtitleBase = '$dayLabel · Card purchase';
  final subtitle =
      (status == TransactionStatus.completed || statusLabel == null)
      ? subtitleBase
      : '$subtitleBase · $statusLabel';

  return TxRowContent(
    badge: badge,
    title: order.crypto.id,
    action: 'Purchased',
    subtitle: subtitle,
    subtitleBase: subtitleBase,
    status: status,
    amount: '+ ${formatTxAmount(order.cryptoAmount)} ${order.crypto.id}',
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
