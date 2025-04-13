import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/src/genius_api.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/stored_key_wallet.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/utilities.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/material.dart';

class Web3 {
  final GeniusApi? geniusApi;

  Web3({this.geniusApi});

  // Should be the same accross most chains
  final multiCallContractAddress =
      EthereumAddress.fromHex("0xca11bde05977b3631167028862be2a173976ca11");

  static final bridgeOutAbi = ContractAbi.fromJson('''
    [
      {
        "inputs": [
          { "internalType": "uint256", "name": "amount", "type": "uint256" },
          { "internalType": "uint256", "name": "id", "type": "uint256" },
          { "internalType": "uint256", "name": "destChainID", "type": "uint256" }
        ],
        "name": "bridgeOut",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function"
      }
    ]
  ''', '');

  static final abi = ContractAbi.fromJson('''[
          { "constant": true, "inputs": [], "name": "name", "outputs": [{ "name": "", "type": "string" }], "type": "function" },
          { "constant": true, "inputs": [], "name": "decimals", "outputs": [{ "name": "", "type": "uint8" }], "type": "function" },
          { "constant": true, "inputs": [{ "name": "_owner", "type": "address" }], "name": "balanceOf", "outputs": [{ "name": "balance", "type": "uint256" }], "type": "function" },
          { "constant": true, "inputs": [], "name": "symbol", "outputs": [{ "name": "", "type": "string" }], "type": "function" }
        ]''', '');

  Future<Map<String, dynamic>> fetchTokenDetailsMulticall({
    required String contractAddress,
    required String walletAddress,
    required String rpcUrl,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    final multicallAbi = '''[
      {
        "constant": true,
        "inputs": [
          { "components": [{ "name": "target", "type": "address" }, { "name": "callData", "type": "bytes" }], "name": "calls", "type": "tuple[]" }
        ],
        "name": "aggregate",
        "outputs": [{ "name": "blockNumber", "type": "uint256" }, { "name": "returnData", "type": "bytes[]" }],
        "payable": false,
        "stateMutability": "view",
        "type": "function"
      }
    ]''';

    final multicallContract = DeployedContract(
        ContractAbi.fromJson(multicallAbi, "Multicall"),
        multiCallContractAddress);

    final tokenContract =
        DeployedContract(abi, EthereumAddress.fromHex(contractAddress));

    final List<List<dynamic>> calls = [
      [
        EthereumAddress.fromHex(contractAddress),
        _encodeFunctionCall(tokenContract, "symbol", [])
      ],
      [
        EthereumAddress.fromHex(contractAddress),
        _encodeFunctionCall(tokenContract, "decimals", [])
      ],
      [
        EthereumAddress.fromHex(contractAddress),
        _encodeFunctionCall(tokenContract, "name", [])
      ],
      [
        EthereumAddress.fromHex(contractAddress),
        _encodeFunctionCall(tokenContract, "balanceOf",
            [EthereumAddress.fromHex(walletAddress)])
      ],
    ];

    final List<dynamic> results =
        await _executeMulticall(client, multicallContract, calls);

    if (results.length < 4) {
      debugPrint("⚠️ Multicall returned incomplete results: $results");
      return {};
    }

    // Decode responses properly
    final String symbol = _decodeString(results[0], "symbol");
    final int decimals = _decodeInt(results[1], "decimals");
    final String name = _decodeString(results[2], "name");
    final BigInt balance = _decodeBigInt(results[3], "balanceOf");

    await client.dispose();

    return {
      'symbol': symbol,
      'decimals': decimals,
      'name': name,
      'balance': balance.toDouble() / pow(10, decimals),
    };
  }

  /// **Encodes Function Call for Multicall**
  Uint8List _encodeFunctionCall(
      DeployedContract contract, String functionName, List<dynamic> params) {
    final function = contract.function(functionName);
    return function.encodeCall(params);
  }

  /// **Executes Multicall Request**
  Future<List<dynamic>> _executeMulticall(Web3Client client,
      DeployedContract multicallContract, List<List<dynamic>> calls) async {
    final ContractFunction aggregateFunction =
        multicallContract.function("aggregate");

    final List<dynamic> response = await client.call(
      contract: multicallContract,
      function: aggregateFunction,
      params: [calls],
    );

    if (response.length < 2 || response[1] is! List<dynamic>) {
      throw Exception("Invalid response from multicall: $response");
    }

    return response[1] as List<dynamic>; // Extract returnData
  }

  /// **Decodes String from Multicall**
  String _decodeString(dynamic data, String fieldName) {
    try {
      if (data is Uint8List) {
        return utf8
            .decode(data)
            .replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'),
                '') // Remove non-debugPrintable characters
            .trim();
      }
      return data.toString();
    } catch (e) {
      debugPrint("⚠️ Decoding error for $fieldName: $e");
      return '';
    }
  }

