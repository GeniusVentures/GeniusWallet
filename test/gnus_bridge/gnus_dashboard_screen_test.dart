import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dev/dev_gnus_bridge.dart' show kDevGnusHosted;
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

/// A host that reports its creation and lets a test fire each callback.
class _FakeHost extends StatefulWidget {
  const _FakeHost({
    required this.start,
    required this.created,
    required this.onLoaded,
    required this.onFailed,
    required this.onNoBridge,
    required this.autoLoad,
  });

  final Uri start;
  final List<Uri> created;
  final VoidCallback onLoaded;
  final VoidCallback onFailed;
  final VoidCallback onNoBridge;
  final bool autoLoad;

  @override
  State<_FakeHost> createState() => _FakeHostState();
}

class _FakeHostState extends State<_FakeHost> {
  @override
  void initState() {
    super.initState();
    widget.created.add(widget.start);
    if (widget.autoLoad) {
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onLoaded());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('fake host'),
        TextButton(onPressed: widget.onLoaded, child: const Text('finish')),
        TextButton(onPressed: widget.onFailed, child: const Text('error')),
        TextButton(
          onPressed: widget.onNoBridge,
          child: const Text('no bridge'),
        ),
      ],
    );
  }
}

Widget _app({
  required bool dev,
  required List<Uri> hosted,
  bool listed = true,
  bool autoLoad = true,
  GWAppearanceMode mode = GWAppearanceMode.dark,
  GnusBrowserLauncher launcher = launchUrl,
  GnusBridgeHostKind hostKind = GnusBridgeHostKind.webview,
  bool blockPop = false,
  String initialLocation = '/',
}) {
  final router = GoRouter(
    initialLocation: initialLocation,
    observers: [GlobalSwapFabHost.popupRoutes],
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const Scaffold(body: Text('wallet home')),
      ),
      GoRoute(
        path: '/',
        builder: (_, _) => _Home(listed: listed),
      ),
      GoRoute(
        path: '/gnus-dashboard',
        builder: (_, _) => PopScope(
          canPop: !blockPop,
          child: GnusDashboardScreen(
            readNet: () async => SgnsNet.staging,
            dev: dev,
            launcher: launcher,
            hostKind: hostKind,
            hostBuilder:
                (
                  context,
                  start, {
                  required onLoaded,
                  required onFailed,
                  required onNoBridge,
                }) => _FakeHost(
                  start: start,
                  created: hosted,
                  autoLoad: autoLoad,
                  onLoaded: onLoaded,
                  onFailed: onFailed,
                  onNoBridge: onNoBridge,
                ),
          ),
        ),
      ),
    ],
  );
  return MaterialApp.router(theme: themeFor(mode), routerConfig: router);
}

