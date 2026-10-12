import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/web/web_chrome_helpers.dart';

void main() {
  group('webDisplayHost', () {
    test('extracts host from a full https url', () {
      expect(webDisplayHost('https://app.uniswap.org/swap'), 'app.uniswap.org');
    });

    test('keeps www and recovers host past an un-encoded query space', () {
      expect(
        webDisplayHost('https://www.google.com/search?q=eth price'),
        'www.google.com',
      );
    });

    test('returns raw input for a hostless scheme (about:blank)', () {
      expect(webDisplayHost('about:blank'), 'about:blank');
    });

    test('returns raw input for unparseable / mid-typing text', () {
      expect(webDisplayHost('not a url'), 'not a url');
    });

    test('never throws and trims surrounding whitespace', () {
      expect(webDisplayHost('  https://x.com/a  '), 'x.com');
    });
  });

  group('tabIndexAfterClose', () {
    int after(int active, int closed, int newLength) => tabIndexAfterClose(
      active: active,
      closed: closed,
      newLength: newLength,
    );

    test('closing a tab after the active one leaves the active tab', () {
      expect(after(0, 2, 2), 0);
      expect(after(1, 2, 2), 1);
    });

    test('closing a tab before the active one follows it left', () {
      expect(after(2, 0, 2), 1);
      expect(after(2, 1, 2), 1);
    });

    test('closing the active tab picks the one that slid into its place', () {
      expect(after(1, 1, 3), 1);
      expect(after(0, 0, 2), 0);
    });

    test('closing the active last tab picks the new last', () {
      expect(after(2, 2, 2), 1);
    });
  });

  group('webIsSecure', () {
    test('https is secure', () => expect(webIsSecure('https://x.com'), true));
    test(
      'http is not secure',
      () => expect(webIsSecure('http://x.com'), false),
    );
    test(
      'about:blank is not secure',
      () => expect(webIsSecure('about:blank'), false),
    );
  });

  group('isOpenableWebUrl', () {
    test('accepts an absolute https url', () {
      expect(isOpenableWebUrl('https://gnus.ai/tos.html'), isTrue);
    });

    test('refuses every other scheme', () {
      for (final url in [
        'http://gnus.ai',
        'file:///etc/passwd',
        'javascript:alert(1)',
        'data:text/html,hi',
        'ftp://gnus.ai',
        'about:blank',
      ]) {
        expect(isOpenableWebUrl(url), isFalse, reason: url);
      }
    });

    test('refuses a missing, empty, hostless or unparseable url', () {
      for (final url in [null, '', 'https://', 'gnus.ai', ' https://gnus.ai']) {
        expect(isOpenableWebUrl(url), isFalse, reason: '$url');
      }
    });
  });
}
