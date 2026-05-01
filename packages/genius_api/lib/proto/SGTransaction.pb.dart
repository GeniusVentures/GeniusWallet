// This is a generated file - do not edit.
//
// Generated from SGTransaction.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:core' as $core;

import 'package:fixnum/fixnum.dart' as $fixnum;
import 'package:protobuf/protobuf.dart' as $pb;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

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
    final result = create();
    if (type != null) result.type = type;
    if (previousHash != null) result.previousHash = previousHash;
    if (sourceAddr != null) result.sourceAddr = sourceAddr;
    if (nonce != null) result.nonce = nonce;
    if (timestamp != null) result.timestamp = timestamp;
    if (uncleHash != null) result.uncleHash = uncleHash;
    if (dataHash != null) result.dataHash = dataHash;
    if (signature != null) result.signature = signature;
    return result;
  }

  DAGStruct._();

  factory DAGStruct.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DAGStruct.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DAGStruct',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'type')
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'previousHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'sourceAddr', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'nonce', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aInt64(5, _omitFieldNames ? '' : 'timestamp')
    ..a<$core.List<$core.int>>(
        6, _omitFieldNames ? '' : 'uncleHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        7, _omitFieldNames ? '' : 'dataHash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        8, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DAGStruct clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DAGStruct copyWith(void Function(DAGStruct) updates) =>
      super.copyWith((message) => updates(message as DAGStruct)) as DAGStruct;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DAGStruct create() => DAGStruct._();
  @$core.override
  DAGStruct createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DAGStruct getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<DAGStruct>(create);
  static DAGStruct? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get type => $_getSZ(0);
  @$pb.TagNumber(1)
  set type($core.String value) => $_setString(0, value);
  @$pb.TagNumber(1)
  $core.bool hasType() => $_has(0);
  @$pb.TagNumber(1)
  void clearType() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get previousHash => $_getN(1);
  @$pb.TagNumber(2)
  set previousHash($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasPreviousHash() => $_has(1);
  @$pb.TagNumber(2)
  void clearPreviousHash() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get sourceAddr => $_getN(2);
  @$pb.TagNumber(3)
  set sourceAddr($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSourceAddr() => $_has(2);
  @$pb.TagNumber(3)
  void clearSourceAddr() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get nonce => $_getI64(3);
  @$pb.TagNumber(4)
  set nonce($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasNonce() => $_has(3);
  @$pb.TagNumber(4)
  void clearNonce() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get timestamp => $_getI64(4);
  @$pb.TagNumber(5)
  set timestamp($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasTimestamp() => $_has(4);
  @$pb.TagNumber(5)
  void clearTimestamp() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.List<$core.int> get uncleHash => $_getN(5);
  @$pb.TagNumber(6)
  set uncleHash($core.List<$core.int> value) => $_setBytes(5, value);
  @$pb.TagNumber(6)
  $core.bool hasUncleHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearUncleHash() => $_clearField(6);

  @$pb.TagNumber(7)
  $core.List<$core.int> get dataHash => $_getN(6);
  @$pb.TagNumber(7)
  set dataHash($core.List<$core.int> value) => $_setBytes(6, value);
  @$pb.TagNumber(7)
  $core.bool hasDataHash() => $_has(6);
  @$pb.TagNumber(7)
  void clearDataHash() => $_clearField(7);

  @$pb.TagNumber(8)
  $core.List<$core.int> get signature => $_getN(7);
  @$pb.TagNumber(8)
  set signature($core.List<$core.int> value) => $_setBytes(7, value);
  @$pb.TagNumber(8)
  $core.bool hasSignature() => $_has(7);
  @$pb.TagNumber(8)
  void clearSignature() => $_clearField(8);
}

class DAGWrapper extends $pb.GeneratedMessage {
  factory DAGWrapper({
    DAGStruct? dagStruct,
  }) {
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    return result;
  }

  DAGWrapper._();

  factory DAGWrapper.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory DAGWrapper.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'DAGWrapper',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DAGWrapper clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  DAGWrapper copyWith(void Function(DAGWrapper) updates) =>
      super.copyWith((message) => updates(message as DAGWrapper)) as DAGWrapper;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static DAGWrapper create() => DAGWrapper._();
  @$core.override
  DAGWrapper createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static DAGWrapper getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<DAGWrapper>(create);
  static DAGWrapper? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);
}

class TransferUTXOInput extends $pb.GeneratedMessage {
  factory TransferUTXOInput({
    $core.List<$core.int>? txIdHash,
    $core.int? outputIndex,
    $core.List<$core.int>? signature,
  }) {
    final result = create();
    if (txIdHash != null) result.txIdHash = txIdHash;
    if (outputIndex != null) result.outputIndex = outputIndex;
    if (signature != null) result.signature = signature;
    return result;
  }

  TransferUTXOInput._();

  factory TransferUTXOInput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferUTXOInput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferUTXOInput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..a<$core.List<$core.int>>(
        1, _omitFieldNames ? '' : 'txIdHash', $pb.PbFieldType.OY)
    ..aI(2, _omitFieldNames ? '' : 'outputIndex',
        fieldType: $pb.PbFieldType.OU3)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'signature', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferUTXOInput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferUTXOInput copyWith(void Function(TransferUTXOInput) updates) =>
      super.copyWith((message) => updates(message as TransferUTXOInput))
          as TransferUTXOInput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferUTXOInput create() => TransferUTXOInput._();
  @$core.override
  TransferUTXOInput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferUTXOInput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferUTXOInput>(create);
  static TransferUTXOInput? _defaultInstance;

  @$pb.TagNumber(1)
  $core.List<$core.int> get txIdHash => $_getN(0);
  @$pb.TagNumber(1)
  set txIdHash($core.List<$core.int> value) => $_setBytes(0, value);
  @$pb.TagNumber(1)
  $core.bool hasTxIdHash() => $_has(0);
  @$pb.TagNumber(1)
  void clearTxIdHash() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.int get outputIndex => $_getIZ(1);
  @$pb.TagNumber(2)
  set outputIndex($core.int value) => $_setUnsignedInt32(1, value);
  @$pb.TagNumber(2)
  $core.bool hasOutputIndex() => $_has(1);
  @$pb.TagNumber(2)
  void clearOutputIndex() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get signature => $_getN(2);
  @$pb.TagNumber(3)
  set signature($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasSignature() => $_has(2);
  @$pb.TagNumber(3)
  void clearSignature() => $_clearField(3);
}

class TransferOutput extends $pb.GeneratedMessage {
  factory TransferOutput({
    $fixnum.Int64? encryptedAmount,
    $core.List<$core.int>? destAddr,
    $core.List<$core.int>? tokenId,
  }) {
    final result = create();
    if (encryptedAmount != null) result.encryptedAmount = encryptedAmount;
    if (destAddr != null) result.destAddr = destAddr;
    if (tokenId != null) result.tokenId = tokenId;
    return result;
  }

  TransferOutput._();

  factory TransferOutput.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferOutput.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferOutput',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..a<$fixnum.Int64>(
        1, _omitFieldNames ? '' : 'encryptedAmount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'destAddr', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOutput clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferOutput copyWith(void Function(TransferOutput) updates) =>
      super.copyWith((message) => updates(message as TransferOutput))
          as TransferOutput;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferOutput create() => TransferOutput._();
  @$core.override
  TransferOutput createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferOutput getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferOutput>(create);
  static TransferOutput? _defaultInstance;

  @$pb.TagNumber(1)
  $fixnum.Int64 get encryptedAmount => $_getI64(0);
  @$pb.TagNumber(1)
  set encryptedAmount($fixnum.Int64 value) => $_setInt64(0, value);
  @$pb.TagNumber(1)
  $core.bool hasEncryptedAmount() => $_has(0);
  @$pb.TagNumber(1)
  void clearEncryptedAmount() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.List<$core.int> get destAddr => $_getN(1);
  @$pb.TagNumber(2)
  set destAddr($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasDestAddr() => $_has(1);
  @$pb.TagNumber(2)
  void clearDestAddr() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get tokenId => $_getN(2);
  @$pb.TagNumber(3)
  set tokenId($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTokenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenId() => $_clearField(3);
}

class UTXOTxParams extends $pb.GeneratedMessage {
  factory UTXOTxParams({
    $core.Iterable<TransferUTXOInput>? inputs,
    $core.Iterable<TransferOutput>? outputs,
  }) {
    final result = create();
    if (inputs != null) result.inputs.addAll(inputs);
    if (outputs != null) result.outputs.addAll(outputs);
    return result;
  }

  UTXOTxParams._();

  factory UTXOTxParams.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UTXOTxParams.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UTXOTxParams',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..pPM<TransferUTXOInput>(1, _omitFieldNames ? '' : 'inputs',
        subBuilder: TransferUTXOInput.create)
    ..pPM<TransferOutput>(2, _omitFieldNames ? '' : 'outputs',
        subBuilder: TransferOutput.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOTxParams clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOTxParams copyWith(void Function(UTXOTxParams) updates) =>
      super.copyWith((message) => updates(message as UTXOTxParams))
          as UTXOTxParams;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOTxParams create() => UTXOTxParams._();
  @$core.override
  UTXOTxParams createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UTXOTxParams getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<UTXOTxParams>(create);
  static UTXOTxParams? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<TransferUTXOInput> get inputs => $_getList(0);

  @$pb.TagNumber(2)
  $pb.PbList<TransferOutput> get outputs => $_getList(1);
}

class UTXO extends $pb.GeneratedMessage {
  factory UTXO({
    $core.int? outputIdx,
    $fixnum.Int64? amount,
    $core.List<$core.int>? hash,
    $core.List<$core.int>? token,
  }) {
    final result = create();
    if (outputIdx != null) result.outputIdx = outputIdx;
    if (amount != null) result.amount = amount;
    if (hash != null) result.hash = hash;
    if (token != null) result.token = token;
    return result;
  }

  UTXO._();

  factory UTXO.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UTXO.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UTXO',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aI(1, _omitFieldNames ? '' : 'outputIdx', fieldType: $pb.PbFieldType.OU3)
    ..a<$fixnum.Int64>(2, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'hash', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'token', $pb.PbFieldType.OY)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXO clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXO copyWith(void Function(UTXO) updates) =>
      super.copyWith((message) => updates(message as UTXO)) as UTXO;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXO create() => UTXO._();
  @$core.override
  UTXO createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UTXO getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXO>(create);
  static UTXO? _defaultInstance;

  @$pb.TagNumber(1)
  $core.int get outputIdx => $_getIZ(0);
  @$pb.TagNumber(1)
  set outputIdx($core.int value) => $_setUnsignedInt32(0, value);
  @$pb.TagNumber(1)
  $core.bool hasOutputIdx() => $_has(0);
  @$pb.TagNumber(1)
  void clearOutputIdx() => $_clearField(1);

  @$pb.TagNumber(2)
  $fixnum.Int64 get amount => $_getI64(1);
  @$pb.TagNumber(2)
  set amount($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasAmount() => $_has(1);
  @$pb.TagNumber(2)
  void clearAmount() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get hash => $_getN(2);
  @$pb.TagNumber(3)
  set hash($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasHash() => $_has(2);
  @$pb.TagNumber(3)
  void clearHash() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get token => $_getN(3);
  @$pb.TagNumber(4)
  set token($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasToken() => $_has(3);
  @$pb.TagNumber(4)
  void clearToken() => $_clearField(4);
}

class UTXOList extends $pb.GeneratedMessage {
  factory UTXOList({
    $core.Iterable<UTXO>? utxos,
  }) {
    final result = create();
    if (utxos != null) result.utxos.addAll(utxos);
    return result;
  }

  UTXOList._();

  factory UTXOList.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory UTXOList.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'UTXOList',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..pPM<UTXO>(1, _omitFieldNames ? '' : 'utxos', subBuilder: UTXO.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOList clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  UTXOList copyWith(void Function(UTXOList) updates) =>
      super.copyWith((message) => updates(message as UTXOList)) as UTXOList;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static UTXOList create() => UTXOList._();
  @$core.override
  UTXOList createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static UTXOList getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<UTXOList>(create);
  static UTXOList? _defaultInstance;

  @$pb.TagNumber(1)
  $pb.PbList<UTXO> get utxos => $_getList(0);
}

class TransferTx extends $pb.GeneratedMessage {
  factory TransferTx({
    DAGStruct? dagStruct,
    $core.List<$core.int>? tokenId,
    UTXOTxParams? utxoParams,
  }) {
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (tokenId != null) result.tokenId = tokenId;
    if (utxoParams != null) result.utxoParams = utxoParams;
    return result;
  }

  TransferTx._();

  factory TransferTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory TransferTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'TransferTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OY)
    ..aOM<UTXOTxParams>(3, _omitFieldNames ? '' : 'utxoParams',
        subBuilder: UTXOTxParams.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  TransferTx copyWith(void Function(TransferTx) updates) =>
      super.copyWith((message) => updates(message as TransferTx)) as TransferTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static TransferTx create() => TransferTx._();
  @$core.override
  TransferTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static TransferTx getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<TransferTx>(create);
  static TransferTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get tokenId => $_getN(1);
  @$pb.TagNumber(2)
  set tokenId($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasTokenId() => $_has(1);
  @$pb.TagNumber(2)
  void clearTokenId() => $_clearField(2);

  @$pb.TagNumber(3)
  UTXOTxParams get utxoParams => $_getN(2);
  @$pb.TagNumber(3)
  set utxoParams(UTXOTxParams value) => $_setField(3, value);
  @$pb.TagNumber(3)
  $core.bool hasUtxoParams() => $_has(2);
  @$pb.TagNumber(3)
  void clearUtxoParams() => $_clearField(3);
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
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (mpcMagicKey != null) result.mpcMagicKey = mpcMagicKey;
    if (offset != null) result.offset = offset;
    if (jobCid != null) result.jobCid = jobCid;
    if (subtaskCids != null) result.subtaskCids.addAll(subtaskCids);
    if (nodeAddresses != null) result.nodeAddresses.addAll(nodeAddresses);
    return result;
  }

  ProcessingTx._();

  factory ProcessingTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory ProcessingTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'ProcessingTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..a<$fixnum.Int64>(
        2, _omitFieldNames ? '' : 'mpcMagicKey', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'offset', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'jobCid')
    ..pPS(5, _omitFieldNames ? '' : 'subtaskCids')
    ..pPS(6, _omitFieldNames ? '' : 'nodeAddresses')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessingTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  ProcessingTx copyWith(void Function(ProcessingTx) updates) =>
      super.copyWith((message) => updates(message as ProcessingTx))
          as ProcessingTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static ProcessingTx create() => ProcessingTx._();
  @$core.override
  ProcessingTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static ProcessingTx getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<ProcessingTx>(create);
  static ProcessingTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $fixnum.Int64 get mpcMagicKey => $_getI64(1);
  @$pb.TagNumber(2)
  set mpcMagicKey($fixnum.Int64 value) => $_setInt64(1, value);
  @$pb.TagNumber(2)
  $core.bool hasMpcMagicKey() => $_has(1);
  @$pb.TagNumber(2)
  void clearMpcMagicKey() => $_clearField(2);

  @$pb.TagNumber(3)
  $fixnum.Int64 get offset => $_getI64(2);
  @$pb.TagNumber(3)
  set offset($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasOffset() => $_has(2);
  @$pb.TagNumber(3)
  void clearOffset() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get jobCid => $_getSZ(3);
  @$pb.TagNumber(4)
  set jobCid($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasJobCid() => $_has(3);
  @$pb.TagNumber(4)
  void clearJobCid() => $_clearField(4);

  @$pb.TagNumber(5)
  $pb.PbList<$core.String> get subtaskCids => $_getList(4);

  @$pb.TagNumber(6)
  $pb.PbList<$core.String> get nodeAddresses => $_getList(5);
}

class MintTx extends $pb.GeneratedMessage {
  factory MintTx({
    DAGStruct? dagStruct,
    $core.List<$core.int>? chainId,
    $core.List<$core.int>? tokenId,
    $fixnum.Int64? amount,
  }) {
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (chainId != null) result.chainId = chainId;
    if (tokenId != null) result.tokenId = tokenId;
    if (amount != null) result.amount = amount;
    return result;
  }

  MintTx._();

  factory MintTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MintTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MintTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'chainId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MintTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MintTx copyWith(void Function(MintTx) updates) =>
      super.copyWith((message) => updates(message as MintTx)) as MintTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MintTx create() => MintTx._();
  @$core.override
  MintTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MintTx getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MintTx>(create);
  static MintTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get chainId => $_getN(1);
  @$pb.TagNumber(2)
  set chainId($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChainId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get tokenId => $_getN(2);
  @$pb.TagNumber(3)
  set tokenId($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTokenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount => $_getI64(3);
  @$pb.TagNumber(4)
  set amount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);
}

class MintTxV2 extends $pb.GeneratedMessage {
  factory MintTxV2({
    DAGStruct? dagStruct,
    $core.List<$core.int>? chainId,
    $core.List<$core.int>? tokenId,
    $fixnum.Int64? amount,
    UTXOTxParams? utxoParams,
  }) {
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (chainId != null) result.chainId = chainId;
    if (tokenId != null) result.tokenId = tokenId;
    if (amount != null) result.amount = amount;
    if (utxoParams != null) result.utxoParams = utxoParams;
    return result;
  }

  MintTxV2._();

  factory MintTxV2.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory MintTxV2.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'MintTxV2',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..a<$core.List<$core.int>>(
        2, _omitFieldNames ? '' : 'chainId', $pb.PbFieldType.OY)
    ..a<$core.List<$core.int>>(
        3, _omitFieldNames ? '' : 'tokenId', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(4, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOM<UTXOTxParams>(5, _omitFieldNames ? '' : 'utxoParams',
        subBuilder: UTXOTxParams.create)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MintTxV2 clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  MintTxV2 copyWith(void Function(MintTxV2) updates) =>
      super.copyWith((message) => updates(message as MintTxV2)) as MintTxV2;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static MintTxV2 create() => MintTxV2._();
  @$core.override
  MintTxV2 createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static MintTxV2 getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<MintTxV2>(create);
  static MintTxV2? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  $core.List<$core.int> get chainId => $_getN(1);
  @$pb.TagNumber(2)
  set chainId($core.List<$core.int> value) => $_setBytes(1, value);
  @$pb.TagNumber(2)
  $core.bool hasChainId() => $_has(1);
  @$pb.TagNumber(2)
  void clearChainId() => $_clearField(2);

  @$pb.TagNumber(3)
  $core.List<$core.int> get tokenId => $_getN(2);
  @$pb.TagNumber(3)
  set tokenId($core.List<$core.int> value) => $_setBytes(2, value);
  @$pb.TagNumber(3)
  $core.bool hasTokenId() => $_has(2);
  @$pb.TagNumber(3)
  void clearTokenId() => $_clearField(3);

  @$pb.TagNumber(4)
  $fixnum.Int64 get amount => $_getI64(3);
  @$pb.TagNumber(4)
  set amount($fixnum.Int64 value) => $_setInt64(3, value);
  @$pb.TagNumber(4)
  $core.bool hasAmount() => $_has(3);
  @$pb.TagNumber(4)
  void clearAmount() => $_clearField(4);

  @$pb.TagNumber(5)
  UTXOTxParams get utxoParams => $_getN(4);
  @$pb.TagNumber(5)
  set utxoParams(UTXOTxParams value) => $_setField(5, value);
  @$pb.TagNumber(5)
  $core.bool hasUtxoParams() => $_has(4);
  @$pb.TagNumber(5)
  void clearUtxoParams() => $_clearField(5);
  @$pb.TagNumber(5)
  UTXOTxParams ensureUtxoParams() => $_ensure(4);
}

class EscrowTx extends $pb.GeneratedMessage {
  factory EscrowTx({
    DAGStruct? dagStruct,
    UTXOTxParams? utxoParams,
    $fixnum.Int64? amount,
    $core.List<$core.int>? devAddr,
    $fixnum.Int64? peersCut,
  }) {
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (utxoParams != null) result.utxoParams = utxoParams;
    if (amount != null) result.amount = amount;
    if (devAddr != null) result.devAddr = devAddr;
    if (peersCut != null) result.peersCut = peersCut;
    return result;
  }

  EscrowTx._();

  factory EscrowTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EscrowTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EscrowTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..aOM<UTXOTxParams>(2, _omitFieldNames ? '' : 'utxoParams',
        subBuilder: UTXOTxParams.create)
    ..a<$fixnum.Int64>(3, _omitFieldNames ? '' : 'amount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..a<$core.List<$core.int>>(
        4, _omitFieldNames ? '' : 'devAddr', $pb.PbFieldType.OY)
    ..a<$fixnum.Int64>(
        5, _omitFieldNames ? '' : 'peersCut', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EscrowTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EscrowTx copyWith(void Function(EscrowTx) updates) =>
      super.copyWith((message) => updates(message as EscrowTx)) as EscrowTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EscrowTx create() => EscrowTx._();
  @$core.override
  EscrowTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EscrowTx getDefault() =>
      _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<EscrowTx>(create);
  static EscrowTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  UTXOTxParams get utxoParams => $_getN(1);
  @$pb.TagNumber(2)
  set utxoParams(UTXOTxParams value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUtxoParams() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxoParams() => $_clearField(2);
  @$pb.TagNumber(2)
  UTXOTxParams ensureUtxoParams() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get amount => $_getI64(2);
  @$pb.TagNumber(3)
  set amount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.List<$core.int> get devAddr => $_getN(3);
  @$pb.TagNumber(4)
  set devAddr($core.List<$core.int> value) => $_setBytes(3, value);
  @$pb.TagNumber(4)
  $core.bool hasDevAddr() => $_has(3);
  @$pb.TagNumber(4)
  void clearDevAddr() => $_clearField(4);

  @$pb.TagNumber(5)
  $fixnum.Int64 get peersCut => $_getI64(4);
  @$pb.TagNumber(5)
  set peersCut($fixnum.Int64 value) => $_setInt64(4, value);
  @$pb.TagNumber(5)
  $core.bool hasPeersCut() => $_has(4);
  @$pb.TagNumber(5)
  void clearPeersCut() => $_clearField(5);
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
    final result = create();
    if (dagStruct != null) result.dagStruct = dagStruct;
    if (utxoParams != null) result.utxoParams = utxoParams;
    if (releaseAmount != null) result.releaseAmount = releaseAmount;
    if (releaseAddress != null) result.releaseAddress = releaseAddress;
    if (escrowSource != null) result.escrowSource = escrowSource;
    if (originalEscrowHash != null)
      result.originalEscrowHash = originalEscrowHash;
    return result;
  }

  EscrowReleaseTx._();

  factory EscrowReleaseTx.fromBuffer($core.List<$core.int> data,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromBuffer(data, registry);
  factory EscrowReleaseTx.fromJson($core.String json,
          [$pb.ExtensionRegistry registry = $pb.ExtensionRegistry.EMPTY]) =>
      create()..mergeFromJson(json, registry);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(
      _omitMessageNames ? '' : 'EscrowReleaseTx',
      package: const $pb.PackageName(_omitMessageNames ? '' : 'SGTransaction'),
      createEmptyInstance: create)
    ..aOM<DAGStruct>(1, _omitFieldNames ? '' : 'dagStruct',
        subBuilder: DAGStruct.create)
    ..aOM<UTXOTxParams>(2, _omitFieldNames ? '' : 'utxoParams',
        subBuilder: UTXOTxParams.create)
    ..a<$fixnum.Int64>(
        3, _omitFieldNames ? '' : 'releaseAmount', $pb.PbFieldType.OU6,
        defaultOrMaker: $fixnum.Int64.ZERO)
    ..aOS(4, _omitFieldNames ? '' : 'releaseAddress')
    ..aOS(5, _omitFieldNames ? '' : 'escrowSource')
    ..aOS(6, _omitFieldNames ? '' : 'originalEscrowHash')
    ..hasRequiredFields = false;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EscrowReleaseTx clone() => deepCopy();
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  EscrowReleaseTx copyWith(void Function(EscrowReleaseTx) updates) =>
      super.copyWith((message) => updates(message as EscrowReleaseTx))
          as EscrowReleaseTx;

  @$core.override
  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static EscrowReleaseTx create() => EscrowReleaseTx._();
  @$core.override
  EscrowReleaseTx createEmptyInstance() => create();
  @$core.pragma('dart2js:noInline')
  static EscrowReleaseTx getDefault() => _defaultInstance ??=
      $pb.GeneratedMessage.$_defaultFor<EscrowReleaseTx>(create);
  static EscrowReleaseTx? _defaultInstance;

  @$pb.TagNumber(1)
  DAGStruct get dagStruct => $_getN(0);
  @$pb.TagNumber(1)
  set dagStruct(DAGStruct value) => $_setField(1, value);
  @$pb.TagNumber(1)
  $core.bool hasDagStruct() => $_has(0);
  @$pb.TagNumber(1)
  void clearDagStruct() => $_clearField(1);
  @$pb.TagNumber(1)
  DAGStruct ensureDagStruct() => $_ensure(0);

  @$pb.TagNumber(2)
  UTXOTxParams get utxoParams => $_getN(1);
  @$pb.TagNumber(2)
  set utxoParams(UTXOTxParams value) => $_setField(2, value);
  @$pb.TagNumber(2)
  $core.bool hasUtxoParams() => $_has(1);
  @$pb.TagNumber(2)
  void clearUtxoParams() => $_clearField(2);
  @$pb.TagNumber(2)
  UTXOTxParams ensureUtxoParams() => $_ensure(1);

  @$pb.TagNumber(3)
  $fixnum.Int64 get releaseAmount => $_getI64(2);
  @$pb.TagNumber(3)
  set releaseAmount($fixnum.Int64 value) => $_setInt64(2, value);
  @$pb.TagNumber(3)
  $core.bool hasReleaseAmount() => $_has(2);
  @$pb.TagNumber(3)
  void clearReleaseAmount() => $_clearField(3);

  @$pb.TagNumber(4)
  $core.String get releaseAddress => $_getSZ(3);
  @$pb.TagNumber(4)
  set releaseAddress($core.String value) => $_setString(3, value);
  @$pb.TagNumber(4)
  $core.bool hasReleaseAddress() => $_has(3);
  @$pb.TagNumber(4)
  void clearReleaseAddress() => $_clearField(4);

  @$pb.TagNumber(5)
  $core.String get escrowSource => $_getSZ(4);
  @$pb.TagNumber(5)
  set escrowSource($core.String value) => $_setString(4, value);
  @$pb.TagNumber(5)
  $core.bool hasEscrowSource() => $_has(4);
  @$pb.TagNumber(5)
  void clearEscrowSource() => $_clearField(5);

  @$pb.TagNumber(6)
  $core.String get originalEscrowHash => $_getSZ(5);
  @$pb.TagNumber(6)
  set originalEscrowHash($core.String value) => $_setString(5, value);
  @$pb.TagNumber(6)
  $core.bool hasOriginalEscrowHash() => $_has(5);
  @$pb.TagNumber(6)
  void clearOriginalEscrowHash() => $_clearField(6);
}

const $core.bool _omitFieldNames =
    $core.bool.fromEnvironment('protobuf.omit_field_names');
const $core.bool _omitMessageNames =
    $core.bool.fromEnvironment('protobuf.omit_message_names');
