import 'dart:math';

import 'package:flutter/material.dart';
import 'package:genius_api/controllers/sgnus_transactions_controller.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/services/transaction_storage_service.dart';

const walletPK = String.fromEnvironment('WALLET_PK', defaultValue: '');
final rand = Random();

bool isWalletPKBypass() {
  return walletPK.isNotEmpty;
}

void byPassSGNUSConnecton(geniusApi) {
  if (!isWalletPKBypass()) {
    return;
  }

  debugPrint('\x1B[37m** Manually skipping SGNUS connection\x1B[0m');

  geniusApi.getSGNUSController().updateConnection(const SGNUSConnection(
      sgnusAddress: "0x67890-Bypass",
      walletAddress: "0x12345-Bypass",
      isConnected: true));
}

void byPassWalletCreation(localWalletStorage) {
  if (!isWalletPKBypass()) {
    return;
  }

  debugPrint('\x1B[37m** Manually importing wallet from variable\x1B[0m');

  localWalletStorage.addWalletToController(const Wallet(
    walletName: 'Bypass Wallet',
    currencySymbol: 'eth',
    coinType: TWCoinType.TWCoinTypeEthereum,
    balance: 0,
    address: '0x6084a30B8CFe3fd27b0672b8fE740B9a8541403e',
    walletType: WalletType.privateKey,
  ));
}

void addFakeSGNUSTransactions(SGNUSTransactionsController txController) {
  if (!isWalletPKBypass()) {
    return;
  }

  debugPrint('\x1B[37m** Adding fake transactions\x1B[0m');
  txController
      .addTransactions(List.generate(20, (_) => getFakeTransaction(true)));
}

void addFakeWalletCubitTransactions(TransactionsCubit cubit) {
  if (!isWalletPKBypass()) {
    return;
  }

  debugPrint('\x1B[37m** Adding fake Wallet transaction to cubit\x1B[0m');
  cubit.addTransaction(getFakeTransaction(false));
}

void addFakeWalletTransactions() {
  if (!isWalletPKBypass()) {
    return;
  }

  debugPrint('\x1B[37m** Adding fake Wallet transactions\x1B[0m');
  TransactionStorageService().addTransaction(
      '0x6084a30B8CFe3fd27b0672b8fE740B9a8541403e', getFakeTransaction(false));
}

Transaction getFakeTransaction(bool isSgnus) {
  final now = DateTime.now();

  const directions = TransactionDirection.values;
  final randomDirection = directions[rand.nextInt(directions.length)];

  const types = TransactionType.values;
  final randomType = types[rand.nextInt(types.length)];

  return Transaction(
    hash: "0x${now.millisecondsSinceEpoch}",
    fromAddress: "0xFromMocked",
    recipients: [
      TransferRecipients(amount: "0.5", toAddr: "0xToMocked"),
    ],
    coinSymbol: "ETH",
    fees: "0.001",
    transactionDirection: randomDirection,
    timeStamp: now,
    type: randomType,
    transactionStatus: TransactionStatus.completed,
    isSGNUS: isSgnus,
  );
}
