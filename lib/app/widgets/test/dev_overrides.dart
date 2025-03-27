import 'dart:math';

import 'package:genius_api/controllers/transactions_controller.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';

const walletPK = String.fromEnvironment('WALLET_PK', defaultValue: '');
final rand = Random();

bool isWalletPKBypass() {
  return walletPK.isNotEmpty;
}

void byPassSGNUSConnecton(geniusApi) {
  if (!isWalletPKBypass()) {
    return;
  }

  print('\x1B[37m** Manually skipping SGNUS connection\x1B[0m');

  geniusApi.getSGNUSController().updateConnection(const SGNUSConnection(
      sgnusAddress: "0x67890", walletAddress: "0x12345", isConnected: true));
}

void byPassWalletCreation(localWalletStorage) {
  if (!isWalletPKBypass()) {
    return;
  }

  print('\x1B[37m** Manually importing wallet from variable\x1B[0m');

  localWalletStorage.addWalletToController(const Wallet(
      walletName: 'Bypass Wallet',
      currencySymbol: 'eth',
      coinType: TWCoinType.TWCoinTypeEthereum,
      balance: 0,
      address: '0x6084a30B8CFe3fd27b0672b8fE740B9a8541403e',
      walletType: WalletType.privateKey,
      transactions: []));
}

void addFakeTransactions(TransactionsController txController) {
  print('\x1B[37m** Adding fake transactions\x1B[0m');
  txController.addTransactions([
    getFakeTransaction(),
    getFakeTransaction(),
    getFakeTransaction(),
    getFakeTransaction(),
    getFakeTransaction(),
    getFakeTransaction()
  ]);
}

Transaction getFakeTransaction() {
  final now = DateTime.now();

  const directions = TransactionDirection.values;
  final randomDirection = directions[rand.nextInt(directions.length)];

  const types = TransactionType.values;
  final randomType = types[rand.nextInt(types.length)];

  return Transaction(
    hash: "0x${now.millisecondsSinceEpoch}",
    fromAddress: "0xFromMocked",
    recipients: [
      const TransferRecipients(amount: "0.5", toAddr: "0xToMocked"),
    ],
    coinSymbol: "ETH",
    fees: "0.001",
    transactionDirection: randomDirection,
    timeStamp: now,
    type: randomType,
    transactionStatus: TransactionStatus.completed,
    isSGNUS: rand.nextBool(),
  );
}
