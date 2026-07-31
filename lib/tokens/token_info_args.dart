import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';

/// The one typed payload every `/token-info` push site builds. Before this,
/// three call sites (`markets_screen.dart`, `dashboard_markets.dart`,
/// `coins_screen.dart`) each assembled their own untyped `extra` map, and one
/// of them - the dashboard Assets panel - passed a nullable market-data
/// snapshot with no way for the route to tell "not covered" apart from
/// "haven't asked yet". `router.dart`'s `/token-info` builder is the only
/// place that turns this into a [TokenInfoScreen]; a fifth call site that
/// skips this type fails `test/tokens/coin_page_entry_parity_test.dart`
/// instead of shipping a divergent page.
///
/// Every field but [originLabel] is nullable, because what a caller knows
/// differs by where it opened this page from:
///
///  * Markets and the dashboard Markets panel always have [marketData]
///    already in hand (their own `FutureStateWidget` never shows a coin with
///    none), so they pass it as a warm start and the page issues no
///    request. They never know [walletCoin] or [network] - the coin they are
///    showing may not even be in the user's wallet.
///  * The dashboard Assets panel knows the wallet's own record for this
///    coin ([walletCoin], [network]), and its own market-data snapshot may be
///    null - CoinGecko's free tier rate-limits, and the dashboard fires this
///    fetch alongside the Markets panel's own fetch on every load. That is
///    the null this plan stops treating as "uncovered".
class TokenInfoArgs {
  const TokenInfoArgs({
    this.coinGeckoId,
    this.symbol,
    this.marketData,
    this.walletCoin,
    this.network,
    this.originLabel = 'MARKETS',
  });

  /// The CoinGecko id - the only reliable token identity the app has. Null
  /// only from a caller that already holds [marketData] and skipped naming
  /// it, or a legacy `extra` map with no identity at all.
  final String? coinGeckoId;

  /// The ticker, kept alongside [coinGeckoId] as the secondary lookup key -
  /// `fetchCoinsMarketData`'s own returned maps are keyed by symbol, not id
  /// (see `coin_gecko_api.dart`).
  final String? symbol;

  /// A warm start. Non-null means the caller already holds this token's
  /// market data and the page must not issue a request for it.
  final CoinGeckoMarketData? marketData;

  /// The wallet's own record for this token - present only when the caller
  /// is showing the user's holdings (the dashboard Assets panel). Null from
  /// both Markets surfaces, where the coin on screen may not be one the
  /// wallet holds at all.
  final Coin? walletCoin;

  /// The wallet network name for [walletCoin]. Null exactly when
  /// [walletCoin] is.
  final String? network;

  /// The back link's word - names the panel the caller actually came from.
  final String originLabel;

  /// Returns [extra] unchanged when it is already a [TokenInfoArgs];
  /// reconstructs one from the legacy `Map<String, dynamic>` shape
  /// (`{"marketData": ..., "isGnusWalletConnected": ...}`) when it is a map;
  /// and returns a const empty instance for anything else, so a malformed or
  /// stale deep link opens an honest empty page instead of throwing inside a
  /// route builder (T-hsb-01).
  ///
  /// **The legacy map branch exists for deep links and must not be deleted**
  /// once the three in-tree call sites below are migrated to pass
  /// [TokenInfoArgs] directly - it is the only path standing between a
  /// serialised deep link and a crash. `isGnusWalletConnected` is
  /// deliberately NOT read here: the route derives that flag itself now (see
  /// `router.dart`), so no caller - legacy or migrated - needs to carry it.
  static TokenInfoArgs fromExtra(Object? extra) {
    if (extra is TokenInfoArgs) {
      return extra;
    }
    if (extra is Map<String, dynamic>) {
      final marketDataRaw = extra['marketData'];
      final CoinGeckoMarketData? marketData;
      if (marketDataRaw is CoinGeckoMarketData) {
        marketData = marketDataRaw;
      } else if (marketDataRaw is Map<String, dynamic>) {
        // A serialised deep link - the same coercion `router.dart` used to
        // do inline.
        marketData = CoinGeckoMarketData.fromJson(marketDataRaw);
      } else {
        marketData = null;
      }
      return TokenInfoArgs(marketData: marketData);
    }
    return const TokenInfoArgs();
  }
}
