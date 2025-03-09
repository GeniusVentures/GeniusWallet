import 'package:genius_wallet/models/coin_gecko_coin.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';

final List<String> dashboardCoinIds = [
  "genius-ai",
  "bitcoin",
  "ethereum",
  "solana",
  "matic-network",
  "ripple",
  "cardano"
];

final List<String> marketsScreenCoinIds = [
  "genius-ai",
  "bitcoin",
  "ethereum",
  "solana",
  "matic-network",
  "ripple",
  "cardano",
  "tether",
  "binancecoin",
  "usd-coin",
  "dogecoin",
  "staked-ether",
  "tron",
  "pi-network",
  "wrapped-bitcoin",
  "chainlink",
  "hedera-hashgraph",
  "wrapped-steth",
  "leo-token",
  "stellar",
  "avalanche-2",
  "sui"
];

// We need to make sure we request all the market data so that we can cache it for other screens and reduce API calls.
List<String> getAllMarketDataCoinIds() {
  return {...dashboardCoinIds, ...marketsScreenCoinIds}.toList();
}

// This will only return a subset of coins for now.
Future<List<CoinGeckoCoin>> getDashboardMarketCoins() async {
  final coins = await fetchAllCoinGeckoCoins();

  // Convert list to a Map for O(1) lookup time
  final Map<String, CoinGeckoCoin> coinMap = {
    for (var coin in coins) coin.id: coin
  };

  // Retrieve only the requested IDs
  return dashboardCoinIds
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
  return marketsScreenCoinIds
      .map((id) => coinMap[id])
      .whereType<CoinGeckoCoin>()
      .toList();
}
