// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'news.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$News {

 String? get headline; String? get body; String? get date; String? get imgSrc;
/// Create a copy of News
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NewsCopyWith<News> get copyWith => _$NewsCopyWithImpl<News>(this as News, _$identity);

  /// Serializes this News to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is News&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.body, body) || other.body == body)&&(identical(other.date, date) || other.date == date)&&(identical(other.imgSrc, imgSrc) || other.imgSrc == imgSrc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,body,date,imgSrc);

@override
String toString() {
  return 'News(headline: $headline, body: $body, date: $date, imgSrc: $imgSrc)';
}


}

/// @nodoc
abstract mixin class $NewsCopyWith<$Res>  {
  factory $NewsCopyWith(News value, $Res Function(News) _then) = _$NewsCopyWithImpl;
@useResult
$Res call({
 String? headline, String? body, String? date, String? imgSrc
});




}
/// @nodoc
class _$NewsCopyWithImpl<$Res>
    implements $NewsCopyWith<$Res> {
  _$NewsCopyWithImpl(this._self, this._then);

  final News _self;
  final $Res Function(News) _then;

/// Create a copy of News
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? headline = freezed,Object? body = freezed,Object? date = freezed,Object? imgSrc = freezed,}) {
  return _then(_self.copyWith(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,imgSrc: freezed == imgSrc ? _self.imgSrc : imgSrc // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [News].
extension NewsPatterns on News {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _News value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _News() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _News value)  $default,){
final _that = this;
switch (_that) {
case _News():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _News value)?  $default,){
final _that = this;
switch (_that) {
case _News() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? headline,  String? body,  String? date,  String? imgSrc)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _News() when $default != null:
return $default(_that.headline,_that.body,_that.date,_that.imgSrc);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? headline,  String? body,  String? date,  String? imgSrc)  $default,) {final _that = this;
switch (_that) {
case _News():
return $default(_that.headline,_that.body,_that.date,_that.imgSrc);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? headline,  String? body,  String? date,  String? imgSrc)?  $default,) {final _that = this;
switch (_that) {
case _News() when $default != null:
return $default(_that.headline,_that.body,_that.date,_that.imgSrc);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _News implements News {
  const _News({this.headline, this.body, this.date, this.imgSrc});
  factory _News.fromJson(Map<String, dynamic> json) => _$NewsFromJson(json);

@override final  String? headline;
@override final  String? body;
@override final  String? date;
@override final  String? imgSrc;

/// Create a copy of News
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NewsCopyWith<_News> get copyWith => __$NewsCopyWithImpl<_News>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NewsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _News&&(identical(other.headline, headline) || other.headline == headline)&&(identical(other.body, body) || other.body == body)&&(identical(other.date, date) || other.date == date)&&(identical(other.imgSrc, imgSrc) || other.imgSrc == imgSrc));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,headline,body,date,imgSrc);

@override
String toString() {
  return 'News(headline: $headline, body: $body, date: $date, imgSrc: $imgSrc)';
}


}

/// @nodoc
abstract mixin class _$NewsCopyWith<$Res> implements $NewsCopyWith<$Res> {
  factory _$NewsCopyWith(_News value, $Res Function(_News) _then) = __$NewsCopyWithImpl;
@override @useResult
$Res call({
 String? headline, String? body, String? date, String? imgSrc
});




}
/// @nodoc
class __$NewsCopyWithImpl<$Res>
    implements _$NewsCopyWith<$Res> {
  __$NewsCopyWithImpl(this._self, this._then);

  final _News _self;
  final $Res Function(_News) _then;

/// Create a copy of News
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? headline = freezed,Object? body = freezed,Object? date = freezed,Object? imgSrc = freezed,}) {
  return _then(_News(
headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,body: freezed == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String?,date: freezed == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String?,imgSrc: freezed == imgSrc ? _self.imgSrc : imgSrc // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
