import 'dart:convert';

import 'package:genius_api/assets/assets.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/web3/web3.dart';

Future<List<Network>> readNetworkAssets() async {
  const String assetLocation = 'assets/json/networks/networks.json';
  final String? response = await safeLoadAsset(assetLocation);

  if (response == null) {
    return List.empty();
  }

  final networksJson = await jsonDecode(response);

  List<Network> networkList = List<Network>.from(
      networksJson.map((network) => Network.fromJson(network)));

  return networkList;
}

Future<List<Network>> readNetworkBridgeAssets() async {
  const String assetLocation = 'assets/json/networks/bridge.json';
  final String? response = await safeLoadAsset(assetLocation);

  if (response == null) {
    return List.empty();
  }

  final networksJson = await jsonDecode(response);

  List<Network> networkList = List<Network>.from(
      networksJson.map((network) => Network.fromJson(network)));

  return networkList;
}

Future<Token?> getTokenFromNetworkByName(
    {required Network network, required String name}) async {
  final String? response = await safeLoadAsset(network.tokensPath ?? "");

  if (response == null) {
    return null;
  }

  final tokensJson = await jsonDecode(response);

  List<Token> tokensList =
      List<Token>.from(tokensJson.map((token) => Token.fromJson(token)));

  return tokensList
      .firstWhere((token) => token.name?.toLowerCase() == name.toLowerCase());
}

Future<List<Token>> getTokensFromNetwork({required Network network}) async {
  final String? response = await safeLoadAsset(network.tokensPath ?? "");

  if (response == null) {
    return List.empty();
  }

  final tokensJson = await jsonDecode(response);

  List<Token> tokensList =
      List<Token>.from(tokensJson.map((token) => Token.fromJson(token)));

  return tokensList;
}

Future<Coin?> fetchCoinBalance(
    {required String walletAddress,
    required Network network,
    required String coinName}) async {
  final web3 = Web3();
  final token =
      await getTokenFromNetworkByName(name: coinName, network: network);

  if (token == null) {
    return null;
  }

  final tokenAddress = token.address!;
  final coinSymbol =
      await web3.symbol(contractAddress: tokenAddress, rpcUrl: network.rpcUrl!);
  final balance = await web3.balanceOf(
      address: walletAddress,
      contractAddress: tokenAddress,
      rpcUrl: network.rpcUrl!);

  return Coin(
      balance: balance,
      address: tokenAddress,
      name: await web3.name(
          contractAddress: tokenAddress, rpcUrl: network.rpcUrl!),
      symbol: coinSymbol,
      networkSymbol: network.symbol,
      iconPath: token.iconPath);
}

Future<List<Coin>> readTokenAssets(
    {required String walletAddress, required Network network}) async {
  List<Token> tokensList = await getTokensFromNetwork(network: network);
  List<Coin> coinList = [];

  // add chains native coin
  final web3 = Web3();
  final balance =
      await web3.getBalance(rpcUrl: network.rpcUrl!, address: walletAddress);

  coinList.add(Coin(
      balance: balance,
      name: network.name,
      symbol: network.symbol?.toUpperCase(),
      networkSymbol: network.symbol,
      iconPath: network.iconPath));

  for (var tokenContract in tokensList) {
    if (tokenContract.address != null && tokenContract.address!.isNotEmpty) {
      final web3 = Web3();
      final coinSymbol = await web3.symbol(
          contractAddress: tokenContract.address!, rpcUrl: network.rpcUrl!);
      final coinDecimals = await web3.decimals(
          contractAddress: tokenContract.address!, rpcUrl: network.rpcUrl!);
      final balance = await web3.balanceOf(
          address: walletAddress,
          contractAddress: tokenContract.address!,
          rpcUrl: network.rpcUrl!);
      if (coinSymbol.isEmpty) {
        continue;
      }
      coinList.add(Coin(
          decimals: coinDecimals,
          balance: balance,
          address: tokenContract.address,
          name: await web3.name(
              contractAddress: tokenContract.address!, rpcUrl: network.rpcUrl!),
          symbol: coinSymbol,
          networkSymbol: network.symbol,
          iconPath: tokenContract.iconPath));
    }
  }

  return coinList;
}
