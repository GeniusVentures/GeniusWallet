// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TransferRecipientsImpl _$$TransferRecipientsImplFromJson(
        Map<String, dynamic> json) =>
    _$TransferRecipientsImpl(
      toAddr: json['toAddr'] as String,
      amount: json['amount'] as String,
    );

Map<String, dynamic> _$$TransferRecipientsImplToJson(
        _$TransferRecipientsImpl instance) =>
    <String, dynamic>{
      'toAddr': instance.toAddr,
      'amount': instance.amount,
    };

_$TransactionImpl _$$TransactionImplFromJson(Map<String, dynamic> json) =>
    _$TransactionImpl(
      hash: json['hash'] as String,
      fromAddress: json['fromAddress'] as String,
      recipients: (json['recipients'] as List<dynamic>)
          .map((e) => TransferRecipients.fromJson(e as Map<String, dynamic>))
          .toList(),
      timeStamp: DateTime.parse(json['timeStamp'] as String),
      transactionDirection: $enumDecode(
          _$TransactionDirectionEnumMap, json['transactionDirection']),
      fees: json['fees'] as String,
      coinSymbol: json['coinSymbol'] as String,
      transactionStatus:
          $enumDecode(_$TransactionStatusEnumMap, json['transactionStatus']),
      isSGNUS: json['isSGNUS'] as bool?,
      type: $enumDecodeNullable(_$TransactionTypeEnumMap, json['type']),
    );

Map<String, dynamic> _$$TransactionImplToJson(_$TransactionImpl instance) =>
    <String, dynamic>{
      'hash': instance.hash,
      'fromAddress': instance.fromAddress,
      'recipients': instance.recipients,
      'timeStamp': instance.timeStamp.toIso8601String(),
      'transactionDirection':
          _$TransactionDirectionEnumMap[instance.transactionDirection]!,
      'fees': instance.fees,
      'coinSymbol': instance.coinSymbol,
      'transactionStatus':
          _$TransactionStatusEnumMap[instance.transactionStatus]!,
      'isSGNUS': instance.isSGNUS,
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
  TransactionType.escrowRelease: 'escrowRelease',
};
