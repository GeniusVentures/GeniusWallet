import 'package:flutter/foundation.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:hive_ce/hive.dart';
import 'package:intl/intl.dart';

String getExplorerUrl(String coinSymbol, String txHash) {
  final lowercaseSymbol = coinSymbol.toLowerCase();

  final explorerMap = {
    'eth': 'https://etherscan.io/tx/',
    'polygon': 'https://polygonscan.com/tx/',
    'matic': 'https://polygonscan.com/tx/',
    'bnb': 'https://bscscan.com/tx/',
    'arb': 'https://arbiscan.io/tx/',
    'op': 'https://optimistic.etherscan.io/tx/',
    'avax': 'https://snowtrace.io/tx/',
    'ftm': 'https://ftmscan.com/tx/',
    'sol':
        'https://solscan.io/tx/', // Solana uses different semantics but many explorers accept just tx hash
    'dot': 'https://polkadot.subscan.io/extrinsic/',
    'pol':
        'https://polygonscan.com/tx/', // assuming 'pol' is a mislabeling of 'polygon'
    'base': 'https://basescan.org/tx/',
    'zec': 'https://zcha.in/transactions/',
  };

  final baseUrl = explorerMap[lowercaseSymbol];
  if (baseUrl == null || txHash.isEmpty) {
    return '';
  }

  return '$baseUrl$txHash';
}

String formatAmount(String amountStr) {
  final amount = double.tryParse(amountStr);
  if (amount == null) {
    return amountStr;
  }

  final fixed = amount.toStringAsFixed(8); // preserve small precision

  // Special case: show exact `.00` if the number ends in .00 (like 100.00)
  if (fixed.endsWith('.00')) {
    return fixed.substring(0, fixed.indexOf('.') + 3); // keep 2 decimal places
  }

  // Trim unnecessary trailing zeros but keep precision
  return fixed.replaceFirst(RegExp(r'([.]*[0]+)$'), '');
}

// ---------------------------------------------------------------------------
// Formatting
// ---------------------------------------------------------------------------

/// Exactly 2 decimals, grouped — for magnitudes >= 1000.
final NumberFormat _bigAmountFormat = NumberFormat('#,##0.00');

/// Minimum 2, maximum 6 decimals, grouped — for magnitudes below 1000, so
/// `0.75` stays `0.75`, `0.0042` stays `0.0042` and `3.5` reads `3.50`.
final NumberFormat _smallAmountFormat = NumberFormat('#,##0.00####');

/// Below this, six decimals render as all zeros and state nothing. The label is
/// a literal because `0.000001.toString()` is `1e-6`, which is not what a
/// wallet row should say.
const double _amountFloor = 0.000001;
const String _amountFloorLabel = '<0.000001';

/// The width clamp sketch 010 asked for: an unbounded amount string must never
/// be what decides the transactions panel's width.
///
/// Returns the MAGNITUDE only — no sign, no symbol. The caller composes those,
/// so there is exactly one place that can produce a doubled sign.
///
/// The unparseable / NaN / infinite early return is a layout guard, not just an
/// honesty guard: commit 37639d5 fixed an app freeze whose root cause was an
/// unbounded value reaching text layout in a height-starved panel. Do not
/// weaken it.
String formatTxAmount(String raw) {
  final trimmed = raw.trim();
  final value = double.tryParse(trimmed);
  if (value == null || value.isNaN || value.isInfinite) {
    return trimmed;
  }
  if (value == 0) {
    return '0.00';
  }

  final magnitude = value.abs();
  if (magnitude >= 1000) {
    return _bigAmountFormat.format(magnitude);
  }
  if (magnitude < _amountFloor) {
    return _amountFloorLabel;
  }
  return _smallAmountFormat.format(magnitude);
}

/// The raw value when [formatTxAmount] lost something, else null.
///
/// Null means "what is displayed is already exact — attach no tooltip".
/// Deliberately returns the RAW MODEL STRING rather than a re-rendered double:
/// round-tripping through `double` is exactly what would destroy the precision
/// this exists to preserve.
String? exactTxAmount(String raw) {
  final trimmed = raw.trim();
  return trimmed == formatTxAmount(raw) ? null : trimmed;
}

/// `coinSymbol` is attacker-chosen and gets interpolated into
/// `assets/images/crypto/<symbol>.png`. Restrict it to `a-z0-9`, cap the
/// length, and let an empty result mean "fall back to the neutral dot".
String sanitizeCoinAsset(String symbol) {
  final cleaned = symbol.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  return cleaned.length > 12 ? cleaned.substring(0, 12) : cleaned;
}

