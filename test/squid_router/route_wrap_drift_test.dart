// The generated client cannot read a route that wraps.
//
// A same-chain NATIVE swap wraps ETH into WETH before it swaps, so the route
// carries a `wrap` action. `WrapDetails` requires `wrapper`, `coinAddresses`
// and `calls`; the live API sends none of the three at the top level, and the
// whole response is rejected over a field the quote never reads.
//
// So the quote maps the raw body, the way the executable route and the status
// poll already do. These cases pin both halves: the drift is real, and the
// mapper is immune to it.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';
import 'package:squidrouter/squidrouter.dart';

import 'route_fixture.dart';

Map<String, dynamic> _body(String name) =>
    jsonDecode(rawRouteFixture(name)) as Map<String, dynamic>;

void main() {
  test('the generated model still rejects a wrapping route', () {
    // Pins the REASON the raw path exists. If a regenerated client ever parses
    // this, the bypass can go — and this case is what will say so.
    expect(
      () => standardSerializers.deserializeWith(
        RouteResponseData.serializer,
        _body(wrapRoute),
      ),
      throwsA(isA<Object>()),
    );
  });

  test('the raw mapper reads the wrapping route the model cannot', () {
    final quote = squidQuoteFromJson(_body(wrapRoute));

    expect(quote.id, '348594b6d168c1c5db62787d714462f6');
    expect(quote.fromAmount, BigInt.from(5000000000000000));
    expect(quote.toAmount, BigInt.from(12339240));
    expect(quote.toAmountMin, BigInt.from(12271374));
    expect(quote.exchangeRate, '2467.848');
    expect(quote.priceImpact, '0.0');
  });

  test('each side scales by its own decimals, not one shared value', () {
    final quote = squidQuoteFromJson(_body(wrapRoute));

    // 18 decimals paying, 6 receiving. One shared value renders the receive
    // side a trillion times small.
    expect(quote.fromAmountDisplay, '0.005');
    expect(quote.toAmountDisplay, '12.33924');
  });

  test('a same-chain wrap costs gas and no bridge fee', () {
    final quote = squidQuoteFromJson(_body(wrapRoute));

    expect(quote.feesUsd, 0.0);
    // Squid's own figure: Base gas really is under a cent here. Pinned exactly
    // so a mapper that silently read nothing could not pass as "cheap".
    expect(quote.gasUsd, 0.0);
    expect(quote.estimatedDuration, const Duration(seconds: 1));
  });

  test('the raw mapper agrees with the generated one where both can read', () {
    // The older fixtures have no wrap action, so the model parses them. The
    // two paths must not disagree about the same bytes.
    for (final name in [sameChainRoute, crossChainRoute]) {
      final viaModel = squidQuote(loadRouteFixture(name));
      final viaRaw = squidQuoteFromJson(_body(name));

      expect(viaRaw.id, viaModel.id, reason: name);
      expect(viaRaw.fromAmount, viaModel.fromAmount, reason: name);
      expect(viaRaw.toAmount, viaModel.toAmount, reason: name);
      expect(viaRaw.toAmountMin, viaModel.toAmountMin, reason: name);
      expect(viaRaw.toAmountDisplay, viaModel.toAmountDisplay, reason: name);
      expect(viaRaw.feesUsd, viaModel.feesUsd, reason: name);
      expect(viaRaw.gasUsd, viaModel.gasUsd, reason: name);
      expect(
        viaRaw.estimatedDuration,
        viaModel.estimatedDuration,
        reason: name,
      );
    }
  });

  test('a body with no route is a route failure, not a crash', () {
    expect(
      () => squidQuoteFromJson(const {}),
      throwsA(isA<SwapRouteException>()),
    );
  });

  test('the generated fee enum hides the wire name behind its serializer', () {
    // Reading the accessor directly would put a screaming-case identifier in
    // front of a user; the human label only exists on the other side of the
    // serializer.
    expect(FeeType.GAS_RECEIVER_FEE.name, 'GAS_RECEIVER_FEE');
    expect(
      standardSerializers.serializeWith(
        FeeType.serializer,
        FeeType.GAS_RECEIVER_FEE,
      ),
      'Gas receiver fee',
    );
  });
}
