import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class GeniusWalletGradient {
  // 23-04: btnGradientBlue/btnGradientGreen/gradientGreen/gradientBlue/
  // brandPrimary/brandSecondaryBright below were `GeniusWalletColors.<name>`
  // references -- fixed (mode-invariant) primitives, now private to
  // gw_colors.dart's library. Several consumers below need these as
  // compile-time constants (default parameter values, `static const`
  // fields used at 20+ call sites app-wide), which a `GWColors` INSTANCE
  // field read cannot satisfy. Inlined as literals, each labelled with the
  // legacy name it mirrors, rather than growing GWColors with matching
  // static consts for values that already live as instance fields there.
  static LinearGradient greenBlueGreenGradient = const LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      Color.fromRGBO(0, 104, 239, 1), // btnGradientBlue
      Color.fromRGBO(1, 221, 166, 1), // btnGradientGreen
    ],
  );

  /// Primary CTA gradient — green (left) → blue (right).
  /// Mirrors the website's `linear-gradient(270deg, #0c91cc, #06aa78)`.
  static const LinearGradient brandCta = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFF0AD89C), // gradientGreen
      Color(0xFF0AAEE6), // gradientBlue
    ],
  );

  /// [brandCta] as a TEXT shader, degraded to a flat light-safe brand when the
  /// surface it paints on is light.
  ///
  /// As text, `brandCta`'s two stops measure **9.4:1 and 6.8:1** on the dark
  /// menu surface — fine. On the LIGHT menu surface (`#EFF2F6`) the same stops
  /// measure **1.65:1 and 2.28:1**, i.e. unreadable, so light collapses the
  /// shader to `brandPrimaryOnSurface` (`#0A6885`, 5.61:1). Collapsing to a
  /// single repeated stop keeps exactly ONE paint path — no branch in the
  /// widget tree (the pattern `gw_view_all_link.dart` already uses).
  ///
  /// [appearanceProxy] must be a surface colour whose luminance stands in for
  /// the appearance — pass `gw.surfaceMenu`. Reading a token rather than the
  /// global flag is what stops two consumers degrading at different
  /// thresholds.
  ///
  /// Lifted here 2026-07-26 from `transactions_slim_view.dart`'s file-scoped
  /// `_activeLabelShader` when a THIRD consumer appeared (the navbar's Connect
  /// field, sketch 043 variant 4A). Its own docs named the risk this shared
  /// home removes: a second, separately-drifting colour decision.
  static LinearGradient brandCtaText(Color appearanceProxy) {
    if (appearanceProxy.computeLuminance() <= 0.5) {
      return brandCta;
    }
    // Not const: brandPrimaryOnSurface is an appearance-aware getter. No
    // BuildContext reaches this static method, so -- like GWDecorations --
    // it reads the live GWColors instance for the current global appearance
    // directly, matching whichever mode already agrees with the code path
    // that got here.
    final safe = (GWAppearance.isLight ? GWColors.light() : GWColors.dark())
        .brandPrimaryOnSurface;
    return LinearGradient(colors: [safe, safe]);
  }

  /// Outline gradient used on bordered cards on the website
  /// (`linear-gradient(to right, var(--color-primary), #36edb5)`).
  static const LinearGradient brandBorder = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: <Color>[
      Color(0xFF14C8FF), // brandPrimary
      Color(0xFF5BFFD0), // brandSecondaryBright
    ],
  );

  /// Subtle background wash for hero sections — fades the brand teal into the
  /// darker contained surface so cards still feel anchored.
  static LinearGradient get heroWash {
    final gw = GWAppearance.isLight ? GWColors.light() : GWColors.dark();
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: <Color>[gw.surfaceBase, gw.surfaceElevated],
    );
  }
}
