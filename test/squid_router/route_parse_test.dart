import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:squidrouter/squidrouter.dart';

import 'route_fixture.dart';

/// The phase's offline proof: recorded real `/v2/route` bodies, parsed by the
/// generated client. Every later plan tests against these rather than against
/// an invented shape.

void main() {
  test('the recorded responses deserialize into RouteResponseData', () {
    for (final name in [sameChainRoute, crossChainRoute]) {
      final estimate = loadRouteFixture(name).route.estimate;

      expect(estimate.exchangeRate, isNotEmpty, reason: name);
      expect(estimate.aggregatePriceImpact, isNotEmpty, reason: name);
      expect(estimate.toAmount, isNotEmpty, reason: name);
      expect(estimate.toAmountMin, isNotEmpty, reason: name);
      // 26-05 follows a quote up with this.
      expect(loadRouteFixture(name).route.quoteId, isNotEmpty, reason: name);
    }
  });

  test('gas is always charged; fees are not', () {
    // A same-chain swap carries no bridge fee. An empty list is a real route,
    // not a parse failure, so nothing downstream may treat it as one.
    expect(
      loadRouteFixture(sameChainRoute).route.estimate.gasCosts,
      isNotEmpty,
    );
    expect(loadRouteFixture(sameChainRoute).route.estimate.feeCosts, isEmpty);
    expect(
      loadRouteFixture(crossChainRoute).route.estimate.feeCosts,
      isNotEmpty,
    );
  });

  test('the two sides carry different decimals', () {
    final estimate = loadRouteFixture(sameChainRoute).route.estimate;

    // The pay and receive sides scale differently, which is precisely the
    // case a single shared decimals value would get wrong.
    expect(estimate.fromToken.decimals, 18);
    expect(estimate.toToken.decimals, 6);
    expect(
      BigInt.parse(estimate.fromAmount),
      BigInt.parse('1000000000000000000'),
    );
    expect(BigInt.parse(estimate.toAmount) < BigInt.from(1000000000), isTrue);
  });

  test('a quoteOnly route carries nothing signable', () {
    final wire =
        standardSerializers.serializeWith(
              RouteResponseData.serializer,
              loadRouteFixture(sameChainRoute),
            )
            as Map<String, dynamic>;

    // Squid answers quoteOnly with an EMPTY transactionRequest rather than
    // omitting it, so "is it null" is the wrong question to ask before
    // signing — an executable route is one carrying target and calldata.
    expect(
      (wire['route'] as Map<String, dynamic>)['transactionRequest'],
      isEmpty,
    );
  });

  test('neither fixture carries a wallet address', () {
    const zero = '0x0000000000000000000000000000000000000000';

    for (final name in [sameChainRoute, crossChainRoute]) {
      final json = jsonDecode(rawRouteFixture(name)) as Map<String, dynamic>;
      final params =
          (json['route'] as Map<String, dynamic>)['params']
              as Map<String, dynamic>;

      expect(params['fromAddress'], zero, reason: name);
      expect(params['toAddress'], zero, reason: name);
    }
  });
}
