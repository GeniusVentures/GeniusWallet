import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

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
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Default surfaces get the top-lit sheen + hairline edge so cards read as
    // material, not flat fills. Custom gradient/background/border are respected.
    final useDefaultSurface = gradient == null && background == null;

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: useDefaultSurface ? null : background,
        gradient:
            gradient ?? (useDefaultSurface ? GWDecorations.surfaceSheen : null),
        borderRadius: BorderRadius.circular(radius),
        border: border ??
            (useDefaultSurface
                ? Border.all(color: gw.borderSubtle, width: 1)
                : null),
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
