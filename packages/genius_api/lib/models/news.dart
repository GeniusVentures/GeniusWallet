import 'package:freezed_annotation/freezed_annotation.dart';

part 'news.freezed.dart';
part 'news.g.dart';

@freezed
class News with _$News {
  const factory News(
      {String? headline, String? body, String? date, String? imgSrc}) = _News;

  factory News.fromJson(Map<String, Object?> json) => _$NewsFromJson(json);
}
