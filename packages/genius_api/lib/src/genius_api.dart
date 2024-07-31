import 'dart:async';
import 'dart:math';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/models/currency.dart';
import 'package:genius_api/models/events.dart';
import 'package:genius_api/models/news.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_api/models/user.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/util/tw_string_impl.dart';
import 'package:secure_storage/secure_storage.dart';

class GeniusApi {
  final SecureStorage _secureStorage;
  final FFIBridgePrebuilt ffiBridgePrebuilt;
  final String passphrase = "gnusai";

  /// Returns a [Stream] of the wallets that the device has saved.
  Stream<List<Wallet>> getWallets() =>
      _secureStorage.walletsController.asBroadcastStream();

  Future<void> saveWallet(Wallet wallet) async =>
      await _secureStorage.saveWallet(wallet);

  GeniusApi({
    required SecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        ffiBridgePrebuilt = FFIBridgePrebuilt() {
    //ffiBridgePrebuilt.wallet_lib.GeniusSDKInit();
  }

  Future<List<Transaction>> getTransactionsFor(String address) async {
    //TODO: Implement getting these from Genius API
    return [
      Transaction(
        hash:
            '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02',
        fromAddress: '0x0',
        toAddress: '0x1',
        timeStamp: '13:26, 10 oct 2022',
        transactionDirection: TransactionDirection.sent,
        amount: '0.0002',
        fees: '',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.pending,
      ),
      Transaction(
          hash:
              '7f5979fb78f082e8b1c676635db8795c4ac6faba03525fb708cb5fd68fd40c5e',
          fromAddress: '0x2',
          toAddress: '0x0',
          timeStamp: '15:20, 09 oct 2022',
          transactionDirection: TransactionDirection.received,
          amount: '0.0003',
          fees: '',
          coinSymbol: 'ETH',
          transactionStatus: TransactionStatus.cancelled),
      Transaction(
        hash:
            '6146ccf6a66d994f7c363db875e31ca35581450a4bf6d3be6cc9ac79233a69d0',
        fromAddress: '0x1',
        toAddress: '0x0',
        timeStamp: '15:22, 10 oct 2022',
        transactionDirection: TransactionDirection.received,
        amount: '0.0023',
        fees: '0.000001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
      ),
    ];
  }

  Future<List<Wallet>> getUserWallets(String id) async {
    await Future.delayed(Duration(seconds: 5));
    //TODO: Implement this with the Genius API
    return [
      Wallet(
        walletName: 'My Ethereum Wallet',
        currencyName: 'Ethereum',
        currencySymbol: 'ETH',
        address: '0x0',
        // balance: 1000,
        balance: 0,
        transactions: await getTransactionsFor('0x0'),
      ),
      Wallet(
        walletName: 'My Bitcoin Wallet',
        currencyName: 'Bitcoin',
        currencySymbol: 'BTC',
        address: '0x1234asdf5678jklp',
        // balance: 1000,
        balance: 12460,
        transactions: [],
      ),
    ];
  }

  Future<User> getUser() async {
    //TODO: Implement this with Genius API. At the time of implementing,
    //no authentication method was specified so mocking the method for now.

    return User(
      firstName: 'John',
      lastName: 'Doe',
      nickname: 'jdoe',
      email: 'jdoe@email.com',
      dateOfBirth: '01/01/1990',
      profilePictureUrl: '',
      wallets: await getUserWallets('some_id?'),
    );
  }

  Future<int> getGasFees() async {
    return 100;
  }

  Future<void> storeUserPin(String pin) async =>
      await _secureStorage.storeUserPin(pin);

  Future<Transaction> postTransaction(Transaction transaction) async {
    await Future.delayed(Duration(seconds: 5));

    ///TODO: Alter this method to actually post the transaction
    return transaction.copyWith(
      timeStamp: DateTime.now().toIso8601String(),
      hash: transaction.hashCode.toString(),
    );
  }

  /// Converts [fiatAmount] in USD to [cryptoCurrency].
  ///
  /// Returns a [num] of how many coins [fiatAmount] converts to.
  Future<num> getConversion(num fiatAmount, String cryptoCurrency) async {
    await Future.delayed(Duration(seconds: 1));

    return fiatAmount / 1551.40;
  }

  /// Returns a list of supported [Currencies] for calculating conversions
  Future<List<Currency>> getCalculatorCurrencies() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Currency(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: '16949.30',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
      Currency(
        symbol: 'ETH',
        name: 'Ethereum',
        price: '1268.94',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
    ];
  }

  /// Converts [fromCurrency] to [toCurrency] and returns a [String] representation of the conversion.
  Future<String> convertCurrencies(
      {required Currency fromCurrency, required Currency toCurrency}) async {
    await Future.delayed(Duration(seconds: 1));
    final randomNum = Random().nextDouble() * 500;

    return randomNum.toStringAsFixed(2);
  }

  /// Verifies that the saved user pin matches [pin].
  Future<bool> verifyUserPin(String pin) async =>
      await _secureStorage.verifyUserPin(pin);

  Future<bool> userExists() async => await _secureStorage.pinExists();

  //TODO: solidify the wallet security options into a class once we know how this will be handled in the API.
  Future<Wallet?> validateWalletImport({
    required String walletName,
    required String walletType,
    required String securityType,
    required String securityValue,
    String? password,
  }) async {
    await Future.delayed(Duration(seconds: 5));

    final random = Random().nextInt(999999);

    final importedWallet = Wallet(
      walletName: walletName,
      currencySymbol: walletType,
      currencyName: walletType,
      balance: 1000,
      address: random.toString(),
      transactions: [],
    );

    await _secureStorage.saveWallet(importedWallet);

    return importedWallet;
  }

  String? getHRPStrideValue() {
    return ffiBridgePrebuilt.wallet_lib
        .stringForHRP(TWHRP.TWHRPStride)
        .cast<Utf8>()
        .toDartString();
  }

  Pointer<Void> createWalletWithSize(int size) {
    return ffiBridgePrebuilt.wallet_lib.TWDataCreateWithSize(size);
  }

  void mintTokens(int amount) {
    //ffiBridgePrebuilt.wallet_lib.GeniusSDKMint(amount);
  }
  void requestAIProcess() {
    //String job_id = "QmUDMvGQXbUKMsjmTzjf4ZuMx7tHx6Z4x8YH8RbwrgyGAf";
//
    //Pointer<Char> charPointer = malloc.allocate<Char>(job_id.length + 1);
//
    //for (int i = 0; i < job_id.length; i++) {
    //  charPointer.elementAt(i).value = job_id.codeUnitAt(i);
    //}
    //charPointer.elementAt(job_id.length).value = 0;
//
    //ffiBridgePrebuilt.wallet_lib.GeniusSDKProcess(charPointer, 100);
//
    //malloc.free(charPointer);
  }

  Future<List<Currency>> getMarkets() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Currency(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: '17000',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
      Currency(
        symbol: 'ETH',
        name: 'Ethereum',
        price: '1300',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
    ];
  }

  Future<List<Currency>> get() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Currency(
        symbol: 'BTC',
        name: 'Bitcoin',
        price: '17000',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
      Currency(
        symbol: 'ETH',
        name: 'Ethereum',
        price: '1300',
        priceCurrency: 'USD',
        priceDate: DateTime.now().toIso8601String(),
      ),
    ];
  }

  // Only built to show 5 max. This layout is complex
  Future<List<News>> getNews() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      News(
          headline: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
          date: 'Jan 09, 2024',
          imgSrc:
              'https://media.istockphoto.com/id/1488521147/photo/global-network-usa-united-states-of-america-north-america-global-business-flight-routes.jpg?s=2048x2048&w=is&k=20&c=MVLf6tCo7bEIhyR8hRlJyiTtej0gZmiaZQyk6Wh2qkY='),
      News(
          headline: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
          date: 'Jan 09, 2024',
          imgSrc:
              'https://media.istockphoto.com/id/1488521147/photo/global-network-usa-united-states-of-america-north-america-global-business-flight-routes.jpg?s=2048x2048&w=is&k=20&c=MVLf6tCo7bEIhyR8hRlJyiTtej0gZmiaZQyk6Wh2qkY='),
      News(
          headline: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
          date: 'Jan 09, 2024',
          imgSrc:
              'https://media.istockphoto.com/id/1488521147/photo/global-network-usa-united-states-of-america-north-america-global-business-flight-routes.jpg?s=2048x2048&w=is&k=20&c=MVLf6tCo7bEIhyR8hRlJyiTtej0gZmiaZQyk6Wh2qkY='),
      News(
          headline: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
          date: 'Jan 09, 2024',
          imgSrc:
              'https://media.istockphoto.com/id/1488521147/photo/global-network-usa-united-states-of-america-north-america-global-business-flight-routes.jpg?s=2048x2048&w=is&k=20&c=MVLf6tCo7bEIhyR8hRlJyiTtej0gZmiaZQyk6Wh2qkY='),
      News(
          headline: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit',
          body:
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum',
          date: 'Jan 09, 2024',
          imgSrc:
              'https://media.istockphoto.com/id/1488521147/photo/global-network-usa-united-states-of-america-north-america-global-business-flight-routes.jpg?s=2048x2048&w=is&k=20&c=MVLf6tCo7bEIhyR8hRlJyiTtej0gZmiaZQyk6Wh2qkY=')
    ];
  }

  Future<List<Events>> getEvents() async {
    await Future.delayed(Duration(seconds: 2));
    return [
      Events(
          body: 'Blockchain in Energy Conference',
          date: 'October 5',
          location: 'Rome',
          weekDay: "Monday"),
      Events(
          body: 'Blockchain in Energy Conference 2',
          date: 'October 8',
          location: 'Rome',
          weekDay: "Thursday"),
      Events(
          body: 'Blockchain in Energy Conference 3',
          date: 'October 9',
          location: 'Rome',
          weekDay: "Friday"),
      Events(
          body: 'Blockchain in Energy Conference 4',
          date: 'October 22',
          location: 'Rome',
          weekDay: "Monday"),
      Events(
          body: 'Blockchain in Energy Conference 5',
          date: 'October 23',
          location: 'Rome',
          weekDay: "Tuesday"),
    ];
  }

  Pointer<TWHDWallet> createNewWallet() {
    Pointer<Utf8> passphraseTWString = TWStringImpl.toTWString(passphrase);
    Pointer<TWHDWallet> wallet = ffiBridgePrebuilt.wallet_lib
        .TWHDWalletCreate(128, passphraseTWString.cast());

    TWStringImpl.delete(passphraseTWString);
    // print(mnemonic.toDartString());

// delete wallet
    //ffiBridgePrebuilt.wallet_lib.TWHDWalletDelete(wallet);
    return wallet;
  }

  // Take in a created wallet, generate the mnemonic and send back the words
  Future<List<String>> getRecoveryPhrase(Pointer<TWHDWallet> wallet) async {
    Pointer<TWString1> walletMnemonic =
        ffiBridgePrebuilt.wallet_lib.TWHDWalletMnemonic(wallet);
    // TODO: fix this casting ( fix in wallet-core to return the correct type )
    Pointer<Utf8> mnemonic = ffiBridgePrebuilt.wallet_lib
        .TWStringUTF8Bytes(walletMnemonic) as Pointer<Utf8>;
    String mnemonicStr = mnemonic.toDartString();
    return mnemonicStr.split(' ');
  }
}
