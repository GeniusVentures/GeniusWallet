import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// THIS FILE IS THE LOAD-BEARING PROOF OF THE ENTIRE COLOUR WORKSTREAM.
//
// Phase 23 has no golden/snapshot baseline (declined, see 23-CONTEXT.md § "NO
// GOLDEN TESTS"). The proof that 23-02's 260+ call-site rewrite paints
// nothing differently is VALUE EQUALITY, not pixel comparison: if every token
// resolves to an identical `Color` reading it through the old
// `GeniusWalletColors` static path or the new `GWColors` extension path, in
// BOTH appearance modes, then an AST codemod that only rewrites the *access
// path* cannot change what gets painted. This is a stronger guarantee than a
// golden image, which only samples a handful of widgets -- this samples
// every token. Do not delete this file because it "looks like a boring
// equality test" -- it is the reason 23-02 is a mechanical rewrite instead of
// 260 individual judgement calls.
//
// See `.planning/phases/23-.../23-01-TOKEN-MAP.md` for the full token map
// this file is driven by, including the one deliberate exclusion
// (`statusNeutral`) and the const-context risk list handed to 23-02.

/// Flips [GWAppearance] to [mode] for the current test, restoring dark (the
/// module-level default) via [addTearDown] -- mirrors
/// `theme_contrast_test.dart`'s `themeFor` helper so no later test file in
/// the same shard inherits a leaked appearance flip. Unlike `themeFor`, this
/// does not build a `ThemeData` -- the parity checks below compare `GWColors`
/// instances directly against `GeniusWalletColors` accessors, which is a
/// cheaper and more direct comparison than round-tripping through
/// `getThemeData()`.
void setAppearance(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
}

/// Constructs the `GWColors` instance matching the currently active
/// [GWAppearance] mode -- exactly how `theme.dart#getThemeData()` picks
/// between `GWColors.light()`/`.dark()` in production. The appearance-aware
/// fields on both factories read straight through the corresponding
/// `GeniusWalletColors` getter, so the factory choice and the active
/// appearance mode must always march in lockstep -- see the mode-gated
/// asserts inside `gw_colors.dart`'s factories for the same invariant.
GWColors currentGwColors() =>
    GWAppearance.isLight ? GWColors.light() : GWColors.dark();

