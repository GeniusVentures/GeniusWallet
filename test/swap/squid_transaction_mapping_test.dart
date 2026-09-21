// The unwrap, proven against a recorded executable route.
//
// 26-03's fixture was fetched with `quoteOnly`, so its transactionRequest is
// an empty object and cannot prove any of this. This one is a real
// `quoteOnly: false` body, wallet address redacted to all-zero.
//
// The load-bearing case is the number format. Squid sends value, gasLimit and
// the two fee fields as DECIMAL strings; the signer parses every one of them
// as hex. A gasLimit of "969344" read as hex is 9,868,100 — ten times the
// real figure, on a value that costs money. So the assertions below run the
// mapped strings back through the signer's own parser rather than comparing
// them to hand-written hex.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/utilities.dart';
import 'package:genius_wallet/squid_router/squid_swap_provider.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

const _wallet = '0x1111111111111111111111111111111111111111';
const _squidRouter = '0xce16F69375520ab01377ce7B88f5BA8C48F8D666';

Map<String, dynamic> _body() => jsonDecode(_raw()) as Map<String, dynamic>;

String _raw() => File(
  'test/squid_router/fixtures/route_response_executable.json',
).readAsStringSync();

Map<String, dynamic> _route(Map<String, dynamic> body) =>
    body['route'] as Map<String, dynamic>;

Map<String, dynamic> _wire(Map<String, dynamic> body) =>
    _route(body)['transactionRequest'] as Map<String, dynamic>;

SwapTransaction _mapped({String? requestId = 'header-request-id'}) =>
    squidTransaction(_body(), from: _wallet, requestId: requestId);

void main() {
  group('the signable map', () {
    test('target becomes to, and the wallet fills in the missing from', () {
      final tx = _mapped();

      // The body carries `target` and no `from` at all.
      expect(tx.request['to'], _squidRouter);
      expect(tx.request['from'], _wallet);
      expect(tx.spender, _squidRouter);
    });

    test('calldata passes through untouched', () {
      final data = _wire(_body())['data'] as String;

      expect(_mapped().request['data'], data);
      expect(data, startsWith('0x'));
    });

    test('the numbers survive the signer\'s own hex parser', () {
      final tx = _mapped();
      final wire = _wire(_body());

      for (final pair in [
        ('gas', 'gasLimit'),
        ('maxFeePerGas', 'maxFeePerGas'),
        ('maxPriorityFeePerGas', 'maxPriorityFeePerGas'),
        ('value', 'value'),
      ]) {
        expect(
          parseHexToBigInt(tx.request[pair.$1]),
          BigInt.parse(wire[pair.$2].toString()),
          reason: '${pair.$1} did not round-trip through the signer',
        );
      }
    });

    test('gasLimit lands on the key the signer reads FIRST', () {
      // `tx['gas'] ?? tx['gasLimit']` — writing only gasLimit would work
      // today and break the moment a caller sets gas.
      expect(_mapped().request.containsKey('gas'), isTrue);
    });

    test('every value is hex-prefixed, because every one is parsed as hex', () {
      final tx = _mapped();

      for (final key in [
        'value',
        'gas',
        'maxFeePerGas',
        'maxPriorityFeePerGas',
        'data',
      ]) {
        expect(tx.request[key], startsWith('0x'), reason: key);
      }
    });
  });

  group('the handles polling needs', () {
    test('requestId comes from the header, not the body', () {
      expect(_mapped().requestId, 'header-request-id');
    });

    test('a missing header falls back to the transactionRequest field', () {
      // The top-level body field is absent entirely; this one is populated.
      final wire = _wire(_body());

      expect(_mapped(requestId: null).requestId, wire['requestId']);
      expect(wire['requestId'], isNotNull);
    });

    test('quoteId is carried', () {
      expect(_mapped().quoteId, _route(_body())['quoteId']);
    });
  });

  group('what is refused, and as which failure', () {
    // The KIND matters, not just the throw: 26-07 gives "no route for this
    // pair" and "the route is unsignable" different copy, and it reads the
    // kind off this exception rather than off an error string.
    SwapRouteFailure failureOf(Map<String, dynamic> body) {
      try {
        squidTransaction(body, from: _wallet, requestId: null);
      } on SwapRouteException catch (e) {
        return e.failure;
      }
      fail('nothing was thrown');
    }

    test('a body with no route is unavailable, not unsignable', () {
      expect(failureOf(const {}), SwapRouteFailure.unavailable);
    });

    test('a quoteOnly body, whose transactionRequest is empty', () {
      final body = _body();
      _route(body)['transactionRequest'] = <String, dynamic>{};

      expect(failureOf(body), SwapRouteFailure.unsignable);
    });

    test('a route type this wallet cannot sign', () {
      // Chainflip deposit-address routes are a different execution model.
      final body = _body();
      _wire(body)['type'] = 'CHAINFLIP_DEPOSIT_ADDRESS';

      expect(failureOf(body), SwapRouteFailure.unsignable);
    });

    test('the thrown exception carries no node detail into its toString', () {
      // Its `detail` is for logs; a screen that printed it would leak a URL.
      final body = _body();
      _wire(body)['type'] = 'CHAINFLIP_DEPOSIT_ADDRESS';

      try {
        squidTransaction(body, from: _wallet, requestId: null);
      } on SwapRouteException catch (e) {
        expect(e.toString(), 'SwapRouteException(unsignable)');
      }
    });
  });

  group('the Squid status vocabulary', () {
    test('every reported status maps', () {
      expect(swapStatusFrom('success'), SwapStatus.success);
      expect(swapStatusFrom('partial_success'), SwapStatus.partialSuccess);
      expect(swapStatusFrom('needs_gas'), SwapStatus.needsGas);
      expect(swapStatusFrom('ongoing'), SwapStatus.ongoing);
      expect(swapStatusFrom('refunded'), SwapStatus.refunded);
      expect(
        swapStatusFrom('failed_on_destination'),
        SwapStatus.failedOnDestination,
      );
      expect(swapStatusFrom('not_found'), SwapStatus.notFound);
    });

    test('anything unrecognised is not an answer, so polling continues', () {
      expect(swapStatusFrom(null), SwapStatus.notFound);
      expect(swapStatusFrom('brand_new_status'), SwapStatus.notFound);
    });
  });

  group('the fixture is safe to commit', () {
    test('it holds no wallet address', () {
      final raw = _raw();
      final params = _route(_body())['params'] as Map<String, dynamic>;

      expect(params['fromAddress'], '0x${'0' * 40}');
      expect(params['toAddress'], '0x${'0' * 40}');
      // The capture address was a well-known public one and is redacted
      // everywhere it appeared, calldata included.
      expect(raw.toLowerCase(), isNot(contains('d8da6bf26964af9d7eed9e03')));
    });
  });
}
