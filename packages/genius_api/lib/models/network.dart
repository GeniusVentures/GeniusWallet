import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/types/network_symbol.dart';

part 'network.freezed.dart';
part 'network.g.dart';

@freezed
class Network with _$Network {
  const factory Network(
      {String? name,
      NetworkSymbol? symbol,
      int? chainId,
      String? rpcUrl,
      String? iconPath}) = _Network;

  factory Network.fromJson(Map<String, Object?> json) =>
      _$NetworkFromJson(json);
}
