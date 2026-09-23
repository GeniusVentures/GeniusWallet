import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// The confirm body for a transfer: an amount hero, a caution, and one
/// Details card. It performs no arithmetic, parsing or unit conversion --
/// every value arrives already formatted from its caller.
class SendTransactionDetails extends StatelessWidget {
  final String fromAddress;
  final String toAddress;
  final String amount;
  final String totalGasFee;
  final String maxFeePerGas;
  final String priorityFee;
  final String? receiveTokenSymbol;

  /// The unit of [amount]. Separate from [feeSymbol] because gas is paid in
  /// the chain's native currency no matter what is being sent -- one shared
  /// symbol would label a gas figure with a token's name.
  final String amountSymbol;
  final String feeSymbol;

  /// Named because the same token and address exist on many chains, and a
  /// send on the wrong one is a common permanent loss.
  final String? networkName;
  final String? tokenContract;

  const SendTransactionDetails({
    super.key,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.totalGasFee,
    required this.maxFeePerGas,
    required this.priorityFee,
    this.receiveTokenSymbol,
    this.amountSymbol = 'ETH',
    this.feeSymbol = 'ETH',
    this.networkName,
    this.tokenContract,
  });

  @override
  Widget build(BuildContext context) {
    final gw = context.gw;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // The amount hero: borderless, centred, and NEUTRAL -- no status
        // colour, no accent, ever. Only the hand-typed fontSize:
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
            if (networkName != null && networkName!.isNotEmpty)
              _PlainDetailRow(label: 'Network', value: networkName!),
            if (tokenContract != null && tokenContract!.isNotEmpty)
              GWCopyRow(label: 'Token', value: tokenContract!),
            if (amount.isNotEmpty)
              _PlainDetailRow(
                label: 'You send',
                value: '$amount $amountSymbol',
              ),
            if (receiveTokenSymbol != null && receiveTokenSymbol!.isNotEmpty)
              _PlainDetailRow(label: 'You receive', value: receiveTokenSymbol!),
            if (totalGasFee.isNotEmpty)
              _PlainDetailRow(
                label: 'Gas Fee',
                value: '$totalGasFee $feeSymbol',
              ),
            if (maxFeePerGas.isNotEmpty)
              _PlainDetailRow(
                label: 'Max Fee Per Gas',
                value: '$maxFeePerGas $feeSymbol',
              ),
            if (priorityFee.isNotEmpty)
              _PlainDetailRow(
                label: 'Priority Fee',
                value: '$priorityFee $feeSymbol',
              ),
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
      // Side by side when both fit; otherwise the value drops under its
      // label and wraps in full -- a figure about to be signed is never cut.
      // Full width, or a Wrap shrinks to its content and spaceBetween no
      // longer pushes the value to the right edge.
      child: SizedBox(
        width: double.infinity,
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: GeniusWalletConsts.space3,
          runSpacing: GeniusWalletConsts.space2,
          children: [
            Text(
              label,
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textPrimary70,
              ),
            ),
            Text(
              value,
              textAlign: TextAlign.right,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
