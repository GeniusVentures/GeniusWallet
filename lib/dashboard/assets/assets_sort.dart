/// The ordering and filtering rules for the `/assets` page (sketch 177 · D as
/// simplified: ONE sort key, value, whose tap toggles direction).
///
/// **Flutter-free on purpose, and this is the deliberate sibling of
/// `lib/dashboard/chart/markets_sort.dart`.** Two reasons, both load-bearing:
///
///  1. This file is the SINGLE ordering authority for holdings. The `/assets`
///     page and plan 25-01's dashboard top-5 (`sorted.take(5)`) must produce
///     the same order or the two surfaces disagree in front of the user. A
///     shared rule that can only be checked by pumping a widget is a rule that
///     silently diverges the day one side is edited.
///  2. A pure comparator is the only way to unit-test the unpriced-holding
///     rule below without constructing a Hive `CoinGeckoMarketData` or
///     standing up a network. See `test/dashboard/assets_sort_test.dart`.
///
/// No enum here, deliberately. There is exactly one sort key, so mirroring
/// `MarketSort` would be an enum with one value pretending to be a choice.
library;

import 'package:flutter/foundation.dart';

/// The Genius token, pinned to the top of the list outright.
///
/// Not "floated within a group that ranks equally" - that was the phase 25
/// reading, and reversing it is the whole point of this rule. See step 1 of
/// [compareAssetsByValue].
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

  /// A holding the app cannot price: the user owns some of it and no usable
  /// quote resolved. This is the one row on the page that needs attention,
  /// which is why [compareAssetsByValue] gives it its own tier.
  ///
  /// A ZERO balance is deliberately excluded. Nothing was failed to be priced
  /// if nothing is held, so a zero-balance unlisted row ranks as an ordinary
  /// value-0 row rather than being promoted above a funded wallet.
  bool get isUnpricedHolding => balance > 0 && (!hasMarketData || price <= 0);

  /// Fiat value of the holding. 0 when either factor is 0, which is the normal
  /// reading for every row in a wallet with no funds.
  double get value => balance * price;
}

