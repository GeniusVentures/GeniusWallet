import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_quote.dart';

/// The live walk. Skipped without an integrator ID, so a plain `flutter test`
/// stays credential-free and offline. Run it with:
///   flutter test test/swap/live_quote_walk_test.dart --dart-define-from-file=squid.local.json

const _gnusOnBase = '0x614577036F0a024DBC1C88BA616b394DD65d105a';
const _usdcOnBase = '0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913';
const _publicAddress = '0xd8dA6BF26964aF9D7eEd9e03E53415D37aA96045';

SwapQuoteRequest _request(String typedAmount) => SwapQuoteRequest(
  fromChainId: '8453',
  fromToken: _gnusOnBase,
  fromAmount: toBaseUnits(typedAmount, 18)!,
  toChainId: '8453',
  toToken: _usdcOnBase,
  fromAddress: _publicAddress,
  toAddress: _publicAddress,
  slippage: 0.5,
);

void main() {
  test(
    'a typed amount reaches Squid and a real rate comes back',
    () async {
      const provider = SquidSwapProvider();

      final one = await provider.quote(_request('1'));
      // 1 RPS on this tier, so the second call waits rather than looking like
      // a bug in our code.
      await Future<void>.delayed(const Duration(seconds: 2));
      final ten = await provider.quote(_request('10'));

      // The mock answered 993.72 for every pair and every amount.
      expect(double.parse(one.exchangeRate), lessThan(10));
      expect(one.exchangeRate, isNot('993.72'));

      // The rate moves with the amount, which a constant cannot do.
      expect(ten.exchangeRate, isNot(one.exchangeRate));
      expect(ten.toAmount, greaterThan(one.toAmount));
      expect(ten.id, isNot(one.id));

      // The receive side is USDC at 6 decimals against a GNUS pay side at 18.
      expect(one.fromAmountDisplay, '1');
      expect(one.toAmountDisplay.split('.').last.length, lessThanOrEqualTo(6));
      expect(one.gasUsd, greaterThan(0));
    },
    skip: squidConfigured ? false : 'no integrator ID in this build',
  );
}
