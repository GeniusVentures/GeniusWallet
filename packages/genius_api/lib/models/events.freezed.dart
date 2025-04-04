// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'events.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Events _$EventsFromJson(Map<String, dynamic> json) {
  return _Events.fromJson(json);
}

/// @nodoc
mixin _$Events {
  String? get location => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get weekDay => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $EventsCopyWith<Events> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventsCopyWith<$Res> {
  factory $EventsCopyWith(Events value, $Res Function(Events) then) =
      _$EventsCopyWithImpl<$Res, Events>;
  @useResult
  $Res call({String? location, String? body, String? weekDay, String? date});
}

/// @nodoc
class _$EventsCopyWithImpl<$Res, $Val extends Events>
    implements $EventsCopyWith<$Res> {
  _$EventsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = freezed,
    Object? body = freezed,
    Object? weekDay = freezed,
    Object? date = freezed,
  }) {
    return _then(_value.copyWith(
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      weekDay: freezed == weekDay
          ? _value.weekDay
          : weekDay // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EventsImplCopyWith<$Res> implements $EventsCopyWith<$Res> {
  factory _$$EventsImplCopyWith(
          _$EventsImpl value, $Res Function(_$EventsImpl) then) =
      __$$EventsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? location, String? body, String? weekDay, String? date});
}

/// @nodoc
class __$$EventsImplCopyWithImpl<$Res>
    extends _$EventsCopyWithImpl<$Res, _$EventsImpl>
    implements _$$EventsImplCopyWith<$Res> {
  __$$EventsImplCopyWithImpl(
      _$EventsImpl _value, $Res Function(_$EventsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? location = freezed,
    Object? body = freezed,
    Object? weekDay = freezed,
    Object? date = freezed,
  }) {
    return _then(_$EventsImpl(
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      weekDay: freezed == weekDay
          ? _value.weekDay
          : weekDay // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EventsImpl implements _Events {
  const _$EventsImpl({this.location, this.body, this.weekDay, this.date});

  factory _$EventsImpl.fromJson(Map<String, dynamic> json) =>
      _$$EventsImplFromJson(json);

  @override
  final String? location;
  @override
  final String? body;
  @override
  final String? weekDay;
  @override
  final String? date;

  @override
  String toString() {
    return 'Events(location: $location, body: $body, weekDay: $weekDay, date: $date)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EventsImpl &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.weekDay, weekDay) || other.weekDay == weekDay) &&
            (identical(other.date, date) || other.date == date));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, location, body, weekDay, date);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$EventsImplCopyWith<_$EventsImpl> get copyWith =>
      __$$EventsImplCopyWithImpl<_$EventsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EventsImplToJson(
      this,
    );
  }
}

abstract class _Events implements Events {
  const factory _Events(
      {final String? location,
      final String? body,
      final String? weekDay,
      final String? date}) = _$EventsImpl;

  factory _Events.fromJson(Map<String, dynamic> json) = _$EventsImpl.fromJson;

  @override
  String? get location;
  @override
  String? get body;
  @override
  String? get weekDay;
  @override
  String? get date;
  @override
  @JsonKey(ignore: true)
  _$$EventsImplCopyWith<_$EventsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
