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

  Future<Transaction?> createBridgeOutTransaction({
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

      final bool hasFunds = await hasEnoughFundsForGas(
        walletAddress: wallet.storedKey.account(0).address(),
        rpcUrl: rpcUrl,
        gasLimit: gasLimit,
        gasPrice: gasPrice,
      );

      if (!hasFunds) {
        return null;
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

      return transaction;
    } finally {
      client.dispose();
    }
  }

  Future<String> executeBridgeOutTransaction({
    required String contractAddress,
    required String rpcUrl,
    required StoredKeyWallet wallet,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
    GeniusApi? geniusApi,
  }) async {
    final client = Web3Client(rpcUrl, Client());

    try {
      // Create Transaction
      final transaction = await createBridgeOutTransaction(
        contractAddress: contractAddress,
        rpcUrl: rpcUrl,
        wallet: wallet,
        amountToBurn: amountToBurn,
        destinationChainId: destinationChainId,
      );

      if (transaction == null) {
        return 'Error: not enough balance for gas fees';
      }

      // Get Private Key
      final hardCodedTokenIdForNow = 0;

      final credentials = EthPrivateKey.fromHex(getPrivateKeyStr(wallet));

      // Execute Transaction
      final txHash = await client.sendTransaction(
        credentials,
        transaction,
        chainId: sourceChainId,
      );

      geniusApi?.mintTokens(
        int.parse(amountToBurn),
        txHash,
        destinationChainId.toString(),
        '$hardCodedTokenIdForNow',
      );

      return txHash;
    } catch (e) {
      print('Error: $e');
      return "Error: $e";
    } finally {
      client.dispose();
    }
  }

  Future<EtherAmount?> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required StoredKeyWallet wallet,
    required String amountToBurn,
    required int destinationChainId,
  }) async {
    final transaction = await createBridgeOutTransaction(
      contractAddress: contractAddress,
      rpcUrl: rpcUrl,
      wallet: wallet,
      amountToBurn: amountToBurn,
      destinationChainId: destinationChainId,
    );

    return transaction?.gasPrice;
  }

  double? getGasPriceInGwei(EtherAmount? gas) {
    return gas?.getValueInUnit(EtherUnit.gwei).toDouble();
  }

  Future<bool> hasEnoughFundsForGas({
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
      return balance.getInWei >= totalGasCost;
    } catch (e) {
      print("Error checking funds: $e");
      return false;
    } finally {
      client.dispose();
    }
  }

  String getPrivateKeyStr(wallet) {
    PrivateKey privateKey;
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
}
