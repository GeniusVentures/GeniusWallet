import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class Web3 {
  static final abi = ContractAbi.fromJson(
      '''[{ "constant": true, "inputs": [], "name": "name", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "decimals", "outputs": [ { "name": "", "type": "uint8" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [ { "name": "_owner", "type": "address" } ], "name": "balanceOf", "outputs": [ { "name": "balance", "type": "uint256" } ], "payable": false, "type": "function" }, { "constant": true, "inputs": [], "name": "symbol", "outputs": [ { "name": "", "type": "string" } ], "payable": false, "type": "function" }]''',
      '');

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
}

// Send transaction

   // final credentials = EthPrivateKey.fromHex(privateKey);
    // final address = credentials.address;

    // final ethAddress = EthereumAddress.fromHex(address);
    // final balance = await client.getBalance(ethAddress);

    // final ethBalance = balance.getValueInUnit(EtherUnit.ether);

    // print(ethBalance);

    // await client.sendTransaction(
    //   credentials,
    //   Transaction(
    //     to: EthereumAddress.fromHex(
    //         '0xC914Bb2ba888e3367bcecEb5C2d99DF7C7423706'),
    //     gasPrice: EtherAmount.inWei(BigInt.one),
    //     maxGas: 100000,
    //     value: EtherAmount.fromInt(EtherUnit.ether, 1),
    //   ),
    // );
