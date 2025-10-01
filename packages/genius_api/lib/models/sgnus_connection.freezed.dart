// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sgnus_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SGNUSConnection {

 String get sgnusAddress; String get walletAddress; GeniusTransactionManagerState? get connection;
/// Create a copy of SGNUSConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SGNUSConnectionCopyWith<SGNUSConnection> get copyWith => _$SGNUSConnectionCopyWithImpl<SGNUSConnection>(this as SGNUSConnection, _$identity);

  /// Serializes this SGNUSConnection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SGNUSConnection&&(identical(other.sgnusAddress, sgnusAddress) || other.sgnusAddress == sgnusAddress)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.connection, connection) || other.connection == connection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sgnusAddress,walletAddress,connection);

@override
String toString() {
  return 'SGNUSConnection(sgnusAddress: $sgnusAddress, walletAddress: $walletAddress, connection: $connection)';
}


}

/// @nodoc
abstract mixin class $SGNUSConnectionCopyWith<$Res>  {
  factory $SGNUSConnectionCopyWith(SGNUSConnection value, $Res Function(SGNUSConnection) _then) = _$SGNUSConnectionCopyWithImpl;
@useResult
$Res call({
 String sgnusAddress, String walletAddress, GeniusTransactionManagerState? connection
});




}
/// @nodoc
class _$SGNUSConnectionCopyWithImpl<$Res>
    implements $SGNUSConnectionCopyWith<$Res> {
  _$SGNUSConnectionCopyWithImpl(this._self, this._then);

  final SGNUSConnection _self;
  final $Res Function(SGNUSConnection) _then;

/// Create a copy of SGNUSConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? sgnusAddress = null,Object? walletAddress = null,Object? connection = freezed,}) {
  return _then(_self.copyWith(
sgnusAddress: null == sgnusAddress ? _self.sgnusAddress : sgnusAddress // ignore: cast_nullable_to_non_nullable
as String,walletAddress: null == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as GeniusTransactionManagerState?,
  ));
}

}


/// Adds pattern-matching-related methods to [SGNUSConnection].
extension SGNUSConnectionPatterns on SGNUSConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SGNUSConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SGNUSConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SGNUSConnection value)  $default,){
final _that = this;
switch (_that) {
case _SGNUSConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SGNUSConnection value)?  $default,){
final _that = this;
switch (_that) {
case _SGNUSConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String sgnusAddress,  String walletAddress,  GeniusTransactionManagerState? connection)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SGNUSConnection() when $default != null:
return $default(_that.sgnusAddress,_that.walletAddress,_that.connection);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String sgnusAddress,  String walletAddress,  GeniusTransactionManagerState? connection)  $default,) {final _that = this;
switch (_that) {
case _SGNUSConnection():
return $default(_that.sgnusAddress,_that.walletAddress,_that.connection);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String sgnusAddress,  String walletAddress,  GeniusTransactionManagerState? connection)?  $default,) {final _that = this;
switch (_that) {
case _SGNUSConnection() when $default != null:
return $default(_that.sgnusAddress,_that.walletAddress,_that.connection);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SGNUSConnection implements SGNUSConnection {
  const _SGNUSConnection({required this.sgnusAddress, required this.walletAddress, required this.connection});
  factory _SGNUSConnection.fromJson(Map<String, dynamic> json) => _$SGNUSConnectionFromJson(json);

@override final  String sgnusAddress;
@override final  String walletAddress;
@override final  GeniusTransactionManagerState? connection;

/// Create a copy of SGNUSConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SGNUSConnectionCopyWith<_SGNUSConnection> get copyWith => __$SGNUSConnectionCopyWithImpl<_SGNUSConnection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SGNUSConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SGNUSConnection&&(identical(other.sgnusAddress, sgnusAddress) || other.sgnusAddress == sgnusAddress)&&(identical(other.walletAddress, walletAddress) || other.walletAddress == walletAddress)&&(identical(other.connection, connection) || other.connection == connection));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,sgnusAddress,walletAddress,connection);

@override
String toString() {
  return 'SGNUSConnection(sgnusAddress: $sgnusAddress, walletAddress: $walletAddress, connection: $connection)';
}


}

/// @nodoc
abstract mixin class _$SGNUSConnectionCopyWith<$Res> implements $SGNUSConnectionCopyWith<$Res> {
  factory _$SGNUSConnectionCopyWith(_SGNUSConnection value, $Res Function(_SGNUSConnection) _then) = __$SGNUSConnectionCopyWithImpl;
@override @useResult
$Res call({
 String sgnusAddress, String walletAddress, GeniusTransactionManagerState? connection
});




}
/// @nodoc
class __$SGNUSConnectionCopyWithImpl<$Res>
    implements _$SGNUSConnectionCopyWith<$Res> {
  __$SGNUSConnectionCopyWithImpl(this._self, this._then);

  final _SGNUSConnection _self;
  final $Res Function(_SGNUSConnection) _then;

/// Create a copy of SGNUSConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? sgnusAddress = null,Object? walletAddress = null,Object? connection = freezed,}) {
  return _then(_SGNUSConnection(
sgnusAddress: null == sgnusAddress ? _self.sgnusAddress : sgnusAddress // ignore: cast_nullable_to_non_nullable
as String,walletAddress: null == walletAddress ? _self.walletAddress : walletAddress // ignore: cast_nullable_to_non_nullable
as String,connection: freezed == connection ? _self.connection : connection // ignore: cast_nullable_to_non_nullable
as GeniusTransactionManagerState?,
  ));
}


}

// dart format on
