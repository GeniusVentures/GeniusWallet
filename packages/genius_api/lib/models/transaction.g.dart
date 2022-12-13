// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Transaction _$$_TransactionFromJson(Map<String, dynamic> json) =>
    _$_Transaction(
      hash: json['hash'] as String,
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      timeStamp: json['timeStamp'] as String,
      transactionDirection: $enumDecode(
          _$TransactionDirectionEnumMap, json['transactionDirection']),
      amount: json['amount'] as String,
      fees: json['fees'] as String,
      coinSymbol: json['coinSymbol'] as String,
      transactionStatus:
          $enumDecode(_$TransactionStatusEnumMap, json['transactionStatus']),
    );

Map<String, dynamic> _$$_TransactionToJson(_$_Transaction instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'timeStamp': instance.timeStamp,
      'transactionDirection':
          _$TransactionDirectionEnumMap[instance.transactionDirection]!,
      'amount': instance.amount,
      'fees': instance.fees,
      'coinSymbol': instance.coinSymbol,
      'transactionStatus':
          _$TransactionStatusEnumMap[instance.transactionStatus]!,
    };

const _$TransactionDirectionEnumMap = {
  TransactionDirection.sent: 'sent',
  TransactionDirection.received: 'received',
};

const _$TransactionStatusEnumMap = {
  TransactionStatus.pending: 'pending',
  TransactionStatus.cancelled: 'cancelled',
  TransactionStatus.completed: 'completed',
};
