import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/route_details_card.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

import '../theme/theme_contrast_test.dart' show contrastRatio;
import 'route_fixture.dart';

/// The card is driven by recorded real responses, end to end: JSON to adapter
/// to pixels. Its previous golden values were frozen from a constant rate the
/// app could not produce, so nothing here asserts a figure twice.

Widget _host(Widget child, {GWColors? colors}) => MaterialApp(
  theme: ThemeData(extensions: [colors ?? GWColors.dark()]),
  home: Scaffold(body: child),
);

/// Pumps an already-built quote directly, so a synthetic body can be
/// exercised without a recorded fixture. [_pumpCard] delegates here.
Future<void> _pumpQuote(
  WidgetTester tester,
  SwapQuote quote, {
  GWColors? colors,
}) async {
  await tester.pumpWidget(
    _host(
      RouteDetailsCard(
        quote: quote,
        fromAmount: '1',
        toAmount: '0.757304',
        fromSymbol: 'GNUS',
        toSymbol: 'USDC',
        slippage: '0.5',
      ),
      colors: colors,
    ),
  );
}

Future<void> _pumpCard(
  WidgetTester tester,
  String fixture, {
  GWColors? colors,
}) => _pumpQuote(tester, squidQuote(loadRouteFixture(fixture)), colors: colors);

/// Sets the GLOBAL appearance to [mode] and returns the matching [GWColors],
/// restoring dark on teardown so no later file inherits a flipped flag.
/// Constructing `GWColors.light()` alone is not enough: its surface fields
/// read this same global, so a light instance built while the global stays
/// dark hands back dark values under a light-sounding name.
GWColors _gwFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return mode == GWAppearanceMode.light ? GWColors.light() : GWColors.dark();
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

  testWidgets('a same-chain route renders no fee row -- the normal case', (
    tester,
  ) async {
    await _pumpCard(tester, sameChainRoute);

    // Checked on the word, not one label, so a future placeholder row can't
    // slip past under a name this test never anticipated.
    expect(find.textContaining('fee'), findsNothing);
    expect(find.text('\$0.00'), findsNothing);
    expect(find.text('Network gas'), findsOneWidget);
    expect(find.text('\$0.01'), findsOneWidget);
  });

  testWidgets(
    'the route fee and the gas cost stay separately findable, never merged',
    (tester) async {
      await _pumpCard(tester, crossChainRoute);

      expect(find.text('Gas receiver fee'), findsOneWidget);
      expect(find.text('Network gas'), findsOneWidget);
      expect(find.text('\$0.48'), findsOneWidget);
      expect(find.text('\$0.02'), findsOneWidget);

      final mergedStrings = tester
          .widgetList<Text>(find.byType(Text))
          .map((widget) => widget.data ?? '')
          .where((text) => text.contains('0.48') && text.contains('0.02'));
      expect(mergedStrings, isEmpty);
    },
  );

  testWidgets('three fee entries each render as their own row', (tester) async {
    final quote = squidQuoteFromJson(
      syntheticRouteWithFees([
        {'name': 'Gas receiver fee', 'amountUsd': '0.91'},
        {'name': 'Boost fee', 'amountUsd': '0.10'},
        {'name': 'Wormhole relayer fee', 'amountUsd': '0.05'},
      ]),
    );

    await _pumpQuote(tester, quote);

    expect(find.text('Gas receiver fee'), findsOneWidget);
    expect(find.text('\$0.91'), findsOneWidget);
    expect(find.text('Boost fee'), findsOneWidget);
    expect(find.text('\$0.10'), findsOneWidget);
    expect(find.text('Wormhole relayer fee'), findsOneWidget);
    expect(find.text('\$0.05'), findsOneWidget);
    expect(find.text('Network gas'), findsOneWidget);
    expect(find.text('\$0.01'), findsOneWidget);
  });

  testWidgets('fee and gas rows stay legible in both appearances', (
    tester,
  ) async {
    for (final mode in GWAppearanceMode.values) {
      final gw = _gwFor(mode);

      if (mode == GWAppearanceMode.light) {
        // Proves the flip actually took: a light instance built while the
        // global stayed dark would still read as dark here.
        expect(
          gw.surfaceElevated.computeLuminance(),
          greaterThan(0.5),
          reason:
              'GWColors.light() read dark values -- the global did not flip',
        );
      }

      await _pumpCard(tester, crossChainRoute, colors: gw);

      expect(find.text('Gas receiver fee'), findsOneWidget);
      expect(find.text('Network gas'), findsOneWidget);
      expect(
        contrastRatio(gw.textSecondary, gw.surfaceElevated),
        greaterThanOrEqualTo(4.5),
        reason: 'label text vs card surface -- $mode',
      );
      expect(
        contrastRatio(gw.textPrimary, gw.surfaceElevated),
        greaterThanOrEqualTo(4.5),
        reason: 'value text vs card surface -- $mode',
      );
    }
  });
}
