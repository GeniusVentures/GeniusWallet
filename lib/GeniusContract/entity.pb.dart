///
//  Generated code. Do not modify.
//  source: entity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

import 'entity.pbenum.dart';

export 'entity.pbenum.dart';

class AccountAmtPair extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('AccountAmtPair', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'account', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, 'amt', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  AccountAmtPair._() : super();
  factory AccountAmtPair() => create();
  factory AccountAmtPair.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory AccountAmtPair.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  AccountAmtPair clone() => AccountAmtPair()..mergeFromMessage(this);
  AccountAmtPair copyWith(void Function(AccountAmtPair) updates) => super.copyWith((message) => updates(message as AccountAmtPair));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static AccountAmtPair create() => AccountAmtPair._();
  AccountAmtPair createEmptyInstance() => create();
  static $pb.PbList<AccountAmtPair> createRepeated() => $pb.PbList<AccountAmtPair>();
  @$core.pragma('dart2js:noInline')
  static AccountAmtPair getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<AccountAmtPair>(create);
  static AccountAmtPair _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get account => $_getN(0);
  @$pb.TagNumber(1)
  set account($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasAccount() => $_has(0);
  @$pb.TagNumber(1)
  void clearAccount() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get amt => $_getN(1);
  @$pb.TagNumber(2)
  set amt($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmt() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmt() => clearField(2);
}

class TokenInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TokenInfo', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..e<TokenType>(1, 'tokenType', $pb.PbFieldType.OE, defaultOrMaker: TokenType.INVALID, valueOf: TokenType.valueOf, enumValues: TokenType.values)
    ..a<$core.List<$core.int>>(2, 'tokenAddress', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  TokenInfo._() : super();
  factory TokenInfo() => create();
  factory TokenInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TokenInfo clone() => TokenInfo()..mergeFromMessage(this);
  TokenInfo copyWith(void Function(TokenInfo) updates) => super.copyWith((message) => updates(message as TokenInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TokenInfo create() => TokenInfo._();
  TokenInfo createEmptyInstance() => create();
  static $pb.PbList<TokenInfo> createRepeated() => $pb.PbList<TokenInfo>();
  @$core.pragma('dart2js:noInline')
  static TokenInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenInfo>(create);
  static TokenInfo _defaultInstance;

  @$pb.TagNumber(1)
  TokenType get tokenType => $_getN(0);
  @$pb.TagNumber(1)
  set tokenType(TokenType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasTokenType() => $_has(0);
  @$pb.TagNumber(1)
  void clearTokenType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get tokenAddress => $_getN(1);
  @$pb.TagNumber(2)
  set tokenAddress($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTokenAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenAddress() => clearField(2);
}

class TokenDistribution extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TokenDistribution', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOM<TokenInfo>(1, 'token', subBuilder: TokenInfo.create)
    ..pc<AccountAmtPair>(2, 'distribution', $pb.PbFieldType.PM, subBuilder: AccountAmtPair.create)
    ..hasRequiredFields = false
  ;

  TokenDistribution._() : super();
  factory TokenDistribution() => create();
  factory TokenDistribution.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenDistribution.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TokenDistribution clone() => TokenDistribution()..mergeFromMessage(this);
  TokenDistribution copyWith(void Function(TokenDistribution) updates) => super.copyWith((message) => updates(message as TokenDistribution));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TokenDistribution create() => TokenDistribution._();
  TokenDistribution createEmptyInstance() => create();
  static $pb.PbList<TokenDistribution> createRepeated() => $pb.PbList<TokenDistribution>();
  @$core.pragma('dart2js:noInline')
  static TokenDistribution getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenDistribution>(create);
  static TokenDistribution _defaultInstance;

  @$pb.TagNumber(1)
  TokenInfo get token => $_getN(0);
  @$pb.TagNumber(1)
  set token(TokenInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);
  @$pb.TagNumber(1)
  TokenInfo ensureToken() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<AccountAmtPair> get distribution => $_getList(1);
}

class TokenTransfer extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TokenTransfer', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOM<TokenInfo>(1, 'token', subBuilder: TokenInfo.create)
    ..aOM<AccountAmtPair>(2, 'receiver', subBuilder: AccountAmtPair.create)
    ..hasRequiredFields = false
  ;

  TokenTransfer._() : super();
  factory TokenTransfer() => create();
  factory TokenTransfer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TokenTransfer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TokenTransfer clone() => TokenTransfer()..mergeFromMessage(this);
  TokenTransfer copyWith(void Function(TokenTransfer) updates) => super.copyWith((message) => updates(message as TokenTransfer));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TokenTransfer create() => TokenTransfer._();
  TokenTransfer createEmptyInstance() => create();
  static $pb.PbList<TokenTransfer> createRepeated() => $pb.PbList<TokenTransfer>();
  @$core.pragma('dart2js:noInline')
  static TokenTransfer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TokenTransfer>(create);
  static TokenTransfer _defaultInstance;

  @$pb.TagNumber(1)
  TokenInfo get token => $_getN(0);
  @$pb.TagNumber(1)
  set token(TokenInfo v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasToken() => $_has(0);
  @$pb.TagNumber(1)
  void clearToken() => clearField(1);
  @$pb.TagNumber(1)
  TokenInfo ensureToken() => $_ensure(0);

  @$pb.TagNumber(2)
  AccountAmtPair get receiver => $_getN(1);
  @$pb.TagNumber(2)
  set receiver(AccountAmtPair v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasReceiver() => $_has(1);
  @$pb.TagNumber(2)
  void clearReceiver() => clearField(2);
  @$pb.TagNumber(2)
  AccountAmtPair ensureReceiver() => $_ensure(1);
}

class SimplexPaymentChannel extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SimplexPaymentChannel', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, 'peerFrom', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(3, 'seqNum', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<TokenTransfer>(4, 'transferToPeer', subBuilder: TokenTransfer.create)
    ..aOM<PayIdList>(5, 'pendingPayIds', subBuilder: PayIdList.create)
    ..a<$fixnum.Int64>(6, 'lastPayResolveDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(7, 'totalPendingAmount', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  SimplexPaymentChannel._() : super();
  factory SimplexPaymentChannel() => create();
  factory SimplexPaymentChannel.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SimplexPaymentChannel.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SimplexPaymentChannel clone() => SimplexPaymentChannel()..mergeFromMessage(this);
  SimplexPaymentChannel copyWith(void Function(SimplexPaymentChannel) updates) => super.copyWith((message) => updates(message as SimplexPaymentChannel));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SimplexPaymentChannel create() => SimplexPaymentChannel._();
  SimplexPaymentChannel createEmptyInstance() => create();
  static $pb.PbList<SimplexPaymentChannel> createRepeated() => $pb.PbList<SimplexPaymentChannel>();
  @$core.pragma('dart2js:noInline')
  static SimplexPaymentChannel getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SimplexPaymentChannel>(create);
  static SimplexPaymentChannel _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelId => $_getN(0);
  @$pb.TagNumber(1)
  set channelId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get peerFrom => $_getN(1);
  @$pb.TagNumber(2)
  set peerFrom($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPeerFrom() => $_has(1);
  @$pb.TagNumber(2)
  void clearPeerFrom() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get seqNum => $_getI64(2);
  @$pb.TagNumber(3)
  set seqNum($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSeqNum() => $_has(2);
  @$pb.TagNumber(3)
  void clearSeqNum() => clearField(3);

  @$pb.TagNumber(4)
  TokenTransfer get transferToPeer => $_getN(3);
  @$pb.TagNumber(4)
  set transferToPeer(TokenTransfer v) { setField(4, v); }
  @$pb.TagNumber(4)
  $core.bool hasTransferToPeer() => $_has(3);
  @$pb.TagNumber(4)
  void clearTransferToPeer() => clearField(4);
  @$pb.TagNumber(4)
  TokenTransfer ensureTransferToPeer() => $_ensure(3);

  @$pb.TagNumber(5)
  PayIdList get pendingPayIds => $_getN(4);
  @$pb.TagNumber(5)
  set pendingPayIds(PayIdList v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasPendingPayIds() => $_has(4);
  @$pb.TagNumber(5)
  void clearPendingPayIds() => clearField(5);
  @$pb.TagNumber(5)
  PayIdList ensurePendingPayIds() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get lastPayResolveDeadline => $_getI64(5);
  @$pb.TagNumber(6)
  set lastPayResolveDeadline($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasLastPayResolveDeadline() => $_has(5);
  @$pb.TagNumber(6)
  void clearLastPayResolveDeadline() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get totalPendingAmount => $_getN(6);
  @$pb.TagNumber(7)
  set totalPendingAmount($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasTotalPendingAmount() => $_has(6);
  @$pb.TagNumber(7)
  void clearTotalPendingAmount() => clearField(7);
}

class PayIdList extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PayIdList', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..p<$core.List<$core.int>>(1, 'payIds', $pb.PbFieldType.PY)
    ..a<$core.List<$core.int>>(2, 'nextListHash', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  PayIdList._() : super();
  factory PayIdList() => create();
  factory PayIdList.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PayIdList.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PayIdList clone() => PayIdList()..mergeFromMessage(this);
  PayIdList copyWith(void Function(PayIdList) updates) => super.copyWith((message) => updates(message as PayIdList));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PayIdList create() => PayIdList._();
  PayIdList createEmptyInstance() => create();
  static $pb.PbList<PayIdList> createRepeated() => $pb.PbList<PayIdList>();
  @$core.pragma('dart2js:noInline')
  static PayIdList getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PayIdList>(create);
  static PayIdList _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.List<$core.int>> get payIds => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get nextListHash => $_getN(1);
  @$pb.TagNumber(2)
  set nextListHash($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasNextListHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearNextListHash() => clearField(2);
}

class TransferFunction extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('TransferFunction', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..e<TransferFunctionType>(1, 'logicType', $pb.PbFieldType.OE, defaultOrMaker: TransferFunctionType.BOOLEAN_AND, valueOf: TransferFunctionType.valueOf, enumValues: TransferFunctionType.values)
    ..aOM<TokenTransfer>(2, 'maxTransfer', subBuilder: TokenTransfer.create)
    ..hasRequiredFields = false
  ;

  TransferFunction._() : super();
  factory TransferFunction() => create();
  factory TransferFunction.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferFunction.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  TransferFunction clone() => TransferFunction()..mergeFromMessage(this);
  TransferFunction copyWith(void Function(TransferFunction) updates) => super.copyWith((message) => updates(message as TransferFunction));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static TransferFunction create() => TransferFunction._();
  TransferFunction createEmptyInstance() => create();
  static $pb.PbList<TransferFunction> createRepeated() => $pb.PbList<TransferFunction>();
  @$core.pragma('dart2js:noInline')
  static TransferFunction getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferFunction>(create);
  static TransferFunction _defaultInstance;

  @$pb.TagNumber(1)
  TransferFunctionType get logicType => $_getN(0);
  @$pb.TagNumber(1)
  set logicType(TransferFunctionType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasLogicType() => $_has(0);
  @$pb.TagNumber(1)
  void clearLogicType() => clearField(1);

  @$pb.TagNumber(2)
  TokenTransfer get maxTransfer => $_getN(1);
  @$pb.TagNumber(2)
  set maxTransfer(TokenTransfer v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasMaxTransfer() => $_has(1);
  @$pb.TagNumber(2)
  void clearMaxTransfer() => clearField(2);
  @$pb.TagNumber(2)
  TokenTransfer ensureMaxTransfer() => $_ensure(1);
}

class ConditionalPay extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ConditionalPay', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, 'payTimestamp', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(2, 'src', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, 'dest', $pb.PbFieldType.OY)
    ..pc<Condition>(4, 'conditions', $pb.PbFieldType.PM, subBuilder: Condition.create)
    ..aOM<TransferFunction>(5, 'transferFunc', subBuilder: TransferFunction.create)
    ..a<$fixnum.Int64>(6, 'resolveDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(7, 'resolveTimeout', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(8, 'payResolver', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  ConditionalPay._() : super();
  factory ConditionalPay() => create();
  factory ConditionalPay.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ConditionalPay.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ConditionalPay clone() => ConditionalPay()..mergeFromMessage(this);
  ConditionalPay copyWith(void Function(ConditionalPay) updates) => super.copyWith((message) => updates(message as ConditionalPay));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ConditionalPay create() => ConditionalPay._();
  ConditionalPay createEmptyInstance() => create();
  static $pb.PbList<ConditionalPay> createRepeated() => $pb.PbList<ConditionalPay>();
  @$core.pragma('dart2js:noInline')
  static ConditionalPay getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ConditionalPay>(create);
  static ConditionalPay _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get payTimestamp => $_getI64(0);
  @$pb.TagNumber(1)
  set payTimestamp($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasPayTimestamp() => $_has(0);
  @$pb.TagNumber(1)
  void clearPayTimestamp() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get src => $_getN(1);
  @$pb.TagNumber(2)
  set src($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSrc() => $_has(1);
  @$pb.TagNumber(2)
  void clearSrc() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get dest => $_getN(2);
  @$pb.TagNumber(3)
  set dest($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDest() => $_has(2);
  @$pb.TagNumber(3)
  void clearDest() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<Condition> get conditions => $_getList(3);

  @$pb.TagNumber(5)
  TransferFunction get transferFunc => $_getN(4);
  @$pb.TagNumber(5)
  set transferFunc(TransferFunction v) { setField(5, v); }
  @$pb.TagNumber(5)
  $core.bool hasTransferFunc() => $_has(4);
  @$pb.TagNumber(5)
  void clearTransferFunc() => clearField(5);
  @$pb.TagNumber(5)
  TransferFunction ensureTransferFunc() => $_ensure(4);

  @$pb.TagNumber(6)
  $fixnum.Int64 get resolveDeadline => $_getI64(5);
  @$pb.TagNumber(6)
  set resolveDeadline($fixnum.Int64 v) { $_setInt64(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasResolveDeadline() => $_has(5);
  @$pb.TagNumber(6)
  void clearResolveDeadline() => clearField(6);

  @$pb.TagNumber(7)
  $fixnum.Int64 get resolveTimeout => $_getI64(6);
  @$pb.TagNumber(7)
  set resolveTimeout($fixnum.Int64 v) { $_setInt64(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasResolveTimeout() => $_has(6);
  @$pb.TagNumber(7)
  void clearResolveTimeout() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get payResolver => $_getN(7);
  @$pb.TagNumber(8)
  set payResolver($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasPayResolver() => $_has(7);
  @$pb.TagNumber(8)
  void clearPayResolver() => clearField(8);
}

class CondPayResult extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CondPayResult', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'condPay', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, 'amount', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  CondPayResult._() : super();
  factory CondPayResult() => create();
  factory CondPayResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CondPayResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CondPayResult clone() => CondPayResult()..mergeFromMessage(this);
  CondPayResult copyWith(void Function(CondPayResult) updates) => super.copyWith((message) => updates(message as CondPayResult));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CondPayResult create() => CondPayResult._();
  CondPayResult createEmptyInstance() => create();
  static $pb.PbList<CondPayResult> createRepeated() => $pb.PbList<CondPayResult>();
  @$core.pragma('dart2js:noInline')
  static CondPayResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CondPayResult>(create);
  static CondPayResult _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get condPay => $_getN(0);
  @$pb.TagNumber(1)
  set condPay($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCondPay() => $_has(0);
  @$pb.TagNumber(1)
  void clearCondPay() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get amount => $_getN(1);
  @$pb.TagNumber(2)
  set amount($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => clearField(2);
}

class VouchedCondPayResult extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('VouchedCondPayResult', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'condPayResult', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, 'sigOfSrc', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, 'sigOfDest', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  VouchedCondPayResult._() : super();
  factory VouchedCondPayResult() => create();
  factory VouchedCondPayResult.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory VouchedCondPayResult.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  VouchedCondPayResult clone() => VouchedCondPayResult()..mergeFromMessage(this);
  VouchedCondPayResult copyWith(void Function(VouchedCondPayResult) updates) => super.copyWith((message) => updates(message as VouchedCondPayResult));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static VouchedCondPayResult create() => VouchedCondPayResult._();
  VouchedCondPayResult createEmptyInstance() => create();
  static $pb.PbList<VouchedCondPayResult> createRepeated() => $pb.PbList<VouchedCondPayResult>();
  @$core.pragma('dart2js:noInline')
  static VouchedCondPayResult getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<VouchedCondPayResult>(create);
  static VouchedCondPayResult _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get condPayResult => $_getN(0);
  @$pb.TagNumber(1)
  set condPayResult($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCondPayResult() => $_has(0);
  @$pb.TagNumber(1)
  void clearCondPayResult() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get sigOfSrc => $_getN(1);
  @$pb.TagNumber(2)
  set sigOfSrc($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSigOfSrc() => $_has(1);
  @$pb.TagNumber(2)
  void clearSigOfSrc() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get sigOfDest => $_getN(2);
  @$pb.TagNumber(3)
  set sigOfDest($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSigOfDest() => $_has(2);
  @$pb.TagNumber(3)
  void clearSigOfDest() => clearField(3);
}

class Condition extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('Condition', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..e<ConditionType>(1, 'conditionType', $pb.PbFieldType.OE, defaultOrMaker: ConditionType.HASH_LOCK, valueOf: ConditionType.valueOf, enumValues: ConditionType.values)
    ..a<$core.List<$core.int>>(2, 'hashLock', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, 'deployedContractAddress', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(4, 'virtualContractAddress', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(5, 'argsQueryFinalization', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(6, 'argsQueryOutcome', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  Condition._() : super();
  factory Condition() => create();
  factory Condition.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Condition.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  Condition clone() => Condition()..mergeFromMessage(this);
  Condition copyWith(void Function(Condition) updates) => super.copyWith((message) => updates(message as Condition));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static Condition create() => Condition._();
  Condition createEmptyInstance() => create();
  static $pb.PbList<Condition> createRepeated() => $pb.PbList<Condition>();
  @$core.pragma('dart2js:noInline')
  static Condition getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Condition>(create);
  static Condition _defaultInstance;

  @$pb.TagNumber(1)
  ConditionType get conditionType => $_getN(0);
  @$pb.TagNumber(1)
  set conditionType(ConditionType v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasConditionType() => $_has(0);
  @$pb.TagNumber(1)
  void clearConditionType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get hashLock => $_getN(1);
  @$pb.TagNumber(2)
  set hashLock($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasHashLock() => $_has(1);
  @$pb.TagNumber(2)
  void clearHashLock() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get deployedContractAddress => $_getN(2);
  @$pb.TagNumber(3)
  set deployedContractAddress($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDeployedContractAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearDeployedContractAddress() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get virtualContractAddress => $_getN(3);
  @$pb.TagNumber(4)
  set virtualContractAddress($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasVirtualContractAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearVirtualContractAddress() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get argsQueryFinalization => $_getN(4);
  @$pb.TagNumber(5)
  set argsQueryFinalization($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasArgsQueryFinalization() => $_has(4);
  @$pb.TagNumber(5)
  void clearArgsQueryFinalization() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get argsQueryOutcome => $_getN(5);
  @$pb.TagNumber(6)
  set argsQueryOutcome($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasArgsQueryOutcome() => $_has(5);
  @$pb.TagNumber(6)
  void clearArgsQueryOutcome() => clearField(6);
}

class CooperativeWithdrawInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CooperativeWithdrawInfo', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(2, 'seqNum', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<AccountAmtPair>(3, 'withdraw', subBuilder: AccountAmtPair.create)
    ..a<$fixnum.Int64>(4, 'withdrawDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(5, 'recipientChannelId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  CooperativeWithdrawInfo._() : super();
  factory CooperativeWithdrawInfo() => create();
  factory CooperativeWithdrawInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CooperativeWithdrawInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CooperativeWithdrawInfo clone() => CooperativeWithdrawInfo()..mergeFromMessage(this);
  CooperativeWithdrawInfo copyWith(void Function(CooperativeWithdrawInfo) updates) => super.copyWith((message) => updates(message as CooperativeWithdrawInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CooperativeWithdrawInfo create() => CooperativeWithdrawInfo._();
  CooperativeWithdrawInfo createEmptyInstance() => create();
  static $pb.PbList<CooperativeWithdrawInfo> createRepeated() => $pb.PbList<CooperativeWithdrawInfo>();
  @$core.pragma('dart2js:noInline')
  static CooperativeWithdrawInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CooperativeWithdrawInfo>(create);
  static CooperativeWithdrawInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelId => $_getN(0);
  @$pb.TagNumber(1)
  set channelId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seqNum => $_getI64(1);
  @$pb.TagNumber(2)
  set seqNum($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSeqNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeqNum() => clearField(2);

  @$pb.TagNumber(3)
  AccountAmtPair get withdraw => $_getN(2);
  @$pb.TagNumber(3)
  set withdraw(AccountAmtPair v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasWithdraw() => $_has(2);
  @$pb.TagNumber(3)
  void clearWithdraw() => clearField(3);
  @$pb.TagNumber(3)
  AccountAmtPair ensureWithdraw() => $_ensure(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get withdrawDeadline => $_getI64(3);
  @$pb.TagNumber(4)
  set withdrawDeadline($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasWithdrawDeadline() => $_has(3);
  @$pb.TagNumber(4)
  void clearWithdrawDeadline() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.int> get recipientChannelId => $_getN(4);
  @$pb.TagNumber(5)
  set recipientChannelId($core.List<$core.int> v) { $_setBytes(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasRecipientChannelId() => $_has(4);
  @$pb.TagNumber(5)
  void clearRecipientChannelId() => clearField(5);
}

class PaymentChannelInitializer extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('PaymentChannelInitializer', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..aOM<TokenDistribution>(1, 'initDistribution', subBuilder: TokenDistribution.create)
    ..a<$fixnum.Int64>(2, 'openDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, 'disputeTimeout', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(4, 'msgValueReceiver', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  PaymentChannelInitializer._() : super();
  factory PaymentChannelInitializer() => create();
  factory PaymentChannelInitializer.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory PaymentChannelInitializer.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  PaymentChannelInitializer clone() => PaymentChannelInitializer()..mergeFromMessage(this);
  PaymentChannelInitializer copyWith(void Function(PaymentChannelInitializer) updates) => super.copyWith((message) => updates(message as PaymentChannelInitializer));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static PaymentChannelInitializer create() => PaymentChannelInitializer._();
  PaymentChannelInitializer createEmptyInstance() => create();
  static $pb.PbList<PaymentChannelInitializer> createRepeated() => $pb.PbList<PaymentChannelInitializer>();
  @$core.pragma('dart2js:noInline')
  static PaymentChannelInitializer getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<PaymentChannelInitializer>(create);
  static PaymentChannelInitializer _defaultInstance;

  @$pb.TagNumber(1)
  TokenDistribution get initDistribution => $_getN(0);
  @$pb.TagNumber(1)
  set initDistribution(TokenDistribution v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasInitDistribution() => $_has(0);
  @$pb.TagNumber(1)
  void clearInitDistribution() => clearField(1);
  @$pb.TagNumber(1)
  TokenDistribution ensureInitDistribution() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get openDeadline => $_getI64(1);
  @$pb.TagNumber(2)
  set openDeadline($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOpenDeadline() => $_has(1);
  @$pb.TagNumber(2)
  void clearOpenDeadline() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get disputeTimeout => $_getI64(2);
  @$pb.TagNumber(3)
  set disputeTimeout($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasDisputeTimeout() => $_has(2);
  @$pb.TagNumber(3)
  void clearDisputeTimeout() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get msgValueReceiver => $_getI64(3);
  @$pb.TagNumber(4)
  set msgValueReceiver($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMsgValueReceiver() => $_has(3);
  @$pb.TagNumber(4)
  void clearMsgValueReceiver() => clearField(4);
}

class CooperativeSettleInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CooperativeSettleInfo', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(2, 'seqNum', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..pc<AccountAmtPair>(3, 'settleBalance', $pb.PbFieldType.PM, subBuilder: AccountAmtPair.create)
    ..a<$fixnum.Int64>(4, 'settleDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  CooperativeSettleInfo._() : super();
  factory CooperativeSettleInfo() => create();
  factory CooperativeSettleInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CooperativeSettleInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CooperativeSettleInfo clone() => CooperativeSettleInfo()..mergeFromMessage(this);
  CooperativeSettleInfo copyWith(void Function(CooperativeSettleInfo) updates) => super.copyWith((message) => updates(message as CooperativeSettleInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CooperativeSettleInfo create() => CooperativeSettleInfo._();
  CooperativeSettleInfo createEmptyInstance() => create();
  static $pb.PbList<CooperativeSettleInfo> createRepeated() => $pb.PbList<CooperativeSettleInfo>();
  @$core.pragma('dart2js:noInline')
  static CooperativeSettleInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CooperativeSettleInfo>(create);
  static CooperativeSettleInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelId => $_getN(0);
  @$pb.TagNumber(1)
  set channelId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get seqNum => $_getI64(1);
  @$pb.TagNumber(2)
  set seqNum($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasSeqNum() => $_has(1);
  @$pb.TagNumber(2)
  void clearSeqNum() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<AccountAmtPair> get settleBalance => $_getList(2);

  @$pb.TagNumber(4)
  $fixnum.Int64 get settleDeadline => $_getI64(3);
  @$pb.TagNumber(4)
  set settleDeadline($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasSettleDeadline() => $_has(3);
  @$pb.TagNumber(4)
  void clearSettleDeadline() => clearField(4);
}

class ChannelMigrationInfo extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ChannelMigrationInfo', package: const $pb.PackageName('entity'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(2, 'fromLedgerAddress', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, 'toLedgerAddress', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, 'migrationDeadline', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  ChannelMigrationInfo._() : super();
  factory ChannelMigrationInfo() => create();
  factory ChannelMigrationInfo.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChannelMigrationInfo.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ChannelMigrationInfo clone() => ChannelMigrationInfo()..mergeFromMessage(this);
  ChannelMigrationInfo copyWith(void Function(ChannelMigrationInfo) updates) => super.copyWith((message) => updates(message as ChannelMigrationInfo));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ChannelMigrationInfo create() => ChannelMigrationInfo._();
  ChannelMigrationInfo createEmptyInstance() => create();
  static $pb.PbList<ChannelMigrationInfo> createRepeated() => $pb.PbList<ChannelMigrationInfo>();
  @$core.pragma('dart2js:noInline')
  static ChannelMigrationInfo getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChannelMigrationInfo>(create);
  static ChannelMigrationInfo _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelId => $_getN(0);
  @$pb.TagNumber(1)
  set channelId($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelId() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelId() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get fromLedgerAddress => $_getN(1);
  @$pb.TagNumber(2)
  set fromLedgerAddress($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasFromLedgerAddress() => $_has(1);
  @$pb.TagNumber(2)
  void clearFromLedgerAddress() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get toLedgerAddress => $_getN(2);
  @$pb.TagNumber(3)
  set toLedgerAddress($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasToLedgerAddress() => $_has(2);
  @$pb.TagNumber(3)
  void clearToLedgerAddress() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get migrationDeadline => $_getI64(3);
  @$pb.TagNumber(4)
  set migrationDeadline($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasMigrationDeadline() => $_has(3);
  @$pb.TagNumber(4)
  void clearMigrationDeadline() => clearField(4);
}

class Entity {
  static final $pb.Extension soltype = $pb.Extension<$core.String>('google.protobuf.FieldOptions', 'soltype', 1001, $pb.PbFieldType.OS);
  static void registerAllExtensions($pb.ExtensionRegistry registry) {
    registry.add(soltype);
  }
}

