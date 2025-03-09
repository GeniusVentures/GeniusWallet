import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/models/coin_gecko_coin.dart';
import 'package:genius_wallet/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_market_cache.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Represents a balance for a specific coin
class CoinBalance {
  final String coinId;
  final double balance;

  CoinBalance({required this.coinId, required this.balance});
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

      print('🆕 Historical - Fetched new data for $coinId from API');
      return historicalPrices;
    } else {
      print(
          '❌ Historical - API error (${response.statusCode}): ${response.body}');

      // ⚠️ If API fails, return existing cache instead of invalidating it
      if (_historicalPricesCache.containsKey(coinId)) {
        print(
            '⚠️ Historical - Returning old cached data for $coinId due to API failure');
        return _historicalPricesCache[coinId]!.data;
      }

      return {}; // No cache available, return empty data
    }
  } catch (e) {
    print('⚠️ Historical - Network error while fetching $coinId prices: $e');

    // ⚠️ If API fails, return existing cache instead of invalidating it
    if (_historicalPricesCache.containsKey(coinId)) {
      print(
          '⚠️ Historical - Returning old cached data for $coinId due to network error');
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
Future<String?> fetchCoinPricesSum(
    {required List<String> coinIds,
    required List<CoinBalance> coinBalances,
    required GeniusApi geniusApi}) async {
  final marketData = await fetchCoinsMarketData(coinIds: coinIds);

  if (marketData.isEmpty) {
    geniusApi.updateAccountFetchDate();
    return null;
  }

  Map<String, double> coinPrices =
      marketData.map((key, value) => MapEntry(key, value.currentPrice));

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

final CoinMarketCache _coinMarketCache = CoinMarketCache();

/// **Fetches market data from CoinGecko**
Future<Map<String, CoinGeckoMarketData>> fetchCoinsMarketData(
    {required List<String> coinIds}) async {
  if (coinIds.isEmpty) return {};

  // 🔹 **Include all market coins in cache**
  final marketCoins = getAllMarketDataCoinIds();
  final allCoinIds = {...coinIds, ...marketCoins}.toList();

  // 🔹 **Check cache first**
  final Map<String, CoinGeckoMarketData> cachedData =
      _coinMarketCache.getCachedData(allCoinIds);

  // 🔹 **Find missing coins that need API fetching**
  final List<String> missingCoinIds =
      allCoinIds.where((id) => !_coinMarketCache.isCoinCached(id)).toList();

  if (missingCoinIds.isEmpty) {
    print("✅ Returning all coins from cache.");
    return cachedData;
  }

  print("🆕 Fetching missing coins from API: ${missingCoinIds.join(',')}");

  // 🔹 **API Call for only missing coins**
  final String marketApi =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${missingCoinIds.join(',')}';

  try {
    final response = await http.get(Uri.parse(marketApi));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      // 🔹 **Convert list to map using CoinGecko ID as key**
      Map<String, CoinGeckoMarketData> newMarketData = {
        for (var coin in data) coin['id']: CoinGeckoMarketData.fromJson(coin)
      };

      // 🔹 **Cache the new data using CoinGecko ID**
      _coinMarketCache.setCachedData(newMarketData);

      // 🔹 **Return data using Coin Symbol as the key**
      return {
        ...cachedData,
        ...{
          for (var entry in newMarketData.entries)
            entry.value.symbol.toLowerCase(): entry.value
        }
      };
    } else {
      print('❌ Failed to fetch market data: ${response.body}');
    }
  } catch (e) {
    print('⚠️ Error fetching market data: $e');
  }

  // 🔹 **Return only cached data if API fails**
  print("⚠️ Returning only cached data due to API failure.");
  return cachedData;
}

// Cache variables
List<CoinGeckoCoin>? _cachedCoinList;
DateTime? _cacheExpiryTime;

/// **Fetch the complete list of coins from CoinGecko (with 1 hour caching)**
Future<List<CoinGeckoCoin>> fetchAllCoinGeckoCoins() async {
  final url = Uri.parse("https://api.coingecko.com/api/v3/coins/list");

  // If cached data is available and still valid, return it
  if (_cachedCoinList != null &&
      _cacheExpiryTime != null &&
      DateTime.now().isBefore(_cacheExpiryTime!)) {
    print("Returning cached coin list...");
    return _cachedCoinList!;
  }

  try {
    print("Fetching new coin list from CoinGecko...");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List<dynamic> coins = json.decode(response.body);

      // Convert JSON list to List<CoinGeckoCoin>
      _cachedCoinList = coins
          .map((coin) => CoinGeckoCoin(
                id: coin["id"] ?? "",
                symbol: coin["symbol"] ?? "",
                name: coin["name"] ?? "",
              ))
          .toList();

      // Set cache expiry time to 1 hour from now
      _cacheExpiryTime = DateTime.now().add(const Duration(hours: 1));

      return _cachedCoinList!;
    } else {
      throw Exception("Failed to load coins from CoinGecko");
    }
  } catch (e) {
    print("Error fetching coin list: $e");
    return [];
  }
}

/// **Search for coins by name (case-insensitive)**
Future<List<CoinGeckoCoin>> searchCoinsByName(String query) async {
  final allCoins = await fetchAllCoinGeckoCoins(); // Get cached or fresh data

  return allCoins
      .where((coin) => coin.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
}
