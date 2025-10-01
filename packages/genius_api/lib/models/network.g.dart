// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Network _$NetworkFromJson(Map<String, dynamic> json) => _Network(
  name: json['name'] as String?,
  symbol: json['symbol'] as String?,
  chainId: (json['chainId'] as num?)?.toInt(),
  coinGeckoId: json['coinGeckoId'] as String?,
  rpcUrl: json['rpcUrl'] as String?,
  iconPath: json['iconPath'] as String?,
  tokensPath: json['tokensPath'] as String?,
);

Map<String, dynamic> _$NetworkToJson(_Network instance) => <String, dynamic>{
  'name': instance.name,
  'symbol': instance.symbol,
  'chainId': instance.chainId,
  'coinGeckoId': instance.coinGeckoId,
  'rpcUrl': instance.rpcUrl,
  'iconPath': instance.iconPath,
  'tokensPath': instance.tokensPath,
};
