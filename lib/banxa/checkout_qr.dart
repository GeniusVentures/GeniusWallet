import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Drawer body that hands the checkout to another device. It has no poller of
/// its own; the screen behind the drawer moves on when the order is paid.
class CheckoutQrBody extends StatelessWidget {
  const CheckoutQrBody({super.key, required this.checkoutUrl});

  final String checkoutUrl;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final qrSize = math.max(
      160.0,
      math.min(240.0, MediaQuery.sizeOf(context).width - 120),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Scan with your phone's camera to open this checkout there. "
            'This screen updates when Banxa has your payment.',
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.bodyMd.copyWith(
              color: gw.textSecondary,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          Center(
            child: Container(
              // A scannable QR needs a light quiet zone in both appearances,
              // so this backing must not follow the theme.
              color: Colors.white,
              padding: const EdgeInsets.all(GeniusWalletConsts.space4),
              child: QrImageView(
                data: checkoutUrl,
                version: QrVersions.auto,
                size: qrSize,
              ),
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          SelectableText(
            checkoutUrl,
            textAlign: TextAlign.center,
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
              fontFamily: GeniusWalletTypography.monoFamily,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWButton(
            variant: GWButtonVariant.secondary,
            expand: true,
            leading: const Icon(Icons.content_copy),
            label: 'Copy link',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: checkoutUrl));
              if (context.mounted) {
                showToast(context, 'Link copied');
              }
            },
          ),
        ],
      ),
    );
  }
}
