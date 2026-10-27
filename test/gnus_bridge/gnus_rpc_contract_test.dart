import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';

Map<String, Object?> _job() => {
  'inputs': ['a'],
  'passes': [
    {'name': 'x', 'n': 1},
  ],
};

Map<String, Object?> _submit({String key = 'key-1'}) => {
  'job': _job(),
  'idempotencyKey': key,
};

/// Valid params for each method, so a refusal is about state and not shape.
final Map<String, Object?> _valid = {
  GnusRpcMethod.getAccounts: null,
  GnusRpcMethod.estimate: {'job': _job()},
  GnusRpcMethod.submitJob: _submit(),
  GnusRpcMethod.listJobs: null,
  GnusRpcMethod.getJob: {'jobId': 'unknown'},
  GnusRpcMethod.getEarnings: null,
};

final _node = '0x${'c' * 128}';

class _Case {
  _Case(
    this.name,
    this.method,
    this.params, {
    this.setup,
    this.code,
    this.check,
  });

  final String name;
  final String method;
  final Object? params;
  final Future<void> Function(GnusHarness h)? setup;

  /// The error code expected, or null for a result.
  final int? code;
  final void Function(Object? result)? check;
}

Future<void> _notInitialized(GnusHarness h) async {
  h.api.sdkInitialized = false;
}

Future<void> _switching(GnusHarness h) async {
  h.app = AppState(
    selectedSDKAccount: gnusTestNode,
    switchingSDKAccount: _node,
  );
}

Future<void> _zeroCost(GnusHarness h) async {
  h.api.costResponse = 0;
}

Future<void> _submitted(GnusHarness h) async {
  await viaDirect(h.build(), _origin, GnusRpcMethod.submitJob, _submit());
}

Map<String, Object?> _map(Object? value) => value! as Map<String, Object?>;

