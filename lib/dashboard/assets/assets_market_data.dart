/// The market-data seam behind the `/assets` page.
///
/// **Why a seam at all.** `AssetsScreen` needs prices, and the only way to get
/// them today opens two Hive boxes and hits the network. A widget test that
/// pumps the real screen cannot do either, so without an injectable resolver
/// the page has no automated coverage at all - the first box lookup throws
/// before a single row renders.
///
/// **Why the WHOLE resolution sits behind it, not just the final call.**
/// `fetchAllCoinGeckoCoins` opens a Hive box too. A seam wrapping only
/// `fetchCoinsMarketData` would still be unpumpable. This is the same
/// injectable-resolver pattern `token_info_screen.dart` already uses, widened
/// from a `List<String>` of ids to a `List<Coin>` for exactly that reason.
///
/// ponytail: [resolveAssetsMarketData] DUPLICATES the id-resolution
/// `CoinsScreenState._fetchMarketData` performs (`coins_screen.dart:88-108`).
/// It is not extracted because `coins_screen.dart` belongs to plan 25-01 and
/// cannot be edited in this wave. It is written here, in the home the shared
/// helper should end up in, so the follow-up after 25-01 lands is a DELETION
/// in `coins_screen.dart` plus a call to this function, not a move.
/// Ceiling: until that follow-up lands the two copies can drift - if the id
/// resolution changes on one side the two surfaces will price coins
/// differently, and nothing fails loudly when they do.
library;

import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';

/// Resolves market data for a wallet's coins, keyed by LOWERCASE SYMBOL -
/// the key `fetchCoinsMarketData` writes and the key `CoinCardRow` reads.
typedef AssetsMarketDataResolver =
    Future<Map<String, CoinGeckoMarketData?>> Function(List<Coin> coins);

/// The production [AssetsMarketDataResolver].
///
/// Maps each wallet coin to a CoinGecko id - its own `coinGeckoId` when set,
/// otherwise a symbol match against the full coin list - then fetches market
/// data for the ids that resolved. Returns an empty map when none do.
///
/// Deliberately does NOT compute or write the wallet total. `CoinsScreen`'s
/// equivalent ends by calling `_calculateTotalValue`, which writes into
/// `WalletDetailsCubit`; carrying that across would create two competing
/// writers for one piece of shared state (threat T-25-02-04). The `/assets`
/// page is read-only against the cubit apart from `selectCoin` on row tap.
///
/// Freshness is NOT this function's job either, and no caller should give it a
/// timer. `fetchCoinsMarketData` is backed by a 3-minute Hive cache shared
/// process-wide, so whichever surface fetches first refreshes both. A second
/// periodic refresh would double the app's request volume against a
/// rate-limited free API and could get both surfaces throttled
/// (threat T-25-02-03).
Future<Map<String, CoinGeckoMarketData?>> resolveAssetsMarketData(
  List<Coin> coins,
) async {
  if (coins.isEmpty) {
    return {};
  }

  final List<CoinGeckoCoin> coinGeckoCoinsList = await fetchAllCoinGeckoCoins();

  final List<String> coinGeckoIds = coins
      .map((walletCoin) {
        // Prefer an explicit id: symbols are not unique across chains and
        // names do not reliably match, so a symbol lookup is the fallback and
        // never the first choice.
        if (walletCoin.coinGeckoId != null) {
          return walletCoin.coinGeckoId!;
        }
        final matchingCoin = coinGeckoCoinsList.firstWhere(
          (coin) =>
              coin.symbol.toLowerCase() == walletCoin.symbol?.toLowerCase(),
          orElse: () =>
              CoinGeckoCoin(id: '', symbol: '', name: 'Unknown Token'),
        );
        return matchingCoin.id.isNotEmpty ? matchingCoin.id : null;
      })
      .whereType<String>()
      .toList();

  if (coinGeckoIds.isEmpty) {
    return {};
  }

  return fetchCoinsMarketData(coinIds: coinGeckoIds);
}
