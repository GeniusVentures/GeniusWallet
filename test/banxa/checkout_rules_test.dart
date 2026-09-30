import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  group('isTrustedCheckoutUrl', () {
    for (final url in [
      'https://banxa.com',
      'https://checkout.banxa.com/x',
      'https://gnus.banxa.com/x',
      'https://gnus.banxa-sandbox.com/x',
      'https://banxa-sandbox.com/orders/1',
    ]) {
      test('trusts $url', () {
        expect(isTrustedCheckoutUrl(Uri.parse(url)), isTrue);
      });
    }

    for (final url in [
      'http://checkout.banxa.com',
      'https://x.evilbanxa.com',
      'https://evilbanxa.com',
      'https://banxa.com.evil.io',
      'https://evil.io/banxa.com',
      'https://user@evil.io/?u=https://banxa.com',
      'javascript:alert(1)',
      'geniuswallet://banxa/callback',
      '',
    ]) {
      test('rejects "$url"', () {
        expect(isTrustedCheckoutUrl(Uri.parse(url)), isFalse);
      });
    }
  });

  group('isBanxaReturn', () {
    final base = BanxaApiService.returnUri.toString();

    test(
      'matches the constant, with or without a query, in the main frame',
      () {
        expect(isBanxaReturn(Uri.parse(base), isMainFrame: true), isTrue);
        expect(
          isBanxaReturn(Uri.parse('$base?orderId=1'), isMainFrame: true),
          isTrue,
        );
      },
    );

    test('ignores a subframe', () {
      expect(isBanxaReturn(Uri.parse(base), isMainFrame: false), isFalse);
    });

    test('ignores a null uri', () {
      expect(isBanxaReturn(null, isMainFrame: true), isFalse);
    });

    for (final url in [
      'geniuswallet://banxa/callback/more',
      'geniuswallet://other/callback',
      'otherscheme://banxa/callback',
      'https://evil.io/?next=$base',
      'https://banxa.com/geniuswallet://banxa/callback',
    ]) {
      test('does not match $url', () {
        expect(isBanxaReturn(Uri.parse(url), isMainFrame: true), isFalse);
      });
    }
  });

  group('allowsCheckoutNavigation', () {
    for (final url in [
      'https://checkout.banxa.com/x',
      'http://example.com',
      'about:blank',
    ]) {
      test('allows $url', () {
        expect(allowsCheckoutNavigation(Uri.parse(url)), isTrue);
      });
    }

    for (final url in [
      'intent://scan/#Intent;scheme=zxing;end',
      'javascript:alert(1)',
      'file:///etc/passwd',
      'mailto:a@b.co',
      'geniuswallet://banxa/callback',
    ]) {
      test('blocks $url', () {
        expect(allowsCheckoutNavigation(Uri.parse(url)), isFalse);
      });
    }

    test('blocks null', () {
      expect(allowsCheckoutNavigation(null), isFalse);
    });
  });

  group('checkoutHostKind', () {
    test('windows and linux use the system browser for now', () {
      expect(checkoutHostKind('windows'), CheckoutHostKind.external);
      expect(checkoutHostKind('linux'), CheckoutHostKind.external);
    });

    for (final os in ['android', 'ios', 'macos']) {
      test('$os uses the webview', () {
        expect(checkoutHostKind(os), CheckoutHostKind.webview);
      });
    }
  });

  group('checkoutPermissionAllowed', () {
    test('camera and microphone are allowed, alone or together', () {
      expect(
        checkoutPermissionAllowed({WebViewPermissionResourceType.camera}),
        isTrue,
      );
      expect(
        checkoutPermissionAllowed({WebViewPermissionResourceType.microphone}),
        isTrue,
      );
      expect(
        checkoutPermissionAllowed({
          WebViewPermissionResourceType.camera,
          WebViewPermissionResourceType.microphone,
        }),
        isTrue,
      );
    });

    test('anything else, or nothing, is refused', () {
      expect(checkoutPermissionAllowed({}), isFalse);
      expect(
        checkoutPermissionAllowed({
          WebViewPermissionResourceType.camera,
          const _Other(),
        }),
        isFalse,
      );
    });
  });
}

class _Other extends WebViewPermissionResourceType {
  const _Other() : super('geolocation');
}
