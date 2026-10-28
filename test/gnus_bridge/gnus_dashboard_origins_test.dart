import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';

import 'gnus_fakes.dart';

void main() {
  group('gnusAllowedOrigins', () {
    test('a release build allows only the pinned origin', () {
      final allowed = gnusAllowedOrigins(SgnsNet.staging, dev: false);

      expect(allowed, {webOrigin(gnusDashboardOrigin(SgnsNet.staging))});
      expect(allowed, isNot(contains(webOrigin('http://localhost:3000'))));
    });

    test('a dev build adds the localhost origin', () {
      final allowed = gnusAllowedOrigins(SgnsNet.staging, dev: true);

      expect(allowed, contains(webOrigin('http://localhost:3000')));
      expect(allowed, hasLength(2));
    });

    test('a dev origin that is not http on localhost is ignored', () {
      for (final bad in [
        'http://evil.com',
        'https://localhost',
        'http://localhost.evil.com',
        'http://127.0.0.1:3000',
        'ftp://localhost',
        'not a url',
        '',
      ]) {
        expect(
          gnusAllowedOrigins(SgnsNet.staging, dev: true, devOrigin: bad),
          hasLength(1),
          reason: bad,
        );
      }
    });

    test('a dev origin on another port is accepted', () {
      final allowed = gnusAllowedOrigins(
        SgnsNet.staging,
        dev: true,
        devOrigin: 'HTTP://LocalHost:4000/x',
      );

      expect(allowed, contains(webOrigin('http://localhost:4000')));
    });

    test('the pinned staging origin is not a name anyone can register', () {
      expect(gnusDashboardOrigin(SgnsNet.staging), endsWith('.invalid'));
    });
  });
}
