import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/nav_chip_style.dart';

/// WCAG relative-luminance contrast ratio. Uses [Color.computeLuminance],
/// Flutter's built-in WCAG-relative-luminance implementation, so this is
/// just the standard (L1+0.05)/(L2+0.05) formula, no reimplementation of the
/// luminance math itself.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  testWidgets('navChipShell pins height 40 and radiusMd shape', (tester) async {
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

    final style = navChipShell(capturedContext);

    final minSize = style.minimumSize?.resolve({});
    final maxSize = style.maximumSize?.resolve({});
    expect(minSize?.height, 40);
    expect(maxSize?.height, 40);

    final shape = style.shape?.resolve({}) as RoundedRectangleBorder?;
    final radius = shape?.borderRadius as BorderRadius?;
    expect(radius?.topLeft.x, GeniusWalletConsts.radiusMd);
  });

  testWidgets('chip RENDERS exactly 40px even under an ambient compact theme', (
    tester,
  ) async {
    // Desktop's adaptivePlatformDensity is compact; its -8 minHeight
    // adjustment previously collapsed the chip to ~32px (8px shorter than
    // Buy GNUS's hard 40). navChipShell now pins standard density, so the
    // rendered box must be exactly 40 regardless of the ambient theme.
    // This asserts the RENDERED size (getSize), not just the style props --
    // the property-only check above passed while the box was still 32.
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(visualDensity: VisualDensity.compact),
        home: Scaffold(
          body: Center(
            child: Builder(
              builder: (context) => TextButton(
                style: navChipShell(context),
                onPressed: () {},
                child: const Text('0x1234'),
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(TextButton)).height, 40);
  });

  testWidgets(
    'navContextChipStyle: transparent/borderless at rest, brand tint + brand '
    'hairline on hover, pinned to 36px pill (039-B track, 044-3 hover)',
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

      final style = navContextChipStyle(capturedContext);
      // No GWColors ThemeExtension registered on the default MaterialApp
      // theme -- navContextChipStyle fails soft to GWColors.dark(), so
      // compare against that same fallback instance.
      final gw = GWColors.dark();

      final restBackground = style.backgroundColor?.resolve({});
      expect(restBackground, Colors.transparent);

      final hoverBackground = style.backgroundColor?.resolve({
        WidgetState.hovered,
      });
      // THE app-wide hover recipe (sketch 044 variant 3, 2026-07-26): brand
      // tint, not a neutral surface fill. Was gw.surfaceElevated, which is
      // exactly the drift this shared recipe exists to prevent.
      expect(hoverBackground, GWDecorations.hoverFill);

      final hoverSide = style.side?.resolve({WidgetState.hovered});
      expect(
        hoverSide?.color,
        GWDecorations.hoverEdge,
        reason: 'hover draws the shared brand hairline',
      );

      // The track (not the chip) now carries the one hairline border --
      // three bordered chips inside a bordered track was the "five things"
      // problem 039-B exists to kill.
      final restSide = style.side?.resolve({});
      expect(restSide, BorderSide.none);

      final minSize = style.minimumSize?.resolve({});
      final maxSize = style.maximumSize?.resolve({});
      expect(minSize?.height, 36);
      expect(maxSize?.height, 36);

      final shape = style.shape?.resolve({}) as RoundedRectangleBorder?;
      final radius = shape?.borderRadius as BorderRadius?;
      expect(radius?.topLeft.x, GeniusWalletConsts.radiusPill);
    },
  );

  test('Connect brand colors clear 4.5:1 AA in both modes', () {
    // Module-level default appearance is dark; flip to light for the light
    // assertions and restore dark in addTearDown so test-order coupling
    // cannot leak into later tests.
    GWAppearance.instance.value = GWAppearanceMode.light;
    addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);

    // Light: token against all three consumer surfaces, not white alone --
    // white alone is exactly the check that let the superseded #0B6E8F's
    // surfaceBase miss (4.35:1) go unnoticed.
    expect(
      contrastRatio(
        GeniusWalletColors.brandPrimaryOnSurface,
        const Color(0xFFFFFFFF), // surfaceElevated
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(
        GeniusWalletColors.brandPrimaryOnSurface,
        const Color(0xFFEFF2F6), // surfaceMenu
      ),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrastRatio(
        GeniusWalletColors.brandPrimaryOnSurface,
        const Color(0xFFDCE0E6), // surfaceBase
      ),
      greaterThanOrEqualTo(4.5),
    );

    GWAppearance.instance.value = GWAppearanceMode.dark;

    // Dark: token (brandPrimaryStrong) on the dark surfaceElevated
    // (0xFF0C0E14).
    expect(
      contrastRatio(
        GeniusWalletColors.brandPrimaryOnSurface,
        const Color(0xFF0C0E14),
      ),
      greaterThanOrEqualTo(4.5),
    );
  });
}
