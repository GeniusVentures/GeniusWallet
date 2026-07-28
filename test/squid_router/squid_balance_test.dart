// The ONE check `SquidBalance` owes.
//
// `amountAsDouble` was `double.tryParse(balance)! / (pow(10, decimals) as
// double)`, and that cast threw on EVERY real token: `pow(int, int)` hands back
// a `num` that is an int at runtime whenever the result fits in an int64, which
// covers every `decimals <= 18`.
//
// It survived because two of the three callers catch and print '0' - so the
// token picker showed a column of honest-looking zeroes next to tokens the
// wallet actually held. The third caller, the swap CTA, has no catch, so
// picking a pay token crashed the whole swap screen.
//
// Hence both halves below: the number must be RIGHT (a zero that is a lie is
// the failure this bug shipped as), and the picker's string must agree with it.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';

SquidBalance _balance(String raw, int decimals) => SquidBalance(
      balance: raw,
      symbol: 'TKN',
      address: '0x0',
      decimals: decimals,
      chainId: '1',
    );

void main() {
  group('amountAsDouble', () {
    test('18 decimals - the case that crashed the swap screen', () {
      // 1.5 ETH in wei. 10^18 fits in an int64, so `pow` returns an int here.
      expect(_balance('1500000000000000000', 18).amountAsDouble, 1.5);
    });

    test('6 decimals - USDC/USDT', () {
      expect(_balance('2500000', 6).amountAsDouble, 2.5);
    });

    test('0 decimals - pow returns the int 1', () {
      expect(_balance('42', 0).amountAsDouble, 42.0);
    });

    test('an unparseable balance is null, never 0', () {
      // 0 would make the swap CTA say "Insufficient TKN" about data it never
      // received. `swap_screen.dart`'s `fromBalanceAmount` documents that rule.
      expect(_balance('', 18).amountAsDouble, isNull);
      expect(_balance('not-a-number', 18).amountAsDouble, isNull);
    });
  });

  group('displayBalance', () {
    test('prints the held amount instead of the catch branch 0', () {
      expect(_balance('1500000000000000000', 18).displayBalance, '1.5');
      expect(_balance('2500000', 6).displayBalance, '2.5');
    });

    test('a real zero still prints 0', () {
      expect(_balance('0', 18).displayBalance, '0');
    });

    test('dust below the 6-decimal window says so rather than lying', () {
      expect(_balance('1', 18).displayBalance, '<0.000001');
    });
  });
}
