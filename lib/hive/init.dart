import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/hive/models/historical_price_cache_entry.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive is used to cache api responses / online and offline
Future<void> initHive() async {
  /// Initialize Hive ( caching )
  await Hive.initFlutter();

  /// Register the adapter for CoinGeckoCoin
  Hive.registerAdapter(CoinGeckoCoinAdapter());
  await Hive.openBox(coinGeckoCacheBox);

  Hive.registerAdapter(CoinGeckoMarketDataAdapter());
  await Hive.openBox<CoinGeckoMarketData>(marketDataBox);
  await Hive.openBox<String>(marketTimestampsBox);

  Hive.registerAdapter(HistoricalPriceCacheEntryAdapter());
  await Hive.openBox<HistoricalPriceCacheEntry>(historicalPricesBox);

  Hive.registerAdapter(NewsArticleAdapter());
  await Hive.openBox<NewsArticle>(coinTelegraphNewsBox);
  await Hive.openBox<String>(coinTelegraphTimestampBox);

  await Hive.openBox(walletBoxName);

  await Hive.openBox(networkBoxName);

  // Transactions
  Hive
    ..registerAdapter(TransactionDirectionAdapter())
    ..registerAdapter(TransactionStatusAdapter())
    ..registerAdapter(TransactionTypeAdapter())
    ..registerAdapter(TransferRecipientsAdapter())
    ..registerAdapter(TransactionAdapter());
}
