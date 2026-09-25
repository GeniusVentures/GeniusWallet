import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

// Reuse the single existing themeFor helper -- do not add a second
// implementation.
import 'theme_contrast_test.dart' show themeFor;

/// Every slot of [TextTheme], by name, so a failure names the slot rather
/// than an index.
Map<String, TextStyle?> _slotsOf(TextTheme textTheme) => {
  'displayLarge': textTheme.displayLarge,
  'displayMedium': textTheme.displayMedium,
  'displaySmall': textTheme.displaySmall,
  'headlineLarge': textTheme.headlineLarge,
  'headlineMedium': textTheme.headlineMedium,
  'headlineSmall': textTheme.headlineSmall,
  'titleLarge': textTheme.titleLarge,
  'titleMedium': textTheme.titleMedium,
  'titleSmall': textTheme.titleSmall,
  'bodyLarge': textTheme.bodyLarge,
  'bodyMedium': textTheme.bodyMedium,
  'bodySmall': textTheme.bodySmall,
  'labelLarge': textTheme.labelLarge,
  'labelMedium': textTheme.labelMedium,
  'labelSmall': textTheme.labelSmall,
};

/// The [RichText] Flutter paints under a [Text] finder -- reading its
/// resolved style is how a widget's ACTUAL rendered font is proven, rather
/// than trusting whatever style the call site claims to pass.
TextStyle _resolvedStyleOf(WidgetTester tester, Finder textFinder) {
  final richText = tester.widget<RichText>(
    find.descendant(of: textFinder, matching: find.byType(RichText)).first,
  );
  return richText.text.style!;
}

void main() {
  for (final mode in GWAppearanceMode.values) {
    test('all 15 TextTheme slots resolve to Inter -- $mode', () {
      final slots = _slotsOf(themeFor(mode).textTheme);
      for (final slot in slots.entries) {
        expect(
          slot.value?.fontFamily,
          'Inter',
          reason:
              '${slot.key} resolved fontFamily ${slot.value?.fontFamily} in '
              '$mode mode, not Inter.',
        );
      }
    });

    testWidgets('a bare ActionChip label resolves Inter -- $mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeFor(mode),
          home: Scaffold(
            body: ActionChip(label: const Text('chip label'), onPressed: () {}),
          ),
        ),
      );

      final style = _resolvedStyleOf(tester, find.text('chip label'));
      expect(style.fontFamily, 'Inter');
    });

    testWidgets('a bare AlertDialog title resolves Inter -- $mode', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themeFor(mode),
          home: const AlertDialog(title: Text('dialog title')),
        ),
      );

      final style = _resolvedStyleOf(tester, find.text('dialog title'));
      expect(style.fontFamily, 'Inter');
    });

    test('mapped slots keep their size -- $mode', () {
      final textTheme = themeFor(mode).textTheme;
      expect(textTheme.labelMedium!.fontSize, 13);
      expect(textTheme.bodySmall!.fontSize, 14);
    });
  }
}
