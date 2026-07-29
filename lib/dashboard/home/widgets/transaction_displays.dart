import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat("MMMM d, y 'at' h:mm a");

String _capitalizeStatus(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

/// Above this row width, the row is the WIDE transactions page: it gains the
/// Status pill + a fixed-width amount column (sketch 030-A2). Below it — the
/// dashboard panel — the row stays the compact two-part item and the status
/// remains folded into the subtitle. A row-local width is the right signal:
/// the page list card is ~760px+, the dashboard panel column stays well under
/// this, so the two presentations separate cleanly without threading a flag
/// through every call site.
const double _wideRowThreshold = 720;

/// The amount column's reserved width on the wide page. Fixed — NOT the widest
/// amount re-measured every frame (that scan is the class of thing that froze
/// the app, 37639d5) — so every amount's left edge, and therefore the Status
/// pill's right edge one `space6` to its left, lands on a single vertical line
/// (Jakub's "all statuses respect one place"). Sized for the largest realistic
/// amount; a rare bigger one ellipsizes and keeps its `exactAmount` tooltip.
const double _wideAmountWidth = 184;

/// THE colour of a status - foreground and its wash - for every consumer.
///
/// This used to be a `switch` inside `_statusPill` and, twenty lines away, a
/// `isDead ? gw.statusError : null` on the receipt's Status row. Two rules for
/// one fact, and they disagreed exactly as you would expect: the pill coloured
/// all four states while the row coloured only `failed` and `cancelled`, so a
/// Completed receipt showed a green pill above a plain white "Completed" and a
/// Pending one showed an amber pill above a white "Pending".
///
/// Jakub, 2026-07-28: *"status completed brakuje im kolorów - powinien być
/// przez komponent połączony"*. Connected here: one function, and neither
/// consumer can drift from the other again.
({Color fg, Color wash}) txStatusColors(
  TransactionStatus status,
  GWColors gw,
) => switch (status) {
  TransactionStatus.completed => (
    fg: gw.statusSuccess,
    wash: gw.statusSuccess.withValues(alpha: 0.14),
  ),
  // Foreground is statusWarningText, NOT statusWarning: the latter is
  // fill-tuned (~1.6:1 on a light canvas) and was invisible as pill text in
  // light mode -- the exact consumer gw_warning_note.dart's note said was
  // "waiting for" this token. The wash stays statusWarning: it IS a fill.
  TransactionStatus.pending => (
    fg: gw.statusWarningText,
    wash: gw.statusWarning.withValues(alpha: 0.16),
  ),
  TransactionStatus.failed => (
    fg: gw.statusError,
    wash: gw.statusError.withValues(alpha: 0.14),
  ),
  // Slate, not red: a cancelled transaction is not a failure, and
  // `surfaceMenu` is a real step up from the 156-A panel behind it.
  TransactionStatus.cancelled => (fg: gw.textSecondary, wash: gw.surfaceMenu),
};

/// The Status pill: label + dot in the status colour on a low-alpha wash of it,
/// reusing the badge palette so pill and badge never disagree on what "failed"
/// looks like. Used by the wide transactions row AND by the receipt hero.
///
/// completed/failed use the appearance-aware `gw.*` colours (AA in both
/// themes); cancelled uses `textSecondary` (also AA-tuned). pending uses the
/// mode-invariant `statusWarning` fill. All four come from [txStatusColors].
/// ponytail: `statusWarning` (#FFC42E) is AA as a label on the dark wash, but
/// as a label on the LIGHT wash it is too pale (~1.8:1). Deferred to the light
/// pass with the rest of the light-mode work; in dark mode — the current focus
/// — it clears AA. Upgrade path: a darker light-mode amber (≈#B26A00) behind a
/// `gw.statusWarning` getter, mirroring `gw.statusSuccess`/`gw.statusError`.
Widget _statusPill(TransactionStatus status, GWColors gw) {
  final (:fg, :wash) = txStatusColors(status, gw);
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: GeniusWalletConsts.space4,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: wash,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          _capitalizeStatus(status),
          maxLines: 1,
          softWrap: false,
          style: GeniusWalletTypography.labelMd.copyWith(
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ],
    ),
  );
}

