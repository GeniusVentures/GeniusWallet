// BXS-04, corrected 2026-08-07: "All Markets" is the table when it fits,
// cards -- icon, name, symbol, price, 24h change, market cap, volume, no
// chart -- only when it does not. The gate is `kMarketsTableMinWidth`
// (the table's own column-width sum), not a device class.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/dashboard/chart/markets_cards.dart';
import 'package:genius_wallet/dashboard/chart/markets_table.dart';
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

/// Deliberately scrambled — rank order, not list order, is what the card
/// grid must produce. The rank-1 entry is Task 1's shared fixture (Bitcoin,
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

// Bare host, no padding around MarketsAllSection: the test surface's
// physical width flows straight through as the LayoutBuilder's `c.maxWidth`,
// so `pumpAllSectionAt` controls the fit-gate's input exactly.
Widget _host(List<MarketRow> rows) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SingleChildScrollView(
      child: MarketsAllSection(rows: rows, onTapRow: (_) {}),
    ),
  ),
);

extension on WidgetTester {
  Future<void> pumpAllSectionAt(double width, List<MarketRow> rows) async {
    view.physicalSize = Size(width, 1200);
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
    await pumpWidget(_host(rows));
    await pump();
  }
}

void main() {
  group('All Markets: table when it fits, cards when it does not', () {
    testWidgets('exactly at kMarketsTableMinWidth, the table renders', (
      tester,
    ) async {
      await tester.pumpAllSectionAt(kMarketsTableMinWidth, _scrambledRows());

      expect(tester.takeException(), isNull);
      expect(find.byType(MarketsTable), findsOneWidget);
      expect(find.byType(GWCard), findsNothing);
    });

    testWidgets('one pixel below kMarketsTableMinWidth, cards render', (
      tester,
    ) async {
      await tester.pumpAllSectionAt(
        kMarketsTableMinWidth - 1,
        _scrambledRows(),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(MarketsTable), findsNothing);
      expect(find.byType(GWCard), findsWidgets);
    });

    testWidgets('cards show price, market cap and volume, and no chart', (
      tester,
    ) async {
      final rows = _scrambledRows();
      // Comfortably below the fit threshold, so this is unambiguously the
      // card grid, not the table.
      await tester.pumpAllSectionAt(kMarketsTableMinWidth - 400, rows);

      for (final row in rows) {
        expect(find.text(_price(row.data.currentPrice)), findsOneWidget);
        expect(find.text(_compact(row.data.marketCap)), findsOneWidget);
        expect(find.text(_compact(row.data.totalVolume)), findsOneWidget);
      }
      // The locked no-chart decision: no LineChart on a card, at any width
      // the card grid itself renders at. (The table's own "Last 7d" column
      // legitimately has a mini-sparkline LineChart -- that is a table
      // claim, not a card claim, and is out of scope for this file.)
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('the first card in document order is the rank-1 coin', (
      tester,
    ) async {
      await tester.pumpAllSectionAt(
        kMarketsTableMinWidth - 400,
        _scrambledRows(),
      );

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
