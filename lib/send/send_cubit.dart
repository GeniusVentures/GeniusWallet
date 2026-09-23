import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/web3/send_service.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/reown/calldata_decoder.dart'
    show tryDecodeErc20Transfer;
import 'package:genius_wallet/reown/utilities.dart' show parseHexToBigInt;
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:web3dart/web3dart.dart' show TransactionReceipt;

/// Every EVM native coin in this app's chain catalogue spends 18 decimals.
/// Used whenever [Coin.decimals] is absent -- which is always, for a coin
/// with no contract address.
const _nativeDecimals = 18;

/// Decimals beyond this are not a real token's -- the same ceiling the dApp
/// calldata decoder holds a token amount to.
const _maxTokenDecimals = 36;

/// Form state only -- **never a key**. [SendCubit.submit] hands the built
/// transaction to [GeniusApi.signAndSendTransaction], which resolves and
/// uses the wallet's key entirely inside `genius_api`.
class SendState {
  const SendState({
    this.coin,
    this.recipient = '',
    this.amount = '',
    this.busy = false,
    this.error,
    this.review,
    this.recorded,
  });

  final Coin? coin;
  final String recipient;
  final String amount;
  final bool busy;
  final String? error;
  final SendReview? review;

  /// The row the last submit resolved to. Read once by the caller (a toast
  /// and a receipt view) and not reset here -- [SendCubit.submit] clears the
  /// form fields that would let a second submit resend the same amount.
  final Transaction? recorded;

  SendState copyWith({
    Coin? coin,
    String? recipient,
    String? amount,
    bool? busy,
    String? error,
    SendReview? review,
    Transaction? recorded,
    bool clearError = false,
    bool clearReview = false,
  }) => SendState(
    coin: coin ?? this.coin,
    recipient: recipient ?? this.recipient,
    amount: amount ?? this.amount,
    busy: busy ?? this.busy,
    error: clearError ? null : (error ?? this.error),
    review: clearReview ? null : (review ?? this.review),
    recorded: recorded ?? this.recorded,
  );
}

/// A built, priced send, ready for the confirm drawer and for [SendCubit
/// .submit] to sign as-is.
class SendReview {
  const SendReview({
    required this.tx,
    required this.fee,
    required this.rawAmount,
    required this.recipient,
  });

  final Map<String, dynamic> tx;
  final SendFee fee;
  final BigInt rawAmount;
  final String recipient;
}

/// Whether [tx] really is the send it claims to be. With no [tokenContract]:
/// the recipient it was built for, the amount it was built for, and no
/// calldata riding along on what is supposed to be a plain native transfer.
/// With one: `to` is the contract, no native value moves, and the calldata
/// decodes back to exactly that recipient and amount -- the review's own
/// proof that the built transaction says what the form said.
bool builtTxMatches(
  Map<String, dynamic> tx, {
  required String recipient,
  required BigInt amount,
  String? tokenContract,
}) {
  final to = tx['to'] as String?;
  final value = tx['value'] as String?;
  if (to == null || value == null) {
    return false;
  }
  if (tokenContract == null) {
    return to.toLowerCase() == recipient.toLowerCase() &&
        parseHexToBigInt(value) == amount &&
        !tx.containsKey('data');
  }
  if (to.toLowerCase() != tokenContract.toLowerCase() ||
      parseHexToBigInt(value) != BigInt.zero) {
    return false;
  }
  final decoded = tryDecodeErc20Transfer(tx['data'] as String?);
  return decoded != null &&
      decoded.counterparty.eip55With0x.toLowerCase() ==
          recipient.toLowerCase() &&
      decoded.amount == amount;
}

