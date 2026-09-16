import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:squidrouter/squidrouter.dart';

/// The phase's offline proof: a recorded real `/v2/route` body, parsed by the
/// generated client. No network, no credential. Every later plan tests against
/// this file rather than against an invented shape.

RouteResponseData parseFixture([
  Map<String, dynamic> Function(Map<String, dynamic>)? edit,
]) {
  final raw = File(
    'test/squid_router/fixtures/route_response.json',
  ).readAsStringSync();
  final json = jsonDecode(raw) as Map<String, dynamic>;
  return standardSerializers.deserializeWith(
    RouteResponseData.serializer,
    edit == null ? json : edit(json),
  )!;
}

void main() {
  test('the recorded response deserializes into RouteResponseData', () {
    final data = parseFixture();
    final estimate = data.route.estimate;

    expect(estimate.exchangeRate, isNotEmpty);
    expect(estimate.aggregatePriceImpact, isNotEmpty);
    expect(estimate.toAmount, isNotEmpty);
    expect(estimate.toAmountMin, isNotEmpty);
    // 26-05 polls with this.
    expect(data.route.quoteId, isNotEmpty);
  });

  test('gas is charged and fees may legitimately be empty', () {
    final estimate = parseFixture().route.estimate;

    expect(estimate.gasCosts, isNotEmpty);
    expect(double.tryParse(estimate.gasCosts.first.amountUsd), isNotNull);
    // A same-chain swap carries no bridge fee. An empty list is a real route,
    // not a parse failure, so nothing downstream may treat it as one.
    expect(estimate.feeCosts, isNotNull);
    for (final fee in estimate.feeCosts) {
      expect(double.tryParse(fee.amountUsd), isNotNull);
    }
  });

  test('the two sides carry different decimals', () {
    final estimate = parseFixture().route.estimate;

    // The pay and receive sides scale differently, which is precisely the
    // case a single shared decimals value would get wrong.
    expect(estimate.fromToken.decimals, 18);
    expect(estimate.toToken.decimals, 6);
    expect(
      BigInt.parse(estimate.fromAmount),
      BigInt.parse('1000000000000000000'),
    );
    expect(
      BigInt.parse(estimate.toAmount) < BigInt.parse('1000000000'),
      isTrue,
    );
  });

  test('a quoteOnly route carries nothing signable', () {
    final wire =
        standardSerializers.serializeWith(
              RouteResponseData.serializer,
              parseFixture(),
            )
            as Map<String, dynamic>;
    final route = wire['route'] as Map<String, dynamic>;

    // Squid answers quoteOnly with an EMPTY transactionRequest rather than
    // omitting it, so "is it null" is the wrong question to ask before
    // signing — an executable route is one that carries target and calldata.
    expect(route['transactionRequest'], isEmpty);
  });

  test('the fixture carries no wallet address', () {
    final raw = File(
      'test/squid_router/fixtures/route_response.json',
    ).readAsStringSync();
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final params =
        (json['route'] as Map<String, dynamic>)['params']
            as Map<String, dynamic>;

    const zero = '0x0000000000000000000000000000000000000000';
    expect(params['fromAddress'], zero);
    expect(params['toAddress'], zero);
  });
}
