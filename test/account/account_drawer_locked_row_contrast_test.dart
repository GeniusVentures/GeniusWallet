// The account tree's own locked-row dimming (title, subtitle, leading icon)
// must clear the same 3:1 non-text floor GWMenuItem's disabled items were
// fixed to clear, on the same 0.7 alpha -- proven directly against the
// token math since GWSelectRow's title/subtitle are private to
// account_drawer.dart.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

void main() {
  const lockedAlpha = 0.7;
  const nonTextFloor = 3.0;

  for (final mode in GWAppearanceMode.values) {
    test(
      'locked-row textSecondary@70% clears 3:1 on surfaceElevated -- $mode',
      () {
        final gw = themeFor(mode).extension<GWColors>()!;
        final dimmed = gw.textSecondary.withValues(alpha: lockedAlpha);
        final effective = Color.alphaBlend(dimmed, gw.surfaceElevated);

        expect(
          contrastRatio(effective, gw.surfaceElevated),
          greaterThanOrEqualTo(nonTextFloor),
          reason:
              'locked-row foreground $effective on surfaceElevated '
              '${gw.surfaceElevated} in $mode mode',
        );
      },
    );
  }
}
