import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/drawer_content.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// 031-B1's receipt head applied to the Banxa purchase-success result
/// (D-02, 21-03). Status colour comes from [txStatusColors] -- the same
/// function the transaction receipt and the Reown swap result already
/// share -- so this pill can never disagree with the app's one palette.
///
/// This drawer's API carries no amount (`BuySuccessDrawer.show` takes only
/// an optional `onClose`), so [GWDrawerReceiptHead.amount] is omitted
/// entirely, not fabricated.
///
/// Stays `const` -- what makes a widget re-skin-blind is never registering a
/// `Theme.of(context)` dependency in `build()` (the defect this file used to
/// be: a fixed `Colors.greenAccent` icon that never read the theme at all),
/// not the constructor being `const`. `Theme.of(context)` still registers a
/// live InheritedWidget dependency on this Element every time `build()`
/// runs, `const`-instanced or not, so this repaints correctly on an
/// appearance toggle.
class BuySuccessDrawerContent extends StatelessWidget {
  const BuySuccessDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final (:fg, :wash) = txStatusColors(TransactionStatus.completed, gw);

    return Column(
      children: [
        GWDrawerReceiptHead(
          identity: Icon(Icons.check_circle, size: 56, color: fg),
          pill: GWDrawerStatusPill(
            label: 'Completed',
            foreground: fg,
            background: wash,
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space6),
        Text(
          'Crypto has been added to your wallet.',
          textAlign: TextAlign.center,
          style: GeniusWalletTypography.bodyMd.copyWith(
            color: gw.textSecondary,
          ),
        ),
      ],
    );
  }
}
