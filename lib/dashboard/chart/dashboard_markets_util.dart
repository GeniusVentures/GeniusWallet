// kDebugMode is required for the dev-only fault-injector gate in
// getDashboardMarketCoins() below. See app_bloc.dart:5-10 for why this is an
// explicit foundation.dart import rather than a material.dart pull-in.
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:genius_wallet/dev/dev_fault_injector.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';

final List<String> topCoinsByCapitalization = [
  "genius-ai",
  "bitcoin",
  "ethereum",
  "ripple",
  "binancecoin",
  "solana",
  "tron",
  "dogecoin",
  "whitebit",
  "hyperliquid",
  "leo-token",
  "cardano",
  "bitcoin-cash",
  "monero",
  "chainlink",
  "zcash",
  "canton",
  "stellar",
  "dai",
  "litecoin",
  "avalanche",
  "hedera",
  "toncoin",
  "near",
];

// We need to make sure we request all the market data so that we can cache it for other screens and reduce API calls.
List<String> getAllMarketDataCoinIds() {
  return topCoinsByCapitalization;
}

/// How many rows the dashboard Markets PANEL renders (phase 25).
///
/// Six, because Jakub named six: GNUS, BTC, ETH, XRP, BNB and SOL. They come
/// out in exactly that order for free - [topCoinsByCapitalization]'s first six
/// entries already ARE that list, in that order - which is why
/// [dashboardMarketRows] contains no re-ordering step. If that list is ever
/// re-sorted, this panel's order moves with it and that is the file to fix.
///
/// The full `/markets` page behind the panel's `View all` is unaffected: it
/// goes through [getMarketCoins], which takes the whole list.
const int kDashboardMarketsCap = 6;

/// The rows the dashboard Markets panel shows: [coins] that actually have a
/// quote, capped at [kDashboardMarketsCap], in the incoming order.
///
/// [pricedSymbols] is the set of LOWERCASED symbols the caller resolved market
/// data for - the same `marketData[symbol.toLowerCase()] != null` test the
/// panel used to run inline. Passing the set rather than the map keeps this
/// function free of the Hive model.
///
/// **The cap is taken AFTER the availability filter, and that ordering is the
/// point.** Filtering a pre-capped list renders five rows with a silent hole
/// whenever one of the named six is unpriced; capping a pre-filtered list
/// renders six whenever six are priced, falling back on whatever
/// [getDashboardMarketCoins] fetched next.
///
/// Which is also why that function's `.take(8)` is NOT narrowed to 6. Two
/// reasons, both load-bearing: `splash.dart` calls it to warm the market
/// cache, so narrowing it would change PREFETCH behaviour as a side effect of
/// a DISPLAY decision; and the extra two coins are exactly the fallback this
/// cap draws on.
List<CoinGeckoCoin> dashboardMarketRows(
  List<CoinGeckoCoin> coins,
  Set<String> pricedSymbols,
) {
  return coins
      .where((coin) => pricedSymbols.contains(coin.symbol.toLowerCase()))
      .take(kDashboardMarketsCap)
      .toList();
}

/// DEV-ONLY: the injected-fault half of [getDashboardMarketCoins], extracted
/// out of it so that function reads as the real fetch with one guarded call
/// at the top. Returns the response the armed fault demands, or `null` when
/// no fault is armed and the caller should do the real fetch. Throws for
/// [DevMarketsFault.error], which is the whole point of that fault.
///
/// Only ever called behind `kDebugMode && kShowDevTools` at that one call
/// site - the gate stays there rather than moving in here, because the gate
/// at the call site is what lets the compiler drop this from a release
/// build. Scoped to that one caller deliberately: getMarketCoins() below
/// serves other screens and must stay untouched, so an armed fault can only
/// ever affect the dashboard Markets panel.
List<CoinGeckoCoin>? _injectedDashboardMarketsFault() {
  switch (DevFaultInjector.instance.marketsFault.value) {
    case DevMarketsFault.error:
      // Any throw type works — MarketsDashboardView's FutureStateWidget
      // catch path (custom_future_builder.dart:30) is untyped and swallows
      // this identically to a real failure. Do not "improve" this into a
      // typed exception; it would not change catch behavior.
      throw Exception(
        'DEV-ONLY: injected by dev_fault_injector.dart (armed via the '
        'dev-tools bubble MOCK section) — not a real markets-load failure.',
      );
    case DevMarketsFault.empty:
      return const <CoinGeckoCoin>[];
    case null:
      return null;
  }
}

// This will only return a subset of coins for now.
Future<List<CoinGeckoCoin>> getDashboardMarketCoins() async {
  // DEV-ONLY, release-safe: kDebugMode and kShowDevTools are both
  // compile-time const bools and they lead this && chain exactly as the
  // account-load fault guard in app_bloc.dart's _onFetchAccount does, so in
  // a release build (or any debug build without the GW_DEV_TOOLS define)
  // this condition constant-folds to false, _injectedDashboardMarketsFault
  // is never called, and this function's executed behavior is byte-for-byte
  // what it is at HEAD. Everything below is the real fetch.
  if (kDebugMode && kShowDevTools) {
    final injected = _injectedDashboardMarketsFault();
    if (injected != null) {
      return injected;
    }
  }

  final coins = await fetchAllCoinGeckoCoins();

  // Convert list to a Map for O(1) lookup time
  final Map<String, CoinGeckoCoin> coinMap = {
    for (var coin in coins) coin.id: coin,
  };

  // Retrieve only the requested IDs
  return topCoinsByCapitalization
      .take(8)
      .map((id) => coinMap[id])
      .whereType<CoinGeckoCoin>()
      .toList();
}

Future<List<CoinGeckoCoin>> getMarketCoins() async {
  final coins = await fetchAllCoinGeckoCoins();

  // Convert list to a Map for O(1) lookup time
  final Map<String, CoinGeckoCoin> coinMap = {
    for (var coin in coins) coin.id: coin,
  };

  // Retrieve only the requested IDs
  return topCoinsByCapitalization
      .map((id) => coinMap[id])
      .whereType<CoinGeckoCoin>()
      .toList();
}
