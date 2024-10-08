// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Coin _$CoinFromJson(Map<String, dynamic> json) {
  return _Coin.fromJson(json);
}

/// @nodoc
mixin _$Coin {
  String? get name => throw _privateConstructorUsedError;
  String? get symbol => throw _privateConstructorUsedError;
  double? get balance => throw _privateConstructorUsedError;
  NetworkSymbol? get networkSymbol => throw _privateConstructorUsedError;
  String? get iconPath => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CoinCopyWith<Coin> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CoinCopyWith<$Res> {
  factory $CoinCopyWith(Coin value, $Res Function(Coin) then) =
      _$CoinCopyWithImpl<$Res, Coin>;
  @useResult
  $Res call(
      {String? name,
      String? symbol,
      double? balance,
      NetworkSymbol? networkSymbol,
      String? iconPath});
}

/// @nodoc
class _$CoinCopyWithImpl<$Res, $Val extends Coin>
    implements $CoinCopyWith<$Res> {
  _$CoinCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? balance = freezed,
    Object? networkSymbol = freezed,
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
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      networkSymbol: freezed == networkSymbol
          ? _value.networkSymbol
          : networkSymbol // ignore: cast_nullable_to_non_nullable
              as NetworkSymbol?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CoinImplCopyWith<$Res> implements $CoinCopyWith<$Res> {
  factory _$$CoinImplCopyWith(
          _$CoinImpl value, $Res Function(_$CoinImpl) then) =
      __$$CoinImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? name,
      String? symbol,
      double? balance,
      NetworkSymbol? networkSymbol,
      String? iconPath});
}

/// @nodoc
class __$$CoinImplCopyWithImpl<$Res>
    extends _$CoinCopyWithImpl<$Res, _$CoinImpl>
    implements _$$CoinImplCopyWith<$Res> {
  __$$CoinImplCopyWithImpl(_$CoinImpl _value, $Res Function(_$CoinImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? name = freezed,
    Object? symbol = freezed,
    Object? balance = freezed,
    Object? networkSymbol = freezed,
    Object? iconPath = freezed,
  }) {
    return _then(_$CoinImpl(
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
      symbol: freezed == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String?,
      balance: freezed == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as double?,
      networkSymbol: freezed == networkSymbol
          ? _value.networkSymbol
          : networkSymbol // ignore: cast_nullable_to_non_nullable
              as NetworkSymbol?,
      iconPath: freezed == iconPath
          ? _value.iconPath
          : iconPath // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CoinImpl implements _Coin {
  const _$CoinImpl(
      {this.name,
      this.symbol,
      this.balance,
      this.networkSymbol,
      this.iconPath});

  factory _$CoinImpl.fromJson(Map<String, dynamic> json) =>
      _$$CoinImplFromJson(json);

  @override
  final String? name;
  @override
  final String? symbol;
  @override
  final double? balance;
  @override
  final NetworkSymbol? networkSymbol;
  @override
  final String? iconPath;

  @override
  String toString() {
    return 'Coin(name: $name, symbol: $symbol, balance: $balance, networkSymbol: $networkSymbol, iconPath: $iconPath)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CoinImpl &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.networkSymbol, networkSymbol) ||
                other.networkSymbol == networkSymbol) &&
            (identical(other.iconPath, iconPath) ||
                other.iconPath == iconPath));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, name, symbol, balance, networkSymbol, iconPath);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CoinImplCopyWith<_$CoinImpl> get copyWith =>
      __$$CoinImplCopyWithImpl<_$CoinImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CoinImplToJson(
      this,
    );
  }
}

abstract class _Coin implements Coin {
  const factory _Coin(
      {final String? name,
      final String? symbol,
      final double? balance,
      final NetworkSymbol? networkSymbol,
      final String? iconPath}) = _$CoinImpl;

  factory _Coin.fromJson(Map<String, dynamic> json) = _$CoinImpl.fromJson;

  @override
  String? get name;
  @override
  String? get symbol;
  @override
  double? get balance;
  @override
  NetworkSymbol? get networkSymbol;
  @override
  String? get iconPath;
  @override
  @JsonKey(ignore: true)
  _$$CoinImplCopyWith<_$CoinImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
