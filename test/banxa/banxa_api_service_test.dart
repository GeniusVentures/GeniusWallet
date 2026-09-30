import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_env.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _key = 'test-key-not-a-real-secret';

BanxaApiService _service(
  List<http.Request> seen, {
  bool sandbox = false,
  int status = 200,
  String? body,
  String apiKey = _key,
}) {
  return BanxaApiService(
    apiKey: apiKey,
    sandbox: sandbox,
    client: MockClient((request) async {
      seen.add(request);
      final answer =
          body ??
          (request.url.path.endsWith('/orders')
              ? '{"orders": [], "total": 0, "pageTotal": 0}'
              : '[]');
      return http.Response(answer, status);
    }),
  );
}

Future<void> _createOrder(BanxaApiService service) {
  return service.createBuyOrder(
    fiatCurrency: 'USD',
    cryptoCurrency: 'GNUS',
    paymentMethodId: 'card',
    walletAddress: '0xabc',
    blockchain: 'ETH',
    cryptoAmount: '10',
  );
}

void main() {
  group('base URL', () {
    test('production calls go to api.banxa.com', () async {
      final seen = <http.Request>[];
      final service = _service(seen);

      await service.getFiatCurrencies();

      expect(
        seen.single.url.toString(),
        'https://api.banxa.com/gnus/v2/fiats/buy',
      );
    });

    test(
      'sandbox sends every call, order listing included, to the sandbox',
      () async {
        final seen = <http.Request>[];
        final service = _service(seen, sandbox: true);

        await service.fetchAllOrders(
          startDateUtc: 'a',
          endDateUtc: 'b',
          externalCustomerId: 'cust',
        );

        expect(seen, isNotEmpty);
        for (final request in seen) {
          expect(request.url.host, 'api.banxa-sandbox.com');
          expect(request.url.path, '/gnus/v2/orders');
        }
      },
    );

    test('production order listing uses the production host', () async {
      final seen = <http.Request>[];
      final service = _service(seen);

      await service.fetchAllOrders(
        startDateUtc: 'a',
        endDateUtc: 'b',
        externalCustomerId: 'cust',
      );

      expect(seen.single.url.host, 'api.banxa.com');
    });

    test('banxaApiBase names both environments', () {
      expect(banxaApiBase(sandbox: false), 'https://api.banxa.com/gnus/v2');
      expect(
        banxaApiBase(sandbox: true),
        'https://api.banxa-sandbox.com/gnus/v2',
      );
    });
  });

  group('the key', () {
    test('rides only in x-api-key, never in a URL', () async {
      final seen = <http.Request>[];
      final service = _service(seen);

      await service.getFiatCurrencies();
      await service.fetchAllOrders(
        startDateUtc: 'a',
        endDateUtc: 'b',
        externalCustomerId: 'cust',
      );

      expect(seen.length, 2);
      for (final request in seen) {
        expect(request.headers['x-api-key'], _key);
        expect(request.url.toString(), isNot(contains(_key)));
      }
    });

    test('isConfigured follows the key, isSandbox follows the flag', () {
      expect(BanxaApiService(apiKey: '', sandbox: false).isConfigured, isFalse);
      expect(BanxaApiService(apiKey: _key, sandbox: true).isConfigured, isTrue);
      expect(BanxaApiService(apiKey: _key, sandbox: true).isSandbox, isTrue);
      expect(BanxaApiService(apiKey: _key, sandbox: false).isSandbox, isFalse);
    });
  });

  group('create order', () {
    test('sends the one return address with no per-order query', () async {
      final seen = <http.Request>[];
      final service = _service(seen, body: '{"id": "o1", "checkoutUrl": "u"}');

      await _createOrder(service);

      final body = jsonDecode(seen.single.body) as Map<String, dynamic>;
      expect(body['redirectUrl'], BanxaApiService.redirectUrl);
      expect(BanxaApiService.returnUri.toString(), BanxaApiService.redirectUrl);
      expect(body['externalOrderId'], startsWith('order_'));
    });

    test(
      'a rejected return address is a typed error without the body',
      () async {
        final seen = <http.Request>[];
        final service = _service(
          seen,
          status: 422,
          body: '{"errors": {"redirectUrl": ["invalid"]}}',
        );

        await expectLater(
          _createOrder(service),
          throwsA(
            isA<BanxaRequestException>()
                .having((e) => e.statusCode, 'statusCode', 422)
                .having(
                  (e) => e.toString(),
                  'toString',
                  isNot(contains('redirectUrl')),
                ),
          ),
        );
      },
    );

    test('a 500 is the same typed error on any call', () async {
      final seen = <http.Request>[];
      final service = _service(seen, status: 500, body: 'secret detail');

      final calls = <Future<Object?> Function()>[
        service.getFiatCurrencies,
        service.getCryptoCurrencies,
        () => service.getOrderById('o1'),
        () => _createOrder(service),
        () => service.getQuote(
          paymentMethodId: 'card',
          crypto: 'GNUS',
          blockchain: 'ETH',
          fiat: 'USD',
          fiatAmount: '10',
        ),
        () => service.fetchAllOrders(
          startDateUtc: 'a',
          endDateUtc: 'b',
          externalCustomerId: 'cust',
        ),
      ];

      for (final call in calls) {
        await expectLater(
          call(),
          throwsA(
            isA<BanxaRequestException>()
                .having((e) => e.statusCode, 'statusCode', 500)
                .having(
                  (e) => e.toString(),
                  'toString',
                  isNot(contains('secret')),
                ),
          ),
        );
      }
    });
  });

  group('timeout', () {
    test('a request that never answers fails instead of hanging', () async {
      final service = BanxaApiService(
        apiKey: _key,
        timeout: const Duration(milliseconds: 20),
        client: MockClient((_) => Completer<http.Response>().future),
      );

      await expectLater(
        service.getOrderById('o1'),
        throwsA(isA<TimeoutException>()),
      );
      await expectLater(
        _createOrder(service),
        throwsA(isA<TimeoutException>()),
      );
    });
  });
}
