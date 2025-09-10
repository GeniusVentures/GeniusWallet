import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/buy_cancelled_drawer.dart';
import 'package:genius_wallet/banxa/buy_success_drawer.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

void handleBanxaRedirect({
  required BuildContext context,
  required String uri,
  required TransactionsCubit transactionsCubit,
}) async {
  final parsedUri = Uri.parse(uri);

  final orderId = parsedUri.queryParameters['orderId'] ?? '';
  final coin = parsedUri.queryParameters['coin'] ?? 'UNKNOWN';
  final coinAmount = parsedUri.queryParameters['coinAmount'] ?? '0';
  final fiatAmount = parsedUri.queryParameters['fiatAmount'] ?? '0';
  final orderStatus =
      parsedUri.queryParameters['orderStatus']?.toLowerCase() ?? '';

  final walletAddress =
      context.read<WalletDetailsCubit>().state.selectedWallet!.address;

  /// TODO: Replace these URLs with the actual success and cancel URLs from Banxa

  final transaction = Transaction(
    hash: orderId,
    fromAddress: walletAddress,
    recipients: [
      TransferRecipients(
        toAddr: walletAddress,
        amount: coinAmount,
      )
    ],
    timeStamp: DateTime.now(),
    transactionDirection: TransactionDirection.received,
    fees: fiatAmount,
    coinSymbol: coin,
    transactionStatus: orderStatus == 'complete'
        ? TransactionStatus.completed
        : TransactionStatus.cancelled,
    type: TransactionType.purchase,
  );

  transactionsCubit.addTransaction(transaction);

  // save to hive
  await TransactionStorageService().addTransaction(walletAddress, transaction);

  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!context.mounted) return;

    if (orderStatus == 'complete') {
      BuySuccessDrawer.show(context, onClose: () {
        Navigator.of(context).pop();
      });
    } else if (orderStatus == 'cancelled') {
      BuyCancelledDrawer.show(context, onClose: () {
        Navigator.of(context).pop();
      });
    }
  });
}
