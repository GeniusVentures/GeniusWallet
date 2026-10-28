import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

import 'gnus_fakes.dart';

const _originValue = 'https://dash.example';
final _origin = webOrigin(_originValue);
const _list = GnusRpcMethod.listJobs;
const _get = GnusRpcMethod.getJob;

GnusJob _job(
  String hash, {
  String? node,
  String origin = _originValue,
  String key = 'k',
  int minute = 0,
  String? jobId,
}) => GnusJob(
  jobId: jobId,
  burnTxHash: hash,
  sdkAddress: (node ?? gnusTestNode).toLowerCase(),
  origin: origin,
  idempotencyKey: key,
  submittedAt: DateTime.utc(2026, 10, 27, 12, minute),
  cost: '1000000000000000000',
  status: GnusJobStatus.submitted,
  bodyHash: 'h',
);

Map<String, Object?> _error(Map<String, Object?> reply) =>
    reply['error']! as Map<String, Object?>;

void main() {
  late GnusHarness h;

  setUp(() async {
    h = await GnusHarness.create();
  });

  tearDown(() async {
    await h.dispose();
  });

  Future<Map<String, Object?>> call(String method, Object? params) async {
    final direct = await viaDirect(h.build(), _origin, method, params);
    final json = await viaJson(h.build(), _origin, method, params);
    expect(json, equals(direct));
    return direct;
  }

  group('gnus_listJobs', () {
    test(
      'lists only the current node account, newest first, in the contract shape',
      () async {
        await h.store.put(_job('0x1', minute: 1));
        await h.store.put(_job('0x2', minute: 2));
        await h.store.put(_job('0x9', node: '0x${'c' * 128}', minute: 9));

        final reply = await call(_list, null);

        final result = reply['result']! as Map<String, Object?>;
        final jobs = result['jobs']! as List<Object?>;
        expect(jobs.map((j) => (j! as Map)['burnTxHash']), ['0x2', '0x1']);
        expect(result['nextCursor'], isNull);
        expect(jobs.first, {
          'jobId': null,
          'burnTxHash': '0x2',
          'sdkAddress': gnusTestNode.toLowerCase(),
          'origin': _origin.value,
          'idempotencyKey': 'k',
          'submittedAt': '2026-10-27T12:02:00.000Z',
          'cost': '1000000000000000000',
          'status': 'submitted',
        });
      },
    );

    test('the default limit is 20 and a cursor pages on', () async {
      for (var i = 0; i < 25; i++) {
        await h.store.put(_job('0x${i.toString().padLeft(2, '0')}', minute: i));
      }

      final first = (await call(_list, {}))['result']! as Map<String, Object?>;
      expect(first['jobs']! as List, hasLength(20));
      final cursor = first['nextCursor']! as String;

      final second =
          (await call(_list, {'cursor': cursor}))['result']!
              as Map<String, Object?>;
      expect(second['jobs']! as List, hasLength(5));
      expect(second['nextCursor'], isNull);
    });

    test('limit bounds: 1, 100 and 20.0 are accepted', () async {
      for (final limit in [1, 100, 20.0]) {
        final reply = await call(_list, {'limit': limit});
        expect(reply['error'], isNull, reason: '$limit');
      }
    });

    test('limit 0, 101, -1, a string and a fraction are -32602', () async {
      for (final limit in [0, 101, -1, '5', 1.5, double.nan, true]) {
        final reply = await viaDirect(h.build(), _origin, _list, {
          'limit': limit,
        });
        expect(
          _error(reply)['code'],
          GnusRpcCode.invalidParams,
          reason: '$limit',
        );
      }
    });

    test('a malformed or oversized cursor is -32602', () async {
      for (final cursor in ['***', 'bm9wZQ==', 'x' * 513, '', 5]) {
        final reply = await call(_list, {'cursor': cursor});
        expect(
          _error(reply)['code'],
          GnusRpcCode.invalidParams,
          reason: '$cursor',
        );
      }
    });

    test('refuses during a switch and with the SDK down', () async {
      h.app = AppState(
        selectedSDKAccount: gnusTestNode,
        switchingSDKAccount: '0x${'c' * 128}',
      );
      expect(
        _error(await call(_list, null))['code'],
        GnusRpcCode.accountSwitching,
      );

      h.app = AppState(selectedSDKAccount: gnusTestNode);
      h.api.sdkInitialized = false;
      expect(_error(await call(_list, null))['code'], GnusRpcCode.disconnected);
    });
  });

  group('gnus_getJob', () {
    setUp(() async {
      await h.store.put(_job('0xAbC', key: 'key-1', minute: 1));
      await h.store.put(
        _job('DEV-HASH', key: 'dev', minute: 2, jobId: 'job-1'),
      );
    });

    test(
      'finds by burn hash in any case, including a non-hex dev hash',
      () async {
        for (final hash in ['0xabc', '0xABC', 'dev-hash']) {
          final reply = await call(_get, {'burnTxHash': hash});
          final job = reply['result']! as Map<String, Object?>;
          expect(job['result'], isNull, reason: hash);
          expect(job['status'], 'submitted', reason: hash);
        }
      },
    );

    test('finds by idempotency key for the same origin only', () async {
      final mine = await call(_get, {'idempotencyKey': 'key-1'});
      expect((mine['result']! as Map)['burnTxHash'], '0xAbC');

      final other = await viaDirect(
        h.build(),
        webOrigin('https://elsewhere.example'),
        _get,
        {'idempotencyKey': 'key-1'},
      );
      expect(other['result'], isNull);
      expect(other.containsKey('result'), isTrue);
    });

    test('finds by job id once one is set', () async {
      final reply = await call(_get, {'jobId': 'job-1'});
      expect((reply['result']! as Map)['burnTxHash'], 'DEV-HASH');
      expect((await call(_get, {'jobId': 'job-2'}))['result'], isNull);
    });

    test('a record of another node account is not found', () async {
      await h.store.put(
        _job('0xother', node: '0x${'c' * 128}', key: 'theirs', minute: 3),
      );

      expect((await call(_get, {'burnTxHash': '0xother'}))['result'], isNull);
      expect(
        (await call(_get, {'idempotencyKey': 'theirs'}))['result'],
        isNull,
      );
    });

    test('an unfinished submit is found by its key as pending', () async {
      final intent = GnusSubmitIntent(
        origin: _origin.value,
        idempotencyKey: 'open',
        bodyHash: 'h',
        payer: gnusTestWalletAddress.toLowerCase(),
        sdkAddress: gnusTestNode.toLowerCase(),
        cost: '1000000000000000000',
        createdAt: DateTime.utc(2026, 10, 27, 12, 5),
      );
      await h.store.putIntent(intent);

      final unsigned = await call(_get, {'idempotencyKey': 'open'});
      expect(unsigned['result'], {
        'jobId': null,
        'burnTxHash': null,
        'sdkAddress': gnusTestNode.toLowerCase(),
        'origin': _origin.value,
        'idempotencyKey': 'open',
        'submittedAt': '2026-10-27T12:05:00.000Z',
        'cost': '1000000000000000000',
        'status': 'pending',
        'result': null,
      });

      await h.store.putIntent(intent.withBurn('0xsigned'));
      final signed = await call(_get, {'idempotencyKey': 'open'});
      expect((signed['result']! as Map)['burnTxHash'], '0xsigned');
    });

    test('a recorded job wins over its intent', () async {
      await h.store.putIntent(
        GnusSubmitIntent(
          origin: _origin.value,
          idempotencyKey: 'key-1',
          bodyHash: 'h',
          payer: gnusTestWalletAddress.toLowerCase(),
          sdkAddress: gnusTestNode.toLowerCase(),
          cost: '1',
          createdAt: DateTime.utc(2026, 10, 27, 12),
        ),
      );

      final reply = await call(_get, {'idempotencyKey': 'key-1'});
      expect((reply['result']! as Map)['status'], 'submitted');
    });

    test('zero or two selectors, or a bad selector, is -32602', () async {
      for (final bad in <Object?>[
        null,
        <String, Object?>{},
        {'burnTxHash': '0xabc', 'idempotencyKey': 'key-1'},
        {'jobId': ''},
        {'jobId': 5},
        {'burnTxHash': 'x' * 257},
      ]) {
        final reply = await call(_get, bad);
        expect(
          _error(reply)['code'],
          GnusRpcCode.invalidParams,
          reason: '$bad',
        );
      }
    });
  });
}
