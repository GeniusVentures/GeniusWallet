import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// 033-B1's confirm body: a borderless amount hero, a static caution, and one
/// merged Details card -- replacing today's five separate boxes (a bordered
/// From box, a bordered To box, the amount hero, an "Estimated changes"
/// caption, and a fixed-dark fee card). No field is renamed, retyped or
/// reordered here -- this is a re-skin, not a data change. T-21-11's
/// mitigation still holds: this file performs no arithmetic, parsing or unit
/// conversion of its own. Every value arrives already formatted from
/// `handle_dapp_requests.dart`.
///
/// **Decision: the "sending-to" line is folded into the Details grid, not a
/// floating borderless row above it.** The task text offered a choice --
/// float `To` alone between the amount and the card, or wrap it in the same
/// [GWDetailGrid] as everything below. Floating it alone reads as an
/// accidental leftover of the five-box layout this file replaces (a single
/// borderless line sitting between two other elements, doing nothing else on
/// its own). Folded in, `From` and `To` sit together at the top of the one
/// Details card -- both via [GWCopyRow] so the FULL address always reaches the
/// clipboard even though the row shows a truncated form for eyeball-verify.
///
/// **`GWWarningNote` was not forked and was not given a borderless flag.**
/// 033-B1 asks for the caution to be a tint with no border;
/// `gw_warning_note.dart` has a hard-coded `Border.all(...)` and no such mode.
/// This file would be that component's fourth consumer, which is the point at
/// which AGENTS.md's Rule of Three would normally justify extracting a shared
/// variant -- except the shape a fourth consumer needs here is not a new
/// component, it is the SAME component with one boolean toggled, and
/// AGENTS.md's own Rule of Three text names that exact case as the one NOT to
/// extract ("if the shared version needs a boolean flag ... don't extract
/// it"). The caution keeps its existing half-alpha border rather than forking
/// or flagging it. Upgrade path, if a borderless mode is ever genuinely
/// needed app-wide: a second NAMED constructor on `GWWarningNote` (not a
/// bool), added the next time a real caller needs it, with its own contrast
/// measurement in both modes the way the current border already has one.
class SendTransactionDetails extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String totalGasFee;
  final String maxFeePerGas;
  final String priorityFee;
  final String? receiveTokenSymbol;

  const SendTransactionDetails({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.totalGasFee,
    required this.maxFeePerGas,
    required this.priorityFee,
    this.receiveTokenSymbol,
  });

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The amount hero: borderless, centred, and NEUTRAL (D-03) -- no
        // status colour, no accent, ever. Only the hand-typed fontSize:
        // 28/FontWeight.bold pair is replaced here; the amount itself was
        // already borderless.
        Text(
          amount,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GeniusWalletTypography.numericHeadline.copyWith(
            color: gw.textPrimary,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        const GWWarningNote(
          "Double-check the recipient address before approving. "
          "GeniusWallet can't undo a transfer.",
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        const GWKicker('Details'),
        const SizedBox(height: GeniusWalletConsts.space4),
        GWDetailGrid(
          rows: [
            if (fromAddress.isNotEmpty)
              GWCopyRow(label: 'From', value: fromAddress),
            if (toAddress.isNotEmpty) GWCopyRow(label: 'To', value: toAddress),
            if (amount.isNotEmpty)
              _PlainDetailRow(label: 'You send', value: '$amount ETH'),
            if (receiveTokenSymbol != null && receiveTokenSymbol!.isNotEmpty)
              _PlainDetailRow(label: 'You receive', value: receiveTokenSymbol!),
            if (totalGasFee.isNotEmpty)
              _PlainDetailRow(label: 'Gas Fee', value: '$totalGasFee ETH'),
            if (maxFeePerGas.isNotEmpty)
              _PlainDetailRow(
                label: 'Max Fee Per Gas',
                value: '$maxFeePerGas ETH',
              ),
            if (priorityFee.isNotEmpty)
              _PlainDetailRow(label: 'Priority Fee', value: '$priorityFee ETH'),
          ],
        ),
      ],
    );
  }
}

/// A plain label/value Details-grid row -- the widget form of
/// `transaction_displays.dart`'s own top-level `_buildRow`, kept as a small
/// [StatelessWidget] rather than a `_buildFoo()` helper method per AGENTS.md's
/// "widgets, not helper methods" rule.
class _PlainDetailRow extends StatelessWidget {
  const _PlainDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
