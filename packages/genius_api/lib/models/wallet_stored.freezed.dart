// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet_stored.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

WalletStored _$WalletStoredFromJson(Map<String, dynamic> json) {
  return _WalletStored.fromJson(json);
}

/// @nodoc
mixin _$WalletStored {
  String get walletName => throw _privateConstructorUsedError;
  String get currencySymbol => throw _privateConstructorUsedError;
  String get mnemonic => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  int get coinType => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WalletStoredCopyWith<WalletStored> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletStoredCopyWith<$Res> {
  factory $WalletStoredCopyWith(
          WalletStored value, $Res Function(WalletStored) then) =
      _$WalletStoredCopyWithImpl<$Res, WalletStored>;
  @useResult
  $Res call(
      {String walletName,
      String currencySymbol,
      String mnemonic,
      String address,
      int coinType});
}

/// @nodoc
class _$WalletStoredCopyWithImpl<$Res, $Val extends WalletStored>
    implements $WalletStoredCopyWith<$Res> {
  _$WalletStoredCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletName = null,
    Object? currencySymbol = null,
    Object? mnemonic = null,
    Object? address = null,
    Object? coinType = null,
  }) {
    return _then(_value.copyWith(
      walletName: null == walletName
          ? _value.walletName
          : walletName // ignore: cast_nullable_to_non_nullable
              as String,
      currencySymbol: null == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletStoredImplCopyWith<$Res>
    implements $WalletStoredCopyWith<$Res> {
  factory _$$WalletStoredImplCopyWith(
          _$WalletStoredImpl value, $Res Function(_$WalletStoredImpl) then) =
      __$$WalletStoredImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String walletName,
      String currencySymbol,
      String mnemonic,
      String address,
      int coinType});
}

/// @nodoc
class __$$WalletStoredImplCopyWithImpl<$Res>
    extends _$WalletStoredCopyWithImpl<$Res, _$WalletStoredImpl>
    implements _$$WalletStoredImplCopyWith<$Res> {
  __$$WalletStoredImplCopyWithImpl(
      _$WalletStoredImpl _value, $Res Function(_$WalletStoredImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? walletName = null,
    Object? currencySymbol = null,
    Object? mnemonic = null,
    Object? address = null,
    Object? coinType = null,
  }) {
    return _then(_$WalletStoredImpl(
      walletName: null == walletName
          ? _value.walletName
          : walletName // ignore: cast_nullable_to_non_nullable
              as String,
      currencySymbol: null == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      mnemonic: null == mnemonic
          ? _value.mnemonic
          : mnemonic // ignore: cast_nullable_to_non_nullable
              as String,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletStoredImpl implements _WalletStored {
  const _$WalletStoredImpl(
      {required this.walletName,
      required this.currencySymbol,
      required this.mnemonic,
      required this.address,
      required this.coinType});

  factory _$WalletStoredImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletStoredImplFromJson(json);

  @override
  final String walletName;
  @override
  final String currencySymbol;
  @override
  final String mnemonic;
  @override
  final String address;
  @override
  final int coinType;

  @override
  String toString() {
    return 'WalletStored(walletName: $walletName, currencySymbol: $currencySymbol, mnemonic: $mnemonic, address: $address, coinType: $coinType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletStoredImpl &&
            (identical(other.walletName, walletName) ||
                other.walletName == walletName) &&
            (identical(other.currencySymbol, currencySymbol) ||
                other.currencySymbol == currencySymbol) &&
            (identical(other.mnemonic, mnemonic) ||
                other.mnemonic == mnemonic) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.coinType, coinType) ||
                other.coinType == coinType));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, walletName, currencySymbol, mnemonic, address, coinType);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletStoredImplCopyWith<_$WalletStoredImpl> get copyWith =>
      __$$WalletStoredImplCopyWithImpl<_$WalletStoredImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletStoredImplToJson(
      this,
    );
  }
}

abstract class _WalletStored implements WalletStored {
  const factory _WalletStored(
      {required final String walletName,
      required final String currencySymbol,
      required final String mnemonic,
      required final String address,
      required final int coinType}) = _$WalletStoredImpl;

  factory _WalletStored.fromJson(Map<String, dynamic> json) =
      _$WalletStoredImpl.fromJson;

  @override
  String get walletName;
  @override
  String get currencySymbol;
  @override
  String get mnemonic;
  @override
  String get address;
  @override
  int get coinType;
  @override
  @JsonKey(ignore: true)
  _$$WalletStoredImplCopyWith<_$WalletStoredImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
