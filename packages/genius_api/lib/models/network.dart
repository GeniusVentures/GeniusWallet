import 'package:freezed_annotation/freezed_annotation.dart';

part 'network.freezed.dart';
part 'network.g.dart';

@freezed
class Network with _$Network {
  const factory Network(
      {String? name,
      String? symbol,
      int? chainId,
      String? rpcUrl,
      String? iconPath,
      String? tokensPath}) = _Network;

  factory Network.fromJson(Map<String, Object?> json) =>
      _$NetworkFromJson(json);
}
