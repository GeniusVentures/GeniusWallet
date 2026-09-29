import 'package:flutter/material.dart';
import 'package:genius_wallet/components/gw_icon.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// One row-menu action, so icon size, colour and disabled treatment cannot
/// drift between the wallet, SDK and child-operation menus that all use it.
///
/// `onPressed: null` is Material's own disabled state - nothing here fakes
/// it with opacity. The icon still needs dimming explicitly: `MenuItemButton`
/// disables its own foreground, but `leadingIcon` is a widget handed to it,
/// so a disabled destructive item would otherwise show a greyed label next
/// to a full-strength icon in [color].
class GWMenuItem extends StatelessWidget {
  const GWMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.lockedReason,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  /// Wraps the item in a [Tooltip] carrying this message when [onPressed] is
  /// null - the reason a caller disabled it, not a generic "disabled" hint.
  final String? lockedReason;

  /// Overrides the enabled foreground colour, for a destructive item.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final enabled = onPressed != null;
    final fg = !enabled
        ? gw.textSecondary.withValues(alpha: 0.5)
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
      child: Text(label),
    );
    if (enabled || lockedReason == null) {
      return item;
    }
    return Tooltip(message: lockedReason, child: item);
  }
}
