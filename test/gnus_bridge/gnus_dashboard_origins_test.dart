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

  group('gnusNavigation', () {
    final allowed = gnusAllowedOrigins(SgnsNet.staging, dev: true);
    const dash = 'http://localhost:3000';

    // frame, url, expected
    final table = <(GnusFrame, String?, GnusNavigation)>[
      (GnusFrame.main, '$dash/page', GnusNavigation.allow),
      (GnusFrame.main, 'HTTP://LocalHost:3000/x', GnusNavigation.allow),
      (GnusFrame.main, 'http://localhost:3001/', GnusNavigation.external),
      (GnusFrame.main, 'https://evil.example/a', GnusNavigation.external),
      (GnusFrame.main, 'https://localhost:3000', GnusNavigation.external),
      (GnusFrame.main, 'about:blank', GnusNavigation.block),
      (GnusFrame.main, 'javascript:alert(1)', GnusNavigation.block),
      (GnusFrame.main, 'file:///etc/passwd', GnusNavigation.block),
      (GnusFrame.main, 'data:text/html,<b>x</b>', GnusNavigation.block),
      (GnusFrame.main, 'intent://x#Intent;end', GnusNavigation.block),
      (GnusFrame.main, null, GnusNavigation.block),
      (GnusFrame.unknown, '$dash/', GnusNavigation.allow),
      (GnusFrame.unknown, 'about:blank', GnusNavigation.allow),
      (GnusFrame.unknown, 'about:srcdoc', GnusNavigation.allow),
      (GnusFrame.unknown, 'about:config', GnusNavigation.block),
      (GnusFrame.unknown, 'http://127.0.0.1:3001/', GnusNavigation.block),
      (GnusFrame.unknown, 'https://evil.example/', GnusNavigation.block),
      (GnusFrame.unknown, 'javascript:1', GnusNavigation.block),
      (GnusFrame.sub, 'https://evil.example/', GnusNavigation.allow),
      (GnusFrame.newWindow, '$dash/', GnusNavigation.external),
      (GnusFrame.newWindow, 'https://evil.example/', GnusNavigation.external),
      (GnusFrame.newWindow, 'javascript:alert(1)', GnusNavigation.block),
      (GnusFrame.newWindow, 'about:blank', GnusNavigation.block),
      (GnusFrame.newWindow, null, GnusNavigation.block),
    ];

    for (final (frame, url, expected) in table) {
      test('$frame $url is $expected', () {
        expect(
          gnusNavigation(
            url: url == null ? null : Uri.tryParse(url),
            frame: frame,
            allowed: allowed,
          ),
          expected,
        );
      });
    }

    test('a non-http URL is never allowed or opened outside the app', () {
      for (final frame in [
        GnusFrame.main,
        GnusFrame.unknown,
        GnusFrame.newWindow,
      ]) {
        for (final url in [
          'javascript:1',
          'file:///x',
          'data:,x',
          'ftp://a/',
        ]) {
          expect(
            gnusNavigation(url: Uri.parse(url), frame: frame, allowed: allowed),
            GnusNavigation.block,
            reason: '$frame $url',
          );
        }
      }
    });
  });

  group('gnusDashboardStart', () {
    final pinned = Uri.parse('${gnusDashboardOrigin(SgnsNet.staging)}/');
    final dev = Uri.parse('http://localhost:3000/');

    for (final (isDev, hosted, expected) in [
      (false, false, pinned),
      (false, true, pinned),
      (true, false, dev),
      (true, true, pinned),
    ]) {
      test('dev: $isDev hosted: $hosted starts on $expected', () {
        for (final net in SgnsNet.values) {
          final start = gnusDashboardStart(net, dev: isDev, hosted: hosted);

          expect(start, expected);
          expect(start.path, '/');
          expect(start.hasQuery, isFalse);
          expect(start.hasFragment, isFalse);
          expect(
            gnusAllowedOrigins(net, dev: isDev),
            contains(webOrigin('$start')),
          );
        }
      });
    }

    test('a dev origin that is not localhost falls back to the pinned one', () {
      expect(
        gnusDashboardStart(
          SgnsNet.staging,
          dev: true,
          devOrigin: 'http://evil.com',
        ),
        pinned,
      );
    });
  });

  group('gnusDashboardListed', () {
    test('a release build waits for a real pinned origin', () {
      final placeholder = SgnsNet.values.any(
        (net) => Uri.parse(gnusDashboardOrigin(net)).host.endsWith('.invalid'),
      );

      expect(gnusDashboardListed(dev: false), !placeholder);
    });

    test('a dev build always lists it', () {
      expect(gnusDashboardListed(dev: true), isTrue);
    });
  });
}