/// The amount's colour, from 12-02's tone — never from a re-inspection of
/// `tx.type`. `none` (a dash: failed, cancelled, a processing job) takes
/// `textSecondary` and NOT the sketch's `--text-primary-38`, which measures
/// ~3.0:1 on the dark panel and fails AA for what is meaningful text.
Color _toneColor(TxAmountTone tone, GWColors gw) => switch (tone) {
  TxAmountTone.incoming => gw.statusSuccess,
  TxAmountTone.outgoing => gw.textPrimary,
  TxAmountTone.none => gw.textSecondary,
};

/// Copy of `_FallbackDot` in `gw_token_row.dart` (private there) so the Assets
/// panel and the Transactions panel degrade identically on a missing coin art.
Widget _fallbackDot(GWColors gw) => CircleAvatar(
  radius: 20,
  backgroundColor: gw.surfaceMenu,
  child: Icon(Icons.token, size: 18, color: gw.textSecondary),
);

Widget _coinImage(String symbol, GWColors gw, {BoxFit fit = BoxFit.contain}) {
  // `symbol` arrives ALREADY sanitised by 12-02's `sanitizeCoinAsset` (a-z0-9,
  // max 12). Never re-derive this path from `tx.coinSymbol` — that raw value is
  // attacker-influenced and this is a filesystem path (T-12-01).
  if (symbol.isEmpty) {
    return _fallbackDot(gw);
  }
  return Image.asset(
    'assets/images/crypto/$symbol.png',
    fit: fit,
    errorBuilder: (_, _, _) => _fallbackDot(gw),
  );
}

