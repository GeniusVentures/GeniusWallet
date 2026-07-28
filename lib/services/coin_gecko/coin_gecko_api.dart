import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/hive/models/historical_price_cache_entry.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

const Duration cacheDuration = Duration(minutes: 3);

// Bounds a single outbound CoinGecko request. A healthy round trip is
// comfortably sub-second, so this does not fire on a merely slow-but-alive
// link; a black-holed socket (accepted but never answered — the client has no
// default timeout) is instead capped at roughly double the boot sequence's
// 1.5s minimum hold (13-02 D7) rather than hanging forever. Judgement call,
// not a measurement (13-CONTEXT Claude's Discretion; 13-RESEARCH A1) — the
// network-down walk in 13-05 is what revisits this value.
const Duration requestTimeout = Duration(seconds: 3);

/// Fetches historical prices for a coin from CoinGecko API
Future<Map<int, double>> fetchHistoricalPrices(String coinId) async {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;

  final Box<HistoricalPriceCacheEntry> box =
      Hive.box<HistoricalPriceCacheEntry>(historicalPricesBox);

  // Check for existing cached entry
  final HistoricalPriceCacheEntry? cacheEntry = box.get(coinId);

  if (cacheEntry != null) {
    final cacheAge = now - cacheEntry.timestamp;

    if (cacheAge <= cacheDuration.inSeconds) {
      return cacheEntry.toIntMap();
    }
  }

  // API endpoint
  final String historyApi =
      'https://api.coingecko.com/api/v3/coins/$coinId/market_chart?vs_currency=usd&days=1';

  try {
    final response = await http
        .get(Uri.parse(historyApi))
        .timeout(requestTimeout);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> prices = data['prices'];

      final Map<int, double> historicalPrices = {
        for (var entry in prices)
          (entry[0] ~/ 1000): (entry[1] as num).toDouble(),
      };

      final newCacheEntry = HistoricalPriceCacheEntry.fromIntMap(
        historicalPrices,
        now,
      );
      await box.put(coinId, newCacheEntry);

      return historicalPrices;
    } else {
      debugPrint(
        'Historical - API error (${response.statusCode}): ${response.body}',
      );

      if (cacheEntry != null) {
        return cacheEntry.toIntMap();
      }

      return {}; // No cache available
    }
  } catch (e) {
    debugPrint('Network error while fetching $coinId prices: $e');

    if (cacheEntry != null) {
      debugPrint('Returning old cached data for $coinId due to network error');
      return cacheEntry.toIntMap();
    }

    return {}; // No cache available
  }
}

Future<Map<String, CoinGeckoMarketData>> fetchCoinsMarketData({
  required List<String> coinIds,
}) async {
  if (coinIds.isEmpty) {
    return {};
  }

  // 🔹 Combine with other market coins if needed
  final marketCoins = getAllMarketDataCoinIds();
  final allCoinIds = {...coinIds, ...marketCoins}.toList();

  final Map<String, CoinGeckoMarketData> cachedData = {};
  // Keep stale entries for fallback instead of deleting them
  final Map<String, CoinGeckoMarketData> staleData = {};
  final List<String> staleCoinIds = [];

  final Box<CoinGeckoMarketData> marketBox = Hive.box<CoinGeckoMarketData>(
    marketDataBox,
  );
  final Box<String> timestampsBox = Hive.box<String>(marketTimestampsBox);

  // 🔹 Look for valid cache entries
  for (var coinId in allCoinIds) {
    final CoinGeckoMarketData? cachedCoin = marketBox.get(coinId);
    final String? timestampStr = timestampsBox.get(coinId);

    if (cachedCoin != null && timestampStr != null) {
      final DateTime? cacheTime = DateTime.tryParse(timestampStr);

      if (cacheTime != null &&
          DateTime.now().difference(cacheTime) < cacheDuration) {
        cachedData[cachedCoin.symbol.toLowerCase()] = cachedCoin;
      } else {
        staleData[cachedCoin.symbol.toLowerCase()] = cachedCoin;
        staleCoinIds.add(coinId);
      }
    }
  }

  // Determine which coins need fetching
  final List<String> missingCoinIds = allCoinIds.where((id) {
    final String? timestampStr = timestampsBox.get(id);
    final DateTime? cacheTime = timestampStr != null
        ? DateTime.tryParse(timestampStr)
        : null;
    return cacheTime == null ||
        DateTime.now().difference(cacheTime) >= cacheDuration;
  }).toList();

  if (missingCoinIds.isEmpty) {
    return cachedData;
  }

  final String marketApi =
      'https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=${missingCoinIds.join(',')}&sparkline=true';

  try {
    final response = await http
        .get(Uri.parse(marketApi))
        .timeout(requestTimeout);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      final nowString = DateTime.now().toIso8601String();
      final Map<String, CoinGeckoMarketData> newMarketData = {};

      for (var coin in data) {
        final marketData = CoinGeckoMarketData.fromJson(coin);

        // Update Hive cache
        await marketBox.put(marketData.id, marketData);
        await timestampsBox.put(marketData.id, nowString);

        newMarketData[marketData.symbol.toLowerCase()] = marketData;
      }

      // Clean up stale entries from Hive only after a successful fetch
      for (var coinId in staleCoinIds) {
        if (!newMarketData.values.any((m) => m.id == coinId)) {
          // Stale coin wasn't in the response — remove from Hive
          await marketBox.delete(coinId);
          await timestampsBox.delete(coinId);
        }
      }

      return {...cachedData, ...newMarketData};
    } else {
      debugPrint('Failed to fetch market data: ${response.body}');
    }
  } catch (e) {
    debugPrint('Error fetching market data: $e');
  }

  // Merge stale data into fallback so expired cache is still usable
  debugPrint("Returning cached market data due to API failure.");
  return {...staleData, ...cachedData};
}

