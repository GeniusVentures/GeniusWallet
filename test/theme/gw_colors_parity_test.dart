import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/gw_context_extension.dart';

// THIS FILE IS THE LOAD-BEARING PROOF OF THE ENTIRE COLOUR WORKSTREAM.
//
// Phase 23 has no golden/snapshot baseline (declined, see 23-CONTEXT.md § "NO
// GOLDEN TESTS"). The proof that 23-02's 260+ call-site rewrite painted
// nothing differently was VALUE EQUALITY, not pixel comparison: every token
// resolving to an identical `Color` reading it through the old
// `GeniusWalletColors` static path or the new `GWColors` extension path, in
// BOTH appearance modes, proved an AST codemod that only rewrites the
// *access path* could not change what gets painted.
//
// 23-04 UPDATE: `GeniusWalletColors` is now a private `part of` `gw_colors.dart`
// (23-04-PLAN.md Task 2) -- its members are unreachable from this file, which
// lives outside `lib/theme/` on purpose (a test file must not be part of the
// production library it tests). The comparisons below are now pinned against
// FROZEN LITERAL values instead of a live `GeniusWalletColors.<field>` read.
// This is not a weaker guard: every literal here was captured from the exact
// `GeniusWalletColors` source this file used to read live, so a value drift
// still fails here exactly as before. What moved inside the library boundary
// is the LIVE cross-check -- `gw_colors.dart`'s own `GWColors.light()`/
// `.dark()` factories carry the identical field-by-field `assert(...)`
// comparing the constructed instance against `GeniusWalletColors` from
// WITHIN the library, where private access remains legal. That assert (not
// this file) is now the thing that fires the moment a future edit changes one
// side and not the other; this file's job is only to pin what "correct"
// currently means, in the open.
//
// See `.planning/phases/23-.../23-01-TOKEN-MAP.md` for the full token map
// this file is driven by, including the one deliberate exclusion
// (`statusNeutral`) and the const-context risk list handed to 23-02.

