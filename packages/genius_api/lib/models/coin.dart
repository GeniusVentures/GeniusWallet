import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:genius_api/types/network_symbol.dart';

part 'coin.freezed.dart';
part 'coin.g.dart';

@freezed
class Coin with _$Coin {
  const factory Coin(
      {String? name,
      String? symbol,
      double? balance,
      NetworkSymbol? networkSymbol,
      String? iconPath}) = _Coin;

  factory Coin.fromJson(Map<String, Object?> json) => _$CoinFromJson(json);
}