List<_Case> _cases() {
  final cases = <_Case>[];

  for (final method in [
    'gnus_doesNotExist',
    'gnus_getAddress',
    'eth_accounts',
    '',
  ]) {
    cases.add(_Case('unknown method "$method"', method, null, code: 4200));
  }

  for (final method in GnusRpcMethod.all) {
    for (final params in <Object?>[
      [1],
      'x',
    ]) {
      cases.add(
        _Case(
          '$method with params ${jsonEncode(params)}',
          method,
          params,
          code: GnusRpcCode.invalidParams,
        ),
      );
    }
  }

  final badParams = <String, (String, Object?)>{
    'submit with no job': (GnusRpcMethod.submitJob, {'idempotencyKey': 'k'}),
    'submit with a string job': (
      GnusRpcMethod.submitJob,
      {'job': 'text', 'idempotencyKey': 'k'},
    ),
    'submit with an empty job': (
      GnusRpcMethod.submitJob,
      {'job': <String, Object?>{}, 'idempotencyKey': 'k'},
    ),
    'submit with a list job': (
      GnusRpcMethod.submitJob,
      {
        'job': [1],
        'idempotencyKey': 'k',
      },
    ),
    'submit with no key': (GnusRpcMethod.submitJob, {'job': _job()}),
    'submit with a 129-character key': (
      GnusRpcMethod.submitJob,
      {'job': _job(), 'idempotencyKey': 'k' * 129},
    ),
    'estimate with no job': (GnusRpcMethod.estimate, <String, Object?>{}),
    'listJobs with limit 0': (GnusRpcMethod.listJobs, {'limit': 0}),
    'listJobs with limit 101': (GnusRpcMethod.listJobs, {'limit': 101}),
    'listJobs with a string limit': (GnusRpcMethod.listJobs, {'limit': '5'}),
    'listJobs with a malformed cursor': (
      GnusRpcMethod.listJobs,
      {'cursor': '!!!'},
    ),
    'getJob with no selector': (GnusRpcMethod.getJob, <String, Object?>{}),
    'getJob with two selectors': (
      GnusRpcMethod.getJob,
      {'jobId': 'a', 'burnTxHash': 'b'},
    ),
    'getEarnings with includeChildren "yes"': (
      GnusRpcMethod.getEarnings,
      {'includeChildren': 'yes'},
    ),
  };
  for (final entry in badParams.entries) {
    cases.add(
      _Case(
        entry.key,
        entry.value.$1,
        entry.value.$2,
        code: GnusRpcCode.invalidParams,
      ),
    );
  }

  for (final entry in _valid.entries) {
    cases.add(
      _Case(
        '${entry.key} with the SDK not initialized',
        entry.key,
        entry.value,
        setup: _notInitialized,
        code: GnusRpcCode.disconnected,
      ),
    );
    if (entry.key == GnusRpcMethod.getAccounts) {
      cases.add(
        _Case(
          'getAccounts during a switch',
          entry.key,
          entry.value,
          setup: _switching,
          check: (result) {
            expect(_map(result)['switching'], isTrue);
            expect(
              _map(_map(result)['node'])['sdkAddress'],
              gnusTestNode.toLowerCase(),
            );
          },
        ),
      );
      continue;
    }
    cases.add(
      _Case(
        '${entry.key} during a switch',
        entry.key,
        entry.value,
        setup: _switching,
        code: GnusRpcCode.accountSwitching,
      ),
    );
  }

  for (final method in [GnusRpcMethod.estimate, GnusRpcMethod.submitJob]) {
    cases.add(
      _Case(
        '$method with a zero SDK cost',
        method,
        _valid[method],
        setup: _zeroCost,
        code: GnusRpcCode.costUnavailable,
      ),
    );
  }

  cases.addAll([
    _Case(
      'getAccounts answers the contract shape',
      GnusRpcMethod.getAccounts,
      null,
      check: (result) {
        expect(_map(result)['version'], kGnusRpcVersion);
        expect(_map(result)['switching'], isFalse);
      },
    ),
    _Case(
      'estimate prices the job',
      GnusRpcMethod.estimate,
      _valid[GnusRpcMethod.estimate],
      check: (result) => expect(_map(result)['cost'], '1234000000000000000000'),
    ),
    _Case(
      'submit burns and reports submitted',
      GnusRpcMethod.submitJob,
      _valid[GnusRpcMethod.submitJob],
      check: (result) {
        expect(_map(result)['status'], 'submitted');
        expect(_map(result)['burnTxHash'], gnusTestBurnHash);
      },
    ),
    _Case(
      'listJobs on an empty record',
      GnusRpcMethod.listJobs,
      null,
      check: (result) {
        expect(_map(result)['jobs'], isEmpty);
        expect(_map(result)['nextCursor'], isNull);
      },
    ),
    _Case(
      'listJobs after a submit',
      GnusRpcMethod.listJobs,
      null,
      setup: _submitted,
      check: (result) => expect(_map(result)['jobs'], hasLength(1)),
    ),
    _Case(
      'getJob finds nothing for an unknown id',
      GnusRpcMethod.getJob,
      {'jobId': 'unknown'},
      check: (result) => expect(result, isNull),
    ),
    _Case(
      'getJob finds a submitted job by burn hash',
      GnusRpcMethod.getJob,
      {'burnTxHash': gnusTestBurnHash},
      setup: _submitted,
      check: (result) => expect(_map(result)['status'], 'submitted'),
    ),
    _Case(
      'getEarnings answers balance and nulls',
      GnusRpcMethod.getEarnings,
      null,
      check: (result) {
        expect(_map(result)['balance'], '12500000000000000000');
        expect(_map(_map(result)['earned'])['total'], isNull);
      },
    ),
  ]);

  return cases;
}

void main() {
  final collected = <Map<String, Object?>>[];

  for (final testCase in _cases()) {
    test(testCase.name, () async {
      final direct = await GnusHarness.create();
      final json = await GnusHarness.create();
      addTearDown(direct.dispose);
      addTearDown(json.dispose);
      await testCase.setup?.call(direct);
      await testCase.setup?.call(json);

      final viaDirectReply = await viaDirect(
        direct.build(),
        _origin,
        testCase.method,
        testCase.params,
      );
      final viaJsonReply = await viaJson(
        json.build(),
        _origin,
        testCase.method,
        testCase.params,
      );

      expect(viaJsonReply, equals(jsonDecode(jsonEncode(viaDirectReply))));
      collected.add(viaJsonReply);
      final code = testCase.code;
      if (code != null) {
        expect(_map(viaJsonReply['error'])['code'], code);
        expect(viaJsonReply.containsKey('result'), isFalse);
      } else {
        expect(viaJsonReply.containsKey('error'), isFalse);
        testCase.check?.call(viaJsonReply['result']);
      }
    });
  }

  test('no reply anywhere carries a cost of 0', () {
    expect(collected, isNotEmpty);
    for (final reply in collected) {
      expect(jsonEncode(reply), isNot(contains('"cost":"0"')));
    }
  });
}
