import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../theme/theme_contrast_test.dart' show themeFor;

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<AnimatedContainer>(
    find.byType(AnimatedContainer),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  for (final mode in GWAppearanceMode.values) {
    testWidgets('disabled primary is a flat tint, loading keeps the gradient '
        '-- $mode', (tester) async {
      final theme = themeFor(mode);
      final gw = theme.extension<GWColors>()!;

      Future<void> pump({VoidCallback? onPressed, bool isLoading = false}) {
        return tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GWButton(
                variant: GWButtonVariant.primary,
                label: 'Go',
                onPressed: onPressed,
                isLoading: isLoading,
              ),
            ),
          ),
        );
      }

      await pump();
      expect(_decoration(tester).gradient, isNull);
      expect(_decoration(tester).color, gw.textPrimary12);
      expect(
        tester.widget<Text>(find.text('Go')).style!.color,
        gw.textPrimary54,
      );

      await pump(onPressed: () {}, isLoading: true);
      expect(_decoration(tester).gradient, isNotNull);

      await pump(onPressed: () {});
      expect(_decoration(tester).gradient, isNotNull);
    });
  }
}
