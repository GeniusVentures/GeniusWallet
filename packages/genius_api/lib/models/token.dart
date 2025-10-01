import 'package:freezed_annotation/freezed_annotation.dart';

part 'token.freezed.dart';
part 'token.g.dart';

@freezed
sealed class Token with _$Token {
  const factory Token(
      {String? address,
      String? iconPath,
      String? name,
      String? coinGeckoId}) = _Token;

  factory Token.fromJson(Map<String, Object?> json) => _$TokenFromJson(json);
}
