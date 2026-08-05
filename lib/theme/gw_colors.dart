import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

part 'genius_wallet_colors.dart';

/// Appearance-aware color tokens as a [ThemeExtension], mirroring the
/// appearance-aware STATIC GETTERS on [GeniusWalletColors] (surfaces, the
/// primary text ladder, textSecondary, borderSubtle/borderStrong).
///
/// WHY THIS EXISTS (see .planning/todos/pending/2026-07-18-const-widgets-do-
/// not-re-skin-on-live-appearance-toggle.md): `GeniusWalletColors` is not an
/// `InheritedWidget`, so `const` widgets that read its static getters never
/// rebuild on a live appearance toggle -- `Element.updateChild` short-circuits
/// on `identical` const children before `build()` re-runs. `Theme` IS an
/// `InheritedWidget`; a component that reads
/// `Theme.of(context).extension<GWColors>()` registers a dependency that
/// forces even a `const` widget to rebuild when the theme changes.
///
/// This is a PURE ACCESS-PATH migration: every field value here is copied
/// VERBATIM from the matching mode branch of the corresponding
/// `GeniusWalletColors` getter/constant. `GeniusWalletColors` remains the
/// single source of truth and stays in place (no big-bang removal) --
/// unmigrated call sites keep working exactly as before.
///
/// 23-01 EXTENDS this class to full name parity with the legacy palette --
/// see `.planning/phases/23-.../23-01-TOKEN-MAP.md` for the complete
/// mapping, including the one deliberate exclusion (`statusNeutral`, which
/// carries its own pre-existing "do not add" note in
/// `genius_wallet_colors.dart`). Name parity (not renaming) is the point: it
/// turns 23-02's 260+ call-site migration into a mechanical prefix rewrite.
///
/// 23-04 DEMOTES `GeniusWalletColors` from a standalone public class to a
/// `part` of this file, with every formerly-public field/getter
/// underscore-prefixed -- the primitive layer this class mirrors is no
/// longer independently importable or readable from outside `lib/theme/`;
/// this class is now the ONLY supported way to read a colour from anywhere
/// else in the app. See `genius_wallet_colors.dart`'s own header comment.
@immutable
class GWColors extends ThemeExtension<GWColors> {
  const GWColors({
    required this.surfaceBase,
    required this.surfaceElevated,
    required this.surfaceMenu,
    required this.surfaceSunken,
    required this.surfaceOverlay,
    required this.textPrimary,
    required this.textPrimary80,
    required this.textPrimary70,
    required this.textPrimary60,
    required this.textPrimary54,
    required this.textPrimary38,
    required this.textPrimary30,
    required this.textPrimary24,
    required this.textPrimary12,
    required this.textPrimary10,
    required this.textSecondary,
    required this.statusSuccess,
    required this.statusError,
    required this.borderSubtle,
    required this.borderStrong,
    required this.borderControl,
    // -- 23-01 additions below: full name parity with GeniusWalletColors --
    required this.lightGreenPrimary,
    required this.lightGreenSecondary,
    required this.mutedGreen,
    required this.deepBlueTertiary,
    required this.deepBlueCardColor,
    required this.deepBlueMenu,
    required this.deepBlue,
    required this.grayPrimary,
    required this.btnText,
    required this.btnDisabled,
    required this.btnTextDisabled,
    required this.btnGradientBlue,
    required this.btnGradientGreen,
    required this.btnFilter,
    required this.btnFilterSelected,
    required this.foundationError,
    required this.borderGrey,
    required this.brandPrimary,
    required this.brandPrimaryStrong,
    required this.brandPrimaryMuted,
    required this.brandPrimarySubtle,
    required this.brandPrimaryOnSurface,
    required this.brandSecondary,
    required this.brandSecondaryStrong,
    required this.brandSecondaryBright,
    required this.brandSecondaryMuted,
    required this.brandSecondarySubtle,
    required this.brandTertiary,
    required this.brandTertiaryMuted,
    required this.brandTertiarySubtle,
    required this.gradientBlue,
    required this.gradientGreen,
    required this.gray500,
    required this.textTertiary,
    required this.textDisabled,
    required this.textOnBrand,
    required this.borderBrand,
    required this.statusWarning,
    required this.statusWarningText,
    required this.textMutedOnSunken,
    required this.statusInfo,
    required this.brandGreen,
    required this.brandGreenStrong,
    required this.brandGreenMuted,
    required this.brandGreenSubtle,
  });

  final Color surfaceBase;
  final Color surfaceElevated;
  final Color surfaceMenu;
  final Color surfaceSunken;
  final Color surfaceOverlay;

  final Color textPrimary;
  final Color textPrimary80;
  final Color textPrimary70;
  final Color textPrimary60;
  final Color textPrimary54;
  final Color textPrimary38;
  final Color textPrimary30;
  final Color textPrimary24;
  final Color textPrimary12;
  final Color textPrimary10;

  final Color textSecondary;

  // ponytail: statusSuccess/statusError (and light-mode textSecondary) live
  // ONLY here as appearance-aware tokens; the source constants
  // GeniusWalletColors._textSecondary/statusSuccess/statusError stay
  // mode-invariant for their non-migrated consumers. Ceiling: those call
  // sites still fail WCAG AA in light mode. Upgrade path: a dedicated token
  // pass that converts the source getters appearance-aware (or migrates those
  // consumers to gw.*), after which these literals fold back into the source.
  final Color statusSuccess;
  final Color statusError;

