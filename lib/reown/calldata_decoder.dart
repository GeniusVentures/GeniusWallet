import 'dart:typed_data';

import 'package:genius_api/models/coin.dart';
// EthereumAddress comes from here rather than from `wallet` directly: that
// package is genius_api's dependency, not this one's.
import 'package:genius_api/web3/web3.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/squid_router/swap_allowance.dart';
// Narrowed with `show`: reown re-exports web3dart wholesale, and a bare
// import would make this file look like it read its ABI types from a
// WalletConnect package.
import 'package:reown_walletkit/reown_walletkit.dart' show Errors, JsonRpcError;
import 'package:web3dart/web3dart.dart';

/// `transfer(address,uint256)` and `approve(address,uint256)`. Typed by hand
/// for readability; a unit test pins each against the selector the ERC-20 ABI
/// derives, so a typo cannot quietly mean "decode nothing, ever".
const kErc20TransferSelector = '0xa9059cbb';
const kErc20ApproveSelector = '0x095ea7b3';

/// The entry point Squid's router is called through. Taken from a response
/// recorded off the live API, which is also the only evidence behind the one
/// allow-list entry below.
const kSquidSwapSelector = '0x58181a80';

/// Routers this wallet will name on screen, by chain and then by lowercased
/// address. An entry here is a claim the user reads as vetting, so only a
/// pair proven by a recorded response from that router is listed.
const Map<int, Map<String, String>> kKnownRouters = {
  8453: {'0xce16f69375520ab01377ce7b88f5ba8c48f8d666': 'Squid'},
};

/// The name for [to] on [chainId], or null when that exact pair is not
/// listed. `const` by construction: fetching this at runtime would put a
/// network round trip on the signing path.
String? knownRouterName(int? chainId, String? to) {
  if (chainId == null || to == null) {
    return null;
  }
  // A lowercased local copy; the caller's own string is never rewritten.
  return kKnownRouters[chainId]?[to.toLowerCase()];
}

/// A selector plus the two 32-byte words `transfer` and `approve` both take.
const _minimumCalldataBytes = 68;

/// Decimals beyond this are not a real token's, so the amount is unreadable
/// rather than very small.
const _maximumTokenDecimals = 36;

/// The two arguments `transfer` and `approve` share, and the two leading
/// words a router swap happens to carry in the same shape.
class DecodedAddressAmount {
  const DecodedAddressAmount({
    required this.counterparty,
    required this.amount,
  });

  /// The recipient of a transfer, the spender of an approve, or the token
  /// going into a swap.
  final EthereumAddress counterparty;

  /// Raw base units, meaningless until paired with the token's own decimals.
  final BigInt amount;
}

/// Half of 2^256. It catches the max-uint256 sentinel exactly and the
/// off-by-a-little variants dApp SDKs emit, and sits far above any real token
/// supply -- so no `totalSupply()` call is needed to decide.
final BigInt kUnlimitedApprovalThreshold = BigInt.two.pow(255);

/// The signing methods a dApp may send. None of them carries a transaction
/// object, and this wallet has no renderer for what they do carry.
const _kSignatureMethods = {
  'personal_sign',
  'eth_signTypedData',
  'eth_signTypedData_v4',
};

/// What kind of request arrived, decided before anything is cast.
enum DappRequestKind {
  /// Carries a transaction object this wallet can summarise.
  transaction,

  /// A signature over a payload this wallet cannot yet display.
  unreadableSignature,

  /// Nothing here knows how to answer this one.
  unsupportedMethod,
}

/// The transaction object a request carries, or null for every other shape.
/// Returns the caller's own map, never a copy: the signer re-reads this same
/// instance, so a copy would be one more place the bytes could drift.
Map<String, dynamic>? transactionParam(dynamic params) {
  if (params is! List || params.isEmpty) {
    return null;
  }
  final first = params.first;
  return first is Map<String, dynamic> ? first : null;
}

/// Reads the method and the SHAPE of the first parameter without casting
/// either. A signing method carries a String where `eth_sendTransaction`
/// carries a map, and casting before checking is what left callers hanging.
DappRequestKind classifyDappRequest(String method, dynamic params) {
  if (_kSignatureMethods.contains(method)) {
    return DappRequestKind.unreadableSignature;
  }
  if (method == 'eth_sendTransaction' && transactionParam(params) != null) {
    return DappRequestKind.transaction;
  }
  return DappRequestKind.unsupportedMethod;
}

/// The error a rejection must carry. `Errors.USER_REJECTED` is the lookup
/// key, not the code; read as a number it is null, and the serializer then
/// drops the field, leaving a rejection nobody can act on.
JsonRpcError userRejectedError() {
  final rejected = Errors.getSdkError(Errors.USER_REJECTED);
  return JsonRpcError(code: rejected.code, message: rejected.message);
}

/// What a pending dApp transaction can honestly be said to do.
enum DappCallKind {
  nativeSend,
  tokenTransfer,
  tokenApprove,

