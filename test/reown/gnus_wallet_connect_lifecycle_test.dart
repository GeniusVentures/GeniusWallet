import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/reown/gnus_wallet_connect.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../gnus_bridge/gnus_fakes.dart';
import 'fake_wallet_kit.dart';

const _otherUrl = 'https://other.example';
final _origin = GnusOrigin.parse(GnusTransport.walletconnect, dashboardUrl);
final _other = GnusOrigin.parse(GnusTransport.walletconnect, _otherUrl);

const _allEvents = [
  'gnus_accountsChanged',
  'gnus_networkChanged',
  'gnus_jobUpdated',
];

const _chain1 = Network(
  name: 'Other',
  symbol: 'eth',
  nativeSymbol: 'ETH',
  chainId: 1,
  rpcUrl: 'https://rpc.invalid',
);

/// Logs what leaves the wallet, in order, and can hold either kind of send.
class _OrderedKit extends FakeWalletKit {
  final List<String> sent = [];
  Completer<void>? holdEmit;

  @override
  Future<void> respondSessionRequest({
    required String topic,
    required JsonRpcResponse response,
  }) async {
    await super.respondSessionRequest(topic: topic, response: response);
    sent.add('reply');
  }

  @override
  Future<void> emitSessionEvent({
    required String topic,
    required String chainId,
    required SessionEventParams event,
  }) async {
    await holdEmit?.future;
    await super.emitSessionEvent(topic: topic, chainId: chainId, event: event);
    sent.add('event');
  }
}

Map<String, Object?> _submitParams(String key) => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': key,
};

void main() {
  late GnusHarness h;
  late _OrderedKit kit;
  late void Function() stop;

  setUp(() async {
    h = await GnusHarness.create();
    kit = _OrderedKit()
      ..activeSessions['topic-1'] = sessionData(events: _allEvents);
    stop = () {};
  });

  tearDown(() async {
    stop();
    await h.dispose();
  });

  GnusRpcHandler attach({GnusConnect? connect, GnusConfirm? confirm}) {
    final handler = h.build(connect: connect, confirm: confirm);
    stop = handleGnusRequests(
      walletKit: kit,
      handler: handler,
      devBuild: false,
    );
    return handler;
  }

  Future<void> switchWallet() async {
    h.walletDetails.push(
      WalletDetailsState(
        selectedWallet: gnusTestWallet.copyWith(
          address: '0x1111111111111111111111111111111111111111',
        ),
        selectedNetwork: gnusTestAmoy,
      ),
    );
    await pumpEventQueue();
  }

  List<String> emitted([String? topic]) => [
    for (final e in kit.emits)
      if (topic == null || e.topic == topic) e.event.name,
  ];

  group('events reach the session that approved them', () {
    test('a wallet switch is one gnus_accountsChanged on eip155:80002 with '
        'the getAccounts payload', () async {
      await h.connections.connect(_origin, h.clock);
      final handler = attach();
      await pumpEventQueue();

      await switchWallet();

      expect(kit.emits, hasLength(1));
      expect(kit.emits.single.chainId, 'eip155:80002');
      expect(kit.emits.single.event.name, 'gnus_accountsChanged');
      expect(
        kit.emits.single.event.data,
        await handler.handle(_origin, GnusRpcMethod.getAccounts, null),
      );
    });

    test('a network switch is gnus_networkChanged', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();

      h.walletDetails.push(
        const WalletDetailsState(
          selectedWallet: gnusTestWallet,
          selectedNetwork: _chain1,
        ),
      );
      await pumpEventQueue();

      expect(emitted(), contains('gnus_networkChanged'));
    });

    test(
      'a session that approved one event gets no call for another',
      () async {
        kit.activeSessions['topic-1'] = sessionData(
          events: const ['gnus_accountsChanged'],
        );
        await h.connections.connect(_origin, h.clock);
        attach();
        await pumpEventQueue();

        h.walletDetails.push(
          const WalletDetailsState(
            selectedWallet: gnusTestWallet,
            selectedNetwork: _chain1,
          ),
        );
        await pumpEventQueue();

        expect(emitted(), isNotEmpty);
        expect(emitted().toSet(), {'gnus_accountsChanged'});
      },
    );

    test('an origin that is not connected gets nothing, and a later connect '
        'resumes without resubscribing', () async {
      attach();
      await pumpEventQueue();

      await switchWallet();
      expect(kit.emits, isEmpty);

      await h.connections.connect(_origin, h.clock);
      h.pushApp(AppState(selectedSDKAccount: '0x${'d' * 128}'));
      await pumpEventQueue();
      expect(emitted(), ['gnus_accountsChanged']);

      await h.connections.revoke(_origin);
      h.pushApp(AppState(selectedSDKAccount: gnusTestNode));
      await pumpEventQueue();
      expect(emitted(), hasLength(1));
    });

    test('a job update reaches only the session whose origin submitted '
        'it', () async {
      kit.activeSessions['topic-2'] = sessionData(
        topic: 'topic-2',
        url: _otherUrl,
        events: _allEvents,
      );
      await h.connections.connect(_origin, h.clock);
      await h.connections.connect(_other, h.clock);
      final handler = attach();
      await pumpEventQueue();

      await handler.handle(
        _origin,
        GnusRpcMethod.submitJob,
        _submitParams('k'),
      );
      await pumpEventQueue();

      expect(emitted('topic-1'), ['gnus_jobUpdated']);
      expect(emitted('topic-2'), isEmpty);
    });

    test('a session connected after the start forwards, and stops on '
        'delete', () async {
      kit.activeSessions.clear();
      await h.connections.connect(_origin, h.clock);
      attach();
      final session = sessionData(events: _allEvents);
      kit.activeSessions['topic-1'] = session;
      kit.connect.broadcast(SessionConnect(session));
      await pumpEventQueue();

      await switchWallet();
      expect(emitted(), hasLength(1));

      kit.activeSessions.clear();
      kit.delete.broadcast(SessionDelete('topic-1'));
      h.pushApp(AppState(selectedSDKAccount: '0x${'d' * 128}'));
      await pumpEventQueue();
      expect(emitted(), hasLength(1));
    });

    test('an expired session stops forwarding', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();

      kit.expire.broadcast(SessionExpire('topic-1'));
      await switchWallet();

      expect(kit.emits, isEmpty);
    });

    test('the disposer stops all forwarding', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();

      stop();
      await switchWallet();

      expect(kit.emits, isEmpty);
    });

    test('an emit that throws is dropped and the next event still goes '
        'out', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();
      kit.failEmits = 1;

      await switchWallet();
      h.pushApp(AppState(selectedSDKAccount: '0x${'d' * 128}'));
      await pumpEventQueue();

      expect(emitted(), ['gnus_accountsChanged']);
    });
  });

  group('one queue per topic', () {
    test('a reply in flight keeps the event queued behind it', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();
      kit.holdRespond = Completer<void>();

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();
      await switchWallet();
      expect(kit.emits, isEmpty);

      kit.holdRespond!.complete();
      await pumpEventQueue();
      expect(kit.sent, ['reply', 'event']);
    });

    test('an event in flight keeps the reply queued behind it', () async {
      await h.connections.connect(_origin, h.clock);
      attach();
      await pumpEventQueue();
      kit.holdEmit = Completer<void>();

      await switchWallet();
      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();
      expect(kit.responses, isEmpty);

      kit.holdEmit!.complete();
      await pumpEventQueue();
      expect(kit.sent, ['event', 'reply']);
    });
  });
}