/// Opens the screen from the home entry. The loading bar animates forever, so
/// this pumps instead of settling.
Future<void> _openScreen(WidgetTester tester) async {
  await tester.tap(find.text('Jobs and earnings'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  await tester.pump();
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

        await _openScreen(tester);

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

  group('states', () {
    Finder loading() => find.bySemanticsLabel('Loading jobs and earnings');
    const failedTitle = "Jobs and earnings didn't load";

    testWidgets('a loading bar shows until the first page finishes', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(dev: true, hosted: [], autoLoad: false));
      await _openScreen(tester);

      expect(loading(), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(
        tester.getSemantics(loading()).flagsCollection.isLiveRegion,
        isTrue,
      );

      await tester.tap(find.text('finish'));
      await tester.pump();

      expect(loading(), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
      semantics.dispose();
    });

    testWidgets('a main-frame error replaces the page with Try again', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(dev: true, hosted: [], autoLoad: false));
      await _openScreen(tester);

      await tester.tap(find.text('error'));
      await tester.pump();

      expect(find.text('fake host'), findsNothing);
      expect(find.text(failedTitle), findsOneWidget);
      expect(
        find.text('Check your connection, then try again.'),
        findsOneWidget,
      );
      expect(find.text('Try again'), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);
      expect(loading(), findsNothing);
      expect(
        tester
            .getSemantics(find.text(failedTitle))
            .flagsCollection
            .isLiveRegion,
        isTrue,
      );
      semantics.dispose();
    });

    testWidgets('Try again builds a fresh host on the same start', (
      tester,
    ) async {
      final hosted = <Uri>[];
      await tester.pumpWidget(_app(dev: true, hosted: hosted, autoLoad: false));
      await _openScreen(tester);
      await tester.tap(find.text('error'));
      await tester.pump();

      await tester.tap(find.text('Try again'));
      await tester.pump();

      expect(hosted, hasLength(2));
      expect(hosted.first, hosted.last);
      expect(find.text('fake host'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    testWidgets('a network that cannot be read fails the screen', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => GnusDashboardScreen(
              readNet: () async => throw StateError('not ready'),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(
          theme: themeFor(GWAppearanceMode.dark),
          routerConfig: router,
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text(failedTitle), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('no bridge shows no page, only the browser notice', (
      tester,
    ) async {
      final launched = <Uri>[];
      await tester.pumpWidget(
        _app(
          dev: false,
          hosted: [],
          autoLoad: false,
          launcher: (url, {mode = LaunchMode.platformDefault}) async {
            launched.add(url);
            return true;
          },
        ),
      );
      await _openScreen(tester);

      await tester.tap(find.text('no bridge'));
      await tester.pump();

      expect(find.text('fake host'), findsNothing);
      expect(
        find.text('Open jobs and earnings in your browser'),
        findsOneWidget,
      );
      expect(
        find.text("This device's web view can't connect to the wallet safely."),
        findsOneWidget,
      );
      expect(loading(), findsNothing);

      await tester.tap(find.text('Open in browser'));
      await tester.pump();

      expect(launched, [Uri.parse('https://gnus-dashboard-staging.invalid/')]);
    });
  });

  group('chrome', () {
    testWidgets('Close leaves at once even when the route blocks popping', (
      tester,
    ) async {
      await tester.pumpWidget(_app(dev: true, hosted: [], blockPop: true));
      await _openScreen(tester);

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('fake host'), findsNothing);
      expect(find.text('Jobs and earnings'), findsOneWidget);
    });

    testWidgets('Close with nothing to pop goes to the wallet home', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(dev: true, hosted: [], initialLocation: '/gnus-dashboard'),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(find.byTooltip('Close'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('wallet home'), findsOneWidget);
    });

    testWidgets('Reload builds a fresh host and shows the bar again', (
      tester,
    ) async {
      final hosted = <Uri>[];
      await tester.pumpWidget(_app(dev: true, hosted: hosted));
      await _openScreen(tester);
      expect(find.byType(LinearProgressIndicator), findsNothing);

      await tester.tap(find.byTooltip('Reload'));
      await tester.pump();

      expect(hosted, hasLength(2));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });

    for (final (kind, hidden) in [
      (GnusBridgeHostKind.linux, true),
      (GnusBridgeHostKind.windows, false),
      (GnusBridgeHostKind.webview, false),
    ]) {
      testWidgets('a root dialog hides the ${kind.name} page: $hidden', (
        tester,
      ) async {
        await tester.pumpWidget(_app(dev: true, hosted: [], hostKind: kind));
        await _openScreen(tester);
        final context = tester.element(find.byType(GnusDashboardScreen));

        final closed = showDialog<void>(
          context: context,
          useRootNavigator: true,
          builder: (_) => const AlertDialog(title: Text('Confirm')),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('fake host'), hidden ? findsNothing : findsOneWidget);

        Navigator.of(context, rootNavigator: true).pop();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        await closed;

        expect(find.text('fake host'), findsOneWidget);
      });
    }

    testWidgets('has the screen-reader labels', (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(_app(dev: true, hosted: []));
      await _openScreen(tester);

      expect(find.bySemanticsLabel('Close jobs and earnings'), findsOneWidget);
      expect(find.bySemanticsLabel('Reload jobs and earnings'), findsOneWidget);
      expect(
        find.bySemanticsLabel(RegExp('Jobs and earnings page, localhost')),
        findsOneWidget,
      );
      final title = find.descendant(
        of: find.byType(GnusDashboardScreen),
        matching: find.text('Jobs and earnings'),
      );
      expect(tester.getSemantics(title).flagsCollection.isHeader, isTrue);
      semantics.dispose();
    });

    for (final mode in GWAppearanceMode.values) {
      testWidgets(
        'meets the guidelines while loading, loaded and failed in $mode',
        (tester) async {
          final semantics = tester.ensureSemantics();
          await tester.pumpWidget(
            _app(dev: true, hosted: [], autoLoad: false, mode: mode),
          );
          await _openScreen(tester);

          Future<void> check() async {
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
          }

          await check();
          await tester.tap(find.text('finish'));
          await tester.pump();
          await check();
          await tester.tap(find.text('error'));
          await tester.pump();
          await check();
          semantics.dispose();
        },
      );
    }
  });

  group('the Hosted switch', () {
    tearDown(() => kDevGnusHosted.value = false);

    for (final (dev, hosted, expected) in [
      (true, false, 'http://localhost:3000/'),
      (true, true, 'https://gnus-dashboard-staging.invalid/'),
      (false, true, 'https://gnus-dashboard-staging.invalid/'),
      (false, false, 'https://gnus-dashboard-staging.invalid/'),
    ]) {
      testWidgets('dev: $dev switch: $hosted starts on $expected', (
        tester,
      ) async {
        kDevGnusHosted.value = hosted;
        final created = <Uri>[];
        await tester.pumpWidget(_app(dev: dev, hosted: created));

        await _openScreen(tester);

        expect(created, [Uri.parse(expected)]);
      });
    }
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
