import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/gnus_wallet_connect.dart';
import 'package:genius_wallet/reown/handle_dapp_requests.dart';
import 'package:genius_wallet/reown/wallet_connect_host.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../gnus_bridge/gnus_fakes.dart';
import 'fake_wallet_kit.dart';

final _origin = GnusOrigin.parse(GnusTransport.walletconnect, dashboardUrl);

Future<void> _pumpApp(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    navigatorKey: navigatorKey,
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: const Scaffold(body: SizedBox.shrink()),
  ),
);

WalletConnectHost _host(
  GnusHarness h,
  FakeWalletKit kit, {
  bool devBuild = false,
}) => WalletConnectHost(
  geniusApi: h.api,
  walletDetails: h.walletDetails,
  transactions: TransactionsCubit(),
  handler: h.build(),
  signableChainIds: () => const [1, 8453],
  devBuild: devBuild,
  walletKit: kit,
  init: () async {},
);

void main() {
  group('tracer', () {
    testWidgets('a verified proposal is approved with the gnus method and '
        'eip155:80002', (tester) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      expect(await host.start(), isTrue);

      kit.proposal.broadcast(proposalEvent());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      final eip155 = kit.approvals.single.namespaces['eip155']!;
      expect(eip155.methods, containsAll(['gnus_getAccounts']));
      expect(eip155.methods, contains('eth_sendTransaction'));
      expect(eip155.chains, contains('eip155:80002'));
      expect(eip155.events, contains('gnus_accountsChanged'));
      expect(eip155.accounts, contains('eip155:80002:$gnusTestWalletAddress'));
      host.dispose();
      await tester.runAsync(h.dispose);
    });

    testWidgets('a proposal with no gnus method is approved as before', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(
        proposalEvent(
          methods: const ['eth_sendTransaction'],
          events: const ['chainChanged'],
          validation: Validation.UNKNOWN,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      final eip155 = kit.approvals.single.namespaces['eip155']!;
      expect(eip155.chains, ['eip155:1', 'eip155:8453']);
      expect(eip155.methods, [
        'eth_sendTransaction',
        'personal_sign',
        'eth_signTypedData',
      ]);
      expect(eip155.events, ['chainChanged', 'accountsChanged']);
      host.dispose();
      await tester.runAsync(h.dispose);
    });

    test('a gnus_getAccounts request opens the connect seam once and is '
        'answered as a direct call would be', () async {
      final h = await GnusHarness.create();
      final handler = h.build();
      final kit = FakeWalletKit()..activeSessions['topic-1'] = sessionData();
      final stop = handleGnusRequests(
        walletKit: kit,
        handler: handler,
        devBuild: false,
      );

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();

      expect(h.connects, [_origin]);
      final direct = await handler.handle(_origin, 'gnus_getAccounts', null);
      expect(kit.responses.single.topic, 'topic-1');
      expect(kit.responses.single.response.id, 1);
      expect(kit.responses.single.response.result, direct);
      stop();
      await h.dispose();
    });

    testWidgets('the ordinary request handler neither answers nor shows a '
        'drawer for a gnus method', (tester) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit()..activeSessions['topic-1'] = sessionData();
      await _pumpApp(tester);
      final stop = handleDappRequests(
        walletKit: kit,
        geniusApi: h.api,
        walletDetailsCubit: h.walletDetails,
        transactionsCubit: TransactionsCubit(),
      );

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await tester.pumpAndSettle();

      expect(kit.responses, isEmpty);
      expect(find.text('Unknown request'), findsNothing);
      stop();
      await tester.runAsync(h.dispose);
    });
  });

  group('the Verify rule', () {
    VerifyContext? context(Validation? validation, {bool? isScam}) =>
        validation == null
        ? null
        : VerifyContext(
            origin: dashboardUrl,
            validation: validation,
            verifyUrl: 'https://verify.walletconnect.org',
            isScam: isScam,
          );

    test('VALID passes and nothing else does in a release build', () {
      GnusOrigin? origin(VerifyContext? c) =>
          gnusProposalOrigin(c, dashboardUrl, devBuild: false).origin;

      expect(origin(context(Validation.VALID)), _origin);
      expect(origin(context(Validation.UNKNOWN)), isNull);
      expect(origin(context(null)), isNull);
      expect(origin(context(Validation.INVALID)), isNull);
      expect(origin(context(Validation.SCAM)), isNull);
      expect(origin(context(Validation.VALID, isScam: true)), isNull);
    });

    test('a refusal names its cause', () {
      GnusRefusal? refusal(VerifyContext? c) =>
          gnusProposalOrigin(c, dashboardUrl, devBuild: false).refusal;

      expect(refusal(context(Validation.SCAM)), GnusRefusal.flagged);
      expect(refusal(context(Validation.INVALID)), GnusRefusal.flagged);
      expect(refusal(context(Validation.UNKNOWN)), GnusRefusal.unverified);
      expect(refusal(context(null)), GnusRefusal.unverified);
    });

    test('UNKNOWN passes in a dev build for a loopback host only', () {
      GnusOrigin? origin(String url, {bool dev = true}) => gnusProposalOrigin(
        context(Validation.UNKNOWN),
        url,
        devBuild: dev,
      ).origin;

      expect(origin('http://localhost:3000')?.value, 'http://localhost:3000');
      expect(origin('http://127.0.0.1:3000')?.value, 'http://127.0.0.1:3000');
      expect(origin('https://evil.example'), isNull);
      expect(origin('http://localhost.evil.example'), isNull);
      expect(origin('http://localhost:3000', dev: false), isNull);
    });

    test('a loopback host is refused in a release build even when VALID', () {
      expect(
        gnusProposalOrigin(
          context(Validation.VALID),
          'http://localhost:3000',
          devBuild: false,
        ).origin,
        isNull,
      );
    });

    test('a peer URL that is not an origin is refused', () {
      for (final url in ['null', '', 'ftp://dash.example', 'dash.example']) {
        expect(
          gnusProposalOrigin(
            context(Validation.VALID),
            url,
            devBuild: true,
          ).origin,
          isNull,
          reason: url,
        );
      }
    });

    testWidgets('a flagged page is refused with a reason and a toast', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(proposalEvent(validation: Validation.SCAM));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(kit.approvals, isEmpty);
      expect(kit.rejections.single.reason.message, contains('flagged'));
      expect(find.text('Allow'), findsNothing);
      expect(find.textContaining('flagged this site'), findsOneWidget);
      host.dispose();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await tester.runAsync(h.dispose);
    });

    testWidgets('an unverified page is refused in a release build', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(proposalEvent(validation: null));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(kit.approvals, isEmpty);
      expect(kit.rejections.single.reason.message, contains('verified'));
      expect(find.textContaining('could not be verified'), findsOneWidget);
      host.dispose();
      await tester.pumpAndSettle(const Duration(seconds: 10));
      await tester.runAsync(h.dispose);
    });

    for (final entry in {
      'http://localhost:3000': true,
      'http://127.0.0.1:3000': true,
      'https://evil.example': false,
    }.entries) {
      testWidgets('a dev build with an unknown ${entry.key} '
          '${entry.value ? 'asks' : 'refuses'}', (tester) async {
        final h = (await tester.runAsync(GnusHarness.create))!;
        final kit = FakeWalletKit();
        final host = _host(h, kit, devBuild: true);
        await _pumpApp(tester);
        await host.start();

        kit.proposal.broadcast(
          proposalEvent(url: entry.key, validation: Validation.UNKNOWN),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('Allow'), entry.value ? findsOneWidget : findsNothing);
        expect(kit.rejections.length, entry.value ? 0 : 1);
        host.dispose();
        await tester.pumpAndSettle(const Duration(seconds: 10));
        await tester.runAsync(h.dispose);
      });
    }
  });

  group('the approved namespace', () {
    testWidgets(
      'only implemented gnus methods and the requested gnus events are '
      'approved, and eip155:80002 is a chain once',
      (tester) async {
        final h = (await tester.runAsync(GnusHarness.create))!;
        final kit = FakeWalletKit();
        final host = WalletConnectHost(
          geniusApi: h.api,
          walletDetails: h.walletDetails,
          transactions: TransactionsCubit(),
          handler: h.build(),
          signableChainIds: () => const [1, 80002],
          devBuild: false,
          walletKit: kit,
          init: () async {},
        );
        await _pumpApp(tester);
        await host.start();

        kit.proposal.broadcast(
          proposalEvent(
            url: 'https://dash.example/some/path?x=1',
            methods: const ['gnus_getAccounts', 'gnus_getAddress', 'wat'],
            events: const ['gnus_jobUpdated', 'gnus_other', 'chainChanged'],
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('https://dash.example'), findsOneWidget);
        await tester.tap(find.text('Allow'));
        await tester.pumpAndSettle();

        final eip155 = kit.approvals.single.namespaces['eip155']!;
        expect(eip155.methods, [
          'eth_sendTransaction',
          'personal_sign',
          'eth_signTypedData',
          'gnus_getAccounts',
        ]);
        expect(eip155.events, [
          'chainChanged',
          'accountsChanged',
          'gnus_jobUpdated',
        ]);
        expect(eip155.chains, ['eip155:1', 'eip155:80002']);
        host.dispose();
        await tester.runAsync(h.dispose);
      },
    );

    testWidgets('a proposal for a retired gnus method is an ordinary dApp', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(
        proposalEvent(
          methods: const ['gnus_getAddress'],
          validation: Validation.UNKNOWN,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      final eip155 = kit.approvals.single.namespaces['eip155']!;
      expect(eip155.methods, isNot(contains('gnus_getAddress')));
      expect(eip155.chains, ['eip155:1', 'eip155:8453']);
      host.dispose();
      await tester.runAsync(h.dispose);
    });

    testWidgets('an approval the SDK refuses is followed by a rejection', (
      tester,
    ) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit()..failApprovals = 1;
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(proposalEvent());
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      expect(kit.approvals, isEmpty);
      expect(kit.rejections.single.id, 1);
      host.dispose();
      await tester.runAsync(h.dispose);
    });
  });

  group('a restored session', () {
    for (final url in ['http://localhost:3000', 'not a url']) {
      test('from $url is answered 4100 in a release build', () async {
        final h = await GnusHarness.create();
        final kit = FakeWalletKit()
          ..activeSessions['topic-1'] = sessionData(url: url);
        final stop = handleGnusRequests(
          walletKit: kit,
          handler: h.build(),
          devBuild: false,
        );

        kit.request.broadcast(gnusRequest('gnus_getAccounts'));
        await pumpEventQueue();

        expect(kit.responses.single.response.error?.code, 4100);
        expect(h.connects, isEmpty);
        stop();
        await h.dispose();
      });
    }
  });
}
