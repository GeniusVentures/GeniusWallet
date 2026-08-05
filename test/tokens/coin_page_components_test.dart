// The checks sketch 070-A and sketch 165 Synthesis (change 8) both own.
//
// Findings invisible in the mode we develop in are exactly how they survive on
// a shipped screen:
//
//  * The Info card USED TO carry six glyphs in six different colours, five of
//    them raw constants tuned on the dark canvas - on dark they all read fine,
//    on the light well four of the six simply were not there. Jakub's
//    2026-07-28 fix collapsed all six to one shared colour; his 2026-07-30
//    call (sketch 165 Synthesis, change 8) went further and removed the
//    glyphs outright. This file's first check inverts accordingly: it now
//    asserts NO icon renders in the card, rather than that the icons share one
//    colour.
//
//  * The Token Amount field lit a FLAT `brandPrimaryStrong` on focus rather
//    than the brand gradient, which also looks perfectly fine in isolation.
//    Unaffected by change 8 - still asserted structurally below.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';

const _address = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets(
    'the Info card renders no icons at all, and its six rows still stand',
    (tester) async {
      // `marketData: null` on purpose - the four numeric rows print "N/A" and
      // still render their labels, so all six rows are in the tree without
      // standing up a 24-field Hive model.
      await tester.pumpWidget(
        _host(const CoinInfoCard(network: 'Ethereum', address: _address)),
      );
      await tester.pumpAndSettle();

      // **sketch 165 Synthesis, change 8 (Jakub, 2026-07-30): no icons.** This
      // replaces the old "one shared glyph colour" assertion - the rainbow's
      // fix was itself replaced by removing the glyphs entirely, not by
      // recolouring them again.
      expect(
        find.byType(SketchIcon),
        findsNothing,
        reason: 'the Info card must render no icons at all',
      );

      // The icon assertion alone would pass on an empty card, so the six rows
      // - Network, Address, Market Cap, Circulating Supply, Total Supply,
      // Volume - are asserted by their labels too.
      expect(find.text('Network'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Market Cap'), findsOneWidget);
      expect(find.text('Circulating Supply'), findsOneWidget);
      expect(find.text('Total Supply'), findsOneWidget);
      expect(find.text('Volume'), findsOneWidget);
    },
  );

  testWidgets('the Convert card has exactly one gradient focus ring, on the '
      'field you can actually edit', (tester) async {
    await tester.pumpWidget(_host(const CoinConvertCard(tokenPrice: 63504.0)));
    await tester.pumpAndSettle();

    // Exactly one: the amount field. The price field is readOnly and must NOT
    // have it - a `readOnly` field still takes focus in Flutter, so a ring
    // there would promise an edit that cannot happen.
    expect(find.byType(GWFocusRing), findsOneWidget);

    // Both labels sit ABOVE their boxes now, so they are plain Texts in the
    // tree rather than an InputDecoration notch.
    expect(find.text('Token price'), findsOneWidget);
    expect(find.text('Token amount'), findsOneWidget);
    expect(find.text('Total'), findsOneWidget);
  });

  testWidgets('the whole Address row copies the FULL address', (tester) async {
    final copied = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    await tester.pumpWidget(
      _host(const CoinInfoCard(network: 'Ethereum', address: _address)),
    );
    await tester.pumpAndSettle();

    // The row draws the SHORT form - assert that first, or the copy assertion
    // below could pass for the wrong reason.
    expect(find.text(_address), findsNothing);

    // Tapping the LABEL, not the glyph: the point of the change is that the
    // whole cell is the target, where it used to be a 15px icon at the far end.
    await tester.tap(find.text('Address'));
    await tester.pumpAndSettle();
    expect(copied, [_address]);
  });
}
