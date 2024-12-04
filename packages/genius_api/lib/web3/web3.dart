import 'dart:math';
import 'dart:typed_data';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/src/genius_api.dart';
import 'package:genius_api/tw/private_key.dart';
import 'package:genius_api/tw/stored_key_wallet.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3 {
  final GeniusApi? geniusApi;

  Web3({this.geniusApi});

  static final abi = ContractAbi.fromJson(
      '''[{ "constant": true, "inputs": [], "name": "name", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "decimals", "outputs": [ { "name": "", "type": "uint8" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_owner", "type": "address" } ], "name": "balanceOf", "outputs": [ { "name": "balance", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "symbol", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "type": "function" }]''',
      '');
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

  Future<String> bridgeOut(
      {required String contractAddress,
      required String rpcUrl,
      required StoredKeyWallet? wallet,
      required String amountToBurn,
      required int sourceChainId,
      required int destinationChainId}) async {
    final client = Web3Client(rpcUrl, Client());

    if (wallet == null) {
      return "Wallet was not found!";
    }

    PrivateKey privateKey;

    if (wallet.storedKey.isMnemonic()) {
      privateKey = wallet.storedKey
          .wallet("")!
          .getKeyForCoin(TWCoinType.TWCoinTypeEthereum);
    } else {
      privateKey = wallet.storedKey
          .privateKey(TWCoinType.TWCoinTypeEthereum, Uint8List(0))!;
    }

    final privateKeyAsStr = privateKey
        .data()
        .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
        .join();

    EthereumAddress contractAddr = EthereumAddress.fromHex(contractAddress);

    try {
      final contract = DeployedContract(abi, contractAddr);
      final decimalsFunction = contract.function('decimals');

      final tokenDecimals = await client
          .call(contract: contract, function: decimalsFunction, params: []);
      // Parse user input into a decimal number
      final double amount = double.parse(amountToBurn);

      // Convert to BigInt by multiplying with 10^decimals
      final burnAmountConverted = BigInt.from(
          amount * pow(10, int.parse(tokenDecimals.first.toString())));

      final credentials = EthPrivateKey.fromHex(privateKeyAsStr);
      final ownAddress = credentials.address;

      final bridgeContract = DeployedContract(
        bridgeOutAbi,
        EthereumAddress.fromHex(contractAddress),
      );

      final bridgeOutFunction = bridgeContract.function('bridgeOut');

      // Estimate Gas Price
      final gasPrice = await client.getGasPrice();

      // Estimate Gas Limit
      final gasLimit = await client.estimateGas(
        sender: ownAddress,
        to: EthereumAddress.fromHex(contractAddress),
        data: bridgeOutFunction.encodeCall(
          [
            burnAmountConverted,
            BigInt.from(0),
            BigInt.from(destinationChainId)
          ],
        ), // Encoded function data
      );

      // Calculate Total Gas Cost
      // final totalCostWei = gasPrice.getInWei * gasLimit;

      // Optional: Convert wei to Ether
      // Convert wei to Ether using EtherAmount.fromBigInt
      // final totalCostEth = EtherAmount.fromBigInt(EtherUnit.wei, totalCostWei)
      //     .getValueInUnit(EtherUnit.ether);

      final transaction = Transaction.callContract(
        contract: bridgeContract,
        function: bridgeOutFunction,
        parameters: [
          burnAmountConverted,
          BigInt.from(0),
          BigInt.from(destinationChainId)
        ],
        from: ownAddress,
        gasPrice: gasPrice, // Example gas price
        maxGas: gasLimit.toInt(), // Example gas limit
      );

      final txHash = await client.sendTransaction(credentials, transaction,
          chainId: sourceChainId);

      geniusApi?.mintTokens(1, "", "", "");

      // geniusApi?.mintTokens(
      //     amount.toInt(), txHash, destinationChainId.toString(), '0');

      return txHash;
    } catch (e) {
      print('Error: $e');
      return "Error: $e";
    } finally {
      client.dispose();
    }
  }
}
