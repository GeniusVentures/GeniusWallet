// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'coin.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Coin _$CoinFromJson(Map<String, dynamic> json) => _Coin(
  name: json['name'] as String?,
  symbol: json['symbol'] as String?,
  address: json['address'] as String?,
  balance: (json['balance'] as num?)?.toDouble(),
  networkSymbol: json['networkSymbol'] as String?,
  decimals: json['decimals'] as String?,
  iconPath: json['iconPath'] as String?,
  coinGeckoId: json['coinGeckoId'] as String?,
);

Map<String, dynamic> _$CoinToJson(_Coin instance) => <String, dynamic>{
  'name': instance.name,
  'symbol': instance.symbol,
  'address': instance.address,
  'balance': instance.balance,
  'networkSymbol': instance.networkSymbol,
  'decimals': instance.decimals,
  'iconPath': instance.iconPath,
  'coinGeckoId': instance.coinGeckoId,
};
