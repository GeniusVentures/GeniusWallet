// The one view type the swap screen has of a token, and the balance maths the
// picker renders through it.
//
// It replaces two hand-written models that duplicated an aggregator's wire
// shapes. The magnitude cases at the bottom are the extremes a real wallet
// produces — they were fixtures in a fabricated balance list until now, and
// they are the reason the picker row and the 38px amount slot are known to
// survive a real token magnitude at all.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_token.dart';

SwapToken _token({
  String symbol = 'TKN',
  String address = '0xabc',
  String chainId = '1',
  int decimals = 18,
  String? raw,
}) => SwapToken(
  chainId: chainId,
  address: address,
  name: symbol,
  symbol: symbol,
  decimals: decimals,
  rawBalance: raw == null ? null : BigInt.parse(raw),
);

void main() {
  group('identity is address AND chain', () {
    test('the same address on two chains is two different tokens', () {
      final onEthereum = _token(address: '0xSAME', chainId: '1');
      final onPolygon = _token(address: '0xSAME', chainId: '137');
      expect(onEthereum.sameAs(onPolygon), isFalse);
    });

    test('address case is not identity — checksummed matches lowercase', () {
      expect(
        _token(address: '0xAbCd').sameAs(_token(address: '0xabcd')),
        isTrue,
      );
    });

    test('null is never the same as anything', () {
      expect(_token().sameAs(null), isFalse);
    });

    test('a balance is not part of identity', () {
      expect(_token(raw: '5').sameAs(_token()), isTrue);
    });
  });

  group('displayBalance — the figure a person reads', () {
    test('DUST: 1e-15 of an 18-decimal token says "less than", never 0', () {
      // The wallet holds something. Rounding it to 0 would be a lie.
      expect(_token(raw: '1000').displayBalance, '<0.000001');
    });

    test('FLOOR: one raw unit of a 6-decimal token is the figure itself', () {
      expect(_token(raw: '1', decimals: 6).displayBalance, '0.000001');
    });

    test('LONG FRACTION: eighteen decimals are capped at six', () {
      expect(_token(raw: '1234567890123456789').displayBalance, '1.234568');
    });

    test('HUGE: 1e12 whole tokens render every digit', () {
      expect(
        _token(raw: '1000000000000000000000000000000').displayBalance,
        '1000000000000',
      );
    });

    test('a whole balance drops its decimal point', () {
      expect(_token(raw: '1000000000000000000').displayBalance, '1');
    });

    test('a fractional balance trims trailing zeros', () {
      expect(_token(raw: '2500000', decimals: 6).displayBalance, '2.5');
    });

    test('absent and zero both read "0" rather than throwing', () {
      expect(_token().displayBalance, '0');
      expect(_token(raw: '0').displayBalance, '0');
    });
  });

  group('formattedBalance — the string MAX puts in the amount field', () {
    test('the LONG FRACTION keeps every digit the wallet holds', () {
      // displayBalance caps at six for the eye; MAX may not, or the tap
      // either strands dust or asks for more than the wallet has.
      expect(
        _token(raw: '1234567890123456789').formattedBalance,
        '1.234567890123456789',
      );
    });

    test('the four magnitudes round-trip exactly', () {
      expect(_token(raw: '1000').formattedBalance, '0.000000000000001');
      expect(_token(raw: '1', decimals: 6).formattedBalance, '0.000001');
      expect(
        _token(raw: '1000000000000000000000000000000').formattedBalance,
        '1000000000000',
      );
      expect(_token(raw: '1000000000000000000').formattedBalance, '1');
    });

    test('MAX never asks for more than the wallet holds', () {
      for (final raw in [
        '1234567890123456789',
        '999999999999999999999999999999',
        '1',
        '1000',
      ]) {
        final token = _token(raw: raw);
        expect(
          toBaseUnits(token.formattedBalance, token.decimals),
          BigInt.parse(raw),
          reason: '$raw did not survive the MAX round trip',
        );
      }
    });
  });

  group('amountAsDouble — the CTA reads this', () {
    test('an absent balance is null, never 0', () {
      // "Insufficient ETH" on data that never arrived is a lie.
      expect(_token().amountAsDouble, isNull);
    });

    test('a zero balance is 0, not null', () {
      expect(_token(raw: '0').amountAsDouble, 0.0);
    });

    test('scales by the token decimals', () {
      expect(
        _token(raw: '2500000', decimals: 6).amountAsDouble,
        closeTo(2.5, 1e-12),
      );
      expect(_token(raw: '7', decimals: 0).amountAsDouble, closeTo(7.0, 1e-12));
    });
  });

  group(
    'isPlausibleDecimals — the provider reports this, we do not read it',
    () {
      test('the values real tokens carry are accepted', () {
        for (final d in [0, 6, 8, 9, 18]) {
          expect(isPlausibleDecimals(d), isTrue, reason: 'decimals=$d');
        }
      });

      test('a negative or absurd value is refused', () {
        // An aggregator publishing the wrong decimals misprices an amount by a
        // power of ten. This catches only the absurd; it cannot catch 16-for-18.
        expect(isPlausibleDecimals(-1), isFalse);
        expect(isPlausibleDecimals(37), isFalse);
        expect(isPlausibleDecimals(256), isFalse);
      });

      test('a fractional value is refused', () {
        expect(isPlausibleDecimals(18.5), isFalse);
      });
    },
  );
}
