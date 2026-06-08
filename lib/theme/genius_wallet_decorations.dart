import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';

/// Depth & material primitives that lift surfaces off the flat canvas.
///
/// The brand stays clean and dark — these add *quality* through subtle
/// top-lighting, hairline edges and soft elevation rather than colour or
/// ornament. Use these instead of painting flat `surfaceElevated` fills.
class GWDecorations {
  GWDecorations._();

  // --- canvas -------------------------------------------------------------

  /// Page background: a quiet vertical wash on the teal base (a touch lighter
  /// at the top, deeper at the bottom) so the canvas reads as a lit space
  /// instead of one flat fill. Replaces `backgroundColor: surfaceBase`.
  static const LinearGradient canvas = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF316E80), // surfaceBase, lifted ~8% at the top
      GeniusWalletColors.surfaceBase, // #2A6275
      Color(0xFF234E5E), // settling toward surfaceMenu at the bottom
    ],
    stops: [0.0, 0.4, 1.0],
  );

  /// A quiet overhead light near the top of the canvas — a faint cool glow
  /// that fades out by mid-screen, so the hero area reads as lit. Layered over
  /// [canvas].
  static const RadialGradient canvasTopLight = RadialGradient(
    center: Alignment(0, -0.9),
    radius: 1.0,
    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)], // white 12% -> 0
    stops: [0.0, 0.6],
  );

  // --- elevated surfaces --------------------------------------------------

  /// Top-lit sheen for dark elevated surfaces — a near-black fill that's a
  /// hair lighter at the top edge, simulating a soft overhead light. The
  /// delta is tiny (~8 L*) so it never reads as a gradient, just as material.
  static const LinearGradient surfaceSheen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF181B24), // surfaceElevated + sheen
      GeniusWalletColors.surfaceElevated, // #0C0E14
    ],
  );

  /// Standard premium surface: top-lit sheen + a 1px hairline edge + soft
  /// card elevation. This is the default for cards, pills, fields, tiles.
  static BoxDecoration surface({
    double radius = GeniusWalletConsts.radiusLg,
    bool elevated = true,
    Color? border,
  }) =>
      BoxDecoration(
        gradient: surfaceSheen,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: border ?? GeniusWalletColors.borderSubtle, // white @ 12%
          width: 1,
        ),
        boxShadow: elevated ? GeniusWalletElevation.card : null,
      );

  /// Pill / fully-rounded variant of [surface].
  static BoxDecoration pill({bool elevated = false, Color? border}) => surface(
      radius: GeniusWalletConsts.radiusPill,
      elevated: elevated,
      border: border);

  // --- tactile circular action -------------------------------------------

  /// Raised circular action (Send / Receive / Swap …): top-lit sheen, hairline
  /// edge and an optional brand glow so the button reads as a physical chip
  /// rather than a flat hole punched in the canvas.
  static BoxDecoration actionCircle({bool glow = false}) => BoxDecoration(
        gradient: surfaceSheen,
        shape: BoxShape.circle,
        border: Border.all(color: GeniusWalletColors.borderSubtle, width: 1),
        boxShadow: [
          ...GeniusWalletElevation.card,
          if (glow)
            BoxShadow(
              color: GeniusWalletColors.brandPrimary.withAlpha(36),
              blurRadius: 18,
            ),
        ],
      );

  // --- hero glow ----------------------------------------------------------

  /// Soft cyan→mint aura placed behind a hero element (the balance). Render
  /// inside a [DecoratedBox] sized smaller than its content so the glow only
  /// bleeds at the edges.
  static BoxDecoration heroGlow = BoxDecoration(
    borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusPill),
    boxShadow: GeniusWalletElevation.glowGradient,
  );
}

/// Layered page background: vertical wash + a quiet overhead light + fine grain
/// so the canvas reads as a lit, textured space instead of one flat fill. Wrap
/// a page body in this instead of painting a solid `surfaceBase`.
class GWCanvasBackground extends StatelessWidget {
  const GWCanvasBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: GWDecorations.canvas),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(gradient: GWDecorations.canvasTopLight),
        ),
        // Fine monochrome grain so large dark fills aren't perfectly flat.
        const IgnorePointer(
          child: Opacity(
            opacity: 0.04,
            child: Image(
              image: AssetImage('assets/images/textures/noise.png'),
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
              alignment: Alignment.topLeft,
              filterQuality: FilterQuality.none,
            ),
          ),
        ),
        child,
      ],
    );
  }
}
