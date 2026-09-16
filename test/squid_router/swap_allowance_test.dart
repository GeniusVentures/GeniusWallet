import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/swap_allowance.dart';

/// A router contract cannot move a token it holds no allowance for, and a
/// standing unlimited allowance to one is how wallets get drained. These cases
/// pin both halves: when an approval is asked for, and for how much.
const _usdcOnBase = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';
const _zeroAddress = '0x0000000000000000000000000000000000000000';
const _squidNativeSentinel = '0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE';

/// The value this module exists to never produce.
final _uint256Max = BigInt.two.pow(256) - BigInt.one;

void main() {
  group('native tokens need no approval', () {
    test('the all-zero address is native, whatever the allowance', () {
      final decision = decideApproval(
        tokenAddress: _zeroAddress,
        allowance: BigInt.zero,
        amount: BigInt.from(5) * BigInt.from(10).pow(18),
      );

      expect(decision, isA<ApprovalNotRequired>());
    });

    test("Squid's 0xEeee sentinel is native, in any case", () {
      for (final address in [
        _squidNativeSentinel,
        _squidNativeSentinel.toLowerCase(),
        _squidNativeSentinel.toUpperCase(),
      ]) {
        expect(
          decideApproval(
            tokenAddress: address,
            allowance: BigInt.zero,
            amount: BigInt.one,
          ),
          isA<ApprovalNotRequired>(),
          reason: '$address is the native sentinel',
        );
      }
    });

    test('an ERC-20 address is not mistaken for native', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.zero,
        amount: BigInt.one,
      );

      expect(decision, isA<ApproveExactAmount>());
    });
  });

  group('an allowance that already covers the amount is left alone', () {
    test('allowance greater than the amount is sufficient', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.from(2000000),
        amount: BigInt.from(1000000),
      );

      expect(decision, isA<AllowanceSufficient>());
    });

    test('allowance exactly equal to the amount is sufficient', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.from(1000000),
        amount: BigInt.from(1000000),
      );

      expect(decision, isA<AllowanceSufficient>());
    });

    test('a zero amount needs nothing, even with a zero allowance', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.zero,
        amount: BigInt.zero,
      );

      expect(decision, isA<AllowanceSufficient>());
    });
  });

  group('a short allowance is topped up for exactly the swap amount', () {
    test('a zero allowance against a real amount asks for approval', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.zero,
        amount: BigInt.from(1000000),
      );

      expect(decision, isA<ApproveExactAmount>());
    });

    test('an allowance one unit short still asks for approval', () {
      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.from(999999),
        amount: BigInt.from(1000000),
      );

      expect(decision, isA<ApproveExactAmount>());
    });

    test('the approved amount equals the swap amount exactly', () {
      final amount = BigInt.parse('1234567890123456789');

      final decision = decideApproval(
        tokenAddress: _usdcOnBase,
        allowance: BigInt.from(1000),
        amount: amount,
      );

      expect((decision as ApproveExactAmount).amount, amount);
    });

    test('the approved amount is never uint256 max', () {
      final amount = BigInt.from(10).pow(18);

      final decision =
          decideApproval(
                tokenAddress: _usdcOnBase,
                allowance: BigInt.zero,
                amount: amount,
              )
              as ApproveExactAmount;

      expect(decision.amount, amount);
      expect(decision.amount, lessThan(_uint256Max));
    });
  });
}
