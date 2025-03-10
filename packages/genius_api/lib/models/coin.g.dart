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
      networkSymbol: json['networkSymbol'] as String?,
      decimals: json['decimals'] as String?,
      iconPath: json['iconPath'] as String?,
      coinGeckoId: json['coinGeckoId'] as String?,
    );

Map<String, dynamic> _$$CoinImplToJson(_$CoinImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'symbol': instance.symbol,
      'address': instance.address,
      'balance': instance.balance,
      'networkSymbol': instance.networkSymbol,
      'decimals': instance.decimals,
      'iconPath': instance.iconPath,
      'coinGeckoId': instance.coinGeckoId,
    };
