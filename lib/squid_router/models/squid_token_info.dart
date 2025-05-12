import 'package:genius_wallet/squid_router/models/squid_balance.dart';

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
  SquidBalance? balance; // Optional balance info

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
    this.balance,
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

  String get display =>
      '$symbol ${balance != null ? ' - ${balance!.formattedBalance}' : ''}';
}
