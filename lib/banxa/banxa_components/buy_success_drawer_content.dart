import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class BuySuccessDrawerContent extends StatelessWidget {
  const BuySuccessDrawerContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.check_circle,
            size: 72, color: GeniusWalletColors.brandGreen),
        SizedBox(height: GeniusWalletConsts.space8),
        Text(
          "Purchase Successful!",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: GeniusWalletConsts.space4),
        Text(
          "Crypto has been added to your wallet.",
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
