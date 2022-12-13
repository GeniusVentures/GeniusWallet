// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get hash => throw _privateConstructorUsedError;
  String get fromAddress => throw _privateConstructorUsedError;
  String get toAddress => throw _privateConstructorUsedError;
  String get timeStamp => throw _privateConstructorUsedError;
  TransactionDirection get transactionDirection =>
      throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;
  String get fees => throw _privateConstructorUsedError;
  String get coinSymbol => throw _privateConstructorUsedError;
  TransactionStatus get transactionStatus => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransactionCopyWith<Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransactionCopyWith<$Res> {
  factory $TransactionCopyWith(
          Transaction value, $Res Function(Transaction) then) =
      _$TransactionCopyWithImpl<$Res, Transaction>;
  @useResult
  $Res call(
      {String hash,
      String fromAddress,
      String toAddress,
      String timeStamp,
      TransactionDirection transactionDirection,
      String amount,
      String fees,
      String coinSymbol,
      TransactionStatus transactionStatus});
}

/// @nodoc
class _$TransactionCopyWithImpl<$Res, $Val extends Transaction>
    implements $TransactionCopyWith<$Res> {
  _$TransactionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hash = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? timeStamp = null,
    Object? transactionDirection = null,
    Object? amount = null,
    Object? fees = null,
    Object? coinSymbol = null,
    Object? transactionStatus = null,
  }) {
    return _then(_value.copyWith(
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDirection: null == transactionDirection
          ? _value.transactionDirection
          : transactionDirection // ignore: cast_nullable_to_non_nullable
              as TransactionDirection,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      fees: null == fees
          ? _value.fees
          : fees // ignore: cast_nullable_to_non_nullable
              as String,
      coinSymbol: null == coinSymbol
          ? _value.coinSymbol
          : coinSymbol // ignore: cast_nullable_to_non_nullable
              as String,
      transactionStatus: null == transactionStatus
          ? _value.transactionStatus
          : transactionStatus // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TransactionCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$_TransactionCopyWith(
          _$_Transaction value, $Res Function(_$_Transaction) then) =
      __$$_TransactionCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String hash,
      String fromAddress,
      String toAddress,
      String timeStamp,
      TransactionDirection transactionDirection,
      String amount,
      String fees,
      String coinSymbol,
      TransactionStatus transactionStatus});
}

/// @nodoc
class __$$_TransactionCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$_Transaction>
    implements _$$_TransactionCopyWith<$Res> {
  __$$_TransactionCopyWithImpl(
      _$_Transaction _value, $Res Function(_$_Transaction) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hash = null,
    Object? fromAddress = null,
    Object? toAddress = null,
    Object? timeStamp = null,
    Object? transactionDirection = null,
    Object? amount = null,
    Object? fees = null,
    Object? coinSymbol = null,
    Object? transactionStatus = null,
  }) {
    return _then(_$_Transaction(
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      toAddress: null == toAddress
          ? _value.toAddress
          : toAddress // ignore: cast_nullable_to_non_nullable
              as String,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as String,
      transactionDirection: null == transactionDirection
          ? _value.transactionDirection
          : transactionDirection // ignore: cast_nullable_to_non_nullable
              as TransactionDirection,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
      fees: null == fees
          ? _value.fees
          : fees // ignore: cast_nullable_to_non_nullable
              as String,
      coinSymbol: null == coinSymbol
          ? _value.coinSymbol
          : coinSymbol // ignore: cast_nullable_to_non_nullable
              as String,
      transactionStatus: null == transactionStatus
          ? _value.transactionStatus
          : transactionStatus // ignore: cast_nullable_to_non_nullable
              as TransactionStatus,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_Transaction implements _Transaction {
  const _$_Transaction(
      {required this.hash,
      required this.fromAddress,
      required this.toAddress,
      required this.timeStamp,
      required this.transactionDirection,
      required this.amount,
      required this.fees,
      required this.coinSymbol,
      required this.transactionStatus});

  factory _$_Transaction.fromJson(Map<String, dynamic> json) =>
      _$$_TransactionFromJson(json);

  @override
  final String hash;
  @override
  final String fromAddress;
  @override
  final String toAddress;
  @override
  final String timeStamp;
  @override
  final TransactionDirection transactionDirection;
  @override
  final String amount;
  @override
  final String fees;
  @override
  final String coinSymbol;
  @override
  final TransactionStatus transactionStatus;

  @override
  String toString() {
    return 'Transaction(hash: $hash, fromAddress: $fromAddress, toAddress: $toAddress, timeStamp: $timeStamp, transactionDirection: $transactionDirection, amount: $amount, fees: $fees, coinSymbol: $coinSymbol, transactionStatus: $transactionStatus)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Transaction &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            (identical(other.toAddress, toAddress) ||
                other.toAddress == toAddress) &&
            (identical(other.timeStamp, timeStamp) ||
                other.timeStamp == timeStamp) &&
            (identical(other.transactionDirection, transactionDirection) ||
                other.transactionDirection == transactionDirection) &&
            (identical(other.amount, amount) || other.amount == amount) &&
            (identical(other.fees, fees) || other.fees == fees) &&
            (identical(other.coinSymbol, coinSymbol) ||
                other.coinSymbol == coinSymbol) &&
            (identical(other.transactionStatus, transactionStatus) ||
                other.transactionStatus == transactionStatus));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hash,
      fromAddress,
      toAddress,
      timeStamp,
      transactionDirection,
      amount,
      fees,
      coinSymbol,
      transactionStatus);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TransactionCopyWith<_$_Transaction> get copyWith =>
      __$$_TransactionCopyWithImpl<_$_Transaction>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_TransactionToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String hash,
      required final String fromAddress,
      required final String toAddress,
      required final String timeStamp,
      required final TransactionDirection transactionDirection,
      required final String amount,
      required final String fees,
      required final String coinSymbol,
      required final TransactionStatus transactionStatus}) = _$_Transaction;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$_Transaction.fromJson;

  @override
  String get hash;
  @override
  String get fromAddress;
  @override
  String get toAddress;
  @override
  String get timeStamp;
  @override
  TransactionDirection get transactionDirection;
  @override
  String get amount;
  @override
  String get fees;
  @override
  String get coinSymbol;
  @override
  TransactionStatus get transactionStatus;
  @override
  @JsonKey(ignore: true)
  _$$_TransactionCopyWith<_$_Transaction> get copyWith =>
      throw _privateConstructorUsedError;
}
