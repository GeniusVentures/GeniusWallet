import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/network.dart';
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

  group('sessions follow the selected wallet and network', () {
    const base = Network(
      name: 'Base',
      symbol: 'base',
      nativeSymbol: 'eth',
      chainId: 8453,
      rpcUrl: 'https://base.invalid',
    );
    final oldAddress = gnusTestWallet.address;

    late GnusHarness h;
    late FakeWalletKit kit;
    late WalletConnectHost host;

    setUp(() async {
      h = await GnusHarness.create();
      kit = FakeWalletKit()
        ..activeSessions['t1'] = sessionData(
          topic: 't1',
          chains: const ['eip155:1', 'eip155:80002'],
          methods: const ['eth_sendTransaction', 'gnus_getAccounts'],
          events: const ['chainChanged', 'accountsChanged'],
          address: oldAddress,
        )
        ..activeSessions['t2'] = sessionData(
          topic: 't2',
          chains: const ['eip155:8453'],
          methods: const ['eth_sendTransaction'],
          events: const ['chainChanged', 'accountsChanged'],
          address: oldAddress,
        );
      host = _host(h, kit);
      await host.start();
    });

    tearDown(() async {
      host.dispose();
      await h.dispose();
    });

    Future<void> push(Wallet? wallet, {Network network = gnusTestAmoy}) async {
      h.walletDetails.push(
        WalletDetailsState(selectedWallet: wallet, selectedNetwork: network),
      );
      await pumpEventQueue();
    }

    test('a switch updates the gnus session on its own chains, and tells an '
        'ordinary dApp only that it has no account', () async {
      final other = gnusTestWallet.copyWith(address: _otherAddress);

      await push(other);

      expect(kit.updates.map((u) => u.topic), ['t1']);
      final first = kit.updates.single.namespaces['eip155']!;
      expect(first.accounts, [
        'eip155:1:$_otherAddress',
        'eip155:80002:$_otherAddress',
      ]);
      expect(first.methods, ['eth_sendTransaction', 'gnus_getAccounts']);
      expect(first.events, ['chainChanged', 'accountsChanged']);
      expect(
        [for (final e in kit.emits) (e.topic, e.chainId, e.event.name)],
        [
          ('t1', 'eip155:1', 'accountsChanged'),
          ('t2', 'eip155:8453', 'accountsChanged'),
        ],
      );
      expect(kit.emits.map((e) => e.event.data), [
        [_otherAddress],
        <String>[],
      ]);
    });

    test('switching back to the wallet an ordinary dApp was given names it '
        'again', () async {
      await push(gnusTestWallet.copyWith(address: _otherAddress));
      await push(gnusTestWallet);

      expect(kit.updates.map((u) => u.topic), ['t1', 't1']);
      expect(
        [
          for (final e in kit.emits)
            if (e.topic == 't2') e.event.data,
        ],
        [
          <String>[],
          [oldAddress],
        ],
      );
    });

    test('a switch to a wallet that cannot sign leaves the account and sends '
        'none', () async {
      await push(gnusTestWallet.copyWith(walletType: WalletType.tracking));

      expect(kit.updates, isEmpty);
      expect(kit.emits.map((e) => e.event.data), [<String>[], <String>[]]);
      expect(kit.emits.map((e) => e.event.name).toSet(), {'accountsChanged'});
    });

    test(
      'a network switch tells only the session that approved the chain',
      () async {
        await push(gnusTestWallet, network: base);

        expect(
          [for (final e in kit.emits) (e.topic, e.chainId, e.event.name)],
          [('t2', 'eip155:8453', 'chainChanged')],
        );
        expect(kit.emits.single.event.data, 8453);
        expect(kit.updates, isEmpty);
      },
    );

    test('a change to neither account nor chain sends nothing', () async {
      h.walletDetails.push(
        const WalletDetailsState(
          selectedWallet: gnusTestWallet,
          selectedNetwork: gnusTestAmoy,
          selectedWalletBalance: '5',
        ),
      );
      await pumpEventQueue();

      expect(kit.updates, isEmpty);
      expect(kit.emits, isEmpty);
    });

    test(
      'one session that cannot be updated does not stop the other',
      () async {
        kit.failUpdateTopics.add('t1');

        await push(gnusTestWallet.copyWith(address: _otherAddress));

        expect(kit.updates, isEmpty);
        expect(kit.emits.map((e) => e.topic), ['t2']);
      },
    );

    test('two quick switches reach the page in order', () async {
      h.walletDetails.push(
        WalletDetailsState(
          selectedWallet: gnusTestWallet.copyWith(address: _otherAddress),
          selectedNetwork: gnusTestAmoy,
        ),
      );
      await push(gnusTestWallet);

      final addresses = [
        for (final e in kit.emits)
          if (e.topic == 't1') (e.event.data as List).single,
      ];
      expect(addresses, [_otherAddress, oldAddress]);
    });
  });
}