/// Pure price lookup. Null means "no price is known", which the row renders as
/// an ABSENT line — never as `$0.00`. Inventing a zero is the same defect
/// sketch 010 flagged on the failed row.
double? fiatValue({
  required String symbol,
  required double amount,
  required Map<String, double> pricesBySymbol,
}) {
  final price = pricesBySymbol[symbol.toLowerCase()];
  return price == null ? null : price * amount;
}

/// The only impure function in this file.
///
/// ponytail: this reads the market cache the Assets panel already fills and
/// adds NO network call of its own, so a transaction in a coin the wallet does
/// not hold simply has no fiat line. Ceiling: coverage is whatever the Assets
/// fetch happened to load. Upgrade path is a shared price provider, if the
/// missing-fiat case ever turns out to be a real gap rather than a rare one.
///
/// The `isBoxOpen` guard earns its place twice: it keeps unit tests from
/// needing a Hive binding, and it keeps a pre-init frame from throwing.
Map<String, double> livePricesBySymbol() {
  if (kDebugMode) {
    final mock = DevMockHoldings.instance.marketData;
    if (mock.isNotEmpty) {
      return {
        for (final data in mock.values)
          data.symbol.toLowerCase(): data.currentPrice,
      };
    }
  }

  if (Hive.isBoxOpen(marketDataBox)) {
    final box = Hive.box<CoinGeckoMarketData>(marketDataBox);
    return {
      for (final data in box.values)
        data.symbol.toLowerCase(): data.currentPrice,
    };
  }

  return const {};
}

/// The one fiat formatter for the transactions surface.
/// `transaction_displays.dart` and `transactions_slim_view.dart` each declare a
/// private duplicate of this shape today; they can drop them for this.
final NumberFormat _fiatFormat = NumberFormat.currency(
  symbol: '\$',
  decimalDigits: 2,
);

String formatFiat(double value) => _fiatFormat.format(value);

// ---------------------------------------------------------------------------
// Row content
// ---------------------------------------------------------------------------

/// Which way the amount points — the row colours from this, never from a
/// re-inspection of `tx.type`.
enum TxAmountTone { incoming, outgoing, none }

// 15-01 removed the last `_emDash` assignment (TT-06: no row prints a dash
// where the number belongs), so the constant went with it. The em dash the
// test loop asserts against lives in the test file.

/// U+2212 REAL MINUS, not a hyphen: it is the same advance width as `+` under
/// tabular figures, so the amount column stays aligned.
const String _minus = '−';
const String _arrow = '→';
const String _middot = '·';

/// Everything 12-03's row widget needs to paint, already decided.
///
/// The row that renders this must contain no `switch (tx.type)` of its own —
/// that single rule is what makes "one anatomy for all seven types" true rather
/// than aspirational, and it is why all of this is testable without a pump.
///
/// Notably ABSENT: the fee. `Fee:` repeated on all eight rows and was never the
/// reason the panel is opened; it moves to the detail drawer in 12-03. The one
/// survivor is `process`, where the fee IS the economic content — 15-01 moved
/// it from that row's value line into its amount column.
@immutable
class TxRowContent {
  const TxRowContent({
    required this.badge,
    required this.title,
    required this.action,
    required this.subtitle,
    required this.subtitleBase,
    required this.status,
    required this.amount,
    required this.tone,
    required this.exactAmount,
    required this.valueLine,
    required this.iconSymbols,
    required this.time,
  });

  final TransactionBadgeKind badge;

  /// The raw status, exposed so the WIDE transactions page can render it as a
  /// pill column. On the narrow panel the status stays folded into [subtitle];
  /// the pill is a wide-only affordance (sketch 030-A2), so both presentations
  /// draw from the same source and neither can drift.
  final TransactionStatus status;

  /// The headline. 010-A is token-first: the asset leads, the action follows.
  final String title;

  /// The quiet chip beside the headline — `Sent`, `Minted`, `Escrow locked`…
  final String action;

  /// One line of real context. Carries the status token if, and only if, the
  /// status is not the happy path.
  final String subtitle;

  /// [subtitle] WITHOUT the ` · Status` suffix — the context alone. The WIDE
  /// page uses this and shows [status] as its own pill instead, so the status
  /// is stated exactly once (pill), not twice (pill + subtitle suffix). For a
  /// completed row this equals [subtitle] (there is no suffix to strip).
  final String subtitleBase;

