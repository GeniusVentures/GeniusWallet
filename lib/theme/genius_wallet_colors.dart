import 'package:flutter/material.dart';

class GeniusWalletColors {
  // ---------------------------------------------------------------------------
  // GNUS brand palette — aligned with the marketing site (gnus.ai).
  // Primary: cyan. Secondary: mint. Tertiary: purple. Use these tokens for
  // new code; legacy names below are remapped onto the new palette.
  // ---------------------------------------------------------------------------

  // Brand — primary (cyan/blue). Vibrant v1.2 — electric. See DESIGN_SYSTEM.md note 2026-05.
  static const Color brandPrimary = Color(0xFF14C8FF);
  static const Color brandPrimaryStrong = Color(0xFF0AAEE6);
  static Color brandPrimaryMuted =
      const Color(0xFF14C8FF).withAlpha(61); // ~24%
  static Color brandPrimarySubtle =
      const Color(0xFF14C8FF).withAlpha(31); // ~12%

  // Brand — secondary (mint/green). Vibrant v1.2 — electric.
  static const Color brandSecondary = Color(0xFF2BF5B4);
  static const Color brandSecondaryStrong = Color(0xFF0AD89C);
  static const Color brandSecondaryBright = Color(0xFF5BFFD0);
  static Color brandSecondaryMuted = const Color(0xFF2BF5B4).withAlpha(61);
  static Color brandSecondarySubtle = const Color(0xFF2BF5B4).withAlpha(31);

  // Brand — tertiary (purple accent). Vibrant v1.2.
  static const Color brandTertiary = Color(0xFFC28FFF);
  static Color brandTertiaryMuted = const Color(0xFFC28FFF).withAlpha(61);
  static Color brandTertiarySubtle = const Color(0xFFC28FFF).withAlpha(31);

  // Signature gradient stops (blue → green CTA from gnus.ai). Vibrant v1.2.
  static const Color gradientBlue = Color(0xFF0AAEE6);
  static const Color gradientGreen = Color(0xFF0AD89C);

  // Surface — teal-blue canvas, lifted further in v1.2 for noticeably more pop,
  // with darker contained cards (gnus.ai layered look).
  static const Color surfaceBase = Color(0xFF2A6275); // page background (teal)
  static const Color surfaceElevated = Color(0xFF0C0E14); // card / contained
  static const Color surfaceMenu = Color(0xFF224C5E); // sheet / menu
  static const Color surfaceSunken = Color(0xFF06080C); // deepest layer
  static Color surfaceOverlay = const Color(0xFF000000).withAlpha(153); // 60%

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  // 80% white — minimum muted tint that still clears WCAG AA (4.5:1) on the
  // bright teal surfaceBase; use for secondary labels that sit on the page bg.
  static const Color textPrimary80 = Color(0xCCFFFFFF);
  static const Color textPrimary70 = Color(0xB3FFFFFF);
  static const Color textPrimary60 = Color(0x99FFFFFF);
  static const Color textPrimary54 = Color(0x8AFFFFFF);
  static const Color textPrimary38 = Color(0x62FFFFFF);
  static const Color textPrimary30 = Color(0x4DFFFFFF);
  static const Color textPrimary24 = Color(0x3DFFFFFF);
  static const Color textPrimary12 = Color(0x1FFFFFFF);
  static const Color textPrimary10 = Color(0x1AFFFFFF);
  static const Color textSecondary =
      Color(0xFF8A8F9D); // gnus.ai --muted-foreground
  static const Color textTertiary = Color.fromARGB(255, 53, 54, 61);
  static const Color textDisabled = Color(0xFF2A2B31);
  static const Color textOnBrand = Color(0xFF000B18);

  // Border
  static const Color borderSubtle = Color.fromRGBO(255, 255, 255, 0.12);
  static const Color borderStrong = Color.fromRGBO(255, 255, 255, 0.24);
  static const Color borderBrand = brandPrimary;

  // Status
  static const Color statusSuccess =
      Color(0xFF0AD89C); // mint-green from gradient (vibrant v1.2)
  static const Color statusError =
      Color(0xFFFF4D4D); // gnus.ai --destructive, vibrant v1.2
  static const Color statusWarning = Color(0xFFFFC42E);
  static const Color statusInfo = brandPrimary;

  // ---------------------------------------------------------------------------
  // Backwards-compatibility aliases — these now point to the new GNUS palette,
  // so existing widgets adopt the refreshed look without immediate refactors.
  // Prefer the semantic tokens above for new code.
  // ---------------------------------------------------------------------------

  // brandGreen → mint secondary (was Color.fromRGBO(0, 234, 174, 1))
  static const Color brandGreen = brandSecondary;
  static const Color brandGreenStrong = brandSecondaryStrong;
  static Color brandGreenMuted = brandSecondaryMuted;
  static Color brandGreenSubtle = brandSecondarySubtle;

  // ---------------------------------------------------------------------------
  // Legacy constants (do not use in new code — prefer semantic tokens above).
  // Values updated to align with the GNUS palette.
  // ---------------------------------------------------------------------------

  static const Color blue500 = brandPrimary;

  static const Color foundationWhite = Color(0xffffffff);

  static const Color foundationBlack = Color(0xff000000);

  static const Color gray900 = Color(0xff18191d);

  static const Color gray500 = textSecondary;

  static const Color darkGreen = Color(0xff7ac231);

  static const Color containerGray = surfaceMenu;

  static const Color gray600 = Color.fromARGB(255, 53, 54, 61);

  static const Color gray800 = Color(0xff2a2b31);

  static const Color red = statusError;

  static const Color cancelled = Color(0xff4A121C);

  static const Color completed = Color(0xff085D51);

  static const Color foundationError = Color(0xff920000);

  static const Color white = Color(0xffffffff);

  static const Color darkBlue500 = brandPrimaryStrong;

  static const Color successGreen = statusSuccess;

  static const Color deepBlue = surfaceBase;

  static const Color deepBlueSecondary = surfaceMenu;

  static const Color deepBlueTertiary = surfaceSunken;

  static const Color deepBlueCardColor = surfaceElevated;

  static const Color deepBlueMenu = surfaceMenu;

  static const Color lightGreenPrimary = brandSecondary;

  static const Color lightGreenSecondary = brandSecondaryStrong;

  static const Color grayPrimary = Color.fromRGBO(21, 30, 41, 1);

  static const Color btnText = textOnBrand;

  static const Color btnDisabled = Color.fromRGBO(188, 188, 188, 1);

  static const Color btnTextDisabled = Color.fromRGBO(101, 101, 101, 1);

  // Signature CTA gradient stops
  static const Color btnGradientBlue = gradientBlue;

  static const Color btnGradientGreen = gradientGreen;

  static const Color btnCopyBorder = Color.fromRGBO(255, 255, 255, 0.30);

  static const Color btnFilter = Color.fromARGB(255, 19, 33, 53);

  static Color btnFilterSelected = brandPrimary.withAlpha(26);

  static const Color rowFilterBlue = Color.fromARGB(255, 14, 25, 40);

  static const Color borderGrey = Color.fromRGBO(255, 255, 255, 0.30);

  static const Color currencyBackground = Color(0xff0050b7);
  static const Color mutedGreen = Color(0xFF2EBE7B);

  static const Color mutedRed = Color(0xFFE57373);
}
