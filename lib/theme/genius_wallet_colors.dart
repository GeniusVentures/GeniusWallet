part of 'gw_colors.dart';

/// The raw colour PRIMITIVE layer -- demoted from a standalone public
/// library to a `part` of `gw_colors.dart` (23-04-PLAN.md Task 2). A `part`
/// file shares its enclosing library's imports (`gw_colors.dart` already
/// imports `package:flutter/material.dart` and `gw_appearance.dart`, both
/// this file needs) and cannot declare its own. Every field/getter below
/// that was PUBLIC is now underscore-prefixed: the compiler, not a naming
/// convention, is what makes it unreachable from any file outside this
/// library. `GWColors` is the one supported way to read a colour from
/// outside `lib/theme/`; the two static exceptions on `GWColors`
/// (`statusNeutral`, `fixedStatusError`, `fixedTextSecondary`) are the sole,
/// deliberately narrow, named carve-outs -- see their own doc comments.
class GeniusWalletColors {
  static const Color _lightGreenPrimary = Colors.greenAccent;
  static const Color _lightGreenSecondary = Color(0xFF54C48E);
  static const Color _mutedGreen = Color(0xFF2EBE7B);

  static const Color _deepBlueTertiary = Color(0xff05090F);
  static const Color _deepBlueCardColor = Color.fromRGBO(10, 18, 31, 1);
  static const Color _deepBlueMenu = Color(0xff0F1B2E);
  static const Color _deepBlue = Color.fromRGBO(20, 37, 61, 1);
  static const Color _grayPrimary = Color.fromRGBO(21, 30, 41, 1);

  static const Color _btnText = Color.fromRGBO(0, 9, 20, 1);
  // Added in Phase 3 plan 03-04: continue_button/isactive_false.g.dart
  // (DS-02) referenced this field (public at the time, as btnDisabled),
  // which Phase 2's port of this file omitted. Ported verbatim from the
  // reference worktree's value at the equivalent position (between
  // _btnText and _btnTextDisabled). 23-04 demoted the field to private; its
  // one former outside-lib/theme consumer was migrated in 23-02.
  static const Color _btnDisabled = Color.fromRGBO(188, 188, 188, 1);
  static const Color _btnTextDisabled = Color.fromRGBO(101, 101, 101, 1);

  static const Color _foundationError = Color(0xff920000);

  static const Color _btnGradientBlue = Color.fromRGBO(0, 104, 239, 1);
  static const Color _btnGradientGreen = Color.fromRGBO(1, 221, 166, 1);
  // Appearance-aware: app-wide root fix for bare-TextButton light-mode
  // legibility. theme.dart:258 is the sole consumer (textButtonTheme
  // .backgroundColor); every bare TextButton flips via this single getter.
  static Color get _btnFilter => _isLight
      ? const Color(0xFFEFF2F6)
      : const Color.fromARGB(255, 19, 33, 53);
  static final Color _btnFilterSelected = _lightGreenPrimary.withValues(
    alpha: 0.1,
  );
  static const Color _borderGrey = Color.fromRGBO(255, 255, 255, 0.30);

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
  static const Color _brandPrimary = Color(0xFF14C8FF);
  static const Color _brandPrimaryStrong = Color(0xFF0AAEE6);
  static final Color _brandPrimaryMuted = const Color(
    0xFF14C8FF,
  ).withAlpha(61); // ~24%
  static final Color _brandPrimarySubtle = const Color(
    0xFF14C8FF,
  ).withAlpha(31); // ~12%

  // Brand colour for content painted ON a surface -- foreground text,
  // outlines, focus rings, indicators -- as distinct from
  // `_brandPrimaryStrong`, which is the brand FILL. Appearance-aware:
  // - light `#0A6885`: 6.30:1 on _surfaceElevated, 5.61:1 on _surfaceMenu,
  //   4.76:1 on _surfaceBase. A deliberate darkening of `#0B6E8F` (the
  //   Connect-chip value this replaces): `#0B6E8F` measures only 4.35:1 on
  //   _surfaceBase and misses AA text (4.5:1).
  // - dark `_brandPrimaryStrong` (`#0AAEE6`): 7.54:1 on _surfaceElevated,
  //   6.81:1 on _surfaceMenu, 7.60:1 on _surfaceBase.
  // ponytail: on light's _surfaceSunken (`#CFD4DB`) this is 4.23:1 -- clears
  // the 3:1 non-text floor but not 4.5:1 body text. Ceiling: no current
  // consumer paints body text on _surfaceSunken. Upgrade path: a second,
  // darker step if a body-text consumer on _surfaceSunken ever appears.
  static const Color _brandPrimaryOnSurfaceLight = Color(0xFF0A6885);
  static Color get _brandPrimaryOnSurface =>
      _isLight ? _brandPrimaryOnSurfaceLight : _brandPrimaryStrong;

