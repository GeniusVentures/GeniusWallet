import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/web/web_utils.dart';

void main() {
  group('opensInApp', () {
    test('linux without WebKitGTK uses the system browser', () {
      expect(opensInApp('linux', linuxWebKit: false), isFalse);
    });

    test('linux with WebKitGTK opens inside the app', () {
      expect(opensInApp('linux', linuxWebKit: true), isTrue);
    });

    test('other platforms always open inside the app', () {
      for (final os in ['windows', 'macos', 'android', 'ios']) {
        expect(opensInApp(os, linuxWebKit: false), isTrue, reason: os);
      }
    });
  });
}
