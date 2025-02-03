class CoinGeckoMarketData {
  final String id;
  final String symbol;
  final String name;
  final double currentPrice;
  final double marketCap;
  final double marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double circulatingSupply;
  final double totalSupply;
  final double ath;
  final double atl;
  final String image;

  CoinGeckoMarketData({
    required this.id,
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.ath,
    required this.atl,
    required this.image,
  });

  /// Factory constructor to create an object from API response
  factory CoinGeckoMarketData.fromJson(Map<String, dynamic> json) {
    return CoinGeckoMarketData(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: (json['current_price'] ?? 0.0).toDouble(),
      marketCap: (json['market_cap'] ?? 0.0).toDouble(),
      marketCapRank: (json['market_cap_rank'] ?? 0.0).toDouble(),
      totalVolume: (json['total_volume'] ?? 0.0).toDouble(),
      high24h: (json['high_24h'] ?? 0.0).toDouble(),
      low24h: (json['low_24h'] ?? 0.0).toDouble(),
      priceChange24h: (json['price_change_24h'] ?? 0.0).toDouble(),
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] ?? 0.0).toDouble(),
      circulatingSupply: (json['circulating_supply'] ?? 0.0).toDouble(),
      totalSupply: (json['total_supply'] ?? 0.0).toDouble(),
      ath: (json['ath'] ?? 0.0).toDouble(),
      atl: (json['atl'] ?? 0.0).toDouble(),
      image: json['image'] ?? '',
    );
  }
}
