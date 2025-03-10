import 'package:hive/hive.dart';

part 'coin_gecko_market_data.g.dart'; // This will be generated

@HiveType(typeId: 1)
class CoinGeckoMarketData {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String name;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final double currentPrice;

  @HiveField(5)
  final double marketCap;

  @HiveField(6)
  final int marketCapRank;

  @HiveField(7)
  final double fullyDilutedValuation;

  @HiveField(8)
  final double totalVolume;

  @HiveField(9)
  final double high24h;

  @HiveField(10)
  final double low24h;

  @HiveField(11)
  final double priceChange24h;

  @HiveField(12)
  final double priceChangePercentage24h;

  @HiveField(13)
  final double marketCapChange24h;

  @HiveField(14)
  final double marketCapChangePercentage24h;

  @HiveField(15)
  final double circulatingSupply;

  @HiveField(16)
  final double totalSupply;

  @HiveField(17)
  final double? maxSupply;

  @HiveField(18)
  final double ath;

  @HiveField(19)
  final double athChangePercentage;

  @HiveField(20)
  final DateTime athDate;

  @HiveField(21)
  final double atl;

  @HiveField(22)
  final double atlChangePercentage;

  @HiveField(23)
  final DateTime atlDate;

  @HiveField(24)
  final DateTime lastUpdated;

  CoinGeckoMarketData({
    required this.id,
    required this.symbol,
    required this.name,
    required this.imageUrl,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.fullyDilutedValuation,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.marketCapChange24h,
    required this.marketCapChangePercentage24h,
    required this.circulatingSupply,
    required this.totalSupply,
    required this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    required this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    required this.atlDate,
    required this.lastUpdated,
  });

  /// From JSON (API Response)
  factory CoinGeckoMarketData.fromJson(Map<String, dynamic> json) {
    return CoinGeckoMarketData(
      id: json['id'] ?? '',
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['image'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      marketCapRank: json['market_cap_rank'] ?? 0,
      fullyDilutedValuation:
          (json['fully_diluted_valuation'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      marketCapChange24h:
          (json['market_cap_change_24h'] as num?)?.toDouble() ?? 0.0,
      marketCapChangePercentage24h:
          (json['market_cap_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply:
          (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      totalSupply: (json['total_supply'] as num?)?.toDouble() ?? 0.0,
      maxSupply: (json['max_supply'] as num?)?.toDouble(),
      ath: (json['ath'] as num?)?.toDouble() ?? 0.0,
      athChangePercentage:
          (json['ath_change_percentage'] as num?)?.toDouble() ?? 0.0,
      athDate: _parseDateTime(json['ath_date']),
      atl: (json['atl'] as num?)?.toDouble() ?? 0.0,
      atlChangePercentage:
          (json['atl_change_percentage'] as num?)?.toDouble() ?? 0.0,
      atlDate: _parseDateTime(json['atl_date']),
      lastUpdated: _parseDateTime(json['last_updated']),
    );
  }

  static DateTime _parseDateTime(dynamic dateStr) {
    if (dateStr == null || dateStr == '') {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
    try {
      return DateTime.parse(dateStr);
    } catch (e) {
      print("⚠️ Failed to parse DateTime: $dateStr");
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// To JSON (optional if you need JSON again)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': imageUrl,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'fully_diluted_valuation': fullyDilutedValuation,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'market_cap_change_24h': marketCapChange24h,
      'market_cap_change_percentage_24h': marketCapChangePercentage24h,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
      'ath': ath,
      'ath_change_percentage': athChangePercentage,
      'ath_date': athDate.toIso8601String(),
      'atl': atl,
      'atl_change_percentage': atlChangePercentage,
      'atl_date': atlDate.toIso8601String(),
      'last_updated': lastUpdated.toIso8601String(),
    };
  }
}
