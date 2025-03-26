// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

News _$NewsFromJson(Map<String, dynamic> json) {
  return _News.fromJson(json);
}

/// @nodoc
mixin _$News {
  String? get headline => throw _privateConstructorUsedError;
  String? get body => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String? get imgSrc => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NewsCopyWith<News> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NewsCopyWith<$Res> {
  factory $NewsCopyWith(News value, $Res Function(News) then) =
      _$NewsCopyWithImpl<$Res, News>;
  @useResult
  $Res call({String? headline, String? body, String? date, String? imgSrc});
}

/// @nodoc
class _$NewsCopyWithImpl<$Res, $Val extends News>
    implements $NewsCopyWith<$Res> {
  _$NewsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = freezed,
    Object? body = freezed,
    Object? date = freezed,
    Object? imgSrc = freezed,
  }) {
    return _then(_value.copyWith(
      headline: freezed == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      imgSrc: freezed == imgSrc
          ? _value.imgSrc
          : imgSrc // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NewsImplCopyWith<$Res> implements $NewsCopyWith<$Res> {
  factory _$$NewsImplCopyWith(
          _$NewsImpl value, $Res Function(_$NewsImpl) then) =
      __$$NewsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? headline, String? body, String? date, String? imgSrc});
}

/// @nodoc
class __$$NewsImplCopyWithImpl<$Res>
    extends _$NewsCopyWithImpl<$Res, _$NewsImpl>
    implements _$$NewsImplCopyWith<$Res> {
  __$$NewsImplCopyWithImpl(_$NewsImpl _value, $Res Function(_$NewsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? headline = freezed,
    Object? body = freezed,
    Object? date = freezed,
    Object? imgSrc = freezed,
  }) {
    return _then(_$NewsImpl(
      headline: freezed == headline
          ? _value.headline
          : headline // ignore: cast_nullable_to_non_nullable
              as String?,
      body: freezed == body
          ? _value.body
          : body // ignore: cast_nullable_to_non_nullable
              as String?,
      date: freezed == date
          ? _value.date
          : date // ignore: cast_nullable_to_non_nullable
              as String?,
      imgSrc: freezed == imgSrc
          ? _value.imgSrc
          : imgSrc // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NewsImpl implements _News {
  const _$NewsImpl({this.headline, this.body, this.date, this.imgSrc});

  factory _$NewsImpl.fromJson(Map<String, dynamic> json) =>
      _$$NewsImplFromJson(json);

  @override
  final String? headline;
  @override
  final String? body;
  @override
  final String? date;
  @override
  final String? imgSrc;

  @override
  String toString() {
    return 'News(headline: $headline, body: $body, date: $date, imgSrc: $imgSrc)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NewsImpl &&
            (identical(other.headline, headline) ||
                other.headline == headline) &&
            (identical(other.body, body) || other.body == body) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.imgSrc, imgSrc) || other.imgSrc == imgSrc));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, headline, body, date, imgSrc);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NewsImplCopyWith<_$NewsImpl> get copyWith =>
      __$$NewsImplCopyWithImpl<_$NewsImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NewsImplToJson(
      this,
    );
  }
}

abstract class _News implements News {
  const factory _News(
      {final String? headline,
      final String? body,
      final String? date,
      final String? imgSrc}) = _$NewsImpl;

  factory _News.fromJson(Map<String, dynamic> json) = _$NewsImpl.fromJson;

  @override
  String? get headline;
  @override
  String? get body;
  @override
  String? get date;
  @override
  String? get imgSrc;
  @override
  @JsonKey(ignore: true)
  _$$NewsImplCopyWith<_$NewsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
