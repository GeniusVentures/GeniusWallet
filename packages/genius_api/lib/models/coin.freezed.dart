// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'coin.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Coin {

 String? get name; String? get symbol; String? get address; double? get balance; String? get networkSymbol; String? get decimals; String? get iconPath; String? get coinGeckoId;
/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CoinCopyWith<Coin> get copyWith => _$CoinCopyWithImpl<Coin>(this as Coin, _$identity);

  /// Serializes this Coin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Coin&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.address, address) || other.address == address)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.networkSymbol, networkSymbol) || other.networkSymbol == networkSymbol)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.coinGeckoId, coinGeckoId) || other.coinGeckoId == coinGeckoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,address,balance,networkSymbol,decimals,iconPath,coinGeckoId);

@override
String toString() {
  return 'Coin(name: $name, symbol: $symbol, address: $address, balance: $balance, networkSymbol: $networkSymbol, decimals: $decimals, iconPath: $iconPath, coinGeckoId: $coinGeckoId)';
}


}

/// @nodoc
abstract mixin class $CoinCopyWith<$Res>  {
  factory $CoinCopyWith(Coin value, $Res Function(Coin) _then) = _$CoinCopyWithImpl;
@useResult
$Res call({
 String? name, String? symbol, String? address, double? balance, String? networkSymbol, String? decimals, String? iconPath, String? coinGeckoId
});




}
/// @nodoc
class _$CoinCopyWithImpl<$Res>
    implements $CoinCopyWith<$Res> {
  _$CoinCopyWithImpl(this._self, this._then);

  final Coin _self;
  final $Res Function(Coin) _then;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? symbol = freezed,Object? address = freezed,Object? balance = freezed,Object? networkSymbol = freezed,Object? decimals = freezed,Object? iconPath = freezed,Object? coinGeckoId = freezed,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double?,networkSymbol: freezed == networkSymbol ? _self.networkSymbol : networkSymbol // ignore: cast_nullable_to_non_nullable
as String?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as String?,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,coinGeckoId: freezed == coinGeckoId ? _self.coinGeckoId : coinGeckoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Coin].
extension CoinPatterns on Coin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Coin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Coin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Coin value)  $default,){
final _that = this;
switch (_that) {
case _Coin():
return $default(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Coin value)?  $default,){
final _that = this;
switch (_that) {
case _Coin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? symbol,  String? address,  double? balance,  String? networkSymbol,  String? decimals,  String? iconPath,  String? coinGeckoId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Coin() when $default != null:
return $default(_that.name,_that.symbol,_that.address,_that.balance,_that.networkSymbol,_that.decimals,_that.iconPath,_that.coinGeckoId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? symbol,  String? address,  double? balance,  String? networkSymbol,  String? decimals,  String? iconPath,  String? coinGeckoId)  $default,) {final _that = this;
switch (_that) {
case _Coin():
return $default(_that.name,_that.symbol,_that.address,_that.balance,_that.networkSymbol,_that.decimals,_that.iconPath,_that.coinGeckoId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? symbol,  String? address,  double? balance,  String? networkSymbol,  String? decimals,  String? iconPath,  String? coinGeckoId)?  $default,) {final _that = this;
switch (_that) {
case _Coin() when $default != null:
return $default(_that.name,_that.symbol,_that.address,_that.balance,_that.networkSymbol,_that.decimals,_that.iconPath,_that.coinGeckoId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Coin implements Coin {
  const _Coin({this.name, this.symbol, this.address, this.balance, this.networkSymbol, this.decimals, this.iconPath, this.coinGeckoId});
  factory _Coin.fromJson(Map<String, dynamic> json) => _$CoinFromJson(json);

@override final  String? name;
@override final  String? symbol;
@override final  String? address;
@override final  double? balance;
@override final  String? networkSymbol;
@override final  String? decimals;
@override final  String? iconPath;
@override final  String? coinGeckoId;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CoinCopyWith<_Coin> get copyWith => __$CoinCopyWithImpl<_Coin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CoinToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Coin&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.address, address) || other.address == address)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.networkSymbol, networkSymbol) || other.networkSymbol == networkSymbol)&&(identical(other.decimals, decimals) || other.decimals == decimals)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.coinGeckoId, coinGeckoId) || other.coinGeckoId == coinGeckoId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,address,balance,networkSymbol,decimals,iconPath,coinGeckoId);

@override
String toString() {
  return 'Coin(name: $name, symbol: $symbol, address: $address, balance: $balance, networkSymbol: $networkSymbol, decimals: $decimals, iconPath: $iconPath, coinGeckoId: $coinGeckoId)';
}


}

/// @nodoc
abstract mixin class _$CoinCopyWith<$Res> implements $CoinCopyWith<$Res> {
  factory _$CoinCopyWith(_Coin value, $Res Function(_Coin) _then) = __$CoinCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? symbol, String? address, double? balance, String? networkSymbol, String? decimals, String? iconPath, String? coinGeckoId
});




}
/// @nodoc
class __$CoinCopyWithImpl<$Res>
    implements _$CoinCopyWith<$Res> {
  __$CoinCopyWithImpl(this._self, this._then);

  final _Coin _self;
  final $Res Function(_Coin) _then;

/// Create a copy of Coin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? symbol = freezed,Object? address = freezed,Object? balance = freezed,Object? networkSymbol = freezed,Object? decimals = freezed,Object? iconPath = freezed,Object? coinGeckoId = freezed,}) {
  return _then(_Coin(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,address: freezed == address ? _self.address : address // ignore: cast_nullable_to_non_nullable
as String?,balance: freezed == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as double?,networkSymbol: freezed == networkSymbol ? _self.networkSymbol : networkSymbol // ignore: cast_nullable_to_non_nullable
as String?,decimals: freezed == decimals ? _self.decimals : decimals // ignore: cast_nullable_to_non_nullable
as String?,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,coinGeckoId: freezed == coinGeckoId ? _self.coinGeckoId : coinGeckoId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
