import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';

import '../squid_router/route_fixture.dart';

/// The adapter is the one place Squid's wire shape is read. If the mapping is
/// wrong, every figure above it is wrong and nothing else would catch it.

void main() {
  test('a same-chain quote maps every figure off the estimate', () {
    final quote = squidQuote(loadRouteFixture(sameChainRoute));

    expect(quote.exchangeRate, '0.757304');
    expect(quote.priceImpact, '0.03');
    expect(quote.id, isNotEmpty);
    expect(quote.fromAmount, BigInt.parse('1000000000000000000'));
    expect(quote.toAmount, BigInt.from(757304));
    expect(quote.toAmountMin, BigInt.from(752760));
    expect(quote.estimatedDuration, const Duration(seconds: 1));
  });

  test('each side is displayed at its own token decimals', () {
    final quote = squidQuote(loadRouteFixture(sameChainRoute));

    // 1 GNUS in, 0.757304 USDC out. Using one shared decimals value would
    // render the receive side as 0.000000000000757304 — the bug this mapping
    // exists to prevent.
    expect(quote.fromAmountDisplay, '1');
    expect(quote.toAmountDisplay, '0.757304');
  });

  test('a same-chain swap costs gas and nothing else', () {
    final quote = squidQuote(loadRouteFixture(sameChainRoute));

    expect(quote.feesUsd, 0.0);
    expect(quote.gasUsd, closeTo(0.01, 1e-9));
    expect(quote.totalCostUsd, closeTo(0.01, 1e-9));
  });

  test('a cross-chain swap adds the bridge fee to gas', () {
    final quote = squidQuote(loadRouteFixture(crossChainRoute));

    // The whole point of summing both: fees alone would report $0.48 and gas
    // alone $0.02, and each understates what leaves the wallet.
    expect(quote.feesUsd, closeTo(0.48, 1e-9));
    expect(quote.gasUsd, closeTo(0.02, 1e-9));
    expect(quote.totalCostUsd, closeTo(0.50, 1e-9));
  });

  test('two real quotes do not map to the same figures', () {
    final same = squidQuote(loadRouteFixture(sameChainRoute));
    final cross = squidQuote(loadRouteFixture(crossChainRoute));

    // A constant would survive every assertion above it. This is what says
    // the numbers actually track the response.
    expect(same.priceImpact, isNot(cross.priceImpact));
    expect(same.exchangeRate, isNot(cross.exchangeRate));
    expect(same.totalCostUsd, isNot(cross.totalCostUsd));
  });
}
