import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_consent/gnus_prompts.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';

import '../gnus_bridge/gnus_fakes.dart';
import '../theme/theme_contrast_test.dart' show themeFor;

final _origin = webOrigin('https://${'a' * 105}.example');
const _cost = '1234000000000000000000';
final _payer = '0x${'1' * 40}';
final _node = '0xAA${'b' * 126}';
const _gas = {'gasPriceGwei': '1.00', 'symbol': 'POL'};

Future<void> _pumpApp(
  WidgetTester tester, {
  GWAppearanceMode mode = GWAppearanceMode.dark,
}) async {
  tester.view.physicalSize = const Size(1280, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: themeFor(mode),
      home: const SizedBox.shrink(),
    ),
  );
}

Future<bool> _spend({Map<String, String>? gas = _gas}) => showGnusSpendConfirm(
  origin: _origin,
  cost: _cost,
  gas: gas,
  payer: _payer,
  nodeAccount: _node,
);

void main() {
  late List<String> copied;

  setUp(() {
    copied = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('spend confirm', () {
    testWidgets('shows the five facts and copies each address whole', (
      tester,
    ) async {
      await _pumpApp(tester);

      final answer = _spend();
      await tester.pumpAndSettle();

      expect(find.text('Pay for a processing job'), findsOneWidget);
      expect(find.text(_origin.value), findsWidgets);
      expect(find.text('1234 GNUS'), findsOneWidget);
      expect(find.text('1.00 Gwei (POL)'), findsOneWidget);
      expect(find.text('Paying wallet'), findsOneWidget);
      expect(find.text('Earning account'), findsOneWidget);

      await tester.ensureVisible(find.text('Paying wallet'));
      await tester.tap(find.text('Paying wallet'));
      await tester.pump();
      await tester.ensureVisible(find.text('Earning account'));
      await tester.tap(find.text('Earning account'));
      await tester.pump(const Duration(seconds: 5));

      expect(copied, [_payer, _node]);
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);
    });

    testWidgets('no gas estimate reads Not available', (tester) async {
      await _pumpApp(tester);

      final answer = _spend(gas: null);
      await tester.pumpAndSettle();

      expect(find.text('Not available'), findsOneWidget);
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      await answer;
    });

    testWidgets('only Approve answers true', (tester) async {
      await _pumpApp(tester);

      var answer = _spend();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(await answer, isTrue);

      answer = _spend();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);

      answer = _spend();
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);
      expect(find.text('Approve'), findsNothing);

      answer = _spend();
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(await answer, isFalse);
      expect(find.text('Approve'), findsNothing);
    });

    testWidgets('a cost that does not parse shows nothing and declines', (
      tester,
    ) async {
      await _pumpApp(tester);

      for (final bad in ['abc', '', '-5', '1.5']) {
        final answer = await showGnusSpendConfirm(
          origin: _origin,
          cost: bad,
          gas: _gas,
          payer: _payer,
          nodeAccount: _node,
        );
        expect(answer, isFalse, reason: bad);
        expect(find.text('Approve'), findsNothing);
      }
    });
  });

  group('each drawer answers for itself', () {
    testWidgets('Approve under a newer route resolves neither of them', (
      tester,
    ) async {
      await _pumpApp(tester);
      final answer = _spend();
      var settled = false;
      unawaited(answer.then((_) => settled = true));
      await tester.pumpAndSettle();
      final above = navigatorKey.currentState!.push(
        MaterialPageRoute<bool>(builder: (_) => const Text('above')),
      );
      await tester.pumpAndSettle();

      // Flutter cancels a held finger on push, so this calls the covered
      // button directly, as any other activation reaching it would.
      tester
          .widget<GWButton>(
            find.widgetWithText(GWButton, 'Approve', skipOffstage: false),
          )
          .onPressed!();
      await tester.pumpAndSettle();

      expect(find.text('above'), findsOneWidget);
      expect(settled, isFalse);

      navigatorKey.currentState!.pop(false);
      await tester.pumpAndSettle();
      expect(await above, isFalse);
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      expect(await answer, isFalse);
    });
  });

  group('Approve arms late', () {
    testWidgets('a tap as the drawer opens does nothing', (tester) async {
      await _pumpApp(tester);
      final answer = _spend();
      var settled = false;
      unawaited(answer.then((_) => settled = true));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Approve'), warnIfMissed: false);
      await tester.pump();
      expect(settled, isFalse);

      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      expect(await answer, isTrue);
    });
  });

  group('no navigator', () {
    testWidgets('both prompts decline without throwing', (tester) async {
      expect(await _spend(), isFalse);
      expect(await showGnusConnectPrompt(origin: _origin), isFalse);
    });
  });

  group('self expiry', () {
    testWidgets('the spend drawer closes itself at the handler timeout', (
      tester,
    ) async {
      await _pumpApp(tester);

      final answer = _spend();
      await tester.pumpAndSettle();
      expect(find.text('Approve'), findsOneWidget);

      await tester.pump(kGnusConfirmTimeout);
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsNothing);
      expect(await answer, isFalse);
    });

    testWidgets('the connect drawer closes itself at the handler timeout', (
      tester,
    ) async {
      await _pumpApp(tester);

      final answer = showGnusConnectPrompt(origin: _origin);
      await tester.pumpAndSettle();
      expect(find.text('Approve'), findsOneWidget);

      await tester.pump(kGnusConfirmTimeout);
      await tester.pumpAndSettle();

      expect(find.text('Approve'), findsNothing);
      expect(await answer, isFalse);
    });

    testWidgets('it closes under a route that was pushed on top', (
      tester,
    ) async {
      await _pumpApp(tester);

      final answer = _spend();
      await tester.pumpAndSettle();
      final above = navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const Text('above')),
      );
      await tester.pumpAndSettle();

      await tester.pump(kGnusConfirmTimeout);
      await tester.pumpAndSettle();

      expect(await answer, isFalse);
      expect(find.text('above'), findsOneWidget);
      navigatorKey.currentState!.pop();
      await tester.pumpAndSettle();
      await above;
    });
  });

  group('through the handler', () {
    final origin = webOrigin('https://dash.example');
    final params = {
      'job': {
        'inputs': ['a'],
      },
      'idempotencyKey': 'key-1',
    };

    testWidgets('Reject answers 4001 with no burn and no intent', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final handler = h.build(confirm: showGnusSpendConfirm);
      await _pumpApp(tester);

      final call = viaJson(handler, origin, GnusRpcMethod.submitJob, params);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text(origin.value), findsWidgets);
      expect(find.text('1234 GNUS'), findsOneWidget);
      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();
      final reply = (await tester.runAsync(() => call))!;

      expect((reply['error']! as Map)['code'], GnusRpcCode.userRejected);
      expect(h.api.count('burn'), 0);
      expect(h.store.intentFor(origin.value, 'key-1'), isNull);
      await tester.runAsync(h.dispose);
    });

    testWidgets('Approve submits once', (tester) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final handler = h.build(confirm: showGnusSpendConfirm);
      await _pumpApp(tester);

      final call = viaJson(handler, origin, GnusRpcMethod.submitJob, params);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();
      final reply = (await tester.runAsync(() => call))!;

      expect((reply['result']! as Map)['status'], 'submitted');
      expect(h.api.count('burn'), 1);
      await tester.runAsync(h.dispose);
    });
  });

  group('contrast', () {
    for (final mode in GWAppearanceMode.values) {
      testWidgets('both prompts meet text contrast in $mode', (tester) async {
        final semantics = tester.ensureSemantics();
        await _pumpApp(tester, mode: mode);

        var answer = showGnusConnectPrompt(origin: _origin);
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.tap(find.text('Reject'));
        await tester.pumpAndSettle();
        await answer;

        answer = _spend();
        await tester.pumpAndSettle();
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        await tester.tap(find.text('Reject'));
        await tester.pumpAndSettle();
        await answer;
        semantics.dispose();
      });
    }
  });
}