  // Brand — secondary (mint/green). Vibrant v1.2 — electric.
  static const Color _brandSecondary = Color(0xFF2BF5B4);
  static const Color _brandSecondaryStrong = Color(0xFF0AD89C);
  static const Color _brandSecondaryBright = Color(0xFF5BFFD0);
  static final Color _brandSecondaryMuted = const Color(
    0xFF2BF5B4,
  ).withAlpha(61);
  static final Color _brandSecondarySubtle = const Color(
    0xFF2BF5B4,
  ).withAlpha(31);

  // Brand — tertiary (purple accent). Vibrant v1.2.
  static const Color _brandTertiary = Color(0xFFC28FFF);
  static final Color _brandTertiaryMuted = const Color(
    0xFFC28FFF,
  ).withAlpha(61);
  static final Color _brandTertiarySubtle = const Color(
    0xFFC28FFF,
  ).withAlpha(31);

  // Signature gradient stops (blue → green CTA from gnus.ai). Vibrant v1.2.
  static const Color _gradientBlue = Color(0xFF0AAEE6);
  static const Color _gradientGreen = Color(0xFF0AD89C);

  // ---------------------------------------------------------------------------
  // Surfaces — appearance-aware. Dark: a true-black canvas with near-black
  // contained cards (hairlines + sheen do the separation). Light: a white
  // canvas with white cards on a faintly washed page.
  // ---------------------------------------------------------------------------

  static const Color _surfaceBaseDark = Color(0xFF0B0D12);
  // ≈15% gray so white cards separate from the page (user-tuned).
  static const Color _surfaceBaseLight = Color(0xFFDCE0E6);

  /// Page background.
  static Color get _surfaceBase =>
      _isLight ? _surfaceBaseLight : _surfaceBaseDark;

  static const Color _surfaceElevatedDark = Color(0xFF0C0E14);
  static const Color _surfaceElevatedLight = Color(0xFFFFFFFF);

  /// Card / contained surface.
  static Color get _surfaceElevated =>
      _isLight ? _surfaceElevatedLight : _surfaceElevatedDark;

  static const Color _surfaceMenuDark = Color(0xFF171A21);
  static const Color _surfaceMenuLight = Color(0xFFEFF2F6);

  /// Sheet / menu surface.
  static Color get _surfaceMenu =>
      _isLight ? _surfaceMenuLight : _surfaceMenuDark;

  static const Color _surfaceSunkenDark = Color(0xFF06080C);
  static const Color _surfaceSunkenLight = Color(0xFFCFD4DB);

  /// Deepest layer.
  static Color get _surfaceSunken =>
      _isLight ? _surfaceSunkenLight : _surfaceSunkenDark;

  static final Color _surfaceOverlay = const Color(
    0xFF000000,
  ).withAlpha(153); // 60%

  // ---------------------------------------------------------------------------
  // Text — the primary ladder is appearance-aware (white on dark, ink on
  // light) with identical alpha steps. _textSecondary is a mid-gray that holds
  // on both canvases.
  // ---------------------------------------------------------------------------

  static const Color _inkLight = Color(0xFF10131A);

  static Color get _textPrimary => _isLight ? _inkLight : Colors.white;
  // 80% — minimum muted tint that still clears WCAG AA (4.5:1) on the page
  // canvas; use for secondary labels that sit on the page bg.
  static Color get _textPrimary80 =>
      _isLight ? const Color(0xCC10131A) : const Color(0xCCFFFFFF);
  static Color get _textPrimary70 =>
      _isLight ? const Color(0xB310131A) : const Color(0xB3FFFFFF);
  static Color get _textPrimary60 =>
      _isLight ? const Color(0x9910131A) : const Color(0x99FFFFFF);
  static Color get _textPrimary54 =>
      _isLight ? const Color(0x8A10131A) : const Color(0x8AFFFFFF);
  static Color get _textPrimary38 =>
      _isLight ? const Color(0x6210131A) : const Color(0x62FFFFFF);
  static Color get _textPrimary30 =>
      _isLight ? const Color(0x4D10131A) : const Color(0x4DFFFFFF);
  static Color get _textPrimary24 =>
      _isLight ? const Color(0x3D10131A) : const Color(0x3DFFFFFF);
  static Color get _textPrimary12 =>
      _isLight ? const Color(0x1F10131A) : const Color(0x1FFFFFFF);
  static Color get _textPrimary10 =>
      _isLight ? const Color(0x1A10131A) : const Color(0x1AFFFFFF);
  static const Color _textSecondary = Color(
    0xFF8A8F9D,
  ); // gnus.ai --muted-foreground
  // Alias used by ported components (e.g. sgnus_wallet.dart) that reference
  // the reference worktree's gray-scale naming instead of the semantic name.
  static const Color _gray500 = _textSecondary;
  static const Color _textTertiary = Color.fromARGB(255, 53, 54, 61);
  static const Color _textDisabled = Color(0xFF2A2B31);
  static const Color _textOnBrand = Color(0xFF000B18);

