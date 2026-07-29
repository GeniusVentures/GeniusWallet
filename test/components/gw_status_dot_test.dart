// Check for GWStatusDot (Phase 14, the third consumer of the dot+label
// anatomy already shipped twice - transaction_displays.dart and
// order_status_style.dart).
//
// The failure this guards against: a row that grows past its 18px line box
// (which silently costs the compute panel's height budget), a trailing
// percentage that shifts the label sideways as its digit widths change, and a
// label that paints in the dot's colour when no [labelColor] was passed -
// that last one is the whole reason one widget can serve both a coloured pill
// and a neutral status row.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/data/gw_status_dot.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// `maxWidth`-only constraints are LOOSE: a `mainAxisSize.min` Row inside them
// shrinks to its content, and a `mainAxisSize.max` Row fills up to the cap.
// A `SizedBox(width: ...)` would instead hand the Row a TIGHT width and defeat
// the very distinction these tests exist to prove.
Widget _host(Widget child, {required double maxWidth}) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    ),
  ),
);

void main() {
  final gw = GWColors.dark();

  testWidgets('with no trailing value the row lays out at its minimum width', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GWStatusDot(color: Colors.blue, label: 'Ready'),
        maxWidth: 400,
      ),
    );

    final row = tester.widget<Row>(find.byType(Row));
    expect(row.mainAxisSize, MainAxisSize.min);

    // Minimum-width layout: the row is far narrower than the 400px it was
    // offered, because it sizes to its own content rather than filling.
    final rowWidth = tester.getSize(find.byType(Row)).width;
    expect(rowWidth, lessThan(200));
  });

  testWidgets(
    'with a trailing value the row fills its width and pushes the trailing '
    'value to the far end',
    (tester) async {
      const width = 300.0;
      await tester.pumpWidget(
        _host(
          const GWStatusDot(
            color: Colors.blue,
            label: 'Processing',
            trailingValue: '42%',
          ),
          maxWidth: width,
        ),
      );

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisSize, MainAxisSize.max);

      final rowRect = tester.getRect(find.byType(Row));
      expect(rowRect.width, moreOrLessEquals(width, epsilon: 0.5));

      final trailingRect = tester.getRect(find.text('42%'));
      expect(trailingRect.right, moreOrLessEquals(rowRect.right, epsilon: 0.5));
    },
  );

  testWidgets(
    'no label colour yields the primary text token rather than the dot '
    "colour",
    (tester) async {
      await tester.pumpWidget(
        _host(
          const GWStatusDot(color: Colors.orange, label: 'Ready'),
          maxWidth: 400,
        ),
      );

      final style = tester.widget<Text>(find.text('Ready')).style!;
      expect(style.color, gw.textPrimary);
      expect(style.color, isNot(Colors.orange));
    },
  );

  testWidgets('the rendered row measures 18 logical pixels tall', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GWStatusDot(
          color: Colors.blue,
          label: 'Processing',
          trailingValue: '5%',
        ),
        maxWidth: 300,
      ),
    );

    final height = tester.getSize(find.byType(GWStatusDot)).height;
    expect(height, moreOrLessEquals(18.0, epsilon: 0.1));
  });

  testWidgets(
    'a trailing percentage carries tabular figures so a changing value does '
    'not shift the label',
    (tester) async {
      await tester.pumpWidget(
        _host(
          const GWStatusDot(
            color: Colors.blue,
            label: 'Processing',
            trailingValue: '7%',
          ),
          maxWidth: 300,
        ),
      );

      final style = tester.widget<Text>(find.text('7%')).style!;
      expect(style.fontFeatures, contains(const FontFeature.tabularFigures()));
    },
  );

  testWidgets('the dot is 6px and the gap to the label is 5px by default', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const GWStatusDot(color: Colors.blue, label: 'Ready'),
        maxWidth: 400,
      ),
    );

    // Scoped to GWStatusDot's own subtree - MaterialApp/Scaffold contribute
    // Container and SizedBox instances of their own.
    final dot = tester.widget<Container>(
      find.descendant(
        of: find.byType(GWStatusDot),
        matching: find.byType(Container),
      ),
    );
    expect(dot.constraints, const BoxConstraints.tightFor(width: 6, height: 6));

    final gap = tester.widget<SizedBox>(
      find.descendant(
        of: find.byType(GWStatusDot),
        matching: find.byType(SizedBox),
      ),
    );
    expect(gap.width, 5);
  });
}
