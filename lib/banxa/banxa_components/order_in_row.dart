import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class OrderInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const OrderInfoRow({required this.label, required this.value, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GeniusWalletTypography.bodyMd
                .copyWith(color: GeniusWalletColors.textSecondary)),
        Text(value, style: GeniusWalletTypography.numericBody),
      ],
    );
  }
}
