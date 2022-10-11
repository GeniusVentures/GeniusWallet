// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wallet.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Wallet _$$_WalletFromJson(Map<String, dynamic> json) => _$_Wallet(
      walletName: json['walletName'] as String,
      currencySymbol: json['currencySymbol'] as String,
      currencyName: json['currencyName'] as String,
      balance: json['balance'] as int,
      address: json['address'] as String,
      transactions: (json['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$$_WalletToJson(_$_Wallet instance) => <String, dynamic>{
      'walletName': instance.walletName,
      'currencySymbol': instance.currencySymbol,
      'currencyName': instance.currencyName,
      'balance': instance.balance,
      'address': instance.address,
      'transactions': instance.transactions,
    };