/// The history row a send resolves to. [coin] is the asset that moved -- on
/// this plan always the coin with no contract address, so [assetSymbol] and
/// [coinSymbol] name the same currency, in whichever casing each side holds.
Transaction sendRow({
  required String hash,
  required TransactionStatus status,
  required String walletAddress,
  required Coin coin,
  required Network network,
  required String recipient,
  required BigInt rawAmount,
  required SendFee fee,
  TransactionReceipt? receipt,
}) {
  final decimals = coin.address == null
      ? _nativeDecimals
      : int.tryParse(coin.decimals ?? '') ?? _nativeDecimals;
  final gasSymbol = (network.nativeSymbol ?? network.symbol ?? '')
      .toUpperCase();
  final assetSymbol = (coin.symbol ?? gasSymbol).toUpperCase();
  final paidFee = feePaid(receipt) ?? fee.maxCost;

  return Transaction(
    hash: hash,
    fromAddress: walletAddress,
    recipients: [
      TransferRecipients(
        toAddr: recipient,
        amount: formatTokenAmount(rawAmount, decimals),
      ),
    ],
    timeStamp: DateTime.now(),
    transactionDirection: TransactionDirection.sent,
    fees: formatTokenAmount(paidFee, _nativeDecimals),
    coinSymbol: gasSymbol,
    transactionStatus: status,
    type: TransactionType.transfer,
    assetSymbol: assetSymbol,
    chainId: network.chainId,
  );
}

class SendCubit extends Cubit<SendState> {
  SendCubit({
    required this.api,
    required this.walletAddress,
    required this.network,
    required this.transactions,
    required this.storage,
    this.wait = Future<void>.delayed,
    Coin? initialCoin,
  }) : super(SendState(coin: initialCoin));

  final GeniusApi api;
  final String walletAddress;
  final Network network;
  final TransactionsCubit transactions;
  final TransactionStorageService storage;
  final Future<void> Function(Duration delay) wait;

  void setRecipient(String value) => emit(
    state.copyWith(recipient: value, clearError: true, clearReview: true),
  );

  void setAmount(String value) =>
      emit(state.copyWith(amount: value, clearError: true, clearReview: true));

  void cancelReview() => emit(state.copyWith(clearReview: true));

  /// Seats [coin] from the picker a bare `/send` opens with. Clears the
  /// amount and any review -- both were priced for whichever coin, if any,
  /// was seated before.
  void selectCoin(Coin coin) => emit(
    state.copyWith(coin: coin, amount: '', clearError: true, clearReview: true),
  );

