import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class RecoveryWordsInput extends StatelessWidget {
  const RecoveryWordsInput({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.blue500,
      height: 200,
      width: MediaQuery.of(context).size.width * 0.8,
    );
  }
}