  final Color borderSubtle;
  final Color borderStrong;

  /// The 3:1 edge for a control whose fill cannot identify it -- see
  /// [GeniusWalletColors._borderControl] for the measurements.
  final Color borderControl;

  // ---------------------------------------------------------------------
  // 23-01 additions -- full name parity with GeniusWalletColors. Every
  // field below is spelled identically to its legacy counterpart (see the
  // token map) so 23-02's call-site rewrite is a pure prefix change.
  // ---------------------------------------------------------------------

  final Color lightGreenPrimary;
  final Color lightGreenSecondary;
  final Color mutedGreen;

  final Color deepBlueTertiary;
  final Color deepBlueCardColor;
  final Color deepBlueMenu;
  final Color deepBlue;
  final Color grayPrimary;

  final Color btnText;
  final Color btnDisabled;
  final Color btnTextDisabled;
  final Color btnGradientBlue;
  final Color btnGradientGreen;

  /// Appearance-aware: app-wide root fix for bare-TextButton light-mode
  /// legibility. `theme.dart`'s `textButtonTheme.backgroundColor` is the
  /// sole consumer of the legacy getter this mirrors; every bare TextButton
  /// flips via this single token.
  final Color btnFilter;
  final Color btnFilterSelected;

  final Color foundationError;
  final Color borderGrey;

  // Brand -- primary (cyan/blue). Vibrant v1.2 -- electric.
  final Color brandPrimary;
  final Color brandPrimaryStrong;
  final Color brandPrimaryMuted;
  final Color brandPrimarySubtle;

  /// Brand colour for content painted ON a surface -- foreground text,
  /// outlines, focus rings, indicators -- as distinct from
  /// [brandPrimaryStrong], which is the brand FILL. Appearance-aware:
  /// - light `#0A6885`: 6.30:1 on surfaceElevated, 5.61:1 on surfaceMenu,
  ///   4.76:1 on surfaceBase. A deliberate darkening of `#0B6E8F` (the
  ///   Connect-chip value this replaces): `#0B6E8F` measures only 4.35:1 on
  ///   surfaceBase and misses AA text (4.5:1).
  /// - dark [brandPrimaryStrong] (`#0AAEE6`): 7.54:1 on surfaceElevated,
  ///   6.81:1 on surfaceMenu, 7.60:1 on surfaceBase.
  /// ponytail: on light's surfaceSunken (`#CFD4DB`) this is 4.23:1 -- clears
  /// the 3:1 non-text floor but not 4.5:1 body text. Ceiling: no current
  /// consumer paints body text on surfaceSunken. Upgrade path: a second,
  /// darker step if a body-text consumer on surfaceSunken ever appears.
  final Color brandPrimaryOnSurface;

  // Brand -- secondary (mint/green). Vibrant v1.2 -- electric.
  final Color brandSecondary;
  final Color brandSecondaryStrong;
  final Color brandSecondaryBright;
  final Color brandSecondaryMuted;
  final Color brandSecondarySubtle;

  // Brand -- tertiary (purple accent). Vibrant v1.2.
  final Color brandTertiary;
  final Color brandTertiaryMuted;
  final Color brandTertiarySubtle;

  // Signature gradient stops (blue -> green CTA from gnus.ai). Vibrant v1.2.
  final Color gradientBlue;
  final Color gradientGreen;

  /// Alias used by ported components (e.g. sgnus_wallet.dart) that reference
  /// the reference worktree's gray-scale naming instead of the semantic name.
  /// Same value as [textSecondary]'s mode-invariant legacy source, not the
  /// AA-adjusted light-mode divergence above -- see the token map.
  final Color gray500;
  final Color textTertiary;
  final Color textDisabled;
  final Color textOnBrand;

  final Color borderBrand;

  final Color statusWarning;

  /// The AA-safe FOREGROUND partner to [statusWarning] — for a warning icon,
  /// border or label, never for a fill.
  ///
  /// [statusWarning] (#FFC42E) is FILL-tuned: ~13:1 on the dark canvas but
  /// **~1.6:1 on white**, so as a foreground on a light surface it is simply
  /// not there. It cannot be given a divergent light value the way
  /// [statusSuccess]/[statusError] were, because it IS still used as a fill —
  /// `order_status_style.dart` and `transaction_badge.dart` both paint with
  /// it, and darkening it would darken those fills. Hence a second, explicitly
  /// foreground-purposed token rather than a divergent value on the first.
  ///
  /// Light is the darkened amber `#92400E` (7.09:1 on `surfaceElevated`
  /// #FFFFFF) that `crypto_address_qr.dart` originally worked out by hand;
  /// dark keeps [statusWarning] itself. Introduced by 23-03 follow-up after
  /// that literal had been hand-copied into four separate files, which is the
  /// duplication 23-01 warned about and 23-04's raw-colour gate would trip on.
  final Color statusWarningText;

