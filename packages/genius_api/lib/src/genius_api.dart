import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:convert/convert.dart';
import 'package:ffi/ffi.dart';
import 'package:genius_api/controllers/sgnus_connection_controller.dart';
import 'package:genius_api/controllers/sgnus_transactions_controller.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/ffi_bridge_prebuilt.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/account.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/test/dev_overrides.dart';
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
  final _ffiBridgePrebuilt = FFIBridgePrebuilt();
  final _sgnusConnectionController = SGNUSConnectionController();
  final _sgnusTransactionsController = SGNUSTransactionsController();
  final _walletsController = BehaviorSubject<List<Wallet>>.seeded([]);
  late final String _address;
  late final String _basePath;
  bool _isSdkInitialized = false;

  GeniusApi({
    required LocalWalletStorage secureStorage,
  }) : _secureStorage = secureStorage;

  Future<void> requestPermissions() async {
    try {
      if (await Permission.storage.isDenied) {
        await Permission.storage.request();
      }
      if (await Permission.location.isDenied) {
        await Permission.location.request();
      }
    } catch (e) {
      debugPrint("❌ Failed to check permissions ${e.toString()}");
    }
  }

  /// Returns a [Stream] of the wallets that the device has saved.
  Stream<List<Wallet>> getWallets() {
    return _walletsController.stream;
  }

  /// Refreshes the wallet list from secure storage and updates the stream.
  Future<void> loadStoredWallets() async {
    final wallets = await _secureStorage.getAllWallets();
    _walletsController.add(wallets);
  }

  SGNUSTransactionsController getSGNUSTransactionsController() {
    return _sgnusTransactionsController;
  }

  Stream<List<Transaction>> getSGNUSTransactionsStream() {
    return getSGNUSTransactionsController().stream;
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
    if (_isSdkInitialized) {
      return;
    }

    requestPermissions();

    final storedKey = await _secureStorage.getSGNUSLinkedWalletPrivateKey();
    if (storedKey == null) {
      debugPrint("No suitable wallet found");
      return;
    }

    await _initSDK(storedKey);
  }

  Future<void> _initSDK(StoredKey storedKey) async {
    if (_isSdkInitialized) {
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

    _basePath = '${(await copyJsonToWritableDirectory()).path}/';
    final basePathPtr = _basePath.toNativeUtf8();

    final privateKeyAsStr = privateKey
        .data()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
    final privateKeyAsPtr = privateKeyAsStr.toNativeUtf8();
    final retVal = _ffiBridgePrebuilt.sgns_lib.GeniusSDKInitWithKey(
        basePathPtr.cast(), privateKeyAsPtr.cast(), true, true, 41001, false);

    malloc.free(privateKeyAsPtr);
    malloc.free(basePathPtr);

    if (retVal == nullptr) {
      debugPrint("Error: failed to init SDK");
      return;
    }

    var rawAddress = _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetAddress();
    List<int> charCodes =
        List<int>.generate(2 + 128, (index) => rawAddress.address[index]);
    _address = String.fromCharCodes(charCodes);

    getSGNUSController().updateConnection(SGNUSConnection(
        sgnusAddress: _address,
        walletAddress: storedKey
                .wallet("")
                ?.getAddressForCoin(TWCoinType.TWCoinTypeEthereum) ??
            "",
        isConnected: true));

    _isSdkInitialized = true;
  }

  Future<void> _registerWallet(StoredKey storedKey) async {
    await _secureStorage.saveStoredKey(storedKey);
    await _initSDK(storedKey);
    await loadStoredWallets();
  }

  Future<Directory> copyJsonToWritableDirectory() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      debugPrint('Base path directory: ${directory.path}');

      final jsonString = await rootBundle.loadString('assets/dev_config.json');
      debugPrint('Loaded dev config: $jsonString');

      final filePath = '${directory.path}/dev_config.json';
      final file = File(filePath);
      await file.writeAsString(jsonString);
      debugPrint('File written to: $filePath');

      final writtenFileContent = await file.readAsString();
      debugPrint('Content of the written file: $writtenFileContent');

      return directory;
    } catch (e) {
      debugPrint('Error in copyJsonToWritableDirectory: $e');
      rethrow;
    }
  }

  Future<double> getGasFees() async {
    return .001;
  }

  Future<void> storeUserPin(String pin) async =>
      await _secureStorage.storeUserPin(pin);

  /// Verifies that the saved user pin matches [pin].
  Future<bool> verifyUserPin(String pin) async =>
      await _secureStorage.verifyUserPin(pin);

  Future<bool> userExists() async => await _secureStorage.pinExists();

  String? getHRPStrideValue() {
    return _ffiBridgePrebuilt.tw_lib
        .stringForHRP(TWHRP.TWHRPStride)
        .cast<Utf8>()
        .toDartString();
  }

  Pointer<Void> createWalletWithSize(int size) {
    return _ffiBridgePrebuilt.tw_lib.TWDataCreateWithSize(size);
  }

  GeniusNodeReturnValue mintTokens(
      int amount, String transactionHash, String chainId, String tokenId) {
    final Pointer<Utf8> transhash = transactionHash.toNativeUtf8();
    final Pointer<Utf8> chainid = chainId.toNativeUtf8();

    // Create GeniusTokenID from string
    final tokenIdData = calloc<GeniusTokenID>();

    // Parse hex string token_id and fill the data array
    String cleanTokenId =
        tokenId.startsWith('0x') ? tokenId.substring(2) : tokenId;

    for (int i = 0; i < 32 && i * 2 < cleanTokenId.length; i++) {
      String hexByte = cleanTokenId.substring(i * 2, (i + 1) * 2);
      tokenIdData.ref.data[i] = int.parse(hexByte, radix: 16);
    }

    final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKMint(amount,
        transhash as Pointer<Char>, chainid as Pointer<Char>, tokenIdData.ref);

    calloc.free(tokenIdData);
    malloc.free(transhash);
    malloc.free(chainid);

    return _mapNodeReturnValue(result);
  }

  void dispose() {
    _walletsController.close();
    _sgnusConnectionController.dispose();
    _sgnusTransactionsController.dispose();
  }

  GeniusNodeReturnValue shutdownSDK() {
    final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKShutdown();
    final mappedResult = _mapNodeReturnValue(result);
    debugPrint("Shutting Down SDK: $mappedResult");
    dispose();
    return mappedResult;
  }

  GeniusNodeReturnValue requestGeniusSDKProcess({required String jobJson}) {
    if (!_isSdkInitialized) {
      return GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED;
    }

    if (jobJson.isEmpty) {
      return GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT;
    }

    // Allocate memory for the jobJson string
    final Pointer<Char> jsonPointer = jobJson.toNativeUtf8().cast<Char>();

    try {
      // Call the native function
      final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKProcess(jsonPointer);
      return _mapNodeReturnValue(result);
    } finally {
      // Free the allocated memory to prevent memory leaks
      calloc.free(jsonPointer);
    }
  }

  int requestGeniusSDKCost({required String jobJson}) {
    if (jobJson.isEmpty || !_isSdkInitialized) {
      return 0;
    }

    // Allocate memory for the jobJson string
    final Pointer<Char> jsonPointer = jobJson.toNativeUtf8().cast<Char>();

    int cost = 0; // Default value if something goes wrong

    try {
      // Call the native function
      cost = _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetCost(jsonPointer);
    } catch (e, stackTrace) {
      // Handle the exception gracefully, e.g., log it
      debugPrint("Error in GeniusSDKGetCost: $e");
      debugPrint('$stackTrace');
    } finally {
      // Free the allocated memory to prevent memory leaks
      calloc.free(jsonPointer);
    }

    return cost;
  }

  // Take in a created wallet and return the mnemonic
  Future<List<String>> getRecoveryPhrase(HDWallet wallet) async {
    return wallet.mnemonic().split(' ');
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

    await _registerWallet(storedKey);
  }

  Future<bool> validateWalletImport({
    required TWCoinType coinType,
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

  Future<bool> importWalletFromKeyStore(String json, String? password,
      String walletName, TWCoinType coinType) async {
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

    await _registerWallet(storedKey);

    return true;
  }

  Future<bool> importWalletFromAddress(address, walletName, coinType) async {
    if (!AnyAddress.isValid(address, coinType)) {
      debugPrint('Invalid Address');
      return false;
    }

    await _secureStorage.saveWatchedWallet(Wallet(
        balance: 0,
        walletName: walletName,
        currencySymbol: CoinUtil.getSymbol(coinType),
        coinType: coinType,
        walletType: WalletType.tracking,
        address: address));

    await loadStoredWallets();

    return true;
  }

  Future<bool> importWalletFromMnemonic(
      String mnemonic, String walletName, TWCoinType coinType) async {
    StoredKey? storedKey =
        StoredKey.importHDWallet(mnemonic, walletName, "", coinType);

    if (storedKey == null) {
      return false;
    }

    await _registerWallet(storedKey);

    return true;
  }

  Future<bool> importWalletFromPrivateKey(
      String privateKey, String walletName, TWCoinType coinType) async {
    final privateKeyData = Uint8List.fromList(hex.decode(privateKey));
    StoredKey? storedKey =
        StoredKey.importPrivateKey(privateKeyData, walletName, "", coinType);

    if (storedKey == null) {
      return false;
    }

    await _registerWallet(storedKey);

    return true;
  }

  Future<void> renameWallet(String address, String newName) async {
    await _secureStorage.renameWallet(address, newName);
    await loadStoredWallets();
  }

  Future<void> deleteWallet(String address) async {
    await _secureStorage.deleteWallet(address);
    await loadStoredWallets();
  }

  String getMinionsBalance([String? tokenId]) {
    if (!_isSdkInitialized) {
      return "0";
    }

    final tokenIdData = calloc<GeniusTokenID>();

    if (tokenId == null) {
      // Use default token (all zeros)
      for (int i = 0; i < 32; i++) {
        tokenIdData.ref.data[i] = 0;
      }
    } else {
      // Parse provided token ID
      String cleanTokenId =
          tokenId.startsWith('0x') ? tokenId.substring(2) : tokenId;

      for (int i = 0; i < 32 && i * 2 < cleanTokenId.length; i++) {
        String hexByte = cleanTokenId.substring(i * 2, (i + 1) * 2);
        tokenIdData.ref.data[i] = int.parse(hexByte, radix: 16);
      }
    }

    final balance =
        _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetBalance(tokenIdData.ref);
    calloc.free(tokenIdData);
    return balance.toString();
  }

  String getSGNUSBalance() {
    if (!_isSdkInitialized) {
      return "0";
    }
    GeniusTokenValue tokenValue =
        _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetBalanceGNUS();
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

  DateTime parseTimestamp(int timestamp) {
    // Determine the unit by the timestamp's magnitude and convert to microseconds.
    int us;
    final len = timestamp.abs().toString().length;

    if (len >= 19) {
      us = timestamp ~/ 1000; // nanoseconds
    } else if (len >= 17) {
      us = timestamp ~/ 10; // 100-nanosecond intervals (Windows FILETIME)
    } else if (len >= 16) {
      us = timestamp; // microseconds
    } else if (len >= 13) {
      us = timestamp * 1000; // milliseconds
    } else {
      us = timestamp * 1000000; // seconds
    }

    try {
      final dt = DateTime.fromMicrosecondsSinceEpoch(us);
      if (dt.year >= 2020 && dt.year <= 2100) {
        return dt;
      }
    } catch (_) {}

    // Fallback: treat raw value as milliseconds
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  void streamSGNUSTransactions() {
    if (!_isSdkInitialized) {
      return;
    }

    var transactions =
        _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetOutTransactions();

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
            amount: output.encryptedAmount.toString())));
      }

      Transaction trans = Transaction(
          hash: String.fromCharCodes(header.dataHash),
          fromAddress: fromAddress,
          recipients: recipients,
          timeStamp: parseTimestamp(header.timestamp.toInt()),
          transactionDirection: _address == fromAddress
              ? TransactionDirection.sent
              : TransactionDirection.received,
          fees: '0',
          coinSymbol: 'minions',
          transactionStatus: TransactionStatus.completed,
          isSGNUS: true,
          type: TransactionType.fromString(header.type));

      return trans;
    });

    // Sort by timestamp, newest first
    ret.sort((a, b) => a.timeStamp.compareTo(b.timeStamp));

    _ffiBridgePrebuilt.sgns_lib.GeniusSDKFreeTransactions(transactions);

    getSGNUSTransactionsController().setTransactions(ret);
  }

  GeniusNodeReturnValue transferTokens(int amount, String address,
      {String? tokenId}) {
    final convertedAddress = calloc<GeniusAddress>();
    final tokenIdData = calloc<GeniusTokenID>();

    final bytes = Uint8List.fromList(address.codeUnits);

    for (int i = 0; i < address.length; ++i) {
      convertedAddress.ref.address[i] = bytes[i];
    }

    if (tokenId == null) {
      // Use default token (all zeros)
      for (int i = 0; i < 32; i++) {
        tokenIdData.ref.data[i] = 0;
      }
    } else {
      // Parse provided token ID
      String cleanTokenId =
          tokenId.startsWith('0x') ? tokenId.substring(2) : tokenId;

      for (int i = 0; i < 32 && i * 2 < cleanTokenId.length; i++) {
        String hexByte = cleanTokenId.substring(i * 2, (i + 1) * 2);
        tokenIdData.ref.data[i] = int.parse(hexByte, radix: 16);
      }
    }

    final ret = _ffiBridgePrebuilt.sgns_lib
        .GeniusSDKTransfer(amount, convertedAddress, tokenIdData.ref);

    calloc.free(convertedAddress);
    calloc.free(tokenIdData);

    return _mapNodeReturnValue(ret);
  }

  double getGNUSPrice() {
    if (!_isSdkInitialized) {
      return 0.0;
    }
    return _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetGNUSPrice();
  }

  String getBalanceGNUSString() {
    if (!_isSdkInitialized) {
      return "0";
    }
    final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetBalanceGNUSString();
    return result.cast<Utf8>().toDartString();
  }

  GeniusNodeReturnValue payDev(int amount, {String? tokenId}) {
    if (!_isSdkInitialized) {
      return GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED;
    }

    final tokenIdData = calloc<GeniusTokenID>();

    if (tokenId == null) {
      // Use default token (all zeros)
      for (int i = 0; i < 32; i++) {
        tokenIdData.ref.data[i] = 0;
      }
    } else {
      // Parse provided token ID
      String cleanTokenId =
          tokenId.startsWith('0x') ? tokenId.substring(2) : tokenId;

      for (int i = 0; i < 32 && i * 2 < cleanTokenId.length; i++) {
        String hexByte = cleanTokenId.substring(i * 2, (i + 1) * 2);
        tokenIdData.ref.data[i] = int.parse(hexByte, radix: 16);
      }
    }

    final result =
        _ffiBridgePrebuilt.sgns_lib.GeniusSDKPayDev(amount, tokenIdData.ref);
    calloc.free(tokenIdData);

    return _mapNodeReturnValue(result);
  }

  GeniusNodeReturnValue _mapNodeReturnValue(int value) {
    try {
      return GeniusNodeReturnValue.fromValue(value);
    } catch (e) {
      debugPrint("Unknown GeniusNodeReturnValue: $value");
      return GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT;
    }
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

  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String address,
    required int sourceChainId,
  }) async {
    final wallet = await _secureStorage.getWallet(address);
    final web3 = Web3(geniusApi: this);

    final privateKey = getDevPrivateKey() ?? web3.getPrivateKeyStr(wallet);

    final resp = await web3.signAndSendTransaction(
        tx: tx, rpcUrl: rpcUrl, chainId: sourceChainId, privateKey: privateKey);

    return resp;
  }

  GeniusProcessingStatusInfo getProcessingStatus() {
    final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetProcessingStatus();
    return result;
  }

  GeniusTransactionManagerState getTransactionManagerState() {
    final result =
        _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetTransactionManagerState();
    return _mapTransactionManagerState(result);
  }

  GeniusNodeState getNodeState() {
    final result = _ffiBridgePrebuilt.sgns_lib.GeniusSDKGetNodeState();
    return _mapNodeState(result);
  }

  GeniusProcessingStatus _mapProcessingStatus(int value) {
    try {
      return GeniusProcessingStatus.fromValue(value);
    } catch (e) {
      debugPrint("Unknown GeniusProcessingStatus: $value");
      return GeniusProcessingStatus.GENIUS_PR_STATUS_DISABLED;
    }
  }

  GeniusTransactionManagerState _mapTransactionManagerState(int value) {
    try {
      return GeniusTransactionManagerState.fromValue(value);
    } catch (e) {
      debugPrint("Unknown GeniusTransactionManagerState: $value");
      return GeniusTransactionManagerState.GENIUS_TM_STATE_CREATING;
    }
  }

  GeniusNodeState _mapNodeState(int value) {
    try {
      return GeniusNodeState.fromValue(value);
    } catch (e) {
      debugPrint("Unknown GeniusNodeState: $value");
      return GeniusNodeState.GENIUS_NODE_CREATING;
    }
  }
}
