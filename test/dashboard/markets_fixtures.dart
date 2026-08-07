// Shared markets-page test fixtures, extracted from
// `markets_hero_height_test.dart` verbatim -- not a single field value is
// adjusted, because the wide-card literals pinned in that file (367.0,
// 301.0) were measured against exactly this data. Three consumers exist by
// the end of quick task 260807-bxs (this file's origin, the timeframe test,
// the cards test), which is the Rule of Three met, not anticipated.
import 'dart:math';

import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';

CoinGeckoCoin marketsFixtureCoin() =>
    CoinGeckoCoin(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin');

/// A 30-point RISING sparkline — `up` reads true, so the chart takes
/// `statusSuccess`, matching the deterministic trend-colour rule.
List<double> marketsFixtureRisingSparkline() =>
    List<double>.generate(30, (i) => 60000.0 + i * 120.0);

CoinGeckoMarketData marketsFixtureMarketData() {
  final sparkline = marketsFixtureRisingSparkline();
  final high = sparkline.reduce(max);
  final low = sparkline.reduce(min);
  return CoinGeckoMarketData(
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: '',
    currentPrice: sparkline.last,
    marketCap: 1.2e12,
    marketCapRank: 1,
    fullyDilutedValuation: 1.3e12,
    totalVolume: 3.4e10,
    high24h: high,
    low24h: low,
    priceChange24h: sparkline.last - sparkline.first,
    priceChangePercentage24h:
        ((sparkline.last - sparkline.first) / sparkline.first) * 100,
    marketCapChange24h: 0,
    marketCapChangePercentage24h: 0,
    circulatingSupply: 19700000,
    totalSupply: 21000000,
    maxSupply: 21000000,
    ath: high * 1.5,
    athChangePercentage: -10,
    athDate: DateTime(2026, 1, 1),
    atl: low * 0.5,
    atlChangePercentage: 500,
    atlDate: DateTime(2020, 1, 1),
    lastUpdated: DateTime(2026, 7, 29),
    sparkline: sparkline,
  );
}
