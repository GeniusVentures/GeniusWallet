import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:squidrouter/squidrouter.dart';

Map<String, dynamic> _wire(RouteRequest request) =>
    standardSerializers.serializeWith(RouteRequest.serializer, request)
        as Map<String, dynamic>;

void main() {
  group('the request Squid is sent', () {
    test('a quoteOnly route carries every field the API requires', () {
      final json = _wire(
        RouteRequest(
          (b) => b
            ..fromChain = '8453'
            ..fromToken = '0x0000000000000000000000000000000000000000'
            ..fromAmount = '1000000000000000'
            ..toChain = '137'
            ..toToken = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174'
            ..quoteOnly = true,
        ),
      );

      expect(json['fromChain'], '8453');
      expect(json['fromToken'], '0x0000000000000000000000000000000000000000');
      expect(json['fromAmount'], '1000000000000000');
      expect(json['toChain'], '137');
      expect(json['toToken'], '0x2791bca1f2de4661ed88a30c99a7a9449aa84174');
      expect(json['quoteOnly'], isTrue);
    });

    test(
      'quoteOnly is absent unless asked for, so a route is never a quote',
      () {
        final json = _wire(
          RouteRequest(
            (b) => b
              ..fromChain = '8453'
              ..fromToken = '0x0000000000000000000000000000000000000000'
              ..fromAmount = '1'
              ..toChain = '137'
              ..toToken = '0x2791bca1f2de4661ed88a30c99a7a9449aa84174',
          ),
        );

        expect(json.containsKey('quoteOnly'), isFalse);
      },
    );
  });

  group('the client app code reaches', () {
    test('points at the v2 host', () {
      expect(Squidrouter.basePath, 'https://v2.api.squidrouter.com');
    });

    test('resolves the two calls a swap needs, and is built once', () {
      final api = squidApi();

      expect(api.getRoute, isA<Function>());
      expect(api.getStatus, isA<Function>());
      expect(identical(api, squidApi()), isTrue);
    });
  });

  group('availability', () {
    test('an unconfigured build reports itself unavailable', () {
      // No --dart-define under `flutter test`, so this is the default build.
      expect(kSquidIntegratorId, isEmpty);
      expect(squidConfigured, isFalse);
    });
  });
}
