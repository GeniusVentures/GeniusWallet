// The money math behind the dApp transaction-approval screen.
//
// `handle_dapp_requests.dart` runs every `eth_sendTransaction` through these two
// functions to produce the amount, the gas total, the priority fee and the max
// fee-per-gas that `SendTransactionDetails` renders. Those numbers are what a
// user reads before deciding whether to sign. Until this file existed, nothing
// in the suite touched either function.
//
// This file goes red if:
//   - wei -> ETH conversion drifts at the 10 decimal places actually displayed,
//   - hex parsing stops handling the `0x` forms WalletConnect really sends,
//   - or either function's silent fallback-to-zero changes shape.
//
// That last group is deliberately pinned rather than "fixed". Both functions
// swallow bad input and return zero, which means a malformed request renders as
// **0 ETH on a signing prompt** instead of refusing to render. That is a real
// property worth arguing about (see the FALLBACK group below), but it is the
// shipped contract, and a test that asserts the current truth is what makes
// changing it a deliberate act rather than an accident.

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/reown/utilities.dart';

void main() {
  group('formatEth - the amount a user reads before signing', () {
    test('whole and fractional ETH convert exactly at 10dp', () {
      expect(formatEth('1000000000000000000'), '1.0000000000');
      expect(formatEth('500000000000000000'), '0.5000000000');
      expect(formatEth('12345678900000000000000'), '12345.6789000000');
      expect(formatEth('1000000000000000000000000'), '1000000.0000000000');
    });

    test('a large value keeps all 10 displayed decimals correct', () {
      // 1234567890123456789012345 wei is 1234567.890123456789012345 ETH.
      // BigInt / BigInt yields a double in Dart, so this is the case that would
      // expose precision loss if the display ever widened past 10dp.
      expect(formatEth('1234567890123456789012345'), '1234567.8901234567');
    });

    test('BigInt.parse accepts the 0x form, so a hex string round-trips', () {
      // 0x1bc16d674ec80000 == 2000000000000000000 wei == 2 ETH. The production
      // path converts hex to BigInt first and passes the decimal string, but
      // this asserts the function does not silently zero a hex input if a
      // caller ever skips that step.
      expect(formatEth('0x1bc16d674ec80000'), '2.0000000000');
    });

    test('sub-0.0000000001 ETH floors to zero at the display precision', () {
      // 1 wei is real value that renders as nothing. Pinned so that widening
      // the precision is a decision someone makes on purpose.
      expect(formatEth('1'), '0.0000000000');
    });

    group('FALLBACK - unparseable input renders as zero, not as an error', () {
      // Both cases return the STRING '0', not '0.0000000000' — the catch block
      // bypasses toStringAsFixed entirely. Anything asserting on the formatted
      // width needs to know that.
      test('garbage returns bare "0"', () {
        expect(formatEth('not-a-number'), '0');
      });

      test('empty returns bare "0"', () {
        expect(formatEth(''), '0');
      });
    });
  });

  group('parseHexToBigInt - the raw values off the wire', () {
    test('parses the hex WalletConnect sends, with and without 0x', () {
      expect(
        parseHexToBigInt('0x1bc16d674ec80000'),
        BigInt.parse('2000000000000000000'),
      );
      expect(
        parseHexToBigInt('1bc16d674ec80000'),
        BigInt.parse('2000000000000000000'),
      );
      expect(
        parseHexToBigInt('0xde0b6b3a7640000'),
        BigInt.parse('1000000000000000000'),
      );
    });

    test('the documented empty forms are zero', () {
      expect(parseHexToBigInt(null), BigInt.zero);
      expect(parseHexToBigInt('0x'), BigInt.zero);
      expect(parseHexToBigInt('0x0'), BigInt.zero);
    });

    test('FALLBACK - unparseable hex is zero, not an exception', () {
      // A malformed `value` or `gas` therefore shows as 0 on the approval
      // screen rather than refusing to render. Pinned, not endorsed.
      expect(parseHexToBigInt('0xnothex'), BigInt.zero);
      expect(parseHexToBigInt('zzz'), BigInt.zero);
    });

    test('a real gas limit and fee survive the round trip into formatEth', () {
      // Mirrors handle_dapp_requests.dart: gasLimit * maxFeePerGas, then format.
      final gasLimit = parseHexToBigInt('0x5208'); // 21000
      final maxFeePerGas = parseHexToBigInt('0x3b9aca00'); // 1 gwei
      expect(gasLimit, BigInt.from(21000));
      expect(maxFeePerGas, BigInt.from(1000000000));
      expect(formatEth((gasLimit * maxFeePerGas).toString()), '0.0000210000');
    });
  });
}
