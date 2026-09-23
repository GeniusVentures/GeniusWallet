import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

/// Secure storage that fails every read, as a locked keychain does.
class _UnreadableStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) => Future.error(PlatformException(code: 'locked'));
}

void main() {
  const raw = FlutterSecureStorage();
  late LocalWalletStorage storage;

  Future<LocalWalletStorage> withValues(Map<String, String> values) {
    FlutterSecureStorage.setMockInitialValues(values);
    return LocalWalletStorage.create(secureStorage: raw);
  }

  setUp(() async {
    storage = await withValues({});
  });

  group('PIN', () {
    test('a stored PIN verifies and a wrong one does not', () async {
      await storage.storeUserPin('1234');

      expect(await storage.pinExists(), isTrue);
      expect(await storage.verifyUserPin('1234'), isTrue);
      expect(await storage.verifyUserPin('0000'), isFalse);
      expect(await storage.verifyUserPin(''), isFalse);
    });

    test('with no PIN stored, nothing verifies — not even empty', () async {
      expect(await storage.pinExists(), isFalse);
      expect(await storage.verifyUserPin(''), isFalse);
      expect(await storage.verifyUserPin('1234'), isFalse);
    });

    test('an empty stored PIN counts as no PIN', () async {
      storage = await withValues({'__pin_key__': ''});

      expect(await storage.pinExists(), isFalse);
      expect(await storage.verifyUserPin(''), isFalse);
    });

    test('changing the PIN retires the old one', () async {
      await storage.storeUserPin('1234');
      await storage.storeUserPin('5678');

      expect(await storage.verifyUserPin('1234'), isFalse);
      expect(await storage.verifyUserPin('5678'), isTrue);
    });

    test('an unreadable store fails closed', () async {
      storage = await LocalWalletStorage.create(
        secureStorage: _UnreadableStorage(),
      );

      expect(await storage.pinExists(), isFalse);
      expect(await storage.verifyUserPin('1234'), isFalse);
    });
  });

  group('account', () {
    test('init creates the default account when none exists', () async {
      await storage.init();

      final account = await storage.loadAccount();
      expect(account?.name, 'Genius');
      expect(account?.balance, 0.0);
    });

    test('init keeps an existing account', () async {
      await storage.saveAccount(Account(name: 'Mine', balance: 50.0));

      await storage.init();

      expect((await storage.loadAccount())?.name, 'Mine');
    });

    test('a corrupt account is dropped, not thrown', () async {
      storage = await withValues({'__account__': 'not json'});

      expect(await storage.loadAccount(), isNull);
      expect(await raw.read(key: '__account__'), isNull);
    });

    test('deleteAccount removes the account and leaves the PIN', () async {
      await storage.storeUserPin('1234');
      await storage.saveAccount(Account(name: 'Mine', balance: 1.0));

      await storage.deleteAccount();

      expect(await storage.loadAccount(), isNull);
      expect(await storage.verifyUserPin('1234'), isTrue);
    });
  });

  group('watched wallets', () {
    const address = '0xD1D5c3416980365ff8A6129c9f8dd01F38719555';
    const wallet = Wallet(
      coinType: TWCoinType.TWCoinTypeEthereum,
      walletName: 'Ethereum Wallet',
      currencySymbol: 'ETH',
      walletType: WalletType.tracking,
      balance: 0.0,
      address: address,
    );

    test('are saved under a lowercased address key', () async {
      await storage.saveWatchedWallet(wallet);

      final stored = await raw.read(
        key: '__watches_key__${address.toLowerCase()}',
      );
      expect(Wallet.fromJson(jsonDecode(stored!)), wallet);
    });

    test('rename and delete match the address case-insensitively', () async {
      await storage.saveWatchedWallet(wallet);

      await storage.renameWallet(address.toUpperCase(), 'Renamed');
      final key = storage.createWatchedWalletKey(address);
      final renamed = Wallet.fromJson(jsonDecode((await raw.read(key: key))!));
      expect(renamed.walletName, 'Renamed');

      await storage.deleteWallet(address.toUpperCase());
      expect(await raw.read(key: key), isNull);
    });
  });
}
