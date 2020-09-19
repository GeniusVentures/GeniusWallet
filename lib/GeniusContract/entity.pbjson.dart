///
//  Generated code. Do not modify.
//  source: entity.proto
//
// @dart = 2.3
// ignore_for_file: camel_case_types,non_constant_identifier_names,library_prefixes,unused_import,unused_shown_name,return_of_invalid_type

const TokenType$json = const {
  '1': 'TokenType',
  '2': const [
    const {'1': 'INVALID', '2': 0},
    const {'1': 'ETH', '2': 1},
    const {'1': 'ERC20', '2': 2},
  ],
};

const TransferFunctionType$json = const {
  '1': 'TransferFunctionType',
  '2': const [
    const {'1': 'BOOLEAN_AND', '2': 0},
    const {'1': 'BOOLEAN_OR', '2': 1},
    const {'1': 'BOOLEAN_CIRCUIT', '2': 2},
    const {'1': 'NUMERIC_ADD', '2': 3},
    const {'1': 'NUMERIC_MAX', '2': 4},
    const {'1': 'NUMERIC_MIN', '2': 5},
  ],
};

const ConditionType$json = const {
  '1': 'ConditionType',
  '2': const [
    const {'1': 'HASH_LOCK', '2': 0},
    const {'1': 'DEPLOYED_CONTRACT', '2': 1},
    const {'1': 'VIRTUAL_CONTRACT', '2': 2},
  ],
};

const AccountAmtPair$json = const {
  '1': 'AccountAmtPair',
  '2': const [
    const {'1': 'account', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'account'},
    const {'1': 'amt', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'amt'},
  ],
};

const TokenInfo$json = const {
  '1': 'TokenInfo',
  '2': const [
    const {'1': 'token_type', '3': 1, '4': 1, '5': 14, '6': '.entity.TokenType', '10': 'tokenType'},
    const {'1': 'token_address', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'tokenAddress'},
  ],
};

const TokenDistribution$json = const {
  '1': 'TokenDistribution',
  '2': const [
    const {'1': 'token', '3': 1, '4': 1, '5': 11, '6': '.entity.TokenInfo', '10': 'token'},
    const {'1': 'distribution', '3': 2, '4': 3, '5': 11, '6': '.entity.AccountAmtPair', '10': 'distribution'},
  ],
};

const TokenTransfer$json = const {
  '1': 'TokenTransfer',
  '2': const [
    const {'1': 'token', '3': 1, '4': 1, '5': 11, '6': '.entity.TokenInfo', '10': 'token'},
    const {'1': 'receiver', '3': 2, '4': 1, '5': 11, '6': '.entity.AccountAmtPair', '10': 'receiver'},
  ],
};

const SimplexPaymentChannel$json = const {
  '1': 'SimplexPaymentChannel',
  '2': const [
    const {'1': 'channel_id', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'channelId'},
    const {'1': 'peer_from', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'peerFrom'},
    const {'1': 'seq_num', '3': 3, '4': 1, '5': 4, '8': const {}, '10': 'seqNum'},
    const {'1': 'transfer_to_peer', '3': 4, '4': 1, '5': 11, '6': '.entity.TokenTransfer', '10': 'transferToPeer'},
    const {'1': 'pending_pay_ids', '3': 5, '4': 1, '5': 11, '6': '.entity.PayIdList', '10': 'pendingPayIds'},
    const {'1': 'last_pay_resolve_deadline', '3': 6, '4': 1, '5': 4, '8': const {}, '10': 'lastPayResolveDeadline'},
    const {'1': 'total_pending_amount', '3': 7, '4': 1, '5': 12, '8': const {}, '10': 'totalPendingAmount'},
  ],
};

const PayIdList$json = const {
  '1': 'PayIdList',
  '2': const [
    const {'1': 'pay_ids', '3': 1, '4': 3, '5': 12, '8': const {}, '10': 'payIds'},
    const {'1': 'next_list_hash', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'nextListHash'},
  ],
};

const TransferFunction$json = const {
  '1': 'TransferFunction',
  '2': const [
    const {'1': 'logic_type', '3': 1, '4': 1, '5': 14, '6': '.entity.TransferFunctionType', '10': 'logicType'},
    const {'1': 'max_transfer', '3': 2, '4': 1, '5': 11, '6': '.entity.TokenTransfer', '10': 'maxTransfer'},
  ],
};

