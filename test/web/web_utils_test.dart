import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlay/nav_destinations.dart';
import 'package:genius_wallet/web/web_utils.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher_platform_interface/link.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';

final _launched = <String>[];

class _RecordingLauncher extends UrlLauncherPlatform {
  @override
  final LinkDelegate? linkDelegate = null;

  @override
  Future<bool> canLaunch(String url) async => true;

  @override
  Future<bool> launch(
    String url, {
    required bool useSafariVC,
    required bool useWebView,
    required bool enableJavaScript,
    required bool enableDomStorage,
    required bool universalLinksOnly,
    required Map<String, String> headers,
    String? webOnlyWindowName,
  }) async {
    _launched.add(url);
    return true;
  }
}

/// Opens [url] through launchWebSite and reports whether the in-app page route
/// was pushed. The system browser path is read from [_launched].
Future<bool> _openedInApp(WidgetTester tester, String url) async {
  late BuildContext appContext;
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, _) {
          appContext = context;
          return const Scaffold(body: Text('home'));
        },
      ),
      GoRoute(
        path: '/web',
        builder: (_, _) => const Scaffold(body: Text('web page')),
      ),
    ],
  );
  await tester.pumpWidget(MaterialApp.router(routerConfig: router));
  launchWebSite(appContext, url);
  await tester.pumpAndSettle();
  return find.text('web page').evaluate().isNotEmpty;
}

void main() {
  group('opensInApp', () {
    test('linux without WebKitGTK uses the system browser', () {
      expect(opensInApp('linux', linuxWebKit: false), isFalse);
    });

    test('linux with WebKitGTK opens inside the app', () {
      expect(opensInApp('linux', linuxWebKit: true), isTrue);
    });

    test('other platforms always open inside the app', () {
      for (final os in ['windows', 'macos', 'android', 'ios']) {
        expect(opensInApp(os, linuxWebKit: false), isTrue, reason: os);
      }
    });
  });

  test('the Web tab is in the nav exactly when pages open in the app', () {
    final web = allDestinations.singleWhere((d) => d.path == '/web');
    expect(web.visible, Platform.isLinux ? linuxInAppWeb : isTrue);
  });

  group('launchWebSite', () {
    setUp(() {
      _launched.clear();
      UrlLauncherPlatform.instance = _RecordingLauncher();
    });

    testWidgets('opens an https link in the app or the system browser', (
      tester,
    ) async {
      const url = 'https://www.gnus.ai/tos.html';
      final inApp = await _openedInApp(tester, url);

      expect(inApp, inAppWeb);
      expect(_launched, inAppWeb ? isEmpty : [url]);
    });

    for (final url in [
      'http://www.gnus.ai/tos.html',
      'file:///etc/passwd',
      'javascript:alert(1)',
      'not a url',
      '',
    ]) {
      testWidgets('ignores "$url": no page, no system browser', (tester) async {
        final inApp = await _openedInApp(tester, url);

        expect(inApp, isFalse);
        expect(_launched, isEmpty);
      });
    }
  });
}
