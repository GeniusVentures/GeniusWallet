import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';

// DEV-ONLY: fixture provider for the phase-05 dashboard walk. Supplies four
// offline, deterministic scenarios (Populated / Long-extreme / Missing-icon /
// Clear) so the dashboard can be visually walked without a live wallet or a
// CoinGecko network call. Never used outside kDebugMode && kShowDevTools
// call sites — see dev_tools_bubble.dart for the buttons that drive this.
class DevMockHoldings {
  DevMockHoldings._();

  static final DevMockHoldings instance = DevMockHoldings._();

  bool mockMode = false;
  List<Coin> coins = const [];

  /// Keyed by lowercase symbol, matching CoinCardRow's lookup convention.
  Map<String, CoinGeckoMarketData> marketData = const {};

  /// Sum of (balance * currentPrice) across [coins], formatted as a plain
  /// number string (no symbol/commas) so it parses cleanly via
  /// `double.tryParse` for the hero balance.
  String get totalBalance {
    double total = 0;
    for (final coin in coins) {
      final data = marketData[coin.symbol?.toLowerCase()];
      if (data != null) {
        total += (coin.balance ?? 0) * data.currentPrice;
      }
    }
    return total.toStringAsFixed(2);
  }

  /// Scenario A — mixed +/- holdings with both a green gainer (ETH) and a
  /// red loser (GNUS).
  void loadPopulated() {
    mockMode = true;
    coins = const [
      Coin(
        name: 'GeniusAI',
        symbol: 'GNUS',
        iconPath: 'assets/images/crypto/gnus.png',
        balance: 1200,
      ),
      Coin(
        name: 'Ethereum',
        symbol: 'ETH',
        iconPath: 'assets/images/crypto/eth.png',
        balance: 1.35,
      ),
      Coin(
        name: 'USD Coin',
        symbol: 'USDC',
        iconPath: 'assets/images/crypto/usdc.png',
        balance: 250,
      ),
      Coin(
        name: 'Tether USD',
        symbol: 'USDT',
        iconPath: 'assets/images/crypto/usdt.png',
        balance: 500,
      ),
    ];
    marketData = {
      'gnus': _fixture(
        symbol: 'GNUS',
        currentPrice: 0.85,
        priceChangePercentage24h: -5.40,
      ),
      'eth': _fixture(
        symbol: 'ETH',
        currentPrice: 3200.00,
        priceChangePercentage24h: 3.20,
      ),
      'usdc': _fixture(
        symbol: 'USDC',
        currentPrice: 1.00,
        priceChangePercentage24h: 0.02,
      ),
      'usdt': _fixture(
        symbol: 'USDT',
        currentPrice: 1.00,
        priceChangePercentage24h: -0.06,
      ),
    };
  }

  /// Scenario B — long name / extreme balance & price values, stresses row
  /// overflow + AutoSizeText per 05-03 criterion 5.
  void loadExtreme() {
    mockMode = true;
    coins = const [
      Coin(
        name: 'Megatoken Ultra Long Display Name Coin',
        symbol: 'MEGALONGSYM',
        iconPath: 'assets/images/crypto/agi.png',
        balance: 123456789.123456789,
      ),
      Coin(
        name: 'Whale',
        symbol: 'WHL',
        iconPath: 'assets/images/crypto/sol.png',
        balance: 9876543.21,
      ),
    ];
    marketData = {
      'megalongsym': _fixture(
        symbol: 'MEGALONGSYM',
        currentPrice: 0.000000012345,
        priceChangePercentage24h: 12.34,
      ),
      'whl': _fixture(
        symbol: 'WHL',
        currentPrice: 123456.78,
        priceChangePercentage24h: -8.90,
      ),
    };
  }

  /// Scenario C — empty iconPath, exercises the `image_not_supported`
  /// fallback in `buildTokenIcon`.
  void loadMissingIcon() {
    mockMode = true;
    coins = const [
      Coin(name: 'No Icon Coin', symbol: 'NOICON', iconPath: '', balance: 42.5),
    ];
    marketData = {
      'noicon': _fixture(
        symbol: 'NOICON',
        currentPrice: 12.34,
        priceChangePercentage24h: 2.10,
      ),
    };
  }

  /// Scenario E - a held token the price feed does not cover.
  ///
  /// `UNLST` carries a real balance and has NO entry in [marketData], which
  /// makes it an "unpriced holding": the one row on `/assets` that leads the
  /// list when descending and trails it when ascending (phase 25 D-1). No
  /// other scenario produces that case, and on Jakub's real wallet - where
  /// every balance is zero - it is otherwise unreachable, so the rule could
  /// only be checked in a unit test and never on a device.
  ///
  /// GNUS and ETH carry real balances AND prices so the unpriced row has
  /// funded rows to be ranked against; against an all-zero wallet it would
  /// lead trivially and prove nothing.
  void loadUnpriced() {
    mockMode = true;
    coins = const [
      Coin(
        name: 'GeniusAI',
        symbol: 'GNUS',
        iconPath: 'assets/images/crypto/gnus.png',
        balance: 1200,
      ),
      Coin(
        name: 'Ethereum',
        symbol: 'ETH',
        iconPath: 'assets/images/crypto/eth.png',
        balance: 1.35,
      ),
      Coin(
        name: 'Unlisted Token',
        symbol: 'UNLST',
        iconPath: '',
        balance: 42.5,
      ),
    ];
    marketData = {
      'gnus': _fixture(
        symbol: 'GNUS',
        currentPrice: 0.85,
        priceChangePercentage24h: -5.40,
      ),
      'eth': _fixture(
        symbol: 'ETH',
        currentPrice: 3200.00,
        priceChangePercentage24h: 3.20,
      ),
      // 'unlst' is deliberately absent. Do not add it.
    };
  }

  /// Scenario D — mock-mode OFF, wipe coins + market data, return to the
  /// real (empty) wallet state.
  void clear() {
    mockMode = false;
    coins = const [];
    marketData = const {};
  }

  /// Builds a [CoinGeckoMarketData] from just the fields the scenario tables
  /// care about; every other required field gets a harmless default so the
  /// scenario tables above stay terse.
  CoinGeckoMarketData _fixture({
    required String symbol,
    required double currentPrice,
    required double priceChangePercentage24h,
  }) {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return CoinGeckoMarketData(
      id: symbol.toLowerCase(),
      symbol: symbol.toLowerCase(),
      name: symbol,
      imageUrl: '',
      currentPrice: currentPrice,
      marketCap: 0,
      marketCapRank: 0,
      fullyDilutedValuation: 0,
      totalVolume: 0,
      high24h: 0,
      low24h: 0,
      priceChange24h: 0,
      priceChangePercentage24h: priceChangePercentage24h,
      marketCapChange24h: 0,
      marketCapChangePercentage24h: 0,
      circulatingSupply: 0,
      totalSupply: 0,
      maxSupply: null,
      ath: 0,
      athChangePercentage: 0,
      athDate: epoch,
      atl: 0,
      atlChangePercentage: 0,
      atlDate: epoch,
      lastUpdated: epoch,
      sparkline: null,
    );
  }
}
