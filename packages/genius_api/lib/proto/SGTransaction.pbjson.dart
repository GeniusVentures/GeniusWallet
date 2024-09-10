//
//  Generated code. Do not modify.
//  source: SGTransaction.proto
//
// @dart = 2.12

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use dAGStructDescriptor instead')
const DAGStruct$json = {
  '1': 'DAGStruct',
  '2': [
    {'1': 'type', '3': 1, '4': 1, '5': 9, '10': 'type'},
    {'1': 'previous_hash', '3': 2, '4': 1, '5': 12, '10': 'previousHash'},
    {'1': 'source_addr', '3': 3, '4': 1, '5': 12, '10': 'sourceAddr'},
    {'1': 'nonce', '3': 4, '4': 1, '5': 4, '10': 'nonce'},
    {'1': 'timestamp', '3': 5, '4': 1, '5': 3, '10': 'timestamp'},
    {'1': 'uncle_hash', '3': 6, '4': 1, '5': 12, '10': 'uncleHash'},
    {'1': 'data_hash', '3': 7, '4': 1, '5': 12, '10': 'dataHash'},
  ],
};

/// Descriptor for `DAGStruct`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dAGStructDescriptor = $convert.base64Decode(
    'CglEQUdTdHJ1Y3QSEgoEdHlwZRgBIAEoCVIEdHlwZRIjCg1wcmV2aW91c19oYXNoGAIgASgMUg'
    'xwcmV2aW91c0hhc2gSHwoLc291cmNlX2FkZHIYAyABKAxSCnNvdXJjZUFkZHISFAoFbm9uY2UY'
    'BCABKARSBW5vbmNlEhwKCXRpbWVzdGFtcBgFIAEoA1IJdGltZXN0YW1wEh0KCnVuY2xlX2hhc2'
    'gYBiABKAxSCXVuY2xlSGFzaBIbCglkYXRhX2hhc2gYByABKAxSCGRhdGFIYXNo');

@$core.Deprecated('Use dAGWrapperDescriptor instead')
const DAGWrapper$json = {
  '1': 'DAGWrapper',
  '2': [
    {'1': 'dag_struct', '3': 1, '4': 1, '5': 11, '6': '.SGTransaction.DAGStruct', '10': 'dagStruct'},
  ],
};

/// Descriptor for `DAGWrapper`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List dAGWrapperDescriptor = $convert.base64Decode(
    'CgpEQUdXcmFwcGVyEjcKCmRhZ19zdHJ1Y3QYASABKAsyGC5TR1RyYW5zYWN0aW9uLkRBR1N0cn'
    'VjdFIJZGFnU3RydWN0');

@$core.Deprecated('Use transferUTXOInputDescriptor instead')
const TransferUTXOInput$json = {
  '1': 'TransferUTXOInput',
  '2': [
    {'1': 'tx_id_hash', '3': 1, '4': 1, '5': 12, '10': 'txIdHash'},
    {'1': 'output_index', '3': 2, '4': 1, '5': 13, '10': 'outputIndex'},
    {'1': 'signature', '3': 3, '4': 1, '5': 12, '10': 'signature'},
  ],
};

/// Descriptor for `TransferUTXOInput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferUTXOInputDescriptor = $convert.base64Decode(
    'ChFUcmFuc2ZlclVUWE9JbnB1dBIcCgp0eF9pZF9oYXNoGAEgASgMUgh0eElkSGFzaBIhCgxvdX'
    'RwdXRfaW5kZXgYAiABKA1SC291dHB1dEluZGV4EhwKCXNpZ25hdHVyZRgDIAEoDFIJc2lnbmF0'
    'dXJl');

@$core.Deprecated('Use transferOutputDescriptor instead')
const TransferOutput$json = {
  '1': 'TransferOutput',
  '2': [
    {'1': 'encrypted_amount', '3': 1, '4': 1, '5': 12, '10': 'encryptedAmount'},
    {'1': 'dest_addr', '3': 2, '4': 1, '5': 12, '10': 'destAddr'},
  ],
};

/// Descriptor for `TransferOutput`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferOutputDescriptor = $convert.base64Decode(
    'Cg5UcmFuc2Zlck91dHB1dBIpChBlbmNyeXB0ZWRfYW1vdW50GAEgASgMUg9lbmNyeXB0ZWRBbW'
    '91bnQSGwoJZGVzdF9hZGRyGAIgASgMUghkZXN0QWRkcg==');

@$core.Deprecated('Use uTXOTxParamsDescriptor instead')
const UTXOTxParams$json = {
  '1': 'UTXOTxParams',
  '2': [
    {'1': 'inputs', '3': 1, '4': 3, '5': 11, '6': '.SGTransaction.TransferUTXOInput', '10': 'inputs'},
    {'1': 'outputs', '3': 2, '4': 3, '5': 11, '6': '.SGTransaction.TransferOutput', '10': 'outputs'},
  ],
};

/// Descriptor for `UTXOTxParams`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List uTXOTxParamsDescriptor = $convert.base64Decode(
    'CgxVVFhPVHhQYXJhbXMSOAoGaW5wdXRzGAEgAygLMiAuU0dUcmFuc2FjdGlvbi5UcmFuc2Zlcl'
    'VUWE9JbnB1dFIGaW5wdXRzEjcKB291dHB1dHMYAiADKAsyHS5TR1RyYW5zYWN0aW9uLlRyYW5z'
    'ZmVyT3V0cHV0UgdvdXRwdXRz');

