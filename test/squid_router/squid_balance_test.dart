import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';

/// Pins the balance math that the 08-07 walk found broken.
///
/// `amountAsDouble` divided by `(pow(10, decimals) as double)`. `pow` returns an
/// **int** when base and exponent are both ints — which they always are here —
/// so that cast threw `type 'int' is not a subtype of type 'double'` for every
/// token carrying a balance, on a line that had been in the tree since
/// `7c40615` (2025-05-12). It stayed dormant because its only reader,
/// `displayBalance`, catches and returns `'0'`. 08-03's CTA ladder added
/// `swap_screen`'s unguarded `fromBalanceAmount`, and the latent throw became
/// console spam plus an "Insufficient balance" rung that could never evaluate.
///
/// The first group is the regression itself: these calls must not throw. The
/// rest pin the rendering contract around them so a future "simplification"
/// back to a cast fails loudly here rather than at the user's swap screen.
SquidBalance _balance({required String raw, required int decimals}) =>
    SquidBalance(
      balance: raw,
      symbol: 'TKN',
      address: '0xabc',
      decimals: decimals,
      chainId: '1',
    );

void main() {
  group('amountAsDouble — the int/double regression', () {
    test('does not throw for an 18-decimal token', () {
      final b = _balance(raw: '1000000000000000000', decimals: 18);
      expect(b.amountAsDouble, closeTo(1.0, 1e-12));
    });

    test('does not throw for a 6-decimal token', () {
      final b = _balance(raw: '2500000', decimals: 6);
      expect(b.amountAsDouble, closeTo(2.5, 1e-12));
    });

    test('does not throw for a 0-decimal token', () {
      // pow(10, 0) is the int 1 — the cast threw here too.
      final b = _balance(raw: '7', decimals: 0);
      expect(b.amountAsDouble, closeTo(7.0, 1e-12));
    });

    test('a zero balance is zero, not a throw', () {
      final b = _balance(raw: '0', decimals: 18);
      expect(b.amountAsDouble, 0.0);
    });
  });

  group('displayBalance — no longer masks the throw as "0"', () {
    test('a held balance renders its real figure, not 0', () {
      final b = _balance(raw: '1000000000000000000', decimals: 18);
      expect(b.displayBalance, '1');
    });

    test('a fractional balance keeps six decimals, trailing zeros trimmed', () {
      // 2.5 USDC
      final b = _balance(raw: '2500000', decimals: 6);
      expect(b.displayBalance, '2.5');
    });

    test('an empty balance still reads "0" rather than crashing', () {
      final b = _balance(raw: '0', decimals: 6);
      expect(b.displayBalance, '0');
    });

    test('dust below the readable floor says "less than", never "0"', () {
      // 1 wei of an 18-decimal token: real, but smaller than 1e-6.
      final b = _balance(raw: '1', decimals: 18);
      expect(b.displayBalance, '<0.000001');
    });
  });

  group('the magnitude stress fixtures render as their comments claim', () {
    // These pin the four extremes added to `mockSquidBalances` at the 08-07
    // walk. The fixtures exist to stress the picker row and the 38px amount
    // slot; if a future edit changes what they render, the comment next to
    // each fixture becomes a lie and this group is where that surfaces.

    test('DUST: 1e-15 of an 18-decimal token reads "<0.000001"', () {
      expect(_balance(raw: '1000', decimals: 18).displayBalance, '<0.000001');
    });

    test('FLOOR: exactly 0.000001 reads as the figure, not "less than"', () {
      expect(_balance(raw: '1', decimals: 6).displayBalance, '0.000001');
    });

    test('LONG FRACTION: eighteen decimals are capped at six', () {
      expect(
        _balance(raw: '1234567890123456789', decimals: 18).displayBalance,
        '1.234568',
      );
    });

    test('HUGE: 1e12 whole tokens render every digit', () {
      expect(
        _balance(
          raw: '1000000000000000000000000000000',
          decimals: 18,
        ).displayBalance,
        '1000000000000',
      );
    });

    test('all four survive the pay-side spendability filter', () {
      // Dust especially — a filter that dropped it would be deciding what is
      // worth owning.
      for (final raw in [
        '1000',
        '1',
        '1234567890123456789',
        '1000000000000000000000000000000',
      ]) {
        expect(
          double.tryParse(raw)! > 0,
          isTrue,
          reason: '$raw must read as a spendable balance',
        );
      }
    });
  });
}