/// The identity slot: one coin, or two overlapped for a swap, with the badge
/// on top. [size] is always a literal (40 in the row, 60 in the drawer) — no
/// dimension here is derived from constraints, per the 37639d5 freeze rule.
Widget _identity(TxRowContent content, GWColors gw, {required double size}) {
  final isPair = content.iconSymbols.length > 1;
  // 0.6 of a literal size, so the whole set is {24, 36} — still a bounded set.
  final sub = size * 0.6;

  return SizedBox(
    width: size,
    height: size,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        if (!isPair)
          Positioned.fill(child: _coinImage(content.iconSymbols.first, gw))
        else ...[
          Positioned(
            left: 0,
            top: 0,
            child: SizedBox(
              width: sub,
              height: sub,
              child: _coinImage(content.iconSymbols.first, gw),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: sub,
              height: sub,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: gw.surfaceElevated, width: 2),
              ),
              // Asset art only. The old `_buildOverlappedIcons` used
              // NetworkImage(fromIconUrl), which fires one network fetch per
              // VISIBLE ROW inside a scrolling list (T-12-02).
              child: ClipOval(
                child: _coinImage(
                  content.iconSymbols[1],
                  gw,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
        // Last in the stack so it paints on top of the coin art.
        Positioned(
          right: -2,
          // Swap-only, deliberate: the bottom-right corner is occupied by the
          // to-token, so the badge moves to the top-right there. Flagged for
          // 12-06's walk.
          bottom: isPair ? null : -2,
          top: isPair ? -2 : null,
          child: TransactionBadge(kind: content.badge),
        ),
      ],
    ),
  );
}

/// ONE row for all seven `TransactionType` values.
///
/// Pure presentation: it renders [txRowContent]'s record and decides nothing.
/// There is deliberately no `switch (tx.type)` and no status branching in here
/// — a missing case belongs in 12-02's derivation, not in this widget. That
/// single rule is what makes "one anatomy" true rather than aspirational.
///
/// Geometry matches `GWTokenRow` (40px icon slot, space6/space4 padding,
/// radiusMd InkWell) so Assets and Transactions read as one system.
class TransactionRow extends StatelessWidget {
  const TransactionRow({super.key, required this.tx, this.onTap});

  final Transaction tx;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that re-skins
    // this row on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final content = txRowContent(tx, prices: livePricesBySymbol());

    final Widget amountText = Text(
      content.amount,
      maxLines: 1,
      softWrap: false,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.right,
      style: GeniusWalletTypography.numericBody.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: _toneColor(content.tone, gw),
      ),
    );

    // Shared by both presentations: right-aligned amount over its value line.
    // On the narrow panel it sits in an Expanded (shrinks/ellipsises); on the
    // wide page it sits in a fixed-width SizedBox so every amount aligns.
    final Widget amountColumn = Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Tooltip ONLY when the clamp actually lost something — wrapping
        // unconditionally attaches an empty tooltip to every row.
        if (content.exactAmount != null)
          Tooltip(message: content.exactAmount!, child: amountText)
        else
          amountText,
        if (content.valueLine != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          Text(
            content.valueLine!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ],
      ],
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        onTap: onTap,
        mouseCursor: SystemMouseCursors.click,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space6,
            vertical: GeniusWalletConsts.space4,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // BOOLEAN from constraints, never a per-frame dimension — the
              // freeze rule (37639d5) bans continuous sizes, not breakpoints.
              final bool wide = constraints.maxWidth >= _wideRowThreshold;
              return Row(
                children: [
                  // Time leads the row: it is fixed-width and tabular, so the
                  // token icons line up in a straight column behind it and the
                  // eye can scan either "when" or "what" down a single edge.
                  SizedBox(
                    width: 44,
                    child: Text(
                      content.time,
                      textAlign: TextAlign.left,
                      maxLines: 1,
                      style: GeniusWalletTypography.numericBody.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        // Not the sketch's --text-primary-38 (~3.0:1): the
                        // timestamp is meaningful text and must clear AA.
                        color: gw.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: GeniusWalletConsts.space6),
                  _identity(content, gw, size: 40),
                  const SizedBox(width: GeniusWalletConsts.space6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            // Token-first (010-A): the asset is the headline, the
                            // action a quiet chip beside it.
                            Flexible(
                              child: Text(
                                content.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GeniusWalletTypography.titleMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: gw.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: GeniusWalletConsts.space4),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: GeniusWalletConsts.space2,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: gw.surfaceMenu,
                                  borderRadius: BorderRadius.circular(
                                    GeniusWalletConsts.radiusXs,
                                  ),
                                ),
                                child: Text(
                                  content.action,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GeniusWalletTypography.labelMd
                                      .copyWith(color: gw.textSecondary),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: GeniusWalletConsts.space2),
                        Text(
                          // On the wide page the Status pill carries the status, so
                          // the subtitle drops the ` · Failed` suffix (no double
                          // statement). On the panel it keeps it — no pill there.
                          wide ? content.subtitleBase : content.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Right side.
                  //
                  // WIDE page (sketch 030-A2): a Status pill, then a fixed
                  // `space6` (12px, the same gap as time↔coin) gap, then a
                  // fixed-width amount column. Because the amount column is a fixed
                  // width sitting flush right and `Expanded` above absorbs all the
                  // slack, the pill's right edge lands on ONE vertical line a
                  // constant space6 off the amount — "every status respects one
                  // place", whatever the label's width.
                  //
                  // NARROW panel: the amount takes an `Expanded` (tight) so it
                  // right-aligns to the card edge and ellipsises when the row is
                  // genuinely narrow (the 320px case) instead of overflowing; no
                  // pill — the status stays folded into the subtitle there.
                  //
                  // Neither branch derives a dimension from constraints; the split
                  // is one boolean and the amount width is a constant (37639d5).
                  if (wide) ...[
                    const SizedBox(width: GeniusWalletConsts.space6),
                    _statusPill(content.status, gw),
                    const SizedBox(width: GeniusWalletConsts.space6),
                    SizedBox(width: _wideAmountWidth, child: amountColumn),
                  ] else ...[
                    const SizedBox(width: GeniusWalletConsts.space4),
                    Expanded(child: amountColumn),
                  ],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

Widget _buildRow(
  BuildContext context,
  String label,
  String value, {
  Color? valueColor,
}) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return Padding(
    padding: kGWDetailRowPadding,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textPrimary70,
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: valueColor ?? gw.textPrimary,
            ),
            // maxLines pairs with the ellipsis: without it, `overflow` only
            // trims the LAST wrapped line, so an unbounded model string still
            // grows the drawer row without limit (T-12-02).
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
  );
}

/// The `·`-grouped short form of an address or a hash - `0x1234·5678 … cdef·0123`.
///
/// Sketch 154-D, borrowing 034-A2's "eyeball verify" treatment: what a person
/// does with an address on screen is compare its ENDS against one they already
/// have. `WalletUtils.getAddressForDisplay` (no longer called here) gives them
/// 6 + 4 characters in two
/// unbroken runs; this gives 8 + 8 in 4-character groups, which is the unit the
/// eye actually checks, and emphasises the two groups that do the verifying.
///
/// **It deliberately does not show the whole value.** A 42-character address
/// chunked in full is ~398px of monospace and this panel's content width is
/// 380; a hash is 66 characters, which no single row can hold at any size.
/// Sketch 154 anticipated exactly this - chunking is *"worth it for an address
/// and arguable for a 64-character hash"*. The full value is what lands in the
/// clipboard, and the clipboard is what the row is for.
List<TextSpan> _valueChunks(String raw, GWColors gw, TextStyle base) {
  final v = raw.trim();
  final prefix = (v.length > 2 && v.toLowerCase().startsWith('0x'))
      ? v.substring(0, 2)
      : '';
  final body = v.substring(prefix.length);

  final strong = base.copyWith(
    color: gw.textPrimary,
    fontWeight: FontWeight.w600,
  );
  final quiet = base.copyWith(color: gw.textSecondary);

  List<String> groupsOf(String s) => [
    for (var i = 0; i < s.length; i += 4)
      s.substring(i, i + 4 > s.length ? s.length : i + 4),
  ];

  // Short enough to print whole - a chain symbol, a short reference. Every
  // group shows; the ends still carry the emphasis.
  if (body.length <= 16) {
    final g = groupsOf(body);
    return [
      if (prefix.isNotEmpty) TextSpan(text: prefix, style: quiet),
      for (var i = 0; i < g.length; i++) ...[
        if (i > 0) TextSpan(text: '·', style: quiet),
        TextSpan(
          text: g[i],
          style: (i == 0 || i == g.length - 1) ? strong : quiet,
        ),
      ],
    ];
  }

  final head = groupsOf(body.substring(0, 8));
  final tail = groupsOf(body.substring(body.length - 8));
  return [
    if (prefix.isNotEmpty) TextSpan(text: prefix, style: quiet),
    TextSpan(text: head[0], style: strong),
    TextSpan(text: '·', style: quiet),
    TextSpan(text: head[1], style: quiet),
    TextSpan(text: ' … ', style: quiet),
    TextSpan(text: tail[0], style: quiet),
    TextSpan(text: '·', style: quiet),
    TextSpan(text: tail[1], style: strong),
  ];
}

/// A detail row whose value belongs in the clipboard rather than on screen.
///
/// Sketch 154-D's whole premise: this drawer is opened *"to get the hash or the
/// address out"*. The glyph is present at rest rather than appearing on hover -
/// an affordance nobody can see until they hover over it is not an affordance -
/// and hover only brightens it, so nothing moves and the row never reflows.
///
/// `HitTestBehavior.opaque` makes the whole row the target, not just the
/// painted glyph: the panel gives us 380px of width and there is no reason to
/// hand the user a 14px one.
class _CopyRow extends StatefulWidget {
  const _CopyRow({required this.label, required this.value});

  final String label;

  /// The FULL value. What is drawn is [_valueChunks]' short form; what is
  /// copied is this.
  final String value;

  @override
  State<_CopyRow> createState() => _CopyRowState();
}

class _CopyRowState extends State<_CopyRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // The address treatment already used by the account drawers: bodySm in
    // JetBrainsMono. There is no mono token to reach for -- every call site
    // names the family, and this one does not invent a sixth way.
    final mono = GeniusWalletTypography.bodySm.copyWith(
      fontFamily: 'JetBrainsMono',
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Clipboard.setData(ClipboardData(text: widget.value));
          showAppSnackBar(context, '${widget.label} copied');
        },
        // The inset is INSIDE the detector, so the whole grid cell is the
        // target -- see kGWDetailRowPadding for why the grid does not pad.
        child: Padding(
          padding: kGWDetailRowPadding,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.label,
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textPrimary70,
                ),
              ),
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text.rich(
                        TextSpan(
                          children: _valueChunks(widget.value, gw, mono),
                        ),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space3),
                    Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: _hovered ? gw.textPrimary : gw.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ONE detail drawer for all seven types, replacing the three divergent
/// `_show*TransactionDetails` methods.
void showTransactionDetails(BuildContext context, Transaction tx) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  final content = txRowContent(tx, prices: livePricesBySymbol());
  final status = tx.transactionStatus;
  // `isDead` is gone with it: the Status row's colour no longer comes from a
  // failed/cancelled test here, it comes from txStatusColors like the pill's.
  final isSent = tx.transactionDirection == TransactionDirection.sent;
  final isSwap = tx.type == TransactionType.swap;

  // Two lists, not one: sketch 154-A groups the rows into TRANSACTION and
  // NETWORK, and the grouping is the design rather than a decoration on top of
  // it.
  final txRows = <Widget>[];
  final netRows = <Widget>[];

  void add(List<Widget> into, String label, String value, {Color? valueColor}) {
    if (value.trim().isEmpty) {
      return;
    }
    into.add(_buildRow(context, label, value, valueColor: valueColor));
  }

  void addCopy(List<Widget> into, String label, String value) {
    if (value.trim().isEmpty) {
      return;
    }
    into.add(_CopyRow(label: label, value: value.trim()));
  }

  // `.toLocal()` on every type. The old `TransactionItem` drawer formatted the
  // raw UTC stamp while the other two localised it — same field, two answers.
  add(txRows, 'Date', _dateFormat.format(tx.timeStamp.toLocal()));
  // The pill's own colour, from the same function -- see txStatusColors for
  // the two rules this replaces.
  add(
    txRows,
    'Status',
    _capitalizeStatus(status),
    valueColor: txStatusColors(status, gw).fg,
  );
  // 154-A: "the exact number belongs on a receipt". `exactAmount` is non-null
  // ONLY when the headline lost precision, so this row appears exactly when
  // there is something the headline is not telling you.
  if (content.exactAmount != null) {
    add(txRows, 'Exact amount', content.exactAmount!);
  }

  if (isSwap) {
    // A swap's counterparty is a router contract, not a person, and its
    // "From"/"To" labels would collide with the address row's — so the pairs
    // take those labels and the address row is dropped for this type. These
    // are amounts, not addresses: plain rows, nothing to copy.
    add(
      txRows,
      'From',
      '${formatTxAmount(tx.fromAmount ?? '')} ${tx.fromSymbol ?? ''}',
    );
    add(
      txRows,
      'To',
      '${formatTxAmount(tx.toAmount ?? '')} ${tx.toSymbol ?? ''}',
    );
    add(txRows, 'Rate', tx.exchangeRate ?? '');
  } else {
    final counterparty = isSent
        ? (tx.recipients.isEmpty ? '' : tx.recipients.first.toAddr)
        : tx.fromAddress;
    // 154-D: the FULL address goes to the row, which prints its short chunked
    // form and copies the whole thing. `getAddressForDisplay` is deliberately
    // not called here any more — it would have truncated the value before the
    // clipboard ever saw it.
    addCopy(txRows, isSent ? 'To' : 'From', counterparty);
  }

  add(netRows, 'Network', tx.coinSymbol);
  // Where the fee lives now that it is off the resting row. A blank `fees`
  // means "no fee is known" (e.g. the D-01 unwired swap path) - skip the row
  // entirely, exactly as the Rate row above already skips a blank
  // `exchangeRate`. Do not "restore" this for a value that composes to a bare
  // coin symbol; that IS the defect this guard closes.
  if (tx.fees.trim().isNotEmpty) {
    add(netRows, 'Network Fee', '${formatTxAmount(tx.fees)} ${tx.coinSymbol}');
  }
  // For a processing job the hash IS the job reference — one row, not the same
  // value printed twice under two labels.
  addCopy(
    netRows,
    tx.type == TransactionType.process ? 'Job' : 'Hash',
    tx.hash,
  );

  final explorerUrl = getExplorerUrl(tx.coinSymbol, tx.hash);

  ResponsiveDrawer.show(
    context: context,
    title: content.action,
    child: ListView(
      children: [
        const SizedBox(height: GeniusWalletConsts.space8),
        Center(child: _identity(content, gw, size: 60)),
        const SizedBox(height: GeniusWalletConsts.space6),
        Center(
          child: Text(
            content.amount,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.numericHeadline.copyWith(
              color: _toneColor(content.tone, gw),
            ),
          ),
        ),
        // The fiat line. Already computed on this call and dropped by the
        // shipped drawer, which is the defect sketch 154 opened with. Null
        // means an unpriced coin, and then no line is printed rather than a
        // fabricated `$0.00`.
        if (content.valueLine != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          Center(
            child: Text(
              content.valueLine!,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
        ],
        const SizedBox(height: GeniusWalletConsts.space6),
        // `_statusPill` was written, correct for all four states, and used only
        // on wide rows. The amount stays neutral on purpose (031 round 2): the
        // colour rides on the icon badge, this pill and the Status row.
        Center(child: _statusPill(status, gw)),
        const SizedBox(height: GeniusWalletConsts.space12),

        // A kicker over a ruled well, which is 154-A's grouping restored
        // (Jakub 2026-07-28: "tej siatki nie ma - chciałbym ją mieć"). The
        // first pass shipped the rows bare on 067-A's reasoning; see
        // `GWDetailGrid`'s doc for why that reasoning covers a box around a
        // FORM and not a read-only table, and why `borderSubtle` rather than
        // the white 36% a form's frame would need.
        const GWKicker('Transaction'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWDetailGrid(rows: txRows),
        const SizedBox(height: GeniusWalletConsts.space10),
        const GWKicker('Network'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWDetailGrid(rows: netRows),
      ],
    ),
    // Suppressed rather than rendered dead: on a chain missing from
    // `explorerMap` the old button opened nothing at all.
    footer: explorerUrl.isEmpty
        ? null
        : GWButton(
            onPressed: () {
              final uri = Uri.tryParse(explorerUrl);
              if (uri?.scheme.startsWith('http') ?? false) {
                launchWebSite(context, uri.toString());
              }
            },
            label: 'View on Explorer',
            leading: const Icon(Icons.open_in_new),
            // gradientOutline, not secondary (Jakub, 2026-07-28): this is the
            // panel's ONLY action, so it carries the brand signature — hollow,
            // because opening a block explorer commits to nothing.
            variant: GWButtonVariant.gradientOutline,
            // lg = 56, matching Swap Settings' Apply and both account drawers.
            // Without it this took the `md` default and was the ONE drawer
            // footer in the app 8px shorter than its neighbours.
            size: GWButtonSize.lg,
            expand: true,
          ),
  );
}
