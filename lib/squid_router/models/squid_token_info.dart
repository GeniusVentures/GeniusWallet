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

  /// Token identity. **Address alone is not it** - the same address exists on
  /// several chains and this list is explicitly cross-chain, so both halves are
  /// load-bearing.
  ///
  /// Written once because it was previously spelled out three times: twice in
  /// `swap_screen.dart` as a De Morgan'd exclusion
  /// (`t.address != x.address || t.chainId != x.chainId`) and once in
  /// `token_selector_drawer.dart` as the selection test. The two spellings
  /// disagreed about what they were for, which is how the picker ended up
  /// hiding the very token it had been told to mark as selected.
  bool sameAs(SquidTokenInfo? other) =>
      other != null &&
      address.toLowerCase() == other.address.toLowerCase() &&
      chainId == other.chainId;

  String get display =>
      '$symbol ${balance != null ? ' - ${balance!.formattedBalance}' : ''}';
}
