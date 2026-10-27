import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

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

  group('idempotency', () {
    test(
      'the same key and body replays the first reply with one burn',
      () async {
        final h = await harness();
        final handler = h.build();

        final first = await viaDirect(handler, _origin, _submit, _params());
        h.clock = h.clock.add(const Duration(hours: 23));
        final second = await viaJson(handler, _origin, _submit, _params());

        expect(second, equals(first));
        expect(h.api.count('burn'), 1);
        expect(h.confirms, hasLength(1));
      },
    );

    test(
      'the same key with another body is -32602 and burns nothing more',
      () async {
        final h = await harness();
        final handler = h.build();
        await viaDirect(handler, _origin, _submit, _params());

        final other = <String, Object?>{
          'job': {'different': true},
          'idempotencyKey': 'key-1',
        };
        final reply = await viaJson(handler, _origin, _submit, other);

        expect(_error(reply)['code'], GnusRpcCode.invalidParams);
        expect(_error(reply)['data'], {
          'reason': GnusRpcReason.idempotencyKeyReused,
        });
        expect(h.api.count('burn'), 1);
      },
    );

    test('both record writes failing still replies the burn hash and a '
        'same-key retry does not burn again', () async {
      final h = await harness();
      final handler = h.build();
      h.store.failWrites = true;

      final first = await viaDirect(handler, _origin, _submit, _params());
      final second = await viaJson(handler, _origin, _submit, _params());

      final result = first['result']! as Map<String, Object?>;
      expect(result['burnTxHash'], gnusTestBurnHash);
      expect(result['status'], 'submitted');
      expect(second, equals(first));
      expect(h.store.byBurnHash(gnusTestBurnHash), isNull);
      expect(h.api.count('burn'), 1);
    });

    test(
      'a failed final write replays submitted, not the early record',
      () async {
        final h = await harness();
        final handler = h.build();
        h.api.onProcess = () async {
          h.store.failWrites = true;
        };

        await viaDirect(handler, _origin, _submit, _params());
        final again = await viaDirect(handler, _origin, _submit, _params());

        expect(
          h.store.byBurnHash(gnusTestBurnHash)!.status,
          GnusJobStatus.bridgedNotProcessed,
        );
        expect(
          (again['result']! as Map<String, Object?>)['status'],
          'submitted',
        );
        expect(h.api.count('burn'), 1);
      },
    );

    test('the same key after 24 hours runs again', () async {
      final h = await harness();
      final handler = h.build();
      await viaDirect(handler, _origin, _submit, _params());
      h.clock = h.clock.add(const Duration(hours: 24, seconds: 1));
      h.api.burnResponse = ApiResponse.success('0xsecond');

      final reply = await viaDirect(handler, _origin, _submit, _params());

      expect(
        (reply['result']! as Map<String, Object?>)['burnTxHash'],
        '0xsecond',
      );
      expect(h.api.count('burn'), 2);
    });

    test('the same key from another origin is a new submit', () async {
      final h = await harness();
      final handler = h.build();
      await viaDirect(handler, _origin, _submit, _params());
      h.api.burnResponse = ApiResponse.success('0xsecond');

      final reply = await viaDirect(
        handler,
        'https://other.example',
        _submit,
        _params(),
      );

      expect(reply['result'], isNotNull);
      expect(h.api.count('burn'), 2);
    });

    test('a refused submit can be retried with the same key', () async {
      final h = await harness();
      final rejecting = h.build(
        confirm:
            ({
              required origin,
              required cost,
              required gas,
              required payer,
              required nodeAccount,
            }) async => false,
      );
      await viaDirect(rejecting, _origin, _submit, _params());

      final reply = await viaDirect(h.build(), _origin, _submit, _params());

      expect(reply['result'], isNotNull);
      expect(h.api.count('burn'), 1);
    });
  });

  group('one submit at a time', () {
    late GnusHarness h;
    late Completer<bool> held;
    late GnusRpcHandler handler;

    setUp(() async {
      h = await harness();
      held = Completer<bool>();
      handler = h.build(
        confirm:
            ({
              required origin,
              required cost,
              required gas,
              required payer,
              required nodeAccount,
            }) => held.future,
      );
    });

    Future<Map<String, Object?>> inFlightCall(String origin, String key) =>
        viaJson(handler, origin, _submit, _params(key: key));

    test(
      'a second submit gets -32005 from any origin, including a retry',
      () async {
        final first = viaDirect(handler, _origin, _submit, _params());

        for (final reply in [
          await inFlightCall(_origin, 'key-2'),
          await inFlightCall('https://other.example', 'key-3'),
          await inFlightCall(_origin, 'key-1'),
        ]) {
          expect(_error(reply)['code'], GnusRpcCode.busy);
          expect(_error(reply)['data'], {
            'reason': GnusRpcReason.submitInFlight,
          });
        }

        held.complete(true);
        expect((await first)['result'], isNotNull);
        expect(h.api.count('burn'), 1);
      },
    );

    test('the lock is free after the first submit finishes', () async {
      final first = viaDirect(handler, _origin, _submit, _params());
      held.complete(true);
      await first;
      h.api.burnResponse = ApiResponse.success('0xsecond');

      final reply = await inFlightCall(_origin, 'key-2');

      expect(reply['result'], isNotNull);
    });

    test('the lock is free after a rejected confirm', () async {
      final first = viaDirect(handler, _origin, _submit, _params());
      held.complete(false);
      expect(_error(await first)['code'], GnusRpcCode.userRejected);

      final reply = await viaDirect(h.build(), _origin, _submit, _params());

      expect(reply['result'], isNotNull);
    });

    test('the lock is free after the owner throws', () async {
      h.api.costThrows = true;
      final first = viaDirect(handler, _origin, _submit, _params());
      held.complete(true);
      expect(_error(await first)['code'], GnusRpcCode.internal);
      h.api.costThrows = false;

      final reply = await inFlightCall(_origin, 'key-1');

      expect(reply['result'], isNotNull);
    });
  });

  test('a gas estimate that fails does not block the submit', () async {
    final h = await harness();
    h.api.gasResponse = ApiResponse.error('rpc down');

    final reply = await viaDirect(h.build(), _origin, _submit, _params());

    expect(reply['result'], isNotNull);
    expect(h.confirms.single.gas, isNull);
  });

  group('who can pay and what it costs, all before the burn', () {
    Map<String, Object?>? errorData(Map<String, Object?> reply) =>
        _error(reply)['data'] as Map<String, Object?>?;

    test('every refused gate state has its code and reason', () async {
      const expected = <BridgeGateState, (int, String?)>{
        BridgeGateState.noWallet: (
          GnusRpcCode.payerCannotSign,
          GnusRpcReason.noWallet,
        ),
        BridgeGateState.viewOnly: (
          GnusRpcCode.payerCannotSign,
          GnusRpcReason.viewOnly,
        ),
        BridgeGateState.child: (
          GnusRpcCode.payerCannotSign,
          GnusRpcReason.child,
        ),
        BridgeGateState.notEarning: (
          GnusRpcCode.payerCannotSign,
          GnusRpcReason.notEarning,
        ),
        BridgeGateState.wrongNetwork: (
          GnusRpcCode.payerCannotSign,
          GnusRpcReason.wrongNetwork,
        ),
        BridgeGateState.noGnus: (
          GnusRpcCode.insufficientFunds,
          GnusRpcReason.noGnus,
        ),
        BridgeGateState.gnusElsewhere: (
          GnusRpcCode.insufficientFunds,
          GnusRpcReason.gnusElsewhere,
        ),
        BridgeGateState.balanceUnavailable: (
          GnusRpcCode.internal,
          GnusRpcReason.balanceUnavailable,
        ),
        BridgeGateState.checking: (
          GnusRpcCode.internal,
          GnusRpcReason.checking,
        ),
        BridgeGateState.switching: (GnusRpcCode.accountSwitching, null),
        BridgeGateState.notStarted: (GnusRpcCode.disconnected, null),
      };
      expect(
        expected.keys.toSet(),
        BridgeGateState.values.toSet()..remove(BridgeGateState.enabled),
      );

      for (final entry in expected.entries) {
        final h = await harness();
        h.gate = BridgeGate(entry.key);

        final reply = await viaJson(h.build(), _origin, _submit, _params());

        expect(_error(reply)['code'], entry.value.$1, reason: entry.key.name);
        expect(
          errorData(reply)?['reason'],
          entry.value.$2,
          reason: entry.key.name,
        );
        expect(h.api.calls, isEmpty, reason: entry.key.name);
      }
    });

    test('a balance below the cost is -32011 and nothing burns', () async {
      final h = await harness();
      h.api.gnusBalance = 12.34;

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(_error(reply)['code'], GnusRpcCode.insufficientFunds);
      expect(h.api.calls, ['cost']);
      expect(h.confirms, isEmpty);
    });

    test('a balance a hair below the cost is -32011, not rounded up', () async {
      final h = await harness();
      h.api.costResponse = 10;
      h.api.gnusBalance = 9.99996;

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(_error(reply)['code'], GnusRpcCode.insufficientFunds);
      expect(h.api.balanceReadFor, gnusTestWalletAddress);
      expect(h.confirms, isEmpty);
    });

    test('a balance exactly equal to the cost proceeds', () async {
      final h = await harness();
      h.api.gnusBalance = 1234.0;

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(reply['result'], isNotNull);
      expect(h.api.count('burn'), 1);
    });

    test('an unreadable balance fails closed with -32603', () async {
      final h = await harness();
      h.api.balanceReadable = false;

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(_error(reply)['code'], GnusRpcCode.internal);
      expect(errorData(reply), {'reason': GnusRpcReason.balanceUnavailable});
      expect(h.api.count('burn'), 0);
      expect(h.confirms, isEmpty);
    });

    test('an unknown GNUS token address is missing_data, no burn', () async {
      final h = await harness();
      h.coins.tokenKnown = false;

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(_error(reply)['code'], GnusRpcCode.internal);
      expect(errorData(reply), {'reason': GnusRpcReason.missingData});
      expect(h.api.count('burn'), 0);
      expect(h.confirms, isEmpty);
    });

    test('a burn that fails leaves no record and never processes', () async {
      final h = await harness();
      h.api.burnResponse = ApiResponse.error('node said no');

      final reply = await viaJson(h.build(), _origin, _submit, _params());

      expect(_error(reply)['code'], GnusRpcCode.bridgeFailed);
      expect(h.api.count('process'), 0);
      expect(h.box.isEmpty, isTrue);
    });
  });

  group('the account changes while the confirm is open', () {
    Future<Map<String, Object?>> submitChanging(
      GnusHarness h,
      void Function() change,
    ) {
      final handler = h.build(
        confirm:
            ({
              required origin,
              required cost,
              required gas,
              required payer,
              required nodeAccount,
            }) async {
              change();
              return true;
            },
      );
      return viaJson(handler, _origin, _submit, _params());
    }

    void expectStopped(GnusHarness h, Map<String, Object?> reply, int code) {
      expect(_error(reply)['code'], code);
      expect(h.api.count('burn'), 0);
      expect(h.box.isEmpty, isTrue);
    }

    test('a started account switch is -32015', () async {
      final h = await harness();
      final reply = await submitChanging(h, () {
        h.app = AppState(
          selectedSDKAccount: gnusTestNode,
          switchingSDKAccount: '0x${'c' * 128}',
        );
      });
      expectStopped(h, reply, GnusRpcCode.accountSwitching);
    });

    test('another node account is -32015 account_changed', () async {
      final h = await harness();
      final reply = await submitChanging(h, () {
        h.app = AppState(selectedSDKAccount: '0x${'d' * 128}');
      });
      expectStopped(h, reply, GnusRpcCode.accountSwitching);
      expect(_error(reply)['data'], {'reason': GnusRpcReason.accountChanged});
    });

    test('another payer wallet is -32015 account_changed', () async {
      final h = await harness();
      final reply = await submitChanging(h, () {
        h.walletDetails.push(
          WalletDetailsState(
            selectedWallet: gnusTestWallet.copyWith(
              address: '0x1111111111111111111111111111111111111111',
            ),
            selectedNetwork: gnusTestAmoy,
          ),
        );
      });
      expectStopped(h, reply, GnusRpcCode.accountSwitching);
      expect(_error(reply)['data'], {'reason': GnusRpcReason.accountChanged});
    });

    test('another network is -32015 account_changed', () async {
      final h = await harness();
      final reply = await submitChanging(h, () {
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
      });
      expectStopped(h, reply, GnusRpcCode.accountSwitching);
      expect(_error(reply)['data'], {'reason': GnusRpcReason.accountChanged});
    });

    test('a payer that can no longer sign is -32012', () async {
      final h = await harness();
      final reply = await submitChanging(h, () {
        h.gate = const BridgeGate(BridgeGateState.viewOnly);
      });
      expectStopped(h, reply, GnusRpcCode.payerCannotSign);
      expect(_error(reply)['data'], {'reason': GnusRpcReason.viewOnly});
    });
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
