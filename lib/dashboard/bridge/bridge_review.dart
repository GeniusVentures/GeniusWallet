import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Opens [review] in a drawer and resolves true only on Confirm.
Future<bool> showBridgeReview(BuildContext context, BridgeReview review) async {
  final confirmed = await ResponsiveDrawer.show<bool>(
    context: context,
    title: 'Review bridge',
    child: SingleChildScrollView(child: review),
    footer: const _ConfirmFooter(),
  );
  return confirmed == true;
}

/// Pops its own drawer once: a double tap must not pop the page beneath.
class _ConfirmFooter extends StatefulWidget {
  const _ConfirmFooter();

  @override
  State<_ConfirmFooter> createState() => _ConfirmFooterState();
}

class _ConfirmFooterState extends State<_ConfirmFooter> {
  bool _done = false;

  void _close(bool confirmed) {
    if (_done) {
      return;
    }
    _done = true;
    Navigator.of(context).pop(confirmed);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GWButton(
            label: 'Cancel',
            variant: GWButtonVariant.gradientOutline,
            expand: true,
            onPressed: () => _close(false),
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space6),
        Expanded(
          child: GWButton(
            label: 'Confirm',
            variant: GWButtonVariant.gradient,
            expand: true,
            onPressed: () => _close(true),
          ),
        ),
      ],
    );
  }
}

/// What a bridge will do, shown before the burn. Every value arrives as a
/// parameter, so it can be pumped without a provider harness.
class BridgeReview extends StatelessWidget {
  const BridgeReview({
    super.key,
    required this.amount,
    required this.symbol,
    required this.sourceNetwork,
    required this.destinationNetwork,
    required this.gasPrice,
  });

  final String amount;
  final String symbol;
  final String sourceNetwork;
  final String destinationNetwork;
  final String gasPrice;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewRow(label: 'Amount burned', value: '$amount $symbol'),
        _ReviewRow(label: 'From', value: sourceNetwork),
        _ReviewRow(label: 'To', value: destinationNetwork),
        _ReviewRow(label: 'You receive', value: '$amount $symbol'),
        _ReviewRow(label: 'Gas price (Gwei)', value: gasPrice),
        const SizedBox(height: GeniusWalletConsts.space6),
        Text(
          'This cannot be undone. The $symbol is burned on $sourceNetwork '
          'and minted on $destinationNetwork.',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.statusErrorText,
          ),
        ),
      ],
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
      child: MergeSemantics(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                label,
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.end,
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: gw.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
