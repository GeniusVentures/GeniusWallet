import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography aligned with the GNUS marketing site (gnus.ai), which uses the
/// Inter variable font with a Tailwind-style scale (text-xs … text-5xl).
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
    Color color = GeniusWalletColors.textPrimary,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) =>
      GoogleFonts.inter(
        fontSize: fontSize,
        height: height,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        fontFeatures: fontFeatures,
      );

  // --- Display ---------------------------------------------------------------
  static final TextStyle displayLg = _inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
  );

  static final TextStyle displayMd = _inter(
    fontSize: 28,
    height: 36 / 28,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
  );

  // --- Headline --------------------------------------------------------------
  static final TextStyle headlineLg = _inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    letterSpacing: _trackingTight,
  );

  static final TextStyle headlineMd = _inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
  );

  // --- Title -----------------------------------------------------------------
  static final TextStyle titleLg = _inter(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
  );

  static final TextStyle titleMd = _inter(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w500,
  );

  // --- Body ------------------------------------------------------------------
  static final TextStyle bodyLg = _inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodyMd = _inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
  );

  static final TextStyle bodySm = _inter(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    color: GeniusWalletColors.textSecondary,
  );

  // --- Label -----------------------------------------------------------------
  static final TextStyle labelMd = _inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
  );

  // --- Numeric variants (tabular figures for balances / addresses) -----------
  static final TextStyle numericDisplay = _inter(
    fontSize: 32,
    height: 40 / 32,
    fontWeight: FontWeight.w700,
    letterSpacing: _trackingTight,
    fontFeatures: _tabular,
  );

  static final TextStyle numericHeadline = _inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w600,
    fontFeatures: _tabular,
  );

  static final TextStyle numericBody = _inter(
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
