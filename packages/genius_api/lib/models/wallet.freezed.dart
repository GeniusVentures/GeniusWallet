// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

Wallet _$WalletFromJson(Map<String, dynamic> json) {
  return _Wallet.fromJson(json);
}

/// @nodoc
mixin _$Wallet {
  int get coinType => throw _privateConstructorUsedError;
  String get walletName => throw _privateConstructorUsedError;
  String get currencySymbol => throw _privateConstructorUsedError;

  /// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
  int get balance => throw _privateConstructorUsedError;
  String get address => throw _privateConstructorUsedError;
  List<Transaction> get transactions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WalletCopyWith<Wallet> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WalletCopyWith<$Res> {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) then) =
      _$WalletCopyWithImpl<$Res, Wallet>;
  @useResult
  $Res call(
      {int coinType,
      String walletName,
      String currencySymbol,
      int balance,
      String address,
      List<Transaction> transactions});
}

/// @nodoc
class _$WalletCopyWithImpl<$Res, $Val extends Wallet>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coinType = null,
    Object? walletName = null,
    Object? currencySymbol = null,
    Object? balance = null,
    Object? address = null,
    Object? transactions = null,
  }) {
    return _then(_value.copyWith(
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
      walletName: null == walletName
          ? _value.walletName
          : walletName // ignore: cast_nullable_to_non_nullable
              as String,
      currencySymbol: null == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      transactions: null == transactions
          ? _value.transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WalletImplCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$$WalletImplCopyWith(
          _$WalletImpl value, $Res Function(_$WalletImpl) then) =
      __$$WalletImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int coinType,
      String walletName,
      String currencySymbol,
      int balance,
      String address,
      List<Transaction> transactions});
}

/// @nodoc
class __$$WalletImplCopyWithImpl<$Res>
    extends _$WalletCopyWithImpl<$Res, _$WalletImpl>
    implements _$$WalletImplCopyWith<$Res> {
  __$$WalletImplCopyWithImpl(
      _$WalletImpl _value, $Res Function(_$WalletImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? coinType = null,
    Object? walletName = null,
    Object? currencySymbol = null,
    Object? balance = null,
    Object? address = null,
    Object? transactions = null,
  }) {
    return _then(_$WalletImpl(
      coinType: null == coinType
          ? _value.coinType
          : coinType // ignore: cast_nullable_to_non_nullable
              as int,
      walletName: null == walletName
          ? _value.walletName
          : walletName // ignore: cast_nullable_to_non_nullable
              as String,
      currencySymbol: null == currencySymbol
          ? _value.currencySymbol
          : currencySymbol // ignore: cast_nullable_to_non_nullable
              as String,
      balance: null == balance
          ? _value.balance
          : balance // ignore: cast_nullable_to_non_nullable
              as int,
      address: null == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String,
      transactions: null == transactions
          ? _value._transactions
          : transactions // ignore: cast_nullable_to_non_nullable
              as List<Transaction>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WalletImpl implements _Wallet {
  const _$WalletImpl(
      {required this.coinType,
      required this.walletName,
      required this.currencySymbol,
      required this.balance,
      required this.address,
      required final List<Transaction> transactions})
      : _transactions = transactions;

  factory _$WalletImpl.fromJson(Map<String, dynamic> json) =>
      _$$WalletImplFromJson(json);

  @override
  final int coinType;
  @override
  final String walletName;
  @override
  final String currencySymbol;

  /// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
  @override
  final int balance;
  @override
  final String address;
  final List<Transaction> _transactions;
  @override
  List<Transaction> get transactions {
    if (_transactions is EqualUnmodifiableListView) return _transactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_transactions);
  }

  @override
  String toString() {
    return 'Wallet(coinType: $coinType, walletName: $walletName, currencySymbol: $currencySymbol, balance: $balance, address: $address, transactions: $transactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WalletImpl &&
            (identical(other.coinType, coinType) ||
                other.coinType == coinType) &&
            (identical(other.walletName, walletName) ||
                other.walletName == walletName) &&
            (identical(other.currencySymbol, currencySymbol) ||
                other.currencySymbol == currencySymbol) &&
            (identical(other.balance, balance) || other.balance == balance) &&
            (identical(other.address, address) || other.address == address) &&
            const DeepCollectionEquality()
                .equals(other._transactions, _transactions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      coinType,
      walletName,
      currencySymbol,
      balance,
      address,
      const DeepCollectionEquality().hash(_transactions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      __$$WalletImplCopyWithImpl<_$WalletImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WalletImplToJson(
      this,
    );
  }
}

abstract class _Wallet implements Wallet {
  const factory _Wallet(
      {required final int coinType,
      required final String walletName,
      required final String currencySymbol,
      required final int balance,
      required final String address,
      required final List<Transaction> transactions}) = _$WalletImpl;

  factory _Wallet.fromJson(Map<String, dynamic> json) = _$WalletImpl.fromJson;

  @override
  int get coinType;
  @override
  String get walletName;
  @override
  String get currencySymbol;
  @override

  /// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
  int get balance;
  @override
  String get address;
  @override
  List<Transaction> get transactions;
  @override
  @JsonKey(ignore: true)
  _$$WalletImplCopyWith<_$WalletImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
