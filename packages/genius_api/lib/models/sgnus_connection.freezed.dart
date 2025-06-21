// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sgnus_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

SGNUSConnection _$SGNUSConnectionFromJson(Map<String, dynamic> json) {
  return _SGNUSConnection.fromJson(json);
}

/// @nodoc
mixin _$SGNUSConnection {
  String get sgnusAddress => throw _privateConstructorUsedError;
  String get walletAddress => throw _privateConstructorUsedError;
  bool get isConnected => throw _privateConstructorUsedError;

  /// Serializes this SGNUSConnection to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SGNUSConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SGNUSConnectionCopyWith<SGNUSConnection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SGNUSConnectionCopyWith<$Res> {
  factory $SGNUSConnectionCopyWith(
          SGNUSConnection value, $Res Function(SGNUSConnection) then) =
      _$SGNUSConnectionCopyWithImpl<$Res, SGNUSConnection>;
  @useResult
  $Res call({String sgnusAddress, String walletAddress, bool isConnected});
}

/// @nodoc
class _$SGNUSConnectionCopyWithImpl<$Res, $Val extends SGNUSConnection>
    implements $SGNUSConnectionCopyWith<$Res> {
  _$SGNUSConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SGNUSConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sgnusAddress = null,
    Object? walletAddress = null,
    Object? isConnected = null,
  }) {
    return _then(_value.copyWith(
      sgnusAddress: null == sgnusAddress
          ? _value.sgnusAddress
          : sgnusAddress // ignore: cast_nullable_to_non_nullable
              as String,
      walletAddress: null == walletAddress
          ? _value.walletAddress
          : walletAddress // ignore: cast_nullable_to_non_nullable
              as String,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SGNUSConnectionImplCopyWith<$Res>
    implements $SGNUSConnectionCopyWith<$Res> {
  factory _$$SGNUSConnectionImplCopyWith(_$SGNUSConnectionImpl value,
          $Res Function(_$SGNUSConnectionImpl) then) =
      __$$SGNUSConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String sgnusAddress, String walletAddress, bool isConnected});
}

/// @nodoc
class __$$SGNUSConnectionImplCopyWithImpl<$Res>
    extends _$SGNUSConnectionCopyWithImpl<$Res, _$SGNUSConnectionImpl>
    implements _$$SGNUSConnectionImplCopyWith<$Res> {
  __$$SGNUSConnectionImplCopyWithImpl(
      _$SGNUSConnectionImpl _value, $Res Function(_$SGNUSConnectionImpl) _then)
      : super(_value, _then);

  /// Create a copy of SGNUSConnection
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? sgnusAddress = null,
    Object? walletAddress = null,
    Object? isConnected = null,
  }) {
    return _then(_$SGNUSConnectionImpl(
      sgnusAddress: null == sgnusAddress
          ? _value.sgnusAddress
          : sgnusAddress // ignore: cast_nullable_to_non_nullable
              as String,
      walletAddress: null == walletAddress
          ? _value.walletAddress
          : walletAddress // ignore: cast_nullable_to_non_nullable
              as String,
      isConnected: null == isConnected
          ? _value.isConnected
          : isConnected // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$SGNUSConnectionImpl implements _SGNUSConnection {
  const _$SGNUSConnectionImpl(
      {required this.sgnusAddress,
      required this.walletAddress,
      required this.isConnected});

  factory _$SGNUSConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SGNUSConnectionImplFromJson(json);

  @override
  final String sgnusAddress;
  @override
  final String walletAddress;
  @override
  final bool isConnected;

  @override
  String toString() {
    return 'SGNUSConnection(sgnusAddress: $sgnusAddress, walletAddress: $walletAddress, isConnected: $isConnected)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SGNUSConnectionImpl &&
            (identical(other.sgnusAddress, sgnusAddress) ||
                other.sgnusAddress == sgnusAddress) &&
            (identical(other.walletAddress, walletAddress) ||
                other.walletAddress == walletAddress) &&
            (identical(other.isConnected, isConnected) ||
                other.isConnected == isConnected));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, sgnusAddress, walletAddress, isConnected);

  /// Create a copy of SGNUSConnection
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SGNUSConnectionImplCopyWith<_$SGNUSConnectionImpl> get copyWith =>
      __$$SGNUSConnectionImplCopyWithImpl<_$SGNUSConnectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SGNUSConnectionImplToJson(
      this,
    );
  }
}

abstract class _SGNUSConnection implements SGNUSConnection {
  const factory _SGNUSConnection(
      {required final String sgnusAddress,
      required final String walletAddress,
      required final bool isConnected}) = _$SGNUSConnectionImpl;

  factory _SGNUSConnection.fromJson(Map<String, dynamic> json) =
      _$SGNUSConnectionImpl.fromJson;

  @override
  String get sgnusAddress;
  @override
  String get walletAddress;
  @override
  bool get isConnected;

  /// Create a copy of SGNUSConnection
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SGNUSConnectionImplCopyWith<_$SGNUSConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
