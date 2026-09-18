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

    expect(quote.feeLines, isEmpty);
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
      expect(viaRaw.gasUsd, viaModel.gasUsd, reason: name);
      expect(
        viaRaw.estimatedDuration,
        viaModel.estimatedDuration,
        reason: name,
      );
      // FeeLine has identity equality, so the lists themselves would never
      // match — compare what a user would actually see instead.
      expect(
        viaRaw.feeLines.map((line) => line.name).toList(),
        viaModel.feeLines.map((line) => line.name).toList(),
        reason: name,
      );
      expect(
        viaRaw.feeLines.map((line) => line.amountUsd).toList(),
        viaModel.feeLines.map((line) => line.amountUsd).toList(),
        reason: name,
      );
    }
  });

  test('an unknown fee name stops the generated model, not the raw mapper', () {
    // The generated fee-name enum admits eight values and its deserializer
    // throws on anything else, so a route naming a fee nobody has seen before
    // cannot reach the typed mapper at all — the whole response is rejected.
    // The raw path carries the name through verbatim. That asymmetry is why
    // the screen reads the raw one, and it is pinned here so a later switch to
    // the typed path cannot make an unknown fee crash a swap unnoticed.
    final body = _body(crossChainRoute);
    final route = body['route'] as Map<String, dynamic>;
    final estimate = route['estimate'] as Map<String, dynamic>;
    final fee = (estimate['feeCosts'] as List).first as Map<String, dynamic>;
    fee['name'] = 'Newly invented fee';

    expect(
      () => standardSerializers.deserializeWith(
        RouteResponseData.serializer,
        body,
      ),
      throwsA(isA<Object>()),
    );
    expect(squidQuoteFromJson(body).feeLines.single.name, 'Newly invented fee');
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
