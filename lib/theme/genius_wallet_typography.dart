import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography aligned with the GNUS marketing site (gnus.ai), which uses the
/// Inter variable font with a Tailwind-style scale (text-xs … text-5xl).
///
/// Styles are getters (not cached finals) so the default text colour follows
/// the appearance-aware `GeniusWalletColors.textPrimary` when the user toggles
/// dark/light in Preferences.
class GeniusWalletTypography {
  GeniusWalletTypography._();

  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  /// Slightly tightened tracking for display/headline sizes — matches the
  /// website's `--tracking-tight` (-0.025em) treatment on large headings.
  static const double _trackingTight = -0.4;

  static TextStyle _inter({
    required double fontSize,
    required double height,
    required FontWeight fontWeight,
    Color? color,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color ?? GeniusWalletColors.textPrimary,
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

  static TextStyle get headlineMd => _inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
      );

  // --- Title -----------------------------------------------------------------
  static TextStyle get titleLg => _inter(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      );

  static TextStyle get titleMd => _inter(
        fontSize: 16,
        height: 22 / 16,
        fontWeight: FontWeight.w500,
      );

  // --- Body ------------------------------------------------------------------
  static TextStyle get bodyLg => _inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodyMd => _inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      );

  static TextStyle get bodySm => _inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: FontWeight.w400,
        color: GeniusWalletColors.textSecondary,
      );

  // --- Label -----------------------------------------------------------------
  static TextStyle get labelMd => _inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w500,
      );

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
