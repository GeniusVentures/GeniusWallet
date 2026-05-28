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

import 'package:flutter/material.dart';

class LocalWalletStorage {
  /// Key used for storing user PIN locally.
  static const _pinKey = '__pin_key__';
  static const _watchesKeyPrefix = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';
  static const _accountKeyPrefix = '__account__';

  final FlutterSecureStorage _secureStorage;
  final Web3 _web3;

  LocalWalletStorage._create(this._secureStorage, this._web3);

  static Future<LocalWalletStorage> create(
      {FlutterSecureStorage? secureStorage, Web3? web3}) async {
    FlutterSecureStorage storageInstance;
    if (secureStorage != null) {
      storageInstance = secureStorage;
    } else {
      // Use EncryptedSharedPreferences to match v3.4+ default behavior
      const androidOptions = AndroidOptions(
        encryptedSharedPreferences: true,
      );

      storageInstance = const FlutterSecureStorage(
        aOptions: androidOptions,
      );
    }

    final web3Instance = web3 ?? Web3();
    final localWalletStorage =
        LocalWalletStorage._create(storageInstance, web3Instance);

    return localWalletStorage;
  }

  Future<void> init() async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      try {
        if (isAWallet(entry.key)) {
          StoredKey? storedKey = StoredKey.importJson(entry.value);

          if (storedKey == null) {
            debugPrint("Deleting key ${entry.key} because it is not parseable");
            await deleteKey(entry.key);
          }
        } else if (isAWatchedWallet(entry.key)) {
          // Validate watched wallet JSON is parseable
          Wallet.fromJson(Map<String, dynamic>.from(jsonDecode(entry.value)));
        }
      } catch (e) {
        debugPrint('Issue with loading wallets');
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
      debugPrint('Issue with loading acount');
      debugPrint(e.toString());
      _secureStorage.delete(key: _accountKeyPrefix);
      return null;
    }
  }

  Future<void> saveAccount(Account account) async {
    await _secureStorage.write(
        key: _accountKeyPrefix, value: jsonEncode(account.toJson()));
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
        key: _accountKeyPrefix, value: jsonEncode(account.toJson()));
  }

  Future<void> updateAccountFetchDate() async {
    final account = await loadAccount();
    if (account == null) {
      return;
    }

    // store new balance, set retrieval date for rate limiting
    account.lastBalanceRetrievalDate = DateTime.now();

    await _secureStorage.write(
        key: _accountKeyPrefix, value: jsonEncode(account.toJson()));
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
    await _secureStorage.write(
        key: createWalletKey(storedKey.account(0).address()),
        value: storedKey.exportJson());
  }

  Future<void> saveWatchedWallet(Wallet wallet) async {
    await _secureStorage.write(
        key: createWatchedWalletKey(wallet.address),
        value: jsonEncode(wallet.toJson()));
  }

  Future<void> renameWallet(String walletAddress, String newName) async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if ((isAWallet(entry.key) || isAWatchedWallet(entry.key)) &&
          isKeyMatchesAddress(entry.key, walletAddress)) {
        if (isAWatchedWallet(entry.key)) {
          // For watched wallets, parse the JSON, update the name, and save.
          final walletJson = Map<String, dynamic>.from(jsonDecode(entry.value));
          walletJson['walletName'] = newName;
          await _secureStorage.write(
              key: entry.key, value: jsonEncode(walletJson));
        } else {
          // For stored-key wallets, parse the JSON, update the name, and save.
          final storedKeyJson =
              Map<String, dynamic>.from(jsonDecode(entry.value));
          storedKeyJson['name'] = newName;
          await _secureStorage.write(
              key: entry.key, value: jsonEncode(storedKeyJson));
        }
        return;
      }
    }
  }

  Future<void> deleteWallet(String walletAddress) async {
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if ((isAWallet(entry.key) || isAWatchedWallet(entry.key)) &&
          isKeyMatchesAddress(entry.key, walletAddress)) {
        await deleteKey(entry.key);
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

  bool isAAccount(String key) {
    return key.toLowerCase().contains(_accountKeyPrefix);
  }

  bool isKeyMatchesAddress(String key, String address) {
    return key.toLowerCase() == createWalletKey(address.toLowerCase()) ||
        key.toLowerCase() == createWatchedWalletKey(address.toLowerCase());
  }

  Future<List<Wallet>> getAllWallets() async {
    final List<Wallet> wallets = [];
    final Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      try {
        if (isAWallet(entry.key)) {
          final StoredKey? storedKey = StoredKey.importJson(entry.value);
          if (storedKey == null) continue;
          final storedKeyWallet = StoredKeyWallet(storedKey);
          wallets.add(await _toSafeWallet(storedKeyWallet));
        } else if (isAWatchedWallet(entry.key)) {
          final Wallet wallet = Wallet.fromJson(
              Map<String, dynamic>.from(jsonDecode(entry.value)));
          wallets.add(await _fetchBalanceForWatchedWallet(wallet));
        }
      } catch (e) {
        debugPrint('Failed to parse wallet ${entry.key}: $e');
      }
    }

    return wallets;
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
  Future<Wallet> _toSafeWallet(StoredKeyWallet wallet) async {
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
    );
  }

  Future<Wallet> _fetchBalanceForWatchedWallet(Wallet wallet) async {
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
    );
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
