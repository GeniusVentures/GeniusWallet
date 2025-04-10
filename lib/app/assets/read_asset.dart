import 'dart:convert';
import 'package:flutter/material.dart';

import 'assets.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/web3/web3.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';

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

Future<List<Coin>> readTokenAssets({
  required String walletAddress,
  required Network network,
  required NetworkTokensProvider networkTokensProvider,
}) async {
  final web3 = Web3();
  List<Token> tokensList = networkTokensProvider.getTokensByNetwork(network);

  // Create futures for native token balance and token contract data
  final List<Future<Coin?>> futures = [
    _fetchNativeToken(web3, walletAddress, network),
    ...tokensList
        .where((token) => token.address != null && token.address!.isNotEmpty)
        .map((token) => _fetchTokenData(token, network, walletAddress)),
  ];

  final results = await Future.wait(futures);

  // Filter out null results and return the combined coin list
  return results.whereType<Coin>().toList();
}

/// **Fetch Native Token Data**
Future<Coin?> _fetchNativeToken(
    Web3 web3, String walletAddress, Network network) async {
  try {
    final balance = await web3.getBalance(
      rpcUrl: network.rpcUrl!,
      address: walletAddress,
    );

    return Coin(
      balance: balance,
      name: network.name,
      symbol: network.symbol?.toUpperCase(),
      networkSymbol: network.symbol,
      iconPath: network.iconPath,
      coinGeckoId: network.coinGeckoId,
    );
  } catch (e) {
    debugPrint("⚠️ Error fetching native token for ${network.name}: $e");
    return null;
  }
}

/// **Fetch Token Contract Data**
Future<Coin?> _fetchTokenData(
  Token tokenContract,
  Network network,
  String walletAddress,
) async {
  try {
    final web3 = Web3();

    final result = await web3.fetchTokenDetailsMulticall(
      contractAddress: tokenContract.address!,
      walletAddress: walletAddress,
      rpcUrl: network.rpcUrl!,
    );

    if (result['symbol'].isEmpty) {
      debugPrint("❌ Could not find token ${tokenContract.name}, skipping");
      return null;
    }

    return Coin(
      decimals: result['decimals'].toString(),
      balance: result['balance'],
      address: tokenContract.address,
      name: result['name'],
      symbol: result['symbol'],
      networkSymbol: network.symbol,
      iconPath: tokenContract.iconPath,
      coinGeckoId: tokenContract.coinGeckoId,
    );
  } catch (e) {
    debugPrint("⚠️ Error fetching data for ${tokenContract.name}: $e");
    return null;
  }
}
