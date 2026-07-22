import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:intl/intl.dart';

final _dateFormat = DateFormat("MMMM d, y 'at' h:mm a");

String _capitalizeStatus(TransactionStatus status) =>
    status.name[0].toUpperCase() + status.name.substring(1);

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
          Positioned.fill(
            child: _coinImage(content.iconSymbols.first, gw),
          )
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
                child: _coinImage(content.iconSymbols[1], gw, fit: BoxFit.cover),
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
          child: Row(
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
                              style: GeniusWalletTypography.labelMd.copyWith(
                                color: gw.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GeniusWalletConsts.space2),
                    Text(
                      content.subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              // Fixed 132 literal, never a fraction of the incoming
              // constraints: an unbounded amount must not decide the panel's
              // width, and a continuously-derived size is the 37639d5 freeze.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tooltip ONLY when the clamp actually lost something —
                    // wrapping unconditionally attaches an empty tooltip to
                    // every row.
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
                ),
              ),
            ],
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
    add('From', '${formatTxAmount(tx.fromAmount ?? '')} ${tx.fromSymbol ?? ''}');
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
