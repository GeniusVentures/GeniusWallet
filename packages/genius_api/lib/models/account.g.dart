// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Account _$AccountFromJson(Map<String, dynamic> json) => _Account(
  name: json['name'] as String?,
  balance: (json['balance'] as num?)?.toDouble(),
  lastBalanceRetrievalDate: json['lastBalanceRetrievalDate'] == null
      ? null
      : DateTime.parse(json['lastBalanceRetrievalDate'] as String),
);

Map<String, dynamic> _$AccountToJson(_Account instance) => <String, dynamic>{
  'name': instance.name,
  'balance': instance.balance,
  'lastBalanceRetrievalDate': instance.lastBalanceRetrievalDate
      ?.toIso8601String(),
};