  /// **Decodes Int (e.g., Decimals) from Multicall Response**
  int _decodeInt(dynamic data, String fieldName) {
    try {
      if (data is Uint8List && data.isNotEmpty) {
        return data.last; // Extracts last byte for integer values
      }
      return int.tryParse(data.toString()) ?? 0;
    } catch (e) {
      debugPrint("⚠️ Decoding error for $fieldName: $e");
      return 0;
    }
  }

  /// **Decodes BigInt from Multicall**
  BigInt _decodeBigInt(dynamic data, String fieldName) {
    try {
      if (data is Uint8List) {
        return BigInt.parse(
            data.map((e) => e.toRadixString(16).padLeft(2, '0')).join(),
            radix: 16);
      }
      return BigInt.tryParse(data.toString()) ?? BigInt.zero;
    } catch (e) {
      debugPrint("⚠️ Decoding error for $fieldName: $e");
      return BigInt.zero;
    }
  }

  Future<double> balanceOf(
      {required String address,
      required String contractAddress,
      required String rpcUrl}) async {
    final client = Web3Client(rpcUrl, Client());

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    final contract = DeployedContract(abi, contractAddr);

    final balanceFunction = contract.function('balanceOf');
    final decimalsFunction = contract.function('decimals');

    try {
      final tokenBalance = await client.call(
          contract: contract,
          function: balanceFunction,
          params: [EthereumAddress.fromHex(address)]);

      final tokenDecimals = await client
          .call(contract: contract, function: decimalsFunction, params: []);

      final balanceWithDecimals = BigInt.parse(tokenBalance.first.toString()) /
          BigInt.from(10).pow(int.parse(tokenDecimals.first.toString()));

      await client.dispose();
      return balanceWithDecimals;
    } catch (e) {
      await client.dispose();
      return 0;
    }
  }

  Future<String> symbol(
      {required String contractAddress, required String rpcUrl}) async {
    final client = Web3Client(rpcUrl, Client());

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    final contract = DeployedContract(abi, contractAddr);
    final symbol = contract.function('symbol');

    try {
      final tokenSymbol =
          await client.call(contract: contract, function: symbol, params: []);

      await client.dispose();
      return tokenSymbol.first;
    } catch (e) {
      await client.dispose();
      return '';
    }
  }

  Future<String> decimals(
      {required String contractAddress, required String rpcUrl}) async {
    final client = Web3Client(rpcUrl, Client());

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    final contract = DeployedContract(abi, contractAddr);
    final decimals = contract.function('decimals');

    try {
      final tokenDecimals =
          await client.call(contract: contract, function: decimals, params: []);

      await client.dispose();
      return tokenDecimals.first;
    } catch (e) {
      await client.dispose();
      return '';
    }
  }

  Future<String> name(
      {required String contractAddress, required String rpcUrl}) async {
    final client = Web3Client(rpcUrl, Client());

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    final contract = DeployedContract(abi, contractAddr);
    final name = contract.function('name');

    try {
      final tokenName =
          await client.call(contract: contract, function: name, params: []);

      await client.dispose();
      return tokenName.first;
    } catch (e) {
      await client.dispose();
      return '';
    }
  }

