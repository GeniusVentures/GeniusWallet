// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'news.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_News _$NewsFromJson(Map<String, dynamic> json) => _News(
  headline: json['headline'] as String?,
  body: json['body'] as String?,
  date: json['date'] as String?,
  imgSrc: json['imgSrc'] as String?,
);

Map<String, dynamic> _$NewsToJson(_News instance) => <String, dynamic>{
  'headline': instance.headline,
  'body': instance.body,
  'date': instance.date,
  'imgSrc': instance.imgSrc,
};
