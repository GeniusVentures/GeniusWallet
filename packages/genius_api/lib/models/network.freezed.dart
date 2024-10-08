// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Network _$NetworkFromJson(Map<String, dynamic> json) {
  return _Network.fromJson(json);
}

/// @nodoc
mixin _$Network {
  String? get name => throw _privateConstructorUsedError;
  NetworkSymbol? get symbol => throw _privateConstructorUsedError;
  int? get chainId => throw _privateConstructorUsedError;
  String? get rpcUrl => throw _privateConstructorUsedError;
  String? get iconPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $NetworkCopyWith<Network> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkCopyWith<$Res> {
  factory $NetworkCopyWith(Network value, $Res Function(Network) then) =
      _$NetworkCopyWithImpl<$Res, Network>;
  @useResult
  $Res call(
      {String? name,
      NetworkSymbol? symbol,
      int? chainId,
      String? rpcUrl,
      String? iconPath});
}

/// @nodoc
class _$NetworkCopyWithImpl<$Res, $Val extends Network>
    implements $NetworkCopyWith<$Res> {
  _$NetworkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? chainId = freezed,
    Object? rpcUrl = freezed,
    Object? iconPath = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as NetworkSymbol?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      rpcUrl: freezed == rpcUrl
          ? _value.rpcUrl
          : rpcUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NetworkImplCopyWith<$Res> implements $NetworkCopyWith<$Res> {
  factory _$$NetworkImplCopyWith(
          _$NetworkImpl value, $Res Function(_$NetworkImpl) then) =
      __$$NetworkImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      NetworkSymbol? symbol,
      int? chainId,
      String? rpcUrl,
      String? iconPath});
}

/// @nodoc
class __$$NetworkImplCopyWithImpl<$Res>
    extends _$NetworkCopyWithImpl<$Res, _$NetworkImpl>
    implements _$$NetworkImplCopyWith<$Res> {
  __$$NetworkImplCopyWithImpl(
      _$NetworkImpl _value, $Res Function(_$NetworkImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? chainId = freezed,
    Object? rpcUrl = freezed,
    Object? iconPath = freezed,
  }) {
    return _then(_$NetworkImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as NetworkSymbol?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      rpcUrl: freezed == rpcUrl
          ? _value.rpcUrl
          : rpcUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkImpl implements _Network {
  const _$NetworkImpl(
      {this.name, this.symbol, this.chainId, this.rpcUrl, this.iconPath});

  factory _$NetworkImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkImplFromJson(json);

  @override
  final String? name;
  @override
  final NetworkSymbol? symbol;
  @override
  final int? chainId;
  @override
  final String? rpcUrl;
  @override
  final String? iconPath;

  @override
  String toString() {
    return 'Network(name: $name, symbol: $symbol, chainId: $chainId, rpcUrl: $rpcUrl, iconPath: $iconPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.chainId, chainId) || other.chainId == chainId) &&
            (identical(other.rpcUrl, rpcUrl) || other.rpcUrl == rpcUrl) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, symbol, chainId, rpcUrl, iconPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NetworkImplCopyWith<_$NetworkImpl> get copyWith =>
      __$$NetworkImplCopyWithImpl<_$NetworkImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$NetworkImplToJson(
      this,
    );
  }
}

abstract class _Network implements Network {
  const factory _Network(
      {final String? name,
      final NetworkSymbol? symbol,
      final int? chainId,
      final String? rpcUrl,
      final String? iconPath}) = _$NetworkImpl;

  factory _Network.fromJson(Map<String, dynamic> json) = _$NetworkImpl.fromJson;

  @override
  String? get name;
  @override
  NetworkSymbol? get symbol;
  @override
  int? get chainId;
  @override
  String? get rpcUrl;
  @override
  String? get iconPath;
  @override
  @JsonKey(ignore: true)
  _$$NetworkImplCopyWith<_$NetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
