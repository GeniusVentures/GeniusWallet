// The ONE check sketch 070-A owes.
//
// Two of its five findings are invisible in the mode we develop in, which is
// exactly how both survived on a shipped screen:
//
//  * The Info card's six glyphs used SIX different colours, five of them raw
//    constants tuned on the dark canvas. On dark they all read (10.8 / 8.3 /
//    7.8 / 6.1 / 4.2 / 10.3), so nothing looks wrong. On the light well they
//    are 1.25 / 1.63 / 1.72 / 2.19 - four of the six simply are not there.
//    A screenshot of dark mode would never catch a regression back to that.
//
//  * The Token Amount field lit a FLAT `brandPrimaryStrong` on focus rather
//    than the brand gradient, which also looks perfectly fine in isolation.
//
// So both are asserted structurally rather than visually: one glyph colour for
// the whole card, and the editable field actually wrapped in a `GWFocusRing`.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/inputs/gw_focus_ring.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/tokens/widgets/sketch_icons.dart';

const _address = '0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  testWidgets('every Info glyph is the SAME colour, and it is the one that '
      'survives light mode', (tester) async {
    // `marketData: null` on purpose - the four numeric rows print "N/A" and
    // still render their glyphs, so all six are in the tree without standing up
    // a 24-field Hive model to assert a colour.
    await tester.pumpWidget(
      _host(const CoinInfoCard(network: 'Ethereum', address: _address)),
    );
    await tester.pumpAndSettle();

    // Six rows: Network, Address, Market Cap, Circulating, Total Supply,
    // Volume. If a row is ever dropped, the set below could collapse to one
    // colour for the wrong reason.
    expect(find.byType(SketchIcon), findsNWidgets(6));

    final glyphs = tester
        .widgetList<SketchIcon>(find.byType(SketchIcon))
        .map((g) => g.color)
        .toSet();

    // ONE entry, not "all pass contrast" - a contrast assertion would still be
    // satisfied by five different colours that each happen to clear a bar in
    // dark, which is precisely the state this replaced.
    expect(
      glyphs.length,
      1,
      reason: 'the rainbow is back: ${glyphs.length} glyph colours',
    );
    expect(glyphs.single, GeniusWalletColors.brandPrimaryOnSurface);
  });

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
