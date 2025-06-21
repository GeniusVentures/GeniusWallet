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
  String? get symbol => throw _privateConstructorUsedError;
  int? get chainId => throw _privateConstructorUsedError;
  String? get coinGeckoId => throw _privateConstructorUsedError;
  String? get rpcUrl => throw _privateConstructorUsedError;
  String? get iconPath => throw _privateConstructorUsedError;
  String? get tokensPath => throw _privateConstructorUsedError;

  /// Serializes this Network to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Network
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $NetworkCopyWith<Network> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NetworkCopyWith<$Res> {
  factory $NetworkCopyWith(Network value, $Res Function(Network) then) =
      _$NetworkCopyWithImpl<$Res, Network>;
  @useResult
  $Res call(
      {String? name,
      String? symbol,
      int? chainId,
      String? coinGeckoId,
      String? rpcUrl,
      String? iconPath,
      String? tokensPath});
}

/// @nodoc
class _$NetworkCopyWithImpl<$Res, $Val extends Network>
    implements $NetworkCopyWith<$Res> {
  _$NetworkCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Network
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? chainId = freezed,
    Object? coinGeckoId = freezed,
    Object? rpcUrl = freezed,
    Object? iconPath = freezed,
    Object? tokensPath = freezed,
  }) {
    return _then(_value.copyWith(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      coinGeckoId: freezed == coinGeckoId
          ? _value.coinGeckoId
          : coinGeckoId // ignore: cast_nullable_to_non_nullable
              as String?,
      rpcUrl: freezed == rpcUrl
          ? _value.rpcUrl
          : rpcUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
      tokensPath: freezed == tokensPath
          ? _value.tokensPath
          : tokensPath // ignore: cast_nullable_to_non_nullable
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
      String? symbol,
      int? chainId,
      String? coinGeckoId,
      String? rpcUrl,
      String? iconPath,
      String? tokensPath});
}

/// @nodoc
class __$$NetworkImplCopyWithImpl<$Res>
    extends _$NetworkCopyWithImpl<$Res, _$NetworkImpl>
    implements _$$NetworkImplCopyWith<$Res> {
  __$$NetworkImplCopyWithImpl(
      _$NetworkImpl _value, $Res Function(_$NetworkImpl) _then)
      : super(_value, _then);

  /// Create a copy of Network
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? chainId = freezed,
    Object? coinGeckoId = freezed,
    Object? rpcUrl = freezed,
    Object? iconPath = freezed,
    Object? tokensPath = freezed,
  }) {
    return _then(_$NetworkImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
      chainId: freezed == chainId
          ? _value.chainId
          : chainId // ignore: cast_nullable_to_non_nullable
              as int?,
      coinGeckoId: freezed == coinGeckoId
          ? _value.coinGeckoId
          : coinGeckoId // ignore: cast_nullable_to_non_nullable
              as String?,
      rpcUrl: freezed == rpcUrl
          ? _value.rpcUrl
          : rpcUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
      tokensPath: freezed == tokensPath
          ? _value.tokensPath
          : tokensPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$NetworkImpl implements _Network {
  const _$NetworkImpl(
      {this.name,
      this.symbol,
      this.chainId,
      this.coinGeckoId,
      this.rpcUrl,
      this.iconPath,
      this.tokensPath});

  factory _$NetworkImpl.fromJson(Map<String, dynamic> json) =>
      _$$NetworkImplFromJson(json);

  @override
  final String? name;
  @override
  final String? symbol;
  @override
  final int? chainId;
  @override
  final String? coinGeckoId;
  @override
  final String? rpcUrl;
  @override
  final String? iconPath;
  @override
  final String? tokensPath;

  @override
  String toString() {
    return 'Network(name: $name, symbol: $symbol, chainId: $chainId, coinGeckoId: $coinGeckoId, rpcUrl: $rpcUrl, iconPath: $iconPath, tokensPath: $tokensPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NetworkImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.chainId, chainId) || other.chainId == chainId) &&
            (identical(other.coinGeckoId, coinGeckoId) ||
                other.coinGeckoId == coinGeckoId) &&
            (identical(other.rpcUrl, rpcUrl) || other.rpcUrl == rpcUrl) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath) &&
            (identical(other.tokensPath, tokensPath) ||
                other.tokensPath == tokensPath));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, name, symbol, chainId,
      coinGeckoId, rpcUrl, iconPath, tokensPath);

  /// Create a copy of Network
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
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
      final String? symbol,
      final int? chainId,
      final String? coinGeckoId,
      final String? rpcUrl,
      final String? iconPath,
      final String? tokensPath}) = _$NetworkImpl;

  factory _Network.fromJson(Map<String, dynamic> json) = _$NetworkImpl.fromJson;

  @override
  String? get name;
  @override
  String? get symbol;
  @override
  int? get chainId;
  @override
  String? get coinGeckoId;
  @override
  String? get rpcUrl;
  @override
  String? get iconPath;
  @override
  String? get tokensPath;

  /// Create a copy of Network
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$NetworkImplCopyWith<_$NetworkImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
