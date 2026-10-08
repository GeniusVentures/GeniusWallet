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
    // Only a missing NetworkManager is permanent; any other failure may be
    // transient, and replacing the backend would hide real changes for good.
    // Matched by name to avoid depending on the dbus package's exception type.
    if (!e.toString().contains(_serviceUnknown)) {
      return;
    }
    debugPrint('NetworkManager missing, assuming online: $e');
    ConnectivityPlatform.instance = _AssumedOnline();
  }
}

const _serviceUnknown = 'org.freedesktop.DBus.Error.ServiceUnknown';

class _AssumedOnline extends ConnectivityPlatform {
  // Ethernet, not `other`: WalletConnect treats `other` as offline.
  static const _online = [ConnectivityResult.ethernet];

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => _online;

  @override
  // Broadcast, like the plugin's own stream: pages listen to it more than once.
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.multi((listener) {
        listener.add(_online);
        listener.close();
      }, isBroadcast: true);
}
