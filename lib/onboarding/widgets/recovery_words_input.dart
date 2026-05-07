import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

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
        border: Border.all(color: GeniusWalletColors.borderSubtle),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radius2xl),
        color: GeniusWalletColors.surfaceMenu,
      ),
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      height: 180,
      width: MediaQuery.of(context).size.width,
      child: Text(
        selectedWords.join(' '),
        style: GeniusWalletTypography.bodyLg,
      ),
    );
  }
}
