import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/inputs/gw_switch.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

/// The enabled outline clears 3:1 against the ON and OFF track, both modes.
/// Two-stage blend: track over backdrop, then outline over that, because
/// `computeLuminance()` ignores alpha.
void main() {
  const uiFloor = 3.0;

  Map<String, Color> surfacesOf(GWColors gw) => {
    'surfaceBase': gw.surfaceBase,
    'surfaceElevated': gw.surfaceElevated,
    'surfaceMenu': gw.surfaceMenu,
    'surfaceSunken': gw.surfaceSunken,
  };

  for (final mode in GWAppearanceMode.values) {
    testWidgets('enabled switch outline clears 3:1 on both tracks -- $mode', (
      tester,
    ) async {
      final theme = themeFor(mode);
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Material(child: GWSwitch(value: true, onChanged: (_) {})),
        ),
      );

      final gw = theme.extension<GWColors>()!;
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      final trackColor = switchWidget.trackColor!;
      final outlineColor = switchWidget.trackOutlineColor!;

      for (final states in <Set<WidgetState>>[
        {WidgetState.selected},
        <WidgetState>{},
      ]) {
        final trackName = states.contains(WidgetState.selected) ? 'ON' : 'OFF';
        final track = trackColor.resolve(states)!;
        final outline = outlineColor.resolve(states)!;
        for (final surface in surfacesOf(gw).entries) {
          final trackComposite = Color.alphaBlend(track, surface.value);
          final composited = Color.alphaBlend(outline, trackComposite);
          final ratio = contrastRatio(composited, trackComposite);
          expect(
            ratio,
            greaterThanOrEqualTo(uiFloor),
            reason:
                'enabled outline $outline on the $trackName track $track '
                'composited over ${surface.key} is '
                '${ratio.toStringAsFixed(2)}:1 in $mode mode, under the '
                '$uiFloor:1 non-text floor.',
          );
        }
      }
    });
  }

  // Switch.adaptive keeps the Material painter on Apple platforms, so the
  // outline must still be stroked there, not just configured.
  for (final platform in [TargetPlatform.iOS, TargetPlatform.macOS]) {
    testWidgets('enabled outline is painted on ${platform.name}', (
      tester,
    ) async {
      final theme = themeFor(
        GWAppearanceMode.light,
      ).copyWith(platform: platform);
      final gw = theme.extension<GWColors>()!;
      await tester.pumpWidget(
        MaterialApp(
          theme: theme,
          home: Scaffold(
            body: Center(child: GWSwitch(value: false, onChanged: (_) {})),
          ),
        ),
      );
      expect(
        tester.renderObject(find.byType(Switch)),
        paints
          ..rrect()
          ..rrect(style: PaintingStyle.stroke, color: gw.borderControlOnBrand),
      );
    });
  }
}
