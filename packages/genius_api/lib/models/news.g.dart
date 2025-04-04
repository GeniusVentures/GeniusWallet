// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NewsImpl _$$NewsImplFromJson(Map<String, dynamic> json) => _$NewsImpl(
      headline: json['headline'] as String?,
      body: json['body'] as String?,
      date: json['date'] as String?,
      imgSrc: json['imgSrc'] as String?,
    );

Map<String, dynamic> _$$NewsImplToJson(_$NewsImpl instance) =>
    <String, dynamic>{
      'headline': instance.headline,
      'body': instance.body,
      'date': instance.date,
      'imgSrc': instance.imgSrc,
    };
