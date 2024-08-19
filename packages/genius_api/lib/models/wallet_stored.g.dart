// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet_stored.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletStoredImpl _$$WalletStoredImplFromJson(Map<String, dynamic> json) =>
    _$WalletStoredImpl(
      walletName: json['walletName'] as String,
      currencySymbol: json['currencySymbol'] as String,
      mnemonic: json['mnemonic'] as String? ?? "",
      privateKey: json['privateKey'] as String? ?? "",
      walletType: $enumDecode(_$WalletTypeEnumMap, json['walletType']),
      address: json['address'] as String,
      coinType: json['coinType'] as int,
    );

Map<String, dynamic> _$$WalletStoredImplToJson(_$WalletStoredImpl instance) =>
    <String, dynamic>{
      'walletName': instance.walletName,
      'currencySymbol': instance.currencySymbol,
      'mnemonic': instance.mnemonic,
      'privateKey': instance.privateKey,
      'walletType': _$WalletTypeEnumMap[instance.walletType]!,
      'address': instance.address,
      'coinType': instance.coinType,
    };

const _$WalletTypeEnumMap = {
  WalletType.tracking: 'tracking',
  WalletType.privateKey: 'privateKey',
  WalletType.mnemonic: 'mnemonic',
  WalletType.keystore: 'keystore',
};