  /// A swap through an allow-listed router, read on its input side. What
  /// comes back out is not in the transaction and is never guessed at.
  routerSwap,

  /// A token call the wallet cannot put a unit on, or one that also moves
  /// native currency. Its figures are raw base units.
  unverifiedToken,
  unknownCall,
}

/// A display-ready reading of one transaction; a null field is one the drawer
/// has no right to state. [recipient]/[amount] describe a transfer and
/// [spender]/[allowance] an approve, and are never both set.
class DappCallSummary {
  const DappCallSummary(
    this.kind, {
    this.recipient,
    this.amount,
    this.symbol,
    this.spender,
    this.allowance,
    this.tokenContract,
    this.tokenIn,
    this.routerName,
    this.nativeAmount,
    this.selector,
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

  /// The token a swap spends, which lives in the calldata rather than in the
  /// `to` field. Never the token a swap returns -- that is not readable here.
  final String? tokenIn;

  /// The allow-listed name of the contract, when it has one. It names the
  /// contract only; it is not a statement that the call itself is safe.
  final String? routerName;

  /// Native currency moving alongside the token call, when any does.
  final String? nativeAmount;

  /// The four bytes naming the function of a call that could not be read.
  final String? selector;

  /// The allowance is at or above [kUnlimitedApprovalThreshold].
  final bool isUnlimitedAllowance;

  /// An approve that sets the allowance to nothing: it takes a permission
  /// away rather than granting one, and the copy must say which.
  bool get isRevocation => spender != null && allowance == '0';
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

/// The token and amount going INTO a router swap. Only the two leading words
/// are read, and only behind the selector gate above: on any other payload
/// those offsets hold something else entirely, so null is the honest answer.
DecodedAddressAmount? tryDecodeSwapInput(String? data) =>
    _tryDecodeAddressAmount(data, kSquidSwapSelector);

/// The native currency this transaction moves, or null when the value cannot
/// be read at all -- an unreadable value is not a zero value, and there is no
/// honest figure to put beside the token one.
BigInt? _nativeValue(Object? value) {
  if (value == null) {
    return BigInt.zero;
  }
  if (value is! String || !value.startsWith('0x')) {
    return null;
  }
  final digits = value.substring(2);
  if (digits.isEmpty) {
    return BigInt.zero;
  }
  return BigInt.tryParse(digits, radix: 16);
}

/// The unit to file a transaction under. A token call is filed under its
/// token: by symbol where the wallet knows one, and by contract address where
/// it does not, because an invented ticker outlives the drawer that showed it.
String receiptSymbol(DappCallSummary summary, {required String nativeSymbol}) {
  switch (summary.kind) {
    case DappCallKind.tokenTransfer:
    case DappCallKind.tokenApprove:
      return summary.symbol ?? nativeSymbol;
    case DappCallKind.unverifiedToken:
      return summary.tokenContract ?? nativeSymbol;
    // A swap is filed under what it spends: the destination is not readable,
    // so there is nothing else true to write down.
    case DappCallKind.routerSwap:
      return summary.symbol ?? summary.tokenIn ?? nativeSymbol;
    case DappCallKind.nativeSend:
    case DappCallKind.unknownCall:
      return nativeSymbol;
  }
}

/// True only for the calldata of a plain send: absent, or `0x` with nothing
/// behind it. Every other payload is a contract call, readable or not.
bool _isPlainSend(Object? data) {
  if (data == null) {
    return true;
  }
  if (data is! String) {
    return false;
  }
  final trimmed = data.trim();
  return trimmed.isEmpty || trimmed.toLowerCase() == '0x';
}

/// The four bytes naming the function, or null when the payload is not hex or
/// is too short to carry one.
String? _selectorOf(String? data) {
  if (data == null) {
    return null;
  }
  try {
    final bytes = hexToBytes(data);
    if (bytes.length < 4) {
      return null;
    }
    return bytesToHex(bytes.sublist(0, 4), include0x: true);
  } catch (_) {
    return null;
  }
}

/// Everything still sayable about a call that could not be read: the contract
/// it is addressed to, the native value it carries, and the selector. No
/// counterparty and no amount, because none was read.
DappCallSummary _unknownCall(
  String? contract,
  String? data,
  BigInt? native,
  String? routerName,
) => DappCallSummary(
  DappCallKind.unknownCall,
  tokenContract: contract,
  routerName: routerName,
  nativeAmount: native == null ? null : formatEth(native.toString()),
  selector: _selectorOf(data),
);

/// A token the wallet holds AND can put a unit on. Absent means the figure
/// stays in base units -- eighteen decimals is never assumed for it.
class _ResolvedToken {
  const _ResolvedToken(this.symbol, this.decimals);

  final String symbol;
  final int decimals;
}

/// The wallet's own reading of [address], or null when it has none it can
/// vouch for. A wrong decimals guess renders a confident wrong amount, and an
/// amount with no unit beside it is a number nobody can act on.
_ResolvedToken? _resolveToken(List<Coin> coins, String address) {
  // A lowercased local copy; Dart strings are immutable, so any map the
  // address came out of keeps its own value untouched.
  final target = address.toLowerCase();
  for (final coin in coins) {
    if (coin.address?.toLowerCase() != target) {
      continue;
    }
    final decimals = int.tryParse(coin.decimals ?? '');
    final symbol = coin.symbol?.trim() ?? '';
    if (decimals == null ||
        decimals < 0 ||
        decimals > _maximumTokenDecimals ||
        symbol.isEmpty) {
      return null;
    }
    return _ResolvedToken(symbol, decimals);
  }
  return null;
}

/// Reads [tx] without writing to it. The same map instance is handed to the
/// signer by reference, so a byte written here is a byte the user never saw
/// and never agreed to.
DappCallSummary summarizeTransaction(
  Map<String, dynamic> tx, {
  required List<Coin> coins,
  int? chainId,
  String? nativeSymbol,
}) {
  final rawData = tx['data'];
  final data = rawData is String ? rawData : null;
  final contract = tx['to'] is String ? tx['to'] as String : null;
  final native = _nativeValue(tx['value']);
  final routerName = knownRouterName(chainId, contract);

  final transfer = tryDecodeErc20Transfer(data);
  final decoded = transfer ?? tryDecodeErc20Approve(data);
  if (decoded == null) {
    // Calldata nobody could read is not a plain send. Saying so would put the
    // one sentence this transaction is certainly not on the last screen
    // before a signature.
    if (_isPlainSend(rawData)) {
      return const DappCallSummary(DappCallKind.nativeSend);
    }
    // Only a listed router earns a look at those fixed offsets, and only
    // behind the selector gate. An unrecognised selector on a listed router
    // falls through here too: a confident mislabel of a swap is worse than
    // saying the call cannot be read.
    final swap = routerName == null ? null : tryDecodeSwapInput(data);
    if (swap == null || native == null) {
      return _unknownCall(contract, data, native, routerName);
    }
    final tokenIn = swap.counterparty.eip55With0x;
    // A swap that spends the chain's own coin names it with the 0xEeee…
    // sentinel and carries the same amount in `value`. That is one spend,
    // not a token plus native currency, and the sentinel is not an address
    // anyone should be shown. If the two figures disagree, both stay.
    if (isNativeToken(tokenIn) && nativeSymbol != null) {
      return DappCallSummary(
        DappCallKind.routerSwap,
        routerName: routerName,
        tokenContract: contract,
        amount: formatEth(swap.amount.toString()),
        symbol: nativeSymbol,
        nativeAmount: native == swap.amount || native == BigInt.zero
            ? null
            : formatEth(native.toString()),
      );
    }
    final inputToken = _resolveToken(coins, tokenIn);
    return DappCallSummary(
      DappCallKind.routerSwap,
      routerName: routerName,
      tokenContract: contract,
      tokenIn: tokenIn,
      amount: inputToken == null
          ? swap.amount.toString()
          : formatTokenAmount(swap.amount, inputToken.decimals),
      symbol: inputToken?.symbol,
      nativeAmount: native == BigInt.zero ? null : formatEth(native.toString()),
    );
  }
  final isApprove = transfer == null;

  if (contract == null || native == null) {
    return _unknownCall(contract, data, native, routerName);
  }

  final token = _resolveToken(coins, contract);
  final counterparty = decoded.counterparty.eip55With0x;
  // A call that also moves native currency keeps that figure alongside the
  // token one, whatever else is known: neither may be summarised away.
  final nativeAmount = native == BigInt.zero
      ? null
      : formatEth(native.toString());

  // ERC-721 approve(address,uint256) shares the ERC-20 selector, and the
  // second word is then a token ID, not an allowance. Only a contract this
  // wallet knows as a fungible token earns that reading; any other approve
  // is a call that could not be read, warned about as such.
  if (token == null && isApprove) {
    return _unknownCall(contract, data, native, routerName);
  }

  // Base units and no unit is the honest form for a token this wallet cannot
  // vouch for. Only a transfer reaches here: its selector has no ERC-721
  // twin, so the second word is an amount.
  if (token == null) {
    return DappCallSummary(
      DappCallKind.unverifiedToken,
      recipient: counterparty,
      amount: decoded.amount.toString(),
      tokenContract: contract,
      nativeAmount: nativeAmount,
    );
  }

  if (isApprove) {
    return DappCallSummary(
      DappCallKind.tokenApprove,
      spender: counterparty,
      allowance: formatTokenAmount(decoded.amount, token.decimals),
      symbol: token.symbol,
      tokenContract: contract,
      nativeAmount: nativeAmount,
      isUnlimitedAllowance: decoded.amount >= kUnlimitedApprovalThreshold,
    );
  }

  return DappCallSummary(
    DappCallKind.tokenTransfer,
    recipient: counterparty,
    amount: formatTokenAmount(decoded.amount, token.decimals),
    symbol: token.symbol,
    tokenContract: contract,
    nativeAmount: nativeAmount,
  );
}