void main() {
  group('Field-count drift guard', () {
    test(
      'GWColors declares exactly 64 fields (21 pre-existing + 43 from the 23-01 token map)',
      () {
        // COMPILE-TIME TRIPWIRE, not a runtime reflection check -- Flutter has
        // no dart:mirrors. `GWColors`'s unnamed constructor makes every field
        // `required`, so constructing one with EXACTLY this named-argument
        // list is a compile error (missing required argument / undefined
        // named parameter) the moment a field is added to one side of the
        // codebase and not the other. That is stronger than a runtime count
        // assertion: it fails `flutter analyze`/the build, not just this test.
        const probe = GWColors(
          // 21 pre-existing fields
          surfaceBase: Colors.black,
          surfaceElevated: Colors.black,
          surfaceMenu: Colors.black,
          surfaceSunken: Colors.black,
          surfaceOverlay: Colors.black,
          textPrimary: Colors.black,
          textPrimary80: Colors.black,
          textPrimary70: Colors.black,
          textPrimary60: Colors.black,
          textPrimary54: Colors.black,
          textPrimary38: Colors.black,
          textPrimary30: Colors.black,
          textPrimary24: Colors.black,
          textPrimary12: Colors.black,
          textPrimary10: Colors.black,
          textSecondary: Colors.black,
          statusSuccess: Colors.black,
          statusError: Colors.black,
          borderSubtle: Colors.black,
          borderStrong: Colors.black,
          borderControl: Colors.black,
          // 43 fields added by the 23-01 token map
          lightGreenPrimary: Colors.black,
          lightGreenSecondary: Colors.black,
          mutedGreen: Colors.black,
          deepBlueTertiary: Colors.black,
          deepBlueCardColor: Colors.black,
          deepBlueMenu: Colors.black,
          deepBlue: Colors.black,
          grayPrimary: Colors.black,
          btnText: Colors.black,
          btnDisabled: Colors.black,
          btnTextDisabled: Colors.black,
          btnGradientBlue: Colors.black,
          btnGradientGreen: Colors.black,
          btnFilter: Colors.black,
          btnFilterSelected: Colors.black,
          foundationError: Colors.black,
          borderGrey: Colors.black,
          brandPrimary: Colors.black,
          brandPrimaryStrong: Colors.black,
          brandPrimaryMuted: Colors.black,
          brandPrimarySubtle: Colors.black,
          brandPrimaryOnSurface: Colors.black,
          brandSecondary: Colors.black,
          brandSecondaryStrong: Colors.black,
          brandSecondaryBright: Colors.black,
          brandSecondaryMuted: Colors.black,
          brandSecondarySubtle: Colors.black,
          brandTertiary: Colors.black,
          brandTertiaryMuted: Colors.black,
          brandTertiarySubtle: Colors.black,
          gradientBlue: Colors.black,
          gradientGreen: Colors.black,
          gray500: Colors.black,
          textTertiary: Colors.black,
          textDisabled: Colors.black,
          textOnBrand: Colors.black,
          borderBrand: Colors.black,
          statusWarning: Colors.black,
          statusInfo: Colors.black,
          brandGreen: Colors.black,
          brandGreenStrong: Colors.black,
          brandGreenMuted: Colors.black,
          brandGreenSubtle: Colors.black,
        );
        expect(probe.surfaceBase, Colors.black);
      },
    );
  });

  group('Fixed (non-appearance-aware) tokens match legacy in both modes', () {
    // legacy name -> (GWColors accessor, GeniusWalletColors accessor). Value
    // is identical in both modes for every field in this map, so a single
    // comparison per mode covers the "light value" and "dark value" columns
    // of the token map simultaneously.
    final fixedFields = <String, (Color Function(GWColors), Color)>{
      'lightGreenPrimary': (
        (gw) => gw.lightGreenPrimary,
        GeniusWalletColors.lightGreenPrimary,
      ),
      'lightGreenSecondary': (
        (gw) => gw.lightGreenSecondary,
        GeniusWalletColors.lightGreenSecondary,
      ),
      'mutedGreen': ((gw) => gw.mutedGreen, GeniusWalletColors.mutedGreen),
      'deepBlueTertiary': (
        (gw) => gw.deepBlueTertiary,
        GeniusWalletColors.deepBlueTertiary,
      ),
      'deepBlueCardColor': (
        (gw) => gw.deepBlueCardColor,
        GeniusWalletColors.deepBlueCardColor,
      ),
      'deepBlueMenu': (
        (gw) => gw.deepBlueMenu,
        GeniusWalletColors.deepBlueMenu,
      ),
      'deepBlue': ((gw) => gw.deepBlue, GeniusWalletColors.deepBlue),
      'grayPrimary': ((gw) => gw.grayPrimary, GeniusWalletColors.grayPrimary),
      'btnText': ((gw) => gw.btnText, GeniusWalletColors.btnText),
      'btnDisabled': ((gw) => gw.btnDisabled, GeniusWalletColors.btnDisabled),
      'btnTextDisabled': (
        (gw) => gw.btnTextDisabled,
        GeniusWalletColors.btnTextDisabled,
      ),
      'btnGradientBlue': (
        (gw) => gw.btnGradientBlue,
        GeniusWalletColors.btnGradientBlue,
      ),
      'btnGradientGreen': (
        (gw) => gw.btnGradientGreen,
        GeniusWalletColors.btnGradientGreen,
      ),
      'btnFilterSelected': (
        (gw) => gw.btnFilterSelected,
        GeniusWalletColors.btnFilterSelected,
      ),
      'foundationError': (
        (gw) => gw.foundationError,
        GeniusWalletColors.foundationError,
      ),
      'borderGrey': ((gw) => gw.borderGrey, GeniusWalletColors.borderGrey),
      'brandPrimary': (
        (gw) => gw.brandPrimary,
        GeniusWalletColors.brandPrimary,
      ),
      'brandPrimaryStrong': (
        (gw) => gw.brandPrimaryStrong,
        GeniusWalletColors.brandPrimaryStrong,
      ),
      'brandPrimaryMuted': (
        (gw) => gw.brandPrimaryMuted,
        GeniusWalletColors.brandPrimaryMuted,
      ),
      'brandPrimarySubtle': (
        (gw) => gw.brandPrimarySubtle,
        GeniusWalletColors.brandPrimarySubtle,
      ),
      'brandSecondary': (
        (gw) => gw.brandSecondary,
        GeniusWalletColors.brandSecondary,
      ),
      'brandSecondaryStrong': (
        (gw) => gw.brandSecondaryStrong,
        GeniusWalletColors.brandSecondaryStrong,
      ),
      'brandSecondaryBright': (
        (gw) => gw.brandSecondaryBright,
        GeniusWalletColors.brandSecondaryBright,
      ),
      'brandSecondaryMuted': (
        (gw) => gw.brandSecondaryMuted,
        GeniusWalletColors.brandSecondaryMuted,
      ),
      'brandSecondarySubtle': (
        (gw) => gw.brandSecondarySubtle,
        GeniusWalletColors.brandSecondarySubtle,
      ),
      'brandTertiary': (
        (gw) => gw.brandTertiary,
        GeniusWalletColors.brandTertiary,
      ),
      'brandTertiaryMuted': (
        (gw) => gw.brandTertiaryMuted,
        GeniusWalletColors.brandTertiaryMuted,
      ),
      'brandTertiarySubtle': (
        (gw) => gw.brandTertiarySubtle,
        GeniusWalletColors.brandTertiarySubtle,
      ),
      'gradientBlue': (
        (gw) => gw.gradientBlue,
        GeniusWalletColors.gradientBlue,
      ),
      'gradientGreen': (
        (gw) => gw.gradientGreen,
        GeniusWalletColors.gradientGreen,
      ),
      'gray500': ((gw) => gw.gray500, GeniusWalletColors.gray500),
      'textTertiary': (
        (gw) => gw.textTertiary,
        GeniusWalletColors.textTertiary,
      ),
      'textDisabled': (
        (gw) => gw.textDisabled,
        GeniusWalletColors.textDisabled,
      ),
      'textOnBrand': ((gw) => gw.textOnBrand, GeniusWalletColors.textOnBrand),
      'borderBrand': ((gw) => gw.borderBrand, GeniusWalletColors.borderBrand),
      'statusWarning': (
        (gw) => gw.statusWarning,
        GeniusWalletColors.statusWarning,
      ),
      'statusInfo': ((gw) => gw.statusInfo, GeniusWalletColors.statusInfo),
      'brandGreen': ((gw) => gw.brandGreen, GeniusWalletColors.brandGreen),
      'brandGreenStrong': (
        (gw) => gw.brandGreenStrong,
        GeniusWalletColors.brandGreenStrong,
      ),
      'brandGreenMuted': (
        (gw) => gw.brandGreenMuted,
        GeniusWalletColors.brandGreenMuted,
      ),
      'brandGreenSubtle': (
        (gw) => gw.brandGreenSubtle,
        GeniusWalletColors.brandGreenSubtle,
      ),
    };

    for (final mode in GWAppearanceMode.values) {
      test('every fixed token, constructed via the $mode factory', () {
        setAppearance(mode);
        final gw = currentGwColors();
        for (final entry in fixedFields.entries) {
          final (accessor, expected) = entry.value;
          expect(accessor(gw), expected, reason: '${entry.key} in $mode mode');
        }
      });
    }
  });

  group('Appearance-aware new tokens match legacy per-mode', () {
    test('btnFilter -- light', () {
      setAppearance(GWAppearanceMode.light);
      expect(GWColors.light().btnFilter, const Color(0xFFEFF2F6));
      expect(GWColors.light().btnFilter, GeniusWalletColors.btnFilter);
    });

    test('btnFilter -- dark', () {
      setAppearance(GWAppearanceMode.dark);
      expect(GWColors.dark().btnFilter, const Color.fromARGB(255, 19, 33, 53));
      expect(GWColors.dark().btnFilter, GeniusWalletColors.btnFilter);
    });

    test('brandPrimaryOnSurface -- light', () {
      setAppearance(GWAppearanceMode.light);
      expect(GWColors.light().brandPrimaryOnSurface, const Color(0xFF0A6885));
      expect(
        GWColors.light().brandPrimaryOnSurface,
        GeniusWalletColors.brandPrimaryOnSurface,
      );
    });

    test('brandPrimaryOnSurface -- dark', () {
      setAppearance(GWAppearanceMode.dark);
      expect(
        GWColors.dark().brandPrimaryOnSurface,
        GeniusWalletColors.brandPrimaryStrong,
      );
      expect(
        GWColors.dark().brandPrimaryOnSurface,
        GeniusWalletColors.brandPrimaryOnSurface,
      );
    });
  });

  group(
    'Documented AA divergence -- textSecondary/statusSuccess/statusError',
    () {
      // These three pre-exist GWColors (not part of the 23-01 token map's new
      // rows) and are DELIBERATELY overridden in light mode for WCAG AA --
      // see the field docs in gw_colors.dart. This is not a parity gap; it is
      // the one place light mode intentionally does NOT match the legacy
      // mode-invariant constant. Recorded here so a future reader sees the
      // divergence is asserted, not merely unassertable.
      test('light mode diverges from the legacy mode-invariant value', () {
        setAppearance(GWAppearanceMode.light);
        final gw = GWColors.light();
        expect(gw.textSecondary, const Color(0xFF5A606E));
        expect(gw.statusSuccess, const Color(0xFF07875F));
        expect(gw.statusError, const Color(0xFFD92D2D));
      });

      test('dark mode matches the legacy mode-invariant value', () {
        setAppearance(GWAppearanceMode.dark);
        final gw = GWColors.dark();
        expect(gw.textSecondary, GeniusWalletColors.textSecondary);
        expect(gw.statusSuccess, const Color(0xFF0AD89C));
        expect(gw.statusError, const Color(0xFFFF4D4D));
      });
    },
  );
}
