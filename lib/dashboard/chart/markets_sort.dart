import 'package:flutter/foundation.dart';

/// The native token featured in the Markets hero (sketch 103 · H1). It is
/// pulled OUT of the "All Markets" table and shown as the hero card above it.
const String kNativeMarketCoinId = 'genius-ai';

/// Sortable columns of the "All Markets" table (sketch 103 · H1 / B).
enum MarketSort { rank, name, price, change, marketCap, volume }

/// The primitive projection of a market row that ordering depends on — kept
/// Flutter-free so [compareMarketRows] is a pure function the check in
/// `test/markets_sort_test.dart` can exercise without pumping a widget or
/// constructing a full Hive `CoinGeckoMarketData`.
@immutable
class MarketRowData {
  final int rank;
  final String name;
  final double price;
  final double changePct;
  final double marketCap;
  final double volume;

  const MarketRowData({
    required this.rank,
    required this.name,
    required this.price,
    required this.changePct,
    required this.marketCap,
    required this.volume,
  });
}

/// Pure comparator for two rows under [sort]. [ascending] flips the natural
/// order (numeric ascending / name A→Z). Name compares case-insensitively;
/// every other key is numeric. Returns <0, 0 or >0 like [Comparable.compareTo].
int compareMarketRows(
  MarketSort sort,
  bool ascending,
  MarketRowData a,
  MarketRowData b,
) {
  final int c;
  switch (sort) {
    case MarketSort.rank:
      c = a.rank.compareTo(b.rank);
    case MarketSort.name:
      c = a.name.toLowerCase().compareTo(b.name.toLowerCase());
    case MarketSort.price:
      c = a.price.compareTo(b.price);
    case MarketSort.change:
      c = a.changePct.compareTo(b.changePct);
    case MarketSort.marketCap:
      c = a.marketCap.compareTo(b.marketCap);
    case MarketSort.volume:
      c = a.volume.compareTo(b.volume);
  }
  return ascending ? c : -c;
}
