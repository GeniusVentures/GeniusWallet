import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// Typography aligned with the GNUS marketing site (gnus.ai), which uses the
/// Inter variable font with a Tailwind-style scale (text-xs … text-5xl).
///
/// Styles are getters (not cached finals) so the default text colour follows
/// the appearance-aware [GWColors.textPrimary] when the user toggles
/// dark/light in Preferences.
class GeniusWalletTypography {
  GeniusWalletTypography._();

  /// The bundled monospace family, named here ONCE. Seed phrases, addresses,
  /// transaction hashes, log output and job payloads all render in this font
  /// so their characters line up in fixed-width columns -- the alignment IS
  /// the verification aid, and a typo'd family string falls back silently to
  /// a proportional font with no error and no test failure. Read this token
  /// instead of the bundled family name by string literal (see
  /// `pubspec.yaml`'s `fonts:` block for the asset declaration).
  ///
  /// A `static const String` (not a `TextStyle`) because call sites diverge
  /// on base style/color/weight -- e.g. `bodySm` vs `bodyLg` vs a bare
  /// `TextStyle`, with or without an explicit `color:` -- so no single
  /// complete `TextStyle` clears the Rule of Three across all eight sites.
  static const String monoFamily = 'JetBrainsMono';

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Slightly tightened tracking for display/headline sizes — matches the
  /// website's `--tracking-tight` (-0.025em) treatment on large headings.
  static const double _trackingTight = -0.4;

  /// Live [GWColors] for the current global [GWAppearance] -- every member of
  /// this class is `static`, so no `BuildContext` ever reaches here. 23-04:
  /// replaces what used to be direct `GeniusWalletColors.<field>` reads, now
  /// that class is private to `gw_colors.dart`'s library.
  static GWColors get _gw =>
      GWAppearance.isLight ? GWColors.light() : GWColors.dark();

  /// Bakes a default text color from the appearance-aware [_gw]`.textPrimary`
  /// when [color] is omitted. This is a BACKWARD-COMPAT fallback only, kept
  /// for the many call sites not yet migrated to context-resolved color --
  /// it does NOT itself make text re-skin live on a `const` widget (see the
  /// GWColors ThemeExtension migration, 04-02). Live-re-skin call sites must
  /// instead pass an explicit `color` sourced from
  /// `Theme.of(context).extension<GWColors>()`
  /// (e.g. `GeniusWalletTypography.titleMd.copyWith(color: gw.textPrimary)`),
  /// which overrides this baked default and rides the registered `Theme`
  /// InheritedWidget dependency.
  static TextStyle _inter({
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) => TextStyle(
    fontFamily: 'Inter',
    fontSize: fontSize,
    height: height,
    fontWeight: fontWeight,
    color: color ?? _gw.textPrimary,
    letterSpacing: letterSpacing,
    fontFeatures: fontFeatures,
  );

  // --- Display ---------------------------------------------------------------
  static TextStyle get displayLg => _inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
  );

  static TextStyle get displayMd => _inter(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
  );

  // --- Headline --------------------------------------------------------------
  static TextStyle get headlineLg => _inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: _trackingTight,
  );

  static TextStyle get headlineMd =>
      _inter(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600);

  // --- Title -----------------------------------------------------------------
  static TextStyle get titleLg =>
      _inter(fontSize: 18, height: 24 / 18, fontWeight: FontWeight.w600);

  static TextStyle get titleMd =>
      _inter(fontSize: 16, height: 22 / 16, fontWeight: FontWeight.w500);

  // --- Body ------------------------------------------------------------------
  static TextStyle get bodyLg =>
      _inter(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);

  // Default body bumped 14->16 for touchscreen legibility (web scale was too
  // small on phones). bodyLg (16) and bodyMd now coincide; re-differentiate
  // later if a distinct dense-body size is needed.
  static TextStyle get bodyMd =>
      _inter(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400);

  static TextStyle get bodySm => _inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    // The legacy mode-invariant value (fixedTextSecondary), not
    // _gw.textSecondary -- see GWColors.fixedTextSecondary's doc comment;
    // bodySm's colour has never diverged by appearance and must not start
    // now ("nothing here may repaint").
    color: GWColors.fixedTextSecondary,
  );

  // --- Label -----------------------------------------------------------------
  // Floor raised 12->13: 12px read too small on a touchscreen.
  static TextStyle get labelMd =>
      _inter(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500);

  // --- Numeric variants (tabular figures for balances / addresses) -----------
  static TextStyle get numericDisplay => _inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
    fontFeatures: _tabular,
  );

  static TextStyle get numericHeadline => _inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  static TextStyle get numericBody => _inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    fontFeatures: _tabular,
  );

  static TextTheme toMaterialTextTheme() => TextTheme(
    displayLarge: displayLg,
    displayMedium: displayMd,
    headlineLarge: headlineLg,
    headlineMedium: headlineMd,
    titleLarge: titleLg,
    titleMedium: titleMd,
    bodyLarge: bodyLg,
    bodyMedium: bodyMd,
    bodySmall: bodySm,
    labelMedium: labelMd,
  );
}
