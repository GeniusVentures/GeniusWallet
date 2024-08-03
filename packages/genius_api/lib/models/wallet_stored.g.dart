// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_stored.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletStoredImpl _$$WalletStoredImplFromJson(Map<String, dynamic> json) =>
    _$WalletStoredImpl(
      walletName: json['walletName'] as String,
      currencySymbol: json['currencySymbol'] as String,
      currencyName: json['currencyName'] as String,
      mnemonic: json['mnemonic'] as String,
      address: json['address'] as String,
    );

Map<String, dynamic> _$$WalletStoredImplToJson(_$WalletStoredImpl instance) =>
    <String, dynamic>{
      'walletName': instance.walletName,
      'currencySymbol': instance.currencySymbol,
      'currencyName': instance.currencyName,
      'mnemonic': instance.mnemonic,
      'address': instance.address,
    };
