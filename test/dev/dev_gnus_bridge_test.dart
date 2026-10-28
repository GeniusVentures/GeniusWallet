import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dev/dev_gnus_bridge.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/dev/dev_tools_bubble.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

import '../gnus_bridge/gnus_fakes.dart';

void main() {
  group('devGnusOutcome', () {
    test('a call that answers is ok, whatever it returned', () async {
      expect(await devGnusOutcome(Future.value({'secret': 'body'})), 'ok');
    });

    test('an error is its code and reason', () async {
      expect(
        await devGnusOutcome(
          Future.error(
            const GnusRpcError(
              GnusRpcCode.busy,
              'Busy',
              data: {'reason': GnusRpcReason.confirmOpen},
            ),
          ),
        ),
        '-32005 confirm_open',
      );
      expect(
        await devGnusOutcome(
          Future.error(
            const GnusRpcError(GnusRpcCode.userRejected, 'User rejected'),
          ),
        ),
        '4001',
      );
    });
  });

  group('devGnusSubmit', () {
    tearDown(DevMockJob.instance.clear);

    test('with no JOB fixture armed it refuses and calls nothing', () async {
      final h = await GnusHarness.create();
      addTearDown(h.dispose);
      final handler = h.build();

      final text = await devGnusSubmit(handler);

      expect(text, kDevGnusNeedsFixture);
      expect(h.api.calls, isEmpty);
      expect(h.connects, isEmpty);
    });

    test(
      'a fixture disarmed while the confirm is open burns nothing',
      () async {
        DevMockJob.instance.arm(DevJobScenario.pricedOk);
        final h = await GnusHarness.create();
        addTearDown(h.dispose);
        await h.connections.connect(kDevGnusOrigin, h.clock);
        final handler = h.build(
          confirm:
              ({
                required origin,
                required cost,
                required gas,
                required payer,
                required nodeAccount,
                required network,
              }) async {
                DevMockJob.instance.clear();
                return true;
              },
        );

        final text = await devGnusSubmit(handler);

        expect(text, '${GnusRpcCode.internal} ${GnusRpcReason.missingData}');
        expect(h.api.count('burn'), 0);
      },
      skip: !JobSubmission.devToolsEnabled,
    );

    test(
      'an armed fixture is not enough outside a dev-tools build',
      () async {
        DevMockJob.instance.arm(DevJobScenario.pricedOk);
        final h = await GnusHarness.create();
        addTearDown(h.dispose);

        final text = await devGnusSubmit(h.build());

        expect(text, kDevGnusNeedsFixture);
        expect(h.api.calls, isEmpty);
      },
      skip: JobSubmission.devToolsEnabled,
    );
  });

  test('the dev origins cannot resolve and the account is 130 characters', () {
    expect(kDevGnusOrigin.value, endsWith('.invalid'));
    expect(kDevGnusOtherOrigin.value, endsWith('.invalid'));
    expect(kDevGnusOrigin, isNot(kDevGnusOtherOrigin));
    expect(kDevGnusEarningAccount, hasLength(130));
  });

  testWidgets('the GNUS BRIDGE section lists its five triggers', (
    tester,
  ) async {
    final panel = DevToolsBubblePanelState.instance;
    addTearDown(() {
      panel.position = null;
      panel.expanded = false;
      panel.gnusBridgeExpanded = false;
    });
    panel.gnusBridgeExpanded = true;
    panel.expanded = true;
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SizedBox.shrink(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Stack(children: [DevToolsBubble(router: router)]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GNUS BRIDGE'), findsOneWidget);
    for (final label in [
      'Connect',
      'Other site',
      'Submit',
      'Preview',
      'Sites',
    ]) {
      await tester.ensureVisible(find.text(label));
      expect(find.text(label), findsOneWidget, reason: label);
    }
  });
}
