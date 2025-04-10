import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/app/assets/read_asset.dart';

class NetworkProvider extends ChangeNotifier {
  List<Network> _networks = [];

  List<Network> get networks => _networks;

  /// Load Networks from the assets
  Future<void> loadNetworks() async {
    try {
      _networks = await readNetworkAssets();
      notifyListeners();
    } catch (error) {
      debugPrint('Error loading networks: $error');
    }
  }

  /// Get Network by ID
  Network? getNetworkById(int chainId) {
    return _networks.firstWhere((network) => network.chainId == chainId,
        orElse: () => Network(chainId: -1, name: 'Unknown'));
  }
}
