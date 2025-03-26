//
//  Generated code. Do not modify.
//  source: SGTransaction.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

class DAGStruct extends $pb.GeneratedMessage {
  factory DAGStruct({
    $core.String? type,
    $core.List<$core.int>? previousHash,
    $core.List<$core.int>? sourceAddr,
    $fixnum.Int64? nonce,
    $fixnum.Int64? timestamp,
    $core.List<$core.int>? uncleHash,
    $core.List<$core.int>? dataHash,
    $core.List<$core.int>? signature,
  }) {
    final $result = create();
    if (type != null) {
      $result.type = type;
    }
    if (previousHash != null) {
      $result.previousHash = previousHash;
    }
    if (sourceAddr != null) {
      $result.sourceAddr = sourceAddr;
    }
    if (nonce != null) {
      $result.nonce = nonce;
    }
    if (timestamp != null) {
      $result.timestamp = timestamp;
    }
    if (uncleHash != null) {
      $result.uncleHash = uncleHash;
    }
    if (dataHash != null) {
      $result.dataHash = dataHash;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  DAGStruct._() : super();
  factory DAGStruct.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DAGStruct.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DAGStruct', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'previousHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'sourceAddr', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(6, _omitFieldNames ? '' : 'uncleHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(7, _omitFieldNames ? '' : 'dataHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(8, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DAGStruct clone() => DAGStruct()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DAGStruct copyWith(void Function(DAGStruct) updates) => super.copyWith((message) => updates(message as DAGStruct)) as DAGStruct;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DAGStruct create() => DAGStruct._();
  DAGStruct createEmptyInstance() => create();
  static $pb.PbList<DAGStruct> createRepeated() => $pb.PbList<DAGStruct>();
  @$core.pragma('dart2js:noInline')
  static DAGStruct getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DAGStruct>(create);
  static DAGStruct? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get previousHash => $_getN(1);
  @$pb.TagNumber(2)
  set previousHash($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasPreviousHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreviousHash() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get sourceAddr => $_getN(2);
  @$pb.TagNumber(3)
  set sourceAddr($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSourceAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceAddr() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get nonce => $_getI64(3);
  @$pb.TagNumber(4)
  set nonce($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasNonce() => $_has(3);
  @$pb.TagNumber(4)
  void clearNonce() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get uncleHash => $_getN(5);
  @$pb.TagNumber(6)
  set uncleHash($core.List<$core.int> v) { $_setBytes(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasUncleHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearUncleHash() => clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get dataHash => $_getN(6);
  @$pb.TagNumber(7)
  set dataHash($core.List<$core.int> v) { $_setBytes(6, v); }
  @$pb.TagNumber(7)
  $core.bool hasDataHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearDataHash() => clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get signature => $_getN(7);
  @$pb.TagNumber(8)
  set signature($core.List<$core.int> v) { $_setBytes(7, v); }
  @$pb.TagNumber(8)
  $core.bool hasSignature() => $_has(7);
  @$pb.TagNumber(8)
  void clearSignature() => clearField(8);
}

class DAGWrapper extends $pb.GeneratedMessage {
  factory DAGWrapper({
    DAGStruct? dagStruct,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    return $result;
  }
  DAGWrapper._() : super();
  factory DAGWrapper.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory DAGWrapper.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'DAGWrapper', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  DAGWrapper clone() => DAGWrapper()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  DAGWrapper copyWith(void Function(DAGWrapper) updates) => super.copyWith((message) => updates(message as DAGWrapper)) as DAGWrapper;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DAGWrapper create() => DAGWrapper._();
  DAGWrapper createEmptyInstance() => create();
  static $pb.PbList<DAGWrapper> createRepeated() => $pb.PbList<DAGWrapper>();
  @$core.pragma('dart2js:noInline')
  static DAGWrapper getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DAGWrapper>(create);
  static DAGWrapper? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);
}

class TransferUTXOInput extends $pb.GeneratedMessage {
  factory TransferUTXOInput({
    $core.List<$core.int>? txIdHash,
    $core.int? outputIndex,
    $core.List<$core.int>? signature,
  }) {
    final $result = create();
    if (txIdHash != null) {
      $result.txIdHash = txIdHash;
    }
    if (outputIndex != null) {
      $result.outputIndex = outputIndex;
    }
    if (signature != null) {
      $result.signature = signature;
    }
    return $result;
  }
  TransferUTXOInput._() : super();
  factory TransferUTXOInput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferUTXOInput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferUTXOInput', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..a<$core.List<$core.int>>(1, _omitFieldNames ? '' : 'txIdHash', $pb.PbFieldType.OY)
    ..a<$core.int>(2, _omitFieldNames ? '' : 'outputIndex', $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferUTXOInput clone() => TransferUTXOInput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferUTXOInput copyWith(void Function(TransferUTXOInput) updates) => super.copyWith((message) => updates(message as TransferUTXOInput)) as TransferUTXOInput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferUTXOInput create() => TransferUTXOInput._();
  TransferUTXOInput createEmptyInstance() => create();
  static $pb.PbList<TransferUTXOInput> createRepeated() => $pb.PbList<TransferUTXOInput>();
  @$core.pragma('dart2js:noInline')
  static TransferUTXOInput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferUTXOInput>(create);
  static TransferUTXOInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txIdHash => $_getN(0);
  @$pb.TagNumber(1)
  set txIdHash($core.List<$core.int> v) { $_setBytes(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasTxIdHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxIdHash() => clearField(1);

  @$pb.TagNumber(2)
  $core.int get outputIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outputIndex($core.int v) { $_setUnsignedInt32(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasOutputIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutputIndex() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signature => $_getN(2);
  @$pb.TagNumber(3)
  set signature($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => clearField(3);
}

class TransferOutput extends $pb.GeneratedMessage {
  factory TransferOutput({
    $fixnum.Int64? encryptedAmount,
    $core.List<$core.int>? destAddr,
  }) {
    final $result = create();
    if (encryptedAmount != null) {
      $result.encryptedAmount = encryptedAmount;
    }
    if (destAddr != null) {
      $result.destAddr = destAddr;
    }
    return $result;
  }
  TransferOutput._() : super();
  factory TransferOutput.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferOutput.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferOutput', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..a<$fixnum.Int64>(1, _omitFieldNames ? '' : 'encryptedAmount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'destAddr', $pb.PbFieldType.OY)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferOutput clone() => TransferOutput()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferOutput copyWith(void Function(TransferOutput) updates) => super.copyWith((message) => updates(message as TransferOutput)) as TransferOutput;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOutput create() => TransferOutput._();
  TransferOutput createEmptyInstance() => create();
  static $pb.PbList<TransferOutput> createRepeated() => $pb.PbList<TransferOutput>();
  @$core.pragma('dart2js:noInline')
  static TransferOutput getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferOutput>(create);
  static TransferOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get encryptedAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set encryptedAmount($fixnum.Int64 v) { $_setInt64(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasEncryptedAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedAmount() => clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get destAddr => $_getN(1);
  @$pb.TagNumber(2)
  set destAddr($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasDestAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestAddr() => clearField(2);
}

class UTXOTxParams extends $pb.GeneratedMessage {
  factory UTXOTxParams({
    $core.Iterable<TransferUTXOInput>? inputs,
    $core.Iterable<TransferOutput>? outputs,
  }) {
    final $result = create();
    if (inputs != null) {
      $result.inputs.addAll(inputs);
    }
    if (outputs != null) {
      $result.outputs.addAll(outputs);
    }
    return $result;
  }
  UTXOTxParams._() : super();
  factory UTXOTxParams.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory UTXOTxParams.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'UTXOTxParams', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..pc<TransferUTXOInput>(1, _omitFieldNames ? '' : 'inputs', $pb.PbFieldType.PM, subBuilder: TransferUTXOInput.create)
    ..pc<TransferOutput>(2, _omitFieldNames ? '' : 'outputs', $pb.PbFieldType.PM, subBuilder: TransferOutput.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  UTXOTxParams clone() => UTXOTxParams()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  UTXOTxParams copyWith(void Function(UTXOTxParams) updates) => super.copyWith((message) => updates(message as UTXOTxParams)) as UTXOTxParams;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOTxParams create() => UTXOTxParams._();
  UTXOTxParams createEmptyInstance() => create();
  static $pb.PbList<UTXOTxParams> createRepeated() => $pb.PbList<UTXOTxParams>();
  @$core.pragma('dart2js:noInline')
  static UTXOTxParams getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOTxParams>(create);
  static UTXOTxParams? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<TransferUTXOInput> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $core.List<TransferOutput> get outputs => $_getList(1);
}

class TransferTx extends $pb.GeneratedMessage {
  factory TransferTx({
    DAGStruct? dagStruct,
    $fixnum.Int64? tokenId,
    UTXOTxParams? utxoParams,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    if (tokenId != null) {
      $result.tokenId = tokenId;
    }
    if (utxoParams != null) {
      $result.utxoParams = utxoParams;
    }
    return $result;
  }
  TransferTx._() : super();
  factory TransferTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory TransferTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'TransferTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<UTXOTxParams>(3, _omitFieldNames ? '' : 'utxoParams', subBuilder: UTXOTxParams.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  TransferTx clone() => TransferTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  TransferTx copyWith(void Function(TransferTx) updates) => super.copyWith((message) => updates(message as TransferTx)) as TransferTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferTx create() => TransferTx._();
  TransferTx createEmptyInstance() => create();
  static $pb.PbList<TransferTx> createRepeated() => $pb.PbList<TransferTx>();
  @$core.pragma('dart2js:noInline')
  static TransferTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<TransferTx>(create);
  static TransferTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get tokenId => $_getI64(1);
  @$pb.TagNumber(2)
  set tokenId($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasTokenId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenId() => clearField(2);

  @$pb.TagNumber(3)
  UTXOTxParams get utxoParams => $_getN(2);
  @$pb.TagNumber(3)
  set utxoParams(UTXOTxParams v) { setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasUtxoParams() => $_has(2);
  @$pb.TagNumber(3)
  void clearUtxoParams() => clearField(3);
  @$pb.TagNumber(3)
  UTXOTxParams ensureUtxoParams() => $_ensure(2);
}

class ProcessingTx extends $pb.GeneratedMessage {
  factory ProcessingTx({
    DAGStruct? dagStruct,
    $fixnum.Int64? mpcMagicKey,
    $fixnum.Int64? offset,
    $core.String? jobCid,
    $core.Iterable<$core.String>? subtaskCids,
    $core.Iterable<$core.String>? nodeAddresses,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    if (mpcMagicKey != null) {
      $result.mpcMagicKey = mpcMagicKey;
    }
    if (offset != null) {
      $result.offset = offset;
    }
    if (jobCid != null) {
      $result.jobCid = jobCid;
    }
    if (subtaskCids != null) {
      $result.subtaskCids.addAll(subtaskCids);
    }
    if (nodeAddresses != null) {
      $result.nodeAddresses.addAll(nodeAddresses);
    }
    return $result;
  }
  ProcessingTx._() : super();
  factory ProcessingTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory ProcessingTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'ProcessingTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'mpcMagicKey', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'jobCid')
    ..pPS(5, _omitFieldNames ? '' : 'subtaskCids')
    ..pPS(6, _omitFieldNames ? '' : 'nodeAddresses')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  ProcessingTx clone() => ProcessingTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  ProcessingTx copyWith(void Function(ProcessingTx) updates) => super.copyWith((message) => updates(message as ProcessingTx)) as ProcessingTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessingTx create() => ProcessingTx._();
  ProcessingTx createEmptyInstance() => create();
  static $pb.PbList<ProcessingTx> createRepeated() => $pb.PbList<ProcessingTx>();
  @$core.pragma('dart2js:noInline')
  static ProcessingTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<ProcessingTx>(create);
  static ProcessingTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get mpcMagicKey => $_getI64(1);
  @$pb.TagNumber(2)
  set mpcMagicKey($fixnum.Int64 v) { $_setInt64(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasMpcMagicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMpcMagicKey() => clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(3)
  set offset($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get jobCid => $_getSZ(3);
  @$pb.TagNumber(4)
  set jobCid($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasJobCid() => $_has(3);
  @$pb.TagNumber(4)
  void clearJobCid() => clearField(4);

  @$pb.TagNumber(5)
  $core.List<$core.String> get subtaskCids => $_getList(4);

  @$pb.TagNumber(6)
  $core.List<$core.String> get nodeAddresses => $_getList(5);
}

class MintTx extends $pb.GeneratedMessage {
  factory MintTx({
    DAGStruct? dagStruct,
    $core.List<$core.int>? chainId,
    $core.List<$core.int>? tokenId,
    $fixnum.Int64? amount,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    if (chainId != null) {
      $result.chainId = chainId;
    }
    if (tokenId != null) {
      $result.tokenId = tokenId;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    return $result;
  }
  MintTx._() : super();
  factory MintTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory MintTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'MintTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..a<$core.List<$core.int>>(2, _omitFieldNames ? '' : 'chainId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(3, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  MintTx clone() => MintTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  MintTx copyWith(void Function(MintTx) updates) => super.copyWith((message) => updates(message as MintTx)) as MintTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MintTx create() => MintTx._();
  MintTx createEmptyInstance() => create();
  static $pb.PbList<MintTx> createRepeated() => $pb.PbList<MintTx>();
  @$core.pragma('dart2js:noInline')
  static MintTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MintTx>(create);
  static MintTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get chainId => $_getN(1);
  @$pb.TagNumber(2)
  set chainId($core.List<$core.int> v) { $_setBytes(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasChainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChainId() => clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get tokenId => $_getN(2);
  @$pb.TagNumber(3)
  set tokenId($core.List<$core.int> v) { $_setBytes(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasTokenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenId() => clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount => $_getI64(3);
  @$pb.TagNumber(4)
  set amount($fixnum.Int64 v) { $_setInt64(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => clearField(4);
}

class EscrowTx extends $pb.GeneratedMessage {
  factory EscrowTx({
    DAGStruct? dagStruct,
    UTXOTxParams? utxoParams,
    $fixnum.Int64? amount,
    $core.List<$core.int>? devAddr,
    $fixnum.Int64? peersCut,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    if (utxoParams != null) {
      $result.utxoParams = utxoParams;
    }
    if (amount != null) {
      $result.amount = amount;
    }
    if (devAddr != null) {
      $result.devAddr = devAddr;
    }
    if (peersCut != null) {
      $result.peersCut = peersCut;
    }
    return $result;
  }
  EscrowTx._() : super();
  factory EscrowTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EscrowTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EscrowTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..aOM<UTXOTxParams>(2, _omitFieldNames ? '' : 'utxoParams', subBuilder: UTXOTxParams.create)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(4, _omitFieldNames ? '' : 'devAddr', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(5, _omitFieldNames ? '' : 'peersCut', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EscrowTx clone() => EscrowTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EscrowTx copyWith(void Function(EscrowTx) updates) => super.copyWith((message) => updates(message as EscrowTx)) as EscrowTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EscrowTx create() => EscrowTx._();
  EscrowTx createEmptyInstance() => create();
  static $pb.PbList<EscrowTx> createRepeated() => $pb.PbList<EscrowTx>();
  @$core.pragma('dart2js:noInline')
  static EscrowTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EscrowTx>(create);
  static EscrowTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  UTXOTxParams get utxoParams => $_getN(1);
  @$pb.TagNumber(2)
  set utxoParams(UTXOTxParams v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUtxoParams() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxoParams() => clearField(2);
  @$pb.TagNumber(2)
  UTXOTxParams ensureUtxoParams() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get devAddr => $_getN(3);
  @$pb.TagNumber(4)
  set devAddr($core.List<$core.int> v) { $_setBytes(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasDevAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearDevAddr() => clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get peersCut => $_getI64(4);
  @$pb.TagNumber(5)
  set peersCut($fixnum.Int64 v) { $_setInt64(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasPeersCut() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeersCut() => clearField(5);
}

class EscrowReleaseTx extends $pb.GeneratedMessage {
  factory EscrowReleaseTx({
    DAGStruct? dagStruct,
    UTXOTxParams? utxoParams,
    $fixnum.Int64? releaseAmount,
    $core.String? releaseAddress,
    $core.String? escrowSource,
    $core.String? originalEscrowHash,
  }) {
    final $result = create();
    if (dagStruct != null) {
      $result.dagStruct = dagStruct;
    }
    if (utxoParams != null) {
      $result.utxoParams = utxoParams;
    }
    if (releaseAmount != null) {
      $result.releaseAmount = releaseAmount;
    }
    if (releaseAddress != null) {
      $result.releaseAddress = releaseAddress;
    }
    if (escrowSource != null) {
      $result.escrowSource = escrowSource;
    }
    if (originalEscrowHash != null) {
      $result.originalEscrowHash = originalEscrowHash;
    }
    return $result;
  }
  EscrowReleaseTx._() : super();
  factory EscrowReleaseTx.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory EscrowReleaseTx.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'EscrowReleaseTx', package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'), createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct', subBuilder: DAGStruct.create)
    ..aOM<UTXOTxParams>(2, _omitFieldNames ? '' : 'utxoParams', subBuilder: UTXOTxParams.create)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'releaseAmount', $pb.PbFieldType.OU6, defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'releaseAddress')
    ..aOS(5, _omitFieldNames ? '' : 'escrowSource')
    ..aOS(6, _omitFieldNames ? '' : 'originalEscrowHash')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.deepCopy] instead. '
  'Will be removed in next major version')
  EscrowReleaseTx clone() => EscrowReleaseTx()..mergeFromMessage(this);
  @$core.Deprecated(
  'Using this can add significant overhead to your binary. '
  'Use [GeneratedMessageGenericExtensions.rebuild] instead. '
  'Will be removed in next major version')
  EscrowReleaseTx copyWith(void Function(EscrowReleaseTx) updates) => super.copyWith((message) => updates(message as EscrowReleaseTx)) as EscrowReleaseTx;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EscrowReleaseTx create() => EscrowReleaseTx._();
  EscrowReleaseTx createEmptyInstance() => create();
  static $pb.PbList<EscrowReleaseTx> createRepeated() => $pb.PbList<EscrowReleaseTx>();
  @$core.pragma('dart2js:noInline')
  static EscrowReleaseTx getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EscrowReleaseTx>(create);
  static EscrowReleaseTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct v) { setField(1, v); }
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  UTXOTxParams get utxoParams => $_getN(1);
  @$pb.TagNumber(2)
  set utxoParams(UTXOTxParams v) { setField(2, v); }
  @$pb.TagNumber(2)
  $core.bool hasUtxoParams() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxoParams() => clearField(2);
  @$pb.TagNumber(2)
  UTXOTxParams ensureUtxoParams() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get releaseAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set releaseAmount($fixnum.Int64 v) { $_setInt64(2, v); }
  @$pb.TagNumber(3)
  $core.bool hasReleaseAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearReleaseAmount() => clearField(3);

  @$pb.TagNumber(4)
  $core.String get releaseAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set releaseAddress($core.String v) { $_setString(3, v); }
  @$pb.TagNumber(4)
  $core.bool hasReleaseAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearReleaseAddress() => clearField(4);

  @$pb.TagNumber(5)
  $core.String get escrowSource => $_getSZ(4);
  @$pb.TagNumber(5)
  set escrowSource($core.String v) { $_setString(4, v); }
  @$pb.TagNumber(5)
  $core.bool hasEscrowSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearEscrowSource() => clearField(5);

  @$pb.TagNumber(6)
  $core.String get originalEscrowHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set originalEscrowHash($core.String v) { $_setString(5, v); }
  @$pb.TagNumber(6)
  $core.bool hasOriginalEscrowHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearOriginalEscrowHash() => clearField(6);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
