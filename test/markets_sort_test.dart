import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';

/// Smallest check that fails if the "All Markets" ordering breaks: the pure
/// [compareMarketRows] comparator and the direction toggle. No widget pump, no
/// Hive model construction — [MarketRowData] is the Flutter-free projection the
/// table sorts by.
void main() {
  MarketRowData row(
    int rank, {
    double price = 0,
    double change = 0,
    double cap = 0,
    double vol = 0,
    String name = 'x',
  }) =>
      MarketRowData(
        rank: rank,
        name: name,
        price: price,
        changePct: change,
        marketCap: cap,
        volume: vol,
      );

  List<int> sortedRanks(
    List<MarketRowData> rows,
    MarketSort sort,
    bool asc,
  ) {
    final copy = [...rows]..sort((a, b) => compareMarketRows(sort, asc, a, b));
    return copy.map((r) => r.rank).toList();
  }

  test('rank ascending puts rank 1 first', () {
    final rows = [row(3), row(1), row(2)];
    expect(sortedRanks(rows, MarketSort.rank, true), [1, 2, 3]);
  });

  test('market cap descending = biggest first', () {
    final rows = [
      row(1, cap: 10),
      row(2, cap: 30),
      row(3, cap: 20),
    ];
    expect(sortedRanks(rows, MarketSort.marketCap, false), [2, 3, 1]);
  });

  test('24h change ascending = biggest loser first', () {
    final rows = [
      row(1, change: 1.3),
      row(2, change: -16.4),
      row(3, change: -0.5),
    ];
    expect(sortedRanks(rows, MarketSort.change, true), [2, 3, 1]);
  });

  test('name sort is case-insensitive and direction toggles', () {
    final rows = [
      row(1, name: 'bitcoin'),
      row(2, name: 'Aave'),
      row(3, name: 'cardano'),
    ];
    expect(sortedRanks(rows, MarketSort.name, true), [2, 1, 3]);
    expect(sortedRanks(rows, MarketSort.name, false), [3, 1, 2]);
  });

  test('the native coin id is the one pulled into the hero', () {
    expect(kNativeMarketCoinId, 'genius-ai');
  });
}
