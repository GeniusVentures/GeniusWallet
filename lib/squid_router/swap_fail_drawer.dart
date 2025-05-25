import 'package:flutter/material.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/squid_router/swap_drawer_content.dart';

class SwapFailDrawer {
  static void show(
    BuildContext context, {
    required String fromAmount,
    required String toAmount,
    required String fromIconUrl,
    required String toIconUrl,
    required String fromSymbol,
    required String toSymbol,
    required String chain,
    VoidCallback? onClose,
  }) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: "Swap Failed",
      children: [
        SwapDrawerContent(
          fromAmount: fromAmount,
          toAmount: toAmount,
          fromIconUrl: fromIconUrl,
          toIconUrl: toIconUrl,
          fromSymbol: fromSymbol,
          toSymbol: toSymbol,
          chain: chain,
          isSuccess: false,
        ),
      ],
      footer: OutlinedButton(
        onPressed: () {
          if (onClose != null) onClose();
        },
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          side: const BorderSide(color: Colors.redAccent),
          minimumSize: const Size.fromHeight(48),
        ),
        child: const Text(
          "Dismiss",
          style: TextStyle(color: Colors.redAccent),
        ),
      ),
    );
  }
}
