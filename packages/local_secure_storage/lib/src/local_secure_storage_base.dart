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

  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  LocalWalletStorage._create();

  static Future<LocalWalletStorage> create() async {
    final localWalletStorage = LocalWalletStorage._create();
    final secureStorage = localWalletStorage._secureStorage;
    final walletsController = localWalletStorage.walletsController;

    List<Wallet> wallets = [];

    Map<String, String> keys = await secureStorage.readAll();

    keys.forEach((key, value) {
      if (key != _pinKey && key != _watchesKey) {
        StoredKeyWallet wallet = StoredKeyWallet(StoredKey.importJson(value));
        wallets.add(mapStoredKeyWalletToWallets(wallet));
      }
    });

    walletsController.add(wallets);

    return localWalletStorage;
  }

  @override
  Future<void> saveStoredKey(StoredKey storedKey) async {
    final currentWallets = [...walletsController.value];
    currentWallets.add(mapStoredKeyWalletToWallets(StoredKeyWallet(storedKey)));
    walletsController.add(currentWallets);

    await _secureStorage.write(
        key: storedKey.account(0).address(), value: storedKey.exportJson());
  }

  // TODO: Figure out deleting wallets
  @override
  Future<void> deleteWallet(String walletAddress) async {
    // final currentWallets = [...walletsController.value];

    // currentWallets.removeWhere((element) =>
    //     element.address.toLowerCase() == walletAddress.toLowerCase());

    // final walletJsonStr = await _secureStorage.read(key: _walletCollectionKey);

    // if (walletJsonStr == null) {
    //   return;
    // }

    // walletsController.add(currentWallets);

    // final walletsMap =
    //     List<Map<String, dynamic>>.from(jsonDecode(walletJsonStr));

    // List<WalletStored> storedWallets =
    //     walletsMap.map(WalletStored.fromJson).toList();

    // storedWallets.removeWhere((element) =>
    //     element.address.toLowerCase() == walletAddress.toLowerCase());

    // await _secureStorage.write(
    //     key: _walletCollectionKey, value: json.encode(storedWallets));
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
      StoredKeyWallet wallet =
          StoredKeyWallet(StoredKey.importJson(entry.value));
      // no need to wait so no (await)
      await _secureStorage.write(
          key: wallet.storedKey.identifier(), value: null);
    }
  }
}

// TODO: wire up fetching balance, transactions
// Don't pass any sensitive data to the UI, no privateKey or mnemonic
Wallet mapStoredKeyWalletToWallets(StoredKeyWallet wallet) {
  // TODO: How to manage multiple accounts in wallet?
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