/// Flips [GWAppearance] to [mode] for the current test, restoring dark (the
/// module-level default) via [addTearDown] -- mirrors
/// `theme_contrast_test.dart`'s `themeFor` helper so no later test file in
/// the same shard inherits a leaked appearance flip. Unlike `themeFor`, this
/// does not build a `ThemeData` -- the parity checks below compare `GWColors`
/// instances directly against frozen literal values, which is a cheaper and
/// more direct comparison than round-tripping through `getThemeData()`.
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
      'GWColors declares exactly 65 fields (21 pre-existing + 43 from the 23-01 token map + statusWarningText from the 23-03 follow-up)',
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
          statusWarningText: Colors.black,
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
    // legacy name -> (GWColors accessor, frozen literal). Every literal below
    // was captured verbatim from `GeniusWalletColors`'s source at the time
    // `GeniusWalletColors` became private (23-04) -- see this file's header
    // comment for why a live `GeniusWalletColors.<field>` read is no longer
    // possible from outside `lib/theme/`. Value is identical in both modes
    // for every field in this map, so a single comparison per mode covers the
    // "light value" and "dark value" columns of the token map simultaneously.
    final fixedFields = <String, (Color Function(GWColors), Color)>{
      'lightGreenPrimary': ((gw) => gw.lightGreenPrimary, Colors.greenAccent),
      'lightGreenSecondary': (
        (gw) => gw.lightGreenSecondary,
        const Color(0xFF54C48E),
      ),
      'mutedGreen': ((gw) => gw.mutedGreen, const Color(0xFF2EBE7B)),
      'deepBlueTertiary': (
        (gw) => gw.deepBlueTertiary,
        const Color(0xff05090F),
      ),
      'deepBlueCardColor': (
        (gw) => gw.deepBlueCardColor,
        const Color.fromRGBO(10, 18, 31, 1),
      ),
      'deepBlueMenu': ((gw) => gw.deepBlueMenu, const Color(0xff0F1B2E)),
      'deepBlue': ((gw) => gw.deepBlue, const Color.fromRGBO(20, 37, 61, 1)),
      'grayPrimary': (
        (gw) => gw.grayPrimary,
        const Color.fromRGBO(21, 30, 41, 1),
      ),
      'btnText': ((gw) => gw.btnText, const Color.fromRGBO(0, 9, 20, 1)),
      'btnDisabled': (
        (gw) => gw.btnDisabled,
        const Color.fromRGBO(188, 188, 188, 1),
      ),
      'btnTextDisabled': (
        (gw) => gw.btnTextDisabled,
        const Color.fromRGBO(101, 101, 101, 1),
      ),
      'btnGradientBlue': (
        (gw) => gw.btnGradientBlue,
        const Color.fromRGBO(0, 104, 239, 1),
      ),
      'btnGradientGreen': (
        (gw) => gw.btnGradientGreen,
        const Color.fromRGBO(1, 221, 166, 1),
      ),
      'btnFilterSelected': (
        (gw) => gw.btnFilterSelected,
        Colors.greenAccent.withValues(alpha: 0.1),
      ),
      'foundationError': ((gw) => gw.foundationError, const Color(0xff920000)),
      'borderGrey': (
        (gw) => gw.borderGrey,
        const Color.fromRGBO(255, 255, 255, 0.30),
      ),
      'brandPrimary': ((gw) => gw.brandPrimary, const Color(0xFF14C8FF)),
      'brandPrimaryStrong': (
        (gw) => gw.brandPrimaryStrong,
        const Color(0xFF0AAEE6),
      ),
      'brandPrimaryMuted': (
        (gw) => gw.brandPrimaryMuted,
        const Color(0xFF14C8FF).withAlpha(61),
      ),
      'brandPrimarySubtle': (
        (gw) => gw.brandPrimarySubtle,
        const Color(0xFF14C8FF).withAlpha(31),
      ),
      'brandSecondary': ((gw) => gw.brandSecondary, const Color(0xFF2BF5B4)),
      'brandSecondaryStrong': (
        (gw) => gw.brandSecondaryStrong,
        const Color(0xFF0AD89C),
      ),
      'brandSecondaryBright': (
        (gw) => gw.brandSecondaryBright,
        const Color(0xFF5BFFD0),
      ),
      'brandSecondaryMuted': (
        (gw) => gw.brandSecondaryMuted,
        const Color(0xFF2BF5B4).withAlpha(61),
      ),
      'brandSecondarySubtle': (
        (gw) => gw.brandSecondarySubtle,
        const Color(0xFF2BF5B4).withAlpha(31),
      ),
      'brandTertiary': ((gw) => gw.brandTertiary, const Color(0xFFC28FFF)),
      'brandTertiaryMuted': (
        (gw) => gw.brandTertiaryMuted,
        const Color(0xFFC28FFF).withAlpha(61),
      ),
      'brandTertiarySubtle': (
        (gw) => gw.brandTertiarySubtle,
        const Color(0xFFC28FFF).withAlpha(31),
      ),
      'gradientBlue': ((gw) => gw.gradientBlue, const Color(0xFF0AAEE6)),
      'gradientGreen': ((gw) => gw.gradientGreen, const Color(0xFF0AD89C)),
      'gray500': ((gw) => gw.gray500, const Color(0xFF8A8F9D)),
      'textTertiary': (
        (gw) => gw.textTertiary,
        const Color.fromARGB(255, 53, 54, 61),
      ),
      'textDisabled': ((gw) => gw.textDisabled, const Color(0xFF2A2B31)),
      'textOnBrand': ((gw) => gw.textOnBrand, const Color(0xFF000B18)),
      'borderBrand': ((gw) => gw.borderBrand, const Color(0xFF14C8FF)),
      'statusWarning': ((gw) => gw.statusWarning, const Color(0xFFFFC42E)),
      'statusInfo': ((gw) => gw.statusInfo, const Color(0xFF14C8FF)),
      'brandGreen': ((gw) => gw.brandGreen, const Color(0xFF2BF5B4)),
      'brandGreenStrong': (
        (gw) => gw.brandGreenStrong,
        const Color(0xFF0AD89C),
      ),
      'brandGreenMuted': (
        (gw) => gw.brandGreenMuted,
        const Color(0xFF2BF5B4).withAlpha(61),
      ),
      'brandGreenSubtle': (
        (gw) => gw.brandGreenSubtle,
        const Color(0xFF2BF5B4).withAlpha(31),
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
    // Frozen literals (see header comment) -- both pinned values in each
    // pair used to be cross-checked against a live GeniusWalletColors read;
    // they now pin the same two known-good values against each other.
    test('btnFilter -- light', () {
      setAppearance(GWAppearanceMode.light);
      expect(GWColors.light().btnFilter, const Color(0xFFEFF2F6));
    });

    test('btnFilter -- dark', () {
      setAppearance(GWAppearanceMode.dark);
      expect(GWColors.dark().btnFilter, const Color.fromARGB(255, 19, 33, 53));
    });

    test('brandPrimaryOnSurface -- light', () {
      setAppearance(GWAppearanceMode.light);
      expect(GWColors.light().brandPrimaryOnSurface, const Color(0xFF0A6885));
    });

    test('brandPrimaryOnSurface -- dark', () {
      setAppearance(GWAppearanceMode.dark);
      // Dark brandPrimaryOnSurface is documented to equal brandPrimaryStrong.
      expect(
        GWColors.dark().brandPrimaryOnSurface,
        GWColors.dark().brandPrimaryStrong,
      );
      expect(GWColors.dark().brandPrimaryOnSurface, const Color(0xFF0AAEE6));
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
        // gray500/textSecondary's mode-invariant legacy value (frozen
        // literal -- see header comment).
        expect(gw.textSecondary, const Color(0xFF8A8F9D));
        expect(gw.statusSuccess, const Color(0xFF0AD89C));
        expect(gw.statusError, const Color(0xFFFF4D4D));
      });
    },
  );

  group('context.gw accessor', () {
    testWidgets(
      'inside the app\'s real theme, returns the registered GWColors',
      (tester) async {
        setAppearance(GWAppearanceMode.dark);
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(extensions: [GWColors.dark()]),
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final registered = Theme.of(capturedContext).extension<GWColors>();
        expect(registered, isNotNull);
        expect(capturedContext.gw, registered);
        expect(capturedContext.gw.surfaceBase, registered!.surfaceBase);
      },
    );

    testWidgets(
      'inside a bare MaterialApp with no extension registered, falls back '
      'without throwing',
      (tester) async {
        late BuildContext capturedContext;
        await tester.pumpWidget(
          MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(Theme.of(capturedContext).extension<GWColors>(), isNull);
        expect(() => capturedContext.gw, returnsNormally);
        expect(capturedContext.gw.surfaceBase, GWColors.dark().surfaceBase);
      },
    );
  });
}
