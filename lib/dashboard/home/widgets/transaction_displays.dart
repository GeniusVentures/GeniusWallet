import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
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

/// The Status pill for the wide page. Soft-tinted (label + dot in the status
/// colour on a low-alpha wash of it), reusing the badge palette so pill and
/// badge never disagree on what "failed" looks like.
///
/// completed/failed use the appearance-aware `gw.*` colours (AA in both
/// themes); cancelled uses `textSecondary` (also AA-tuned). pending uses the
/// mode-invariant `statusWarning` fill.
/// ponytail: `statusWarning` (#FFC42E) is AA as a label on the dark wash, but
/// as a label on the LIGHT wash it is too pale (~1.8:1). Deferred to the light
/// pass with the rest of the light-mode work; in dark mode — the current focus
/// — it clears AA. Upgrade path: a darker light-mode amber (≈#B26A00) behind a
/// `gw.statusWarning` getter, mirroring `gw.statusSuccess`/`gw.statusError`.
Widget _statusPill(TransactionStatus status, GWColors gw) {
  final (Color fg, Color bg) = switch (status) {
    TransactionStatus.completed => (
      gw.statusSuccess,
      gw.statusSuccess.withValues(alpha: 0.14),
    ),
    TransactionStatus.pending => (
      GeniusWalletColors.statusWarning,
      GeniusWalletColors.statusWarning.withValues(alpha: 0.16),
    ),
    TransactionStatus.failed => (
      gw.statusError,
      gw.statusError.withValues(alpha: 0.14),
    ),
    TransactionStatus.cancelled => (gw.textSecondary, gw.surfaceMenu),
  };
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: GeniusWalletConsts.space4,
      vertical: 3,
    ),
    decoration: BoxDecoration(
      color: bg,
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
  if (symbol.isEmpty) return _fallbackDot(gw);
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
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: GeniusWalletTypography.bodySm.copyWith(color: gw.textPrimary70),
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
  );
}

Widget _buildDetailsCard(BuildContext context, List<Widget> rows) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space2),
    child: Column(spacing: 10.0, children: rows),
  );
}

/// ONE detail drawer for all seven types, replacing the three divergent
/// `_show*TransactionDetails` methods.
void showTransactionDetails(BuildContext context, Transaction tx) {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  final content = txRowContent(tx, prices: livePricesBySymbol());
  final status = tx.transactionStatus;
  final isDead =
      status == TransactionStatus.failed ||
      status == TransactionStatus.cancelled;
  final isSent = tx.transactionDirection == TransactionDirection.sent;
  final isSwap = tx.type == TransactionType.swap;

  final rows = <Widget>[];
  void add(String label, String value, {Color? valueColor}) {
    if (value.trim().isEmpty) return;
    rows.add(_buildRow(context, label, value, valueColor: valueColor));
  }

  // `.toLocal()` on every type. The old `TransactionItem` drawer formatted the
  // raw UTC stamp while the other two localised it — same field, two answers.
  add('Date', _dateFormat.format(tx.timeStamp.toLocal()));
  add(
    'Status',
    _capitalizeStatus(status),
    valueColor: isDead ? gw.statusError : null,
  );

  if (isSwap) {
    // A swap's counterparty is a router contract, not a person, and its
    // "From"/"To" labels would collide with the address row's — so the pairs
    // take those labels and the address row is dropped for this type.
    add(
      'From',
      '${formatTxAmount(tx.fromAmount ?? '')} ${tx.fromSymbol ?? ''}',
    );
    add('To', '${formatTxAmount(tx.toAmount ?? '')} ${tx.toSymbol ?? ''}');
    add('Rate', tx.exchangeRate ?? '');
  } else {
    final counterparty = isSent
        ? (tx.recipients.isEmpty ? '' : tx.recipients.first.toAddr)
        : tx.fromAddress;
    add(isSent ? 'To' : 'From', WalletUtils.getAddressForDisplay(counterparty));
  }

  add('Network', tx.coinSymbol);
  // Where the fee lives now that it is off the resting row.
  add('Network Fee', '${formatTxAmount(tx.fees)} ${tx.coinSymbol}');
  // For a processing job the hash IS the job reference — one row, not the same
  // value printed twice under two labels.
  add(
    tx.type == TransactionType.process ? 'Job' : 'Hash',
    WalletUtils.getAddressForDisplay(tx.hash),
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
        const SizedBox(height: GeniusWalletConsts.space8),
        _buildDetailsCard(context, rows),
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
            variant: GWButtonVariant.secondary,
            expand: true,
          ),
  );
}
