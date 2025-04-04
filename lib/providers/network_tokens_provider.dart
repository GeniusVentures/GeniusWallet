import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_wallet/app/assets/assets.dart';

class NetworkTokensProvider with ChangeNotifier {
  final Map<Network, List<Token>> _tokensByNetwork = {};

  Map<Network, List<Token>> get tokensByNetwork => _tokensByNetwork;

  /// Load tokens for all networks
  Future<void> loadTokensForNetworks(List<Network> networks) async {
    for (var network in networks) {
      final tokens = await _getTokensFromNetwork(network: network);
      _tokensByNetwork[network] = tokens;
    }
    notifyListeners();
  }

  /// Get tokens from a specific network
  Future<List<Token>> _getTokensFromNetwork({required Network network}) async {
    final String? response = await safeLoadAsset(network.tokensPath ?? "");

    if (response == null) {
      return List.empty();
    }

    final tokensJson = jsonDecode(response);
    List<Token> tokensList = List<Token>.from(
      tokensJson.map((token) => Token.fromJson(token)),
    );

    return tokensList;
  }

  /// Retrieve tokens by network
  List<Token> getTokensByNetwork(Network network) {
    return _tokensByNetwork[network] ?? [];
  }
}
