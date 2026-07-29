import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A dot + label status row - the shape shipped twice already and never
/// shared. `transaction_displays.dart:99-113`'s `_statusPill` and
/// `banxa_components/order_status_style.dart:87-99`'s `OrderStatusPill` both
/// draw a 6px circle, a 5px gap, then the label at `labelMd` weight 600. The
/// compute panel's status row (Phase 14) is the third occurrence of that exact
/// anatomy, and the geometry above is copied from those two forks verbatim
/// rather than re-chosen - that is what makes this an extraction instead of a
/// new invention, and it is also what keeps this row inside its 18px line box.
///
/// **There is no pill here.** Both existing forks wrap this shape in their own
/// wash `Container` and pass their foreground colour as [labelColor]; the
/// compute panel passes no [labelColor] at all and gets `gw.textPrimary`
/// instead of the dot's hue. That single parameter is what lets one widget
/// serve both a coloured-label pill (wrapped by the call site) and a
/// neutral-label status row (used bare). [color] paints only the dot - the
/// call site owns any wash, padding or pill shape around this widget.
///
/// **Migrating the two existing forks onto this widget is deliberately out of
/// scope here.** `transaction_displays.dart`'s pill belongs to Phase 12/15
/// (transactions); `order_status_style.dart`'s pill belongs to Phase 9
/// (Banxa). Both migrations are a zero-repaint change once undertaken, because
/// the geometry already matches exactly - that is the point of copying it
/// rather than inventing a new value here.
class GWStatusDot extends StatelessWidget {
  const GWStatusDot({
    super.key,
    required this.color,
    required this.label,
    this.labelColor,
    this.trailingValue,
    this.size = 6,
    this.gap = 5,
  });

  /// The dot's fill only. The call site picks the semantic token (success,
  /// error, warning, brand, or a neutral secondary text colour) - this widget
  /// carries no opinion about which state maps to which hue.
  final Color color;

  final String label;

  /// Null renders the label in `gw.textPrimary` rather than [color]. This is
  /// the parameter that separates a coloured-label pill (pass the dot's own
  /// colour) from a neutral-label status row (pass nothing).
  final Color? labelColor;

  /// Renders at the same `labelMd` w600 metric as [label], with
  /// `FontFeature.tabularFigures()` so a ticking percentage does not shift the
  /// label sideways as its digit widths change. Whether this is null also
  /// governs the row's main-axis sizing - see the class doc: null keeps the
  /// row at its minimum width (the two pill forks' need), non-null fills the
  /// available width and pushes this value to the far end (the compute tile's
  /// need).
  final String? trailingValue;

  /// Circle diameter. Defaults to the shipped forks' 6px.
  final double size;

  /// Gap between the circle and the label. Defaults to the shipped forks' 5px.
  final double gap;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final hasTrailing = trailingValue != null;

    final dot = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    // Single line, ellipsis overflow. A wrap would add a second line box and
    // silently break the 18px height budget this row exists to protect.
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: GeniusWalletTypography.labelMd.copyWith(
        fontWeight: FontWeight.w600,
        color: labelColor ?? gw.textPrimary,
      ),
    );

    return Row(
      mainAxisSize: hasTrailing ? MainAxisSize.max : MainAxisSize.min,
      children: [
        dot,
        SizedBox(width: gap),
        // Expanded (only when trailing is present) is what fills the row and
        // pushes the trailing value flush to the far end; Flexible keeps the
        // no-trailing row at its minimum width while still letting a very
        // long label ellipsise instead of overflowing a tight parent.
        hasTrailing ? Expanded(child: labelText) : Flexible(child: labelText),
        if (hasTrailing)
          Text(
            trailingValue!,
            style: GeniusWalletTypography.labelMd.copyWith(
              fontWeight: FontWeight.w600,
              color: gw.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
      ],
    );
  }
}
