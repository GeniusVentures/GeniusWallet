import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/reown/gnus_wallet_connect.dart';
import 'package:reown_walletkit/reown_walletkit.dart';

import '../gnus_bridge/gnus_fakes.dart';
import 'fake_wallet_kit.dart';

final _origin = GnusOrigin.parse(GnusTransport.walletconnect, dashboardUrl);

// What the dashboard's WalletConnect client does with an answer: an error
// message that is a JSON object with `message` carries the error's data, and
// `{}` stands for a null result.
Map<String, Object?> _decode(JsonRpcResponse response) {
  final error = response.error;
  if (error == null) {
    final result = jsonDecode(jsonEncode(response.result));
    return {'result': result is Map && result.isEmpty ? null : result};
  }
  Object? parsed;
  try {
    parsed = jsonDecode(error.message ?? '');
  } on FormatException {
    parsed = null;
  }
  if (parsed is Map && parsed['message'] is String) {
    return {
      'error': {
        'code': error.code,
        'message': parsed['message'],
        if (parsed.containsKey('data')) 'data': parsed['data'],
      },
    };
  }
  return {
    'error': {'code': error.code, 'message': error.message},
  };
}

GnusJob _job(String hash, {String? jobId}) => GnusJob(
  jobId: jobId,
  burnTxHash: hash,
  sdkAddress: gnusTestNode.toLowerCase(),
  origin: _origin.value,
  idempotencyKey: 'k',
  submittedAt: DateTime.utc(2026, 10, 27, 12),
  cost: '1000000000000000000',
  status: GnusJobStatus.submitted,
  bodyHash: 'h',
);

Map<String, Object?> _submitParams(String key) => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': key,
};

void main() {
  late GnusHarness h;
  late GnusRpcHandler handler;
  late FakeWalletKit kit;
  late void Function() stop;
  var nextId = 1;

  setUp(() async {
    h = await GnusHarness.create();
    handler = h.build();
    await h.connections.connect(_origin, h.clock);
    kit = FakeWalletKit()..activeSessions['topic-1'] = sessionData();
    stop = handleGnusRequests(
      walletKit: kit,
      handler: handler,
      devBuild: false,
    );
  });

  tearDown(() async {
    stop();
    await h.dispose();
  });

  Future<Map<String, Object?>> overWalletConnect(
    String method,
    Object? params,
  ) async {
    final before = kit.responses.length;
    kit.request.broadcast(gnusRequest(method, params: params, id: nextId++));
    await pumpEventQueue();
    expect(kit.responses.length, before + 1, reason: '$method: one answer');
    return _decode(kit.responses.last.response);
  }

  Future<void> expectParity(String method, Object? params) async {
    final wire = await overWalletConnect(method, params);
    final direct = await viaJson(handler, _origin, method, params);
    expect(wire, equals(direct), reason: method);
  }

  group('both call paths answer alike', () {
    test('gnus_getAccounts', () => expectParity('gnus_getAccounts', null));

    test('gnus_estimate: a priced job and a bad param', () async {
      await expectParity('gnus_estimate', {
        'job': {
          'inputs': ['a'],
        },
      });
      await expectParity('gnus_estimate', {'job': 'not an object'});
      final bad = await overWalletConnect('gnus_estimate', {'job': 1});
      expect((bad['error']! as Map)['code'], GnusRpcCode.invalidParams);
    });

    test('gnus_listJobs', () async {
      await h.store.put(_job('0x1'));
      await h.store.put(_job('0x2'));
      await expectParity('gnus_listJobs', null);
      await expectParity('gnus_listJobs', {'limit': 1});
    });

    test('gnus_getJob: no record is null, a record is the job', () async {
      await expectParity('gnus_getJob', {'burnTxHash': '0xmissing'});
      final none = await overWalletConnect('gnus_getJob', {
        'burnTxHash': '0xmissing',
      });
      expect(none, {'result': null});

      await h.store.put(_job('0x1'));
      await expectParity('gnus_getJob', {'burnTxHash': '0x1'});
      final found = await overWalletConnect('gnus_getJob', {
        'burnTxHash': '0x1',
      });
      expect((found['result']! as Map)['burnTxHash'], '0x1');
    });

    test('gnus_getEarnings', () => expectParity('gnus_getEarnings', null));

    test('an error with data.reason keeps its data', () async {
      h.gate = const BridgeGate(BridgeGateState.viewOnly);
      await expectParity('gnus_submitJob', _submitParams('k-refused'));
      final wire = await overWalletConnect(
        'gnus_submitJob',
        _submitParams('k-refused'),
      );
      final error = wire['error']! as Map;
      expect(error['code'], GnusRpcCode.payerCannotSign);
      expect(error['data'], {'reason': GnusRpcReason.viewOnly});
    });

    test('an unsupported method keeps its code', () async {
      await expectParity('gnus_getAddress', null);
    });

    test('gnus_submitJob burns once; the direct replay equals the first '
        'answer', () async {
      final wire = await overWalletConnect(
        'gnus_submitJob',
        _submitParams('K'),
      );
      final direct = await viaJson(
        handler,
        _origin,
        'gnus_submitJob',
        _submitParams('K'),
      );

      expect(wire['result'], isNotNull);
      expect(direct, equals(wire));
      expect(h.api.count('burn'), 1);
    });
  });

  group('the wire encoding', () {
    test('an error with data is the JSON text of message and data', () async {
      h.gate = const BridgeGate(BridgeGateState.viewOnly);

      await overWalletConnect('gnus_submitJob', _submitParams('k'));

      final error = kit.responses.single.response.error!;
      expect(jsonDecode(error.message!), {
        'message': 'Payer cannot sign',
        'data': {'reason': GnusRpcReason.viewOnly},
      });
    });

    test('an error without data keeps its plain message', () async {
      await overWalletConnect('gnus_getAddress', null);

      final error = kit.responses.single.response.error!;
      expect(error.code, GnusRpcCode.unsupportedMethod);
      expect(error.message, 'Method not supported');
    });

    test('a null result goes out as an empty object', () async {
      await overWalletConnect('gnus_getJob', {'burnTxHash': '0xmissing'});

      expect(kit.responses.single.response.result, <String, Object?>{});
    });
  });
}
