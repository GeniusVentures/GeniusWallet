import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import 'gnus_fakes.dart';

final _origin = webOrigin('https://dash.example');

final _node = gnusTestNode.toLowerCase();
final _otherNode = '0x${'d' * 128}';
final _mainNode = '0x${'b' * 128}';

Map<String, Object?> _submitParams() => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': 'key-1',
};

void main() {
  final harnesses = <GnusHarness>[];

  Future<GnusHarness> harness() async {
    final h = await GnusHarness.create();
    harnesses.add(h);
    return h;
  }

  tearDown(() async {
    for (final h in harnesses) {
      await h.dispose();
    }
    harnesses.clear();
  });

  /// A handler already past its baseline, and the events it emits from here.
  Future<(GnusRpcHandler, List<GnusEvent>)> started(GnusHarness h) async {
    final handler = h.build();
    final events = <GnusEvent>[];
    handler.events.listen(events.add);
    await pumpEventQueue();
    return (handler, events);
  }

  Future<Object?> freshAccounts(GnusRpcHandler handler) =>
      handler.handle(_origin, GnusRpcMethod.getAccounts, null);

  List<GnusEvent> named(List<GnusEvent> events, String name) => [
    for (final event in events)
      if (event.name == name) event,
  ];

  test('constructing the handler emits nothing', () async {
    final h = await harness();

    final (_, events) = await started(h);

    expect(events, isEmpty);
  });

  test('a new selected wallet fires one accountsChanged', () async {
    final h = await harness();
    final (handler, events) = await started(h);

    h.walletDetails.push(
      WalletDetailsState(
        selectedWallet: gnusTestWallet.copyWith(
          address: '0x1111111111111111111111111111111111111111',
        ),
        selectedNetwork: gnusTestAmoy,
      ),
    );
    await pumpEventQueue();

    expect(events, hasLength(1));
    expect(events.single.name, GnusRpcEventName.accountsChanged);
    expect(events.single.payload, await freshAccounts(handler));
  });

  test('a new SDK account fires one accountsChanged', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.pushApp(AppState(selectedSDKAccount: _otherNode));
    await pumpEventQueue();

    expect(events, hasLength(1));
    expect(events.single.name, GnusRpcEventName.accountsChanged);
    expect((events.single.payload['node']! as Map)['sdkAddress'], _otherNode);
  });

  test('a link added for the node fires one accountsChanged', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.pushApp(
      AppState(
        selectedSDKAccount: gnusTestNode,
        sdkAccountLinks: {
          _node: (
            walletAddress: gnusTestWalletAddress,
            walletName: 'Test Wallet',
          ),
        },
      ),
    );
    await pumpEventQueue();

    expect(events, hasLength(1));
    expect(
      (events.single.payload['node']! as Map)['linkedEvm'],
      gnusTestWalletAddress.toLowerCase(),
    );
  });

  test('a switch starting and ending fires twice', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.pushApp(
      AppState(
        selectedSDKAccount: gnusTestNode,
        switchingSDKAccount: _otherNode,
      ),
    );
    await pumpEventQueue();
    h.pushApp(AppState(selectedSDKAccount: gnusTestNode));
    await pumpEventQueue();

    expect(
      [for (final e in events) e.name],
      [GnusRpcEventName.accountsChanged, GnusRpcEventName.accountsChanged],
    );
    expect([for (final e in events) e.payload['switching']], [true, false]);
  });

  test('a registrations change fires accountsChanged with the role', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.registrations = {
      _mainNode: [gnusTestNode],
    };
    h.registrationChanges.add(null);
    await pumpEventQueue();

    expect(events, hasLength(1));
    final node = events.single.payload['node']! as Map;
    expect(node['role'], 'child');
    expect(node['main'], _mainNode);
  });

  test('a registrations change that changes nothing fires nothing', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.registrationChanges.add(null);
    await pumpEventQueue();

    expect(events, isEmpty);
  });

  test('a new chain fires networkChanged and accountsChanged', () async {
    final h = await harness();
    final (_, events) = await started(h);

    h.walletDetails.push(
      const WalletDetailsState(
        selectedWallet: gnusTestWallet,
        selectedNetwork: Network(
          name: 'Other',
          symbol: 'eth',
          nativeSymbol: 'ETH',
          chainId: 1,
          rpcUrl: 'https://rpc.invalid',
        ),
      ),
    );
    await pumpEventQueue();

    expect(named(events, GnusRpcEventName.networkChanged), hasLength(1));
    expect(named(events, GnusRpcEventName.networkChanged).single.payload, {
      'sdk': 'staging',
      'evmChainId': 1,
    });
    expect(named(events, GnusRpcEventName.accountsChanged), hasLength(1));
    expect(events, hasLength(2));
  });

  test('a processing tick fires nothing and reads no registrations', () async {
    final h = await harness();
    final (_, events) = await started(h);
    final readsBefore = h.registrationReads;

    for (var tick = 0; tick < 3; tick++) {
      h.pushApp(
        AppState(
          selectedSDKAccount: gnusTestNode,
          isProcessing: tick.isEven,
          processingPercentage: tick / 10,
        ),
      );
      await pumpEventQueue();
    }

    expect(events, isEmpty);
    expect(h.registrationReads, readsBefore);
  });

  test('the same state pushed twice fires once', () async {
    final h = await harness();
    final (_, events) = await started(h);
    final next = AppState(selectedSDKAccount: _otherNode);

    h.pushApp(next);
    await pumpEventQueue();
    h.pushApp(next);
    await pumpEventQueue();

    expect(events, hasLength(1));
  });

  test('a submit announces the status change once', () async {
    final h = await harness();
    final (handler, events) = await started(h);

    await handler.handle(_origin, GnusRpcMethod.submitJob, _submitParams());
    await pumpEventQueue();

    final record = h.store.byBurnHash(gnusTestBurnHash)!;
    final updates = named(events, GnusRpcEventName.jobUpdated);
    expect(updates, hasLength(1));
    expect(updates.single.payload, record.toContract());
    expect(updates.single.payload['status'], 'submitted');
    expect(events, hasLength(1));
  });

  test('a submit whose Process fails announces nothing', () async {
    final h = await harness();
    h.api.processResponse =
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED;
    final (handler, events) = await started(h);

    await handler.handle(_origin, GnusRpcMethod.submitJob, _submitParams());
    await pumpEventQueue();

    expect(named(events, GnusRpcEventName.jobUpdated), isEmpty);
  });

  test('after dispose nothing fires and a second dispose is a no-op', () async {
    final h = await harness();
    final (handler, events) = await started(h);

    await handler.dispose();
    h.pushApp(AppState(selectedSDKAccount: _otherNode));
    h.registrationChanges.add(null);
    await pumpEventQueue();
    await handler.dispose();

    expect(events, isEmpty);
  });

  group('eventsFor', () {
    final stranger = webOrigin('https://stranger.example');
    final neighbour = webOrigin('https://neighbour.example');

    Future<void> change(GnusHarness h) async {
      h.pushApp(AppState(selectedSDKAccount: _otherNode));
      h.walletDetails.push(
        const WalletDetailsState(
          selectedWallet: gnusTestWallet,
          selectedNetwork: Network(
            name: 'Other',
            symbol: 'eth',
            nativeSymbol: 'ETH',
            chainId: 1,
            rpcUrl: 'https://rpc.invalid',
          ),
        ),
      );
      await pumpEventQueue();
    }

    test(
      'an unconnected origin gets nothing, a connected one gets all',
      () async {
        final h = await harness();
        await h.connections.connect(_origin, h.clock);
        final handler = h.build();
        final connected = <GnusEvent>[];
        final unconnected = <GnusEvent>[];
        handler.eventsFor(_origin).listen(connected.add);
        handler.eventsFor(stranger).listen(unconnected.add);
        await pumpEventQueue();

        await change(h);
        h.pushApp(AppState(selectedSDKAccount: gnusTestNode));
        await handler.handle(_origin, GnusRpcMethod.submitJob, _submitParams());
        await pumpEventQueue();

        expect(
          connected.map((e) => e.name).toSet(),
          containsAll([
            GnusRpcEventName.accountsChanged,
            GnusRpcEventName.networkChanged,
            GnusRpcEventName.jobUpdated,
          ]),
        );
        expect(unconnected, isEmpty);
      },
    );

    test('a job update reaches only the origin that submitted it', () async {
      final h = await harness();
      await h.connections.connect(_origin, h.clock);
      await h.connections.connect(neighbour, h.clock);
      final handler = h.build();
      final own = <GnusEvent>[];
      final other = <GnusEvent>[];
      handler.eventsFor(_origin).listen(own.add);
      handler.eventsFor(neighbour).listen(other.add);
      await pumpEventQueue();

      await handler.handle(_origin, GnusRpcMethod.submitJob, _submitParams());
      await pumpEventQueue();

      expect(named(own, GnusRpcEventName.jobUpdated), hasLength(1));
      expect(named(other, GnusRpcEventName.jobUpdated), isEmpty);
    });

    test('a revoke stops delivery and a reconnect resumes it', () async {
      final h = await harness();
      await h.connections.connect(_origin, h.clock);
      final handler = h.build();
      final events = <GnusEvent>[];
      handler.eventsFor(_origin).listen(events.add);
      await pumpEventQueue();

      h.pushApp(AppState(selectedSDKAccount: _otherNode));
      await pumpEventQueue();
      expect(events, hasLength(1));

      await h.connections.revoke(_origin);
      h.pushApp(AppState(selectedSDKAccount: _mainNode));
      await pumpEventQueue();
      expect(events, hasLength(1));

      await h.connections.connect(_origin, h.clock);
      h.pushApp(AppState(selectedSDKAccount: gnusTestNode));
      await pumpEventQueue();
      expect(events, hasLength(2));
    });
  });
}
