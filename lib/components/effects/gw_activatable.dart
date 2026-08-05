import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A tap target that a keyboard can reach and activate -- the sibling of
/// [GWHoverable] (`gw_hoverable.dart`), which owns hover and nothing else.
///
/// Exists because every control-track chip in the app was a bare
/// `GestureDetector(onTap:)`. `GestureDetector` responds to pointers only: it
/// takes no focus, has no `Semantics`, and cannot be activated from a
/// keyboard, which fails **WCAG 2.1.1 (Keyboard), Level A** -- not a styling
/// preference. Six chips shared that defect
/// (`_TimeframeTab` x2, `_FilterChip`, `_UnitSegment`, `_AmountChip`,
/// `_OrderToneChip`), which is why this is one widget rather than six
/// hand-rolled `FocusableActionDetector`s.
///
/// **Owns:** focus traversal, Enter/Space activation, the button role and
/// selected state reported to assistive tech, and the focus ring. The ring is
/// the one piece of paint this widget does own -- WCAG 2.4.7 requires a
/// visible focus indicator, so a caller cannot be trusted to opt out of it the
/// way it opts out of a hover response.
///
/// **Does not own:** anything else about paint. Callers keep deciding their own
/// fill, radius, padding and label colour exactly as they do under
/// [GWHoverable]; this widget only wraps the result.
///
/// `InkWell` was the other stdlib candidate and was declined: it would have
/// brought a splash and a highlight into six chips whose hover response is
/// already specified (sketch 008 variant D, "lift chip"), changing paint at
/// every site to fix a behaviour defect.
class GWActivatable extends StatelessWidget {
  const GWActivatable({
    required this.onPressed,
    required this.child,
    this.label,
    this.selected,
    this.borderRadius,
    super.key,
  });

  /// Invoked on tap, and on Enter or Space while focused.
  final VoidCallback onPressed;

  final Widget child;

  /// The accessible name. Pass when the visible glyph is an abbreviation the
  /// screen reader should not read literally; omit when the child's own text
  /// is already the name.
  ///
  /// When given, the child's own semantics are excluded -- otherwise the two
  /// merge and a reader announces "Minions MIN". `_UnitSegment` in
  /// `compute_panel.dart` had already hand-rolled that same `excludeSemantics`
  /// for the same reason; it now comes with the label.
  final String? label;

  /// Reported as the selected state to assistive tech. Null for targets that
  /// have no selected/unselected distinction.
  final bool? selected;

  /// Radius of the focus ring. Defaults to the pill used by every control
  /// track chip.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final radius = borderRadius ?? GeniusWalletConsts.radiusPill;

    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: FocusableActionDetector(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              onPressed();
              return null;
            },
          ),
        },
        shortcuts: const <ShortcutActivator, Intent>{
          // Enter is already bound to ActivateIntent by the default
          // WidgetsApp shortcuts; Space is bound for buttons but not for a
          // bare focusable, so it is stated here to match what a user
          // reasonably expects of a chip.
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        child: Builder(
          builder: (context) {
            final focused = Focus.of(context).hasFocus;
            return DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: focused
                    ? Border.all(color: gw.borderBrand, width: 2)
                    : null,
              ),
              child: GestureDetector(
                onTap: onPressed,
                // Only the CHILD's semantics are dropped when a label is
                // given, never the detector's -- excluding the whole subtree
                // takes `isFocusable` and the focus action with it, so a
                // reader would stop announcing the chip as reachable while
                // traversal still worked.
                child: label == null ? child : ExcludeSemantics(child: child),
              ),
            );
          },
        ),
      ),
    );
  }
}
