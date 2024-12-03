// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CoinImpl _$$CoinImplFromJson(Map<String, dynamic> json) => _$CoinImpl(
      name: json['name'] as String?,
      symbol: json['symbol'] as String?,
      address: json['address'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      networkSymbol:
          $enumDecodeNullable(_$NetworkSymbolEnumMap, json['networkSymbol']),
      iconPath: json['iconPath'] as String?,
    );

Map<String, dynamic> _$$CoinImplToJson(_$CoinImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'address': instance.address,
      'balance': instance.balance,
      'networkSymbol': _$NetworkSymbolEnumMap[instance.networkSymbol],
      'iconPath': instance.iconPath,
    };

const _$NetworkSymbolEnumMap = {
  NetworkSymbol.eth: 'eth',
  NetworkSymbol.matic: 'matic',
  NetworkSymbol.eth_test_net: 'eth_test_net',
  NetworkSymbol.matic_test_net: 'matic_test_net',
};
