// A Linux desktop without NetworkManager makes connectivity_plus throw on
// every check. WalletConnect calls both checkConnectivity() and
// onConnectivityChanged while starting, so both must answer "online".

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/network/connectivity_fallback.dart';

class _NoNetworkManager extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      Future.error(StateError('org.freedesktop.DBus.Error.ServiceUnknown'));

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      Stream.error(StateError('org.freedesktop.DBus.Error.ServiceUnknown'));
}

class _Wifi extends ConnectivityPlatform {
  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => [
    ConnectivityResult.wifi,
  ];
}

void main() {
  late ConnectivityPlatform original;

  setUp(() {
    original = ConnectivityPlatform.instance;
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    ConnectivityPlatform.instance = original;
  });

  test('a failing backend is replaced by one that reports online', () async {
    ConnectivityPlatform.instance = _NoNetworkManager();

    await assumeOnlineWithoutNetworkManager();

    expect(await Connectivity().checkConnectivity(), [
      ConnectivityResult.ethernet,
    ]);
    expect(await Connectivity().onConnectivityChanged.toList(), [
      [ConnectivityResult.ethernet],
    ]);
  });

  test('a working backend is kept', () async {
    final wifi = _Wifi();
    ConnectivityPlatform.instance = wifi;

    await assumeOnlineWithoutNetworkManager();

    expect(ConnectivityPlatform.instance, same(wifi));
  });

  test('other platforms are never probed or replaced', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final failing = _NoNetworkManager();
    ConnectivityPlatform.instance = failing;

    await assumeOnlineWithoutNetworkManager();

    expect(ConnectivityPlatform.instance, same(failing));
  });
}
