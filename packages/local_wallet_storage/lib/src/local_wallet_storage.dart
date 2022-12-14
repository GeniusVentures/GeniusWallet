import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_api/genius_api.dart';
import 'package:wallet_storage_template/wallet_storage_template.dart';

class LocalWalletStorage extends WalletStorage {
  /// Key used for storing wallets locally.
  static const _walletCollectionKey = '__wallet_collection_key__';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  LocalWalletStorage._create();

  /// Need a "factory" method here since we need to initialize the Stream
  /// which needs awaiting.
  static Future<LocalWalletStorage> create() async {
    final localWalletStorage = LocalWalletStorage._create();

    final walletJsonStr =
        await localWalletStorage._secureStorage.read(key: _walletCollectionKey);

    if (walletJsonStr == null) {
      localWalletStorage.walletsController.add([]);
    } else {
      final walletsMap =
          List<Map<String, dynamic>>.from(jsonDecode(walletJsonStr));

      final wallets = walletsMap.map(Wallet.fromJson).toList();

      localWalletStorage.walletsController.add(wallets);
    }

    return localWalletStorage;
  }

  @override
  Future<void> deleteWallet(String walletAddress) async {
    final currentWallets = [...walletsController.value];

    currentWallets.removeWhere((element) => element.address == walletAddress);

    walletsController.add(currentWallets);

    _secureStorage.write(
        key: _walletCollectionKey, value: json.encode(currentWallets));
  }

  @override
  Future<void> saveWallet(Wallet wallet) async {
    final currentWallets = [...walletsController.value];

    final index = currentWallets
        .indexWhere((element) => element.address == wallet.address);

    if (index >= 0) {
      currentWallets[index] = wallet;
    } else {
      currentWallets.add(wallet);
    }

    walletsController.add(currentWallets);
    _secureStorage.write(
        key: _walletCollectionKey, value: json.encode(currentWallets));
  }
}
