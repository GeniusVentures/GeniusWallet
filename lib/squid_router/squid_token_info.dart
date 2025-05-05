class SquidTokenInfo {
  final int chainId;
  final String address;
  final String name;
  final String symbol;
  final int decimals;
  final bool crosschain;
  final String commonKey;
  final String logoURI;
  final String coingeckoId;

  SquidTokenInfo({
    required this.chainId,
    required this.address,
    required this.name,
    required this.symbol,
    required this.decimals,
    required this.crosschain,
    required this.commonKey,
    required this.logoURI,
    required this.coingeckoId,
  });

  factory SquidTokenInfo.fromJson(Map<String, dynamic> json) {
    return SquidTokenInfo(
      chainId: json['chainId'],
      address: json['address'],
      name: json['name'],
      symbol: json['symbol'],
      decimals: json['decimals'],
      crosschain: json['crosschain'],
      commonKey: json['commonKey'],
      logoURI: json['logoURI'],
      coingeckoId: json['coingeckoId'],
    );
  }
}
