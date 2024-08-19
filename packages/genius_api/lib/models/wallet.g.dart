// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WalletImpl _$$WalletImplFromJson(Map<String, dynamic> json) => _$WalletImpl(
      coinType: json['coinType'] as int,
      walletName: json['walletName'] as String,
      currencySymbol: json['currencySymbol'] as String,
      walletType: $enumDecode(_$WalletTypeEnumMap, json['walletType']),
      balance: json['balance'] as int,
      address: json['address'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$WalletImplToJson(_$WalletImpl instance) =>
    <String, dynamic>{
      'coinType': instance.coinType,
      'walletName': instance.walletName,
      'currencySymbol': instance.currencySymbol,
      'walletType': _$WalletTypeEnumMap[instance.walletType]!,
      'balance': instance.balance,
      'address': instance.address,
      'transactions': instance.transactions,
    };

const _$WalletTypeEnumMap = {
  WalletType.tracking: 'tracking',
  WalletType.privateKey: 'privateKey',
  WalletType.mnemonic: 'mnemonic',
  WalletType.keystore: 'keystore',
};
