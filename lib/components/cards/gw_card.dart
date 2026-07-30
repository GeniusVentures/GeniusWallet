import 'package:flutter/material.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/genius_wallet_motion.dart';
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
    this.hoverLift = false,
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

  /// Design-system hover — the sketch 008 D "lift chip" applied to a card: on
  /// pointer-enter the surface rises 2px, its hairline goes to [GWColors.borderStrong]
  /// and its shadow deepens to [GeniusWalletElevation.dialog]. Only takes effect
  /// together with [onTap] (a non-interactive card has no hover affordance).
  /// Defaults to `false` so every existing call site renders byte-identically —
  /// this is the additive flag the News redesign needs so it stops hand-rolling
  /// a `MouseRegion` + black scrim.
  final bool hoverLift;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this widget to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Default surfaces get the top-lit sheen + hairline edge so cards read as
    // material, not flat fills. Custom gradient/background/border are respected.
    final useDefaultSurface = gradient == null && background == null;

    if (hoverLift && onTap != null) {
      return _HoverLiftCard(
        onTap: onTap!,
        padding: padding,
        radius: radius,
        width: width,
        height: height,
        elevated: elevated,
        gradient: gradient,
        background: background,
        border: border,
        useDefaultSurface: useDefaultSurface,
        gw: gw,
        child: child,
      );
    }

    final content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: _cardDecoration(
        gw: gw,
        useDefaultSurface: useDefaultSurface,
        elevated: elevated,
        hovered: false,
        gradient: gradient,
        background: background,
        border: border,
        radius: radius,
      ),
      child: child,
    );

    if (onTap == null) {
      return content;
    }

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

/// Shared surface decoration for both the resting card and the hover-lift
/// variant. With `hovered: false` this is byte-identical to the pre-hoverLift
/// GWCard decoration (hairline `borderSubtle`, `elevation.card`); on hover the
/// hairline strengthens and the shadow deepens.
BoxDecoration _cardDecoration({
  required GWColors gw,
  required bool useDefaultSurface,
  required bool elevated,
  required bool hovered,
  required Gradient? gradient,
  required Color? background,
  required BoxBorder? border,
  required double radius,
}) {
  return BoxDecoration(
    color: useDefaultSurface ? null : background,
    gradient:
        gradient ?? (useDefaultSurface ? GWDecorations.surfaceSheen : null),
    borderRadius: BorderRadius.circular(radius),
    // THE app-wide hover recipe (sketch 044 variant 3, 2026-07-26): the
    // hairline goes BRAND on hover, not merely stronger, so a card answers a
    // pointer with the same mark as a nav tab and a control-track chip. A
    // caller-supplied border is still respected as-is, so a custom-bordered
    // card never surprises.
    border:
        border ??
        (useDefaultSurface
            ? Border.all(
                color: hovered ? GWDecorations.hoverEdge : gw.borderSubtle,
                width: 1,
              )
            : null),
    // Shadow no longer reacts to hover. Depth was this card's half of three
    // disagreeing hovers; the shared recipe is decorative, not geometric.
    boxShadow: elevated ? GeniusWalletElevation.card : null,
  );
}

/// The interactive, hover-reactive GWCard. Kept private and only reached via
/// `GWCard(hoverLift: true, onTap: ...)` so the common stateless path pays no
/// `State`/`MouseRegion` cost.
///
/// Hover plumbing moved into `GWHoverable` (23-05) -- this widget only
/// supplies the builder, which is the exact surface + Material + InkWell tree
/// it built directly before the migration. Demoted to `StatelessWidget`:
/// once hover moved out, this widget held no state of its own.
class _HoverLiftCard extends StatelessWidget {
  const _HoverLiftCard({
    required this.child,
    required this.onTap,
    required this.padding,
    required this.radius,
    required this.width,
    required this.height,
    required this.elevated,
    required this.gradient,
    required this.background,
    required this.border,
    required this.useDefaultSurface,
    required this.gw,
  });

  final Widget child;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double? width;
  final double? height;
  final bool elevated;
  final Gradient? gradient;
  final Color? background;
  final BoxBorder? border;
  final bool useDefaultSurface;
  final GWColors gw;

  @override
  Widget build(BuildContext context) {
    return GWHoverable(
      builder: (hovered) {
        final surface = AnimatedContainer(
          duration: GeniusWalletMotion.fast,
          curve: GeniusWalletMotion.standard,
          width: width,
          height: height,
          padding: padding,
          // The 2px lift is gone (2026-07-26). Hover is now the app-wide
          // decorative recipe — brand tint painted OVER the card plus the brand
          // hairline in the decoration below — so a card, a nav tab and a chip in
          // the navbar's control track all answer a pointer identically. The tint
          // rides in `foregroundDecoration` because the card's own surface may be
          // a gradient, and a BoxDecoration cannot hold both a gradient and a
          // colour.
          foregroundDecoration: hovered
              ? BoxDecoration(
                  color: GWDecorations.hoverFill,
                  borderRadius: BorderRadius.circular(radius),
                )
              : null,
          decoration: _cardDecoration(
            gw: gw,
            useDefaultSurface: useDefaultSurface,
            elevated: elevated,
            hovered: hovered,
            gradient: gradient,
            background: background,
            border: border,
            radius: radius,
          ),
          child: child,
        );

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(radius),
            onTap: onTap,
            child: surface,
          ),
        );
      },
    );
  }
}