const ConditionalPay$json = const {
  '1': 'ConditionalPay',
  '2': const [
    const {
      '1': 'pay_timestamp',
      '3': 1,
      '4': 1,
      '5': 4,
      '8': const {'6': 1},
      '10': 'payTimestamp',
    },
    const {'1': 'src', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'src'},
    const {'1': 'dest', '3': 3, '4': 1, '5': 12, '8': const {}, '10': 'dest'},
    const {'1': 'conditions', '3': 4, '4': 3, '5': 11, '6': '.entity.Condition', '10': 'conditions'},
    const {'1': 'transfer_func', '3': 5, '4': 1, '5': 11, '6': '.entity.TransferFunction', '10': 'transferFunc'},
    const {'1': 'resolve_deadline', '3': 6, '4': 1, '5': 4, '8': const {}, '10': 'resolveDeadline'},
    const {'1': 'resolve_timeout', '3': 7, '4': 1, '5': 4, '8': const {}, '10': 'resolveTimeout'},
    const {'1': 'pay_resolver', '3': 8, '4': 1, '5': 12, '8': const {}, '10': 'payResolver'},
  ],
};

const CondPayResult$json = const {
  '1': 'CondPayResult',
  '2': const [
    const {'1': 'cond_pay', '3': 1, '4': 1, '5': 12, '10': 'condPay'},
    const {'1': 'amount', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'amount'},
  ],
};

const VouchedCondPayResult$json = const {
  '1': 'VouchedCondPayResult',
  '2': const [
    const {'1': 'cond_pay_result', '3': 1, '4': 1, '5': 12, '10': 'condPayResult'},
    const {'1': 'sig_of_src', '3': 2, '4': 1, '5': 12, '10': 'sigOfSrc'},
    const {'1': 'sig_of_dest', '3': 3, '4': 1, '5': 12, '10': 'sigOfDest'},
  ],
};

const Condition$json = const {
  '1': 'Condition',
  '2': const [
    const {'1': 'condition_type', '3': 1, '4': 1, '5': 14, '6': '.entity.ConditionType', '10': 'conditionType'},
    const {'1': 'hash_lock', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'hashLock'},
    const {'1': 'deployed_contract_address', '3': 3, '4': 1, '5': 12, '8': const {}, '10': 'deployedContractAddress'},
    const {'1': 'virtual_contract_address', '3': 4, '4': 1, '5': 12, '8': const {}, '10': 'virtualContractAddress'},
    const {'1': 'args_query_finalization', '3': 5, '4': 1, '5': 12, '10': 'argsQueryFinalization'},
    const {'1': 'args_query_outcome', '3': 6, '4': 1, '5': 12, '10': 'argsQueryOutcome'},
  ],
};

const CooperativeWithdrawInfo$json = const {
  '1': 'CooperativeWithdrawInfo',
  '2': const [
    const {'1': 'channel_id', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'channelId'},
    const {'1': 'seq_num', '3': 2, '4': 1, '5': 4, '8': const {}, '10': 'seqNum'},
    const {'1': 'withdraw', '3': 3, '4': 1, '5': 11, '6': '.entity.AccountAmtPair', '10': 'withdraw'},
    const {'1': 'withdraw_deadline', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'withdrawDeadline'},
    const {'1': 'recipient_channel_id', '3': 5, '4': 1, '5': 12, '8': const {}, '10': 'recipientChannelId'},
  ],
};

const PaymentChannelInitializer$json = const {
  '1': 'PaymentChannelInitializer',
  '2': const [
    const {'1': 'init_distribution', '3': 1, '4': 1, '5': 11, '6': '.entity.TokenDistribution', '10': 'initDistribution'},
    const {'1': 'open_deadline', '3': 2, '4': 1, '5': 4, '8': const {}, '10': 'openDeadline'},
    const {'1': 'dispute_timeout', '3': 3, '4': 1, '5': 4, '8': const {}, '10': 'disputeTimeout'},
    const {'1': 'msg_value_receiver', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'msgValueReceiver'},
  ],
};

const CooperativeSettleInfo$json = const {
  '1': 'CooperativeSettleInfo',
  '2': const [
    const {'1': 'channel_id', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'channelId'},
    const {'1': 'seq_num', '3': 2, '4': 1, '5': 4, '8': const {}, '10': 'seqNum'},
    const {'1': 'settle_balance', '3': 3, '4': 3, '5': 11, '6': '.entity.AccountAmtPair', '10': 'settleBalance'},
    const {'1': 'settle_deadline', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'settleDeadline'},
  ],
};

const ChannelMigrationInfo$json = const {
  '1': 'ChannelMigrationInfo',
  '2': const [
    const {'1': 'channel_id', '3': 1, '4': 1, '5': 12, '8': const {}, '10': 'channelId'},
    const {'1': 'from_ledger_address', '3': 2, '4': 1, '5': 12, '8': const {}, '10': 'fromLedgerAddress'},
    const {'1': 'to_ledger_address', '3': 3, '4': 1, '5': 12, '8': const {}, '10': 'toLedgerAddress'},
    const {'1': 'migration_deadline', '3': 4, '4': 1, '5': 4, '8': const {}, '10': 'migrationDeadline'},
  ],
};

