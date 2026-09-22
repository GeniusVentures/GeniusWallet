import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper rather than adding a third
// implementation (`theme_contrast_test.dart`'s own doc comment: "do not add
// a second implementation").
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

/// The checks owed by `GWCheckbox` and `GWSwitch`'s disabled states.
///
/// `borderControl` and `borderSubtle` are both translucent, so each must be
/// composited over the surface it sits on (`Color.alphaBlend`) before its
/// luminance is meaningful -- `computeLuminance()` ignores alpha.
void main() {
  const uiFloor = 3.0;

  Map<String, Color> surfacesOf(GWColors gw) => {
    'surfaceElevated': gw.surfaceElevated,
    'surfaceMenu': gw.surfaceMenu,
    'surfaceBase': gw.surfaceBase,
  };

  for (final mode in GWAppearanceMode.values) {
    test('disabled checkbox side/fill (borderControl) clears 3:1 -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      for (final surface in surfacesOf(gw).entries) {
        final composited = Color.alphaBlend(gw.borderControl, surface.value);
        final ratio = contrastRatio(composited, surface.value);
        expect(
          ratio,
          greaterThanOrEqualTo(uiFloor),
          reason:
              'disabled borderControl ${gw.borderControl} composited over '
              '${surface.key} ${surface.value} is ${ratio.toStringAsFixed(2)}:1 '
              'in $mode mode, under the $uiFloor:1 non-text floor.',
        );
      }
    });

    test(
      'checkmark (textPrimary) clears 3:1 on the disabled fill -- $mode',
      () {
        final gw = themeFor(mode).extension<GWColors>()!;
        for (final surface in surfacesOf(gw).entries) {
          final fill = Color.alphaBlend(gw.borderControl, surface.value);
          final ratio = contrastRatio(gw.textPrimary, fill);
          expect(
            ratio,
            greaterThanOrEqualTo(uiFloor),
            reason:
                'checkmark ${gw.textPrimary} on the disabled fill $fill '
                '(${surface.key}) is ${ratio.toStringAsFixed(2)}:1 in $mode '
                'mode, under the $uiFloor:1 non-text floor.',
          );
        }
      },
    );

    test('disabled switch thumb clears 3:1 against its track -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      final ratio = contrastRatio(gw.textSecondary, gw.surfaceMenu);
      expect(
        ratio,
        greaterThanOrEqualTo(uiFloor),
        reason:
            'disabled thumb ${gw.textSecondary} vs track ${gw.surfaceMenu} '
            'is ${ratio.toStringAsFixed(2)}:1 in $mode mode.',
      );
    });

    test('disabled switch outline clears 3:1 against its track -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      final composited = Color.alphaBlend(gw.borderControl, gw.surfaceMenu);
      final ratio = contrastRatio(composited, gw.surfaceMenu);
      expect(
        ratio,
        greaterThanOrEqualTo(uiFloor),
        reason:
            'disabled outline ${gw.borderControl} composited over track '
            '${gw.surfaceMenu} is ${ratio.toStringAsFixed(2)}:1 in $mode mode.',
      );
    });

    test(
      'disabled switch thumb differs from the enabled-off thumb -- $mode',
      () {
        final gw = themeFor(mode).extension<GWColors>()!;
        final ratio = contrastRatio(gw.textSecondary, gw.textPrimary);
        expect(
          ratio,
          greaterThanOrEqualTo(2.9),
          reason:
              'disabled thumb ${gw.textSecondary} vs the enabled-off thumb '
              '${gw.textPrimary} is only ${ratio.toStringAsFixed(2)}:1 in '
              '$mode mode -- disabled could be mistaken for merely off.',
        );
      },
    );

    test('borderSubtle stays below 3:1 on every surface -- $mode', () {
      // Pins the defect this fix exists for. If a future retune makes
      // borderSubtle itself AA-safe as a control edge, this test fails and
      // the borderControl swap in GWCheckbox/GWSwitch can be revisited
      // rather than kept forever.
      final gw = themeFor(mode).extension<GWColors>()!;
      for (final surface in surfacesOf(gw).entries) {
        final composited = Color.alphaBlend(gw.borderSubtle, surface.value);
        final ratio = contrastRatio(composited, surface.value);
        expect(
          ratio,
          lessThan(uiFloor),
          reason:
              'borderSubtle now clears $uiFloor:1 on ${surface.key} in '
              '$mode mode -- the borderControl disabled-state fix may be '
              'redundant.',
        );
      }
    });
  }
}
