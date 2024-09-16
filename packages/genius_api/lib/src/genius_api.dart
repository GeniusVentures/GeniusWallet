import 'dart:async';
import 'dart:math';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/events.dart';
import 'package:genius_api/models/news.dart';
import 'package:genius_api/tw/any_address.dart';
import 'package:genius_api/tw/coin_util.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/stored_key.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:secure_storage/secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:genius_api/proto/SGTransaction.pb.dart';
import 'package:flutter/services.dart' show rootBundle;

class GeniusApi {
  final SecureStorage _secureStorage;
  final FFIBridgePrebuilt ffiBridgePrebuilt;
  late final String address;
  late final String jsonFilePath;

  /// Returns a [Stream] of the wallets that the device has saved.
  Stream<List<Wallet>> getWallets() {
    return _secureStorage.walletsController.asBroadcastStream();
  }

  Future<Account?> getAccount() async {
    return await _secureStorage.loadAccount();
  }

  Future<void> saveAccount(Account account) async {
    return await _secureStorage.saveAccount(account);
  }

  Future<void> saveAccountBalance(double balance) async {
    return await _secureStorage.saveAccountBalance(balance);
  }

  Future<void> updateAccountFetchDate() async {
    return await _secureStorage.updateAccountFetchDate();
  }

  GeniusApi({
    required SecureStorage secureStorage,
  })  : _secureStorage = secureStorage,
        ffiBridgePrebuilt = FFIBridgePrebuilt();

  Future<void> initSDK() async {
    jsonFilePath = await copyJsonToWritableDirectory();
    final basePathPtr = jsonFilePath.toNativeUtf8();
    final retVal = ffiBridgePrebuilt.wallet_lib.GeniusSDKInit(basePathPtr);
    address = getAddress();
    String dartString = retVal.toDartString();
    print(dartString);
    malloc.free(basePathPtr);
  }

  Future<String> copyJsonToWritableDirectory() async {
    // Get the directory to store files
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/dev_config.json';

    // Copy the asset file to the directory
    final jsonString = await rootBundle.loadString('assets/dev_config.json');
    final file = File(filePath);
    await file.writeAsString(jsonString);

    // Return the file path to be used in FFI
    return '${directory.path}/';
  }

  Future<double> getGasFees() async {
    return .001;
  }

  Future<void> storeUserPin(String pin) async =>
      await _secureStorage.storeUserPin(pin);

