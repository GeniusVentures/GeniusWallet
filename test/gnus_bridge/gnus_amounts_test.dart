import 'dart:math' show pow;

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/utilities.dart' show gnusBurnBaseUnits;
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';

void main() {
  test('cost conversion is exact and rejects a non-positive cost', () {
    expect(gnusCostBaseUnits(1), '1000000000000000000');
    expect(gnusCostBaseUnits(1234), '1234000000000000000000');
    expect(gnusCostBaseUnits(0), isNull);
    expect(gnusCostBaseUnits(-5), isNull);
  });

  test('the burn converts exactly the cost the confirm shows', () {
    // 2363 is the first odd cost a double product cannot hold.
    for (final minions in [1, 1234, 2363, 999999999]) {
      final shown = BigInt.parse(gnusCostBaseUnits(minions)!);
      expect(gnusBurnBaseUnits('$minions', 18), shown, reason: '$minions');
    }
    expect(
      BigInt.from(double.parse('2363') * pow(10, 18)),
      isNot(BigInt.parse(gnusCostBaseUnits(2363)!)),
    );
  });

  test('the burn refuses a token whose decimals are not 18', () {
    expect(gnusBurnBaseUnits('1234', 6), isNull);
    expect(gnusBurnBaseUnits('12e3', 18), isNull);
  });

  test('payer balance conversion is exact for plain and exponent doubles', () {
    expect(gnusBalanceBaseUnits(0.1), '100000000000000000');
    expect(gnusBalanceBaseUnits(12.34), '12340000000000000000');
    expect(gnusBalanceBaseUnits(99999.99), '99999990000000000000000');
    expect(gnusBalanceBaseUnits(1234.0), '1234000000000000000000');
    expect(gnusBalanceBaseUnits(0.0), '0');
    expect(gnusBalanceBaseUnits(1e-7), '100000000000');
    expect(gnusBalanceBaseUnits(1.5e21), '1500000000000000000000${'0' * 18}');
    expect(gnusBalanceBaseUnits(1e-19), '0');
  });

  test('payer balance conversion adds nothing to the input digits', () {
    expect(gnusBalanceBaseUnits(0.1 + 0.2), '300000000000000040');
  });

  test('payer balance conversion rejects a value that is not a balance', () {
    expect(gnusBalanceBaseUnits(null), isNull);
    expect(gnusBalanceBaseUnits(double.nan), isNull);
    expect(gnusBalanceBaseUnits(double.infinity), isNull);
    expect(gnusBalanceBaseUnits(-1.0), isNull);
  });

  test('node balance conversion keeps all six SDK decimals', () {
    expect(
      sgnusBalanceBaseUnits('18446744073709.551615'),
      '18446744073709551615000000000000',
    );
    expect(sgnusBalanceBaseUnits('12.5'), '12500000000000000000');
    expect(sgnusBalanceBaseUnits(' 0 '), '0');
  });

  test('node balance conversion rejects a string that is not a decimal', () {
    for (final bad in ['', 'abc', '1e5', '-1', '.']) {
      expect(sgnusBalanceBaseUnits(bad), isNull, reason: bad);
    }
  });

  test('gas price parsing keeps only a real number', () {
    expect(gnusGasPrice('1.00 Gwei', 'pol'), {
      'gasPriceGwei': '1.00',
      'symbol': 'POL',
    });
    expect(gnusGasPrice('42.42 Gwei', 'ETH'), {
      'gasPriceGwei': '42.42',
      'symbol': 'ETH',
    });
    expect(gnusGasPrice('null Gwei', 'POL'), isNull);
    expect(gnusGasPrice(null, 'POL'), isNull);
    expect(gnusGasPrice('1.00 Gwei', null), isNull);
    expect(gnusGasPrice('1.00 Gwei', ''), isNull);
    expect(gnusGasPrice('1.00', 'POL'), isNull);
  });

  test('a cost converted here displays as the whole number it came from', () {
    expect(
      formatTokenAmount(BigInt.parse(gnusCostBaseUnits(1234)!), kGnusDecimals),
      '1234',
    );
  });
}
