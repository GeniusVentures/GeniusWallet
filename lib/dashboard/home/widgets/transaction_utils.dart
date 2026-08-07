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
    this.subtitleLead,
    required this.amount,
    required this.tone,
    required this.exactAmount,
    required this.valueLine,
    required this.iconSymbols,
    required this.time,
    this.statusLabel,
  });

  final TransactionBadgeKind badge;

  /// The raw status, exposed so the WIDE transactions page can render it as a
  /// pill column. On the narrow panel the status stays folded into [subtitle];
  /// the pill is a wide-only affordance (sketch 030-A2), so both presentations
  /// draw from the same source and neither can drift.
  final TransactionStatus status;

  /// The headline. 010-A is token-first: the asset leads, the action follows.
  final String title;

  /// The DRAWER's title - `Sent`, `Minted`, `Escrow locked`, `Processing job`.
  ///
  /// It used to be the chip beside the headline too; sketch 179-C deleted that
  /// chip, so the row no longer reads this at all. It stays because
  /// `showTransactionDetails` passes it to `ResponsiveDrawer.show`, and because
  /// four of the eight leads below deliberately differ from it: the drawer has a
  /// whole header to spend, the subtitle has 113px.
  final String action;

  /// One line of real context. Carries the status token if, and only if, the
  /// status is not the happy path.
  ///
  /// The row no longer renders this field directly - it lays out
  /// [subtitleLead], [subtitleBase] and [statusTail] as separate elements. This
  /// is the COMPOSED whole line, it is the field a caller-built record supplies
  /// (the Buy GNUS orders rail), and `transaction_utils_test.dart`'s invariant
  /// test binds the three pieces back to it so they can never drift. Do not
  /// "simplify" it away.
  final String subtitle;

  /// The part of the context line that MAY SHRINK - the qualifier.
  ///
  /// [subtitleLead] + [subtitleBase] is what the row lays out, in that order and
  /// inside ONE paragraph, so an end ellipsis eats this piece first and only
  /// reaches the lead once this is gone (sketch 179-C: the verb survives, the
  /// qualifier gives way). Both branches render both pieces; only [statusTail]
  /// is wide-suppressed.
  ///
  /// Carries no ` · Status` suffix, which is what keeps the status stated
  /// exactly once per presentation: the pill on the wide page, [statusTail] on
  /// the narrow one. For a completed row this equals [subtitle] minus the lead.
  ///
  /// MAY BE EMPTY - `purchase` has a lead and no qualifier. That is safe now
  /// because the lead is what keeps the second line from collapsing; the old
  /// contract that this was never empty no longer holds.
  final String subtitleBase;

  /// The part of the context line that does NOT give way - the verb.
  ///
  /// Null means "no lead", which is what keeps the Buy GNUS orders rail
  /// (`lib/banxa/`) rendering its single-piece line with no edit at all.
  final String? subtitleLead;

  /// The status as the NARROW row's pinned tail, or null on the happy path.
  ///
  /// Deliberately a COMPUTED GETTER and not a constructor field: a caller that
  /// builds its own record keeps the narrow row's status without opting in, and
  /// the tail and the wide page's pill read the same two fields, so they cannot
  /// disagree about what a row's status is.
  ///
  /// The value carries NO LEADING MIDDLE DOT, which is a deviation from sketch
  /// 179 and is forced by measurement. The row pins this to the right edge as a
  /// separate element with its own `space2` gutter, so a separator between two
  /// already-separated elements does nothing - and the 8px the dot costs is
  /// exactly what makes a pending mint render `Minte…` instead of `Minted` on a
  /// 113px line, which is the defect 179-C exists to remove.
  String? get statusTail => status == TransactionStatus.completed
      ? null
      : (statusLabel ?? _statusLabel(status));

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

  /// The display label for [status] when the enum's own name is not the
  /// truthful one. NULL means "use the enum name", which is what
  /// [txRowContent] always produces - this exists for a caller that builds
  /// the record itself.
  ///
  /// The case it was added for: a Banxa order's `Expired` folds onto
  /// [TransactionStatus.failed] (it is red today and must stay red), but the
  /// row would then read "Failed" for an order that merely ran out of time.
  /// The label rides here rather than as a parameter on the row/drawer so
  /// both presentations - the wide row's pill and the drawer's Status row -
  /// read one source and cannot drift.
  final String? statusLabel;
}

