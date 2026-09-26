// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'network.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Network {

 String? get name;/// The CHAIN's key — what `networkSymbol` carries and what the explorer
/// map resolves a transaction's URL from. Not always the coin you spend.
 String? get symbol;/// The ticker of the coin this chain charges gas in, when it differs from
/// [symbol]. Base's chain key is "base"; the coin it spends is ETH.
/// Falls back to [symbol], which is correct for every chain named after
/// its own currency.
 String? get nativeSymbol; int? get chainId; String? get coinGeckoId; String? get rpcUrl; String? get iconPath; String? get tokensPath;/// Set in `networks.json`, never inferred from [name]: the testnet marker
/// is spelled differently on almost every chain.
 bool get testnet;
/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkCopyWith<Network> get copyWith => _$NetworkCopyWithImpl<Network>(this as Network, _$identity);

  /// Serializes this Network to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Network&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.nativeSymbol, nativeSymbol) || other.nativeSymbol == nativeSymbol)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.coinGeckoId, coinGeckoId) || other.coinGeckoId == coinGeckoId)&&(identical(other.rpcUrl, rpcUrl) || other.rpcUrl == rpcUrl)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.tokensPath, tokensPath) || other.tokensPath == tokensPath)&&(identical(other.testnet, testnet) || other.testnet == testnet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,nativeSymbol,chainId,coinGeckoId,rpcUrl,iconPath,tokensPath,testnet);

@override
String toString() {
  return 'Network(name: $name, symbol: $symbol, nativeSymbol: $nativeSymbol, chainId: $chainId, coinGeckoId: $coinGeckoId, rpcUrl: $rpcUrl, iconPath: $iconPath, tokensPath: $tokensPath, testnet: $testnet)';
}


}

/// @nodoc
abstract mixin class $NetworkCopyWith<$Res>  {
  factory $NetworkCopyWith(Network value, $Res Function(Network) _then) = _$NetworkCopyWithImpl;
@useResult
$Res call({
 String? name, String? symbol, String? nativeSymbol, int? chainId, String? coinGeckoId, String? rpcUrl, String? iconPath, String? tokensPath, bool testnet
});




}
/// @nodoc
class _$NetworkCopyWithImpl<$Res>
    implements $NetworkCopyWith<$Res> {
  _$NetworkCopyWithImpl(this._self, this._then);

  final Network _self;
  final $Res Function(Network) _then;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = freezed,Object? symbol = freezed,Object? nativeSymbol = freezed,Object? chainId = freezed,Object? coinGeckoId = freezed,Object? rpcUrl = freezed,Object? iconPath = freezed,Object? tokensPath = freezed,Object? testnet = null,}) {
  return _then(_self.copyWith(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,nativeSymbol: freezed == nativeSymbol ? _self.nativeSymbol : nativeSymbol // ignore: cast_nullable_to_non_nullable
as String?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int?,coinGeckoId: freezed == coinGeckoId ? _self.coinGeckoId : coinGeckoId // ignore: cast_nullable_to_non_nullable
as String?,rpcUrl: freezed == rpcUrl ? _self.rpcUrl : rpcUrl // ignore: cast_nullable_to_non_nullable
as String?,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,tokensPath: freezed == tokensPath ? _self.tokensPath : tokensPath // ignore: cast_nullable_to_non_nullable
as String?,testnet: null == testnet ? _self.testnet : testnet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Network].
extension NetworkPatterns on Network {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Network value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Network() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Network value)  $default,){
final _that = this;
switch (_that) {
case _Network():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Network value)?  $default,){
final _that = this;
switch (_that) {
case _Network() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? name,  String? symbol,  String? nativeSymbol,  int? chainId,  String? coinGeckoId,  String? rpcUrl,  String? iconPath,  String? tokensPath,  bool testnet)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Network() when $default != null:
return $default(_that.name,_that.symbol,_that.nativeSymbol,_that.chainId,_that.coinGeckoId,_that.rpcUrl,_that.iconPath,_that.tokensPath,_that.testnet);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? name,  String? symbol,  String? nativeSymbol,  int? chainId,  String? coinGeckoId,  String? rpcUrl,  String? iconPath,  String? tokensPath,  bool testnet)  $default,) {final _that = this;
switch (_that) {
case _Network():
return $default(_that.name,_that.symbol,_that.nativeSymbol,_that.chainId,_that.coinGeckoId,_that.rpcUrl,_that.iconPath,_that.tokensPath,_that.testnet);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? name,  String? symbol,  String? nativeSymbol,  int? chainId,  String? coinGeckoId,  String? rpcUrl,  String? iconPath,  String? tokensPath,  bool testnet)?  $default,) {final _that = this;
switch (_that) {
case _Network() when $default != null:
return $default(_that.name,_that.symbol,_that.nativeSymbol,_that.chainId,_that.coinGeckoId,_that.rpcUrl,_that.iconPath,_that.tokensPath,_that.testnet);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Network implements Network {
  const _Network({this.name, this.symbol, this.nativeSymbol, this.chainId, this.coinGeckoId, this.rpcUrl, this.iconPath, this.tokensPath, this.testnet = false});
  factory _Network.fromJson(Map<String, dynamic> json) => _$NetworkFromJson(json);

@override final  String? name;
/// The CHAIN's key — what `networkSymbol` carries and what the explorer
/// map resolves a transaction's URL from. Not always the coin you spend.
@override final  String? symbol;
/// The ticker of the coin this chain charges gas in, when it differs from
/// [symbol]. Base's chain key is "base"; the coin it spends is ETH.
/// Falls back to [symbol], which is correct for every chain named after
/// its own currency.
@override final  String? nativeSymbol;
@override final  int? chainId;
@override final  String? coinGeckoId;
@override final  String? rpcUrl;
@override final  String? iconPath;
@override final  String? tokensPath;
/// Set in `networks.json`, never inferred from [name]: the testnet marker
/// is spelled differently on almost every chain.
@override@JsonKey() final  bool testnet;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NetworkCopyWith<_Network> get copyWith => __$NetworkCopyWithImpl<_Network>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NetworkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Network&&(identical(other.name, name) || other.name == name)&&(identical(other.symbol, symbol) || other.symbol == symbol)&&(identical(other.nativeSymbol, nativeSymbol) || other.nativeSymbol == nativeSymbol)&&(identical(other.chainId, chainId) || other.chainId == chainId)&&(identical(other.coinGeckoId, coinGeckoId) || other.coinGeckoId == coinGeckoId)&&(identical(other.rpcUrl, rpcUrl) || other.rpcUrl == rpcUrl)&&(identical(other.iconPath, iconPath) || other.iconPath == iconPath)&&(identical(other.tokensPath, tokensPath) || other.tokensPath == tokensPath)&&(identical(other.testnet, testnet) || other.testnet == testnet));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,symbol,nativeSymbol,chainId,coinGeckoId,rpcUrl,iconPath,tokensPath,testnet);

@override
String toString() {
  return 'Network(name: $name, symbol: $symbol, nativeSymbol: $nativeSymbol, chainId: $chainId, coinGeckoId: $coinGeckoId, rpcUrl: $rpcUrl, iconPath: $iconPath, tokensPath: $tokensPath, testnet: $testnet)';
}


}

