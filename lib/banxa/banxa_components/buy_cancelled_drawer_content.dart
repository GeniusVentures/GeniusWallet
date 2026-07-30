import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/drawer_content.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// 031-B1's receipt head applied to the Banxa purchase-cancelled result
/// (D-02, 21-03). **Cancelled takes slate, not red** -- 066-B's explicit
/// rule, already implemented by [txStatusColors]
/// (`fg: textSecondary, wash: surfaceMenu`): nothing broke, so nothing here
/// should read as an error, unlike the red `Icons.cancel` this file used to
/// paint.
///
/// Stays `const` -- see `BuySuccessDrawerContent`'s doc comment for why a
/// `const` constructor does not prevent the live `Theme.of(context)` read in
/// `build()` from re-skinning this widget on an appearance toggle.
class BuyCancelledDrawerContent extends StatelessWidget {
  const BuyCancelledDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final (:fg, :wash) = txStatusColors(TransactionStatus.cancelled, gw);

    return Column(
      children: [
        GWDrawerReceiptHead(
          // An outline glyph, not the filled alarm-shaped Icons.cancel this
          // drawer used to paint -- a cancellation is not an error.
          identity: Icon(Icons.cancel_outlined, size: 56, color: fg),
          pill: GWDrawerStatusPill(
            label: 'Cancelled',
            foreground: fg,
            background: wash,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        Text(
          'You exited the checkout process before completing the '
          'transaction.',
          textAlign: TextAlign.center,
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
      ],
    );
  }
}
