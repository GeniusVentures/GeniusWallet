import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_bridge_view_mobile.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';

import 'gnus_fakes.dart';

void main() {
  group('gnusPickerExtensions', () {
    for (final (accept, expected) in <(List<String>, List<String>?)>[
      (['.json', 'application/json'], ['json']),
      (['.JSON'], ['json']),
      ([' .json '], ['json']),
      (['.json', '.JSON', '.txt'], ['json', 'txt']),
      ([], null),
      (['image/*'], null),
      (['.'], null),
    ]) {
      test('$accept gives $expected', () {
        expect(gnusPickerExtensions(accept), expected);
      });
    }
  });

  group('gnusPickerAllowed', () {
    final allowed = gnusAllowedOrigins(SgnsNet.staging, dev: true);

    for (final (url, expected) in <(String?, bool)>[
      ('http://localhost:3000/jobs?x=1', true),
      ('https://gnus-dashboard-staging.invalid/', true),
      (null, false),
      ('about:blank', false),
      ('https://evil.example/', false),
      ('http://localhost:4000/', false),
      ('http://localhost.evil.com:3000/', false),
      ('file:///etc/passwd', false),
      ('not a url', false),
    ]) {
      test('$url is $expected', () {
        expect(gnusPickerAllowed(url, allowed), expected);
      });
    }

    test('a release allowlist refuses the dev origin', () {
      expect(
        gnusPickerAllowed(
          'http://localhost:3000/',
          gnusAllowedOrigins(SgnsNet.staging, dev: false),
        ),
        isFalse,
      );
    });

    test('the origin on the list is the one asked about', () {
      expect(allowed, contains(webOrigin('http://localhost:3000')));
    });
  });
}
