// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sgnus_connection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SGNUSConnectionImpl _$$SGNUSConnectionImplFromJson(
        Map<String, dynamic> json) =>
    _$SGNUSConnectionImpl(
      sgnusAddress: json['sgnusAddress'] as String,
      walletAddress: json['walletAddress'] as String,
      isConnected: json['isConnected'] as bool,
    );

Map<String, dynamic> _$$SGNUSConnectionImplToJson(
        _$SGNUSConnectionImpl instance) =>
    <String, dynamic>{
      'sgnusAddress': instance.sgnusAddress,
      'walletAddress': instance.walletAddress,
      'isConnected': instance.isConnected,
    };
