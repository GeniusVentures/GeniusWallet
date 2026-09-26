// WalletKit's init() ends in an unconditional pay.init(), and walletconnect_pay
// ships no desktop plugin, so init throws MissingPluginException there.
// stubPayOnDesktop() must swap in a platform that completes on desktop and
// leaves android/ios on the real method channel.

import 'dart:async';

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

  group('WalletKitInstance.initOnce() - retry after failure, single start', () {
    test('a failed start is forgotten; the next call retries', () async {
      var callCount = 0;
      final instance = WalletKitInstance.withInit(() async {
        callCount++;
        if (callCount == 1) {
          throw StateError('relay unreachable');
        }
      });

      await expectLater(instance.initOnce(), throwsStateError);
      expect(callCount, 1);

      await instance.initOnce();
      expect(callCount, 2);
    });

    test('two concurrent calls share one in-flight start', () async {
      var callCount = 0;
      final gate = Completer<void>();
      final instance = WalletKitInstance.withInit(() {
        callCount++;
        return gate.future;
      });

      final first = instance.initOnce();
      final second = instance.initOnce();

      expect(identical(first, second), isTrue);
      expect(callCount, 1);

      gate.complete();
      await Future.wait([first, second]);
    });

    test('a successful start is never repeated', () async {
      var callCount = 0;
      final instance = WalletKitInstance.withInit(() async {
        callCount++;
      });

      await instance.initOnce();
      await instance.initOnce();

      expect(callCount, 1);
    });
  });
}
