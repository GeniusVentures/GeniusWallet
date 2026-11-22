import 'dart:io';

import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/hive/models/historical_price_cache_entry.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

RandomAccessFile? _instanceLock;

/// The fd holding the app lock. Retained for the process lifetime: a dropped
/// reference could be finalized, closing the fd and silently freeing the
/// lock while the app still runs.
RandomAccessFile? get heldInstanceLock => _instanceLock;

/// Takes the process-lifetime lock that keeps a second copy of the app out of
/// Hive: a double launch races the per-box `.lock` checks and can truncate a
/// box under the winner. Returns false when another running copy holds it.
/// The OS frees the lock when the process dies, even on kill -9.
Future<bool> acquireSingleInstanceLock({Directory? dir}) async {
  final directory = dir ?? await appDataDirectory();
  final lockFile = File(
    '${directory.path}${Platform.pathSeparator}genius_wallet.instance.lock',
  );
  final handle = lockFile.openSync(mode: FileMode.append);
  try {
    await handle.lock(FileLock.exclusive);
  } on FileSystemException {
    await handle.close();
    return false;
  }
  _instanceLock = handle;
  return true;
}

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
  Hive.init((await appDataDirectory()).path);

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

  // One box first, alone, elects a single winner when two copies start at
  // once: the loser fails here holding nothing, instead of each copy taking
  // some of the concurrent locks below and both reporting "already running".
  await Hive.openBox(preferencesBoxName);

  await Future.wait([
    Hive.openBox(coinGeckoCacheBox),
    Hive.openBox<CoinGeckoMarketData>(marketDataBox),
    Hive.openBox<String>(marketTimestampsBox),
    Hive.openBox<HistoricalPriceCacheEntry>(historicalPricesBox),
    Hive.openBox<NewsArticle>(coinTelegraphNewsBox),
    Hive.openBox<String>(coinTelegraphTimestampBox),
    Hive.openBox(walletBoxName),
    Hive.openBox(networkBoxName),
  ]);
}

/// True when [e] means another running copy of the app holds a box's `.lock`
/// file: a `.lock` path failing with a lock-conflict code, so a read-only or
/// full disk still surfaces as its real error.
bool isHiveLockHeld(FileSystemException e) =>
    (e.path?.endsWith('.lock') ?? false) &&
    _lockConflictCodes.contains(e.osError?.errorCode);

// Windows ERROR_SHARING_VIOLATION / ERROR_LOCK_VIOLATION (33 measured on a
// second instance), Linux EAGAIN, macOS EAGAIN.
const _lockConflictCodes = {32, 33, 11, 35};
