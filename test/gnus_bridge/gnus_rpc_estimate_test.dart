import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

import 'gnus_fakes.dart';

final _origin = webOrigin('https://dash.example');
const _estimate = GnusRpcMethod.estimate;

Map<String, Object?> _params() => {
  'job': {
    'inputs': ['a'],
    'passes': [
      {'name': 'x', 'n': 1},
    ],
  },
};

Map<String, Object?> _error(Map<String, Object?> reply) =>
    reply['error']! as Map<String, Object?>;

Map<String, Object?> _result(Map<String, Object?> reply) =>
    reply['result']! as Map<String, Object?>;

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

  test('an estimate prices without burning, on both transports', () async {
    final replies = <Map<String, Object?>>[];
    for (final transport in [viaDirect, viaJson]) {
      final h = await harness();
      h.api.gnusBalance = 99999.99;

      replies.add(await transport(h.build(), _origin, _estimate, _params()));

      expect(h.api.calls, ['cost', 'gas']);
      expect(h.confirms, isEmpty);
    }

    expect(replies[0], equals(replies[1]));
    expect(_result(replies[0]), {
      'cost': '1234000000000000000000',
      'gas': {'gasPriceGwei': '1.00', 'symbol': 'POL'},
      'balance': '99999990000000000000000',
      'network': {'sdk': 'staging', 'evmChainId': 80002},
    });
  });

  test('a zero or failed cost is -32010 with no gas call', () async {
    final h = await harness();
    h.api.costResponse = 0;

    final reply = await viaJson(h.build(), _origin, _estimate, _params());

    expect(_error(reply)['code'], GnusRpcCode.costUnavailable);
    expect(reply['result'], isNull);
    expect(h.api.calls, ['cost']);
  });

  test('a failed gas response or a null Gwei string is gas null', () async {
    for (final gas in [ApiResponse<String>.error('rpc down'), null]) {
      final h = await harness();
      h.api.gasResponse = gas ?? ApiResponse.success('null Gwei');

      final reply = await viaJson(h.build(), _origin, _estimate, _params());

      expect(_result(reply)['gas'], isNull);
      expect(_result(reply)['cost'], '1234000000000000000000');
    }
  });

  test('an unreadable balance is balance null, still a result', () async {
    final h = await harness();
    h.api.balanceReadable = false;

    final reply = await viaJson(h.build(), _origin, _estimate, _params());

    expect(_result(reply)['balance'], isNull);
    expect(_result(reply)['cost'], '1234000000000000000000');
  });

  test('an estimate ignores the gate', () async {
    final h = await harness();
    h.gate = const BridgeGate(BridgeGateState.viewOnly);

    final reply = await viaJson(h.build(), _origin, _estimate, _params());

    expect(reply['result'], isNotNull);
    expect(h.api.calls, ['cost', 'gas']);
  });

  test('a missing job is -32602, a switch in progress is -32015', () async {
    final h = await harness();

    final bad = await viaJson(h.build(), _origin, _estimate, {'job': 'text'});
    expect(_error(bad)['code'], GnusRpcCode.invalidParams);

    h.app = AppState(
      selectedSDKAccount: gnusTestNode,
      switchingSDKAccount: '0x${'c' * 128}',
    );
    final switching = await viaJson(h.build(), _origin, _estimate, _params());
    expect(_error(switching)['code'], GnusRpcCode.accountSwitching);
    expect(h.api.calls, isEmpty);
  });
}