  /// Muted label text painted DIRECTLY on [surfaceSunken] -- the control-track
  /// well. Every `GWControlTrack` consumer paints its UNSELECTED chip label
  /// here (selected chips sit on an opaque brand gradient and are unaffected).
  ///
  /// Exists because [textSecondary] is calibrated against the page and card
  /// canvases (6.3:1 there) and NOT against [surfaceSunken], the darkest gray
  /// step: on light's `#CFD4DB` it measures **4.23:1**, under the 4.5:1 body
  /// floor. The chip label is 12px `w600`, and WCAG large text starts at
  /// 18.66px bold, so the 3:1 large-text allowance does not apply.
  ///
  /// Light is `#4A5060` (5.41:1 on `surfaceSunken` #CFD4DB); dark keeps
  /// [textSecondary]'s own value, which already clears 6.20:1 on the near-black
  /// sunken step. Same shape as [statusWarningText]: a foreground-purposed
  /// token rather than a divergent value on the surface token, so the four
  /// tracks stay conformant instead of one of them picking a one-off.
  final Color textMutedOnSunken;

  final Color statusInfo;

  // Backwards-compatibility aliases -- see genius_wallet_colors.dart's own
  // "Backwards-compatibility aliases" block: gw_loading_state.dart and the
  // loading/loading.dart shadow file reference brandGreen*, ported verbatim
  // from the reference worktree.
  final Color brandGreen;
  final Color brandGreenStrong;
  final Color brandGreenMuted;
  final Color brandGreenSubtle;

