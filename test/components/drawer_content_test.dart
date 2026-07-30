// The two runnable checks `drawer_content.dart` owes (21-01).
//
// Only two of the plan's five originally-named primitives are actually new
// here — see the file-head comment on `drawer_content.dart` for why
// `GWDrawerListRow`/`GWDrawerSection`/`GWDrawerDetailRow` are NOT rebuilt
// (they already exist, adopted, and tested, under `GWSelectRow` and
// `GWKicker`/`GWDetailGrid`). This file covers only what is actually new:
// `GWDrawerStatusPill` maps no enum, and `GWDrawerReceiptHead` omits its
// optional slots entirely rather than rendering a placeholder, and never
// derives its amount colour from anything passed to it (D-03).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/drawer_content.dart';

void main() {
  group('GWDrawerStatusPill', () {
    testWidgets('renders the caller-supplied colours directly, not from an '
        'enum mapping', (tester) async {
      const fg = Color(0xFF123456);
      const bg = Color(0xFFABCDEF);

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GWDrawerStatusPill(
              label: 'Refunded',
              foreground: fg,
              background: bg,
            ),
          ),
        ),
      );

      expect(find.text('Refunded'), findsOneWidget);

      final pillContainer = tester.widget<Container>(
        find.byType(Container).first,
      );
      expect((pillContainer.decoration! as BoxDecoration).color, bg);

      final text = tester.widget<Text>(find.text('Refunded'));
      expect(text.style!.color, fg);
    });
  });

  group('GWDrawerReceiptHead', () {
    Widget host({String? fiat, String? exact, Widget? pill}) => MaterialApp(
      home: Scaffold(
        body: GWDrawerReceiptHead(
          identity: const SizedBox(width: 60, height: 60, key: Key('id')),
          amount: '1.234 ETH',
          amountColor: const Color(0xFFAA00AA),
          fiat: fiat,
          exact: exact,
          pill: pill,
        ),
      ),
    );

    testWidgets('an omitted fiat, exact and pill each render nothing at all', (
      tester,
    ) async {
      await tester.pumpWidget(host());

      // The identity slot is a SizedBox, so the ONLY Text in the tree should
      // be the amount itself - no placeholder text of any kind for the three
      // optional slots that were left null.
      expect(find.byType(Text), findsOneWidget);
      expect(find.byKey(const Key('id')), findsOneWidget);
    });

    testWidgets('a supplied fiat, exact and pill all render', (tester) async {
      await tester.pumpWidget(
        host(
          fiat: r'$42.00',
          exact: '1.2340001 ETH',
          pill: const Text('Completed', key: Key('the-pill')),
        ),
      );

      expect(find.text(r'$42.00'), findsOneWidget);
      expect(find.text('1.2340001 ETH'), findsOneWidget);
      expect(find.byKey(const Key('the-pill')), findsOneWidget);
    });

    testWidgets('the amount colour is the caller\'s own value, never derived '
        'here', (tester) async {
      await tester.pumpWidget(host());
      final amountText = tester.widget<Text>(find.text('1.234 ETH'));
      expect(amountText.style!.color, const Color(0xFFAA00AA));
    });
  });
}
