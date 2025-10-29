// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Currency _$CurrencyFromJson(Map<String, dynamic> json) => _Currency(
  symbol: json['symbol'] as String,
  name: json['name'] as String,
  price: json['price'] as String?,
  priceCurrency: json['priceCurrency'] as String?,
  logoUrl: json['logoUrl'] as String?,
  priceDate: json['priceDate'] as String?,
);

Map<String, dynamic> _$CurrencyToJson(_Currency instance) => <String, dynamic>{
  'symbol': instance.symbol,
  'name': instance.name,
  'price': instance.price,
  'priceCurrency': instance.priceCurrency,
  'logoUrl': instance.logoUrl,
  'priceDate': instance.priceDate,
};
