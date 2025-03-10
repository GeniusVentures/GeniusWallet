import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CoinMarketCache {
  final Box<CoinGeckoMarketData> _marketDataBox =
      Hive.box<CoinGeckoMarketData>('marketDataBox');
  final Box _timestampsBox = Hive.box('marketTimestampsBox');

  final Duration cacheDuration = const Duration(seconds: 60);

  /// Get cached data for specific coins (returns with **coin symbol as key**)
  Map<String, CoinGeckoMarketData> getCachedData(List<String> coinIds) {
    final Map<String, CoinGeckoMarketData> validCache = {};

    for (var coinId in coinIds) {
      final CoinGeckoMarketData? cachedCoin = _marketDataBox.get(coinId);
      final String? timestampString = _timestampsBox.get(coinId);

      if (cachedCoin != null && timestampString != null) {
        final DateTime? cacheTime = DateTime.tryParse(timestampString);

        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < cacheDuration) {
          validCache[cachedCoin.symbol.toLowerCase()] = cachedCoin;
        } else {
          // ❌ Remove expired entries
          _marketDataBox.delete(coinId);
          _timestampsBox.delete(coinId);
        }
      }
    }

    return validCache;
  }

  /// Save new data to cache using CoinGecko ID
  Future<void> setCachedData(Map<String, CoinGeckoMarketData> newData) async {
    final nowString = DateTime.now().toIso8601String();

    for (var entry in newData.entries) {
      await _marketDataBox.put(entry.key, entry.value);
      await _timestampsBox.put(entry.key, nowString);
    }
  }

  /// Check if Coin is in Cache**
  bool isCoinCached(String coinId) {
    final String? timestampString = _timestampsBox.get(coinId);

    if (timestampString == null) return false;

    final DateTime? cacheTime = DateTime.tryParse(timestampString);
    return cacheTime != null &&
        DateTime.now().difference(cacheTime) < cacheDuration;
  }

  /// Optional utility to clear all caches
  Future<void> clearCache() async {
    await _marketDataBox.clear();
    await _timestampsBox.clear();
    print("🗑️ Cleared all Coin Market caches.");
  }
}
