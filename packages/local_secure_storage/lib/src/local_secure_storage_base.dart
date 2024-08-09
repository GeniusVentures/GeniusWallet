import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/wallet_stored.dart';
import 'package:secure_storage/secure_storage.dart';

class LocalWalletStorage extends SecureStorage {
  /// Key used for storing wallets locally.
  static const _walletCollectionKey = '__wallet_collection_key__';

  /// Key used for storing user PIN locally.
  static const _pinKey = '__pin_key__';

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

      final storedWallets = walletsMap.map(WalletStored.fromJson).toList();
      List<Wallet> wallets = storedWallets
          .map((storedWallet) => mapStoredWalletToWallet(storedWallet))
          .toList();

      // only load non sensitive data into the controller for the app
      localWalletStorage.walletsController.add(wallets);
    }

    return localWalletStorage;
  }

  @override
  Future<void> deleteWallet(String walletAddress) async {
    final currentWallets = [...walletsController.value];

    currentWallets.removeWhere((element) => element.address == walletAddress);

    final walletJsonStr = await _secureStorage.read(key: _walletCollectionKey);

    if (walletJsonStr == null) {
      return;
    }

    walletsController.add(currentWallets);

    final walletsMap =
        List<Map<String, dynamic>>.from(jsonDecode(walletJsonStr));

    List<WalletStored> storedWallets =
        walletsMap.map(WalletStored.fromJson).toList();

    storedWallets.removeWhere((element) => element.address == walletAddress);

    await _secureStorage.write(
        key: _walletCollectionKey, value: json.encode(storedWallets));
  }

  @override
  Future<void> saveWallet(WalletStored wallet) async {
    final isExistingWallet = walletsController.value
            .indexWhere((element) => element.address == wallet.address) >=
        0;

    if (isExistingWallet) {
      await deleteWallet(wallet.address);
    }

    final currentWallets = [...walletsController.value];

    currentWallets.add(mapStoredWalletToWallet(wallet));

    final walletJsonStr = await _secureStorage.read(key: _walletCollectionKey);

    walletsController.add(currentWallets);

    final walletsMap = walletJsonStr != null
        ? List<Map<String, dynamic>>.from(jsonDecode(walletJsonStr))
        : null;

    List<WalletStored> storedWallets = walletsMap != null
        ? walletsMap.map(WalletStored.fromJson).toList()
        : [];

    storedWallets.add(wallet);

    await _secureStorage.write(
        key: _walletCollectionKey, value: json.encode(storedWallets));
    //twenty jungle lazy consider valid dirt mimic firm rail clerk normal number
  }

  @override
  Future<void> storeUserPin(String pin) async =>
      await _secureStorage.write(key: _pinKey, value: pin);

  @override
  Future<bool> verifyUserPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey) ?? '';

      return storedPin.isNotEmpty && storedPin == pin;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> pinExists() async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey) ?? '';
      return storedPin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }
}

// TODO: wire up fetching balance, transactions
Wallet mapStoredWalletToWallet(WalletStored wallet) {
  return Wallet(
      walletName: wallet.walletName,
      currencySymbol: wallet.currencySymbol,
      coinType: wallet.coinType,
      balance: 0,
      address: wallet.address,
      transactions: []);
}
