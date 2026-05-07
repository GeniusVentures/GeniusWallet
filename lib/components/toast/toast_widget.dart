import 'package:flutter/material.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class ToastWidget extends StatelessWidget {
  final String title;
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const ToastWidget({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.onDismiss,
  }) : super(key: key);

  Color _accent() {
    switch (type) {
      case ToastType.success:
        return GeniusWalletColors.statusSuccess;
      case ToastType.error:
        return GeniusWalletColors.statusError;
      case ToastType.warning:
        return GeniusWalletColors.statusWarning;
    }
  }

  IconData _icon() {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle_outline_outlined;
      case ToastType.error:
        return Icons.error_outline_outlined;
      case ToastType.warning:
        return Icons.warning_amber_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accent();
    return Container(
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      decoration: BoxDecoration(
        color: GeniusWalletColors.surfaceElevated,
        border: Border.all(color: accent, width: 2),
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        boxShadow: GeniusWalletElevation.card,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(_icon(), color: accent, size: 28),
          const SizedBox(width: GeniusWalletConsts.space6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GeniusWalletTypography.titleMd),
                const SizedBox(height: GeniusWalletConsts.space2),
                SelectableText(
                  message,
                  style: GeniusWalletTypography.bodySm.copyWith(
                    color: GeniusWalletColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDismiss,
            child: const Padding(
              padding: EdgeInsets.all(GeniusWalletConsts.space2),
              child: Icon(
                Icons.close,
                color: GeniusWalletColors.textSecondary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
