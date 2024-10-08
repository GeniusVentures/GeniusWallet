import 'dart:convert';

import 'package:genius_api/assets/assets.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/network_symbol.dart';
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

Future<List<Coin>> readTokenAssets(
    {required String walletAddress,
    required String rpcUrl,
    required NetworkSymbol networkSymbol}) async {
  final String assetLocation = 'assets/json/${networkSymbol.name}/tokens.json';
  final String? response = await safeLoadAsset(assetLocation);

  if (response == null) {
    return List.empty();
  }

  final tokensJson = await jsonDecode(response);

  List<Token> tokensList =
      List<Token>.from(tokensJson.map((token) => Token.fromJson(token)));
  List<Coin> coinList = [];
  for (var tokenContract in tokensList) {
    if (tokenContract.address != null && tokenContract.address!.isNotEmpty) {
      final web3 = Web3();
      final coinSymbol = await web3.symbol(
          contractAddress: tokenContract.address!, rpcUrl: rpcUrl);
      final balance = await web3.balanceOf(
          address: walletAddress,
          contractAddress: tokenContract.address!,
          rpcUrl: rpcUrl);
      if (coinSymbol.isEmpty) {
        continue;
      }
      coinList.add(Coin(
          balance: balance,
          name: await web3.name(
              contractAddress: tokenContract.address!, rpcUrl: rpcUrl),
          symbol: coinSymbol,
          networkSymbol: networkSymbol,
          // Try to find a crypto image by symbol
          iconPath: coinSymbol.isNotEmpty
              ? 'assets/images/crypto/${coinSymbol.toLowerCase()}.png'
              : ''));
    }
  }

  return coinList;
}