  /// Already signed and clamped, and never empty — every type produces a real
  /// number, including a job (its fee) and a failed row (the amount it
  /// attempted). `valueLine` is what says whether it moved.
  final String amount;
  final TxAmountTone tone;

  /// The unclamped value for a tooltip, or null when nothing was lost.
  final String? exactAmount;

  /// Fiat, or `Not charged`, or NULL — null means print no line at all. An
  /// unpriced coin drops the line rather than fabricating `$0.00`.
  final String? valueLine;

  /// Sanitised asset symbols; two of them for a swap so both tokens can show.
  final List<String> iconSymbols;
  final String time;
}

TransactionBadgeKind _badgeForType(TransactionType? type, bool isSent) {
  switch (type) {
    case TransactionType.mint:
      return TransactionBadgeKind.mint;
    case TransactionType.process:
      return TransactionBadgeKind.job;
    case TransactionType.escrow:
    case TransactionType.escrowRelease:
      return TransactionBadgeKind.escrow;
    case TransactionType.purchase:
      return TransactionBadgeKind.purchase;
    case TransactionType.swap:
      return TransactionBadgeKind.swap;
    case TransactionType.transfer:
    case null:
      return isSent ? TransactionBadgeKind.sent : TransactionBadgeKind.received;
  }
}

String _actionFor(TransactionType? type, bool isSent) {
  switch (type) {
    case TransactionType.mint:
      return 'Minted';
    case TransactionType.escrow:
      return 'Escrow locked';
    case TransactionType.escrowRelease:
      return 'Escrow released';
    case TransactionType.process:
      return 'Processing job';
    case TransactionType.purchase:
      return 'Purchased';
    case TransactionType.swap:
      return 'Swapped';
    case TransactionType.transfer:
    case null:
      return isSent ? 'Sent' : 'Received';
  }
}

