import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/web/web_view_linux.dart';

Widget _app(GWColors colors) => MaterialApp(
  theme: ThemeData(extensions: [colors]),
  home: Builder(
    builder: (context) => Scaffold(
      body: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const Scaffold(body: WebPageCloseButton()),
          ),
        ),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  testWidgets('tapping the control pops the route it sits on', (tester) async {
    await tester.pumpWidget(_app(GWColors.dark()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(WebPageCloseButton), findsOneWidget);

    await tester.tap(find.byTooltip('Close'));
    await tester.pumpAndSettle();

    expect(find.byType(WebPageCloseButton), findsNothing);
    expect(find.text('open'), findsOneWidget);
  });

  testWidgets('it is labelled Close for assistive technology', (tester) async {
    await tester.pumpWidget(_app(GWColors.light()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Close'), findsWidgets);
  });

  for (final entry in {
    'light': GWColors.light(),
    'dark': GWColors.dark(),
  }.entries) {
    testWidgets('icon uses textPrimary in ${entry.key} mode', (tester) async {
      await tester.pumpWidget(_app(entry.value));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final icon = tester.widget<Icon>(
        find.descendant(
          of: find.byType(WebPageCloseButton),
          matching: find.byIcon(Icons.cancel),
        ),
      );
      expect(icon.color, entry.value.textPrimary);
    });
  }
}
