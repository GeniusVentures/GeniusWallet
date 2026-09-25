import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

/// `statusSuccessText`/`statusErrorText` clear 4.5:1 on every plain surface
/// and every status wash a pill label sits on. Washes are translucent, so
/// each is composited over its backdrop first.
void main() {
  const bodyTextFloor = 4.5;
  const washAlphas = [0.12, 0.14, 0.15, 0.20];

  Map<String, Color> plainSurfacesOf(GWColors gw) => {
    'surfaceElevated': gw.surfaceElevated,
    'surfaceMenu': gw.surfaceMenu,
    'surfaceBase': gw.surfaceBase,
    'surfaceSunken': gw.surfaceSunken,
  };

  Map<String, Color> washSurfacesOf(GWColors gw) => {
    'surfaceElevated': gw.surfaceElevated,
    'surfaceBase': gw.surfaceBase,
  };

  final tones = <String, ({Color raw, Color text})>{};

  for (final mode in GWAppearanceMode.values) {
    test('$mode: text tokens clear 4.5:1 on every plain surface', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      tones['success'] = (raw: gw.statusSuccess, text: gw.statusSuccessText);
      tones['error'] = (raw: gw.statusError, text: gw.statusErrorText);

      for (final tone in tones.entries) {
        for (final surface in plainSurfacesOf(gw).entries) {
          final ratio = contrastRatio(tone.value.text, surface.value);
          expect(
            ratio,
            greaterThanOrEqualTo(bodyTextFloor),
            reason:
                '${tone.key}Text on ${surface.key} is '
                '${ratio.toStringAsFixed(2)}:1 in $mode mode, under the '
                '$bodyTextFloor:1 body-text floor.',
          );
        }
      }
    });

    test('$mode: text tokens clear 4.5:1 on their own tinted wash', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      tones['success'] = (raw: gw.statusSuccess, text: gw.statusSuccessText);
      tones['error'] = (raw: gw.statusError, text: gw.statusErrorText);

      for (final tone in tones.entries) {
        for (final surface in washSurfacesOf(gw).entries) {
          for (final alpha in washAlphas) {
            final wash = tone.value.raw.withValues(alpha: alpha);
            final composited = Color.alphaBlend(wash, surface.value);
            final ratio = contrastRatio(tone.value.text, composited);
            expect(
              ratio,
              greaterThanOrEqualTo(bodyTextFloor),
              reason:
                  '${tone.key}Text on a ${(alpha * 100).round()}% wash '
                  'over ${surface.key} is ${ratio.toStringAsFixed(2)}:1 '
                  'in $mode mode, under the $bodyTextFloor:1 floor.',
            );
          }
        }
      }
    });
  }

  test('raw statusSuccess on light surfaceMenu is why this token exists', () {
    // Pins the defect statusSuccessText was added to fix. If a future retune
    // makes the raw fill token itself AA-safe as text on surfaceMenu, this
    // test fails and the call-site swap this plan makes can be reconsidered.
    final light = themeFor(GWAppearanceMode.light).extension<GWColors>()!;

    expect(
      contrastRatio(light.statusSuccess, light.surfaceMenu),
      lessThan(bodyTextFloor),
      reason:
          'statusSuccess now clears AA as text on light surfaceMenu -- '
          'the statusSuccessText swap may no longer be load-bearing there.',
    );
  });
}