  Future<double> getBalance(
      {required String rpcUrl, required String address}) async {
    final client = Web3Client(rpcUrl, Client());

    try {
      final balance = await client.getBalance(EthereumAddress.fromHex(address));
      final ethBalance = balance.getValueInUnit(EtherUnit.ether);

      await client.dispose();
      return ethBalance;
    } catch (e) {
      await client.dispose();
      return 0;
    }
  }

  Future<ApiResponse<Transaction>> createBridgeOutTransaction({
    required String contractAddress,
    required String rpcUrl,
    required StoredKeyWallet wallet,
    required String amountToBurn,
    required int destinationChainId,
  }) async {
    final client = Web3Client(rpcUrl, Client());
    final hardCodedTokenIdForNow = 0;

    final credentials = EthPrivateKey.fromHex(getPrivateKeyStr(wallet));
    final ownAddress = credentials.address;

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    try {
      // Contract Setup
      final bridgeContract = DeployedContract(
        bridgeOutAbi,
        contractAddr,
      );
      final contract = DeployedContract(abi, contractAddr);
      final bridgeOutFunction = bridgeContract.function('bridgeOut');
      final decimalsFunction = contract.function('decimals');

      // Get Token Decimals
      final tokenDecimals = await client.call(
        contract: bridgeContract,
        function: decimalsFunction,
        params: [],
      );

      // Convert Amount to BigInt
      final double amount = double.parse(amountToBurn);
      final burnAmountConverted = BigInt.from(
          amount * pow(10, int.parse(tokenDecimals.first.toString())));

      // Estimate Gas Price and Gas Limit
      final gasPrice = await client.getGasPrice();
      final gasLimit = await client.estimateGas(
        sender: ownAddress,
        to: contractAddr,
        data: bridgeOutFunction.encodeCall(
          [
            burnAmountConverted,
            BigInt.from(hardCodedTokenIdForNow),
            BigInt.from(destinationChainId)
          ],
        ),
      );

      final hasFundsResponse = await hasEnoughFundsForGas(
        walletAddress: wallet.storedKey.account(0).address(),
        rpcUrl: rpcUrl,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );

      if (!hasFundsResponse.isSuccess ||
          (hasFundsResponse.isSuccess && !hasFundsResponse.data!)) {
        return ApiResponse.error("Not enough funds for gas to bridge tokens");
      }

      // Create Transaction
      final transaction = Transaction.callContract(
        contract: bridgeContract,
        function: bridgeOutFunction,
        parameters: [
          burnAmountConverted,
          BigInt.from(hardCodedTokenIdForNow),
          BigInt.from(destinationChainId),
        ],
        from: ownAddress,
        gasPrice: gasPrice,
        maxGas: gasLimit.toInt(),
      );

      return ApiResponse.success(transaction);
    } catch (e) {
      return ApiResponse.error(e.toString());
    } finally {
      client.dispose();
    }
  }

  Future<ApiResponse<String>> executeBridgeOutTransaction(
      {required String contractAddress,
      required String rpcUrl,
      required StoredKeyWallet wallet,
      required String amountToBurn,
      required int sourceChainId,
      required int destinationChainId}) async {
    final client = Web3Client(rpcUrl, Client());

    try {
      // Create Transaction
      final transactionResponse = await createBridgeOutTransaction(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        wallet: wallet,
        amountToBurn: amountToBurn,
        destinationChainId: destinationChainId,
      );

      if (!transactionResponse.isSuccess || transactionResponse.data == null) {
        return ApiResponse.error(transactionResponse.errorMessage ??
            'Not enough balance to pay for gas fees');
      }

      // Get Private Key

      final credentials = EthPrivateKey.fromHex(getPrivateKeyStr(wallet));

      // Execute Transaction
      final txHash = await client.sendTransaction(
        credentials,
        transactionResponse.data!, // handled above if null
        chainId: sourceChainId,
      );

      return ApiResponse.success(txHash);
    } catch (e) {
      ApiResponse.error(e.toString());
    } finally {
      client.dispose();
    }

    return ApiResponse.error('Failed to bridge: unknown');
  }

