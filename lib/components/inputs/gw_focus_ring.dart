import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A brand-gradient focus ring around whatever it wraps.
///
/// Why this exists rather than an `InputDecoration` border: a `BorderSide`
/// takes a single `Color`, so no `InputBorder` can be a gradient. The app's
/// accent **is** the gradient — `drawers-final`'s global rule is "no flat blue
/// as the accent" — so a focused field painted `brandPrimary` is off-language
/// in the one state where the app is most clearly speaking to the user.
///
/// It also solves the bug that made this necessary: `theme.dart:242` sets an
/// app-wide `focusedBorder`, which beats any local `border: InputBorder.none`
/// because a per-state border always beats the fallback. Fields wrapped here
/// silence all four `InputDecoration` border states and let the ring paint.
///
/// **Geometry is constant across states.** The outer box keeps the same
/// [borderWidth] whether focused or not, swapping only the paint — a ring that
/// appears on focus by *growing* would shove the content it surrounds by a
/// pixel and a half every time the user clicks into it.
///
/// Focus is detected from descendants: the wrapper node cannot take focus
/// itself and is skipped in traversal, so it observes without participating.
/// Call sites do not have to own a `FocusNode`.
class GWFocusRing extends StatefulWidget {
  const GWFocusRing({
    super.key,
    required this.child,
    this.radius = GeniusWalletConsts.radiusMd,
    this.borderWidth = 1.5,
    this.restingColor,
    this.background,
    this.gradient = GeniusWalletGradient.brandCta,
    this.padding = EdgeInsets.zero,
    this.enabled = true,
  });

  final Widget child;
  final double radius;
  final double borderWidth;

  /// The unfocused edge. Defaults to `gw.borderSubtle`. Pass
  /// `Colors.transparent` for a control that should show no edge at rest.
  final Color? restingColor;

  /// Fill inside the ring. Defaults to `gw.surfaceElevated`.
  final Color? background;

  /// The focused edge. The real `brandCta` stops by default — the same pair
  /// the CTA buttons use, not `brandPrimary`/`brandSecondary`.
  final LinearGradient gradient;

  final EdgeInsetsGeometry padding;

  /// When false the ring never lights, for a read-only or disabled control.
  final bool enabled;

  @override
  State<GWFocusRing> createState() => _GWFocusRingState();
}

class _GWFocusRingState extends State<GWFocusRing> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final lit = _focused && widget.enabled;

    final outerRadius = BorderRadius.circular(widget.radius);
    final innerRadius = BorderRadius.circular(
      (widget.radius - widget.borderWidth).clamp(0.0, widget.radius),
    );

    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      // Fires when this node OR any descendant gains/loses focus, which is the
      // whole point: the field inside keeps its own node and this only watches.
      onFocusChange: (hasFocus) {
        if (hasFocus != _focused) {
          setState(() => _focused = hasFocus);
        }
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: lit ? widget.gradient : null,
          color: lit ? null : (widget.restingColor ?? gw.borderSubtle),
          borderRadius: outerRadius,
        ),
        child: Padding(
          padding: EdgeInsets.all(widget.borderWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.background ?? gw.surfaceElevated,
              borderRadius: innerRadius,
            ),
            child: Padding(padding: widget.padding, child: widget.child),
          ),
        ),
      ),
    );
  }
}
