import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';

class _FailingConnectionStore extends GnusConnectionStore {
  _FailingConnectionStore(super.box);

  @override
  Future<void> connect(String origin, DateTime at) async {
    throw const FileSystemException('disk full');
  }
}

/// Valid params for every method, so only the connection decides the reply.
final Map<String, Object?> _valid = {
  GnusRpcMethod.getAccounts: null,
  GnusRpcMethod.estimate: {
    'job': {
      'inputs': ['a'],
    },
  },
  GnusRpcMethod.submitJob: {
    'job': {
      'inputs': ['a'],
    },
    'idempotencyKey': 'key-1',
  },
  GnusRpcMethod.listJobs: null,
  GnusRpcMethod.getJob: {'idempotencyKey': 'key-1'},
  GnusRpcMethod.getEarnings: null,
};

int? _code(Map<String, Object?> reply) =>
    (reply['error'] as Map<String, Object?>?)?['code'] as int?;

void main() {
  late GnusHarness h;

  setUp(() async {
    h = await GnusHarness.create();
  });

  tearDown(() => h.dispose());

  test('bad params and an unknown method answer before any prompt', () async {
    final handler = h.build();

    for (final method in GnusRpcMethod.all) {
      final reply = await viaJson(handler, _origin, method, [1]);
      expect(_code(reply), GnusRpcCode.invalidParams, reason: method);
    }
    final unknown = await viaJson(handler, _origin, 'gnus_nope', null);

    expect(_code(unknown), GnusRpcCode.unsupportedMethod);
    expect(h.connects, isEmpty);
    expect(h.connections.isConnected(_origin), isFalse);
  });

  test('every method asks first, then reports the wallet not ready', () async {
    h.api.sdkInitialized = false;
    final handler = h.build();

    for (final entry in _valid.entries) {
      h.connects.clear();
      await h.connections.revoke(_origin);

      final reply = await viaJson(handler, _origin, entry.key, entry.value);

      expect(_code(reply), GnusRpcCode.disconnected, reason: entry.key);
      expect(h.connects, [_origin], reason: entry.key);
    }
  });

  test('a declined connect answers 4001 and connects nothing', () async {
    h.api.sdkInitialized = false;
    final handler = h.build(connect: ({required String origin}) async => false);

    for (final entry in _valid.entries) {
      final reply = await viaJson(handler, _origin, entry.key, entry.value);

      expect(_code(reply), GnusRpcCode.userRejected, reason: entry.key);
      expect(h.connections.isConnected(_origin), isFalse, reason: entry.key);
    }
  });

  test('a connect that throws is a rejection', () async {
    final handler = h.build(
      connect: ({required String origin}) async => throw StateError('boom'),
    );

    final reply = await viaJson(
      handler,
      _origin,
      GnusRpcMethod.getAccounts,
      null,
    );

    expect(_code(reply), GnusRpcCode.userRejected);
  });

  test('a revoked origin is asked again', () async {
    final handler = h.build();
    await viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);
    await viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);
    expect(h.connects, [_origin]);

    await h.connections.revoke(_origin);
    await viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);

    expect(h.connects, [_origin, _origin]);
  });

  test('a failed connection write answers -32603 and stays out', () async {
    h.connections = _FailingConnectionStore(h.connectionBox);
    final handler = h.build();

    final reply = await viaJson(
      handler,
      _origin,
      GnusRpcMethod.getAccounts,
      null,
    );

    expect(_code(reply), GnusRpcCode.internal);
    expect(h.connections.isConnected(_origin), isFalse);
  });

  test('a wallet or network change needs no new prompt', () async {
    final handler = h.build();
    await viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);

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
    final reply = await viaJson(
      handler,
      _origin,
      GnusRpcMethod.getAccounts,
      null,
    );

    expect(reply['result'], isA<Map>());
    expect(h.connects, [_origin]);
  });

  test('a look-alike origin does not inherit a connection', () async {
    final handler = h.build();
    await viaJson(handler, _origin, GnusRpcMethod.getAccounts, null);

    for (final other in [
      'http://dash.example',
      'https://dash.example:8443',
      'https://dash.example.evil.invalid',
      'https://Dash.example',
    ]) {
      expect(h.connections.isConnected(other), isFalse, reason: other);
    }
  });
}
