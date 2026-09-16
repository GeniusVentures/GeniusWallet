import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';

/// `toBaseUnits` converts the typed amount into the integer the router spends.
/// A 10^18 error here is the whole balance, so every case is asserted.

void main() {
  group('toBaseUnits', () {
    test('a fractional amount scales by the token decimals', () {
      expect(toBaseUnits('1.5', 18), BigInt.parse('1500000000000000000'));
      expect(toBaseUnits('1', 6), BigInt.from(1000000));
      expect(toBaseUnits('0.75', 6), BigInt.from(750000));
    });

    test('the smallest representable unit survives', () {
      expect(toBaseUnits('0.000000000000000001', 18), BigInt.one);
      expect(toBaseUnits('0.000001', 6), BigInt.one);
    });

    test('a fraction longer than decimals truncates and never throws', () {
      // 0.1234567 at 6 decimals is 123456 units, not 123457: the router
      // cannot spend the seventh digit, and rounding up spends more than
      // the user typed.
      expect(toBaseUnits('0.1234567', 6), BigInt.from(123456));
      expect(toBaseUnits('0.9999999', 6), BigInt.from(999999));
      expect(toBaseUnits('1.5', 0), BigInt.one);
    });

    test('an unparseable amount is null, never zero', () {
      // Zero would be sent to the router as a real amount. Null cannot be.
      for (final bad in ['', '  ', '.', 'abc', '1.2.3', '-1', '1e18', '1,5']) {
        expect(toBaseUnits(bad, 18), isNull, reason: 'input "$bad"');
      }
    });

    test('a leading decimal point parses, since the amount field allows it', () {
      expect(toBaseUnits('.5', 6), BigInt.from(500000));
      expect(toBaseUnits('2.', 6), BigInt.from(2000000));
    });

    test('a hostile decimals value returns null rather than throwing', () {
      // Decimals come from Squid, which is outside our trust boundary.
      expect(toBaseUnits('1', -1), isNull);
    });

    test('it is the inverse of formatTokenAmount', () {
      for (final raw in [
        '1',
        '1000000000000000000',
        '1234567890123456789',
        '757304',
      ]) {
        final decimals = raw.length > 10 ? 18 : 6;
        final formatted = formatTokenAmount(BigInt.parse(raw), decimals);
        expect(toBaseUnits(formatted, decimals), BigInt.parse(raw));
      }
    });
  });
}
