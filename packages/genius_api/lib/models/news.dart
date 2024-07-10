import 'package:freezed_annotation/freezed_annotation.dart';

@freezed
class News {
  final String headline = 'headline placeholder';
  final String body = 'body placeholdeer';
  final String date = '1/01/2001';

  News({headline, body, date});
}