  Future<Transaction> postTransaction(Transaction transaction) async {
    await Future.delayed(Duration(seconds: 5));

    ///TODO: Alter this method to actually post the transaction
    return transaction.copyWith(
      timeStamp: DateTime.now(),
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
    ffiBridgePrebuilt.wallet_lib.GeniusSDKMintTokens(amount);
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

  // TODO: this still needs implemented from GNUS sdk
  Future<List<Transaction>> getTransactionsFor(String address) async {
    return [
      Transaction(
        hash:
            '5f16f4c7f149ac4f9510d9cf8cf384038ad348b3bcdc01915f95de12df9d1b02',
        fromAddress: '0x0',
        toAddress: '0x1',
        timeStamp: DateTime.utc(2022, 10, 10, 13, 26),
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
          timeStamp: DateTime.utc(2022, 10, 09, 15, 20),
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
        timeStamp: DateTime.utc(2022, 10, 10, 15, 22),
        transactionDirection: TransactionDirection.received,
        amount: '0.0023',
        fees: '0.000001',
        coinSymbol: 'ETH',
        transactionStatus: TransactionStatus.completed,
      ),
    ];
  }

  // Currently we just create a account with Ethereum wallet for the user
  Future<void> saveWallet(HDWallet wallet) async {
    String mnemonic = wallet.mnemonic();
    String ethAddress = wallet.getAddressForCoin(TWCoinType.TWCoinTypeEthereum);
    String walletName = wallet.name ??
        "${ethAddress.substring(0, 5)}...${ethAddress.substring(ethAddress.length - 4)}";
    StoredKey? storedKey = StoredKey.importHDWallet(
        mnemonic, walletName, "", TWCoinType.TWCoinTypeEthereum);

    if (storedKey == null) {
      return;
    }

    await _secureStorage.saveStoredKey(storedKey);
  }

  Future<bool> validateWalletImport({
    required int coinType,
    required String walletName,
    required String walletType,
    required SecurityType securityType,
    required String securityValue,
    String? password,
  }) async {
    if (securityType == SecurityType.passphrase) {
      return await importWalletFromMnemonic(
          securityValue, walletName, coinType);
    }

    if (securityType == SecurityType.privateKey) {
      return await importWalletFromPrivateKey(
          securityValue, walletName, coinType);
    }

    if (securityType == SecurityType.address) {
      return await importWalletFromAddress(securityValue, walletName, coinType);
    }

    if (securityType == SecurityType.keystore) {
      return await importWalletFromKeyStore(
          securityValue, password, walletName, coinType);
    }

    return false;
  }

  Future<bool> importWalletFromKeyStore(
      String json, String? password, String walletName, int coinType) async {
    StoredKey? storedKey = StoredKey.importJson(json);

    if (storedKey == null) {
      return false;
    }

    final mnemonic = storedKey.decryptMnemonic(
        Uint8List.fromList(password?.codeUnits ?? List.empty()));

    final pk = hex.encode(storedKey.decryptPrivateKey(
            Uint8List.fromList(password?.codeUnits ?? List.empty())) ??
        List.empty());

    if (mnemonic == null || pk == "") {
      return false;
    }

    await _secureStorage.saveStoredKey(storedKey);

    return true;
  }

  Future<bool> importWalletFromAddress(address, walletName, coinType) async {
    if (!AnyAddress.isValid(address, coinType)) {
      print('Invalid Address');
      return false;
    }

    await _secureStorage.saveWatchedWallet(Wallet(
        balance: 0,
        walletName: walletName,
        currencySymbol: CoinUtil.getSymbol(coinType),
        coinType: coinType,
        walletType: WalletType.tracking,
        transactions: [],
        address: address));

    return true;
  }

  Future<bool> importWalletFromMnemonic(
      String mnemonic, String walletName, int coinType) async {
    StoredKey? storedKey =
        StoredKey.importHDWallet(mnemonic, walletName, "", coinType);

    if (storedKey == null) {
      return false;
    }

    await _secureStorage.saveStoredKey(storedKey);

    return true;
  }

  Future<bool> importWalletFromPrivateKey(
      String privateKey, String walletName, int coinType) async {
    final privateKeyData = Uint8List.fromList(hex.decode(privateKey));
    StoredKey? storedKey =
        StoredKey.importPrivateKey(privateKeyData, walletName, "", coinType);

    if (storedKey == null) {
      return false;
    }

    await _secureStorage.saveStoredKey(storedKey);

    return true;
  }

  Future<void> deleteWallet(String address) async {
    await _secureStorage.deleteWallet(address);
  }

  Future<void> getWalletTransactions(String address) async {}

  Future<double> getWalletBalance(String rpcUrl, String address) async {
    return await Web3().getBalance(rpcUrl: rpcUrl, address: address);
  }

  int getBalance() {
    return ffiBridgePrebuilt.wallet_lib.GeniusSDKGetBalance();
  }

  /// Returns address as a hexadecimal string, with 64 hex characters prepended
  /// by `0x`.
  String getAddress() {
    var address = ffiBridgePrebuilt.wallet_lib.GeniusSDKGetAddress();

    List<int> charCodes =
        List<int>.generate(66, (index) => address.address[index]);

    return String.fromCharCodes(charCodes);
  }

  List<Transaction> getTransactions() {
    var transactions = ffiBridgePrebuilt.wallet_lib.GeniusSDKGetTransactions();

    List<Transaction> ret = List.generate(transactions.size, (i) {
      var buffer =
          transactions.ptr[i].ptr.asTypedList(transactions.ptr[i].size);
      var struct = DAGWrapper.fromBuffer(buffer).dagStruct;

      var fromAddress = String.fromCharCodes(struct.sourceAddr);

      Transaction trans = Transaction(
          hash: String.fromCharCodes(struct.dataHash),
          fromAddress: fromAddress,
          toAddress: "não sei",
          timeStamp: DateTime.fromMicrosecondsSinceEpoch(
              struct.timestamp.toInt() ~/ 1000),
          transactionDirection: address == fromAddress
              ? TransactionDirection.sent
              : TransactionDirection.received, // não sei
          amount: '69', // não sei
          fees: '0',
          coinSymbol: 'GNUS',
          transactionStatus: TransactionStatus.completed,
          type: TransactionType.fromString(struct.type));

      return trans;
    });

    ffiBridgePrebuilt.wallet_lib.GeniusSDKFreeTransactions(transactions);

    return ret;
  }

  bool transferTokens(int amount, String address) {
    final convertedAddress = calloc<GeniusAddress>();

    final bytes = Uint8List.fromList(address.codeUnits);

    for (int i = 0; i < address.length; ++i) {
      convertedAddress.ref.address[i] = bytes[i];
    }

    final ret = ffiBridgePrebuilt.wallet_lib
        .GeniusSDKTransferTokens(amount, convertedAddress);

    calloc.free(convertedAddress);

    return ret;
  }
}
