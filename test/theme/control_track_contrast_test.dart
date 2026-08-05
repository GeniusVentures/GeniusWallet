import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper rather than adding a third
// implementation (`theme_contrast_test.dart`'s own doc comment: "do not add
// a second implementation"); `compute_contrast_test.dart` imports it the
// same way.
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

/// The check owed by `textMutedOnSunken`.
///
/// Every `GWControlTrack` consumer paints its UNSELECTED chip label directly
/// on `surfaceSunken`. `textSecondary` -- the token they all used before --
/// is calibrated against the page and card canvases, not against the sunken
/// well, and measured 4.23:1 there in light mode. This file is what fails if
/// anyone points a chip label back at `textSecondary`, or retunes either
/// token without re-measuring the pairing.
///
/// 4.5:1 is the correct floor, not 3:1: the chip label is 12px `w600`, and
/// WCAG large text starts at 18.66px bold.
void main() {
  const bodyTextFloor = 4.5;

  for (final mode in GWAppearanceMode.values) {
    test(
      'unselected control-track label clears AA on surfaceSunken -- $mode',
      () {
        final gw = themeFor(mode).extension<GWColors>()!;
        final ratio = contrastRatio(gw.textMutedOnSunken, gw.surfaceSunken);

        expect(
          ratio,
          greaterThanOrEqualTo(bodyTextFloor),
          reason:
              'textMutedOnSunken=${gw.textMutedOnSunken} on '
              'surfaceSunken=${gw.surfaceSunken} is ${ratio.toStringAsFixed(2)}:1 '
              'in $mode mode, under the $bodyTextFloor:1 body-text floor.',
        );
      },
    );
  }

  test('textSecondary on surfaceSunken is why this token exists', () {
    // Pins the defect this token was added to fix. If a future retune makes
    // textSecondary itself AA-safe on the sunken well, this test fails and
    // textMutedOnSunken can be deleted rather than quietly kept forever.
    final light = themeFor(GWAppearanceMode.light).extension<GWColors>()!;

    expect(
      contrastRatio(light.textSecondary, light.surfaceSunken),
      lessThan(bodyTextFloor),
      reason:
          'textSecondary now clears AA on light surfaceSunken -- '
          'textMutedOnSunken is redundant and should be removed.',
    );
  });
}
