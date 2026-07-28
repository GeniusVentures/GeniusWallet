// Check for GWKicker (sketch 065, variant C · two steps).
//
// The failure this guards against is the one the component exists to end: the
// app carried FIVE hand-written values for one typographic role (10/11/13px,
// tracking 0.4-0.88) and they drifted because nothing tied them together. So
// the assertions pin the two steps by number, and — the part that actually
// matters — assert that `GWKicker.style()` returns exactly what the widget
// renders. Two call sites (the sortable Markets header, GWViewAllLink) consume
// the static style instead of the widget; if those two ever diverge, the drift
// is back with a component's name on it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: Scaffold(body: SizedBox(width: 400, child: child)),
);

TextStyle _styleOf(WidgetTester tester, String upperLabel) =>
    tester.widget<Text>(find.text(upperLabel)).style!;

void main() {
  testWidgets('default step is 13 / w600 / 0.5 and upper-cases its label', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const GWKicker('Transaction')));

    // Upper-casing belongs to the component: call sites pass natural casing.
    expect(find.text('TRANSACTION'), findsOneWidget);
    expect(find.text('Transaction'), findsNothing);

    final s = _styleOf(tester, 'TRANSACTION');
    expect(s.fontSize, 13);
    expect(s.fontWeight, FontWeight.w600);
    expect(s.letterSpacing, 0.5);
    expect(s.height, 18 / 13);
    expect(s.color, GWColors.dark().textSecondary);
  });

  testWidgets('dense step is 11 / w600 / 0.6', (tester) async {
    await tester.pumpWidget(_host(const GWKicker('Market cap', dense: true)));

    final s = _styleOf(tester, 'MARKET CAP');
    expect(s.fontSize, 11);
    expect(s.fontWeight, FontWeight.w600);
    expect(s.letterSpacing, 0.6);
    expect(s.height, 16 / 11);
  });

  testWidgets('the two steps are actually different sizes', (tester) async {
    // Guards the collapse this sketch rejected: if someone "simplifies" the
    // component back to one value, the Markets column header grows and this
    // fails rather than the layout quietly shifting.
    final gw = GWColors.dark();
    expect(
      GWKicker.style(gw, dense: true).fontSize,
      lessThan(GWKicker.style(gw).fontSize!),
    );
    expect(
      GWKicker.style(gw, dense: true).letterSpacing,
      greaterThan(GWKicker.style(gw).letterSpacing!),
    );
  });

  testWidgets('static style() matches what the widget renders, both steps', (
    tester,
  ) async {
    final gw = GWColors.dark();

    await tester.pumpWidget(_host(const GWKicker('Today')));
    expect(_styleOf(tester, 'TODAY'), GWKicker.style(gw));

    await tester.pumpWidget(_host(const GWKicker('Volume', dense: true)));
    expect(_styleOf(tester, 'VOLUME'), GWKicker.style(gw, dense: true));
  });

  testWidgets('trailing is pushed to the right edge; without one there is no Row',
      (tester) async {
    await tester.pumpWidget(
      _host(const GWKicker('Network', trailing: Icon(Icons.chevron_right))),
    );
    final host = tester.getRect(find.byType(GWKicker));
    final trailing = tester.getRect(find.byType(Icon));
    expect(trailing.right, moreOrLessEquals(host.right, epsilon: 0.5));

    // No trailing -> a bare Text, not a Row: the component must not reserve
    // width it has nothing to put in.
    await tester.pumpWidget(_host(const GWKicker('Network')));
    expect(
      find.descendant(of: find.byType(GWKicker), matching: find.byType(Row)),
      findsNothing,
    );
  });
}
