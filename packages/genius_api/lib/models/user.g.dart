// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_User _$UserFromJson(Map<String, dynamic> json) => _User(
  profilePictureUrl: json['profilePictureUrl'] as String,
  nickname: json['nickname'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  dateOfBirth: json['dateOfBirth'] as String,
  wallets: (json['wallets'] as List<dynamic>)
      .map((e) => Wallet.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$UserToJson(_User instance) => <String, dynamic>{
  'profilePictureUrl': instance.profilePictureUrl,
  'nickname': instance.nickname,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'dateOfBirth': instance.dateOfBirth,
  'wallets': instance.wallets,
};
