import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_cancelled_drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class BuyCancelledDrawer {
  static void show(
    BuildContext context, {
    VoidCallback? onClose,
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: "Cancelled",
      children: const [
        BuyCancelledDrawerContent(),
      ],
      footer: OutlinedButton(
        onPressed: () {
          if (onClose != null) {
            onClose();
          }
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: GeniusWalletColors.statusError),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "Close",
          style: TextStyle(color: GeniusWalletColors.statusError),
        ),
      ),
      onClose: onClose,
    );
  }
}