String _statusLabel(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

/// Never returns an empty string — an address can be blank on a malformed
/// record and a blank subtitle would collapse the row's second line.
String _addressLine(String address) {
  final display = WalletUtils.getAddressForDisplay(address.trim());
  return display.isEmpty ? 'Unknown address' : display;
}

/// The single derivation 12-03 renders.
TxRowContent txRowContent(
  Transaction tx, {
  required Map<String, double> prices,
}) {
  final type = tx.type;
  final status = tx.transactionStatus;
  final isSent = tx.transactionDirection == TransactionDirection.sent;
  final isDead =
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;

  // BADGE — status wins over type, because a pending or failed transaction is
  // first of all pending or failed.
  final TransactionBadgeKind badge;
  if (status == TransactionStatus.pending) {
    badge = TransactionBadgeKind.pending;
  } else if (isDead) {
    badge = TransactionBadgeKind.failed;
  } else {
    badge = _badgeForType(type, isSent);
  }

  // TITLE — the asset is the headline; a swap has two.
  final String title;
  if (type == TransactionType.swap &&
      tx.fromSymbol != null &&
      tx.toSymbol != null) {
    title = '${tx.fromSymbol} $_arrow ${tx.toSymbol}';
  } else {
    title = tx.coinSymbol;
  }

  // SUBTITLE — one line of real context, never a repeated relative time.
  // `recipients` comes from an untrusted source and `.first` throws on empty,
  // which today's code does unguarded.
  String subtitle;
  switch (type) {
    case TransactionType.mint:
      subtitle = 'Minted to wallet';
    case TransactionType.escrow:
      subtitle = 'Locked in escrow';
    case TransactionType.escrowRelease:
      subtitle = 'Released from escrow';
    case TransactionType.process:
      subtitle = 'Job ${_addressLine(tx.hash)}';
    case TransactionType.purchase:
      subtitle = 'Card purchase';
    case TransactionType.swap:
      final fromAmount = formatTxAmount(tx.fromAmount ?? '0');
      subtitle = '$fromAmount ${tx.fromSymbol ?? tx.coinSymbol}';
    case TransactionType.transfer:
    case null:
      if (isSent) {
        subtitle = tx.recipients.isEmpty
            ? 'Unknown recipient'
            : _addressLine(tx.recipients.first.toAddr);
      } else {
        subtitle = _addressLine(tx.fromAddress);
      }
  }
  // The whole of "status is rendered only when it is not the happy path".
  // Captured BEFORE the append so the wide page can show the context alone and
  // carry the status in its own pill.
  final subtitleBase = subtitle;
  if (status != TransactionStatus.completed) {
    subtitle = '$subtitle $_middot ${_statusLabel(status)}';
  }

  // AMOUNT + TONE + VALUE LINE.
  //
  // The TYPE decides all four values first; the dead status is applied as an
  // OVERRIDE afterwards. It is deliberately not a leading `if (isDead)` gate:
  // a failed `process` has no transfer amount at all, so a dedicated dead
  // branch would have to re-derive the fee, and the two copies would drift.
  // Running the type first means a failed job automatically prints the same
  // `− 0.002 ETH` its completed twin does. One rule, no duplication — do not
  // "simplify" this back into a leading gate.
  //
  // `amount` stays `final`: every arm of the chain assigns it exactly once and
  // the override does not touch it, so the compiler keeps guarding against a
  // future arm that forgets. Only `tone` is written twice.
  final String amount;
  TxAmountTone tone;
  String? exactAmount;
  String? valueLine;

  if (type == TransactionType.process) {
    // A job has no transfer amount, but it is not amountless: it spends
    // `tx.fees`, and that leaves the wallet. So the fee IS the amount, with a
    // real minus — 12-02's dash was caution standing in for a known fact.
    //
    // `tx.fees` is untrusted (RPC-supplied) and reaches text layout in a
    // height-starved panel for the first time here, so it goes through
    // `formatTxAmount` like every other raw amount — that early return is the
    // 37639d5 freeze guard, not merely a formatting nicety.
    //
    // TONE is `outgoing` -> `gw.textPrimary`, deliberately the same full weight
    // a successful send gets: a completed job genuinely spent that money, so it
    // must not read quieter than any other spend. The old `none` ->
    // `textSecondary` is the treatment for "this is not really a number", which
    // is exactly the claim being removed.
    amount = '$_minus ${formatTxAmount(tx.fees)} ${tx.coinSymbol}';
    tone = TxAmountTone.outgoing;
    exactAmount = exactTxAmount(tx.fees);
    // The old `'<fee> <symbol> spent'` string is gone — the amount column now
    // carries that, and repeating it would crowd out the fiat the value line
    // exists for. Null stays null: an unpriced coin drops the line rather than
    // printing a zero, the same rule every other branch obeys.
    final fiat = _fiatLine(tx.fees, tx.coinSymbol, prices);
    valueLine = fiat == null ? null : '$fiat fee';
  } else if (type == TransactionType.swap) {
    final rawAmount = tx.toAmount ?? '0';
    final symbol = tx.toSymbol ?? tx.coinSymbol;
    amount = '+ ${formatTxAmount(rawAmount)} $symbol';
    tone = TxAmountTone.incoming;
    exactAmount = exactTxAmount(rawAmount);
    valueLine = _fiatLine(rawAmount, symbol, prices);
  } else {
    final outgoing =
        type == TransactionType.escrow ||
        ((type == null || type == TransactionType.transfer) && isSent);
    final rawAmount = tx.recipients.isEmpty ? '0' : tx.recipients.first.amount;
    amount =
        '${outgoing ? _minus : '+'} '
        '${formatTxAmount(rawAmount)} ${tx.coinSymbol}';
    tone = outgoing ? TxAmountTone.outgoing : TxAmountTone.incoming;
    exactAmount = exactTxAmount(rawAmount);
    valueLine = _fiatLine(rawAmount, tx.coinSymbol, prices);
  }

  // DEAD-STATUS OVERRIDE — failed or cancelled. The amount the type computed
  // stands (sketch 022: Jakub overruled 021's unsigned amount — print the real
  // number, let the status carry the truth), and `Not charged` is the price of
  // that override. It is load-bearing, not decoration: `− 0.75 ETH` with no
  // value line reads as a wallet that lost 0.75 ETH. Never drop it.
  //
  // TONE stays `none` -> gw.textSecondary, and that is a call worth arguing:
  //   - `outgoing` -> textPrimary is the exact ink a successful spend uses, so
  //     a failed row at that weight is indistinguishable from a completed one
  //     when scanning the column — the double-counting sketch 021 §2 objected
  //     to.
  //   - `incoming` -> statusSuccess GREEN on a failed receive would be actively
  //     false; green is this app's success colour.
  //   - `none` measures 6.0:1 dark (#8A8F9D on #0C0E14) and 6.3:1 light
  //     (#5A606E on white) — AA text in both appearances, so quiet is not weak.
  // No fourth tone: `none` + `Not charged` + the badge + the `· Failed`
  // subtitle already state it three times over.
  //
  // ponytail: a dead row re-uses the completed row's amount derivation
  // wholesale. Ceiling: no hook exists if some future type ever needs a
  // genuinely different "attempted" amount. Upgrade path is a per-type
  // attempted-amount field on `TxRowContent` — not another leading branch.
  if (isDead) {
    tone = TxAmountTone.none;
    valueLine = 'Not charged';
  }

  // Sanitised HERE so the widget never touches a raw, attacker-chosen symbol.
  final iconSymbols = type == TransactionType.swap
      ? [
          sanitizeCoinAsset(tx.fromSymbol ?? tx.coinSymbol),
          sanitizeCoinAsset(tx.toSymbol ?? tx.coinSymbol),
        ]
      : [sanitizeCoinAsset(tx.coinSymbol)];

  return TxRowContent(
    badge: badge,
    title: title,
    action: _actionFor(type, isSent),
    subtitle: subtitle,
    subtitleBase: subtitleBase,
    status: status,
    amount: amount,
    tone: tone,
    exactAmount: exactAmount,
    valueLine: valueLine,
    iconSymbols: iconSymbols,
    time: txTimeLabel(tx.timeStamp),
  );
}

/// Null when the amount will not parse or the symbol has no known price — the
/// row then prints NO value line, which is the honest outcome. Never `$0.00`.
String? _fiatLine(String rawAmount, String symbol, Map<String, double> prices) {
  final parsed = double.tryParse(rawAmount.trim());
  if (parsed == null || parsed.isNaN || parsed.isInfinite) {
    return null;
  }
  final value = fiatValue(
    symbol: symbol,
    amount: parsed,
    pricesBySymbol: prices,
  );
  return value == null ? null : formatFiat(value);
}

// ---------------------------------------------------------------------------
// Time and day grouping
// ---------------------------------------------------------------------------

/// Per-row clock time, e.g. `18:42`.
///
/// 24-hour is deliberate and must not be "localised" into a regression later: a
/// `h:mm a` string varies in width, and under tabular figures the amount/time
/// columns are the tightest part of the narrow panel. Fixed width here is what
/// keeps that column from moving row to row.
String txTimeLabel(DateTime ts) => DateFormat.Hm().format(ts.toLocal());

final DateFormat _dayFormat = DateFormat('d MMM');
final DateFormat _dayWithYearFormat = DateFormat('d MMM y');

bool _sameCalendarDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// `Today` / `Yesterday` / `18 Jul` / `18 Jul 2025`.
///
/// Compares CALENDAR DAYS, never a `Duration` delta — a 23-hour gap can
/// straddle midnight and a 25-hour one can fail to. `DateTime(y, m, d - 1)`
/// normalises the month/year rollover itself and, being wall-clock, is also
/// immune to the DST day that is 23 or 25 hours long.
String txDayLabel(DateTime day, DateTime now) {
  final local = day.toLocal();
  final today = now.toLocal();
  if (_sameCalendarDay(local, today)) {
    return 'Today';
  }

  final yesterday = DateTime(today.year, today.month, today.day - 1);
  if (_sameCalendarDay(local, yesterday)) {
    return 'Yesterday';
  }

  return local.year == today.year
      ? _dayFormat.format(local)
      : _dayWithYearFormat.format(local);
}

/// One calendar day's worth of transactions, newest first.
@immutable
class TxDay {
  const TxDay({required this.day, required this.label, required this.items});

  final DateTime day;
  final String label;
  final List<Transaction> items;
}

/// Buckets [txs] into local calendar days, newest day first and newest item
/// first inside each day. This is what replaces the eight identical `a day ago`
/// strings sketch 010 measured: the date is stated once, per group.
///
/// Sorts a COPY — the caller's list is bloc/stream-owned and must not be
/// reordered under it. [now] is injectable so tests are not time-of-day
/// dependent.
List<TxDay> groupTransactionsByDay(List<Transaction> txs, {DateTime? now}) {
  if (txs.isEmpty) {
    return const [];
  }

  final reference = now ?? DateTime.now();
  final sorted = List<Transaction>.of(txs)
    ..sort((a, b) => b.timeStamp.compareTo(a.timeStamp));

  // Insertion-ordered, so iterating the buckets gives newest-day-first for free.
  final buckets = <DateTime, List<Transaction>>{};
  for (final tx in sorted) {
    final local = tx.timeStamp.toLocal();
    final key = DateTime(local.year, local.month, local.day);
    buckets.putIfAbsent(key, () => <Transaction>[]).add(tx);
  }

  return [
    for (final entry in buckets.entries)
      TxDay(
        day: entry.key,
        label: txDayLabel(entry.key, reference),
        items: entry.value,
      ),
  ];
}
