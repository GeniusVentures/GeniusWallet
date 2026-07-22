import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

class GeniusWalletColors {
  static const Color lightGreenPrimary = Colors.greenAccent;
  static const Color lightGreenSecondary = Color(0xFF54C48E);
  static const Color mutedGreen = Color(0xFF2EBE7B);

  static const Color deepBlueTertiary = Color(0xff05090F);
  static const Color deepBlueCardColor = Color.fromRGBO(10, 18, 31, 1);
  static const Color deepBlueMenu = Color(0xff0F1B2E);
  static const Color deepBlue = Color.fromRGBO(20, 37, 61, 1);
  static const Color grayPrimary = Color.fromRGBO(21, 30, 41, 1);

  static const Color btnText = Color.fromRGBO(0, 9, 20, 1);
  // Added in Phase 3 plan 03-04: continue_button/isactive_false.g.dart
  // (DS-02) references GeniusWalletColors.btnDisabled, which Phase 2's port
  // of this file omitted. Ported verbatim from the reference worktree's
  // value at the equivalent position (between btnText and btnTextDisabled).
  static const Color btnDisabled = Color.fromRGBO(188, 188, 188, 1);
  static const Color btnTextDisabled = Color.fromRGBO(101, 101, 101, 1);

  static const Color foundationError = Color(0xff920000);

  static const Color btnGradientBlue = Color.fromRGBO(0, 104, 239, 1);
  static const Color btnGradientGreen = Color.fromRGBO(1, 221, 166, 1);
  // Appearance-aware: app-wide root fix for bare-TextButton light-mode
  // legibility. theme.dart:258 is the sole consumer (textButtonTheme
  // .backgroundColor); every bare TextButton flips via this single getter.
  static Color get btnFilter =>
      _isLight ? const Color(0xFFEFF2F6) : const Color.fromARGB(255, 19, 33, 53);
  static Color btnFilterSelected = lightGreenPrimary.withValues(alpha: 0.1);
  static const Color borderGrey = Color.fromRGBO(255, 255, 255, 0.30);

  // ---------------------------------------------------------------------------
  // GNUS brand palette — aligned with the marketing site (gnus.ai).
  // Primary: cyan. Secondary: mint. Tertiary: purple. Use these tokens for
  // new code; legacy names below are remapped onto the new palette.
  //
  // Appearance: the neutral stack (surfaces, primary text ladder, hairlines)
  // is mode-aware — dark = true-black canvas, light = white canvas — driven by
  // GWAppearance (Preferences ▸ Appearance). Brand + status colours are fixed.
  // ---------------------------------------------------------------------------

  static bool get _isLight => GWAppearance.isLight;

  // Brand — primary (cyan/blue). Vibrant v1.2 — electric. See DESIGN_SYSTEM.md note 2026-05.
  static const Color brandPrimary = Color(0xFF14C8FF);
  static const Color brandPrimaryStrong = Color(0xFF0AAEE6);
  static Color brandPrimaryMuted =
      const Color(0xFF14C8FF).withAlpha(61); // ~24%
  static Color brandPrimarySubtle =
      const Color(0xFF14C8FF).withAlpha(31); // ~12%

  // Brand colour for content painted ON a surface -- foreground text,
  // outlines, focus rings, indicators -- as distinct from
  // `brandPrimaryStrong`, which is the brand FILL. Appearance-aware:
  // - light `#0A6885`: 6.30:1 on surfaceElevated, 5.61:1 on surfaceMenu,
  //   4.76:1 on surfaceBase. A deliberate darkening of `#0B6E8F` (the
  //   Connect-chip value this replaces): `#0B6E8F` measures only 4.35:1 on
  //   surfaceBase and misses AA text (4.5:1).
  // - dark `brandPrimaryStrong` (`#0AAEE6`): 7.54:1 on surfaceElevated,
  //   6.81:1 on surfaceMenu, 7.60:1 on surfaceBase.
  // ponytail: on light's surfaceSunken (`#CFD4DB`) this is 4.23:1 -- clears
  // the 3:1 non-text floor but not 4.5:1 body text. Ceiling: no current
  // consumer paints body text on surfaceSunken. Upgrade path: a second,
  // darker step if a body-text consumer on surfaceSunken ever appears.
  static const Color _brandPrimaryOnSurfaceLight = Color(0xFF0A6885);
  static Color get brandPrimaryOnSurface =>
      _isLight ? _brandPrimaryOnSurfaceLight : brandPrimaryStrong;

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

  // ---------------------------------------------------------------------------
  // Surfaces — appearance-aware. Dark: a true-black canvas with near-black
  // contained cards (hairlines + sheen do the separation). Light: a white
  // canvas with white cards on a faintly washed page.
  // ---------------------------------------------------------------------------

  static const Color _surfaceBaseDark = Color(0xFF0B0D12);
  // ≈15% gray so white cards separate from the page (user-tuned).
  static const Color _surfaceBaseLight = Color(0xFFDCE0E6);

  /// Page background.
  static Color get surfaceBase =>
      _isLight ? _surfaceBaseLight : _surfaceBaseDark;

  static const Color _surfaceElevatedDark = Color(0xFF0C0E14);
  static const Color _surfaceElevatedLight = Color(0xFFFFFFFF);

  /// Card / contained surface.
  static Color get surfaceElevated =>
      _isLight ? _surfaceElevatedLight : _surfaceElevatedDark;

