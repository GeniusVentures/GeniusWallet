import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:ffi/ffi.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/events.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/tw/any_address.dart';
import 'package:genius_api/tw/coin_util.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/stored_key.dart';
import 'package:genius_api/types/security_type.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:local_secure_storage/local_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:genius_api/proto/SGTransaction.pb.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:rxdart/rxdart.dart';
import 'package:permission_handler/permission_handler.dart';

class GeniusApi {
  final LocalWalletStorage _secureStorage;
  final FFIBridgePrebuilt ffiBridgePrebuilt;
  final SGNUSConnectionController _sgnusConnectionController;
  late final String address;
  late final String jsonFilePath;
  bool isSdkInitialized = false;

  GeniusApi({
    required LocalWalletStorage secureStorage,
  })  : _secureStorage = secureStorage,
        ffiBridgePrebuilt = FFIBridgePrebuilt(),
        _sgnusConnectionController = SGNUSConnectionController();

  Future<void> requestPermissions() async {
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }
    } catch (e) {
      print("❌ Failed to check permissions ${e.toString()}");
    }
  }

  /// Returns a [Stream] of the wallets that the device has saved.
  Stream<List<Wallet>> getWallets() {
    return getWalletsController().asBroadcastStream();
  }

  BehaviorSubject<List<Wallet>> getWalletsController() {
    return _secureStorage.walletsController;
  }

  SGNUSConnectionController getSGNUSController() {
    return _sgnusConnectionController;
  }

  Stream<SGNUSConnection> getSGNUSConnectionStream() {
    return getSGNUSController().stream;
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

  Future<void> initSDK() async {
    requestPermissions();
    final storedKey = await _secureStorage.getSGNUSLinkedWalletPrivateKey();

    if (storedKey == null) {
      print("No suitable wallet found");
      return;
    }

    await _initSDK(storedKey);
  }

  Future<void> _initSDK(StoredKey storedKey) async {
    if (isSdkInitialized) {
      return;
    }

    PrivateKey privateKey;

    if (storedKey.isMnemonic()) {
      privateKey =
          storedKey.wallet("")!.getKeyForCoin(TWCoinType.TWCoinTypeEthereum);
    } else {
      privateKey =
          storedKey.privateKey(TWCoinType.TWCoinTypeEthereum, Uint8List(0))!;
    }

    jsonFilePath = await copyJsonToWritableDirectory();
    final basePathPtr = jsonFilePath.toNativeUtf8();

    final privateKeyAsStr = privateKey
        .data()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    final privateKeyAsPtr = privateKeyAsStr.toNativeUtf8();
    print('Json File Path: ${jsonFilePath}');
    final retVal = ffiBridgePrebuilt.wallet_lib
        .GeniusSDKInit(basePathPtr, privateKeyAsPtr, true, true, 41001);

    if (retVal == nullptr) {
      return;
    }

    address = getSGNUSAddress();

    malloc.free(basePathPtr);
    malloc.free(privateKeyAsPtr);

    // Update UI with SGNUS connection status
    getSGNUSController().updateConnection(SGNUSConnection(
        sgnusAddress: address,
        walletAddress: storedKey
                .wallet("")
                ?.getAddressForCoin(TWCoinType.TWCoinTypeEthereum) ??
            "",
        isConnected: true));

    isSdkInitialized = true;
  }

  Future<String> copyJsonToWritableDirectory() async {
    try {
      // Get the directory to store files
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/dev_config.json';

      print(
          'Application documents directory: ${directory.path}'); // Log the directory path

      // Load the asset file
      final jsonString = await rootBundle.loadString('assets/dev_config.json');
      print('Loaded JSON string: $jsonString'); // Log the content of the JSON

      // Write the file to the writable directory
      final file = File(filePath);
      await file.writeAsString(jsonString);
      print('File written to: $filePath'); // Log the file path after writing

      // Verify the file was written correctly
      final writtenFileContent = await file.readAsString();
      print(
          'Content of the written file: $writtenFileContent'); // Log the written file content

      // Return the directory path for use in FFI
      return '${directory.path}/';
    } catch (e) {
      // Log any error that occurs
      print('Error in copyJsonToWritableDirectory: $e');
      rethrow;
    }
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

  void mintTokens(
      int amount, String transaction_hash, String chain_id, String token_id) {
    final Pointer<Utf8> transhash = transaction_hash.toNativeUtf8();
    final Pointer<Utf8> chainid = chain_id.toNativeUtf8();
    final Pointer<Utf8> tokenid = token_id.toNativeUtf8();
    ffiBridgePrebuilt.wallet_lib
        .GeniusSDKMint(amount, transhash, chainid, tokenid);
  }

  void shutdownSDK() {
    ffiBridgePrebuilt.wallet_lib.GeniusSDKShutdown();
    print("Shutting Down SDK");
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

  void requestGeniusSDKProcess({required String jobJson}) {
    if (jobJson.isEmpty || !isSdkInitialized) {
      return;
    }

    // Allocate memory for the jobJson string
    final Pointer<Char> jsonPointer = jobJson.toNativeUtf8().cast<Char>();

    try {
      // Call the native function
      ffiBridgePrebuilt.wallet_lib.GeniusSDKProcess(jsonPointer);
    } finally {
      // Free the allocated memory to prevent memory leaks
      calloc.free(jsonPointer);
    }
  }

  int requestGeniusSDKCost({required String jobJson}) {
    if (jobJson.isEmpty || !isSdkInitialized) {
      return 0;
    }

    // Allocate memory for the jobJson string
    final Pointer<Char> jsonPointer = jobJson.toNativeUtf8().cast<Char>();

    int cost = 0; // Default value if something goes wrong

    try {
      // Call the native function
      cost = ffiBridgePrebuilt.wallet_lib.GeniusSDKGetCost(jsonPointer);
    } catch (e, stackTrace) {
      // Handle the exception gracefully, e.g., log it
      print("Error in GeniusSDKGetCost: $e");
      print(stackTrace);
    } finally {
      // Free the allocated memory to prevent memory leaks
      calloc.free(jsonPointer);
    }

    return cost;
  }

  Future<List<Currency>> getMarkets() async {
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

  Future<List<Events>> getEvents() async {
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
    return [];
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
    await _initSDK(storedKey);
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
    await _initSDK(storedKey);

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
    await _initSDK(storedKey);

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
    await _initSDK(storedKey);

    return true;
  }

  Future<void> deleteWallet(String address) async {
    await _secureStorage.deleteWallet(address);
  }

  Future<void> getWalletTransactions(String address) async {}

  int getMinionsBalance() {
    if (!isSdkInitialized) {
      return 0;
    }
    return ffiBridgePrebuilt.wallet_lib.GeniusSDKGetBalance();
  }

  String getSGNUSBalance() {
    if (!isSdkInitialized) {
      return '';
    }
    GeniusTokenValue tokenValue =
        ffiBridgePrebuilt.wallet_lib.GeniusSDKGetBalanceGNUS();
    final array = tokenValue.value;
    List<int> charCodes = [];
    for (int i = 0; i < 22; i++) {
      final c = array[i];
      if (c == 0) {
        break;
      }
      charCodes.add(c);
    }

    return String.fromCharCodes(charCodes);
  }

  /// Returns address as a hexadecimal string, with 64 hex characters prepended
  /// by `0x`.
  String getSGNUSAddress() {
    if (!isSdkInitialized) {
      return '';
    }
    var address = ffiBridgePrebuilt.wallet_lib.GeniusSDKGetAddress();

    List<int> charCodes =
        List<int>.generate(66, (index) => address.address[index]);

    return String.fromCharCodes(charCodes);
  }

  List<Transaction> getSGNUSTransactions() {
    if (!isSdkInitialized) {
      return [];
    }

    var transactions =
        ffiBridgePrebuilt.wallet_lib.GeniusSDKGetOutTransactions();

    List<Transaction> ret = List.generate(transactions.size, (i) {
      var buffer =
          transactions.ptr[i].ptr.asTypedList(transactions.ptr[i].size);
      var header = DAGWrapper.fromBuffer(buffer).dagStruct;

      var fromAddress = String.fromCharCodes(header.sourceAddr);

      var recipients = List<TransferRecipients>.empty(growable: true);

      List<TransferOutput>? rawRecipients;

      if (header.type == "escrow") {
        rawRecipients = EscrowTx.fromBuffer(buffer).utxoParams.outputs;
      } else if (header.type == "mint") {
        recipients.add(TransferRecipients(
            amount: MintTx.fromBuffer(buffer).amount.toString(), toAddr: ""));
      } else if (header.type == "process") {
        // No recipients in this kind of transaction
      } else if (header.type == "transfer") {
        rawRecipients = TransferTx.fromBuffer(buffer).utxoParams.outputs;
      }

      if (rawRecipients != null) {
        recipients.addAll(rawRecipients.map((output) => TransferRecipients(
            toAddr: output.destAddr
                .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
                .join(),
            amount: output.encryptedAmount.join())));
      }

      Transaction trans = Transaction(
          hash: String.fromCharCodes(header.dataHash),
          fromAddress: fromAddress,
          recipients: recipients,
          timeStamp: DateTime.fromMicrosecondsSinceEpoch(
              header.timestamp.toInt() ~/ 1000),
          transactionDirection: address == fromAddress
              ? TransactionDirection.sent
              : TransactionDirection.received,
          fees: '0',
          coinSymbol: 'GNUS',
          transactionStatus: TransactionStatus.completed,
          type: TransactionType.fromString(header.type));

      return trans;
    }).reversed.toList(); // Reverse the list to put latest first

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
        .GeniusSDKTransfer(amount, convertedAddress);

    calloc.free(convertedAddress);

    return ret;
  }

  Future<ApiResponse<String>> bridgeOut(
      {required String contractAddress,
      required String rpcUrl,
      required String address,
      required String amountToBurn,
      required int sourceChainId,
      required int destinationChainId,
      bool shouldMintTokens = false}) async {
    final wallet = await _secureStorage.getWallet(address);

    if (wallet == null) {
      return ApiResponse.error("Error: Could not find Wallet");
    }

    final resp = await Web3(geniusApi: this).executeBridgeOutTransaction(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        amountToBurn: amountToBurn,
        sourceChainId: sourceChainId,
        destinationChainId: destinationChainId,
        wallet: wallet);

    if (shouldMintTokens && resp.isSuccess && resp.data != null) {
      final hardCodedTokenIdForNow = 0;

      mintTokens(
        int.parse(amountToBurn),
        resp.data!,
        destinationChainId.toString(),
        '$hardCodedTokenIdForNow',
      );
    }

    return resp;
  }

  Future<ApiResponse<String>> getBrigeOutGasCost(
      {required String contractAddress,
      required String rpcUrl,
      required String address,
      required String amountToBurn,
      required int sourceChainId,
      required int destinationChainId}) async {
    final wallet = await _secureStorage.getWallet(address);

    if (wallet == null) {
      return ApiResponse.error("Error: Could not find Wallet");
    }

    final web3 = Web3(geniusApi: this);
    final gasResponse = await web3.getBrigeOutGasCost(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        amountToBurn: amountToBurn,
        destinationChainId: destinationChainId,
        wallet: wallet);

    if (!gasResponse.isSuccess) {
      return ApiResponse.error(
          gasResponse.errorMessage ?? "Failed to retrieve gas costs");
    }

    final gasPriceInGwei = web3.getGasPriceInGwei(gasResponse.data);

    // Return as a nicely formatted string
    return ApiResponse.success("${gasPriceInGwei?.toStringAsFixed(2)} Gwei");
  }
}
