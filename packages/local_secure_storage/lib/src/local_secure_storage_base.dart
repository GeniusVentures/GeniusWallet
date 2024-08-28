import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/coin_util.dart';
import 'package:genius_api/tw/stored_key.dart';
import 'package:genius_api/tw/stored_key_wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:secure_storage/secure_storage.dart';

class LocalWalletStorage extends SecureStorage {
  /// Key used for storing user PIN locally.
  static const _pinKey = '__pin_key__';
  static const _watchesKeyPrefix = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  LocalWalletStorage._create();

  static Future<LocalWalletStorage> create() async {
    final localWalletStorage = LocalWalletStorage._create();
    //await localWalletStorage.deleteAllWallets();

    Map<String, String> keys =
        await localWalletStorage._secureStorage.readAll();

    for (var entry in keys.entries) {
      try {
        if (localWalletStorage.isAWallet(entry.key)) {
          StoredKey? storedKey = StoredKey.importJson(entry.value);
          // A key was not able to be parsed, delete it
          if (storedKey == null) {
            print("Deleted storedkey ${entry.key}");
            await localWalletStorage.deleteKey(entry.key);
          }

          localWalletStorage.addWalletToController(
              mapStoredKeyWalletToWallets(StoredKeyWallet(storedKey)));
        } else if (localWalletStorage.isAWatchedWallet(entry.key)) {
          Wallet? wallet = Wallet.fromJson(
              Map<String, dynamic>.from(jsonDecode(entry.value)));
          localWalletStorage.addWalletToController(wallet);
        }
      } catch (e) {
        // Some issue happened with parsing key. Delete wallet
        print("Deleted wallet ${entry.key}");
        await localWalletStorage.deleteKey(entry.key);
      }
    }

    return localWalletStorage;
  }

  @override
  Future<void> saveStoredKey(StoredKey storedKey) async {
    addWalletToController(
        mapStoredKeyWalletToWallets(StoredKeyWallet(storedKey)));

    await _secureStorage.write(
        key: createWalletKey(storedKey.account(0).address()),
        value: storedKey.exportJson());
  }

  @override
  Future<void> saveWatchedWallet(Wallet wallet) async {
    addWalletToController(wallet);

    await _secureStorage.write(
        key: createWatchedWalletKey(wallet.address),
        value: jsonEncode(wallet.toJson()));
  }

  @override
  Future<void> deleteWallet(String walletAddress) async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if ((isAWallet(entry.key) || isAWatchedWallet(entry.key)) &&
          isKeyMatchesAddress(entry.key, walletAddress)) {
        await deleteKey(entry.key);
        deleteWalletFromController(walletAddress);
        return;
      }
    }
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

  @override
  Future<void> deleteAllWallets() async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if (isAWallet(entry.key)) {
        await deleteKey(entry.key);
      } else if (isAWatchedWallet(entry.key)) {
        await deleteKey(entry.key);
      }
    }

    deleteAllWalletsFromController();
  }

  Future<void> deleteKey(String key) async {
    await _secureStorage.write(key: key, value: null);
  }

  String createWalletKey(String address) {
    return '$_walletKeyPrefix${address.toLowerCase()}';
  }

  bool isAWallet(String key) {
    return key.toLowerCase().contains(_walletKeyPrefix);
  }

  bool isAWatchedWallet(String key) {
    return key.toLowerCase().contains(_watchesKeyPrefix);
  }

  String createWatchedWalletKey(String address) {
    return '$_watchesKeyPrefix${address.toLowerCase()}';
  }

  bool isKeyMatchesAddress(String key, String address) {
    return key.toLowerCase() == createWalletKey(address.toLowerCase()) ||
        key.toLowerCase() == createWatchedWalletKey(address.toLowerCase());
  }

  void addWalletToController(Wallet wallet) {
    // delete it if it already existed
    deleteWalletFromController(wallet.address);
    final currentWallets = [...walletsController.value];
    currentWallets.add(wallet);
    walletsController.add(currentWallets);
  }

  void deleteAllWalletsFromController() {
    walletsController.add([]);
  }

  void deleteWalletFromController(String address) {
    final currentWallets = [...walletsController.value];
    currentWallets.removeWhere(
        (element) => element.address.toLowerCase() == address.toLowerCase());
    walletsController.add(currentWallets);
  }
}

// TODO: wire up fetching balance, transactions
// Don't pass any sensitive data to the UI, no privateKey or mnemonic
Wallet mapStoredKeyWalletToWallets(StoredKeyWallet wallet) {
  return Wallet(
      walletName: wallet.storedKey.name(),
      currencySymbol:
          CoinUtil.getSymbol(wallet.storedKey.account(0).coinType()),
      coinType: wallet.storedKey.account(0).coinType(),
      balance: 0,
      address: wallet.storedKey.account(0).address(),
      walletType: wallet.storedKey.isMnemonic()
          ? WalletType.mnemonic
          : WalletType.privateKey,
      transactions: []);
}
