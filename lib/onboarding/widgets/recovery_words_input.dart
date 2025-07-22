import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class RecoveryWordsInput extends StatelessWidget {
  final List<String> selectedWords;
  const RecoveryWordsInput({
    super.key,
    required this.selectedWords,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: GeniusWalletColors.gray500),
          borderRadius: const BorderRadius.all(Radius.circular(15)),
          color: GeniusWalletColors.grayPrimary),
      padding: const EdgeInsets.all(16),
      height: 180,
      width: MediaQuery.of(context).size.width,
      child: Text(selectedWords.join(' ')),
    );
  }
}
