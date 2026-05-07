import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';

class GWCard extends StatelessWidget {
  const GWCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(GeniusWalletConsts.space8),
    this.onTap,
    this.elevated = true,
    this.gradient,
    this.background,
    this.border,
    this.radius = GeniusWalletConsts.radiusLg,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final bool elevated;
  final Gradient? gradient;
  final Color? background;
  final BoxBorder? border;
  final double radius;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final resolvedBackground = gradient != null
        ? null
        : (background ?? GeniusWalletColors.surfaceElevated);

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: resolvedBackground,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border,
        boxShadow: elevated ? GeniusWalletElevation.card : null,
      ),
      child: child,
    );

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onTap,
        child: content,
      ),
    );
  }
}
