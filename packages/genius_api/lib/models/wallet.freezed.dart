// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'wallet.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Wallet {

 TWCoinType get coinType; String get walletName; String get currencySymbol; WalletType get walletType;/// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
 double get balance; String get address;
/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WalletCopyWith<Wallet> get copyWith => _$WalletCopyWithImpl<Wallet>(this as Wallet, _$identity);

  /// Serializes this Wallet to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Wallet&&(identical(other.coinType, coinType) || other.coinType == coinType)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.walletType, walletType) || other.walletType == walletType)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coinType,walletName,currencySymbol,walletType,balance,address);

@override
String toString() {
  return 'Wallet(coinType: $coinType, walletName: $walletName, currencySymbol: $currencySymbol, walletType: $walletType, balance: $balance, address: $address)';
}


}

/// @nodoc
abstract mixin class $WalletCopyWith<$Res>  {
  factory $WalletCopyWith(Wallet value, $Res Function(Wallet) _then) = _$WalletCopyWithImpl;
@useResult
$Res call({
 TWCoinType coinType, String walletName, String currencySymbol, WalletType walletType, double balance, String address
});




}
/// @nodoc
class _$WalletCopyWithImpl<$Res>
    implements $WalletCopyWith<$Res> {
  _$WalletCopyWithImpl(this._self, this._then);

  final Wallet _self;
  final $Res Function(Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? coinType = null,Object? walletName = null,Object? currencySymbol = null,Object? walletType = null,Object? balance = null,Object? address = null,}) {
  return _then(_self.copyWith(
coinType: null == coinType ? _self.coinType : coinType // ignore: cast_nullable_to_non_nullable
as TWCoinType,walletName: null == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,walletType: null == walletType ? _self.walletType : walletType // ignore: cast_nullable_to_non_nullable
as WalletType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Wallet].
extension WalletPatterns on Wallet {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Wallet value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Wallet value)  $default,){
final _that = this;
switch (_that) {
case _Wallet():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Wallet value)?  $default,){
final _that = this;
switch (_that) {
case _Wallet() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( TWCoinType coinType,  String walletName,  String currencySymbol,  WalletType walletType,  double balance,  String address)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.coinType,_that.walletName,_that.currencySymbol,_that.walletType,_that.balance,_that.address);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( TWCoinType coinType,  String walletName,  String currencySymbol,  WalletType walletType,  double balance,  String address)  $default,) {final _that = this;
switch (_that) {
case _Wallet():
return $default(_that.coinType,_that.walletName,_that.currencySymbol,_that.walletType,_that.balance,_that.address);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( TWCoinType coinType,  String walletName,  String currencySymbol,  WalletType walletType,  double balance,  String address)?  $default,) {final _that = this;
switch (_that) {
case _Wallet() when $default != null:
return $default(_that.coinType,_that.walletName,_that.currencySymbol,_that.walletType,_that.balance,_that.address);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Wallet implements Wallet {
  const _Wallet({required this.coinType, required this.walletName, required this.currencySymbol, required this.walletType, required this.balance, required this.address});
  factory _Wallet.fromJson(Map<String, dynamic> json) => _$WalletFromJson(json);

@override final  TWCoinType coinType;
@override final  String walletName;
@override final  String currencySymbol;
@override final  WalletType walletType;
/// The idea for making balance an int is that we store the smallest unit (i.e. satoshis, wei, etc.). However, these can be changed
@override final  double balance;
@override final  String address;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WalletCopyWith<_Wallet> get copyWith => __$WalletCopyWithImpl<_Wallet>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WalletToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Wallet&&(identical(other.coinType, coinType) || other.coinType == coinType)&&(identical(other.walletName, walletName) || other.walletName == walletName)&&(identical(other.currencySymbol, currencySymbol) || other.currencySymbol == currencySymbol)&&(identical(other.walletType, walletType) || other.walletType == walletType)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.address, address) || other.address == address));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,coinType,walletName,currencySymbol,walletType,balance,address);

@override
String toString() {
  return 'Wallet(coinType: $coinType, walletName: $walletName, currencySymbol: $currencySymbol, walletType: $walletType, balance: $balance, address: $address)';
}


}

/// @nodoc
abstract mixin class _$WalletCopyWith<$Res> implements $WalletCopyWith<$Res> {
  factory _$WalletCopyWith(_Wallet value, $Res Function(_Wallet) _then) = __$WalletCopyWithImpl;
@override @useResult
$Res call({
 TWCoinType coinType, String walletName, String currencySymbol, WalletType walletType, double balance, String address
});




}
/// @nodoc
class __$WalletCopyWithImpl<$Res>
    implements _$WalletCopyWith<$Res> {
  __$WalletCopyWithImpl(this._self, this._then);

  final _Wallet _self;
  final $Res Function(_Wallet) _then;

/// Create a copy of Wallet
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? coinType = null,Object? walletName = null,Object? currencySymbol = null,Object? walletType = null,Object? balance = null,Object? address = null,}) {
  return _then(_Wallet(
coinType: null == coinType ? _self.coinType : coinType // ignore: cast_nullable_to_non_nullable
as TWCoinType,walletName: null == walletName ? _self.walletName : walletName // ignore: cast_nullable_to_non_nullable
as String,currencySymbol: null == currencySymbol ? _self.currencySymbol : currencySymbol // ignore: cast_nullable_to_non_nullable
as String,walletType: null == walletType ? _self.walletType : walletType // ignore: cast_nullable_to_non_nullable
as WalletType,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double,address: null == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
