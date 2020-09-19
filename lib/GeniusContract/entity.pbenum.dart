///
//  Generated code. Do not modify.
//  source: entity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

// ignore_for_file: UNDEFINED_SHOWN_NAME,UNUSED_SHOWN_NAME
import 'dart:core' as $core;
import 'package:protobuf/protobuf.dart' as $pb;

class TokenType extends $pb.ProtobufEnum {
  static const TokenType INVALID = TokenType._(0, 'INVALID');
  static const TokenType ETH = TokenType._(1, 'ETH');
  static const TokenType ERC20 = TokenType._(2, 'ERC20');

  static const $core.List<TokenType> values = <TokenType> [
    INVALID,
    ETH,
    ERC20,
  ];

  static final $core.Map<$core.int, TokenType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TokenType valueOf($core.int value) => _byValue[value];

  const TokenType._($core.int v, $core.String n) : super(v, n);
}

class TransferFunctionType extends $pb.ProtobufEnum {
  static const TransferFunctionType BOOLEAN_AND = TransferFunctionType._(0, 'BOOLEAN_AND');
  static const TransferFunctionType BOOLEAN_OR = TransferFunctionType._(1, 'BOOLEAN_OR');
  static const TransferFunctionType BOOLEAN_CIRCUIT = TransferFunctionType._(2, 'BOOLEAN_CIRCUIT');
  static const TransferFunctionType NUMERIC_ADD = TransferFunctionType._(3, 'NUMERIC_ADD');
  static const TransferFunctionType NUMERIC_MAX = TransferFunctionType._(4, 'NUMERIC_MAX');
  static const TransferFunctionType NUMERIC_MIN = TransferFunctionType._(5, 'NUMERIC_MIN');

  static const $core.List<TransferFunctionType> values = <TransferFunctionType> [
    BOOLEAN_AND,
    BOOLEAN_OR,
    BOOLEAN_CIRCUIT,
    NUMERIC_ADD,
    NUMERIC_MAX,
    NUMERIC_MIN,
  ];

  static final $core.Map<$core.int, TransferFunctionType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static TransferFunctionType valueOf($core.int value) => _byValue[value];

  const TransferFunctionType._($core.int v, $core.String n) : super(v, n);
}

class ConditionType extends $pb.ProtobufEnum {
  static const ConditionType HASH_LOCK = ConditionType._(0, 'HASH_LOCK');
  static const ConditionType DEPLOYED_CONTRACT = ConditionType._(1, 'DEPLOYED_CONTRACT');
  static const ConditionType VIRTUAL_CONTRACT = ConditionType._(2, 'VIRTUAL_CONTRACT');

  static const $core.List<ConditionType> values = <ConditionType> [
    HASH_LOCK,
    DEPLOYED_CONTRACT,
    VIRTUAL_CONTRACT,
  ];

  static final $core.Map<$core.int, ConditionType> _byValue = $pb.ProtobufEnum.initByValue(values);
  static ConditionType valueOf($core.int value) => _byValue[value];

  const ConditionType._($core.int v, $core.String n) : super(v, n);
}

