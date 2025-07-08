import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:genius_wallet/tokeninfo/token_info_loader.dart';
import 'package:genius_wallet/tokeninfo/token_model.g.dart';

void main() {
  group('TokenInfoLoader', () {
    late TokenInfoLoader tokenLoader;

    setUp(() {
      tokenLoader = TokenInfoLoader();
    });

    tearDown(() {
      tokenLoader.dispose();
    });

    test('loads single token from GitHub (first in array)', () async {
      final token = await tokenLoader.loadToken();

      expect(token, isNotNull);
      expect(token!.name, equals('GNUS'));
      expect(token.id, equals('0000000000000000000000000000000000000000000000000000000000000000'));
      expect(token.iconUrl, contains('GNUS.png'));
    });

    test('loads tokens as list', () async {
      final tokens = await tokenLoader.loadTokens();

      expect(tokens, isNotEmpty);
      expect(tokens.first.name, equals('GNUS'));
      // Should have multiple tokens now
      expect(tokens.length, greaterThan(1));
    });

    test('handles network errors gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final loader = TokenInfoLoader(
        httpClient: mockClient,
      );

      final token = await loader.loadToken();
      expect(token, isNull);

      final tokens = await loader.loadTokens();
      expect(tokens, isEmpty);
    });

    test('handles invalid JSON gracefully', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Invalid JSON', 200);
      });

      final loader = TokenInfoLoader(
        httpClient: mockClient,
      );

      final token = await loader.loadToken();
      expect(token, isNull);
    });

    test('handles both single object and array formats', () async {
      // Test array format
      final mockClientArray = MockClient((request) async {
        return http.Response('''
          [
            {
              "id": "0000000000000000000000000000000000000000000000000000000000000000",
              "name": "GNUS",
              "iconUrl": "https://example.com/gnus.png"
            },
            {
              "id": "1111111111111111111111111111111111111111111111111111111111111111",
              "name": "TEST",
              "iconUrl": "https://example.com/test.png"
            }
          ]
        ''', 200);
      });

      final loaderArray = TokenInfoLoader(httpClient: mockClientArray);
      final tokensFromArray = await loaderArray.loadTokens();
      expect(tokensFromArray.length, equals(2));

      // Test single object format (backward compatibility)
      final mockClientObject = MockClient((request) async {
        return http.Response('''
          {
            "id": "0000000000000000000000000000000000000000000000000000000000000000",
            "name": "GNUS",
            "iconUrl": "https://example.com/gnus.png"
          }
        ''', 200);
      });

      final loaderObject = TokenInfoLoader(httpClient: mockClientObject);
      final tokensFromObject = await loaderObject.loadTokens();
      expect(tokensFromObject.length, equals(1));
    });

    test('caching prevents unnecessary network calls', () async {
      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response('''
          [
            {
              "id": "0000000000000000000000000000000000000000000000000000000000000000",
              "name": "GNUS",
              "iconUrl": "https://example.com/icon.png"
            }
          ]
        ''', 200);
      });

      final loader = TokenInfoLoader(
        httpClient: mockClient,
      );

      // First call
      final tokens1 = await loader.loadTokensWithCache();
      expect(callCount, equals(1));
      expect(tokens1.length, equals(1));

      // Second call with cache
      final tokens2 = await loader.loadTokensWithCache(
        cachedTokens: tokens1,
        lastFetch: DateTime.now(),
        cacheDuration: const Duration(hours: 1),
      );
      expect(callCount, equals(1)); // No additional network call
      expect(tokens2, equals(tokens1));

      // Third call with expired cache
      final tokens3 = await loader.loadTokensWithCache(
        cachedTokens: tokens1,
        lastFetch: DateTime.now().subtract(const Duration(hours: 2)),
        cacheDuration: const Duration(hours: 1),
      );
      expect(callCount, equals(2)); // New network call
    });

    test('loadTokenById finds correct token', () async {
      final mockClient = MockClient((request) async {
        return http.Response('''
          [
            {
              "id": "0000000000000000000000000000000000000000000000000000000000000000",
              "name": "GNUS",
              "iconUrl": "https://example.com/gnus.png"
            },
            {
              "id": "1111111111111111111111111111111111111111111111111111111111111111",
              "name": "TEST",
              "iconUrl": "https://example.com/test.png"
            }
          ]
        ''', 200);
      });

      final loader = TokenInfoLoader(
        httpClient: mockClient,
      );

      final token = await loader.loadTokenById('1111111111111111111111111111111111111111111111111111111111111111');
      expect(token, isNotNull);
      expect(token!.name, equals('TEST'));

      final notFound = await loader.loadTokenById('nonexistent');
      expect(notFound, isNull);
    });

    test('loadGNUSToken returns GNUS token', () async {
      final gnusToken = await tokenLoader.loadGNUSToken();

      expect(gnusToken, isNotNull);
      expect(gnusToken!.name, equals('GNUS'));
      expect(gnusToken.id, equals('0000000000000000000000000000000000000000000000000000000000000000'));
    });

    test('loads real token data from GitHub URL', () async {
      // This is an integration test that hits the actual GitHub URL
      final realLoader = TokenInfoLoader();

      final token = await realLoader.loadToken();

      expect(token, isNotNull);
      expect(token!.name, equals('GNUS'));
      expect(token.id, equals('0000000000000000000000000000000000000000000000000000000000000000'));
      expect(token.iconUrl, equals('https://raw.githubusercontent.com/GeniusVentures/tokeninfo/main/images/GNUS.png'));

      // Test loading all tokens
      final tokens = await realLoader.loadTokens();
      expect(tokens, isNotEmpty);
      expect(tokens.first.name, equals('GNUS'));

      realLoader.dispose();
    });
  });
}