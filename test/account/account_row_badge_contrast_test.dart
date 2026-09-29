// The account tree's row tags ("Selected", "On node", "Switching…", "SDK",
// "SDK PENDING") are all GWRowBadge: label text at the badge's own colour, on
// a 12% wash of that same colour. Proven here against the wash alone, and against that
// same wash further composited on GWSelectRow's own selection tint -- the
// one background a tagged row can actually sit on.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

void main() {
  const badgeWashAlpha = 0.12;
  const bodyTextFloor = 4.5;

  // GWSelectRow._selectionTint's own two gradient stops -- copied, not
  // imported (private to that file), so a change to that gradient has to
  // update both.
  const selectionTintStops = [Color(0x2E0AD89C), Color(0x2E0AAEE6)];

  void checkBadge(String label, GWColors gw, Color color, String mode) {
    final wash = color.withValues(alpha: badgeWashAlpha);

    final plain = Color.alphaBlend(wash, gw.surfaceElevated);
    expect(
      contrastRatio(color, plain),
      greaterThanOrEqualTo(bodyTextFloor),
      reason:
          '$label badge $color on its own wash over surfaceElevated '
          'in $mode mode',
    );

    for (final stop in selectionTintStops) {
      final selectedSurface = Color.alphaBlend(stop, gw.surfaceElevated);
      final composited = Color.alphaBlend(wash, selectedSurface);
      expect(
        contrastRatio(color, composited),
        greaterThanOrEqualTo(bodyTextFloor),
        reason:
            '$label badge $color on its wash over the selection tint '
            '($stop) in $mode mode',
      );
    }
  }

  for (final mode in GWAppearanceMode.values) {
    test(
      'Selected / SDK (brandPrimaryBadgeText) wash clears 4.5:1 -- $mode',
      () {
        final gw = themeFor(mode).extension<GWColors>()!;
        checkBadge('Selected/SDK', gw, gw.brandPrimaryBadgeText, '$mode');
      },
    );

    test('On node (statusSuccessText) wash clears 4.5:1 -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      checkBadge('Earning', gw, gw.statusSuccessText, '$mode');
    });

    test('SDK PENDING (statusWarningText) wash clears 4.5:1 -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      checkBadge('Setting up', gw, gw.statusWarningText, '$mode');
    });

    test('Switching… (statusWarningText) wash clears 4.5:1 -- $mode', () {
      final gw = themeFor(mode).extension<GWColors>()!;
      checkBadge('Switching…', gw, gw.statusWarningText, '$mode');
    });
  }
}
