import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.backgroundColor = GeniusWalletColors.deepBlueCardColor,
    this.iconColor = GeniusWalletColors.lightGreenSecondary,
    this.textColor = GeniusWalletColors.gray500,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _iconColor =
        onPressed != null ? iconColor : GeniusWalletColors.gray600;
    final _textColor =
        onPressed != null ? textColor : GeniusWalletColors.gray600;

    return Expanded(child: LayoutBuilder(
      builder: (context, constraints) {
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(4),
            fixedSize: Size(constraints.maxWidth * 0.25, constraints.maxWidth),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                GeniusWalletConsts.borderRadiusCard,
              ),
            ),
            disabledBackgroundColor: GeniusWalletColors.deepBlueCardColor,
            backgroundColor: backgroundColor,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: constraints.maxWidth * 0.35, color: _iconColor), // Icon
              const SizedBox(height: 4),
              Flexible(
                child: AutoSizeText(
                  text,
                  style: TextStyle(
                    color: _textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1, // Ensure it doesn't overflow
                  overflow: TextOverflow.ellipsis,
                ),
              ), // Text below the icon
            ],
          ),
        );
      },
    ));
  }
}
