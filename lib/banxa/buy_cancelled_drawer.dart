import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/buy_cancelled_drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';

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
          side: const BorderSide(color: Colors.redAccent),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "Close",
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
      onClose: onClose,
    );
  }
}
