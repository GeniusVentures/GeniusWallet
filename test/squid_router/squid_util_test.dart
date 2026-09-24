import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';

/// `toBaseUnits` converts the typed amount into the integer the router spends.
/// A 10^18 error here is the whole balance, so every case is asserted.

void main() {
  _percentCases();
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

    test(
      'a leading decimal point parses, since the amount field allows it',
      () {
        expect(toBaseUnits('.5', 6), BigInt.from(500000));
        expect(toBaseUnits('2.', 6), BigInt.from(2000000));
      },
    );

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

// Squid sends a percentage as its own string, at whatever precision it likes.
// The row printed it verbatim, so a real impact read as `-0.0234567%`.
void _percentCases() {
  group('formatPercent', () {
    test('trims to two decimals and drops trailing zeros', () {
      expect(formatPercent('-0.3908'), '-0.39');
      expect(formatPercent('2467.848'), '2467.85');
      expect(formatPercent('1.50'), '1.5');
      expect(formatPercent('1.00'), '1');
    });

    test('a true zero says zero', () {
      expect(formatPercent('0.0'), '0');
      expect(formatPercent('0'), '0');
    });

    test('too small to show is not the same as none', () {
      // Rounding these to `0` would claim the route has no impact when it
      // has one. Sign is irrelevant at this magnitude; presence is not.
      expect(formatPercent('0.001'), '~0');
      expect(formatPercent('-0.004'), '~0');
    });

    test('an unreadable value is passed through, never invented', () {
      expect(formatPercent('n/a'), 'n/a');
      expect(formatPercent(''), '');
      // toStringAsFixed throws on a non-finite double; the raw string wins.
      expect(formatPercent('Infinity'), 'Infinity');
    });
  });

  group('capDecimals', () {
    test('a long fraction is cut, not rounded', () {
      // Rounding up would advertise a better rate than the route quoted.
      expect(capDecimals('0.757304', 4), '0.7573');
      expect(capDecimals('0.75739', 4), '0.7573');
    });

    test('a short value is left exactly as it came', () {
      expect(capDecimals('1', 4), '1');
      expect(capDecimals('0.75', 4), '0.75');
      expect(capDecimals('0.7573', 4), '0.7573');
    });

    test('trailing zeros the cut exposes are dropped', () {
      expect(capDecimals('0.750000123', 4), '0.75');
    });

    test('a value too small to survive the cut is left whole', () {
      // Cutting these to four places leaves only zeros, and rendering a real
      // amount as 0 would say the route returns nothing.
      expect(capDecimals('0.00001', 4), '0.00001');
      expect(capDecimals('0.000000000000000001', 4), '0.000000000000000001');
    });

    test('digits are counted from the first significant one', () {
      // Cutting at the fourth decimal PLACE renders 0.0001 and halves the
      // amount, so every value in [0.0001, 0.0002) reads as the same number.
      expect(capDecimals('0.00019999', 4), '0.0001999');
      expect(capDecimals('0.000123456', 4), '0.0001234');
    });

    test('an unreadable value is passed through, never invented', () {
      expect(capDecimals('n/a', 4), 'n/a');
      expect(capDecimals('', 4), '');
      expect(capDecimals('1e-9', 4), '1e-9');
      expect(capDecimals('0.757304', -1), '0.757304');
    });

    test('an all-zero fraction collapses to the whole number', () {
      expect(capDecimals('1.000000000000000000', 4), '1');
      expect(capDecimals('0.000000000000000000', 4), '0');
    });

    test('a pay amount rounds up, so the row never understates it', () {
      expect(capDecimals('1.23459', 4, roundUp: true), '1.2346');
      expect(capDecimals('0.750000123', 4, roundUp: true), '0.7501');
      expect(capDecimals('0.99999', 4, roundUp: true), '1');
      expect(capDecimals('0.00019999', 4, roundUp: true), '0.0002');
      // Nothing was discarded, so there is nothing to round.
      expect(capDecimals('1.23450000', 4, roundUp: true), '1.2345');
      expect(capDecimals('1.2345', 4, roundUp: true), '1.2345');
    });

    test('no double is involved, so 18 digits survive intact', () {
      // A double cannot hold this; a formatter that parsed one would round it.
      expect(capDecimals('123456789.123456789012345678', 4), '123456789.1234');
    });
  });
}
