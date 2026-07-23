import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

enum ActionButtonAnimation { none, rotate }

class ActionButton extends StatefulWidget {
  final IconData icon;
  final String text;
  final VoidCallback? onPressed;

  /// Optional overrides. When null, colors resolve from the appearance-aware
  /// design system in [build] (fill → [GWColors.surfaceElevated], icon glyph →
  /// [GeniusWalletColors.brandPrimaryOnSurface], caption → [GWColors.textSecondary]).
  final Color? backgroundColor;
  final Color? iconColor;
  final Color? textColor;
  final ActionButtonAnimation animation;
  final String? semanticLabel;

  const ActionButton({
    super.key,
    required this.icon,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.textColor,
    this.animation = ActionButtonAnimation.none,
    this.semanticLabel,
  });

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
    // Fail-soft read registers the InheritedWidget dependency so even a `const`
    // ActionButton re-skins on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final bool isEnabled = widget.onPressed != null;

    // Enabled treatment (design system): elevated surface fill, brand accent
    // glyph, secondary-text caption — all appearance-aware. Caller overrides win.
    final Color enabledFill = widget.backgroundColor ?? gw.surfaceElevated;
    final Color enabledGlyph =
        widget.iconColor ?? GeniusWalletColors.brandPrimaryOnSurface;
    final Color enabledCaption = widget.textColor ?? gw.textSecondary;

    // Disabled treatment (Send / Swap / gated More): a recessed surface with a
    // lowered-but-visible glyph + caption so the button reads as clearly
    // disabled (not enabled) yet stays legible in both dark and light modes.
    final Color disabledFill = gw.surfaceSunken;
    final Color disabledGlyph = gw.textPrimary54;
    final Color disabledCaption = gw.textPrimary54;

    final Color glyphColor = isEnabled ? enabledGlyph : disabledGlyph;
    final Color captionColor = isEnabled ? enabledCaption : disabledCaption;

    return Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final iconWidget = Icon(
            widget.icon,
            size: constraints.maxWidth * 0.45,
            color: glyphColor,
          );

          final animatedIcon = widget.animation == ActionButtonAnimation.rotate
              ? RotationTransition(turns: _controller, child: iconWidget)
              : iconWidget;

          // 🟢 Semantics wrapper for accessibility
          return Semantics(
            button: true,
            enabled: isEnabled,
            label: widget.semanticLabel ?? widget.text,
            child: ElevatedButton(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                fixedSize: Size(
                  constraints.maxWidth * 0.25,
                  constraints.maxWidth,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    GeniusWalletConsts.borderRadiusCard,
                  ),
                ),
                backgroundColor: enabledFill,
                disabledBackgroundColor: disabledFill,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  animatedIcon,
                  Flexible(
                    child: AutoSizeText(
                      widget.text,
                      style: TextStyle(
                        color: captionColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