  Future<ApiResponse<EtherAmount?>> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required StoredKeyWallet wallet,
    required String amountToBurn,
    required int destinationChainId,
  }) async {
    final transactionResponse = await createBridgeOutTransaction(
      contractAddress: contractAddress,
      rpcUrl: rpcUrl,
      wallet: wallet,
      amountToBurn: amountToBurn,
      destinationChainId: destinationChainId,
    );

    if (!transactionResponse.isSuccess) {
      return ApiResponse.error(
          transactionResponse.errorMessage ?? "Error bridging");
    }

    return ApiResponse.success(transactionResponse.data?.gasPrice);
  }

  double? getGasPriceInGwei(EtherAmount? gas) {
    return gas?.getValueInUnit(EtherUnit.gwei).toDouble();
  }

  Future<ApiResponse<bool>> hasEnoughFundsForGas({
    required String walletAddress,
    required String rpcUrl,
    required BigInt gasLimit, // Estimated gas limit
    required EtherAmount gasPrice, // Gas price in wei
  }) async {
    final client = Web3Client(rpcUrl, Client());

    try {
      // Get the wallet balance in wei
      final EthereumAddress address = EthereumAddress.fromHex(walletAddress);
      final EtherAmount balance = await client.getBalance(address);

      // Calculate total gas cost: gas price * gas limit
      final BigInt totalGasCost = gasPrice.getInWei * gasLimit;

      // Check if the balance is greater than or equal to the gas cost
      return ApiResponse.success(balance.getInWei >= totalGasCost);
    } catch (e) {
      return ApiResponse.error(e.toString());
    } finally {
      client.dispose();
    }
  }

  String getPrivateKeyStr(wallet) {
    PrivateKey privateKey;
    if (wallet == null) {
      return '';
    }
    if (wallet.storedKey.isMnemonic()) {
      privateKey = wallet.storedKey
          .wallet("")!
          .getKeyForCoin(TWCoinType.TWCoinTypeEthereum);
    } else {
      privateKey = wallet.storedKey
          .privateKey(TWCoinType.TWCoinTypeEthereum, Uint8List(0));
    }
    return privateKey
        .data()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  Future<ApiResponse<String>> signAndSendTransaction({
    required Map<String, dynamic> tx,
    required String rpcUrl,
    required String privateKey,
    required int chainId,
  }) async {
    final client = Web3Client(rpcUrl, Client());

    try {
      final from = EthereumAddress.fromHex(tx['from']);
      final to = EthereumAddress.fromHex(tx['to']);
      final value = parseHexToBigInt(tx['value']);
      final gasLimit = parseHexToBigInt(tx['gas'] ?? tx['gasLimit']);
      final maxFeePerGas = parseHexToBigInt(tx['maxFeePerGas']);
      final maxPriorityFee = parseHexToBigInt(tx['maxPriorityFeePerGas']);
      final data = tx['data'] != null ? hexToBytes(tx['data']) : Uint8List(0);

      final transaction = Transaction(
        from: from,
        to: to,
        value: EtherAmount.inWei(value),
        gasPrice: EtherAmount.inWei(maxFeePerGas),
        maxPriorityFeePerGas: EtherAmount.inWei(maxPriorityFee),
        maxFeePerGas: EtherAmount.inWei(maxFeePerGas),
        data: data,
        maxGas: gasLimit.toInt(),
      );

      if (privateKey.isEmpty) {
        return ApiResponse.error("No private key provided for signing");
      }

      final credentials = EthPrivateKey.fromHex(privateKey);

      final txHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: chainId,
      );

      return ApiResponse.success(txHash);
    } catch (e) {
      return ApiResponse.error("Sign/Send failed: $e");
    } finally {
      client.dispose();
    }
  }
}