/// Pure comparator for two asset rows, implementing D-1 as a TOTAL order.
///
/// Descending ([ascending] false, the page default):
///
///  1. GNUS, above everything else
///  2. every unpriced holding, above every priced row
///  3. within the unpriced tier: larger balance first
///  4. within the priced tier: larger value first
///  5. tie-break: symbol A to Z, case-insensitively
///
/// Ascending mirrors steps 2 to 4: priced rows by value ascending (so the
/// `$0.00` rows lead) and the unpriced tier LAST, smaller balance first.
/// Pinning that tier to the top in both directions would leave the head of the
/// list unchanged when the user taps the toggle, and the control would read as
/// broken.
///
/// ## Step 1 is a PIN, and it was restored on purpose (2026-08-07)
///
/// GNUS ranks first outright, ahead of the unpriced tier, in BOTH directions.
/// It is not a tie-break. Phase 25 made it one: 25-01 dropped the dashboard
/// panel's absolute GNUS-first partition in favour of 25-02's shared
/// comparator, where GNUS won only among rows that already ranked equally.
/// That reversal was invisible on an all-zero wallet - every priced row ties at
/// value 0 there, so GNUS came first regardless - and only showed itself on a
/// funded wallet, where a larger holding outranked it. Jakub asked for the pin
/// back on 2026-08-07. Change it in this function or not at all: both the
/// `/assets` page and the dashboard panel's top 5 sort through here, and that
/// is what stops the two surfaces disagreeing in front of the user.
///
/// **Ascending keeps GNUS first. The rejected alternative was mirroring it to
/// LAST when ascending**, by symmetry with the unpriced tier. Rejected because
/// a pinned row is pinned: the arrow then visibly reorders everything else
/// around a fixed head, which reads as intentional, whereas a token that
/// teleports between first and last on a direction toggle reads as a bug. The
/// tier mirrors because it is a RANKING (rank by attention needed); the pin
/// does not, because it is not a ranking at all. Note also that the existing
/// ascending expectations already put GNUS first, so mirroring would have
/// meant weakening tests rather than adding to them.
///
/// ## What the pin does NOT do
///
///  * **It never fabricates a row.** This is a comparator: it orders rows that
///    already exist. A wallet holding no GNUS renders no GNUS row, and a wallet
///    holding nothing at all short-circuits to the empty state
///    (`assets_screen.dart`, S3) before any sort runs.
///  * **A zero-balance GNUS is still pinned, and that is wanted.** It renders
///    as an ordinary `$0.00` row at the top, which is where it already sits on
///    Jakub's all-zero wallet today, and it sits beside a `Buy GNUS` CTA that
///    makes a held-none row read as an offer rather than a defect. Making the
///    pin conditional on `balance > 0` was considered and rejected: it would
///    make the row leap down the list the moment a balance hit zero, which is
///    a worse surprise than a quiet $0.00 at the top.
///
/// The real cost, named so it is a decision and not a rediscovery: an unpriced
/// holding is the one row on the page that needs attention, and it now sits
/// BELOW GNUS instead of leading the list. Accepted - the pin is a brand rule
/// and it outranks the attention rule by exactly one row.
///
/// **Steps 1 and 5 do NOT flip with [ascending], and that is intent rather
/// than an oversight - do not "fix" it.** Flipping the direction should flip
/// the RANKING, not scramble rows that rank equally. Two consequences follow,
/// both wanted and both covered by tests:
///
///  * In a wallet where every balance is zero, every priced row ties at value
///    0, so the pin and the tie-break are the entire ordering and the list is
///    identical in both directions. Tapping the toggle changes the arrow and
///    not the order. That is correct: nothing has value to rank.
///  * The comparator is TOTAL, which matters because Dart's `List.sort` is not
///    stable (the trap documented in `coins_screen.dart`). Without a total
///    order the all-zero wallet would reorder itself between rebuilds.
///
/// Returns <0, 0 or >0 like [Comparable.compareTo].
int compareAssetsByValue(bool ascending, AssetRowData a, AssetRowData b) {
  // Step 1: the pin. Direction-INDEPENDENT and ahead of the tier, which is the
  // whole difference from the phase 25 reading where this same check sat below
  // the ranking and could therefore only break ties.
  final bool aNative = a.symbol.toUpperCase() == _kNativeSymbol;
  final bool bNative = b.symbol.toUpperCase() == _kNativeSymbol;
  if (aNative != bNative) {
    return aNative ? -1 : 1;
  }

  final bool aUnpriced = a.isUnpricedHolding;
  final bool bUnpriced = b.isUnpricedHolding;

  // Step 2: the tier, which is the only part of the rule that is not a plain
  // numeric compare. Descending floats the tier; ascending sinks it.
  if (aUnpriced != bUnpriced) {
    if (aUnpriced) {
      return ascending ? 1 : -1;
    }
    return ascending ? -1 : 1;
  }

  // Steps 3 and 4: rank within the tier. Both are natural-ascending compares
  // negated for descending, so the two tiers mirror together.
  final int ranked = aUnpriced
      ? a.balance.compareTo(b.balance)
      : a.value.compareTo(b.value);
  final int directed = ascending ? ranked : -ranked;
  if (directed != 0) {
    return directed;
  }

  // Step 5: direction-INDEPENDENT, per the doc above. Two rows that are BOTH
  // GNUS (the same symbol on two networks) reach here and tie, exactly as they
  // did before the pin - the pin separates GNUS from everything else, never
  // GNUS from itself.
  return a.symbol.toLowerCase().compareTo(b.symbol.toLowerCase());
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

/// [rows] ordered by [compareAssetsByValue].
///
/// Copies before sorting - it must never sort the caller's list in place,
/// because the caller's list is derived from cubit state that other widgets
/// are reading in the same frame.
List<AssetRowData> sortAssets(
  List<AssetRowData> rows, {
  required bool ascending,
}) {
  final sorted = List<AssetRowData>.of(rows);
  sorted.sort((a, b) => compareAssetsByValue(ascending, a, b));
  return sorted;
}
