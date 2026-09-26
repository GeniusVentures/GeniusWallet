// WalletKit's init() ends in an unconditional pay.init(), and walletconnect_pay
// ships no desktop plugin, so init throws MissingPluginException there.
// stubPayOnDesktop() must swap in a platform that completes on desktop and
// leaves android/ios on the real method channel.

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/reown/reown_walletkit_instance.dart';
import 'package:walletconnect_pay/walletconnect_pay_method_channel.dart';
import 'package:walletconnect_pay/walletconnect_pay_platform_interface.dart';

void main() {
  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    WalletconnectPayPlatform.instance = MethodChannelWalletconnectPay();
  });

  group('Pay stub - desktop gets a no-op, mobile keeps the native plugin', () {
    for (final platform in [
      TargetPlatform.windows,
      TargetPlatform.macOS,
      TargetPlatform.linux,
    ]) {
      group('on $platform', () {
        setUp(() {
          debugDefaultTargetPlatformOverride = platform;
        });

        test('stubPayOnDesktop() replaces the method channel', () {
          stubPayOnDesktop();

          expect(
            WalletconnectPayPlatform.instance,
            isNot(isA<MethodChannelWalletconnectPay>()),
          );
        });

        test('initialize() completes with true', () async {
          stubPayOnDesktop();

          expect(await WalletconnectPayPlatform.instance.initialize(), isTrue);
        });

        test('every payment method throws UnsupportedError', () {
          stubPayOnDesktop();
          final stub = WalletconnectPayPlatform.instance;

          expect(
            () => stub.getPaymentOptions(requestJson: '{}'),
            throwsUnsupportedError,
          );
          expect(
            () => stub.getRequiredPaymentActions(requestJson: '{}'),
            throwsUnsupportedError,
          );
          expect(
            () => stub.confirmPayment(requestJson: '{}'),
            throwsUnsupportedError,
          );
        });
      });
    }

    for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
      test(
        'on $platform, stubPayOnDesktop() leaves the native plugin in place',
        () {
          debugDefaultTargetPlatformOverride = platform;

          stubPayOnDesktop();

          expect(
            WalletconnectPayPlatform.instance,
            isA<MethodChannelWalletconnectPay>(),
          );
        },
      );
    }
  });
}
