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
}
