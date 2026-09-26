/// The single ordering and filtering authority for holdings: the `/assets`
/// page and the dashboard panel both sort through here so they cannot
/// disagree. Flutter-free so the rules unit-test without widgets or network.
library;

import 'package:flutter/foundation.dart';

/// The Genius token: the one row a wallet holding nothing still shows.
const String _kNativeSymbol = 'GNUS';

/// The primitive projection of an asset row that ordering and filtering depend
/// on - name, symbol, balance, price, and whether market data resolved at all.
///
/// [hasMarketData] is NOT derivable from [price]: a coin the price feed covers
/// can legitimately quote 0, and a coin it has never heard of has no quote at
/// all. Both end up unpriced (see [isUnpricedHolding]), but keeping the two
/// facts apart is what lets the caller build this projection straight from a
/// map lookup without inventing a sentinel price.
@immutable
class AssetRowData {
  final String name;
  final String symbol;
  final double balance;
  final double price;
  final bool hasMarketData;

  const AssetRowData({
    required this.name,
    required this.symbol,
    required this.balance,
    required this.price,
    required this.hasMarketData,
  });

  /// A holding the app cannot price: some is owned but no usable quote
  /// resolved. A zero balance is excluded - nothing held, nothing to price.
  bool get isUnpricedHolding => balance > 0 && (!hasMarketData || price <= 0);

  /// Fiat value of the holding. 0 when either factor is 0, which is the normal
  /// reading for every row in a wallet with no funds.
  double get value => balance * price;
}

/// Total order: priced holdings by value, then unpriced holdings by balance,
/// then rows holding nothing; ties by symbol A to Z. [ascending] reverses all
/// but the symbol tie-break, which stays fixed because `List.sort` is unstable.
int compareAssetsByValue(bool ascending, AssetRowData a, AssetRowData b) {
  int tier(AssetRowData row) => row.balance <= 0
      ? 2
      : row.isUnpricedHolding
      ? 1
      : 0;
  final int byTier = tier(b).compareTo(tier(a));
  final int ranked = byTier != 0
      ? byTier
      : a.isUnpricedHolding
      ? a.balance.compareTo(b.balance)
      : a.value.compareTo(b.value);
  final int directed = ascending ? ranked : -ranked;
  if (directed != 0) {
    return directed;
  }
  return a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase());
}

/// [items] ordered by [compareAssetsByValue]. A wallet that holds nothing
/// shows only its GNUS rows (when it lists any) instead of a list of zeroes.
List<T> orderAssets<T>(
  Iterable<T> items,
  AssetRowData Function(T item) rowOf, {
  required bool ascending,
}) {
  final all = List<T>.of(items);
  final bool holdsNothing = all.every((item) => rowOf(item).balance <= 0);
  final gnus = holdsNothing
      ? all
            .where((item) => rowOf(item).symbol.toUpperCase() == _kNativeSymbol)
            .toList()
      : <T>[];
  final shown = gnus.isEmpty ? all : gnus;
  shown.sort((a, b) => compareAssetsByValue(ascending, rowOf(a), rowOf(b)));
  return shown;
}

/// Whether [row] survives the search box's current [query].
///
/// Trimmed and lower-cased, substring-matched against name OR symbol. An empty
/// (or whitespace-only) query matches everything, so the caller does not need
/// to branch on "is the search active".
///
/// **The query reaches this function and nothing else.** It is never
/// interpolated into a URL, a request body, a shell command or a Hive key, and
/// it never triggers a network call (threat T-25-02-02). Keeping the matcher
/// pure is what makes that claim checkable in a unit test instead of asserted
/// in a comment.
bool matchesAssetQuery(String query, AssetRowData row) {
  final String needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return true;
  }
  return row.name.toLowerCase().contains(needle) ||
      row.symbol.toLowerCase().contains(needle);
}

/// [orderAssets] over bare rows. Never sorts the caller's list in place.
List<AssetRowData> sortAssets(
  List<AssetRowData> rows, {
  required bool ascending,
}) => orderAssets(rows, (row) => row, ascending: ascending);
