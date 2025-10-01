// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sgnus_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SGNUSConnection _$SGNUSConnectionFromJson(Map<String, dynamic> json) =>
    _SGNUSConnection(
      sgnusAddress: json['sgnusAddress'] as String,
      walletAddress: json['walletAddress'] as String,
      connection: $enumDecodeNullable(
        _$GeniusTransactionManagerStateEnumMap,
        json['connection'],
      ),
    );

Map<String, dynamic> _$SGNUSConnectionToJson(_SGNUSConnection instance) =>
    <String, dynamic>{
      'sgnusAddress': instance.sgnusAddress,
      'walletAddress': instance.walletAddress,
      'connection': _$GeniusTransactionManagerStateEnumMap[instance.connection],
    };

const _$GeniusTransactionManagerStateEnumMap = {
  GeniusTransactionManagerState.GENIUS_TM_STATE_CREATING:
      'GENIUS_TM_STATE_CREATING',
  GeniusTransactionManagerState.GENIUS_TM_STATE_INITIALIZING:
      'GENIUS_TM_STATE_INITIALIZING',
  GeniusTransactionManagerState.GENIUS_TM_STATE_SYNCHING:
      'GENIUS_TM_STATE_SYNCHING',
  GeniusTransactionManagerState.GENIUS_TM_STATE_READY: 'GENIUS_TM_STATE_READY',
};
