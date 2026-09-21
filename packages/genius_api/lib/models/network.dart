import 'package:freezed_annotation/freezed_annotation.dart';

part 'network.freezed.dart';
part 'network.g.dart';

@freezed
abstract class Network with _$Network {
  const factory Network({
    String? name,

    /// The CHAIN's key — what `networkSymbol` carries and what the explorer
    /// map resolves a transaction's URL from. Not always the coin you spend.
    String? symbol,

    /// The ticker of the coin this chain charges gas in, when it differs from
    /// [symbol]. Base's chain key is "base"; the coin it spends is ETH.
    /// Falls back to [symbol], which is correct for every chain named after
    /// its own currency.
    String? nativeSymbol,
    int? chainId,
    String? coinGeckoId,
    String? rpcUrl,
    String? iconPath,
    String? tokensPath,
  }) = _Network;

  factory Network.fromJson(Map<String, Object?> json) =>
      _$NetworkFromJson(json);
}
