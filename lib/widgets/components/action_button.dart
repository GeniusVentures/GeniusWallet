import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

enum ActionButtonAnimation { none, rotate }

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color iconColor;
  final Color textColor;
  final ActionButtonAnimation animation;

  const ActionButton({
    Key? key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.backgroundColor = GeniusWalletColors.deepBlueCardColor,
    this.iconColor = GeniusWalletColors.lightGreenSecondary,
    this.textColor = GeniusWalletColors.gray500,
    this.animation = ActionButtonAnimation.none,
  }) : super(key: key);

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    if (widget.animation == ActionButtonAnimation.rotate) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant ActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animation == ActionButtonAnimation.rotate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconWidget = Icon(
            widget.icon,
            size: constraints.maxWidth * 0.35,
            color: widget.iconColor,
          );

          final animatedIcon = widget.animation == ActionButtonAnimation.rotate
              ? RotationTransition(
                  turns: _controller,
                  child: iconWidget,
                )
              : iconWidget;

          return ElevatedButton(
            onPressed: widget.onPressed,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(0),
              fixedSize:
                  Size(constraints.maxWidth * 0.25, constraints.maxWidth),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  GeniusWalletConsts.borderRadiusCard,
                ),
              ),
              disabledBackgroundColor: GeniusWalletColors.deepBlueCardColor,
              backgroundColor: widget.backgroundColor,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                animatedIcon,
                Flexible(
                  child: AutoSizeText(
                    widget.text,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