Future<List<CoinGeckoCoin>> fetchAllCoinGeckoCoins() async {
  final box = Hive.box(coinGeckoCacheBox);

  // Check for cached data
  final cachedCoins = box.get(coinListBoxKey);
  final expiry = box.get(cacheExpiryKey);

  if (cachedCoins != null && expiry != null) {
    final expiryDate = DateTime.tryParse(expiry);
    if (expiryDate != null && DateTime.now().isBefore(expiryDate)) {
      return List<CoinGeckoCoin>.from(cachedCoins as List);
    }
  }

  // If cache is missing or expired, fetch new data
  final url = Uri.parse(
    "https://api.coingecko.com/api/v3/coins/list?include_platform=true",
  );

  try {
    final response = await http.get(url).timeout(requestTimeout);

    if (response.statusCode == 200) {
      final coins = json.decode(response.body) as List<dynamic>;

      final coinList = coins
          .map(
            (coin) => CoinGeckoCoin(
              id: coin['id'] ?? '',
              symbol: coin['symbol'] ?? '',
              name: coin['name'] ?? '',
            ),
          )
          .toList();

      // Cache the new list and expiry time
      await box.put(coinListBoxKey, coinList);
      await box.put(
        cacheExpiryKey,
        DateTime.now().add(cacheDuration).toIso8601String(),
      );

      return coinList;
    } else {
      throw Exception("Failed to load coins from CoinGecko");
    }
  } catch (e) {
    debugPrint("Error fetching coin list: $e");

    // Return cached data even if expired as fallback
    if (cachedCoins != null) {
      debugPrint("Returning expired cached data...");
      return List<CoinGeckoCoin>.from(cachedCoins as List);
    }

    return [];
  }
}

/// **Search for coins by name (case-insensitive)**
Future<List<CoinGeckoCoin>> searchCoinsByName(
  String query, {
  int? maxResults, // Optional param with no default limit
}) async {
  final allCoins = await fetchAllCoinGeckoCoins(); // Get cached or fresh data

  // Filter coins matching the query (case-insensitive)
  final matchingCoins = allCoins
      .where((coin) => coin.name.toLowerCase().contains(query.toLowerCase()))
      .toList();

  // If maxResults is provided, return a limited subset
  if (maxResults != null && maxResults > 0) {
    final endIndex = matchingCoins.length < maxResults
        ? matchingCoins.length
        : maxResults;

    return matchingCoins.sublist(0, endIndex);
  }

  // Return all matching coins if no limit specified
  return matchingCoins;
}

/// Represents a balance for a specific coin
class CoinBalance {
  final String coinId;
  final double balance;

  CoinBalance({required this.coinId, required this.balance});
}

Future<String?> fetchCoinPricesSum({
  required List<String> coinIds,
  required List<CoinBalance> coinBalances,
  required GeniusApi geniusApi,
}) async {
  final marketData = await fetchCoinsMarketData(coinIds: coinIds);

  if (marketData.isEmpty) {
    geniusApi.updateAccountFetchDate();
    return null;
  }

  final Map<String, double> coinPrices = marketData.map(
    (key, value) => MapEntry(key, value.currentPrice),
  );

  final double totalBalance = calculateTotalBalance(coinBalances, coinPrices);

  geniusApi.saveAccountBalance(totalBalance);

  return "\$ ${NumberFormat('#,##0.00').format(totalBalance)}";
}

/// 🏦 **Helper Function: Calculates Total Balance**
double calculateTotalBalance(
  List<CoinBalance> coinBalances,
  Map<String, double> coinPrices,
) {
  return coinBalances.fold(0, (sum, element) {
    final coinPrice = coinPrices[element.coinId] ?? 0.0;
    return sum + (coinPrice * element.balance);
  });
}
