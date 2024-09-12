// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      hash: json['hash'] as String,
      fromAddress: json['fromAddress'] as String,
      toAddress: json['toAddress'] as String,
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      transactionDirection: $enumDecode(
          _$TransactionDirectionEnumMap, json['transactionDirection']),
      amount: json['amount'] as String,
      fees: json['fees'] as String,
      coinSymbol: json['coinSymbol'] as String,
      transactionStatus:
          $enumDecode(_$TransactionStatusEnumMap, json['transactionStatus']),
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'fromAddress': instance.fromAddress,
      'toAddress': instance.toAddress,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'transactionDirection':
          _$TransactionDirectionEnumMap[instance.transactionDirection]!,
      'amount': instance.amount,
      'fees': instance.fees,
      'coinSymbol': instance.coinSymbol,
      'transactionStatus':
          _$TransactionStatusEnumMap[instance.transactionStatus]!,
      'type': _$TransactionTypeEnumMap[instance.type],
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

const _$TransactionTypeEnumMap = {
  TransactionType.transfer: 'transfer',
  TransactionType.mint: 'mint',
  TransactionType.escrow: 'escrow',
  TransactionType.process: 'process',
};
