// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Token _$TokenFromJson(Map<String, dynamic> json) => _Token(
  address: json['address'] as String?,
  iconPath: json['iconPath'] as String?,
  name: json['name'] as String?,
  coinGeckoId: json['coinGeckoId'] as String?,
);

Map<String, dynamic> _$TokenToJson(_Token instance) => <String, dynamic>{
  'address': instance.address,
  'iconPath': instance.iconPath,
  'name': instance.name,
  'coinGeckoId': instance.coinGeckoId,
};
