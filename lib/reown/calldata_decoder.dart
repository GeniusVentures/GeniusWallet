import 'dart:typed_data';

import 'package:genius_api/models/coin.dart';
// EthereumAddress comes from here rather than from `wallet` directly: that
// package is genius_api's dependency, not this one's.
import 'package:genius_api/web3/web3.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:web3dart/web3dart.dart';

/// `transfer(address,uint256)` and `approve(address,uint256)`. Typed by hand
/// for readability; a unit test pins each against the selector the ERC-20 ABI
/// derives, so a typo cannot quietly mean "decode nothing, ever".
const kErc20TransferSelector = '0xa9059cbb';
const kErc20ApproveSelector = '0x095ea7b3';

/// A selector plus the two 32-byte words `transfer` and `approve` both take.
const _minimumCalldataBytes = 68;

/// Decimals beyond this are not a real token's, so the amount is unreadable
/// rather than very small.
const _maximumTokenDecimals = 36;

/// The two arguments `transfer` and `approve` share.
class DecodedAddressAmount {
  const DecodedAddressAmount({
    required this.counterparty,
    required this.amount,
  });

  /// The recipient of a transfer, or the spender of an approve.
  final EthereumAddress counterparty;

  /// Raw base units, meaningless until paired with the token's own decimals.
  final BigInt amount;
}

/// Half of 2^256. It catches the max-uint256 sentinel exactly and the
/// off-by-a-little variants dApp SDKs emit, and sits far above any real token
/// supply -- so no `totalSupply()` call is needed to decide.
final BigInt kUnlimitedApprovalThreshold = BigInt.two.pow(255);

/// What a pending dApp transaction can honestly be said to do.
enum DappCallKind { nativeSend, tokenTransfer, tokenApprove, unknownCall }

/// A display-ready reading of one transaction. A null field is one the drawer
/// has no right to state.
///
/// [recipient]/[amount] describe a transfer and [spender]/[allowance] an
/// approve; they are never both set, which is what keeps an approval out of
/// the send body.
class DappCallSummary {
  const DappCallSummary(
    this.kind, {
    this.recipient,
    this.amount,
    this.symbol,
    this.spender,
    this.allowance,
    this.tokenContract,
    this.isUnlimitedAllowance = false,
  });

  final DappCallKind kind;
  final String? recipient;
  final String? amount;
  final String? symbol;
  final String? spender;
  final String? allowance;

  /// The contract the call is addressed to, exactly as the transaction spells
  /// it.
  final String? tokenContract;

  /// The allowance is at or above [kUnlimitedApprovalThreshold].
  final bool isUnlimitedAllowance;
}

/// Returns null on anything that is not exactly this call: unreadable hex,
/// too few bytes, a different selector, or a decode that throws. The caller
/// treats null as "cannot be read", never as an empty result.
DecodedAddressAmount? _tryDecodeAddressAmount(
  String? data,
  String selectorHex,
) {
  if (data == null) {
    return null;
  }
  final Uint8List bytes;
  try {
    bytes = hexToBytes(data);
  } catch (_) {
    return null;
  }
  if (bytes.length < _minimumCalldataBytes) {
    return null;
  }
  if (bytesToHex(bytes.sublist(0, 4), include0x: true) != selectorHex) {
    return null;
  }
  try {
    const tuple = TupleType([AddressType(), UintType()]);
    // The offset steps over the selector inside the same buffer, so the
    // calldata is never copied or re-sliced to be read.
    final result = tuple.decode(bytes.buffer, 4);
    return DecodedAddressAmount(
      counterparty: result.data[0] as EthereumAddress,
      amount: result.data[1] as BigInt,
    );
  } catch (_) {
    return null;
  }
}

DecodedAddressAmount? tryDecodeErc20Transfer(String? data) =>
    _tryDecodeAddressAmount(data, kErc20TransferSelector);

DecodedAddressAmount? tryDecodeErc20Approve(String? data) =>
    _tryDecodeAddressAmount(data, kErc20ApproveSelector);

/// True only when the transaction provably moves no native currency. An
/// unreadable value is not a zero value.
bool _movesNoNativeValue(Object? value) {
  if (value == null) {
    return true;
  }
  if (value is! String || !value.startsWith('0x')) {
    return false;
  }
  final digits = value.substring(2);
  if (digits.isEmpty) {
    return true;
  }
  return BigInt.tryParse(digits, radix: 16) == BigInt.zero;
}

/// Reads [tx] without writing to it. The same map instance is handed to the
/// signer by reference, so a byte written here is a byte the user never saw
/// and never agreed to.
DappCallSummary summarizeTransaction(
  Map<String, dynamic> tx, {
  required List<Coin> coins,
}) {
  final data = tx['data'] is String ? tx['data'] as String : null;
  final transfer = tryDecodeErc20Transfer(data);
  final decoded = transfer ?? tryDecodeErc20Approve(data);
  if (decoded == null) {
    return const DappCallSummary(DappCallKind.nativeSend);
  }
  final isApprove = transfer == null;

  // Both a token and native currency would leave the wallet, and the send
  // rows can only state one figure.
  if (!_movesNoNativeValue(tx['value'])) {
    return const DappCallSummary(DappCallKind.unknownCall);
  }

  final contract = tx['to'];
  if (contract is! String) {
    return const DappCallSummary(DappCallKind.unknownCall);
  }
  // A lowercased local copy; Dart strings are immutable, so the map keeps its
  // own value untouched.
  final target = contract.toLowerCase();

  Coin? token;
  for (final coin in coins) {
    if (coin.address?.toLowerCase() == target) {
      token = coin;
      break;
    }
  }
  if (token == null) {
    return const DappCallSummary(DappCallKind.unknownCall);
  }

  // Never fall back to eighteen. A wrong decimals guess renders a confident
  // wrong amount, which is worse than admitting the token is unreadable.
  final decimals = int.tryParse(token.decimals ?? '');
  if (decimals == null || decimals < 0 || decimals > _maximumTokenDecimals) {
    return const DappCallSummary(DappCallKind.unknownCall);
  }

  // An amount with no unit beside it is a number a user cannot act on.
  final symbol = token.symbol?.trim() ?? '';
  if (symbol.isEmpty) {
    return const DappCallSummary(DappCallKind.unknownCall);
  }

  final counterparty = decoded.counterparty.eip55With0x;
  if (isApprove) {
    return DappCallSummary(
      DappCallKind.tokenApprove,
      spender: counterparty,
      allowance: formatTokenAmount(decoded.amount, decimals),
      symbol: symbol,
      tokenContract: contract,
      isUnlimitedAllowance: decoded.amount >= kUnlimitedApprovalThreshold,
    );
  }

  return DappCallSummary(
    DappCallKind.tokenTransfer,
    recipient: counterparty,
    amount: formatTokenAmount(decoded.amount, decimals),
    symbol: symbol,
    tokenContract: contract,
  );
}
