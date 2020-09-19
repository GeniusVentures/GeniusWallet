///
//  Generated code. Do not modify.
//  source: chain.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

class OpenChannelRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('OpenChannelRequest', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelInitializer', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'sigs', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  OpenChannelRequest._() : super();
  factory OpenChannelRequest() => create();
  factory OpenChannelRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory OpenChannelRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  OpenChannelRequest clone() => OpenChannelRequest()..mergeFromMessage(this);
  OpenChannelRequest copyWith(void Function(OpenChannelRequest) updates) => super.copyWith((message) => updates(message as OpenChannelRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static OpenChannelRequest create() => OpenChannelRequest._();
  OpenChannelRequest createEmptyInstance() => create();
  static $pb.PbList<OpenChannelRequest> createRepeated() => $pb.PbList<OpenChannelRequest>();
  @$core.pragma('dart2js:noInline')
  static OpenChannelRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<OpenChannelRequest>(create);
  static OpenChannelRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelInitializer => $_getN(0);
  @$pb.TagNumber(1)
  set channelInitializer($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelInitializer() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelInitializer() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get sigs => $_getList(1);
}

class CooperativeWithdrawRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CooperativeWithdrawRequest', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'withdrawInfo', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'sigs', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  CooperativeWithdrawRequest._() : super();
  factory CooperativeWithdrawRequest() => create();
  factory CooperativeWithdrawRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CooperativeWithdrawRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CooperativeWithdrawRequest clone() => CooperativeWithdrawRequest()..mergeFromMessage(this);
  CooperativeWithdrawRequest copyWith(void Function(CooperativeWithdrawRequest) updates) => super.copyWith((message) => updates(message as CooperativeWithdrawRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CooperativeWithdrawRequest create() => CooperativeWithdrawRequest._();
  CooperativeWithdrawRequest createEmptyInstance() => create();
  static $pb.PbList<CooperativeWithdrawRequest> createRepeated() => $pb.PbList<CooperativeWithdrawRequest>();
  @$core.pragma('dart2js:noInline')
  static CooperativeWithdrawRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CooperativeWithdrawRequest>(create);
  static CooperativeWithdrawRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get withdrawInfo => $_getN(0);
  @$pb.TagNumber(1)
  set withdrawInfo($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasWithdrawInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearWithdrawInfo() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get sigs => $_getList(1);
}

class CooperativeSettleRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('CooperativeSettleRequest', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'settleInfo', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'sigs', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  CooperativeSettleRequest._() : super();
  factory CooperativeSettleRequest() => create();
  factory CooperativeSettleRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory CooperativeSettleRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  CooperativeSettleRequest clone() => CooperativeSettleRequest()..mergeFromMessage(this);
  CooperativeSettleRequest copyWith(void Function(CooperativeSettleRequest) updates) => super.copyWith((message) => updates(message as CooperativeSettleRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static CooperativeSettleRequest create() => CooperativeSettleRequest._();
  CooperativeSettleRequest createEmptyInstance() => create();
  static $pb.PbList<CooperativeSettleRequest> createRepeated() => $pb.PbList<CooperativeSettleRequest>();
  @$core.pragma('dart2js:noInline')
  static CooperativeSettleRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<CooperativeSettleRequest>(create);
  static CooperativeSettleRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get settleInfo => $_getN(0);
  @$pb.TagNumber(1)
  set settleInfo($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSettleInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearSettleInfo() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get sigs => $_getList(1);
}

class ResolvePayByConditionsRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ResolvePayByConditionsRequest', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'condPay', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'hashPreimages', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  ResolvePayByConditionsRequest._() : super();
  factory ResolvePayByConditionsRequest() => create();
  factory ResolvePayByConditionsRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ResolvePayByConditionsRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ResolvePayByConditionsRequest clone() => ResolvePayByConditionsRequest()..mergeFromMessage(this);
  ResolvePayByConditionsRequest copyWith(void Function(ResolvePayByConditionsRequest) updates) => super.copyWith((message) => updates(message as ResolvePayByConditionsRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ResolvePayByConditionsRequest create() => ResolvePayByConditionsRequest._();
  ResolvePayByConditionsRequest createEmptyInstance() => create();
  static $pb.PbList<ResolvePayByConditionsRequest> createRepeated() => $pb.PbList<ResolvePayByConditionsRequest>();
  @$core.pragma('dart2js:noInline')
  static ResolvePayByConditionsRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ResolvePayByConditionsRequest>(create);
  static ResolvePayByConditionsRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get condPay => $_getN(0);
  @$pb.TagNumber(1)
  set condPay($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasCondPay() => $_has(0);
  @$pb.TagNumber(1)
  void clearCondPay() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get hashPreimages => $_getList(1);
}

class SignedSimplexState extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SignedSimplexState', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'simplexState', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'sigs', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  SignedSimplexState._() : super();
  factory SignedSimplexState() => create();
  factory SignedSimplexState.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedSimplexState.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SignedSimplexState clone() => SignedSimplexState()..mergeFromMessage(this);
  SignedSimplexState copyWith(void Function(SignedSimplexState) updates) => super.copyWith((message) => updates(message as SignedSimplexState));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SignedSimplexState create() => SignedSimplexState._();
  SignedSimplexState createEmptyInstance() => create();
  static $pb.PbList<SignedSimplexState> createRepeated() => $pb.PbList<SignedSimplexState>();
  @$core.pragma('dart2js:noInline')
  static SignedSimplexState getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedSimplexState>(create);
  static SignedSimplexState _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get simplexState => $_getN(0);
  @$pb.TagNumber(1)
  set simplexState($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasSimplexState() => $_has(0);
  @$pb.TagNumber(1)
  void clearSimplexState() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get sigs => $_getList(1);
}

class SignedSimplexStateArray extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('SignedSimplexStateArray', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..pc<SignedSimplexState>(1, 'signedSimplexStates', $pb.PbFieldType.PM, subBuilder: SignedSimplexState.create)
    ..hasRequiredFields = false
  ;

  SignedSimplexStateArray._() : super();
  factory SignedSimplexStateArray() => create();
  factory SignedSimplexStateArray.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory SignedSimplexStateArray.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  SignedSimplexStateArray clone() => SignedSimplexStateArray()..mergeFromMessage(this);
  SignedSimplexStateArray copyWith(void Function(SignedSimplexStateArray) updates) => super.copyWith((message) => updates(message as SignedSimplexStateArray));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static SignedSimplexStateArray create() => SignedSimplexStateArray._();
  SignedSimplexStateArray createEmptyInstance() => create();
  static $pb.PbList<SignedSimplexStateArray> createRepeated() => $pb.PbList<SignedSimplexStateArray>();
  @$core.pragma('dart2js:noInline')
  static SignedSimplexStateArray getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<SignedSimplexStateArray>(create);
  static SignedSimplexStateArray _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<SignedSimplexState> get signedSimplexStates => $_getList(0);
}

class ChannelMigrationRequest extends $pb.GeneratedMessage {
  static final $pb.BuilderInfo _i = $pb.BuilderInfo('ChannelMigrationRequest', package: const $pb.PackageName('chain'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, 'channelMigrationInfo', $pb.PbFieldType.OY)
    ..p<$core.List<$core.int>>(2, 'sigs', $pb.PbFieldType.PY)
    ..hasRequiredFields = false
  ;

  ChannelMigrationRequest._() : super();
  factory ChannelMigrationRequest() => create();
  factory ChannelMigrationRequest.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ChannelMigrationRequest.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);
  ChannelMigrationRequest clone() => ChannelMigrationRequest()..mergeFromMessage(this);
  ChannelMigrationRequest copyWith(void Function(ChannelMigrationRequest) updates) => super.copyWith((message) => updates(message as ChannelMigrationRequest));
  $pb.BuilderInfo get info_ => _i;
  @$core.pragma('dart2js:noInline')
  static ChannelMigrationRequest create() => ChannelMigrationRequest._();
  ChannelMigrationRequest createEmptyInstance() => create();
  static $pb.PbList<ChannelMigrationRequest> createRepeated() => $pb.PbList<ChannelMigrationRequest>();
  @$core.pragma('dart2js:noInline')
  static ChannelMigrationRequest getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ChannelMigrationRequest>(create);
  static ChannelMigrationRequest _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get channelMigrationInfo => $_getN(0);
  @$pb.TagNumber(1)
  set channelMigrationInfo($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasChannelMigrationInfo() => $_has(0);
  @$pb.TagNumber(1)
  void clearChannelMigrationInfo() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.List<$core.int>> get sigs => $_getList(1);
}

