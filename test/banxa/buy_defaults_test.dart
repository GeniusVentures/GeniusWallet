import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_helpers/buy_defaults.dart';

void main() {
  group('defaultFiatCode', () {
    test('uses the locale currency when it is offered', () {
      expect(defaultFiatCode('en_US', ['EUR', 'USD']), 'USD');
      expect(defaultFiatCode('de_DE', ['EUR', 'USD']), 'EUR');
    });

    test('falls back to USD, then the first offered', () {
      expect(defaultFiatCode('de_DE', ['USD', 'GBP']), 'USD');
      expect(defaultFiatCode('de_DE', ['GBP']), 'GBP');
      expect(defaultFiatCode('xx', ['EUR', 'USD']), 'USD');
    });
  });

  group('presetAmounts', () {
    test('scales from the minimum', () {
      expect(presetAmounts(min: 20, max: 15000), [50, 100, 250, 500]);
    });

    test('drops presets above the maximum', () {
      expect(presetAmounts(min: 20, max: 200), [50, 100]);
    });

    test('a missing minimum behaves like 20', () {
      expect(presetAmounts(min: 0, max: 15000), [50, 100, 250, 500]);
    });

    test('a large minimum gives four increasing values above 2.5x it', () {
      final p = presetAmounts(min: 300000, max: 0);
      expect(p, hasLength(4));
      expect(p.first, greaterThanOrEqualTo(300000 * 2.5));
      for (var i = 1; i < p.length; i++) {
        expect(p[i], greaterThan(p[i - 1]));
      }
    });

    test('every preset is 1, 2, 2.5 or 5 times a power of ten, once', () {
      for (final min in [0.5, 1, 3, 7, 20, 45, 100, 999, 1000, 300000]) {
        final p = presetAmounts(min: min, max: 0);
        expect(p.toSet(), hasLength(p.length), reason: 'min $min');
        for (final v in p) {
          var f = v.toDouble();
          while (f >= 10) {
            f /= 10;
          }
          while (f < 1) {
            f *= 10;
          }
          expect(
            [1, 2, 2.5, 5].any((s) => (s - f).abs() < 1e-9),
            isTrue,
            reason: 'min $min gave $v',
          );
        }
      }
    });
  });
}
