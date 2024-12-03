// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NetworkImpl _$$NetworkImplFromJson(Map<String, dynamic> json) =>
    _$NetworkImpl(
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      chainId: (json['chainId'] as num?)?.toInt(),
      rpcUrl: json['rpcUrl'] as String?,
      iconPath: json['iconPath'] as String?,
      tokensPath: json['tokensPath'] as String?,
    );

Map<String, dynamic> _$$NetworkImplToJson(_$NetworkImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'chainId': instance.chainId,
      'rpcUrl': instance.rpcUrl,
      'iconPath': instance.iconPath,
      'tokensPath': instance.tokensPath,
    };