  /// Validates, prices and builds the send, landing it on [SendState.review]
  /// for the confirm drawer. Refuses -- with a reason, never a silent no-op
  /// -- on a bad address, an unparsable amount, an unreadable fee, or a
  /// balance short of the amount plus the max fee.
  Future<void> review() async {
    final coin = state.coin;
    if (coin == null || state.busy) {
      return;
    }
    final recipient = state.recipient.trim();
    if (!isEvmAddress(recipient)) {
      emit(state.copyWith(error: 'Enter a valid address.', clearReview: true));
      return;
    }

    final tokenContract = coin.address;
    int decimals;
    if (tokenContract == null) {
      decimals = _nativeDecimals;
    } else {
      final parsed = int.tryParse(coin.decimals ?? '');
      if (parsed == null || parsed < 0 || parsed > _maxTokenDecimals) {
        emit(
          state.copyWith(
            error: "This token's decimals are unknown.",
            clearReview: true,
          ),
        );
        return;
      }
      decimals = parsed;
    }

    final rawAmount = toBaseUnits(state.amount.trim(), decimals);
    if (rawAmount == null || rawAmount <= BigInt.zero) {
      emit(
        state.copyWith(error: 'Enter an amount to send.', clearReview: true),
      );
      return;
    }

    final rpcUrl = network.rpcUrl ?? '';
    final gasSymbol = (network.nativeSymbol ?? network.symbol ?? '')
        .toUpperCase();
    emit(state.copyWith(busy: true, clearError: true, clearReview: true));
    try {
      final data = tokenContract == null
          ? null
          : erc20TransferCalldata(
              tokenContract: tokenContract,
              recipient: recipient,
              amount: rawAmount,
            );
      final fee = await api.estimateSendFee(
        rpcUrl: rpcUrl,
        sender: walletAddress,
        recipient: tokenContract ?? recipient,
        data: data,
      );

      if (tokenContract == null) {
        final balance = await api.nativeBalance(
          address: walletAddress,
          rpcUrl: rpcUrl,
        );
        if (rawAmount + fee.maxCost > balance) {
          if (!isClosed) {
            emit(
              state.copyWith(
                busy: false,
                error: "Not enough $gasSymbol to cover the amount and the fee.",
              ),
            );
          }
          return;
        }
      } else {
        final tokenBalance = await api.rawBalanceOf(
          address: walletAddress,
          contractAddress: tokenContract,
          rpcUrl: rpcUrl,
        );
        if (rawAmount > tokenBalance) {
          final symbol = (coin.symbol ?? '').toUpperCase();
          if (!isClosed) {
            emit(
              state.copyWith(
                busy: false,
                error: "Your $symbol balance doesn't cover this amount.",
              ),
            );
          }
          return;
        }
        final nativeBalance = await api.nativeBalance(
          address: walletAddress,
          rpcUrl: rpcUrl,
        );
        if (fee.maxCost > nativeBalance) {
          if (!isClosed) {
            emit(
              state.copyWith(
                busy: false,
                error: "Not enough $gasSymbol for the network fee.",
              ),
            );
          }
          return;
        }
      }

      final tx = buildSendTx(
        from: walletAddress,
        recipient: recipient,
        amount: rawAmount,
        fee: fee,
        tokenContract: tokenContract,
      );
      if (!builtTxMatches(
        tx,
        recipient: recipient,
        amount: rawAmount,
        tokenContract: tokenContract,
      )) {
        if (!isClosed) {
          emit(
            state.copyWith(busy: false, error: "Couldn't build this transfer."),
          );
        }
        return;
      }
      if (isClosed) {
        return;
      }
      emit(
        state.copyWith(
          busy: false,
          review: SendReview(
            tx: tx,
            fee: fee,
            rawAmount: rawAmount,
            recipient: recipient,
          ),
        ),
      );
    } catch (_) {
      // Covers both a thrown estimate/balance read and SendFeeUnavailable --
      // neither leaves anything specific enough to say beyond this.
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            error: "Couldn't estimate the network fee.",
          ),
        );
      }
    }
  }

  /// Signs [SendState.review], writes a pending row, polls to a terminal
  /// receipt, then overwrites the same row resolved. The write order is
  /// crash-safe: a pending row lands before the poll even starts, so a
  /// broadcast that outlives the app session is never unrecorded.
  ///
  /// Returns the resolved row on success, null on any failure -- the
  /// caller's signal, never [SendState.recorded] on its own, which a later
  /// failed submit would otherwise leave looking like a fresh success.
  Future<Transaction?> submit() async {
    final review = state.review;
    final coin = state.coin;
    if (review == null || coin == null || state.busy) {
      return null;
    }

    final rpcUrl = network.rpcUrl ?? '';
    emit(state.copyWith(busy: true, clearError: true));

    final result = await api.signAndSendTransaction(
      tx: review.tx,
      rpcUrl: rpcUrl,
      address: walletAddress,
      sourceChainId: network.chainId ?? 0,
    );

    final hash = result.data;
    if (!result.isSuccess || hash == null || hash.isEmpty) {
      if (!isClosed) {
        emit(
          state.copyWith(
            busy: false,
            error: result.errorMessage ?? 'The signature failed.',
          ),
        );
      }
      return null;
    }

    Transaction rowWith(
      TransactionStatus status, {
      TransactionReceipt? receipt,
    }) => sendRow(
      hash: hash,
      status: status,
      walletAddress: walletAddress,
      coin: coin,
      network: network,
      recipient: review.recipient,
      rawAmount: review.rawAmount,
      fee: review.fee,
      receipt: receipt,
    );

    // Written before the resolved status, keyed by the real hash: a crash
    // between broadcast and settlement must leave an accurate pending row
    // rather than no record of funds that already moved.
    await storage.addTransaction(
      walletAddress,
      rowWith(TransactionStatus.pending),
    );

    final receipt = await pollReceipt(
      hash: hash,
      read: (h) => api.transactionReceipt(hash: h, rpcUrl: rpcUrl),
      wait: wait,
    );
    final resolved = rowWith(settledStatus(receipt), receipt: receipt);
    await storage.addTransaction(walletAddress, resolved);
    transactions.addTransaction(resolved);

    if (isClosed) {
      return resolved;
    }
    emit(
      state.copyWith(
        busy: false,
        recorded: resolved,
        recipient: '',
        amount: '',
        clearReview: true,
      ),
    );
    return resolved;
  }
}
