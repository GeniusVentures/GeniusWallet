import 'package:freezed_annotation/freezed_annotation.dart';

part 'events.freezed.dart';
part 'events.g.dart';

@freezed
class Events with _$Events {
  const factory Events(
      {String? location,
      String? body,
      String? weekDay,
      String? date}) = _Events;

  factory Events.fromJson(Map<String, Object?> json) => _$EventsFromJson(json);
}
