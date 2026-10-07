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

/// One wallet's SGNUS account: which wallet produced it, and its name at
/// link time. Holds public addresses and a display name only, never key
/// material.
typedef SDKAccountLink = ({String walletAddress, String walletName});

class LocalWalletStorage {
  /// Key used for storing user PIN locally.
  static const _pinKey = '__pin_key__';
  static const _watchesKeyPrefix = '__watches_key__';
  static const _walletKeyPrefix = 'wallet_';
  static const _accountKeyPrefix = '__account__';

  /// Address of the wallet the Genius SDK is initialised with. Must not
  /// contain [_walletKeyPrefix], or it would be read back as a wallet.
  static const _sdkDefaultWalletKey = '__sgnus_linked_address__';

  /// Map of SDK address -> the wallet that produced it. Must not contain
  /// [_walletKeyPrefix], [_watchesKeyPrefix] or [_accountKeyPrefix], or it
  /// would be read back as one of those.
  static const _sdkAccountLinksKey = '__sdk_links__';

  final _SerialStorage _secureStorage;
  final Web3 _web3;

  /// Serialises each read-change-write of the links map.
  static final _linksLock = _SerialQueue();

  LocalWalletStorage._create(FlutterSecureStorage storage, this._web3)
    : _secureStorage = _SerialStorage(storage);

  /// Android options for the wallet store. resetOnError stays false: its default
  /// erases every wallet on one read error. migrateWithBackup stays false: it
  /// skips migrating v9's EncryptedSharedPreferences, so upgraded wallets vanish.
  @visibleForTesting
  static const androidOptions = AndroidOptions(
    resetOnError: false,
    migrateWithBackup: false,
  );

  static Future<LocalWalletStorage> create({
    FlutterSecureStorage? secureStorage,
    Web3? web3,
  }) async {
    FlutterSecureStorage storageInstance;
    if (secureStorage != null) {
      storageInstance = secureStorage;
    } else {
      storageInstance = const FlutterSecureStorage(aOptions: androidOptions);
    }

    final web3Instance = web3 ?? Web3();
    final localWalletStorage = LocalWalletStorage._create(
      storageInstance,
      web3Instance,
    );

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
    final account = Account(
      balance: 0.0,
      name: 'Genius',
      lastBalanceRetrievalDate: null,
    );
    await saveAccount(account);
    return account;
  }

  Future<Account?> loadAccount() async {
    String? accountData = await _secureStorage.read(key: _accountKeyPrefix);

    if (accountData == null) {
      return null;
    }

    try {
      Account? account = Account.fromJson(
        Map<String, dynamic>.from(jsonDecode(accountData)),
      );
      return account;
    } catch (e) {
      debugPrint('Issue with loading acount');
      debugPrint(e.toString());
      await _secureStorage.delete(key: _accountKeyPrefix);
      return null;
    }
  }