/// @nodoc
abstract mixin class _$NetworkCopyWith<$Res> implements $NetworkCopyWith<$Res> {
  factory _$NetworkCopyWith(_Network value, $Res Function(_Network) _then) = __$NetworkCopyWithImpl;
@override @useResult
$Res call({
 String? name, String? symbol, String? nativeSymbol, int? chainId, String? coinGeckoId, String? rpcUrl, String? iconPath, String? tokensPath, bool testnet
});




}
/// @nodoc
class __$NetworkCopyWithImpl<$Res>
    implements _$NetworkCopyWith<$Res> {
  __$NetworkCopyWithImpl(this._self, this._then);

  final _Network _self;
  final $Res Function(_Network) _then;

/// Create a copy of Network
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = freezed,Object? symbol = freezed,Object? nativeSymbol = freezed,Object? chainId = freezed,Object? coinGeckoId = freezed,Object? rpcUrl = freezed,Object? iconPath = freezed,Object? tokensPath = freezed,Object? testnet = null,}) {
  return _then(_Network(
name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,symbol: freezed == symbol ? _self.symbol : symbol // ignore: cast_nullable_to_non_nullable
as String?,nativeSymbol: freezed == nativeSymbol ? _self.nativeSymbol : nativeSymbol // ignore: cast_nullable_to_non_nullable
as String?,chainId: freezed == chainId ? _self.chainId : chainId // ignore: cast_nullable_to_non_nullable
as int?,coinGeckoId: freezed == coinGeckoId ? _self.coinGeckoId : coinGeckoId // ignore: cast_nullable_to_non_nullable
as String?,rpcUrl: freezed == rpcUrl ? _self.rpcUrl : rpcUrl // ignore: cast_nullable_to_non_nullable
as String?,iconPath: freezed == iconPath ? _self.iconPath : iconPath // ignore: cast_nullable_to_non_nullable
as String?,tokensPath: freezed == tokensPath ? _self.tokensPath : tokensPath // ignore: cast_nullable_to_non_nullable
as String?,testnet: null == testnet ? _self.testnet : testnet // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