  /// Light-mode instance. Every field is copied verbatim from the LIGHT
  /// branch of the matching `GeniusWalletColors` getter/constant.
  ///
  /// MACHINE VALUE-PRESERVATION CHECK: a one-alpha-step transcription slip
  /// across this ~60-field copy is invisible to the eye and to `flutter
  /// analyze`. This assert is MODE-GATED -- it only enforces when the global
  /// appearance is actually light (i.e. this is the branch getThemeData()
  /// picks), so it does not fire for the fail-soft `?? GWColors.dark()`
  /// fallback that consumers may construct while the app is in dark mode.
  /// Strips in release; zero-cost in production.
  factory GWColors.light() {
    final instance = GWColors(
      surfaceBase: GeniusWalletColors._surfaceBase,
      surfaceElevated: GeniusWalletColors._surfaceElevated,
      surfaceMenu: GeniusWalletColors._surfaceMenu,
      surfaceSunken: GeniusWalletColors._surfaceSunken,
      surfaceOverlay: GeniusWalletColors._surfaceOverlay,
      textPrimary: GeniusWalletColors._textPrimary,
      textPrimary80: GeniusWalletColors._textPrimary80,
      textPrimary70: GeniusWalletColors._textPrimary70,
      textPrimary60: GeniusWalletColors._textPrimary60,
      textPrimary54: GeniusWalletColors._textPrimary54,
      textPrimary38: GeniusWalletColors._textPrimary38,
      textPrimary30: GeniusWalletColors._textPrimary30,
      textPrimary24: GeniusWalletColors._textPrimary24,
      textPrimary12: GeniusWalletColors._textPrimary12,
      textPrimary10: GeniusWalletColors._textPrimary10,
      // AA fix: light-mode textSecondary deliberately diverges from the
      // mode-invariant GeniusWalletColors._textSecondary (3.0:1 X) to 6.3:1.
      textSecondary: const Color(0xFF5A606E),
      statusSuccess: const Color(0xFF07875F), // 4.5:1 on white
      statusError: const Color(0xFFD92D2D), // 4.8:1 on white
      borderSubtle: GeniusWalletColors._borderSubtle,
      borderStrong: GeniusWalletColors._borderStrong,
      borderControl: GeniusWalletColors._borderControl,
      // 23-01 additions -- fixed tokens read the same const/getter in both
      // modes; appearance-aware ones (btnFilter, brandPrimaryOnSurface) read
      // through the legacy getter, which resolves for whichever mode is
      // active when this factory runs -- identical pattern to the 21
      // pre-existing fields above.
      lightGreenPrimary: GeniusWalletColors._lightGreenPrimary,
      lightGreenSecondary: GeniusWalletColors._lightGreenSecondary,
      mutedGreen: GeniusWalletColors._mutedGreen,
      deepBlueTertiary: GeniusWalletColors._deepBlueTertiary,
      deepBlueCardColor: GeniusWalletColors._deepBlueCardColor,
      deepBlueMenu: GeniusWalletColors._deepBlueMenu,
      deepBlue: GeniusWalletColors._deepBlue,
      grayPrimary: GeniusWalletColors._grayPrimary,
      btnText: GeniusWalletColors._btnText,
      btnDisabled: GeniusWalletColors._btnDisabled,
      btnTextDisabled: GeniusWalletColors._btnTextDisabled,
      btnGradientBlue: GeniusWalletColors._btnGradientBlue,
      btnGradientGreen: GeniusWalletColors._btnGradientGreen,
      btnFilter: GeniusWalletColors._btnFilter,
      btnFilterSelected: GeniusWalletColors._btnFilterSelected,
      foundationError: GeniusWalletColors._foundationError,
      borderGrey: GeniusWalletColors._borderGrey,
      brandPrimary: GeniusWalletColors._brandPrimary,
      brandPrimaryStrong: GeniusWalletColors._brandPrimaryStrong,
      brandPrimaryMuted: GeniusWalletColors._brandPrimaryMuted,
      brandPrimarySubtle: GeniusWalletColors._brandPrimarySubtle,
      brandPrimaryOnSurface: GeniusWalletColors._brandPrimaryOnSurface,
      brandSecondary: GeniusWalletColors._brandSecondary,
      brandSecondaryStrong: GeniusWalletColors._brandSecondaryStrong,
      brandSecondaryBright: GeniusWalletColors._brandSecondaryBright,
      brandSecondaryMuted: GeniusWalletColors._brandSecondaryMuted,
      brandSecondarySubtle: GeniusWalletColors._brandSecondarySubtle,
      brandTertiary: GeniusWalletColors._brandTertiary,
      brandTertiaryMuted: GeniusWalletColors._brandTertiaryMuted,
      brandTertiarySubtle: GeniusWalletColors._brandTertiarySubtle,
      gradientBlue: GeniusWalletColors._gradientBlue,
      gradientGreen: GeniusWalletColors._gradientGreen,
      gray500: GeniusWalletColors._gray500,
      textTertiary: GeniusWalletColors._textTertiary,
      textDisabled: GeniusWalletColors._textDisabled,
      textOnBrand: GeniusWalletColors._textOnBrand,
      borderBrand: GeniusWalletColors._borderBrand,
      statusWarning: GeniusWalletColors._statusWarning,
      statusWarningText: const Color(0xFF92400E),
      textMutedOnSunken: const Color(0xFF4A5060),
      statusInfo: GeniusWalletColors._statusInfo,
      brandGreen: GeniusWalletColors._brandGreen,
      brandGreenStrong: GeniusWalletColors._brandGreenStrong,
      brandGreenMuted: GeniusWalletColors._brandGreenMuted,
      brandGreenSubtle: GeniusWalletColors._brandGreenSubtle,
    );
    // NB: textSecondary is intentionally OMITTED from the value-preservation
    // assert below -- light-mode textSecondary deliberately diverges from the
    // GeniusWalletColors invariant for WCAG AA (see field above). statusSuccess
    // and statusError are omitted for the same reason (see their field docs).
    assert(
      !GWAppearance.isLight ||
          (instance.surfaceBase == GeniusWalletColors._surfaceBase &&
              instance.surfaceElevated == GeniusWalletColors._surfaceElevated &&
              instance.surfaceMenu == GeniusWalletColors._surfaceMenu &&
              instance.surfaceSunken == GeniusWalletColors._surfaceSunken &&
              instance.surfaceOverlay == GeniusWalletColors._surfaceOverlay &&
              instance.textPrimary == GeniusWalletColors._textPrimary &&
              instance.textPrimary80 == GeniusWalletColors._textPrimary80 &&
              instance.textPrimary70 == GeniusWalletColors._textPrimary70 &&
              instance.textPrimary60 == GeniusWalletColors._textPrimary60 &&
              instance.textPrimary54 == GeniusWalletColors._textPrimary54 &&
              instance.textPrimary38 == GeniusWalletColors._textPrimary38 &&
              instance.textPrimary30 == GeniusWalletColors._textPrimary30 &&
              instance.textPrimary24 == GeniusWalletColors._textPrimary24 &&
              instance.textPrimary12 == GeniusWalletColors._textPrimary12 &&
              instance.textPrimary10 == GeniusWalletColors._textPrimary10 &&
              instance.borderSubtle == GeniusWalletColors._borderSubtle &&
              instance.borderStrong == GeniusWalletColors._borderStrong &&
              instance.borderControl == GeniusWalletColors._borderControl &&
              instance.lightGreenPrimary ==
                  GeniusWalletColors._lightGreenPrimary &&
              instance.lightGreenSecondary ==
                  GeniusWalletColors._lightGreenSecondary &&
              instance.mutedGreen == GeniusWalletColors._mutedGreen &&
              instance.deepBlueTertiary ==
                  GeniusWalletColors._deepBlueTertiary &&
              instance.deepBlueCardColor ==
                  GeniusWalletColors._deepBlueCardColor &&
              instance.deepBlueMenu == GeniusWalletColors._deepBlueMenu &&
              instance.deepBlue == GeniusWalletColors._deepBlue &&
              instance.grayPrimary == GeniusWalletColors._grayPrimary &&
              instance.btnText == GeniusWalletColors._btnText &&
              instance.btnDisabled == GeniusWalletColors._btnDisabled &&
              instance.btnTextDisabled == GeniusWalletColors._btnTextDisabled &&
              instance.btnGradientBlue == GeniusWalletColors._btnGradientBlue &&
              instance.btnGradientGreen ==
                  GeniusWalletColors._btnGradientGreen &&
              instance.btnFilter == GeniusWalletColors._btnFilter &&
              instance.btnFilterSelected ==
                  GeniusWalletColors._btnFilterSelected &&
              instance.foundationError == GeniusWalletColors._foundationError &&
              instance.borderGrey == GeniusWalletColors._borderGrey &&
              instance.brandPrimary == GeniusWalletColors._brandPrimary &&
              instance.brandPrimaryStrong ==
                  GeniusWalletColors._brandPrimaryStrong &&
              instance.brandPrimaryMuted ==
                  GeniusWalletColors._brandPrimaryMuted &&
              instance.brandPrimarySubtle ==
                  GeniusWalletColors._brandPrimarySubtle &&
              instance.brandPrimaryOnSurface ==
                  GeniusWalletColors._brandPrimaryOnSurface &&
              instance.brandSecondary == GeniusWalletColors._brandSecondary &&
              instance.brandSecondaryStrong ==
                  GeniusWalletColors._brandSecondaryStrong &&
              instance.brandSecondaryBright ==
                  GeniusWalletColors._brandSecondaryBright &&
              instance.brandSecondaryMuted ==
                  GeniusWalletColors._brandSecondaryMuted &&
              instance.brandSecondarySubtle ==
                  GeniusWalletColors._brandSecondarySubtle &&
              instance.brandTertiary == GeniusWalletColors._brandTertiary &&
              instance.brandTertiaryMuted ==
                  GeniusWalletColors._brandTertiaryMuted &&
              instance.brandTertiarySubtle ==
                  GeniusWalletColors._brandTertiarySubtle &&
              instance.gradientBlue == GeniusWalletColors._gradientBlue &&
              instance.gradientGreen == GeniusWalletColors._gradientGreen &&
              instance.gray500 == GeniusWalletColors._gray500 &&
              instance.textTertiary == GeniusWalletColors._textTertiary &&
              instance.textDisabled == GeniusWalletColors._textDisabled &&
              instance.textOnBrand == GeniusWalletColors._textOnBrand &&
              instance.borderBrand == GeniusWalletColors._borderBrand &&
              instance.statusWarning == GeniusWalletColors._statusWarning &&
              instance.statusInfo == GeniusWalletColors._statusInfo &&
              instance.brandGreen == GeniusWalletColors._brandGreen &&
              instance.brandGreenStrong ==
                  GeniusWalletColors._brandGreenStrong &&
              instance.brandGreenMuted == GeniusWalletColors._brandGreenMuted &&
              instance.brandGreenSubtle ==
                  GeniusWalletColors._brandGreenSubtle),
      'GWColors.light() value drifted from GeniusWalletColors in light mode',
    );
    return instance;
  }

