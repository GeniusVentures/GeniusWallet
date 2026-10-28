import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

class _Home extends StatelessWidget {
  const _Home({this.listed = true});

  final bool listed;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: ComputePanel(
          view: viewForComputeState(ComputeState.processing),
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
  return MaterialApp.router(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    routerConfig: router,
  );
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
