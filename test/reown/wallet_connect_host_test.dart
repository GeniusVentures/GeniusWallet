import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/navigation/router.dart';
import 'package:genius_wallet/reown/wallet_connect_host.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:reown_walletkit/reown_walletkit.dart' hide Wallet;

import '../gnus_bridge/gnus_fakes.dart';
import 'fake_wallet_kit.dart';

const _otherAddress = '0x9999999999999999999999999999999999999999';

Future<void> _pumpApp(WidgetTester tester) => tester.pumpWidget(
  MaterialApp(
    navigatorKey: navigatorKey,
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: const Scaffold(body: SizedBox.shrink()),
  ),
);

WalletConnectHost _host(GnusHarness h, FakeWalletKit kit) => WalletConnectHost(
  geniusApi: h.api,
  walletDetails: h.walletDetails,
  transactions: TransactionsCubit(),
  handler: h.build(),
  signableChainIds: () => const [1, 8453],
  devBuild: false,
  walletKit: kit,
  init: () async {},
);

WalletDetailsState _state(Wallet? wallet) =>
    WalletDetailsState(selectedWallet: wallet, selectedNetwork: gnusTestAmoy);

void main() {
  group('a wallet that cannot sign', () {
    final cannotSign = <String, Wallet?>{
      'none selected': null,
      'tracking': gnusTestWallet.copyWith(walletType: WalletType.tracking),
      'sgnus': gnusTestWallet.copyWith(walletType: WalletType.sgnus),
    };

    for (final entry in cannotSign.entries) {
      for (final gnus in [false, true]) {
        testWidgets(
          '${entry.key} refuses ${gnus ? 'a gnus' : 'an ordinary'} proposal',
          (tester) async {
            final h = (await tester.runAsync(GnusHarness.create))!;
            final kit = FakeWalletKit();
            final host = _host(h, kit);
            h.walletDetails.push(_state(entry.value));
            await _pumpApp(tester);
            await host.start();

            kit.proposal.broadcast(
              proposalEvent(
                methods: gnus
                    ? const ['gnus_getAccounts']
                    : const ['eth_sendTransaction'],
              ),
            );
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 300));

            expect(kit.approvals, isEmpty);
            expect(
              kit.rejections.single.reason.code,
              Errors.getSdkError(Errors.UNSUPPORTED_ACCOUNTS).code,
            );
            expect(find.text('Allow'), findsNothing);
            expect(find.textContaining('cannot sign'), findsOneWidget);
            host.dispose();
            await tester.pumpAndSettle(const Duration(seconds: 10));
            await tester.runAsync(h.dispose);
          },
        );
      }
    }

    testWidgets('switching to a wallet that can sign is read at the next '
        'proposal', (tester) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      h.walletDetails.push(
        _state(gnusTestWallet.copyWith(walletType: WalletType.tracking)),
      );
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(proposalEvent(id: 1));
      await tester.pumpAndSettle(const Duration(seconds: 10));
      expect(kit.rejections, hasLength(1));

      h.walletDetails.push(
        _state(gnusTestWallet.copyWith(address: _otherAddress)),
      );
      kit.proposal.broadcast(proposalEvent(id: 2));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      final eip155 = kit.approvals.single.namespaces['eip155']!;
      expect(kit.approvals.single.id, 2);
      expect(eip155.accounts, everyElement(endsWith(_otherAddress)));
      host.dispose();
      await tester.runAsync(h.dispose);
    });

    testWidgets('a wallet switched to one that cannot sign while the drawer is '
        'open is not approved', (tester) async {
      final h = (await tester.runAsync(GnusHarness.create))!;
      final kit = FakeWalletKit();
      final host = _host(h, kit);
      await _pumpApp(tester);
      await host.start();

      kit.proposal.broadcast(proposalEvent());
      await tester.pumpAndSettle();
      h.walletDetails.push(
        _state(gnusTestWallet.copyWith(walletType: WalletType.tracking)),
      );
      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(kit.approvals, isEmpty);
      expect(kit.rejections, hasLength(1));
      host.dispose();
      await tester.runAsync(h.dispose);
    });
  });
}
