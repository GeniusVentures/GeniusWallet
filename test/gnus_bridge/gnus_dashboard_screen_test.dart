import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_screen.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_contrast_test.dart' show themeFor;

class _Home extends StatelessWidget {
  const _Home({this.listed = true});

  final bool listed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ComputePanel(
          view: viewForComputeState(ComputeState.ready),
          balance: 1,
          fiatSubline: '',
          useMinions: false,
          onUnitChanged: (_) {},
          onLinkTap: (_) {},
          onNewJob: () {},
          onOpenDashboard: listed ? () => openGnusDashboard(context) : null,
        ),
      ),
    );
  }
}

Widget _app({
  required bool dev,
  required List<Uri> hosted,
  GnusDashboardHostBuilder? host,
  bool listed = true,
  GWAppearanceMode mode = GWAppearanceMode.dark,
}) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => _Home(listed: listed),
      ),
      GoRoute(
        path: '/gnus-dashboard',
        builder: (_, _) => GnusDashboardScreen(
          readNet: () async => SgnsNet.staging,
          dev: dev,
          hostBuilder:
              host ??
              (context, start) {
                hosted.add(start);
                return const Text('fake host');
              },
        ),
      ),
    ],
  );
  return MaterialApp.router(theme: themeFor(mode), routerConfig: router);
}

void main() {
  group('entry to host', () {
    for (final (dev, expected) in [
      (true, 'http://localhost:3000/'),
      (false, 'https://gnus-dashboard-staging.invalid/'),
    ]) {
      testWidgets('dev: $dev starts on $expected', (tester) async {
        final hosted = <Uri>[];
        await tester.pumpWidget(_app(dev: dev, hosted: hosted));

        await tester.tap(find.text('Jobs and earnings'));
        await tester.pumpAndSettle();

        expect(find.text('fake host'), findsOneWidget);
        expect(hosted, [Uri.parse(expected)]);
      });
    }
  });

  testWidgets('an unlisted entry shows no button', (tester) async {
    await tester.pumpWidget(_app(dev: false, hosted: [], listed: false));

    expect(find.text('Earning'), findsWidgets);
    expect(find.text('Jobs and earnings'), findsNothing);
  });

  group('without an in-app web view', () {
    Future<List<Uri>> pumpOpen(
      WidgetTester tester, {
      required Future<bool> Function(Uri) launch,
      Future<SgnsNet> Function()? readNet,
    }) async {
      final pushed = <Uri>[];
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, _) => Scaffold(
              body: TextButton(
                onPressed: () => openGnusDashboard(
                  context,
                  inApp: false,
                  launcher: (url, {mode = LaunchMode.platformDefault}) {
                    expect(mode, LaunchMode.externalApplication);
                    return launch(url);
                  },
                  readNet: readNet ?? () async => SgnsNet.staging,
                ),
                child: const Text('open'),
              ),
            ),
          ),
          GoRoute(
            path: '/gnus-dashboard',
            builder: (_, state) {
              pushed.add(state.uri);
              return const SizedBox.shrink();
            },
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          theme: themeFor(GWAppearanceMode.dark),
          routerConfig: router,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump();
      return pushed;
    }

    testWidgets('launches the start in the browser and pushes no route', (
      tester,
    ) async {
      final launched = <Uri>[];
      final pushed = await pumpOpen(
        tester,
        launch: (url) async {
          launched.add(url);
          return true;
        },
      );

      expect(launched, [gnusDashboardStart(SgnsNet.staging, dev: false)]);
      expect(pushed, isEmpty);
      expect(find.text("Couldn't open your browser."), findsNothing);
    });

    for (final (name, launch) in <(String, Future<bool> Function(Uri))>[
      ('returns false', (_) async => false),
      ('throws', (_) async => throw Exception('no browser')),
    ]) {
      testWidgets('a launch that $name shows a toast', (tester) async {
        await pumpOpen(tester, launch: launch);

        expect(find.text("Couldn't open your browser."), findsOneWidget);
        await tester.pumpAndSettle(const Duration(seconds: 10));
      });
    }

    testWidgets('an unreadable network shows the toast and launches nothing', (
      tester,
    ) async {
      var launched = 0;
      await pumpOpen(
        tester,
        launch: (_) async => ++launched > 0,
        readNet: () async => throw StateError('not ready'),
      );

      expect(launched, 0);
      expect(find.text("Couldn't open your browser."), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 10));
    });
  });

  group('the entry', () {
    testWidgets('is a button labelled Open jobs and earnings', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(dev: true, hosted: []));

      final node = tester.getSemantics(
        find.bySemanticsLabel(RegExp('Open jobs and earnings')),
      );

      expect(node.label, contains('Open jobs and earnings'));
      expect(node.flagsCollection.isButton, isTrue);
      semantics.dispose();
    });

    for (final mode in GWAppearanceMode.values) {
      testWidgets('meets contrast and tap-target guidelines in $mode', (
        tester,
      ) async {
        final semantics = tester.ensureSemantics();
        await tester.pumpWidget(_app(dev: true, hosted: [], mode: mode));

        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        semantics.dispose();
      });
    }

    testWidgets('does not overflow at 320 px and text scale 1.3', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 800),
            textScaler: TextScaler.linear(1.3),
          ),
          child: _app(dev: true, hosted: []),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text('Jobs and earnings'), findsOneWidget);
    });
  });

  group('the route', () {
    test('reads no URL, query or extra', () {
      final source = File('lib/navigation/router.dart').readAsLinesSync();
      final at = source.indexWhere((l) => l.contains("'/gnus-dashboard'"));
      final block = source
          .skip(at)
          .take(8)
          .where((l) => !l.trimLeft().startsWith('//'))
          .join('\n');

      expect(at, isNonNegative);
      expect(RegExp(r'state\.(extra|uri)').hasMatch(block), isFalse);
    });
  });

  group('gnusBridgeHostKind', () {
    for (final (os, webkit, kind) in [
      ('windows', false, GnusBridgeHostKind.windows),
      ('linux', true, GnusBridgeHostKind.linux),
      ('linux', false, GnusBridgeHostKind.browser),
      ('android', false, GnusBridgeHostKind.webview),
      ('ios', false, GnusBridgeHostKind.webview),
      ('macos', false, GnusBridgeHostKind.webview),
    ]) {
      test('$os with WebKitGTK $webkit is ${kind.name}', () {
        expect(gnusBridgeHostKind(os, linuxWebKit: webkit), kind);
      });
    }
  });
}