  static const Color _surfaceMenuDark = Color(0xFF171A21);
  static const Color _surfaceMenuLight = Color(0xFFEFF2F6);

  /// Sheet / menu surface.
  static Color get surfaceMenu =>
      _isLight ? _surfaceMenuLight : _surfaceMenuDark;

  static const Color _surfaceSunkenDark = Color(0xFF06080C);
  static const Color _surfaceSunkenLight = Color(0xFFCFD4DB);

  /// Deepest layer.
  static Color get surfaceSunken =>
      _isLight ? _surfaceSunkenLight : _surfaceSunkenDark;

  static Color surfaceOverlay = const Color(0xFF000000).withAlpha(153); // 60%

  // ---------------------------------------------------------------------------
  // Text — the primary ladder is appearance-aware (white on dark, ink on
  // light) with identical alpha steps. textSecondary is a mid-gray that holds
  // on both canvases.
  // ---------------------------------------------------------------------------

  static const Color _inkLight = Color(0xFF10131A);

  static Color get textPrimary => _isLight ? _inkLight : Colors.white;
  // 80% — minimum muted tint that still clears WCAG AA (4.5:1) on the page
  // canvas; use for secondary labels that sit on the page bg.
  static Color get textPrimary80 =>
      _isLight ? const Color(0xCC10131A) : const Color(0xCCFFFFFF);
  static Color get textPrimary70 =>
      _isLight ? const Color(0xB310131A) : const Color(0xB3FFFFFF);
  static Color get textPrimary60 =>
      _isLight ? const Color(0x9910131A) : const Color(0x99FFFFFF);
  static Color get textPrimary54 =>
      _isLight ? const Color(0x8A10131A) : const Color(0x8AFFFFFF);
  static Color get textPrimary38 =>
      _isLight ? const Color(0x6210131A) : const Color(0x62FFFFFF);
  static Color get textPrimary30 =>
      _isLight ? const Color(0x4D10131A) : const Color(0x4DFFFFFF);
  static Color get textPrimary24 =>
      _isLight ? const Color(0x3D10131A) : const Color(0x3DFFFFFF);
  static Color get textPrimary12 =>
      _isLight ? const Color(0x1F10131A) : const Color(0x1FFFFFFF);
  static Color get textPrimary10 =>
      _isLight ? const Color(0x1A10131A) : const Color(0x1AFFFFFF);
  static const Color textSecondary =
      Color(0xFF8A8F9D); // gnus.ai --muted-foreground
  // Alias used by ported components (e.g. sgnus_wallet.dart) that reference
  // the reference worktree's gray-scale naming instead of the semantic name.
  static const Color gray500 = textSecondary;
  static const Color textTertiary = Color.fromARGB(255, 53, 54, 61);
  static const Color textDisabled = Color(0xFF2A2B31);
  static const Color textOnBrand = Color(0xFF000B18);

  // Border — hairlines flip with the canvas (white-based on dark, ink-based
  // on light).
  static Color get borderSubtle => _isLight
      ? const Color.fromRGBO(16, 19, 26, 0.12)
      : const Color.fromRGBO(255, 255, 255, 0.12);
  static Color get borderStrong => _isLight
      ? const Color.fromRGBO(16, 19, 26, 0.24)
      : const Color.fromRGBO(255, 255, 255, 0.24);
  static const Color borderBrand = brandPrimary;

  // Status
  static const Color statusSuccess =
      Color(0xFF0AD89C); // mint-green from gradient (vibrant v1.2)
  static const Color statusError =
      Color(0xFFFF4D4D); // gnus.ai --destructive, vibrant v1.2
  static const Color statusWarning = Color(0xFFFFC42E);
  // Slate — the transaction-badge fill sketch 012 picked for Sent and Escrow.
  // WHY a new token rather than reuse: amber already means Pending and red
  // already means Failed, so painting a *successful* send in either would make
  // a completed transaction read as a problem. Slate is the deliberate
  // "nothing is wrong here, this is just an outbound movement" neutral.
  //
  // ponytail: FILL ONLY — never use this as a text/foreground colour. It is
  // mode-invariant and deliberately NOT added to the GWColors extension,
  // because the badge's GLYPH colour is computed from the fill
  // (badgeGlyphColor in dashboard/home/widgets/transaction_badge.dart), so the
  // pair stays AA-correct in both appearances without a second hand-maintained
  // appearance-aware token. Ceiling: as a fill on the light canvas it is only
  // 2.6:1 against white, which is fine for a filled shape but would fail AA as
  // text. Upgrade path: promote to GWColors with a per-appearance value if a
  // text consumer ever appears.
  static const Color statusNeutral = Color(0xFF64748B);
  static const Color statusInfo = brandPrimary;

  // ---------------------------------------------------------------------------
  // Backwards-compatibility aliases — new names only (no develop token is
  // reassigned here). Added in Phase 3 because gw_loading_state.dart and the
  // loading/loading.dart shadow file (both DS-02) reference brandGreen, which
  // Phase 2 did not port. Ported verbatim from the reference worktree's own
  // "Backwards-compatibility aliases" block (genius_wallet_colors.dart).
  // ---------------------------------------------------------------------------

  // brandGreen → mint secondary (was Color.fromRGBO(0, 234, 174, 1))
  static const Color brandGreen = brandSecondary;
  static const Color brandGreenStrong = brandSecondaryStrong;
  static Color brandGreenMuted = brandSecondaryMuted;
  static Color brandGreenSubtle = brandSecondarySubtle;
}
