// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AccountImpl _$$AccountImplFromJson(Map<String, dynamic> json) =>
    _$AccountImpl(
      name: json['name'] as String?,
      balance: (json['balance'] as num?)?.toDouble(),
      lastBalanceRetrievalDate: json['lastBalanceRetrievalDate'] == null
          ? null
          : DateTime.parse(json['lastBalanceRetrievalDate'] as String),
    );

Map<String, dynamic> _$$AccountImplToJson(_$AccountImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'balance': instance.balance,
      'lastBalanceRetrievalDate':
          instance.lastBalanceRetrievalDate?.toIso8601String(),
    };
