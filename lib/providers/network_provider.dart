import 'package:flutter/material.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/assets/read_asset.dart';

/// The persisted network if it is still allowed, else the first mainnet, so a
/// testnet chosen in developer mode does not come back once it is off.
Network restoreSelectedNetwork(
  List<Network> networks, {
  int? chainId,
  String? rpcUrl,
  required bool allowTestnets,
}) {
  return networks
          .where(
            (n) =>
                n.chainId == chainId &&
                n.rpcUrl == rpcUrl &&
                (allowTestnets || !n.testnet),
          )
          .firstOrNull ??
      networks.firstWhere((n) => !n.testnet, orElse: () => networks.first);
}

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
    return _networks.firstWhere(
      (network) => network.chainId == chainId,
      orElse: () => const Network(chainId: -1, name: 'Unknown'),
    );
  }
}