  /// Dark-mode instance. Every field is copied verbatim from the DARK branch
  /// of the matching `GeniusWalletColors` getter/constant. Mirror of
  /// [GWColors.light] -- see its doc comment for the assert rationale.
  factory GWColors.dark() {
    final instance = GWColors(
      surfaceBase: GeniusWalletColors._surfaceBase,
      surfaceElevated: GeniusWalletColors._surfaceElevated,
      surfaceMenu: GeniusWalletColors._surfaceMenu,
      surfaceSunken: GeniusWalletColors._surfaceSunken,
      surfaceOverlay: GeniusWalletColors._surfaceOverlay,
      textPrimary: GeniusWalletColors._textPrimary,
      textPrimary80: GeniusWalletColors._textPrimary80,
      textPrimary70: GeniusWalletColors._textPrimary70,
      textPrimary60: GeniusWalletColors._textPrimary60,
      textPrimary54: GeniusWalletColors._textPrimary54,
      textPrimary38: GeniusWalletColors._textPrimary38,
      textPrimary30: GeniusWalletColors._textPrimary30,
      textPrimary24: GeniusWalletColors._textPrimary24,
      textPrimary12: GeniusWalletColors._textPrimary12,
      textPrimary10: GeniusWalletColors._textPrimary10,
      // Dark-mode textSecondary keeps the invariant (0xFF8A8F9D passes AA on
      // the dark surface); the status tokens are the original dark values.
      textSecondary: GeniusWalletColors._textSecondary,
      statusSuccess: const Color(0xFF0AD89C),
      statusError: const Color(0xFFFF4D4D),
      borderSubtle: GeniusWalletColors._borderSubtle,
      borderStrong: GeniusWalletColors._borderStrong,
      borderControl: GeniusWalletColors._borderControl,
      lightGreenPrimary: GeniusWalletColors._lightGreenPrimary,
      lightGreenSecondary: GeniusWalletColors._lightGreenSecondary,
      mutedGreen: GeniusWalletColors._mutedGreen,
      deepBlueTertiary: GeniusWalletColors._deepBlueTertiary,
      deepBlueCardColor: GeniusWalletColors._deepBlueCardColor,
      deepBlueMenu: GeniusWalletColors._deepBlueMenu,
      deepBlue: GeniusWalletColors._deepBlue,
      grayPrimary: GeniusWalletColors._grayPrimary,
      btnText: GeniusWalletColors._btnText,
      btnDisabled: GeniusWalletColors._btnDisabled,
      btnTextDisabled: GeniusWalletColors._btnTextDisabled,
      btnGradientBlue: GeniusWalletColors._btnGradientBlue,
      btnGradientGreen: GeniusWalletColors._btnGradientGreen,
      btnFilter: GeniusWalletColors._btnFilter,
      btnFilterSelected: GeniusWalletColors._btnFilterSelected,
      foundationError: GeniusWalletColors._foundationError,
      borderGrey: GeniusWalletColors._borderGrey,
      brandPrimary: GeniusWalletColors._brandPrimary,
      brandPrimaryStrong: GeniusWalletColors._brandPrimaryStrong,
      brandPrimaryMuted: GeniusWalletColors._brandPrimaryMuted,
      brandPrimarySubtle: GeniusWalletColors._brandPrimarySubtle,
      brandPrimaryOnSurface: GeniusWalletColors._brandPrimaryOnSurface,
      brandSecondary: GeniusWalletColors._brandSecondary,
      brandSecondaryStrong: GeniusWalletColors._brandSecondaryStrong,
      brandSecondaryBright: GeniusWalletColors._brandSecondaryBright,
      brandSecondaryMuted: GeniusWalletColors._brandSecondaryMuted,
      brandSecondarySubtle: GeniusWalletColors._brandSecondarySubtle,
      brandTertiary: GeniusWalletColors._brandTertiary,
      brandTertiaryMuted: GeniusWalletColors._brandTertiaryMuted,
      brandTertiarySubtle: GeniusWalletColors._brandTertiarySubtle,
      gradientBlue: GeniusWalletColors._gradientBlue,
      gradientGreen: GeniusWalletColors._gradientGreen,
      gray500: GeniusWalletColors._gray500,
      textTertiary: GeniusWalletColors._textTertiary,
      textDisabled: GeniusWalletColors._textDisabled,
      textOnBrand: GeniusWalletColors._textOnBrand,
      borderBrand: GeniusWalletColors._borderBrand,
      statusWarning: GeniusWalletColors._statusWarning,
      statusWarningText: GeniusWalletColors._statusWarning,
      textMutedOnSunken: GeniusWalletColors._textSecondary,
      statusInfo: GeniusWalletColors._statusInfo,
      brandGreen: GeniusWalletColors._brandGreen,
      brandGreenStrong: GeniusWalletColors._brandGreenStrong,
      brandGreenMuted: GeniusWalletColors._brandGreenMuted,
      brandGreenSubtle: GeniusWalletColors._brandGreenSubtle,
    );
    // NB: textSecondary is OMITTED from the value-preservation assert below to
    // mirror light() -- the light branch deliberately diverges it for AA, so
    // the shared assert cannot compare it (dark still uses the invariant
    // value). statusSuccess/statusError are omitted for the same reason.
    assert(
      GWAppearance.isLight ||
          (instance.surfaceBase == GeniusWalletColors._surfaceBase &&
              instance.surfaceElevated == GeniusWalletColors._surfaceElevated &&
              instance.surfaceMenu == GeniusWalletColors._surfaceMenu &&
              instance.surfaceSunken == GeniusWalletColors._surfaceSunken &&
              instance.surfaceOverlay == GeniusWalletColors._surfaceOverlay &&
              instance.textPrimary == GeniusWalletColors._textPrimary &&
              instance.textPrimary80 == GeniusWalletColors._textPrimary80 &&
              instance.textPrimary70 == GeniusWalletColors._textPrimary70 &&
              instance.textPrimary60 == GeniusWalletColors._textPrimary60 &&
              instance.textPrimary54 == GeniusWalletColors._textPrimary54 &&
              instance.textPrimary38 == GeniusWalletColors._textPrimary38 &&
              instance.textPrimary30 == GeniusWalletColors._textPrimary30 &&
              instance.textPrimary24 == GeniusWalletColors._textPrimary24 &&
              instance.textPrimary12 == GeniusWalletColors._textPrimary12 &&
              instance.textPrimary10 == GeniusWalletColors._textPrimary10 &&
              instance.borderSubtle == GeniusWalletColors._borderSubtle &&
              instance.borderStrong == GeniusWalletColors._borderStrong &&
              instance.borderControl == GeniusWalletColors._borderControl &&
              instance.lightGreenPrimary ==
                  GeniusWalletColors._lightGreenPrimary &&
              instance.lightGreenSecondary ==
                  GeniusWalletColors._lightGreenSecondary &&
              instance.mutedGreen == GeniusWalletColors._mutedGreen &&
              instance.deepBlueTertiary ==
                  GeniusWalletColors._deepBlueTertiary &&
              instance.deepBlueCardColor ==
                  GeniusWalletColors._deepBlueCardColor &&
              instance.deepBlueMenu == GeniusWalletColors._deepBlueMenu &&
              instance.deepBlue == GeniusWalletColors._deepBlue &&
              instance.grayPrimary == GeniusWalletColors._grayPrimary &&
              instance.btnText == GeniusWalletColors._btnText &&
              instance.btnDisabled == GeniusWalletColors._btnDisabled &&
              instance.btnTextDisabled == GeniusWalletColors._btnTextDisabled &&
              instance.btnGradientBlue == GeniusWalletColors._btnGradientBlue &&
              instance.btnGradientGreen ==
                  GeniusWalletColors._btnGradientGreen &&
              instance.btnFilter == GeniusWalletColors._btnFilter &&
              instance.btnFilterSelected ==
                  GeniusWalletColors._btnFilterSelected &&
              instance.foundationError == GeniusWalletColors._foundationError &&
              instance.borderGrey == GeniusWalletColors._borderGrey &&
              instance.brandPrimary == GeniusWalletColors._brandPrimary &&
              instance.brandPrimaryStrong ==
                  GeniusWalletColors._brandPrimaryStrong &&
              instance.brandPrimaryMuted ==
                  GeniusWalletColors._brandPrimaryMuted &&
              instance.brandPrimarySubtle ==
                  GeniusWalletColors._brandPrimarySubtle &&
              instance.brandPrimaryOnSurface ==
                  GeniusWalletColors._brandPrimaryOnSurface &&
              instance.brandSecondary == GeniusWalletColors._brandSecondary &&
              instance.brandSecondaryStrong ==
                  GeniusWalletColors._brandSecondaryStrong &&
              instance.brandSecondaryBright ==
                  GeniusWalletColors._brandSecondaryBright &&
              instance.brandSecondaryMuted ==
                  GeniusWalletColors._brandSecondaryMuted &&
              instance.brandSecondarySubtle ==
                  GeniusWalletColors._brandSecondarySubtle &&
              instance.brandTertiary == GeniusWalletColors._brandTertiary &&
              instance.brandTertiaryMuted ==
                  GeniusWalletColors._brandTertiaryMuted &&
              instance.brandTertiarySubtle ==
                  GeniusWalletColors._brandTertiarySubtle &&
              instance.gradientBlue == GeniusWalletColors._gradientBlue &&
              instance.gradientGreen == GeniusWalletColors._gradientGreen &&
              instance.gray500 == GeniusWalletColors._gray500 &&
              instance.textTertiary == GeniusWalletColors._textTertiary &&
              instance.textDisabled == GeniusWalletColors._textDisabled &&
              instance.textOnBrand == GeniusWalletColors._textOnBrand &&
              instance.borderBrand == GeniusWalletColors._borderBrand &&
              instance.statusWarning == GeniusWalletColors._statusWarning &&
              instance.statusInfo == GeniusWalletColors._statusInfo &&
              instance.brandGreen == GeniusWalletColors._brandGreen &&
              instance.brandGreenStrong ==
                  GeniusWalletColors._brandGreenStrong &&
              instance.brandGreenMuted == GeniusWalletColors._brandGreenMuted &&
              instance.brandGreenSubtle ==
                  GeniusWalletColors._brandGreenSubtle),
      'GWColors.dark() value drifted from GeniusWalletColors in dark mode',
    );
    return instance;
  }

