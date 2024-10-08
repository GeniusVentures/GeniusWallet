// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'network.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NetworkImpl _$$NetworkImplFromJson(Map<String, dynamic> json) =>
    _$NetworkImpl(
      name: json['name'] as String?,
      symbol: $enumDecodeNullable(_$NetworkSymbolEnumMap, json['symbol']),
      chainId: json['chainId'] as int?,
      rpcUrl: json['rpcUrl'] as String?,
      iconPath: json['iconPath'] as String?,
    );

Map<String, dynamic> _$$NetworkImplToJson(_$NetworkImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': _$NetworkSymbolEnumMap[instance.symbol],
      'chainId': instance.chainId,
      'rpcUrl': instance.rpcUrl,
      'iconPath': instance.iconPath,
    };

const _$NetworkSymbolEnumMap = {
  NetworkSymbol.eth: 'eth',
  NetworkSymbol.matic: 'matic',
  NetworkSymbol.eth_test_net: 'eth_test_net',
  NetworkSymbol.matic_test_net: 'matic_test_net',
};
