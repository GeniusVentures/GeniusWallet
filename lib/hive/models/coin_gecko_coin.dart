import 'package:hive/hive.dart';

part 'coin_gecko_coin.g.dart'; // Generated adapter file

@HiveType(typeId: 0)
class CoinGeckoCoin {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String name;

  CoinGeckoCoin({
    required this.id,
    required this.symbol,
    required this.name,
  });

  factory CoinGeckoCoin.fromJson(Map<String, dynamic> json) => CoinGeckoCoin(
        id: json['id'] ?? '',
        symbol: json['symbol'] ?? '',
        name: json['name'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'symbol': symbol,
        'name': name,
      };
}