/// One drawer detail row as DATA, not as a widget.
///
/// `showTransactionDetails` renders these through its own `add()`/`addCopy()`
/// helpers, and that is the point: those helpers already return early on a
/// blank value, so a field an external API did not provide becomes NO ROW -
/// not a dash, not `Unknown`, not an empty row. A caller supplying extras
/// therefore writes no null-guards of its own, and cannot build the wrong
/// widget either (`_buildRow` and `_CopyRow` are private to the drawer's own
/// file).
@immutable
class TxDetailRow {
  const TxDetailRow(this.label, this.value, {this.copy = false});

  final String label;

  /// The FULL value. A copy row prints a shortened form and copies this.
  final String value;

  /// Whether the value belongs in the clipboard rather than only on screen -
  /// an address, an order id, a hash.
  final bool copy;
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

  // SUBTITLE - one line of real context, never a repeated relative time, and
  // since 179-C split in two at a point the phrase already had: a LEAD that
  // does not give way and a QUALIFIER that does.
  //
  // `recipients` comes from an untrusted source and `.first` throws on empty,
  // which today's code does unguarded.
  //
  // Five of these arms already carried their verb, so splitting at the space
  // they already contain recomposes to a byte-identical line; only `transfer`
  // and `swap` gain a word, because those two never stated their verb here.
  //
  // NO ROW PRINTS THE TRANSACTION'S OWN HASH (Jakub on device, 2026-08-07:
  // "usun ten 'transaction ID' czy cokolwiek jest po prawej stronie, bo to nie
  // ma nawet sensu"). `process` was the only arm that did - its base was
  // `_addressLine(tx.hash)`, drawn as `0xabcd...7890` - and a hash identifies
  // the row you have already tapped, which is the one question a person
  // scanning a list is not asking. It stays reachable and copyable IN FULL from
  // the detail drawer, as a row labelled `Job`;
  // `transaction_receipt_copy_test.dart` asserts that, and it was written
  // BEFORE the row lost the string so the removal could be shown to be
  // decluttering rather than data loss.
  //
  // WHAT SURVIVES, and why it is not the same thing. `to wallet`, `in escrow`
  // and `from escrow` are QUALIFIERS - places, not values. `· 1.50 ETH` is a
  // QUANTITY. Both `transfer` directions carry a COUNTERPARTY, which is the
  // row's only WHO: delete it and a send to one person and a send to another
  // become the same row - same token, same amount, same word `Sent`. All of
  // them render as `0x` + 4 + `...` + 4 exactly like the hash did, so they LOOK
  // identical; they are not. Do not "finish the job" by deleting them.
  final String subtitleLead;
  final String subtitleBase;
  switch (type) {
    case TransactionType.mint:
      subtitleLead = 'Minted';
      subtitleBase = 'to wallet';
    case TransactionType.escrow:
      subtitleLead = 'Locked';
      subtitleBase = 'in escrow';
    case TransactionType.escrowRelease:
      subtitleLead = 'Released';
      subtitleBase = 'from escrow';
    case TransactionType.process:
      // THE ONE ARM WHOSE WORDING VARIES WITH STATUS, and the one place in this
      // file where that is deliberate. Jakub ruled it on 2026-08-07, choosing a
      // hybrid over both alternatives he was shown (the full wording everywhere
      // and clipping, or `Job` everywhere and never clipping).
      //
      // The rule: the full wording where it FITS, the short word where it does
      // not. What decides the fit is the STATUS TAIL, because the tail is what
      // sets the paragraph's box. The row's middle column is 113.0px at a 390pt
      // phone; the paragraph gets that less `space2` (4) less the tail, and the
      // tail is drawn if and only if the status is not completed:
      //
      //     completed  113.0px   `Processing job` is 103.6px      -> WHOLE
      //     failed      68.2px   103.6 + 12.3 of ellipsis = 115.9 -> cut
      //     pending     53.1px   same                             -> cut
      //     cancelled   40.7px   same                             -> cut
      //
      // `Job` is 26.1px, so `Job` + ellipsis is 38.4px and clears even the
      // 40.7px a cancelled row leaves. That is why the short word survives on
      // all four statuses and the long one survives on exactly one.
      //
      // Why status and not a real width test: this is a PURE derivation with no
      // `BuildContext`, no resolved `TextStyle` and no access to the engine, and
      // it runs per row per frame in a scrolling list. A `TextPainter` here
      // would need a style it cannot see and would break every unit test that
      // calls it without a binding. So the predicate is the STRUCTURAL fact that
      // produces the fit - `status == completed` is exactly "no status tail is
      // pinned to this line, so the paragraph has the whole 113.0px" - and the
      // measured arithmetic is written above so the mapping is checkable rather
      // than magic. `transaction_row_subtitle_test.dart` measures all four
      // boxes and both words and reddens if any of these numbers moves.
      //
      // THE ACCEPTED COST, stated because it is unusual: the label's length now
      // varies with status. Jakub took that knowingly. His reasoning: on a
      // failed, pending or cancelled row the status word sits right beside the
      // lead, so `Job` next to `Pending` reads completely while `Proces…` next
      // to `Pending` reads as nothing. Clipping was his original complaint about
      // this row and it outweighs the wording.
      //
      // Four alternatives were measured and all four are closed. A shorter word:
      // `Processing` alone is still about 76px and misses 68.2, 53.1 and 40.7.
      // Moving the tail to the title line: at bodySm the pending tail would
      // leave the title 53.1px, and `WSTETH` is about 60px while a swap's
      // `ETH -> GNUS` is about 95px, so it trades a cut verb for a cut TOKEN,
      // and the token is the headline the row is organised around (010-A).
      // Wrapping to two lines: per-row height changes make a ragged list. Taking
      // width from the amount column: that column already clips ordinary amounts
      // (86.5 to 136.0px against the 113 it gets), so it is strictly worse.
      subtitleLead = status == TransactionStatus.completed
          ? 'Processing job'
          : 'Job';
      subtitleBase = '';
    case TransactionType.purchase:
      // An empty base is legal: the lead is what keeps the second line from
      // collapsing. `process` is the other arm with no qualifier, since
      // 2026-08-07.
      subtitleLead = 'Card purchase';
      subtitleBase = '';
    case TransactionType.swap:
      final fromAmount = formatTxAmount(tx.fromAmount ?? '0');
      subtitleLead = 'Swapped';
      subtitleBase = '$_middot $fromAmount ${tx.fromSymbol ?? tx.coinSymbol}';
    case TransactionType.transfer:
    case null:
      subtitleLead = isSent ? 'Sent' : 'Received';
      if (isSent) {
        subtitleBase = tx.recipients.isEmpty
            ? '$_middot Unknown recipient'
            : '$_middot ${_addressLine(tx.recipients.first.toAddr)}';
      } else {
        subtitleBase = '$_middot ${_addressLine(tx.fromAddress)}';
      }
  }
  // The composed whole line. Built FROM the pieces rather than beside them, so
  // the three can never state different things about one row.
  //
  // The middle dot survives INSIDE the qualifier, where it still separates two
  // runs of one flow (`Sent · 0x7a3f…9c21`). It does not survive on the status
  // tail, which the row draws as its own right-pinned element - see
  // [TxRowContent.statusTail].
  String subtitle = subtitleBase.isEmpty
      ? subtitleLead
      : '$subtitleLead $subtitleBase';
  // The whole of "status is rendered only when it is not the happy path".
  // Appended LAST so the wide page can show the context alone and carry the
  // status in its own pill.
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
    subtitleLead: subtitleLead,
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
///
/// [limit] caps the result at the [limit] MOST RECENT transactions - the
/// dashboard panel's "last 5" (phase 25). It is applied AFTER the newest-first
/// sort below and BEFORE bucketing, which is what makes it mean "the most
/// recent N" rather than "the first N the caller happened to hand us". A day
/// whose every item fell outside the limit therefore never appears as an empty
/// group.
///
/// Null - the default - keeps every existing caller byte-identical, which is
/// what stops the dashboard cap from reaching the full `/transactions` page.
List<TxDay> groupTransactionsByDay(
  List<Transaction> txs, {
  DateTime? now,
  int? limit,
}) {
  if (txs.isEmpty) {
    return const [];
  }

  final reference = now ?? DateTime.now();
  final sorted = List<Transaction>.of(txs)
    ..sort((a, b) => b.timeStamp.compareTo(a.timeStamp));
  final visible = limit == null ? sorted : sorted.take(limit);

  // Insertion-ordered, so iterating the buckets gives newest-day-first for free.
  final buckets = <DateTime, List<Transaction>>{};
  for (final tx in visible) {
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
