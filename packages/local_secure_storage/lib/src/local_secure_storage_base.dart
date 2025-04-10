import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/tw/coin_util.dart';
import 'package:genius_api/tw/stored_key.dart';
import 'package:genius_api/tw/stored_key_wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/material.dart';

class LocalWalletStorage {
  /// Key used for storing user PIN locally.
  static const _pinKey = '__pin_key__';
  static const _watchesKeyPrefix = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';
  static const _accountKeyPrefix = '__account__';

  final walletsController = BehaviorSubject<List<Wallet>>.seeded([]);
  Stream<List<Wallet>> getWallets() => walletsController.asBroadcastStream();
  final FlutterSecureStorage _secureStorage;
  final Web3 _web3;

  LocalWalletStorage._create(this._secureStorage, this._web3);

  static Future<LocalWalletStorage> create(
      {FlutterSecureStorage? secureStorage, Web3? web3}) async {
    final storageInstance = secureStorage ?? FlutterSecureStorage();
    final web3Instance = web3 ?? Web3();
    final localWalletStorage =
        LocalWalletStorage._create(storageInstance, web3Instance);
    //await localWalletStorage.deleteAllWallets();
    return localWalletStorage;
  }

  Future<void> init() async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      try {
        if (isAWallet(entry.key)) {
          StoredKey? storedKey = StoredKey.importJson(entry.value);

          // A key was not able to be parsed, delete it
          if (storedKey == null) {
            debugPrint("Deleted storedkey ${entry.key}");
            await deleteKey(entry.key);
          }

          final storedKeyWallet = StoredKeyWallet(storedKey);

          addWalletToController(
              await mapStoredKeyWalletToWallets(storedKeyWallet));
        } else if (isAWatchedWallet(entry.key)) {
          Wallet? wallet = Wallet.fromJson(
              Map<String, dynamic>.from(jsonDecode(entry.value)));
          addWalletToController(await mapWalletToWallets(wallet));
        }
      } catch (e) {
        debugPrint('** Issue with loading wallets ');
        debugPrint(e.toString());
      }
    }

    final account = await loadAccount();

    if (account == null) {
      // create account if one doesn't exist
      await createNewAccount();
    }
  }

  Future<Account> createNewAccount() async {
    final account =
        Account(balance: 0.0, name: 'Genius', lastBalanceRetrievalDate: null);
    await saveAccount(account);
    return account;
  }

  Future<Account?> loadAccount() async {
    String? accountData = await _secureStorage.read(key: _accountKeyPrefix);

    if (accountData == null) {
      return null;
    }

    try {
      Account? account =
          Account.fromJson(Map<String, dynamic>.from(jsonDecode(accountData)));
      return account;
    } catch (e) {
      // What to do if the account doesn't load? Is deleting / creating a new one appropriate? We don't want to brick the app
      debugPrint('** Issue with loading acount');
      debugPrint(e.toString());
      _secureStorage.delete(key: _accountKeyPrefix);
      return await createNewAccount();
    }
  }

  Future<void> saveAccount(Account account) async {
    await _secureStorage.write(
        key: getAccountKey(), value: jsonEncode(account.toJson()));
  }

  Future<void> saveAccountBalance(double balance) async {
    final account = await loadAccount();
    if (account == null) {
      return;
    }

    // store new balance, set retrieval date for rate limiting
    account.balance = balance;
    account.lastBalanceRetrievalDate = DateTime.now();

    await _secureStorage.write(
        key: getAccountKey(), value: jsonEncode(account.toJson()));
  }

  updateAccountFetchDate() async {
    final account = await loadAccount();
    if (account == null) {
      return;
    }

    // store new balance, set retrieval date for rate limiting
    account.lastBalanceRetrievalDate = DateTime.now();

    await _secureStorage.write(
        key: getAccountKey(), value: jsonEncode(account.toJson()));
  }

  Future<void> deleteAccount() async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if (isAAccount(entry.key)) {
        await deleteKey(entry.key);
        return;
      }
    }
  }

  Future<void> saveStoredKey(StoredKey storedKey) async {
    addWalletToController(
        await mapStoredKeyWalletToWallets(StoredKeyWallet(storedKey)));

    await _secureStorage.write(
        key: createWalletKey(storedKey.account(0).address()),
        value: storedKey.exportJson());
  }

  Future<void> saveWatchedWallet(Wallet wallet) async {
    addWalletToController(await mapWalletToWallets(wallet));

    await _secureStorage.write(
        key: createWatchedWalletKey(wallet.address),
        value: jsonEncode(wallet.toJson()));
  }

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

  Future<StoredKeyWallet?> getWallet(String walletAddress) async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if ((isAWallet(entry.key) || isAWatchedWallet(entry.key)) &&
          isKeyMatchesAddress(entry.key, walletAddress)) {
        StoredKey? storedKey = StoredKey.importJson(entry.value);

        // A key was not able to be parsed, delete it
        if (storedKey == null) {
          return null;
        }

        return StoredKeyWallet(storedKey);
      }
    }
    return null;
  }

  Future<void> storeUserPin(String pin) async =>
      await _secureStorage.write(key: _pinKey, value: pin);

  Future<bool> verifyUserPin(String pin) async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey) ?? '';

      return storedPin.isNotEmpty && storedPin == pin;
    } catch (e) {
      return false;
    }
  }

  Future<bool> pinExists() async {
    try {
      final storedPin = await _secureStorage.read(key: _pinKey) ?? '';
      return storedPin.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

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

  String getAccountKey() {
    return _accountKeyPrefix;
  }

  bool isAAccount(String key) {
    return key.toLowerCase().contains(_accountKeyPrefix);
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

  Future<StoredKey?> getSGNUSLinkedWalletPrivateKey() async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if (isAWallet(entry.key)) {
        StoredKey? storedKey = StoredKey.importJson(entry.value);
        if (storedKey == null) {
          continue;
        }
        return storedKey;
      }
    }

    return null;
  }

  // Don't pass any sensitive data to the UI, no privateKey or mnemonic
  Future<Wallet> mapStoredKeyWalletToWallets(StoredKeyWallet wallet) async {
    final address = wallet.storedKey.account(0).address();
    final List<Network> networks = await readNetworkAssets();
    final symbol = CoinUtil.getSymbol(wallet.storedKey.account(0).coinType());
    final network =
        networks.where((element) => (element.symbol) == symbol.toLowerCase());

    double walletBalance = 0;

    try {
      if (network.isNotEmpty) {
        walletBalance = await _web3.getBalance(
            address: address, rpcUrl: network.first.rpcUrl ?? "");
      }
    } catch (e) {
      debugPrint('Failed to fetch wallet balance');
    }

    return Wallet(
        walletName: wallet.storedKey.name(),
        currencySymbol:
            CoinUtil.getSymbol(wallet.storedKey.account(0).coinType()),
        coinType: wallet.storedKey.account(0).coinType(),
        balance: walletBalance,
        address: wallet.storedKey.account(0).address(),
        walletType: wallet.storedKey.isMnemonic()
            ? WalletType.mnemonic
            : WalletType.privateKey,
        transactions: []);
  }

  Future<Wallet> mapWalletToWallets(Wallet wallet) async {
    final List<Network> networks = await readNetworkAssets();
    final network = networks.where(
        (element) => element.symbol == wallet.currencySymbol.toLowerCase());

    double walletBalance = 0;

    try {
      if (network.isNotEmpty) {
        walletBalance = await _web3.getBalance(
            address: wallet.address, rpcUrl: network.first.rpcUrl ?? "");
      }
    } catch (e) {
      debugPrint('Failed to fetch wallet balance');
    }

    return Wallet(
        walletName: wallet.walletName,
        currencySymbol: wallet.currencySymbol,
        coinType: wallet.coinType,
        balance: walletBalance,
        address: wallet.address,
        walletType: wallet.walletType,
        transactions: []);
  }
}

Future<List<Network>> readNetworkAssets() async {
  const String assetLocation = 'assets/json/networks/networks.json';
  final String? response = await safeLoadAsset(assetLocation);

  if (response == null) {
    return List.empty();
  }

  final networksJson = await jsonDecode(response);

  List<Network> networkList = List<Network>.from(
      networksJson.map((network) => Network.fromJson(network)));

  return networkList;
}

Future<String?> safeLoadAsset(String path) async {
  try {
    return await rootBundle.loadString(path);
  } catch (e) {
    debugPrint('$e');
    return null;
  }
}
