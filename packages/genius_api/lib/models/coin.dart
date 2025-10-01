import 'package:freezed_annotation/freezed_annotation.dart';

part 'coin.freezed.dart';
part 'coin.g.dart';

@freezed
sealed class Coin with _$Coin {
  const factory Coin(
      {String? name,
      String? symbol,
      String? address,
      double? balance,
      String? networkSymbol,
      String? decimals,
      String? iconPath,
      String? coinGeckoId}) = _Coin;

  factory Coin.fromJson(Map<String, Object?> json) => _$CoinFromJson(json);
}
