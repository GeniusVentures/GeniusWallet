import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class BuyCancelledDrawerContent extends StatelessWidget {
  const BuyCancelledDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.cancel, size: 72, color: GeniusWalletColors.statusError),
        SizedBox(height: 16),
        Text(
          "Purchase Cancelled",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          "You exited the checkout process before completing the transaction.",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
