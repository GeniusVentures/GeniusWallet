// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'currency.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Currency _$CurrencyFromJson(Map<String, dynamic> json) {
  return _Currency.fromJson(json);
}

/// @nodoc
mixin _$Currency {
  String get symbol => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String? get price => throw _privateConstructorUsedError;
  String? get priceCurrency => throw _privateConstructorUsedError;
  String? get logoUrl => throw _privateConstructorUsedError;
  String? get priceDate => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $CurrencyCopyWith<Currency> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CurrencyCopyWith<$Res> {
  factory $CurrencyCopyWith(Currency value, $Res Function(Currency) then) =
      _$CurrencyCopyWithImpl<$Res, Currency>;
  @useResult
  $Res call(
      {String symbol,
      String name,
      String? price,
      String? priceCurrency,
      String? logoUrl,
      String? priceDate});
}

/// @nodoc
class _$CurrencyCopyWithImpl<$Res, $Val extends Currency>
    implements $CurrencyCopyWith<$Res> {
  _$CurrencyCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? price = freezed,
    Object? priceCurrency = freezed,
    Object? logoUrl = freezed,
    Object? priceDate = freezed,
  }) {
    return _then(_value.copyWith(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      priceCurrency: freezed == priceCurrency
          ? _value.priceCurrency
          : priceCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      priceDate: freezed == priceDate
          ? _value.priceDate
          : priceDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$CurrencyImplCopyWith<$Res>
    implements $CurrencyCopyWith<$Res> {
  factory _$$CurrencyImplCopyWith(
          _$CurrencyImpl value, $Res Function(_$CurrencyImpl) then) =
      __$$CurrencyImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String symbol,
      String name,
      String? price,
      String? priceCurrency,
      String? logoUrl,
      String? priceDate});
}

/// @nodoc
class __$$CurrencyImplCopyWithImpl<$Res>
    extends _$CurrencyCopyWithImpl<$Res, _$CurrencyImpl>
    implements _$$CurrencyImplCopyWith<$Res> {
  __$$CurrencyImplCopyWithImpl(
      _$CurrencyImpl _value, $Res Function(_$CurrencyImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? symbol = null,
    Object? name = null,
    Object? price = freezed,
    Object? priceCurrency = freezed,
    Object? logoUrl = freezed,
    Object? priceDate = freezed,
  }) {
    return _then(_$CurrencyImpl(
      symbol: null == symbol
          ? _value.symbol
          : symbol // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      price: freezed == price
          ? _value.price
          : price // ignore: cast_nullable_to_non_nullable
              as String?,
      priceCurrency: freezed == priceCurrency
          ? _value.priceCurrency
          : priceCurrency // ignore: cast_nullable_to_non_nullable
              as String?,
      logoUrl: freezed == logoUrl
          ? _value.logoUrl
          : logoUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      priceDate: freezed == priceDate
          ? _value.priceDate
          : priceDate // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$CurrencyImpl implements _Currency {
  const _$CurrencyImpl(
      {required this.symbol,
      required this.name,
      this.price,
      this.priceCurrency,
      this.logoUrl,
      this.priceDate});

  factory _$CurrencyImpl.fromJson(Map<String, dynamic> json) =>
      _$$CurrencyImplFromJson(json);

  @override
  final String symbol;
  @override
  final String name;
  @override
  final String? price;
  @override
  final String? priceCurrency;
  @override
  final String? logoUrl;
  @override
  final String? priceDate;

  @override
  String toString() {
    return 'Currency(symbol: $symbol, name: $name, price: $price, priceCurrency: $priceCurrency, logoUrl: $logoUrl, priceDate: $priceDate)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CurrencyImpl &&
            (identical(other.symbol, symbol) || other.symbol == symbol) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.price, price) || other.price == price) &&
            (identical(other.priceCurrency, priceCurrency) ||
                other.priceCurrency == priceCurrency) &&
            (identical(other.logoUrl, logoUrl) || other.logoUrl == logoUrl) &&
            (identical(other.priceDate, priceDate) ||
                other.priceDate == priceDate));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, symbol, name, price, priceCurrency, logoUrl, priceDate);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$CurrencyImplCopyWith<_$CurrencyImpl> get copyWith =>
      __$$CurrencyImplCopyWithImpl<_$CurrencyImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CurrencyImplToJson(
      this,
    );
  }
}

abstract class _Currency implements Currency {
  const factory _Currency(
      {required final String symbol,
      required final String name,
      final String? price,
      final String? priceCurrency,
      final String? logoUrl,
      final String? priceDate}) = _$CurrencyImpl;

  factory _Currency.fromJson(Map<String, dynamic> json) =
      _$CurrencyImpl.fromJson;

  @override
  String get symbol;
  @override
  String get name;
  @override
  String? get price;
  @override
  String? get priceCurrency;
  @override
  String? get logoUrl;
  @override
  String? get priceDate;
  @override
  @JsonKey(ignore: true)
  _$$CurrencyImplCopyWith<_$CurrencyImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
