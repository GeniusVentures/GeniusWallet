import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// connectivity_plus reads Linux connectivity from NetworkManager over D-Bus.
/// Without it every check throws, and WalletConnect refuses to start, so a
/// failed first check swaps in a platform that always reports online.
Future<void> assumeOnlineWithoutNetworkManager() async {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.linux) {
    return;
  }
  try {
    await ConnectivityPlatform.instance.checkConnectivity();
  } catch (e) {
    debugPrint('Connectivity unavailable, assuming online: $e');
    ConnectivityPlatform.instance = _AssumedOnline();
  }
}

class _AssumedOnline extends ConnectivityPlatform {
  // Ethernet, not `other`: WalletConnect treats `other` as offline.
  static const _online = [ConnectivityResult.ethernet];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _online;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.value(_online);
}
