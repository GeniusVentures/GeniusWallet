import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';

class CreateOrderButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback? onPressed;
  final bool compact;
  final String label;

  const CreateOrderButton({
    required this.enabled,
    required this.onPressed,
    required this.compact,
    required this.label,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Ink(
        decoration: BoxDecoration(
          gradient: enabled
              ? GeniusWalletGradient.greenBlueGreenGradient
              : LinearGradient(
                  colors: [Colors.grey.shade500, Colors.grey.shade600],
                ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          alignment: Alignment.center,
          height: 48,
          child: Text(
            label,
            style: TextStyle(
              color: enabled
                  ? GeniusWalletColors.deepBlue
                  : Colors.black.withOpacity(0.4),
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
