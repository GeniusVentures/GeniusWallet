import 'dart:typed_data';

import 'package:genius_api/models/transaction.dart' show TransactionStatus;
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

import 'web3.dart';

/// A priced EIP-1559 send: everything the signer needs, nothing it has to
/// default on its own.
class SendFee {
  const SendFee({
    required this.maxFeePerGas,
    required this.maxPriorityFeePerGas,
    required this.gasLimit,
  });

  final BigInt maxFeePerGas;
  final BigInt maxPriorityFeePerGas;
  final BigInt gasLimit;

  /// The most this send can cost, in native wei: `maxFeePerGas * gasLimit`.
  BigInt get maxCost => maxFeePerGas * gasLimit;
}

/// One fee read's two market fields -- what [buildSendTx] and the signer
/// actually consume, whichever source produced them.
typedef FeePerGas = ({BigInt maxFeePerGas, BigInt maxPriorityFeePerGas});

/// Neither the EIP-1559 fee market nor a legacy gas price could be read. A
/// send must never reach the signer with a zero fee, so this
/// blocks the review step instead of letting a `0x0` field through.
class SendFeeUnavailable implements Exception {
  const SendFeeUnavailable([
    this.message = "Couldn't estimate the network fee.",
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Picks the fee to sign with: the EIP-1559 market answer when it is usable,
/// a legacy gas price (used for both fields) when it is not. A chain whose
/// RPC gives neither cannot be sent on -- see [SendFeeUnavailable].
Future<FeePerGas> chooseFeePerGas({
  required Future<FeePerGas> Function() eip1559,
  required Future<BigInt> Function() gasPrice,
}) async {
  try {
    final fee = await eip1559();
    if (fee.maxFeePerGas > BigInt.zero) {
      // A priority fee above the max is not a market answer, it is the RPC's
      // arithmetic disagreeing with itself -- signing with it would either
      // be rejected or silently overpay.
      final priority = fee.maxPriorityFeePerGas > fee.maxFeePerGas
          ? fee.maxFeePerGas
          : fee.maxPriorityFeePerGas;
      return (maxFeePerGas: fee.maxFeePerGas, maxPriorityFeePerGas: priority);
    }
  } catch (_) {
    // Falls through to the legacy read below.
  }

  try {
    final legacy = await gasPrice();
    if (legacy > BigInt.zero) {
      return (maxFeePerGas: legacy, maxPriorityFeePerGas: legacy);
    }
  } catch (_) {
    // Both sources are unusable; SendFeeUnavailable below is the answer.
  }

  throw const SendFeeUnavailable();
}

/// The native-send transaction map `signAndSendTransaction` reads: no `data`
/// key, so the signer's own `Uint8List(0)` default applies.
Map<String, dynamic> buildSendTx({
  required String from,
  required String recipient,
  required BigInt amount,
  required SendFee fee,
}) => {
  'from': from,
  'to': recipient,
  'value': '0x${amount.toRadixString(16)}',
  'gas': '0x${fee.gasLimit.toRadixString(16)}',
  'maxFeePerGas': '0x${fee.maxFeePerGas.toRadixString(16)}',
  'maxPriorityFeePerGas': '0x${fee.maxPriorityFeePerGas.toRadixString(16)}',
};

/// Reads a broadcast transaction's receipt. A throw means "not yet indexed",
/// the same convention [pollReceipt] and `swap_execution.dart`'s poll share.
typedef ReceiptReader = Future<TransactionReceipt?> Function(String hash);

/// Polls [hash] until a receipt exists or [attempts] run out. A `null` read
/// or a thrown read is "not yet" and is never terminal on its own; any
/// non-null receipt is (a status-false receipt is a settled failure, not a
/// reason to keep polling). Exhaustion leaves the row pending, not lost.
Future<TransactionReceipt?> pollReceipt({
  required String hash,
  required ReceiptReader read,
  required Future<void> Function(Duration delay) wait,
  int attempts = 20,
  Duration interval = const Duration(seconds: 3),
}) async {
  for (var attempt = 0; attempt < attempts; attempt++) {
    if (attempt > 0) {
      await wait(interval);
    }
    TransactionReceipt? receipt;
    try {
      receipt = await read(hash);
    } catch (_) {
      receipt = null;
    }
    if (receipt != null) {
      return receipt;
    }
  }
  return null;
}

/// The wallet's own reading of a receipt: no receipt yet is pending, a
/// receipt exists and reads `status` for whether the chain accepted it.
TransactionStatus settledStatus(TransactionReceipt? receipt) {
  if (receipt == null) {
    return TransactionStatus.pending;
  }
  return receipt.status == false
      ? TransactionStatus.failed
      : TransactionStatus.completed;
}

/// What the send actually cost, in native wei -- `null` until both the gas
/// used and the price paid are on the receipt.
BigInt? feePaid(TransactionReceipt? receipt) {
  final gasUsed = receipt?.gasUsed;
  final price = receipt?.effectiveGasPrice;
  if (gasUsed == null || price == null) {
    return null;
  }
  return gasUsed * price.getInWei;
}

/// The three chain reads a send needs, each owning and disposing its own
/// [Web3Client] -- the same shape as [Web3.rawBalanceOf].
extension SendReads on Web3 {
  /// [address]'s native-coin balance, in wei.
  Future<BigInt> readNativeBalance({
    required String address,
    required String rpcUrl,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      return balance.getInWei;
    } finally {
      await client.dispose();
    }
  }

  /// A priced send from [sender] to [recipient]: [chooseFeePerGas] for the
  /// market fee, `estimateGas` for the limit. Throws [SendFeeUnavailable]
  /// when no fee could be read.
  Future<SendFee> readSendFee({
    required String rpcUrl,
    required String sender,
    required String recipient,
    Uint8List? data,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      final senderAddress = EthereumAddress.fromHex(sender);
      final recipientAddress = EthereumAddress.fromHex(recipient);

      final chosen = await chooseFeePerGas(
        eip1559: () async {
          // The 50th-percentile entry: not the most eager quote and not the
          // most conservative, no buffer added on top.
          final fees = await client.getGasInEIP1559();
          final median = fees[1];
          return (
            maxFeePerGas: median.maxFeePerGas,
            maxPriorityFeePerGas: median.maxPriorityFeePerGas,
          );
        },
        gasPrice: () async {
          final price = await client.getGasPrice();
          return price.getInWei;
        },
      );

      final gasLimit = await client.estimateGas(
        sender: senderAddress,
        to: recipientAddress,
        data: data,
      );

      return SendFee(
        maxFeePerGas: chosen.maxFeePerGas,
        maxPriorityFeePerGas: chosen.maxPriorityFeePerGas,
        gasLimit: gasLimit,
      );
    } finally {
      await client.dispose();
    }
  }

  /// [hash]'s on-chain receipt, or `null` while it is still unconfirmed.
  Future<TransactionReceipt?> readReceipt({
    required String hash,
    required String rpcUrl,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    try {
      return await client.getTransactionReceipt(hash);
    } finally {
      await client.dispose();
    }
  }
}