  @override
  GWColors copyWith({
    Color? surfaceBase,
    Color? surfaceElevated,
    Color? surfaceMenu,
    Color? surfaceSunken,
    Color? surfaceOverlay,
    Color? textPrimary,
    Color? textPrimary80,
    Color? textPrimary70,
    Color? textPrimary60,
    Color? textPrimary54,
    Color? textPrimary38,
    Color? textPrimary30,
    Color? textPrimary24,
    Color? textPrimary12,
    Color? textPrimary10,
    Color? textSecondary,
    Color? statusSuccess,
    Color? statusError,
    Color? borderSubtle,
    Color? borderStrong,
    Color? borderControl,
    Color? lightGreenPrimary,
    Color? lightGreenSecondary,
    Color? mutedGreen,
    Color? deepBlueTertiary,
    Color? deepBlueCardColor,
    Color? deepBlueMenu,
    Color? deepBlue,
    Color? grayPrimary,
    Color? btnText,
    Color? btnDisabled,
    Color? btnTextDisabled,
    Color? btnGradientBlue,
    Color? btnGradientGreen,
    Color? btnFilter,
    Color? btnFilterSelected,
    Color? foundationError,
    Color? borderGrey,
    Color? brandPrimary,
    Color? brandPrimaryStrong,
    Color? brandPrimaryMuted,
    Color? brandPrimarySubtle,
    Color? brandPrimaryOnSurface,
    Color? brandSecondary,
    Color? brandSecondaryStrong,
    Color? brandSecondaryBright,
    Color? brandSecondaryMuted,
    Color? brandSecondarySubtle,
    Color? brandTertiary,
    Color? brandTertiaryMuted,
    Color? brandTertiarySubtle,
    Color? gradientBlue,
    Color? gradientGreen,
    Color? gray500,
    Color? textTertiary,
    Color? textDisabled,
    Color? textOnBrand,
    Color? borderBrand,
    Color? statusWarning,
    Color? statusWarningText,
    Color? textMutedOnSunken,
    Color? statusInfo,
    Color? brandGreen,
    Color? brandGreenStrong,
    Color? brandGreenMuted,
    Color? brandGreenSubtle,
  }) {
    return GWColors(
      surfaceBase: surfaceBase ?? this.surfaceBase,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      surfaceMenu: surfaceMenu ?? this.surfaceMenu,
      surfaceSunken: surfaceSunken ?? this.surfaceSunken,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
      textPrimary: textPrimary ?? this.textPrimary,
      textPrimary80: textPrimary80 ?? this.textPrimary80,
      textPrimary70: textPrimary70 ?? this.textPrimary70,
      textPrimary60: textPrimary60 ?? this.textPrimary60,
      textPrimary54: textPrimary54 ?? this.textPrimary54,
      textPrimary38: textPrimary38 ?? this.textPrimary38,
      textPrimary30: textPrimary30 ?? this.textPrimary30,
      textPrimary24: textPrimary24 ?? this.textPrimary24,
      textPrimary12: textPrimary12 ?? this.textPrimary12,
      textPrimary10: textPrimary10 ?? this.textPrimary10,
      textSecondary: textSecondary ?? this.textSecondary,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusError: statusError ?? this.statusError,
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
      borderControl: borderControl ?? this.borderControl,
      lightGreenPrimary: lightGreenPrimary ?? this.lightGreenPrimary,
      lightGreenSecondary: lightGreenSecondary ?? this.lightGreenSecondary,
      mutedGreen: mutedGreen ?? this.mutedGreen,
      deepBlueTertiary: deepBlueTertiary ?? this.deepBlueTertiary,
      deepBlueCardColor: deepBlueCardColor ?? this.deepBlueCardColor,
      deepBlueMenu: deepBlueMenu ?? this.deepBlueMenu,
      deepBlue: deepBlue ?? this.deepBlue,
      grayPrimary: grayPrimary ?? this.grayPrimary,
      btnText: btnText ?? this.btnText,
      btnDisabled: btnDisabled ?? this.btnDisabled,
      btnTextDisabled: btnTextDisabled ?? this.btnTextDisabled,
      btnGradientBlue: btnGradientBlue ?? this.btnGradientBlue,
      btnGradientGreen: btnGradientGreen ?? this.btnGradientGreen,
      btnFilter: btnFilter ?? this.btnFilter,
      btnFilterSelected: btnFilterSelected ?? this.btnFilterSelected,
      foundationError: foundationError ?? this.foundationError,
      borderGrey: borderGrey ?? this.borderGrey,
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryStrong: brandPrimaryStrong ?? this.brandPrimaryStrong,
      brandPrimaryMuted: brandPrimaryMuted ?? this.brandPrimaryMuted,
      brandPrimarySubtle: brandPrimarySubtle ?? this.brandPrimarySubtle,
      brandPrimaryOnSurface:
          brandPrimaryOnSurface ?? this.brandPrimaryOnSurface,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      brandSecondaryStrong: brandSecondaryStrong ?? this.brandSecondaryStrong,
      brandSecondaryBright: brandSecondaryBright ?? this.brandSecondaryBright,
      brandSecondaryMuted: brandSecondaryMuted ?? this.brandSecondaryMuted,
      brandSecondarySubtle: brandSecondarySubtle ?? this.brandSecondarySubtle,
      brandTertiary: brandTertiary ?? this.brandTertiary,
      brandTertiaryMuted: brandTertiaryMuted ?? this.brandTertiaryMuted,
      brandTertiarySubtle: brandTertiarySubtle ?? this.brandTertiarySubtle,
      gradientBlue: gradientBlue ?? this.gradientBlue,
      gradientGreen: gradientGreen ?? this.gradientGreen,
      gray500: gray500 ?? this.gray500,
      textTertiary: textTertiary ?? this.textTertiary,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnBrand: textOnBrand ?? this.textOnBrand,
      borderBrand: borderBrand ?? this.borderBrand,
      statusWarning: statusWarning ?? this.statusWarning,
      statusWarningText: statusWarningText ?? this.statusWarningText,
      textMutedOnSunken: textMutedOnSunken ?? this.textMutedOnSunken,
      statusInfo: statusInfo ?? this.statusInfo,
      brandGreen: brandGreen ?? this.brandGreen,
      brandGreenStrong: brandGreenStrong ?? this.brandGreenStrong,
      brandGreenMuted: brandGreenMuted ?? this.brandGreenMuted,
      brandGreenSubtle: brandGreenSubtle ?? this.brandGreenSubtle,
    );
  }

