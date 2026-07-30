import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/bottom_drawer/drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';

/// 031-B1's receipt, applied to the Reown swap result (D-02, 21-03).
///
/// Status colour comes from ONE source, [txStatusColors] -- the same
/// function the transaction receipt's own pill and Status row already
/// share -- so this drawer's pill can never disagree with the palette every
/// other receipt in the app uses (T-21-04). This drawer's API carries no
/// amount, so [GWDrawerReceiptHead.amount] is omitted entirely rather than a
/// fabricated figure (21-CONTEXT's scope fence).
///
/// **A finding, recorded, not acted on (21-03-SUMMARY.md):**
/// `handle_dapp_requests.dart:174-184` builds a complete `Transaction` model
/// two lines before calling `SwapResultDrawer.show` -- exactly what
/// `showTransactionDetails` consumes, which means this drawer could in
/// principle take the same deletion-and-repoint `9ff7c04` applied to the two
/// squid swap drawers, instead of being re-skinned. That is Phase 10
/// mechanics and out of this plan's fence.
class SwapResultDrawer {
  static Future<void> show({
    required BuildContext context,
    required bool isSuccess,
    required String txHash,
    required String coinSymbol,
  }) async {
    final gw = context.gw;
    final status = isSuccess
        ? TransactionStatus.completed
        : TransactionStatus.failed;
    final (:fg, :wash) = txStatusColors(status, gw);
    // The existing glyph choice is kept; only its size and colour source
    // change, from a locally-derived iconColor to the shared palette.
    final icon = isSuccess ? Icons.check_circle : Icons.error;
    final message = isSuccess ? 'Swap Success' : 'Swap Failed';
    final explorerUrl = (txHash.isNotEmpty)
        ? getExplorerUrl(coinSymbol, txHash)
        : '';

    await ResponsiveDrawer.show(
      context: context,
      title: message,
      child: ListView(
        children: [
          GWDrawerReceiptHead(
            identity: Icon(icon, size: 56, color: fg),
            pill: GWDrawerStatusPill(
              label: isSuccess ? 'Completed' : 'Failed',
              foreground: fg,
              background: wash,
            ),
          ),
          // Neither the kicker nor the grid render for the failure branch,
          // which always passes an empty txHash -- GWDetailGrid already
          // renders nothing for an empty row list, but a bare kicker over
          // nothing is not emitted either.
          if (txHash.isNotEmpty) ...[
            const SizedBox(height: GeniusWalletConsts.space10),
            const GWKicker('Transaction'),
            const SizedBox(height: GeniusWalletConsts.space4),
            GWDetailGrid(
              rows: [GWCopyRow(label: 'Transaction hash', value: txHash)],
            ),
          ],
        ],
      ),
      footer: Column(
        children: [
          GWButton(
            onPressed: () => context.push('/transactions'),
            label: 'Go to Transactions',
            variant: GWButtonVariant.gradient,
            size: GWButtonSize.lg,
            expand: true,
          ),
          if (explorerUrl.isNotEmpty) ...[
            const SizedBox(height: GeniusWalletConsts.space6),
            GWButton(
              onPressed: () => launchWebSite(context, explorerUrl),
              label: 'View on Explorer',
              variant: GWButtonVariant.gradientOutline,
              size: GWButtonSize.lg,
              expand: true,
            ),
          ],
        ],
      ),
    );
  }
}
