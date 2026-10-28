import 'dart:async';
import 'dart:convert';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
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

/// A handler that fails in a way the contract never does.
class _ThrowingHandler implements GnusRpcHandler {
  @override
  Future<Object?> handle(GnusOrigin origin, String method, Object? params) =>
      Future.error(StateError('boom'));

  @override
  Stream<GnusEvent> eventsFor(GnusOrigin origin) => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Map<String, Object?> _submitParams(String key) => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': key,
};

Map<String, Object?> _errorOf(JsonRpcResponse response) {
  final error = response.error!;
  final parsed = jsonDecode(error.message!);
  return {
    'code': error.code,
    ...(parsed is Map ? parsed.cast<String, Object?>() : const {}),
  };
}

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

  group('a slow prompt stays answerable', () {
    test('every gnus request gets an expiry past the prompt timeout, before '
        'the handler runs', () async {
      final seen = <bool>[];
      attach(
        connect: ({required GnusOrigin origin}) async {
          seen.add(kit.core.expirer.expiries.containsKey('7'));
          return true;
        },
      );

      kit.request.broadcast(gnusRequest('gnus_getAccounts', id: 7));
      kit.request.broadcast(gnusRequest('eth_chainId', id: 8));
      await pumpEventQueue();

      final soonest = ReownCoreUtils.calculateExpiry(
        kGnusConfirmTimeout.inSeconds + 55,
      );
      expect(seen, [true]);
      expect(kit.core.expirer.expiries['7'], greaterThan(soonest));
      expect(kit.core.expirer.expiries.containsKey('8'), isFalse);
    });

    test('the first call from a new origin opens the prompt once; decline is '
        '4001', () async {
      var asked = 0;
      attach(
        connect: ({required GnusOrigin origin}) async {
          asked++;
          return false;
        },
      );

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();

      expect(asked, 1);
      expect(kit.responses.single.response.error?.code, 4001);
    });

    test('a prompt held past five minutes and then approved still answers '
        'once', () {
      fakeAsync((async) {
        final held = Completer<bool>();
        attach(connect: ({required GnusOrigin origin}) => held.future);

        kit.request.broadcast(gnusRequest('gnus_getAccounts'));
        async.elapse(const Duration(minutes: 6));
        expect(kit.responses, isEmpty);

        held.complete(true);
        async.flushMicrotasks();
        expect(kit.responses, hasLength(1));
        expect(kit.responses.single.response.error, isNull);
        expect(kit.responses.single.response.result, isNotNull);
      });
    });

    test('a second origin during a prompt is -32005 confirm_open', () async {
      kit.activeSessions['topic-2'] = sessionData(
        topic: 'topic-2',
        url: _otherUrl,
      );
      final held = Completer<bool>();
      attach(connect: ({required GnusOrigin origin}) => held.future);

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();
      kit.request.broadcast(
        gnusRequest('gnus_getAccounts', id: 2, topic: 'topic-2'),
      );
      await pumpEventQueue();

      final error = _errorOf(kit.responses.single.response);
      expect(error['code'], GnusRpcCode.busy);
      expect((error['data']! as Map)['reason'], GnusRpcReason.confirmOpen);
      held.complete(true);
    });
  });

  group('everything the wallet cannot serve gets its code', () {
    setUp(() async {
      await h.connections.connect(_origin, h.clock);
    });

    test('an SDK that is not initialized is 4900', () async {
      h.api.sdkInitialized = false;
      attach();

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();

      expect(kit.responses.single.response.error?.code, 4900);
    });

    test('a switch in progress is -32015', () async {
      h.app = AppState(
        selectedSDKAccount: gnusTestNode,
        switchingSDKAccount: '0x${'c' * 128}',
      );
      attach();

      kit.request.broadcast(gnusRequest('gnus_listJobs'));
      await pumpEventQueue();

      expect(kit.responses.single.response.error?.code, -32015);
    });

    test('a rejected confirm is 4001 and burns nothing', () async {
      attach(
        confirm:
            ({
              required origin,
              required cost,
              required gas,
              required payer,
              required nodeAccount,
              required network,
            }) async => false,
      );

      kit.request.broadcast(
        gnusRequest('gnus_submitJob', params: _submitParams('k')),
      );
      await pumpEventQueue();

      expect(kit.responses.single.response.error?.code, 4001);
      expect(h.api.count('burn'), 0);
    });

    test('a refused gate keeps its reason', () async {
      h.gate = const BridgeGate(BridgeGateState.viewOnly);
      attach();

      kit.request.broadcast(
        gnusRequest('gnus_submitJob', params: _submitParams('k')),
      );
      await pumpEventQueue();

      final error = _errorOf(kit.responses.single.response);
      expect(error['code'], GnusRpcCode.payerCannotSign);
      expect((error['data']! as Map)['reason'], GnusRpcReason.viewOnly);
    });

    test('a throw that is not a contract error is -32603', () async {
      stop = handleGnusRequests(
        walletKit: kit,
        handler: _ThrowingHandler(),
        devBuild: false,
      );

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();

      expect(kit.responses.single.response.error?.code, -32603);
      expect(kit.responses.single.response.error?.message, 'Internal error');
    });

    test('a reply that cannot be delivered is dropped and the submit '
        'stands', () async {
      attach();
      kit.failResponds = 1;

      kit.request.broadcast(
        gnusRequest('gnus_submitJob', params: _submitParams('k')),
      );
      await pumpEventQueue();

      expect(kit.responses, isEmpty);
      expect(h.api.count('burn'), 1);
      expect(h.store.byBurnHash(gnusTestBurnHash), isNotNull);
    });

    test('a session deleted while a prompt is open gets no answer and '
        'nothing throws', () async {
      await h.connections.revoke(_origin);
      final held = Completer<bool>();
      attach(connect: ({required GnusOrigin origin}) => held.future);

      kit.request.broadcast(gnusRequest('gnus_getAccounts'));
      await pumpEventQueue();
      kit.activeSessions.clear();
      kit.delete.broadcast(SessionDelete('topic-1'));
      held.complete(true);
      await pumpEventQueue();

      expect(kit.responses, isEmpty);
    });
  });
}
