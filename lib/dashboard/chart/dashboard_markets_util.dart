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

// This will only return a subset of coins for now.
Future<List<CoinGeckoCoin>> getDashboardMarketCoins() async {
  final coins = await fetchAllCoinGeckoCoins();

  // Convert list to a Map for O(1) lookup time
  final Map<String, CoinGeckoCoin> coinMap = {
    for (var coin in coins) coin.id: coin
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
    for (var coin in coins) coin.id: coin
  };

  // Retrieve only the requested IDs
  return topCoinsByCapitalization
      .map((id) => coinMap[id])
      .whereType<CoinGeckoCoin>()
      .toList();
}
