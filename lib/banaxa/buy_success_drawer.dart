// buy_success_drawer.dart
import 'package:flutter/material.dart';
import 'package:genius_wallet/banaxa/buy_success_drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';

class BuySuccessDrawer {
  static void show(
    BuildContext context, {
    VoidCallback? onClose,
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: "Success",
      children: const [
        BuySuccessDrawerContent(),
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
          side: const BorderSide(color: Colors.greenAccent),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "Done",
          style: TextStyle(color: Colors.greenAccent),
        ),
      ),
    );
  }
}
