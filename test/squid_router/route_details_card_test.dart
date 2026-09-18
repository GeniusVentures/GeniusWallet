import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import 'route_fixture.dart';

/// The card is driven by recorded real responses, end to end: JSON to adapter
/// to pixels. Its previous golden values were frozen from a constant rate the
/// app could not produce, so nothing here asserts a figure twice.

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(body: child),
);

Future<void> _pumpCard(WidgetTester tester, String fixture) async {
  await tester.pumpWidget(
    _host(
      RouteDetailsCard(
        quote: squidQuote(loadRouteFixture(fixture)),
        fromAmount: '1',
        toAmount: '0.757304',
        fromSymbol: 'GNUS',
        toSymbol: 'USDC',
        slippage: '0.5',
      ),
    ),
  );
}

void main() {
  testWidgets('the same-chain rows survive with no fee row', (tester) async {
    await _pumpCard(tester, sameChainRoute);

    expect(find.text('Pricing'), findsOneWidget);
    expect(find.text('Slippage'), findsOneWidget);
    expect(find.text('Price Impact'), findsOneWidget);
    expect(find.text('Network gas'), findsOneWidget);
    expect(find.text('Fees'), findsNothing);
  });

  testWidgets('every figure is read off the quote', (tester) async {
    await _pumpCard(tester, sameChainRoute);

    expect(find.text('1 GNUS ~ 0.757304 USDC'), findsOneWidget);
    expect(find.text('0.5'), findsOneWidget);
    expect(find.text('0.03%'), findsOneWidget);
    // Gas only on a same-chain route — and the row still shows it, where
    // summing fees alone would have printed $0.00.
    expect(find.text('\$0.01'), findsOneWidget);
  });

  testWidgets('a second real quote renders itemized fee and gas', (
    tester,
  ) async {
    await _pumpCard(tester, crossChainRoute);

    // The route's own fee and chain gas each keep their own row and figure —
    // nothing here is a sum, and no literal label is hard-coded.
    expect(find.text('2.93%'), findsOneWidget);
    expect(find.text('Gas receiver fee'), findsOneWidget);
    expect(find.text('\$0.48'), findsOneWidget);
    expect(find.text('Network gas'), findsOneWidget);
    expect(find.text('\$0.02'), findsOneWidget);
    expect(find.text('Fees'), findsNothing);
    expect(find.text('\$0.50'), findsNothing);
    expect(find.text('0.03%'), findsNothing);
  });
}
