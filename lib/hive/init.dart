import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/hive/models/historical_price_cache_entry.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Hive is used to cache api responses / online and offline
///
/// This runs BEFORE `runApp()`, so every millisecond here is a millisecond the
/// user spends looking at an empty window. Measured on macOS 2026-07-22: it was
/// **2061ms of a 2383ms pre-first-frame window** — 86% of it — because the ten
/// boxes were opened one `await` at a time and the disk reads simply summed.
///
/// Two changes, both behaviour-preserving:
///
/// 1. Every adapter is registered up front. `registerAdapter` is synchronous and
///    cheap, and having them all in place before any box opens is strictly safer
///    than the previous interleaving — an adapter can never now be registered
///    *after* a box that might need it.
/// 2. The boxes open concurrently. They are independent files, and nothing here
///    read one box to decide how to open another.
Future<void> initHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter(CoinGeckoCoinAdapter())
    ..registerAdapter(CoinGeckoMarketDataAdapter())
    ..registerAdapter(HistoricalPriceCacheEntryAdapter())
    ..registerAdapter(NewsArticleAdapter())
    ..registerAdapter(TransactionDirectionAdapter())
    ..registerAdapter(TransactionStatusAdapter())
    ..registerAdapter(TransactionTypeAdapter())
    ..registerAdapter(TransferRecipientsAdapter())
    ..registerAdapter(TransactionAdapter());

  await Future.wait([
    Hive.openBox(coinGeckoCacheBox),
    Hive.openBox<CoinGeckoMarketData>(marketDataBox),
    Hive.openBox<String>(marketTimestampsBox),
    Hive.openBox<HistoricalPriceCacheEntry>(historicalPricesBox),
    Hive.openBox<NewsArticle>(coinTelegraphNewsBox),
    Hive.openBox<String>(coinTelegraphTimestampBox),
    Hive.openBox(walletBoxName),
    Hive.openBox(networkBoxName),
    Hive.openBox(preferencesBoxName),
  ]);
}
