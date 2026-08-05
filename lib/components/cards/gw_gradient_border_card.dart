import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

/// Card surface with a thin brand-gradient outline — the signature treatment
/// the GNUS marketing site uses for highlight cards (`border-gradient-primary-to`).
///
/// Use [GWGradientBorderCard] for hero / featured content (account summary,
/// staking position, "premium" surfaces). Use the standard [GWCard] elsewhere.
///
/// Set [glass] to true for the frosted-glass treatment — combined with the
/// animated [GWMeshBackground] this gives the premium "floating panel" look.
class GWGradientBorderCard extends StatelessWidget {
  const GWGradientBorderCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GeniusWalletConsts.space8),
    this.onTap,
    this.gradient = GeniusWalletGradient.brandBorder,
    this.background,
    this.borderWidth = 1.5,
    this.radius = GeniusWalletConsts.radius2xl,
    this.glow = false,
    this.glass = false,
    this.glassBlur = 24,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  /// Outline gradient. Defaults to the cyan→mint brand outline; pass
  /// [GeniusWalletGradient.brandCta] for a green→blue treatment instead.
  final LinearGradient gradient;
  final Color? background;
  final double borderWidth;
  final double radius;

  /// Adds the cyan/mint dual glow under the card when true — reserve for the
  /// single most important card on the screen.
  final bool glow;

  /// Frosted-glass background — applies a backdrop blur and uses the
  /// background colour at reduced opacity. Use over an animated / colourful
  /// surface (e.g. [GWMeshBackground]) for the premium floating-panel effect.
  final bool glass;

  /// Blur radius (sigma) when [glass] is true. Higher = more frosted.
  final double glassBlur;

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final outerRadius = BorderRadius.circular(radius);
    final innerRadius = BorderRadius.circular(
      (radius - borderWidth).clamp(0.0, radius),
    );

    final innerBg = glass
        ? (background ?? context.gw.surfaceElevated).withAlpha(115)
        : (background ?? context.gw.surfaceElevated);

    Widget innerSurface = Container(
      decoration: BoxDecoration(color: innerBg, borderRadius: innerRadius),
      padding: padding,
      child: child,
    );

    if (glass) {
      innerSurface = ClipRRect(
        borderRadius: innerRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: glassBlur, sigmaY: glassBlur),
          child: innerSurface,
        ),
      );
    }

    final card = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: outerRadius,
        boxShadow: glow ? GeniusWalletElevation.glowGradient : null,
      ),
      padding: EdgeInsets.all(borderWidth),
      child: innerSurface,
    );

    if (onTap == null) {
      return card;
    }

    return Material(
      color: Colors.transparent,
      borderRadius: outerRadius,
      child: InkWell(borderRadius: outerRadius, onTap: onTap, child: card),
    );
  }
}