  /// Appearance is a discrete two-state toggle, not an animation -- a
  /// discrete flip at the midpoint is acceptable (no visible interpolation
  /// frame occurs in practice since `ThemeData` swaps are not animated here).
  @override
  GWColors lerp(ThemeExtension<GWColors>? other, double t) {
    if (other is! GWColors) {
      return this;
    }
    return t < 0.5 ? this : other;
  }

  // ---------------------------------------------------------------------
  // 23-04: two narrow, named, STATIC (not instance-field) exceptions to full
  // primitive closure. Both exist because a `const` call site needs a
  // compile-time constant and cannot take a BuildContext/Theme read at all --
  // a plain instance field would not help there, and inlining the hex at the
  // call site would violate AGENTS.md's "no raw hex outside lib/theme". Each
  // has exactly one documented consumer; this is not a reopening of the
  // primitive layer for general use.
  // ---------------------------------------------------------------------

  /// [GeniusWalletColors._statusNeutral]'s mode-invariant, FILL-ONLY value,
  /// exposed as a static const rather than promoted to a `GWColors` INSTANCE
  /// field -- 23-01-TOKEN-MAP.md's "Excluded" section and the primitive's own
  /// doc comment both record that exclusion as deliberate (no per-appearance
  /// divergent value is ever needed for this fill). Sole consumer:
  /// `transaction_badge.dart`'s three `const TransactionBadgeSpec(...)` badge
  /// kinds (Sent/Escrow/Swapped), which need `fill` to stay a compile-time
  /// constant.
  static const Color statusNeutral = GeniusWalletColors._statusNeutral;

