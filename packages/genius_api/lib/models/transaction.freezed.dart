// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TransferRecipients _$TransferRecipientsFromJson(Map<String, dynamic> json) {
  return _TransferRecipients.fromJson(json);
}

/// @nodoc
mixin _$TransferRecipients {
  String get toAddr => throw _privateConstructorUsedError;
  String get amount => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TransferRecipientsCopyWith<TransferRecipients> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TransferRecipientsCopyWith<$Res> {
  factory $TransferRecipientsCopyWith(
          TransferRecipients value, $Res Function(TransferRecipients) then) =
      _$TransferRecipientsCopyWithImpl<$Res, TransferRecipients>;
  @useResult
  $Res call({String toAddr, String amount});
}

/// @nodoc
class _$TransferRecipientsCopyWithImpl<$Res, $Val extends TransferRecipients>
    implements $TransferRecipientsCopyWith<$Res> {
  _$TransferRecipientsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toAddr = null,
    Object? amount = null,
  }) {
    return _then(_value.copyWith(
      toAddr: null == toAddr
          ? _value.toAddr
          : toAddr // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransferRecipientsImplCopyWith<$Res>
    implements $TransferRecipientsCopyWith<$Res> {
  factory _$$TransferRecipientsImplCopyWith(_$TransferRecipientsImpl value,
          $Res Function(_$TransferRecipientsImpl) then) =
      __$$TransferRecipientsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String toAddr, String amount});
}

/// @nodoc
class __$$TransferRecipientsImplCopyWithImpl<$Res>
    extends _$TransferRecipientsCopyWithImpl<$Res, _$TransferRecipientsImpl>
    implements _$$TransferRecipientsImplCopyWith<$Res> {
  __$$TransferRecipientsImplCopyWithImpl(_$TransferRecipientsImpl _value,
      $Res Function(_$TransferRecipientsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? toAddr = null,
    Object? amount = null,
  }) {
    return _then(_$TransferRecipientsImpl(
      toAddr: null == toAddr
          ? _value.toAddr
          : toAddr // ignore: cast_nullable_to_non_nullable
              as String,
      amount: null == amount
          ? _value.amount
          : amount // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransferRecipientsImpl implements _TransferRecipients {
  const _$TransferRecipientsImpl({required this.toAddr, required this.amount});

  factory _$TransferRecipientsImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransferRecipientsImplFromJson(json);

  @override
  final String toAddr;
  @override
  final String amount;

  @override
  String toString() {
    return 'TransferRecipients(toAddr: $toAddr, amount: $amount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransferRecipientsImpl &&
            (identical(other.toAddr, toAddr) || other.toAddr == toAddr) &&
            (identical(other.amount, amount) || other.amount == amount));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, toAddr, amount);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransferRecipientsImplCopyWith<_$TransferRecipientsImpl> get copyWith =>
      __$$TransferRecipientsImplCopyWithImpl<_$TransferRecipientsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransferRecipientsImplToJson(
      this,
    );
  }
}

abstract class _TransferRecipients implements TransferRecipients {
  const factory _TransferRecipients(
      {required final String toAddr,
      required final String amount}) = _$TransferRecipientsImpl;

  factory _TransferRecipients.fromJson(Map<String, dynamic> json) =
      _$TransferRecipientsImpl.fromJson;

  @override
  String get toAddr;
  @override
  String get amount;
  @override
  @JsonKey(ignore: true)
  _$$TransferRecipientsImplCopyWith<_$TransferRecipientsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Transaction _$TransactionFromJson(Map<String, dynamic> json) {
  return _Transaction.fromJson(json);
}

/// @nodoc
mixin _$Transaction {
  String get hash => throw _privateConstructorUsedError;
  String get fromAddress => throw _privateConstructorUsedError;
  List<TransferRecipients> get recipients => throw _privateConstructorUsedError;
  DateTime get timeStamp => throw _privateConstructorUsedError;
  TransactionDirection get transactionDirection =>
      throw _privateConstructorUsedError;
  String get fees => throw _privateConstructorUsedError;
  String get coinSymbol => throw _privateConstructorUsedError;
  TransactionStatus get transactionStatus => throw _privateConstructorUsedError;
  TransactionType? get type => throw _privateConstructorUsedError;

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
      List<TransferRecipients> recipients,
      DateTime timeStamp,
      TransactionDirection transactionDirection,
      String fees,
      String coinSymbol,
      TransactionStatus transactionStatus,
      TransactionType? type});
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
    Object? recipients = null,
    Object? timeStamp = null,
    Object? transactionDirection = null,
    Object? fees = null,
    Object? coinSymbol = null,
    Object? transactionStatus = null,
    Object? type = freezed,
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
      recipients: null == recipients
          ? _value.recipients
          : recipients // ignore: cast_nullable_to_non_nullable
              as List<TransferRecipients>,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionDirection: null == transactionDirection
          ? _value.transactionDirection
          : transactionDirection // ignore: cast_nullable_to_non_nullable
              as TransactionDirection,
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
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TransactionImplCopyWith<$Res>
    implements $TransactionCopyWith<$Res> {
  factory _$$TransactionImplCopyWith(
          _$TransactionImpl value, $Res Function(_$TransactionImpl) then) =
      __$$TransactionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String hash,
      String fromAddress,
      List<TransferRecipients> recipients,
      DateTime timeStamp,
      TransactionDirection transactionDirection,
      String fees,
      String coinSymbol,
      TransactionStatus transactionStatus,
      TransactionType? type});
}

