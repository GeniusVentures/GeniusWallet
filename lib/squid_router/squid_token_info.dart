class SquidTokenInfo {
  final String address;
  final String symbol;
  final String name;
  final int chainId;
  final int decimals;
  final String? logoURI;

  SquidTokenInfo({
    required this.address,
    required this.symbol,
    required this.name,
    required this.chainId,
    required this.decimals,
    this.logoURI,
  });

  factory SquidTokenInfo.fromJson(Map<String, dynamic> json) {
    return SquidTokenInfo(
      address: json['address'],
      symbol: json['symbol'],
      name: json['name'],
      chainId: json['chainId'],
      decimals: json['decimals'],
      logoURI: json['logoURI'],
    );
  }

  String get display => '$symbol (Chain $chainId)';
}
