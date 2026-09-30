import 'package:flutter/material.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// One row-menu action shared by the wallet, SDK and child-operation menus.
/// Disabled is `onPressed: null`; the icon is dimmed here because
/// `MenuItemButton` does not dim a caller-supplied `leadingIcon`.
class GWMenuItem extends StatelessWidget {
  const GWMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.lockedReason,
    this.color,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Wraps the item in a [Tooltip] carrying this message when [onPressed] is
  /// null - the reason a caller disabled it, not a generic "disabled" hint.
  final String? lockedReason;

  /// Overrides the enabled foreground colour, for a destructive item.
  final Color? color;

  /// A second, smaller line under the label.
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final enabled = onPressed != null;
    // 70%, not 50%: measured against surfaceMenu (the real menu backdrop,
    // not the row it's opened from), 50% clears only 2.10:1 (light) /
    // 2.32:1 (dark) -- under the 3:1 non-text floor. 70% clears 3.01:1 /
    // 3.31:1, the minimum step that does.
    final fg = !enabled
        ? gw.textSecondary.withValues(alpha: 0.7)
        : (color ?? gw.textPrimary);
    final item = MenuItemButton(
      leadingIcon: GWIcon.material(icon, color: fg),
      style: MenuItemButton.styleFrom(
        foregroundColor: fg,
        // Without this, Material substitutes its own onSurface@38% for the
        // disabled label and the row disagrees with its own icon again.
        disabledForegroundColor: fg,
      ),
      onPressed: onPressed,
      child: subtitle == null
          ? Text(label)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                Text(
                  subtitle!,
                  style: GeniusWalletTypography.labelMd.copyWith(color: fg),
                ),
              ],
            ),
    );
    if (enabled || lockedReason == null) {
      return item;
    }
    return Tooltip(message: lockedReason, child: item);
  }
}