/// @nodoc
class __$$TransactionImplCopyWithImpl<$Res>
    extends _$TransactionCopyWithImpl<$Res, _$TransactionImpl>
    implements _$$TransactionImplCopyWith<$Res> {
  __$$TransactionImplCopyWithImpl(
      _$TransactionImpl _value, $Res Function(_$TransactionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? hash = null,
    Object? fromAddress = null,
    Object? recipients = null,
    Object? timeStamp = null,
    Object? transactionDirection = null,
    Object? fees = null,
    Object? coinSymbol = null,
    Object? transactionStatus = null,
    Object? type = freezed,
  }) {
    return _then(_$TransactionImpl(
      hash: null == hash
          ? _value.hash
          : hash // ignore: cast_nullable_to_non_nullable
              as String,
      fromAddress: null == fromAddress
          ? _value.fromAddress
          : fromAddress // ignore: cast_nullable_to_non_nullable
              as String,
      recipients: null == recipients
          ? _value._recipients
          : recipients // ignore: cast_nullable_to_non_nullable
              as List<TransferRecipients>,
      timeStamp: null == timeStamp
          ? _value.timeStamp
          : timeStamp // ignore: cast_nullable_to_non_nullable
              as DateTime,
      transactionDirection: null == transactionDirection
          ? _value.transactionDirection
          : transactionDirection // ignore: cast_nullable_to_non_nullable
              as TransactionDirection,
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
      type: freezed == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as TransactionType?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TransactionImpl implements _Transaction {
  const _$TransactionImpl(
      {required this.hash,
      required this.fromAddress,
      required final List<TransferRecipients> recipients,
      required this.timeStamp,
      required this.transactionDirection,
      required this.fees,
      required this.coinSymbol,
      required this.transactionStatus,
      this.type})
      : _recipients = recipients;

  factory _$TransactionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TransactionImplFromJson(json);

  @override
  final String hash;
  @override
  final String fromAddress;
  final List<TransferRecipients> _recipients;
  @override
  List<TransferRecipients> get recipients {
    if (_recipients is EqualUnmodifiableListView) return _recipients;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_recipients);
  }

  @override
  final DateTime timeStamp;
  @override
  final TransactionDirection transactionDirection;
  @override
  final String fees;
  @override
  final String coinSymbol;
  @override
  final TransactionStatus transactionStatus;
  @override
  final TransactionType? type;

  @override
  String toString() {
    return 'Transaction(hash: $hash, fromAddress: $fromAddress, recipients: $recipients, timeStamp: $timeStamp, transactionDirection: $transactionDirection, fees: $fees, coinSymbol: $coinSymbol, transactionStatus: $transactionStatus, type: $type)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TransactionImpl &&
            (identical(other.hash, hash) || other.hash == hash) &&
            (identical(other.fromAddress, fromAddress) ||
                other.fromAddress == fromAddress) &&
            const DeepCollectionEquality()
                .equals(other._recipients, _recipients) &&
            (identical(other.timeStamp, timeStamp) ||
                other.timeStamp == timeStamp) &&
            (identical(other.transactionDirection, transactionDirection) ||
                other.transactionDirection == transactionDirection) &&
            (identical(other.fees, fees) || other.fees == fees) &&
            (identical(other.coinSymbol, coinSymbol) ||
                other.coinSymbol == coinSymbol) &&
            (identical(other.transactionStatus, transactionStatus) ||
                other.transactionStatus == transactionStatus) &&
            (identical(other.type, type) || other.type == type));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      hash,
      fromAddress,
      const DeepCollectionEquality().hash(_recipients),
      timeStamp,
      transactionDirection,
      fees,
      coinSymbol,
      transactionStatus,
      type);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      __$$TransactionImplCopyWithImpl<_$TransactionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TransactionImplToJson(
      this,
    );
  }
}

abstract class _Transaction implements Transaction {
  const factory _Transaction(
      {required final String hash,
      required final String fromAddress,
      required final List<TransferRecipients> recipients,
      required final DateTime timeStamp,
      required final TransactionDirection transactionDirection,
      required final String fees,
      required final String coinSymbol,
      required final TransactionStatus transactionStatus,
      final TransactionType? type}) = _$TransactionImpl;

  factory _Transaction.fromJson(Map<String, dynamic> json) =
      _$TransactionImpl.fromJson;

  @override
  String get hash;
  @override
  String get fromAddress;
  @override
  List<TransferRecipients> get recipients;
  @override
  DateTime get timeStamp;
  @override
  TransactionDirection get transactionDirection;
  @override
  String get fees;
  @override
  String get coinSymbol;
  @override
  TransactionStatus get transactionStatus;
  @override
  TransactionType? get type;
  @override
  @JsonKey(ignore: true)
  _$$TransactionImplCopyWith<_$TransactionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
