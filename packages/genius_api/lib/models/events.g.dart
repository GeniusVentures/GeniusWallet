// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$EventsImpl _$$EventsImplFromJson(Map<String, dynamic> json) => _$EventsImpl(
      location: json['location'] as String?,
      body: json['body'] as String?,
      weekDay: json['weekDay'] as String?,
      date: json['date'] as String?,
    );

Map<String, dynamic> _$$EventsImplToJson(_$EventsImpl instance) =>
    <String, dynamic>{
      'location': instance.location,
      'body': instance.body,
      'weekDay': instance.weekDay,
      'date': instance.date,
    };
