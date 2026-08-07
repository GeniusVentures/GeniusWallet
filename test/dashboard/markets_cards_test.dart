// BXS-04: the All Markets body is a list of cards -- icon, name, symbol,
// price, 24h change, market cap and volume, no chart on any card, one per
// row at phone width and two at desktop, ordered rank ascending.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/dashboard/chart/markets_cards.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

import 'markets_fixtures.dart';

MarketRow _row({required int rank, required String name, required String id}) {
  return MarketRow(
    CoinGeckoCoin(id: id, symbol: id, name: name),
    CoinGeckoMarketData(
      id: id,
      symbol: id,
      name: name,
      imageUrl: '',
      currentPrice: 100.0 * rank,
      marketCap: 1e9 * rank,
      marketCapRank: rank,
      fullyDilutedValuation: 1.1e9 * rank,
      totalVolume: 1e7 * rank,
      high24h: 110.0 * rank,
      low24h: 90.0 * rank,
      priceChange24h: 1.0,
      priceChangePercentage24h: 1.0,
      marketCapChange24h: 0,
      marketCapChangePercentage24h: 0,
      circulatingSupply: 1e6,
      totalSupply: 1e6,
      maxSupply: 1e6,
      ath: 200.0 * rank,
      athChangePercentage: -10,
      athDate: DateTime(2026, 1, 1),
      atl: 1.0,
      atlChangePercentage: 500,
      atlDate: DateTime(2020, 1, 1),
      lastUpdated: DateTime(2026, 7, 29),
      sparkline: null,
    ),
  );
}

/// Deliberately scrambled — rank order, not list order, is what the widget
/// must produce. The rank-1 entry is Task 1's shared fixture (Bitcoin,
/// `marketCapRank: 1`) rather than a fourth synthetic coin, making this
/// file's third consumer of `markets_fixtures.dart` (Rule of Three, met not
/// anticipated).
List<MarketRow> _scrambledRows() => [
  _row(rank: 3, name: 'Coin C', id: 'coin-c'),
  MarketRow(marketsFixtureCoin(), marketsFixtureMarketData()),
  _row(rank: 4, name: 'Coin D', id: 'coin-d'),
  _row(rank: 2, name: 'Coin B', id: 'coin-b'),
];

// Mirrors _MarketCard's own private formatters — the widget's helpers are
// private to markets_cards.dart, so the test replicates the formatting to
// build an independent expectation rather than importing internals.
String _price(double v) =>
    NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(v);

String _compact(double v) {
  if (v >= 1e12) {
    return '\$${(v / 1e12).toStringAsFixed(2)}T';
  }
  if (v >= 1e9) {
    return '\$${(v / 1e9).toStringAsFixed(1)}B';
  }
  if (v >= 1e6) {
    return '\$${(v / 1e6).toStringAsFixed(1)}M';
  }
  return '\$${(v / 1e3).toStringAsFixed(1)}K';
}

Widget _host(List<MarketRow> rows) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SingleChildScrollView(
      child: MarketsCards(rows: rows, onTapRow: (_) {}),
    ),
  ),
);

extension on WidgetTester {
  Future<void> pumpCardsAt(Size size, List<MarketRow> rows) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
    await pumpWidget(_host(rows));
    await pump();
  }
}

void main() {
  group('BXS-04: cards replace the markets table', () {
    testWidgets('at 402x900 cards are one per row', (tester) async {
      await tester.pumpCardsAt(const Size(402, 900), _scrambledRows());

      expect(tester.takeException(), isNull);
      // One per row: the first two cards do NOT share a top edge.
      final firstTop = tester.getTopLeft(find.byType(GWCard).at(0)).dy;
      final secondTop = tester.getTopLeft(find.byType(GWCard).at(1)).dy;
      expect(firstTop, isNot(secondTop));
    });

    testWidgets('at 1400x1000 cards are two per row', (tester) async {
      await tester.pumpCardsAt(const Size(1400, 1000), _scrambledRows());

      expect(tester.takeException(), isNull);
      // Two per row: the first two cards DO share a top edge.
      final firstTop = tester.getTopLeft(find.byType(GWCard).at(0)).dy;
      final secondTop = tester.getTopLeft(find.byType(GWCard).at(1)).dy;
      expect(firstTop, secondTop);
    });

    testWidgets('cards show price, market cap and volume, and no chart', (
      tester,
    ) async {
      final rows = _scrambledRows();
      await tester.pumpCardsAt(const Size(1400, 1000), rows);

      for (final row in rows) {
        expect(find.text(_price(row.data.currentPrice)), findsOneWidget);
        expect(find.text(_compact(row.data.marketCap)), findsOneWidget);
        expect(find.text(_compact(row.data.totalVolume)), findsOneWidget);
      }
      // The locked no-chart decision: no LineChart anywhere in the list,
      // at any width.
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('the first card in document order is the rank-1 coin', (
      tester,
    ) async {
      await tester.pumpCardsAt(const Size(1400, 1000), _scrambledRows());

      expect(
        find.descendant(
          of: find.byType(GWCard).first,
          matching: find.text('Bitcoin'),
        ),
        findsOneWidget,
      );
    });
  });
}
