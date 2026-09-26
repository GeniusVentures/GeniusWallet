import 'package:flutter/foundation.dart';
import 'package:reown_walletkit/reown_walletkit.dart';
import 'package:walletconnect_pay/walletconnect_pay_platform_interface.dart';

/// ponytail: WalletKit runs Pay's init unconditionally and Pay ships no
/// desktop plugin. This leans on a public but unexported platform-interface
/// file; remove it once Reown guards pay.init on unsupported platforms.
class _NoPayPlatform extends WalletconnectPayPlatform {
  @override
  Future<bool> initialize({
    String? apiKey,
    String? appId,
    String? clientId,
    String? baseUrl,
  }) => Future.value(true);

  @override
  Future<String> getPaymentOptions({required String requestJson}) =>
      throw UnsupportedError('WalletConnect Pay is not available on desktop');

  @override
  Future<String> getRequiredPaymentActions({required String requestJson}) =>
      throw UnsupportedError('WalletConnect Pay is not available on desktop');

  @override
  Future<String> confirmPayment({required String requestJson}) =>
      throw UnsupportedError('WalletConnect Pay is not available on desktop');
}

/// Installs a no-op Pay platform on windows, macOS and linux, where
/// walletconnect_pay ships no plugin and WalletKit.init() would otherwise
/// throw MissingPluginException.
void stubPayOnDesktop() {
  if (kIsWeb) {
    return;
  }
  switch (defaultTargetPlatform) {
    case TargetPlatform.windows:
    case TargetPlatform.macOS:
    case TargetPlatform.linux:
      WalletconnectPayPlatform.instance = _NoPayPlatform();
    case TargetPlatform.android:
    case TargetPlatform.iOS:
    case TargetPlatform.fuchsia:
      break;
  }
}

class WalletKitInstance {
  static final WalletKitInstance _instance = WalletKitInstance._internal();
  late final ReownWalletKit walletKit;
  Future<void>? _initFuture;

  factory WalletKitInstance() => _instance;

  WalletKitInstance._internal() {
    stubPayOnDesktop();
    walletKit = ReownWalletKit(
      core: ReownCore(projectId: '999123e54f32a21dbd087339746231b1'),
      metadata: const PairingMetadata(
        name: 'Gnus.ai Wallet',
        description: 'Gnus.ai wallet',
        url: 'https://gnus.ai/',
        icons: ['https://example.com/logo.png'],
      ),
    );
  }

  Future<void> initOnce() {
    final inFlight = _initFuture;
    if (inFlight != null) {
      return inFlight;
    }

    final future = walletKit.init();
    _initFuture = future;
    return future;
  }
}
