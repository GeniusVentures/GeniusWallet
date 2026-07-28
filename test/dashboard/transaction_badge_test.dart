import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the existing WCAG helper rather than adding a third implementation
// (see its doc comment in test/theme/theme_contrast_test.dart).
import '../theme/theme_contrast_test.dart' show contrastRatio;

/// Builds the [GWColors] instance for [mode], restoring dark afterward so no
/// other test file inherits a flipped appearance (same discipline as
/// `themeFor` in theme_contrast_test.dart).
GWColors colorsFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return mode == GWAppearanceMode.light ? GWColors.light() : GWColors.dark();
}

void main() {
  group('every badge kind clears AA in both appearances', () {
    for (final mode in GWAppearanceMode.values) {
      for (final kind in TransactionBadgeKind.values) {
        test('${kind.name} glyph vs fill -- $mode', () {
          final gw = colorsFor(mode);
          final spec = badgeSpec(kind, gw);
          final glyph = badgeGlyphColor(spec.fill);
          expect(
            contrastRatio(glyph, spec.fill),
            greaterThanOrEqualTo(4.5),
            reason:
                '${kind.name} in $mode mode: glyph=$glyph on fill=${spec.fill}',
          );
        });
      }
    }
  });

  group('the locked fills are the locked values', () {
    final gw = GWColors.dark();
    test('sent + escrow are Slate #64748B', () {
      expect(
        badgeSpec(TransactionBadgeKind.sent, gw).fill.toARGB32(),
        0xFF64748B,
      );
      expect(
        badgeSpec(TransactionBadgeKind.escrow, gw).fill.toARGB32(),
        0xFF64748B,
      );
    });
    test('mint is brandTertiary #C28FFF', () {
      expect(
        badgeSpec(TransactionBadgeKind.mint, gw).fill.toARGB32(),
        0xFFC28FFF,
      );
    });
    test('job is brandPrimaryStrong #0AAEE6', () {
      expect(
        badgeSpec(TransactionBadgeKind.job, gw).fill.toARGB32(),
        0xFF0AAEE6,
      );
    });
    test('pending is statusWarning #FFC42E', () {
      expect(
        badgeSpec(TransactionBadgeKind.pending, gw).fill.toARGB32(),
        0xFFFFC42E,
      );
    });
  });

  group('mint and job carry the picked glyphs', () {
    final gw = GWColors.dark();
    // Sketch 012 recommended the opposite pairing; this was Jakub's explicit
    // override. Pinned so it is not "corrected" later.
    test('mint is the pickaxe SVG, not an IconData', () {
      final spec = badgeSpec(TransactionBadgeKind.mint, gw);
      expect(spec.svgAsset, 'assets/images/pickaxe.svg');
      expect(spec.icon, isNull);
    });
    test('job is Icons.dns', () {
      expect(badgeSpec(TransactionBadgeKind.job, gw).icon, Icons.dns);
    });
  });

  test('every kind has a spec', () {
    final gw = GWColors.dark();
    for (final kind in TransactionBadgeKind.values) {
      expect(badgeSpec(kind, gw).label, isNotEmpty, reason: kind.name);
    }
    expect(TransactionBadgeKind.values.length, 9);
  });
}
