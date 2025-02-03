class CoinGeckoCoin {
  final String id;
  final String symbol;
  final String name;

  CoinGeckoCoin({required this.id, required this.symbol, required this.name});

  /// Convert JSON Map to Coin object
  factory CoinGeckoCoin.fromJson(Map<String, dynamic> json) {
    return CoinGeckoCoin(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
    );
  }

  /// Convert Coin object to JSON Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
    };
  }
}
