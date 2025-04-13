import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class CoinCardContainer extends StatelessWidget {
  final Widget child;
  const CoinCardContainer({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: GeniusWalletColors.deepBlueCardColor,
      child: SizedBox(height: 80, child: child),
    );
  }
}
