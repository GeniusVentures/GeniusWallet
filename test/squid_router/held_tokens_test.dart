import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/held_tokens.dart';
import 'package:genius_wallet/squid_router/models/squid_balance.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';

/// The pay-side holdings filter decided by Braian at the 08-07 walk:
/// "a user can't simply swap a BNB he does not have."
///
/// The asymmetry is the point — these cases pin what the PAY side drops. The
/// receive side never calls this, and a test asserting it does would be
/// asserting the opposite of the decision.
SquidTokenInfo _token({
  required String symbol,
  String? balance,
  int decimals = 18,
  int chainId = 1,
}) => SquidTokenInfo(
  chainId: chainId,
  address: '0x${symbol.toLowerCase()}',
  name: symbol,
  symbol: symbol,
  decimals: decimals,
  crosschain: true,
  commonKey: symbol,
  logoURI: '',
  coingeckoId: symbol.toLowerCase(),
  balance: balance == null
      ? null
      : SquidBalance(
          balance: balance,
          symbol: symbol,
          address: '0x${symbol.toLowerCase()}',
          decimals: decimals,
          chainId: '$chainId',
        ),
);

void main() {
  group('hasSpendableBalance', () {
    test('a token with no balance object at all is not spendable', () {
      expect(hasSpendableBalance(_token(symbol: 'BNB')), isFalse);
    });

    test('a zero balance is not spendable', () {
      expect(hasSpendableBalance(_token(symbol: 'BNB', balance: '0')), isFalse);
    });

    test('a whole-token balance is spendable', () {
      expect(
        hasSpendableBalance(
          _token(symbol: 'ETH', balance: '1000000000000000000'),
        ),
        isTrue,
      );
    });

    test('dust below the display floor is STILL spendable', () {
      // 1 wei renders as "<0.000001" in the picker. It is real, and hiding it
      // would be the filter deciding what is worth owning.
      expect(hasSpendableBalance(_token(symbol: 'ETH', balance: '1')), isTrue);
    });

    test('decimals never change the answer', () {
      // The same raw amount across wildly different decimals: scaling cannot
      // turn non-zero into zero, which is why the filter ignores decimals.
      for (final decimals in [0, 6, 18]) {
        expect(
          hasSpendableBalance(
            _token(symbol: 'TKN', balance: '5', decimals: decimals),
          ),
          isTrue,
          reason: 'decimals=$decimals should not affect spendability',
        );
      }
    });

    test('a malformed balance is rejected rather than thrown on', () {
      // amountAsDouble would bang-unwrap tryParse and take the picker down.
      expect(
        hasSpendableBalance(_token(symbol: 'BAD', balance: 'not-a-number')),
        isFalse,
      );
      expect(hasSpendableBalance(_token(symbol: 'BAD', balance: '')), isFalse);
    });
  });

  group('heldTokens', () {
    test('keeps only the tokens carrying a balance, in order', () {
      final tokens = [
        _token(symbol: 'ETH', balance: '1000000000000000000'),
        _token(symbol: 'BNB'),
        _token(symbol: 'USDT', balance: '2500000', decimals: 6),
        _token(symbol: 'DAI', balance: '0'),
      ];

      expect(heldTokens(tokens).map((t) => t.symbol).toList(), ['ETH', 'USDT']);
    });

    test('a wallet holding nothing yields an empty list, not a throw', () {
      final tokens = [_token(symbol: 'BNB'), _token(symbol: 'DAI')];
      expect(heldTokens(tokens), isEmpty);
    });

    test('an empty catalogue yields an empty list', () {
      expect(heldTokens([]), isEmpty);
    });

    test('the same token on two chains is judged per chain', () {
      final tokens = [
        _token(symbol: 'USDC', chainId: 1, balance: '1000000', decimals: 6),
        _token(symbol: 'USDC', chainId: 137, decimals: 6),
      ];
      final held = heldTokens(tokens);
      expect(held, hasLength(1));
      expect(held.single.chainId, 1);
    });
  });
}
