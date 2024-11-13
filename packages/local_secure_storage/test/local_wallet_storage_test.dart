import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:local_secure_storage/src/local_secure_storage_base.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:mockito/annotations.dart';

import 'local_wallet_storage_test.mocks.dart';

@GenerateMocks([Web3])
@GenerateMocks([FlutterSecureStorage])
void main() {
  group('LocalWalletStorage Tests', () {
    late LocalWalletStorage localWalletStorage;
    late MockFlutterSecureStorage mockSecureStorage;
    late MockWeb3 mockWeb3;

    setUp(() async {
      mockWeb3 = MockWeb3();
      mockSecureStorage = MockFlutterSecureStorage();
      localWalletStorage = await LocalWalletStorage.create(
          secureStorage: mockSecureStorage, web3: mockWeb3);
    });

    group('init', () {
      test('should create a new account if none exists', () async {
        when(mockSecureStorage.readAll())
            .thenAnswer((_) async => <String, String>{});
        when(mockSecureStorage.read(key: '__account__'))
            .thenAnswer((_) async => null);

        await localWalletStorage.init();

        Account expectedAccount = Account(balance: 0.0, name: 'Genius');

        verify(mockSecureStorage.write(
          key: '__account__',
          value: jsonEncode(expectedAccount.toJson()),
        )).called(1);
      });
      test('should not create a new account if one already exists', () async {
        when(mockSecureStorage.readAll())
            .thenAnswer((_) async => <String, String>{});
        when(mockSecureStorage.read(key: '__account__')).thenAnswer((_) async =>
            jsonEncode(Account(balance: 0.0, name: 'Genius').toJson()));

        await localWalletStorage.init();

        verifyNever(mockSecureStorage.write(
            key: anyNamed('key'), value: anyNamed('value')));
      });
      test('should load watched wallet from storage', () async {
        final Map<String, String> watchedWalletSavedData = {
          '__watches_key__0xd1d5c3416980365ff8a6129c9f8dd01f38719555': """{
              "coinType": 60,
              "walletName": "Ethereum Wallet",
              "currencySymbol": "ETH",
              "walletType": "tracking",
              "balance": 0.0,
              "address": "0xD1D5c3416980365ff8A6129c9f8dd01F38719555",
              "transactions": []
            }"""
        };

        when(mockSecureStorage.readAll())
            .thenAnswer((_) async => watchedWalletSavedData);
        when(mockSecureStorage.read(key: '__account__'))
            .thenAnswer((_) async => null);
        when(mockWeb3.getBalance(
                rpcUrl: anyNamed('rpcUrl'), address: anyNamed('address')))
            .thenAnswer((_) async => 0.0);

        await localWalletStorage.init();

        expect(
            localWalletStorage.walletsController.value.first,
            equals(Wallet(
                coinType: 60,
                address: '0xD1D5c3416980365ff8A6129c9f8dd01F38719555',
                balance: 0.0,
                walletName: 'Ethereum Wallet',
                currencySymbol: 'ETH',
                transactions: [],
                walletType: WalletType.tracking)));
      });
    });

    group('loadAccount', () {
      test('should load an existing account from secure storage', () async {
        final accountData = Account(
                balance: 50.0,
                name: 'Genius',
                lastBalanceRetrievalDate: DateTime.now())
            .toJson();
        when(mockSecureStorage.read(key: '__account__'))
            .thenAnswer((_) async => jsonEncode(accountData));

        final account = await localWalletStorage.loadAccount();
        expect(account?.name, 'Genius');
        expect(account?.balance, 50.0);
      });
    });

    group('saveAccount', () {
      test('should save an account to secure storage', () async {
        final account = Account(
            balance: 100.0,
            name: 'Test Account',
            lastBalanceRetrievalDate: DateTime.now());

        await localWalletStorage.saveAccount(account);

        verify(mockSecureStorage.write(
          key: '__account__',
          value: jsonEncode(account.toJson()),
        )).called(1);
      });
    });

    group('deleteAccount', () {
      test('should delete an account from secure storage', () async {
        when(mockSecureStorage.readAll()).thenAnswer((_) async => {
              '__account__':
                  jsonEncode(Account(balance: 0.0, name: 'Genius').toJson())
            });

        await localWalletStorage.deleteAccount();

        verify(mockSecureStorage.write(key: '__account__', value: null))
            .called(1);
      });
    });

    group('storeUserPin', () {
      test('should store a user PIN in secure storage', () async {
        const pin = '1234';
        await localWalletStorage.storeUserPin(pin);

        verify(mockSecureStorage.write(key: '__pin_key__', value: pin))
            .called(1);
      });
    });

    group('verifyUserPin', () {
      test('should verify the user PIN correctly', () async {
        const pin = '1234';
        when(mockSecureStorage.read(key: '__pin_key__'))
            .thenAnswer((_) async => pin);

        final isValid = await localWalletStorage.verifyUserPin(pin);
        expect(isValid, true);

        final isInvalid = await localWalletStorage.verifyUserPin('0000');
        expect(isInvalid, false);
      });
    });

    group('pinExists', () {
      test('should check if a PIN exists', () async {
        when(mockSecureStorage.read(key: '__pin_key__'))
            .thenAnswer((_) async => '1234');

        final exists = await localWalletStorage.pinExists();
        expect(exists, true);

        when(mockSecureStorage.read(key: '__pin_key__'))
            .thenAnswer((_) async => null);

        final notExists = await localWalletStorage.pinExists();
        expect(notExists, false);
      });
    });

    group('saveWatchedWallet', () {
      test('should add a watched wallet to the controller and secure storage',
          () async {
        final wallet = Wallet(
            coinType: 1,
            currencySymbol: "eth",
            walletType: WalletType.tracking,
            walletName: 'Test Wallet',
            address: '0x123',
            balance: 0,
            transactions: []);
        const testKey = '__test_key__';
        const testValue = '__test_value__';

        when(mockSecureStorage.write(
          key: testKey,
          value: testValue,
        )).thenAnswer((_) async => {});

        await localWalletStorage.saveWatchedWallet(wallet);

        expect(localWalletStorage.walletsController.value, contains(wallet));

        verify(mockSecureStorage.write(
          key: '__watches_key__0x123',
          value: jsonEncode(wallet.toJson()),
        )).called(1);
      });
    });

    group('deleteAllWallets', () {
      test('should delete all wallets from controller and secure storage',
          () async {
        when(mockSecureStorage.readAll()).thenAnswer((_) async => {
              'wallet_0x123': jsonEncode(Wallet(
                  coinType: 1,
                  currencySymbol: "eth",
                  walletType: WalletType.mnemonic,
                  walletName: 'Wallet1',
                  address: '0x123',
                  balance: 50,
                  transactions: []).toJson()),
              '__watches_key__0x456': jsonEncode(Wallet(
                  coinType: 1,
                  currencySymbol: "eth",
                  walletType: WalletType.mnemonic,
                  walletName: 'Wallet2',
                  address: '0x456',
                  balance: 100,
                  transactions: []).toJson()),
            });

        await localWalletStorage.deleteAllWallets();

        verify(mockSecureStorage.write(key: 'wallet_0x123', value: null))
            .called(1);
        verify(mockSecureStorage.write(
                key: '__watches_key__0x456', value: null))
            .called(1);
        expect(localWalletStorage.walletsController.value, isEmpty);
      });
    });
  });
}