  // Border — hairlines flip with the canvas (white-based on dark, ink-based
  // on light).
  static Color get _borderSubtle => _isLight
      ? const Color.fromRGBO(16, 19, 26, 0.12)
      : const Color.fromRGBO(255, 255, 255, 0.12);
  static Color get _borderStrong => _isLight
      ? const Color.fromRGBO(16, 19, 26, 0.24)
      : const Color.fromRGBO(255, 255, 255, 0.24);

  /// The edge of a CONTROL whose fill cannot identify it -- an input on a
  /// drawer panel, where fill and panel are two dark values 1.11:1 apart.
  ///
  /// WHY a third border token rather than [_borderStrong]: WCAG 1.4.11 asks for
  /// 3:1 from anything that identifies a UI component, and when the boundary is
  /// the ONLY identifier it has to carry that alone. Measured on the 156-A
  /// drawer canvas (`_surfaceElevated` #0C0E14), compositing the hairline over
  /// the panel it sits on:
  ///
  /// | edge | contrast |
  /// |---|---|
  /// | `_borderSubtle` white 12% | 1.36:1 |
  /// | `_borderStrong` white 24% | 2.11:1 |
  /// | white 30% (sketch 156's first proposal) | 2.64:1 |
  /// | **white 36%** | **3.30:1** ✓ |
  ///
  /// 36 is not a round number chosen for looks -- it is the first step that
  /// clears 3:1, and sketch 067's contrast table arrives at the same value
  /// independently. Light mode takes ink at 46% for the same reason: the light
  /// panel is pure white, and 3:1 on white lands at ~#919397.
  ///
  /// ponytail: this is the CONTROL edge, not a general "strong hairline".
  /// Decorative separators stay on [_borderSubtle] -- a rule that carries no
  /// information has no 1.4.11 threshold to meet, and painting every hairline
  /// at 36% would make the app a wireframe.
  static Color get _borderControl => _isLight
      ? const Color.fromRGBO(16, 19, 26, 0.46)
      : const Color.fromRGBO(255, 255, 255, 0.36);
  static const Color _borderBrand = _brandPrimary;

  // Status
  //
  // 23-04: the ORIGINAL public `statusSuccess` field was deleted here -- once
  // demoted to private, `flutter analyze` proved it had zero references
  // anywhere in the app (GWColors.light()/.dark() both hardcode their own
  // AA-adjusted literals for statusSuccess directly and never read this
  // field, unlike statusError/textSecondary below, which DO still have a
  // live consumer needing the untouched original -- see GWColors
  // .fixedStatusError). "A private member nobody reads is dead code, and
  // this is the first moment the compiler can prove it" (23-04-PLAN.md).
  static const Color _statusError = Color(
    0xFFFF4D4D,
  ); // gnus.ai --destructive, vibrant v1.2
  static const Color _statusWarning = Color(0xFFFFC42E);
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
  static const Color _statusNeutral = Color(0xFF64748B);
  static const Color _statusInfo = _brandPrimary;

  // ---------------------------------------------------------------------------
  // Backwards-compatibility aliases — new names only (no develop token is
  // reassigned here). Added in Phase 3 because gw_loading_state.dart and the
  // loading/loading.dart shadow file (both DS-02) reference _brandGreen, which
  // Phase 2 did not port. Ported verbatim from the reference worktree's own
  // "Backwards-compatibility aliases" block (genius_wallet_colors.dart).
  // ---------------------------------------------------------------------------

  // _brandGreen → mint secondary (was Color.fromRGBO(0, 234, 174, 1))
  static const Color _brandGreen = _brandSecondary;
  static const Color _brandGreenStrong = _brandSecondaryStrong;
  static final Color _brandGreenMuted = _brandSecondaryMuted;
  static final Color _brandGreenSubtle = _brandSecondarySubtle;
}
