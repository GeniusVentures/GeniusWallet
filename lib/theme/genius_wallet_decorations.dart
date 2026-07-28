import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_elevation.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

/// Depth & material primitives that lift surfaces off the flat canvas.
///
/// The brand stays clean — these add *quality* through subtle top-lighting,
/// hairline edges and soft elevation rather than colour or ornament. All
/// primitives are appearance-aware (dark = black canvas, light = white
/// canvas) via [GWAppearance]. Use these instead of painting flat
/// `surfaceElevated` fills.
class GWDecorations {
  GWDecorations._();

  // --- canvas -------------------------------------------------------------

  /// Dark: a quiet vertical wash on a true-black base — a touch lifted at the
  /// top, deepest at the bottom — so the canvas reads as a lit space instead
  /// of one flat fill.
  static const LinearGradient _canvasDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF14171E), // lifted near-black at the top
      Color(0xFF0B0D12), // surfaceBase (dark)
      Color(0xFF07090D), // settling toward sunken at the bottom
    ],
    stops: [0.0, 0.4, 1.0],
  );

  /// Light: a soft cool-gray wash (≈15% off white, user-tuned) so the white
  /// cards separate clearly from the page.
  static const LinearGradient _canvasLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE3E6EB), Color(0xFFDCE0E6), Color(0xFFD3D7DE)],
    stops: [0.0, 0.4, 1.0],
  );

  /// Page background wash. Replaces `backgroundColor: surfaceBase`.
  static LinearGradient get canvas =>
      GWAppearance.isLight ? _canvasLight : _canvasDark;

  /// A quiet overhead light near the top of the dark canvas — a faint cool
  /// glow that fades out by mid-screen, so the hero area reads as lit.
  /// Layered over [canvas] (dark mode only; a vignette would read as dirt on
  /// white).
  static const RadialGradient canvasTopLight = RadialGradient(
    center: Alignment(0, -0.9),
    radius: 1.0,
    colors: [Color(0x1FFFFFFF), Color(0x00FFFFFF)], // white 12% -> 0
    stops: [0.0, 0.6],
  );

  // --- elevated surfaces --------------------------------------------------

  /// Dark: a FLAT surfaceElevated fill, matching the Swap tab's boxes exactly
  /// (`swap_field.dart` passes `background: gw.surfaceElevated` to GWCard,
  /// which skips the sheen). Jakub, 2026-07-25: the Swap boxes are the target
  /// look for every box in the app, so the one lever that reaches them all is
  /// this gradient — every `GWDecorations.surface()` consumer, every default
  /// `GWCard`, plus dialogs, bottom sheets, the responsive overlay and the
  /// empty state read it.
  ///
  /// Kept as a LinearGradient rather than switched to a solid `color:` so the
  /// change stays one edit instead of rewriting every consumer's decoration.
  /// The previous top-lit pair was 0xFF181B24 -> 0xFF0C0E14 (~8 L* delta).
  static const LinearGradient _surfaceSheenDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0C0E14), // surfaceElevated (dark)
      Color(0xFF0C0E14), // same stop — flat, no sheen
    ],
  );

  /// Light: white settling into a faint cool gray at the bottom edge.
  static const LinearGradient _surfaceSheenLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF5F7FA)],
  );

  /// Top-lit sheen for elevated surfaces, simulating a soft overhead light.
  static LinearGradient get surfaceSheen =>
      GWAppearance.isLight ? _surfaceSheenLight : _surfaceSheenDark;

  /// Standard premium surface: top-lit sheen + a 1px hairline edge + soft
  /// card elevation. This is the default for cards, pills, fields, tiles.
  static BoxDecoration surface({
    double radius = GeniusWalletConsts.radiusLg,
    bool elevated = true,
    Color? border,
  }) => BoxDecoration(
    gradient: surfaceSheen,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(
      color: border ?? GeniusWalletColors.borderSubtle, // hairline @ 12%
      width: 1,
    ),
    boxShadow: elevated ? GeniusWalletElevation.card : null,
  );

  /// Pill / fully-rounded variant of [surface].
  static BoxDecoration pill({bool elevated = false, Color? border}) => surface(
    radius: GeniusWalletConsts.radiusPill,
    elevated: elevated,
    border: border,
  );

  // --- hover ---------------------------------------------------------------

  /// THE hover treatment. One recipe for every interactive surface in the app
  /// — nav tabs, control-track chips, cards, list rows (sketch 044 variant 3,
  /// chosen 2026-07-26).
  ///
  /// Deliberately **decorative, not geometric**. The three hovers this
  /// replaces all moved the element: the nav tab rose 1px, `GWCard` rose 2px,
  /// and the track chips did neither (only a fill), so nothing in the app
  /// agreed. Geometry was the wrong foundation for a shared recipe on two
  /// counts: `ButtonStyle` cannot express a transform, so every button-based
  /// control needed its own wrapper; and lifting a chip that sits INSIDE a
  /// recessed `surfaceSunken` track contradicts itself — a thing in a groove
  /// does not rise above its rim.
  ///
  /// Both tokens are fixed-brand, not appearance-aware, matching every other
  /// brand colour (`genius_wallet_colors.dart:42` — "Brand + status colours
  /// are fixed"), so this reads identically in dark and light.
  ///
  /// The hairline is not decoration on decoration: a 12% tint alone, on a list
  /// row over `surfaceElevated`, sits at the edge of visibility. The border is
  /// what says "this row, not its neighbour".
  static Color get hoverFill => GeniusWalletColors.brandPrimarySubtle; // ~12%
  static Color get hoverEdge => GeniusWalletColors.brandPrimaryMuted; //  ~24%

  /// [hoverFill] + [hoverEdge] as a decoration, for consumers that paint a
  /// `BoxDecoration` (nav tabs, cards). Button-based controls read the two
  /// colours directly into their `ButtonStyle` instead.
  static BoxDecoration hover({required double radius}) => BoxDecoration(
    color: hoverFill,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: hoverEdge, width: 1),
  );

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

/// Layered page background: vertical wash + (dark mode) a quiet overhead
/// light + fine grain, so the canvas reads as a lit, textured space instead of
/// one flat fill. Wrap a page body in this instead of painting a solid
/// `surfaceBase`.
class GWCanvasBackground extends StatelessWidget {
  const GWCanvasBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isLight = GWAppearance.isLight;
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(decoration: BoxDecoration(gradient: GWDecorations.canvas)),
        if (!isLight) ...[
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
        ],
        child,
      ],
    );
  }
}
