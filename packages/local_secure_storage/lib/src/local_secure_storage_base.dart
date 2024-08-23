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
  static const _watchesKey = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  LocalWalletStorage._create();

  static Future<LocalWalletStorage> create() async {
    final localWalletStorage = LocalWalletStorage._create();

    //await localWalletStorage.deleteAllWallets();

    Map<String, String> keys =
        await localWalletStorage._secureStorage.readAll();

    for (var entry in keys.entries) {
      if (localWalletStorage.isAWallet(entry.key)) {
        StoredKey? storedKey = StoredKey.importJson(entry.value);
        // A key was not able to be parsed, delete it
        if (storedKey == null) {
          await localWalletStorage.deleteKey(entry.key);
        }
        localWalletStorage.addWalletToController(storedKey);
      }
    }

    return localWalletStorage;
  }

  @override
  Future<void> saveStoredKey(StoredKey storedKey) async {
    addWalletToController(storedKey);

    await _secureStorage.write(
        key: createKey(storedKey.account(0).address()),
        value: storedKey.exportJson());
  }

  @override
  Future<void> deleteWallet(String walletAddress) async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if (isAWallet(entry.key) &&
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
      }
    }

    deleteAllWalletsFromController();
  }

  Future<void> deleteKey(key) async {
    await _secureStorage.write(key: key, value: null);
  }

  String createKey(String address) {
    return '$_walletKeyPrefix${address.toLowerCase()}';
  }

  bool isAWallet(String key) {
    return key.toLowerCase().contains(_walletKeyPrefix);
  }

  bool isKeyMatchesAddress(String key, String address) {
    return key.toLowerCase() == createKey(address.toLowerCase());
  }

  void addWalletToController(storedKey) {
    final currentWallets = [...walletsController.value];
    currentWallets.add(mapStoredKeyWalletToWallets(StoredKeyWallet(storedKey)));
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
