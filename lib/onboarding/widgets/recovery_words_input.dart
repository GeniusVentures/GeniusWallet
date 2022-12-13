import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class RecoveryWordsInput extends StatelessWidget {
  final List<String> selectedWords;
  const RecoveryWordsInput({
    super.key,
    required this.selectedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: GeniusWalletColors.blue500.withOpacity(0.1),
      height: 200,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Text(selectedWords.join(' ')),
    );
  }
}
