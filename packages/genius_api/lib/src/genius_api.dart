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
import 'package:genius_api/models/wallet_stored.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/string_util.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:secure_storage/secure_storage.dart';

class GeniusApi {
  final SecureStorage _secureStorage;
  final FFIBridgePrebuilt ffiBridgePrebuilt;

  /// Returns a [Stream] of the wallets that the device has saved.
  Stream<List<Wallet>> getWallets() {
    return _secureStorage.walletsController.asBroadcastStream();
  }

  GeniusApi({
    required SecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        ffiBridgePrebuilt = FFIBridgePrebuilt() {
    //ffiBridgePrebuilt.wallet_lib.GeniusSDKInit();
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

  HDWallet createNewWallet() {
    return HDWallet();
  }

  // Take in a created wallet and return the mnemonic
  Future<List<String>> getRecoveryPhrase(HDWallet wallet) async {
    return wallet.mnemonic().split(' ');
  }

  // TODO: should we save the wallet in local storage encrypted with the users password/pin?
  // Will save the mnemonic of the wallet for now.
  // TODO: how many coin addresses do we want to save / support, for now just ETH
  // maybe allow users to add new networks through the UI?
  // TODO: add support for multiple currencies in a single wallet
  //       convert currenty symbol, currency name, address to a list
  Future<void> saveWallet(HDWallet wallet) async {
    String mnemonic = wallet.mnemonic();
    String ethAddress = wallet.getAddressForCoin(TWCoinType.TWCoinTypeEthereum);
    String currencySymbol = StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWCoinTypeConfigurationGetSymbol(TWCoinType.TWCoinTypeEthereum)
        .cast());
    String walletName = wallet.name ??
        "${ethAddress.substring(0, 5)}...${ethAddress.substring(ethAddress.length - 4)}";

    final walletStored = WalletStored(
        walletName: walletName,
        currencySymbol: currencySymbol,
        currencyName: "Ethereum",
        mnemonic: mnemonic,
        address: ethAddress);
    await _secureStorage.saveWallet(walletStored);
  }

  // TODO: this still needs implemented from GNUS sdk
  Future<List<Transaction>> getTransactionsFor(String address) async {
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

  // TODO: add other import methods (security types)
  Future<Wallet?> validateWalletImport({
    required String walletName,
    required String walletType,
    required SecurityType securityType,
    required String securityValue,
    String? password,
  }) async {
    if (!ffiBridgePrebuilt.wallet_lib
        .TWMnemonicIsValid(StringUtil.toTWString(securityValue).cast())) {
      return null;
    }

    HDWallet wallet =
        HDWallet.createWithMnemonic(securityValue, passphrase: "");
    wallet.setName(walletName);

    // TODO: add support for other coin types
    String ethAddress = wallet.getAddressForCoin(TWCoinType.TWCoinTypeEthereum);
    String currencySymbol = StringUtil.toDartString(ffiBridgePrebuilt.wallet_lib
        .TWCoinTypeConfigurationGetSymbol(TWCoinType.TWCoinTypeEthereum)
        .cast());

    final importedWallet = Wallet(
      walletName: walletName,
      currencySymbol: currencySymbol,
      currencyName: "Ethereum",
      balance: 0,
      address: ethAddress,
      transactions: [],
    );

    await saveWallet(wallet);

    return importedWallet;
  }

  Future<void> deleteWallet(String address) async {
    await _secureStorage.deleteWallet(address);
  }
}