  /// [GeniusWalletColors._statusError]'s ORIGINAL mode-invariant value
  /// (`#FF4D4D`), distinct from this class's own appearance-aware
  /// [statusError] INSTANCE field (which diverges in light mode for WCAG AA
  /// -- see that field's doc comment). Sole consumer: `lib/main.dart`'s
  /// `ErrorWidget.builder`, which may replace a widget ABOVE
  /// `MaterialApp`/`Theme` and therefore cannot guarantee a `Theme` ancestor
  /// to read through -- its icon color must stay `const`, so neither a
  /// context read nor a `GWColors.dark()` factory call (itself not `const`)
  /// can serve here.
  static const Color fixedStatusError = GeniusWalletColors._statusError;

  /// [GeniusWalletColors._textSecondary]'s ORIGINAL mode-invariant value
  /// (`#8A8F9D`), distinct from this class's own appearance-aware
  /// [textSecondary] INSTANCE field (which diverges in light mode for WCAG
  /// AA). Sole consumer: `theme.dart`'s `tabBarTheme.unselectedLabelColor`
  /// and `textSelectionTheme.selectionColor`, which read the legacy
  /// mode-invariant value on both branches TODAY (i.e. before 23-04, in both
  /// `ColorScheme.light()`/`.dark()` calls) -- preserved verbatim rather
  /// than switched to the AA-adjusted instance field, since either would be
  /// a behaviour change ("nothing here may repaint") outside this plan's
  /// reachability-and-naming scope.
  static const Color fixedTextSecondary = GeniusWalletColors._textSecondary;
}
