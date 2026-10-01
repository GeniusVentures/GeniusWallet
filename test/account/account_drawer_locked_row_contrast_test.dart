// The account tree's own locked-row dimming (title, subtitle, leading icon)
// must clear the same 3:1 non-text floor GWMenuItem's disabled items were
// fixed to clear, on the same 0.8 alpha -- proven directly against the
// token math since GWSelectRow's title/subtitle are private to
// account_drawer.dart. A locked row can also be the selected one, so this
// also has to clear 3:1 painted over GWSelectRow's own selection tint, not
// just the bare panel.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

void main() {
  const lockedAlpha = 0.8;
  const nonTextFloor = 3.0;

  // GWSelectRow._selectionTint's own two gradient stops -- copied, not
  // imported (private to that file), so a change to that gradient has to
  // update both.
  const selectionTintStops = [Color(0x2E0AD89C), Color(0x2E0AAEE6)];

  for (final mode in GWAppearanceMode.values) {
    test(
      'locked-row textSecondary@80% clears 3:1 on surfaceElevated -- $mode',
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

    test('locked-row textSecondary@80% clears 3:1 on the selection tint '
        '(selected and locked at once) -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      final dimmed = gw.textSecondary.withValues(alpha: lockedAlpha);

      for (final stop in selectionTintStops) {
        final selectedSurface = Color.alphaBlend(stop, gw.surfaceElevated);
        final effective = Color.alphaBlend(dimmed, selectedSurface);

        expect(
          contrastRatio(effective, selectedSurface),
          greaterThanOrEqualTo(nonTextFloor),
          reason:
              'locked-row foreground $effective on the selection tint '
              '($stop over ${gw.surfaceElevated}) in $mode mode',
        );
      }
    });
  }
}
