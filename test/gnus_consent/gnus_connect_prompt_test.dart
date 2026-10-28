import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_consent/gnus_prompts.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

import '../gnus_bridge/gnus_fakes.dart';
import '../theme/theme_contrast_test.dart' show themeFor;

const _origin = 'https://dash.example';

Future<void> _pumpApp(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    navigatorKey: navigatorKey,
    theme: themeFor(GWAppearanceMode.dark),
    home: const SizedBox.shrink(),
  ),
);

void main() {
  testWidgets('the first call opens the drawer and Approve connects', (
    tester,
  ) async {
    final h = (await tester.runAsync(GnusHarness.create))!;
    final handler = h.build(connect: showGnusConnectPrompt);
    await _pumpApp(tester);

    final first = viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);
    await tester.pumpAndSettle();

    expect(find.text(_origin), findsWidgets);
    expect(find.text('Connect this site?'), findsOneWidget);
    expect(h.connections.isConnected(_origin), isFalse);

    await tester.tap(find.text('Approve'));
    await tester.pumpAndSettle();
    final reply = (await tester.runAsync(() => first))!;

    expect(reply['result'], isA<Map>());
    expect(h.connections.isConnected(_origin), isTrue);

    final second = viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);
    await tester.pumpAndSettle();
    expect(find.text('Connect this site?'), findsNothing);
    expect((await tester.runAsync(() => second))!['result'], isA<Map>());

    await tester.runAsync(h.dispose);
  });

  testWidgets('Reject answers 4001 and stores nothing', (tester) async {
    final h = (await tester.runAsync(GnusHarness.create))!;
    final handler = h.build(connect: showGnusConnectPrompt);
    await _pumpApp(tester);

    final call = viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    final reply = (await tester.runAsync(() => call))!;

    expect((reply['error']! as Map)['code'], GnusRpcCode.userRejected);
    expect(h.connections.isConnected(_origin), isFalse);
    expect(h.connections.all(), isEmpty);

    await tester.runAsync(h.dispose);
  });

  testWidgets('a long origin is shown whole', (tester) async {
    final long = 'https://${'a' * 100}.example';
    final h = (await tester.runAsync(GnusHarness.create))!;
    final handler = h.build(connect: showGnusConnectPrompt);
    await _pumpApp(tester);

    final call = viaJson(handler, long, GnusRpcMethod.getAccounts, null);
    await tester.pumpAndSettle();

    // The title may shorten it; the site line under it must not.
    final shown = tester.widgetList<Text>(find.text(long));
    expect(
      shown.where((t) => t.maxLines == null && t.overflow == null),
      isNotEmpty,
    );
    await tester.tap(find.text('Reject'));
    await tester.pumpAndSettle();
    await tester.runAsync(() => call);
    await tester.runAsync(h.dispose);
  });
}
