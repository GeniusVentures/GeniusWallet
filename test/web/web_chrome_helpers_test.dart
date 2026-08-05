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
}
