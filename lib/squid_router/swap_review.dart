import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Opens [review] in a drawer and resolves true only on Confirm.
Future<bool> showSwapReview(BuildContext context, SwapReview review) async {
  final confirmed = await ResponsiveDrawer.show<bool>(
    context: context,
    title: 'Review swap',
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

/// What a swap will do, shown before funds move: both amounts, the floor
/// slippage protection enforces, the network and every fee.
class SwapReview extends StatelessWidget {
  const SwapReview({
    super.key,
    required this.fromAmount,
    required this.fromSymbol,
    required this.toAmount,
    required this.toSymbol,
    required this.minimumReceived,
    required this.slippage,
    required this.network,
    required this.quote,
  });

  final String fromAmount;
  final String fromSymbol;
  final String toAmount;
  final String toSymbol;
  final String minimumReceived;
  final double slippage;
  final String network;
  final SwapQuote quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReviewRow(label: 'You pay', value: '$fromAmount $fromSymbol'),
        _ReviewRow(label: 'You receive', value: '$toAmount $toSymbol'),
        _ReviewRow(
          label: 'Minimum received ($slippage% slippage)',
          value: '$minimumReceived $toSymbol',
        ),
        _ReviewRow(label: 'Network', value: network),
        for (final fee in quote.feeLines)
          _ReviewRow(
            label: fee.name,
            value: '\$${fee.amountUsd.toStringAsFixed(2)}',
          ),
        _ReviewRow(
          label: 'Network gas',
          value: '\$${quote.gasUsd.toStringAsFixed(2)}',
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
