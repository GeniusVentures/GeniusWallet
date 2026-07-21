/// Pure, widget-free totals math for the dashboard Assets panel.
///
/// Deliberately free of any Flutter/Hive import so the one non-trivial
/// computation in this change (the balance*price*pct fold) is directly
/// unit-testable without constructing the heavy `CoinGeckoMarketData` model.
/// Single source for the math consumed by both the Assets header and
/// `CoinsScreenState._calculateTotalValue`.
library;

/// Fiat value of a single holding.
double holdingValue(double balance, double price) => balance * price;

/// 24h fiat change of a single holding, given its 24h percentage move.
double holdingDayChange(double balance, double price, double pct) =>
    balance * price * pct / 100;

/// Total fiat value across all holdings.
double assetsTotal(Iterable<({double balance, double price})> holdings) =>
    holdings.fold(0.0, (sum, h) => sum + holdingValue(h.balance, h.price));

/// Total 24h fiat change across all holdings.
double assetsDayChange(
        Iterable<({double balance, double price, double pct})> holdings) =>
    holdings.fold(
        0.0, (sum, h) => sum + holdingDayChange(h.balance, h.price, h.pct));