  Future<void> saveAccount(Account account) async {
    await _secureStorage.write(
      key: _accountKeyPrefix,
      value: jsonEncode(account.toJson()),
    );
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
      key: _accountKeyPrefix,
      value: jsonEncode(account.toJson()),
    );
  }

  Future<void> updateAccountFetchDate() async {
    final account = await loadAccount();
    if (account == null) {
      return;
    }

    // store new balance, set retrieval date for rate limiting
    account.lastBalanceRetrievalDate = DateTime.now();

    await _secureStorage.write(
      key: _accountKeyPrefix,
      value: jsonEncode(account.toJson()),
    );
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
      value: storedKey.exportJson(),
    );
  }

  Future<void> saveWatchedWallet(Wallet wallet) async {
    await _secureStorage.write(
      key: createWatchedWalletKey(wallet.address),
      value: jsonEncode(wallet.toJson()),
    );
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
            key: entry.key,
            value: jsonEncode(walletJson),
          );
        } else {
          // For stored-key wallets, parse the JSON, update the name, and save.
          final storedKeyJson = Map<String, dynamic>.from(
            jsonDecode(entry.value),
          );
          storedKeyJson['name'] = newName;
          await _secureStorage.write(
            key: entry.key,
            value: jsonEncode(storedKeyJson),
          );
        }
        return;
      }
    }
  }

  /// A private key and a watch-only row can share one address, so the caller
  /// names which one goes: an address-only match could delete the key.
  ///
  /// A key wallet's current name is frozen onto every SDK link it produced
  /// before the entry is gone, so that account still says whose it was.
  /// Links are never removed here. Watch-only deletes have no SDK account
  /// and never touch links.
  Future<void> deleteWallet(
    String walletAddress, {
    required bool watchOnly,
  }) async {
    final target = watchOnly
        ? createWatchedWalletKey(walletAddress)
        : createWalletKey(walletAddress);
    Map<String, String> keys = await _secureStorage.readAll();

    for (var entry in keys.entries) {
      if (entry.key.toLowerCase() == target) {
        if (!watchOnly) {
          await _freezeLinkNames(walletAddress, entry.value);
        }
        await deleteKey(entry.key);
        return;
      }
    }
  }

  /// Copies the wallet's current name (the field [renameWallet] writes) onto
  /// every link pointing at it, so a deleted wallet's SDK account keeps
  /// reading its last known name. A parse failure leaves link names as they
  /// were.
  Future<void> _freezeLinkNames(String walletAddress, String storedKeyJson) =>
      _linksLock.run(() async {
        try {
          final name =
              Map<String, dynamic>.from(jsonDecode(storedKeyJson))['name']
                  as String?;
          if (name == null) {
            return;
          }
          final lowered = walletAddress.toLowerCase();
          final links = await _readSDKAccountLinks();
          var changed = false;
          for (final sdkAddress in links.keys.toList()) {
            final link = links[sdkAddress]!;
            if (link.walletAddress == lowered && link.walletName != name) {
              links[sdkAddress] = (
                walletAddress: link.walletAddress,
                walletName: name,
              );
              changed = true;
            }
          }
          if (changed) {
            await _writeSDKAccountLinks(links);
          }
        } catch (_) {
          // Leaves link names as they were.
        }
      });

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

  /// Throws on a read failure: reporting "no PIN" would let onboarding
  /// overwrite a real PIN the store merely could not read.
  Future<bool> pinExists() async {
    final storedPin = await _secureStorage.read(key: _pinKey) ?? '';
    return storedPin.isNotEmpty;
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
            Map<String, dynamic>.from(jsonDecode(entry.value)),
          );
          wallets.add(await _fetchBalanceForWatchedWallet(wallet));
        }
      } catch (e) {
        debugPrint('Failed to parse wallet ${entry.key}: $e');
      }
    }

    return wallets;
  }

  Future<StoredKey?> getSDKDefaultWalletKey() async {
    final keys = await _secureStorage.readAll();

    for (final key in sdkDefaultWalletCandidates(keys)) {
      final storedKey = StoredKey.importJson(keys[key]!);
      if (storedKey != null) {
        return storedKey;
      }
    }

    return null;
  }

  /// Wallet entries in the order the SDK default is tried: the default
  /// wallet, then the rest by lowest address, so readAll() order never picks
  /// the key. Watch-only wallets hold no key and are never candidates.
  @visibleForTesting
  List<String> sdkDefaultWalletCandidates(Map<String, String> keys) {
    final candidates = keys.keys.where(isAWallet).toList()..sort();
    final defaultWallet = keys[_sdkDefaultWalletKey];
    // ponytail: if the default wallet is deleted, the lowest address takes
    // over and the SDK gains one account for it; asking the user would avoid
    // that.
    if (defaultWallet != null &&
        candidates.remove(createWalletKey(defaultWallet))) {
      candidates.insert(0, createWalletKey(defaultWallet));
    }
    return candidates;
  }

  /// Every parseable key wallet, in [sdkDefaultWalletCandidates] order.
  /// Watch-only wallets hold no key and are never included.
  Future<List<StoredKey>> getStoredKeys() async {
    final keys = await _secureStorage.readAll();
    final storedKeys = <StoredKey>[];
    for (final key in sdkDefaultWalletCandidates(keys)) {
      final storedKey = StoredKey.importJson(keys[key]!);
      if (storedKey != null) {
        storedKeys.add(storedKey);
      }
    }
    return storedKeys;
  }

  /// Records the wallet the SDK was initialised with, so later starts reuse
  /// its key instead of adding another SDK account.
  Future<void> saveSDKDefaultWalletAddress(String address) async {
    await _secureStorage.write(
      key: _sdkDefaultWalletKey,
      value: address.toLowerCase(),
    );
  }

  /// The wallet each SDK account was produced from, keyed by lowercased SDK
  /// address. Never throws — a missing, corrupt or unreadable value reads as
  /// no links.
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async {
    try {
      return await _readSDKAccountLinks();
    } catch (e) {
      debugPrint('Failed to read SDK account links: $e');
      return {};
    }
  }

  // Throws when storage can't be read or parsed, so a read-modify-write
  // never saves an empty map over links it failed to read.
  Future<Map<String, SDKAccountLink>> _readSDKAccountLinks() async {
    final raw = await _secureStorage.read(key: _sdkAccountLinksKey);
    if (raw == null) {
      return {};
    }
    final decoded = Map<String, dynamic>.from(jsonDecode(raw));
    return decoded.map((sdkAddress, value) {
      final entry = Map<String, dynamic>.from(value as Map);
      return MapEntry(sdkAddress, (
        walletAddress: entry['wallet'] as String,
        walletName: entry['name'] as String,
      ));
    });
  }

  /// Records that [sdkAddress] was produced by [walletAddress], named
  /// [walletName] at link time. Both addresses are lowercased so a later
  /// lookup never misses on case alone.
  Future<void> saveSDKAccountLink(
    String sdkAddress,
    String walletAddress,
    String walletName,
  ) => _linksLock.run(() async {
    final links = await _readSDKAccountLinks();
    links[sdkAddress.toLowerCase()] = (
      walletAddress: walletAddress.toLowerCase(),
      walletName: walletName,
    );
    await _writeSDKAccountLinks(links);
  });

  /// Drops [sdkAddress]'s link entirely (lowercased). Used when its SDK
  /// account is deleted along with its wallet, so a stale link never reads
  /// as "linked" to a wallet that is not coming back.
  Future<void> removeSDKAccountLink(String sdkAddress) =>
      _linksLock.run(() async {
        final links = await _readSDKAccountLinks();
        if (links.remove(sdkAddress.toLowerCase()) == null) {
          return;
        }
        await _writeSDKAccountLinks(links);
      });

  Future<void> _writeSDKAccountLinks(Map<String, SDKAccountLink> links) async {
    await _secureStorage.write(
      key: _sdkAccountLinksKey,
      value: jsonEncode(
        links.map(
          (sdkAddress, link) => MapEntry(sdkAddress, {
            'wallet': link.walletAddress,
            'name': link.walletName,
          }),
        ),
      ),
    );
  }

  // Don't pass any sensitive data to the UI, no privateKey or mnemonic
  Future<Wallet> _toSafeWallet(StoredKeyWallet wallet) async {
    final address = wallet.storedKey.account(0).address();
    final List<Network> networks = await readNetworkAssets();
    final symbol = CoinUtil.getSymbol(wallet.storedKey.account(0).coinType());
    final network = networks.where(
      (element) => (element.symbol) == symbol.toLowerCase(),
    );

    double walletBalance = 0;

    try {
      if (network.isNotEmpty) {
        walletBalance = await _web3.getBalance(
          address: address,
          rpcUrl: network.first.rpcUrl ?? "",
        );
      }
    } catch (e) {
      debugPrint('Failed to fetch wallet balance');
    }

    return Wallet(
      walletName: wallet.storedKey.name(),
      currencySymbol: CoinUtil.getSymbol(
        wallet.storedKey.account(0).coinType(),
      ),
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
      (element) => element.symbol == wallet.currencySymbol.toLowerCase(),
    );

    double walletBalance = 0;

    try {
      if (network.isNotEmpty) {
        walletBalance = await _web3.getBalance(
          address: wallet.address,
          rpcUrl: network.first.rpcUrl ?? "",
        );
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

/// Runs queued operations one at a time, in order; a failure does not block
/// the next operation.
class _SerialQueue {
  Future<void> _tail = Future.value();

  Future<T> run<T>(Future<T> Function() op) {
    final result = _tail.then((_) => op());
    _tail = result.then((_) {}, onError: (_) {});
    return result;
  }
}

/// The Windows backend rewrites one file per write, and a read that lands
/// mid-write fails to decrypt and deletes that file, taking every wallet with
/// it. One process-wide queue keeps reads and writes from overlapping.
class _SerialStorage {
  _SerialStorage(this._storage);

  final FlutterSecureStorage _storage;
  static final _queue = _SerialQueue();

  Future<String?> read({required String key}) =>
      _queue.run(() => _storage.read(key: key));

  Future<Map<String, String>> readAll() => _queue.run(_storage.readAll);

  Future<void> write({required String key, required String? value}) =>
      _queue.run(() => _storage.write(key: key, value: value));

  Future<void> delete({required String key}) =>
      _queue.run(() => _storage.delete(key: key));
}

Future<List<Network>> readNetworkAssets() async {
  const String assetLocation = 'assets/json/networks/networks.json';
  final String? response = await safeLoadAsset(assetLocation);

  if (response == null) {
    return List.empty();
  }

  final networksJson = await jsonDecode(response);

  List<Network> networkList = List<Network>.from(
    networksJson.map((network) => Network.fromJson(network)),
  );

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
