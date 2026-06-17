// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sgnus_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SGNUSConnection _$SGNUSConnectionFromJson(Map<String, dynamic> json) =>
    _SGNUSConnection(
      sgnusAddress: json['sgnusAddress'] as String,
      walletAddress: json['walletAddress'] as String,
      isConnected: json['isConnected'] as bool,
    );

Map<String, dynamic> _$SGNUSConnectionToJson(_SGNUSConnection instance) =>
    <String, dynamic>{
      'sgnusAddress': instance.sgnusAddress,
      'walletAddress': instance.walletAddress,
      'isConnected': instance.isConnected,
    };
