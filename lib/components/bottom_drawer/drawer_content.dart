import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// asked this phase to promote, so the six receipts (D-02) read as one family
// rather than six columns that resemble each other. Colour in this file rides
// on the icon, the pill and the status row only, never on an amount (D-03) —
// GWDrawerReceiptHead.amountColor is always the caller's own value, never
// derived from a status here.
//
// This file does NOT also hold a list row or a section/detail-row pair.
// 21-01's plan named three more classes — GWDrawerListRow, GWDrawerSection,
// GWDrawerDetailRow — and by the time this plan executed, all three already
// existed under different names, already promoted, already adopted by more
// callers than this plan would have converted on its own:
//
// * The list row (sketch 032-A1) is GWSelectRow
//   (lib/components/cards/gw_select_row.dart), promoted 2026-07-28 from
//   this same _TokenRow this plan's Task 3 was going to convert. It already
//   has four consumers (Select Network, SDK Accounts, Your Accounts, Token
//   Selector) and its own test, test/components/gw_select_row_test.dart,
//   which is this plan's "list selection treatment" check. Writing a second,
//   GWDrawerListRow-named copy here would not be sharing — it would be the
//   exact duplication D-04 exists to remove.
// * The section card and detail row are GWKicker
//   (lib/components/cards/gw_kicker.dart) plus GWDetailGrid /
//   kGWDetailRowPadding (lib/components/cards/gw_detail_grid.dart),
//   promoted the same day. GWDetailGrid already fixes the reported defect
//   this plan's read_first notes describe (_buildDetailsCard's
//   vertical-only padding) — its rows own their own horizontal+vertical
//   inset precisely so a tappable copy row's hit area matches its painted
//   cell, which is a finer answer than this plan's own GWDrawerDetailRow
//   spec asked for. transaction_displays.dart's showTransactionDetails
//   already renders its TRANSACTION/NETWORK groups through this pair.
//
// See 21-01-SUMMARY.md for the full account of what shipped ahead of this
// plan (commits 8044bdb, bd501d7, d7903fc) and why re-building already-
// adopted primitives under new names was declined rather than attempted.

/// 031-B1's status pill, generalised so the five non-transaction receipts
/// (D-02, 21-04) can use the same physical pill as the transaction receipt's
/// own `_statusPill` (`transaction_displays.dart`) without inheriting its
/// `TransactionStatus` mapping.
///
/// This widget maps NO enum and owns NO palette — the caller supplies the
/// foreground/background pair. That is what lets `_statusPill` keep its
/// already-correct four-state `TransactionStatus` palette (kept as-is; it is
/// out of this plan's file scope) while every other receipt supplies its own
/// fixed state without a fake transaction status to hang it on. Geometry is
/// lifted verbatim from `_statusPill`: 999 radius, `space4` horizontal /
/// 3px vertical padding, a 6px dot, a 5px gap, `labelMd` at w600.
class GWDrawerStatusPill extends StatelessWidget {
  const GWDrawerStatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
  });

  final String label;

  /// The dot and the label text.
  final Color foreground;

  /// The pill's low-alpha wash. The caller owns this pairing entirely — nine
  /// out of ten times it will be `foreground.withValues(alpha: 0.14)`, but
  /// this widget does not assume that, because `_statusPill`'s own four
  /// tones do not all use the same alpha (see `txStatusColors`).
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: foreground,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: GeniusWalletTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// 031-B1's receipt head: the identity, the amount and the state, centred, in
/// the order every receipt shares. Every optional slot omitted entirely when
/// null — never a placeholder, never a fabricated zero, matching the rule
/// `showTransactionDetails` already follows for its own fiat line.
///
/// The gap from whatever sits above this widget (the shell's header hairline,
/// via the caller's own body padding) to [identity] is `space16` (32px) —
/// deliberately larger than the `space10` (20px) gap the CALLER places between
/// this widget and the first section label below it, per the drawers-final
/// refinement table. That trailing gap is the caller's, not this widget's,
/// exactly as `showTransactionDetails` already places its own gap before
/// `GWKicker('Transaction')` today.
///
/// **`amount`/`amountColor` are an optional SLOT, not a mode flag (21-03).**
/// Three of the six receipts D-02 names — both Banxa results and the Reown
/// swap result — carry no amount at all in their APIs: `BuySuccessDrawer.show`
/// takes only an optional `onClose`, `BuyCancelledDrawer.show` takes nothing,
/// `SwapResultDrawer.show` takes `isSuccess`/`txHash`/`coinSymbol`. The
/// rejected alternative was requiring every caller to supply an amount, which
/// would have forced either a fabricated figure (21-CONTEXT's scope fence
/// forbids inventing data) or three receipts built outside this family —
/// exactly the fragmentation D-02 exists to remove. Omitting the slot
/// entirely, the same way [fiat]/[exact]/[pill] already behave when null, is
/// the one option that needs neither.
class GWDrawerReceiptHead extends StatelessWidget {
  const GWDrawerReceiptHead({
    super.key,
    required this.identity,
    this.amount,
    this.amountColor,
    this.pill,
    this.fiat,
    this.exact,
  }) : assert(
         amount == null || amountColor != null,
         'amountColor is required whenever amount is supplied — a caller '
         'must never pass an amount and silently inherit a derived colour '
         '(D-03 exists precisely because a derived amount colour is the '
         'failure mode).',
       );

  /// One coin, or two overlapped for a swap, with its badge — the same shape
  /// `_identity()` in `transaction_displays.dart` already builds. This widget
  /// does not build it; the caller does, exactly as it does today.
  final Widget identity;

  /// Omitted entirely (not a placeholder, not a fabricated `0`) when the
  /// caller's own data carries no amount. See the class doc.
  final String? amount;

  /// D-03: the caller's own colour. Never derive this from a status here —
  /// the amount stays neutral in every receipt; colour rides on the icon
  /// badge, the pill and the Status row only. Required whenever [amount] is
  /// supplied — enforced by the constructor's assert.
  final Color? amountColor;

  /// Typically a [GWDrawerStatusPill]. Any widget so a receipt with no status
  /// concept at all can omit it entirely rather than pass an empty one.
  final Widget? pill;

  final String? fiat;
  final String? exact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: GeniusWalletConsts.space16),
        identity,
        if (amount != null) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          Text(
            amount!,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GeniusWalletTypography.numericHeadline.copyWith(
              color: amountColor,
            ),
          ),
        ],
        if (fiat != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          _QuietLine(fiat!),
        ],
        if (exact != null) ...[
          const SizedBox(height: GeniusWalletConsts.space2),
          _QuietLine(exact!),
        ],
        if (pill != null) ...[
          const SizedBox(height: GeniusWalletConsts.space6),
          pill!,
        ],
      ],
    );
  }
}

/// The fiat and exact-amount sub-lines share one quiet treatment — the same
/// `bodyMd`/`textSecondary` style `showTransactionDetails` already uses for
/// its own fiat line.
class _QuietLine extends StatelessWidget {
  const _QuietLine(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this text to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary),
    );
  }
}
