import 'package:genius_wallet/models/coin_gecko_market_data.dart';

class CoinMarketCache {
  final Map<String, CoinGeckoMarketData> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  final Duration cacheDuration = const Duration(seconds: 60);

  /// Get cached data for specific coins (returns with **coin symbol as key**)
  Map<String, CoinGeckoMarketData> getCachedData(List<String> coinIds) {
    final Map<String, CoinGeckoMarketData> validCache = {};

    for (var coinId in coinIds) {
      if (_cache.containsKey(coinId)) {
        final cacheTime = _cacheTimestamps[coinId];
        if (cacheTime != null &&
            DateTime.now().difference(cacheTime) < cacheDuration) {
          final cachedCoin = _cache[coinId]!;
          validCache[cachedCoin.symbol.toLowerCase()] = cachedCoin;
        } else {
          // ❌ Remove expired entries
          _cache.remove(coinId);
          _cacheTimestamps.remove(coinId);
        }
      }
    }

    return validCache;
  }

  /// Save new data to cache using CoinGecko ID
  void setCachedData(Map<String, CoinGeckoMarketData> newData) {
    for (var entry in newData.entries) {
      _cache[entry.key] = entry.value; // Store using CoinGecko ID
      _cacheTimestamps[entry.key] = DateTime.now();
    }
  }

  /// Check if Coin is in Cache**
  bool isCoinCached(String coinId) {
    final cacheTime = _cacheTimestamps[coinId];
    return cacheTime != null &&
        DateTime.now().difference(cacheTime) < cacheDuration;
  }
}
