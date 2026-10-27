import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';
const _submit = GnusRpcMethod.submitJob;

typedef _Transport =
    Future<Map<String, Object?>> Function(
      GnusHarness harness,
      String method,
      Object? params,
    );

Map<String, Object?> _params({String key = 'key-1'}) => {
  'job': {
    'inputs': ['a'],
    'passes': [
      {'name': 'x', 'n': 1},
    ],
  },
  'idempotencyKey': key,
};

final _transports = <String, _Transport>{
  'direct': (h, method, params) =>
      viaDirect(h.build(), _origin, method, params),
  'json': (h, method, params) => viaJson(h.build(), _origin, method, params),
};

Map<String, Object?> _error(Map<String, Object?> reply) =>
    reply['error']! as Map<String, Object?>;

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

  test('a submit burns once and replies the same on both transports', () async {
    final replies = <Map<String, Object?>>[];
    for (final transport in _transports.values) {
      final h = await harness();
      replies.add(await transport(h, _submit, _params()));

      expect(h.api.calls, ['cost', 'gas', 'burn', 'process']);
      final record = h.store.byBurnHash(gnusTestBurnHash);
      expect(record, isNotNull);
      expect(record!.origin, _origin);
      expect(record.idempotencyKey, 'key-1');
      expect(record.cost, '1234000000000000000000');
      expect(record.status, GnusJobStatus.submitted);
      expect(record.submittedAt, h.clock);
      expect(record.sdkAddress, gnusTestNode.toLowerCase());

      expect(h.confirms, hasLength(1));
      final shown = h.confirms.single;
      expect(shown.origin, _origin);
      expect(shown.cost, '1234000000000000000000');
      expect(shown.gas, {'gasPriceGwei': '1.00', 'symbol': 'POL'});
      expect(shown.payer, gnusTestWalletAddress.toLowerCase());
      expect(shown.nodeAccount, gnusTestNode.toLowerCase());
    }

    expect(replies[0], equals(replies[1]));
    final result = replies[0]['result']! as Map<String, Object?>;
    expect(result['jobId'], isNull);
    expect(result['burnTxHash'], gnusTestBurnHash);
    expect(result['status'], 'submitted');
    expect(result['sdkAddress'], matches(RegExp(r'^0x[0-9a-f]{128}$')));
  });

  test('the default confirm rejects and nothing burns', () async {
    final h = await harness();

    final reply = await viaDirect(
      h.buildDefaultConfirm(),
      _origin,
      _submit,
      _params(),
    );

    expect(_error(reply)['code'], GnusRpcCode.userRejected);
    expect(h.api.calls, isNot(contains('burn')));
    expect(h.store.byBurnHash(gnusTestBurnHash), isNull);
  });

  test('a confirm that throws is a rejection', () async {
    final h = await harness();
    final handler = h.build(
      confirm:
          ({
            required origin,
            required cost,
            required gas,
            required payer,
            required nodeAccount,
          }) async => throw StateError('prompt crashed'),
    );

    final reply = await viaDirect(handler, _origin, _submit, _params());

    expect(_error(reply)['code'], GnusRpcCode.userRejected);
    expect(h.api.calls, isNot(contains('burn')));
  });

  group('refusals are identical on both transports', () {
    Future<void> expectCode(
      int code,
      Future<void> Function(GnusHarness h) arrange, {
      String method = _submit,
      Object? params,
      bool noSpend = true,
    }) async {
      final replies = <Map<String, Object?>>[];
      for (final transport in _transports.values) {
        final h = await harness();
        await arrange(h);
        replies.add(await transport(h, method, params ?? _params()));
        if (noSpend) {
          expect(h.api.calls, isNot(contains('burn')));
        }
      }
      expect(replies[0], equals(replies[1]));
      expect(_error(replies[0])['code'], code);
    }

    test('an unknown method is 4200', () async {
      await expectCode(
        GnusRpcCode.unsupportedMethod,
        (h) async {},
        method: 'gnus_doesNotExist',
      );
    });

    test('the retired gnus_getAddress is 4200', () async {
      await expectCode(
        GnusRpcCode.unsupportedMethod,
        (h) async {},
        method: 'gnus_getAddress',
      );
    });

    test('non-object params are -32602', () async {
      await expectCode(GnusRpcCode.invalidParams, (h) async {}, params: [1]);
    });

    test('a missing, empty or oversized job or key is -32602', () async {
      for (final bad in <Map<String, Object?>>[
        {'idempotencyKey': 'k'},
        {'job': <String, Object?>{}, 'idempotencyKey': 'k'},
        {'job': 'text', 'idempotencyKey': 'k'},
        {
          'job': {'a': 1},
        },
        {
          'job': {'a': 1},
          'idempotencyKey': '',
        },
        {
          'job': {'a': 1},
          'idempotencyKey': 'k' * 129,
        },
      ]) {
        await expectCode(GnusRpcCode.invalidParams, (h) async {}, params: bad);
      }
    });

    test('a job past the size cap is -32602', () async {
      await expectCode(
        GnusRpcCode.invalidParams,
        (h) async {},
        params: {
          'job': {'blob': 'x' * kGnusMaxJobBytes},
          'idempotencyKey': 'k',
        },
      );
    });

    test('an account switch in progress is -32015', () async {
      await expectCode(GnusRpcCode.accountSwitching, (h) async {
        h.app = AppState(
          selectedSDKAccount: gnusTestNode,
          switchingSDKAccount: '0x${'c' * 128}',
        );
      });
    });

    test('an SDK that is not initialized is 4900', () async {
      await expectCode(GnusRpcCode.disconnected, (h) async {
        h.api.sdkInitialized = false;
      });
    });

    test('every gate state but enabled refuses before pricing', () async {
      for (final state in BridgeGateState.values) {
        if (state == BridgeGateState.enabled) {
          continue;
        }
        final h = await harness();
        h.gate = BridgeGate(state);

        final reply = await viaDirect(h.build(), _origin, _submit, _params());

        expect(reply['error'], isNotNull, reason: state.name);
        expect(h.api.calls, isEmpty, reason: state.name);
      }
    });

    test('a failed cost is -32010 and never cost 0', () async {
      await expectCode(GnusRpcCode.costUnavailable, (h) async {
        h.api.costResponse = 0;
      });
    });

    test('a failed burn is -32013', () async {
      await expectCode(GnusRpcCode.bridgeFailed, (h) async {
        h.api.burnResponse = ApiResponse.error('node said no');
      }, noSpend: false);
    });
  });

  test('a failed process after the burn is a result, not an error', () async {
    final h = await harness();
    h.api.processResponse =
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED;

    final reply = await viaJson(h.build(), _origin, _submit, _params());

    final result = reply['result']! as Map<String, Object?>;
    expect(result['status'], 'bridgedNotProcessed');
    expect(result['burnTxHash'], gnusTestBurnHash);
    expect(
      h.store.byBurnHash(gnusTestBurnHash)!.status,
      GnusJobStatus.bridgedNotProcessed,
    );
  });

  test('the record exists before Process runs and ends submitted', () async {
    final h = await harness();
    GnusJob? seenDuringProcess;
    h.api.onProcess = () async {
      seenDuringProcess = h.store.byBurnHash(gnusTestBurnHash);
    };

    await viaDirect(h.build(), _origin, _submit, _params());

    expect(seenDuringProcess, isNotNull);
    expect(seenDuringProcess!.status, GnusJobStatus.bridgedNotProcessed);
    expect(
      h.store.byBurnHash(gnusTestBurnHash)!.status,
      GnusJobStatus.submitted,
    );
  });

  test('a process that throws after the burn leaves the record', () async {
    final h = await harness();
    h.api.onProcess = () async => throw StateError('isolate died');

    final reply = await viaDirect(h.build(), _origin, _submit, _params());

    expect(
      (reply['result']! as Map<String, Object?>)['status'],
      'bridgedNotProcessed',
    );
    expect(
      h.store.byBurnHash(gnusTestBurnHash)!.status,
      GnusJobStatus.bridgedNotProcessed,
    );
  });

  test('a gas estimate that fails does not block the submit', () async {
    final h = await harness();
    h.api.gasResponse = ApiResponse.error('rpc down');

    final reply = await viaDirect(h.build(), _origin, _submit, _params());

    expect(reply['result'], isNotNull);
    expect(h.confirms.single.gas, isNull);
  });

  test('gas price parsing keeps only a real number', () {
    expect(gnusGasPrice('1.00 Gwei', 'pol'), {
      'gasPriceGwei': '1.00',
      'symbol': 'POL',
    });
    expect(gnusGasPrice('null Gwei', 'POL'), isNull);
    expect(gnusGasPrice('1.00 Gwei', null), isNull);
    expect(gnusGasPrice('1.00 Gwei', ''), isNull);
    expect(gnusGasPrice(null, 'POL'), isNull);
  });

  test('cost conversion is exact and rejects a non-positive cost', () {
    expect(gnusCostBaseUnits(1), '1000000000000000000');
    expect(gnusCostBaseUnits(0), isNull);
    expect(gnusCostBaseUnits(-5), isNull);
  });

  test('the body hash ignores key order', () {
    expect(
      gnusJobBodyHash({
        'a': 1,
        'b': {'x': 1, 'y': 2},
      }),
      gnusJobBodyHash({
        'b': {'y': 2, 'x': 1},
        'a': 1,
      }),
    );
    expect(gnusJobBodyHash({'a': 1}), isNot(gnusJobBodyHash({'a': 2})));
  });
}
