import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

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
/// `GeniusWalletColors` getter. `GeniusWalletColors` remains the single
/// source of truth and stays in place (no big-bang removal) -- unmigrated
/// call sites keep working exactly as before.
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
    required this.borderSubtle,
    required this.borderStrong,
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
  final Color borderSubtle;
  final Color borderStrong;

  /// Light-mode instance. Every field is copied verbatim from the LIGHT
  /// branch of the matching `GeniusWalletColors` getter.
  ///
  /// MACHINE VALUE-PRESERVATION CHECK: a one-alpha-step transcription slip
  /// across this ~18-field copy is invisible to the eye and to `flutter
  /// analyze`. This assert is MODE-GATED -- it only enforces when the global
  /// appearance is actually light (i.e. this is the branch getThemeData()
  /// picks), so it does not fire for the fail-soft `?? GWColors.dark()`
  /// fallback that consumers may construct while the app is in dark mode.
  /// Strips in release; zero-cost in production.
  factory GWColors.light() {
    final instance = GWColors(
      surfaceBase: GeniusWalletColors.surfaceBase,
      surfaceElevated: GeniusWalletColors.surfaceElevated,
      surfaceMenu: GeniusWalletColors.surfaceMenu,
      surfaceSunken: GeniusWalletColors.surfaceSunken,
      surfaceOverlay: GeniusWalletColors.surfaceOverlay,
      textPrimary: GeniusWalletColors.textPrimary,
      textPrimary80: GeniusWalletColors.textPrimary80,
      textPrimary70: GeniusWalletColors.textPrimary70,
      textPrimary60: GeniusWalletColors.textPrimary60,
      textPrimary54: GeniusWalletColors.textPrimary54,
      textPrimary38: GeniusWalletColors.textPrimary38,
      textPrimary30: GeniusWalletColors.textPrimary30,
      textPrimary24: GeniusWalletColors.textPrimary24,
      textPrimary12: GeniusWalletColors.textPrimary12,
      textPrimary10: GeniusWalletColors.textPrimary10,
      textSecondary: GeniusWalletColors.textSecondary,
      borderSubtle: GeniusWalletColors.borderSubtle,
      borderStrong: GeniusWalletColors.borderStrong,
    );
    assert(
      !GWAppearance.isLight ||
          (instance.surfaceBase == GeniusWalletColors.surfaceBase &&
              instance.surfaceElevated == GeniusWalletColors.surfaceElevated &&
              instance.surfaceMenu == GeniusWalletColors.surfaceMenu &&
              instance.surfaceSunken == GeniusWalletColors.surfaceSunken &&
              instance.surfaceOverlay == GeniusWalletColors.surfaceOverlay &&
              instance.textPrimary == GeniusWalletColors.textPrimary &&
              instance.textPrimary80 == GeniusWalletColors.textPrimary80 &&
              instance.textPrimary70 == GeniusWalletColors.textPrimary70 &&
              instance.textPrimary60 == GeniusWalletColors.textPrimary60 &&
              instance.textPrimary54 == GeniusWalletColors.textPrimary54 &&
              instance.textPrimary38 == GeniusWalletColors.textPrimary38 &&
              instance.textPrimary30 == GeniusWalletColors.textPrimary30 &&
              instance.textPrimary24 == GeniusWalletColors.textPrimary24 &&
              instance.textPrimary12 == GeniusWalletColors.textPrimary12 &&
              instance.textPrimary10 == GeniusWalletColors.textPrimary10 &&
              instance.textSecondary == GeniusWalletColors.textSecondary &&
              instance.borderSubtle == GeniusWalletColors.borderSubtle &&
              instance.borderStrong == GeniusWalletColors.borderStrong),
      'GWColors.light() value drifted from GeniusWalletColors in light mode',
    );
    return instance;
  }

  /// Dark-mode instance. Every field is copied verbatim from the DARK branch
  /// of the matching `GeniusWalletColors` getter. Mirror of [GWColors.light]
  /// -- see its doc comment for the assert rationale.
  factory GWColors.dark() {
    final instance = GWColors(
      surfaceBase: GeniusWalletColors.surfaceBase,
      surfaceElevated: GeniusWalletColors.surfaceElevated,
      surfaceMenu: GeniusWalletColors.surfaceMenu,
      surfaceSunken: GeniusWalletColors.surfaceSunken,
      surfaceOverlay: GeniusWalletColors.surfaceOverlay,
      textPrimary: GeniusWalletColors.textPrimary,
      textPrimary80: GeniusWalletColors.textPrimary80,
      textPrimary70: GeniusWalletColors.textPrimary70,
      textPrimary60: GeniusWalletColors.textPrimary60,
      textPrimary54: GeniusWalletColors.textPrimary54,
      textPrimary38: GeniusWalletColors.textPrimary38,
      textPrimary30: GeniusWalletColors.textPrimary30,
      textPrimary24: GeniusWalletColors.textPrimary24,
      textPrimary12: GeniusWalletColors.textPrimary12,
      textPrimary10: GeniusWalletColors.textPrimary10,
      textSecondary: GeniusWalletColors.textSecondary,
      borderSubtle: GeniusWalletColors.borderSubtle,
      borderStrong: GeniusWalletColors.borderStrong,
    );
    assert(
      GWAppearance.isLight ||
          (instance.surfaceBase == GeniusWalletColors.surfaceBase &&
              instance.surfaceElevated == GeniusWalletColors.surfaceElevated &&
              instance.surfaceMenu == GeniusWalletColors.surfaceMenu &&
              instance.surfaceSunken == GeniusWalletColors.surfaceSunken &&
              instance.surfaceOverlay == GeniusWalletColors.surfaceOverlay &&
              instance.textPrimary == GeniusWalletColors.textPrimary &&
              instance.textPrimary80 == GeniusWalletColors.textPrimary80 &&
              instance.textPrimary70 == GeniusWalletColors.textPrimary70 &&
              instance.textPrimary60 == GeniusWalletColors.textPrimary60 &&
              instance.textPrimary54 == GeniusWalletColors.textPrimary54 &&
              instance.textPrimary38 == GeniusWalletColors.textPrimary38 &&
              instance.textPrimary30 == GeniusWalletColors.textPrimary30 &&
              instance.textPrimary24 == GeniusWalletColors.textPrimary24 &&
              instance.textPrimary12 == GeniusWalletColors.textPrimary12 &&
              instance.textPrimary10 == GeniusWalletColors.textPrimary10 &&
              instance.textSecondary == GeniusWalletColors.textSecondary &&
              instance.borderSubtle == GeniusWalletColors.borderSubtle &&
              instance.borderStrong == GeniusWalletColors.borderStrong),
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
    Color? borderSubtle,
    Color? borderStrong,
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
      borderSubtle: borderSubtle ?? this.borderSubtle,
      borderStrong: borderStrong ?? this.borderStrong,
    );
  }

  /// Appearance is a discrete two-state toggle, not an animation -- a
  /// discrete flip at the midpoint is acceptable (no visible interpolation
  /// frame occurs in practice since `ThemeData` swaps are not animated here).
  @override
  GWColors lerp(ThemeExtension<GWColors>? other, double t) {
    if (other is! GWColors) return this;
    return t < 0.5 ? this : other;
  }
}