@$core.Deprecated('Use transferTxDescriptor instead')
const TransferTx$json = {
  '1': 'TransferTx',
  '2': [
    {'1': 'dag_struct', '3': 1, '4': 1, '5': 11, '6': '.SGTransaction.DAGStruct', '10': 'dagStruct'},
    {'1': 'token_id', '3': 2, '4': 1, '5': 4, '10': 'tokenId'},
    {'1': 'utxo_params', '3': 3, '4': 1, '5': 11, '6': '.SGTransaction.UTXOTxParams', '10': 'utxoParams'},
  ],
};

/// Descriptor for `TransferTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List transferTxDescriptor = $convert.base64Decode(
    'CgpUcmFuc2ZlclR4EjcKCmRhZ19zdHJ1Y3QYASABKAsyGC5TR1RyYW5zYWN0aW9uLkRBR1N0cn'
    'VjdFIJZGFnU3RydWN0EhkKCHRva2VuX2lkGAIgASgEUgd0b2tlbklkEjwKC3V0eG9fcGFyYW1z'
    'GAMgASgLMhsuU0dUcmFuc2FjdGlvbi5VVFhPVHhQYXJhbXNSCnV0eG9QYXJhbXM=');

@$core.Deprecated('Use processingTxDescriptor instead')
const ProcessingTx$json = {
  '1': 'ProcessingTx',
  '2': [
    {'1': 'dag_struct', '3': 1, '4': 1, '5': 11, '6': '.SGTransaction.DAGStruct', '10': 'dagStruct'},
    {'1': 'mpc_magic_key', '3': 2, '4': 1, '5': 4, '10': 'mpcMagicKey'},
    {'1': 'offset', '3': 3, '4': 1, '5': 4, '10': 'offset'},
    {'1': 'job_cid', '3': 4, '4': 1, '5': 9, '10': 'jobCid'},
    {'1': 'subtask_cid', '3': 5, '4': 1, '5': 9, '10': 'subtaskCid'},
  ],
};

/// Descriptor for `ProcessingTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List processingTxDescriptor = $convert.base64Decode(
    'CgxQcm9jZXNzaW5nVHgSNwoKZGFnX3N0cnVjdBgBIAEoCzIYLlNHVHJhbnNhY3Rpb24uREFHU3'
    'RydWN0UglkYWdTdHJ1Y3QSIgoNbXBjX21hZ2ljX2tleRgCIAEoBFILbXBjTWFnaWNLZXkSFgoG'
    'b2Zmc2V0GAMgASgEUgZvZmZzZXQSFwoHam9iX2NpZBgEIAEoCVIGam9iQ2lkEh8KC3N1YnRhc2'
    'tfY2lkGAUgASgJUgpzdWJ0YXNrQ2lk');

@$core.Deprecated('Use mintTxDescriptor instead')
const MintTx$json = {
  '1': 'MintTx',
  '2': [
    {'1': 'dag_struct', '3': 1, '4': 1, '5': 11, '6': '.SGTransaction.DAGStruct', '10': 'dagStruct'},
    {'1': 'amount', '3': 2, '4': 1, '5': 4, '10': 'amount'},
  ],
};

/// Descriptor for `MintTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List mintTxDescriptor = $convert.base64Decode(
    'CgZNaW50VHgSNwoKZGFnX3N0cnVjdBgBIAEoCzIYLlNHVHJhbnNhY3Rpb24uREFHU3RydWN0Ug'
    'lkYWdTdHJ1Y3QSFgoGYW1vdW50GAIgASgEUgZhbW91bnQ=');

@$core.Deprecated('Use escrowTxDescriptor instead')
const EscrowTx$json = {
  '1': 'EscrowTx',
  '2': [
    {'1': 'dag_struct', '3': 1, '4': 1, '5': 11, '6': '.SGTransaction.DAGStruct', '10': 'dagStruct'},
    {'1': 'utxo_params', '3': 2, '4': 1, '5': 11, '6': '.SGTransaction.UTXOTxParams', '10': 'utxoParams'},
    {'1': 'num_chunks', '3': 3, '4': 1, '5': 4, '10': 'numChunks'},
    {'1': 'dev_addr', '3': 4, '4': 1, '5': 12, '10': 'devAddr'},
    {'1': 'dev_cut', '3': 5, '4': 1, '5': 2, '10': 'devCut'},
  ],
};

/// Descriptor for `EscrowTx`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List escrowTxDescriptor = $convert.base64Decode(
    'CghFc2Nyb3dUeBI3CgpkYWdfc3RydWN0GAEgASgLMhguU0dUcmFuc2FjdGlvbi5EQUdTdHJ1Y3'
    'RSCWRhZ1N0cnVjdBI8Cgt1dHhvX3BhcmFtcxgCIAEoCzIbLlNHVHJhbnNhY3Rpb24uVVRYT1R4'
    'UGFyYW1zUgp1dHhvUGFyYW1zEh0KCm51bV9jaHVua3MYAyABKARSCW51bUNodW5rcxIZCghkZX'
    'ZfYWRkchgEIAEoDFIHZGV2QWRkchIXCgdkZXZfY3V0GAUgASgCUgZkZXZDdXQ=');

