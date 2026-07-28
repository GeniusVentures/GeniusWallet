// The ONE check GWSelectRow owes (sketch 068-A).
//
// This row exists because two of the three pickers it replaces could not show
// you what was selected: Select Network passed `ListTile(selected: true)` with
// no theme behind it, which paints nothing, and Your Accounts painted a flat
// brand fill. So the assertion that matters is the one about selection being
// VISIBLE, and specifically about the part of it that carries WCAG 1.4.11.
//
// The tint (1.39:1) and the brand edge (1.60:1) are both below 3:1 on the
// drawer panel; only the check glyph (6.81:1) carries the state on its own. A
// change that drops the glyph and keeps the tint would look fine in a
// screenshot and fail the requirement, which is exactly the kind of regression
// a test is for.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _host({required bool selected}) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: 380,
        child: GWSelectRow(
          leading: const SizedBox(width: 36, height: 36),
          title: 'Ethereum',
          subtitle: 'ETH',
          selected: selected,
          onTap: () {},
        ),
      ),
    ),
  ),
);

/// The row's own decorated box - the one carrying the border and the tint.
BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(
    find.descendant(
      of: find.byType(GWSelectRow),
      matching: find.byType(Container),
    ),
  );
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('a selected row carries the check glyph, an unselected one does '
      'not', (tester) async {
    await tester.pumpWidget(_host(selected: false));
    expect(find.byIcon(Icons.check_circle), findsNothing);

    await tester.pumpWidget(_host(selected: true));
    expect(find.byIcon(Icons.check_circle), findsOneWidget);
  });

  testWidgets('selection is also the tint, so the row does not rely on the '
      'glyph alone', (tester) async {
    await tester.pumpWidget(_host(selected: false));
    expect(_decoration(tester).gradient, isNull);

    await tester.pumpWidget(_host(selected: true));
    expect(_decoration(tester).gradient, isNotNull);
  });

  testWidgets('the border width is identical selected and unselected', (
    tester,
  ) async {
    // The always-present transparent border is not a style choice: a row that
    // GAINS a 1px border on selection or hover shifts its own contents by a
    // pixel on every state change. Assert the geometry, not the colour.
    await tester.pumpWidget(_host(selected: false));
    final resting = _decoration(tester).border!.top.width;

    await tester.pumpWidget(_host(selected: true));
    final chosen = _decoration(tester).border!.top.width;

    expect(resting, chosen);
    expect(resting, 1);
  });
}
