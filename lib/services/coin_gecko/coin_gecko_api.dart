import 'dart:convert';
import 'package:genius_api/genius_api.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

final String apiKey = ""; // Optional API Key if required

/// Represents a balance for a specific coin
class CoinBalance {
  final String coinId;
  final double balance;

  CoinBalance({required this.coinId, required this.balance});
}

/// **Cache Entry Class**
class _CoinPricesCacheEntry {
  final Map<String, double> data;
  final int timestamp;

  _CoinPricesCacheEntry({required this.data, required this.timestamp});
}

// Cache storage with expiration
final Map<String, _CoinPricesCacheEntry> _coinPricesCache = {};

/// 📡 **Fetches Live Coin Prices from CoinGecko API**
/// - If cached data exists and is fresh (≤60 seconds old), return it.
/// - If API call fails (rate-limited or error), return existing cached data.
/// - If API call succeeds, update the cache.
Future<Map<String, double>> fetchCoinPrices({required String coinIds}) async {
  final now =
      DateTime.now().millisecondsSinceEpoch ~/ 1000; // Current time (sec)

  // Check if the data exists in cache and is still valid
  if (_coinPricesCache.containsKey(coinIds)) {
    final cacheEntry = _coinPricesCache[coinIds]!;
    final cacheAge = now - cacheEntry.timestamp;

    if (cacheAge <= 60) {
      print('✅ Returning cached prices for $coinIds (Age: $cacheAge sec)');
      return cacheEntry.data;
    }
  }

  // API endpoint
  String priceApi =
      'https://api.coingecko.com/api/v3/simple/price?ids=$coinIds&vs_currencies=usd';

  try {
    final response = await http.get(Uri.parse(priceApi));

    if (response.statusCode == 200) {
      final Map<String, dynamic> coinPrices = jsonDecode(response.body);

      // Convert API response into { "bitcoin": 45000.23 }
      Map<String, double> parsedPrices = coinPrices
          .map((key, value) => MapEntry(key, value['usd']?.toDouble() ?? 0.0));

      // ✅ Update cache with new data
      _coinPricesCache[coinIds] = _CoinPricesCacheEntry(
        data: parsedPrices,
        timestamp: now,
      );

      print('🆕 Fetched new prices from API for $coinIds');
      return parsedPrices;
    } else {
      print('❌ API error (${response.statusCode}): ${response.body}');

      // ⚠️ If API fails, return existing cached data instead of invalidating
      if (_coinPricesCache.containsKey(coinIds)) {
        print('⚠️ Returning old cached prices for $coinIds due to API failure');
        return _coinPricesCache[coinIds]!.data;
      }

      return {}; // No cache available, return empty data
    }
  } catch (e) {
    print('⚠️ Network error while fetching prices for $coinIds: $e');

    // ⚠️ If API fails, return existing cached data instead of invalidating
    if (_coinPricesCache.containsKey(coinIds)) {
      print('⚠️ Returning old cached prices for $coinIds due to network error');
      return _coinPricesCache[coinIds]!.data;
    }

    return {}; // No cache available, return empty data
  }
}

// Cache storage with expiration
final Map<String, _CacheEntry> _historicalPricesCache = {};

/// **Fetches historical prices for a coin from CoinGecko API**
/// - If cached data exists and is fresh (≤60 seconds old), return it.
/// - If API call fails (rate-limited or error), return existing cached data.
/// - If API call succeeds, update the cache.
Future<Map<int, double>> fetchHistoricalPrices(String coinId) async {
  final now =
      DateTime.now().millisecondsSinceEpoch ~/ 1000; // Current time (sec)

  // Check if the coin data is already in cache and is still valid
  if (_historicalPricesCache.containsKey(coinId)) {
    final cacheEntry = _historicalPricesCache[coinId]!;
    final cacheAge = now - cacheEntry.timestamp;

    if (cacheAge <= 60) {
      print('✅ Returning cached data for $coinId (Age: $cacheAge sec)');
      return cacheEntry.data;
    }
  }

  // API endpoint
  String historyApi =
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=1';

  try {
    final response = await http.get(Uri.parse(historyApi));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> prices = data['prices'];

      // Convert API response into a map of { timestamp (sec) : price }
      Map<int, double> historicalPrices = {
        for (var entry in prices)
          (entry[0] ~/ 1000):
              (entry[1] as num).toDouble(), // Convert timestamp & price
      };

      // ✅ Update the cache with new data
      _historicalPricesCache[coinId] = _CacheEntry(
        data: historicalPrices,
        timestamp: now,
      );

      print('🆕 Fetched new data for $coinId from API');
      return historicalPrices;
    } else {
      print('❌ API error (${response.statusCode}): ${response.body}');

      // ⚠️ If API fails, return existing cache instead of invalidating it
      if (_historicalPricesCache.containsKey(coinId)) {
        print('⚠️ Returning old cached data for $coinId due to API failure');
        return _historicalPricesCache[coinId]!.data;
      }

      return {}; // No cache available, return empty data
    }
  } catch (e) {
    print('⚠️ Network error while fetching $coinId prices: $e');

    // ⚠️ If API fails, return existing cache instead of invalidating it
    if (_historicalPricesCache.containsKey(coinId)) {
      print('⚠️ Returning old cached data for $coinId due to network error');
      return _historicalPricesCache[coinId]!.data;
    }

    return {}; // No cache available, return empty data
  }
}

/// **Cache Entry Class**
class _CacheEntry {
  final Map<int, double> data;
  final int timestamp;

  _CacheEntry({required this.data, required this.timestamp});
}

/// 💰 **Fetches Coin Prices & Calculates Total Balance in USD**
Future<String?> fetchCoinPricesSum({
  required String coinIds,
  required List<CoinBalance> coinBalances,
  required GeniusApi geniusApi,
}) async {
  final coinPrices = await fetchCoinPrices(coinIds: coinIds);

  if (coinPrices.isEmpty) {
    geniusApi.updateAccountFetchDate();
    return null;
  }

  double totalBalance = calculateTotalBalance(coinBalances, coinPrices);

  geniusApi.saveAccountBalance(totalBalance);

  return "\$ ${NumberFormat('#,##0.00').format(totalBalance)}";
}

/// 🏦 **Helper Function: Calculates Total Balance**
double calculateTotalBalance(
    List<CoinBalance> coinBalances, Map<String, double> coinPrices) {
  return coinBalances.fold(0, (sum, element) {
    final coinPrice = coinPrices[element.coinId] ?? 0.0;
    return sum + (coinPrice * element.balance);
  });
}
