import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:hive_ce/hive.dart';

const _nodeA = '0xaa';
const _nodeB = '0xbb';
int _boxes = 0;

GnusJob _job(
  String hash, {
  String node = _nodeA,
  String origin = 'https://o',
  String key = 'k',
  DateTime? at,
  String? jobId,
}) => GnusJob(
  jobId: jobId,
  burnTxHash: hash,
  sdkAddress: node,
  origin: origin,
  idempotencyKey: key,
  submittedAt: at ?? DateTime.utc(2026, 10, 27, 12),
  cost: '1000000000000000000',
  status: GnusJobStatus.submitted,
  bodyHash: 'h',
);

DateTime _t(int minutes) => DateTime.utc(2026, 10, 27, 12, minutes);

void main() {
  late Box<String> box;
  late GnusJobStore store;

  setUp(() async {
    box = await Hive.openBox<String>(
      'gnusStore${_boxes++}',
      bytes: Uint8List(0),
    );
    store = GnusJobStore(box);
  });

  tearDown(() async {
    await box.close();
  });

  group('page', () {
    test(
      'returns the current node newest first and pages without gaps',
      () async {
        await store.put(_job('0x1', at: _t(1)));
        await store.put(_job('0x2', at: _t(2)));
        await store.put(_job('0x3', at: _t(3)));
        await store.put(_job('0x9', node: _nodeB, at: _t(9)));

        final first = store.page(sdkAddress: _nodeA, limit: 2);
        expect(first.jobs.map((j) => j.burnTxHash), ['0x3', '0x2']);
        expect(first.nextCursor, isNotNull);

        final second = store.page(
          sdkAddress: _nodeA,
          limit: 2,
          cursor: first.nextCursor,
        );
        expect(second.jobs.map((j) => j.burnTxHash), ['0x1']);
        expect(second.nextCursor, isNull);
      },
    );

    test('equal times order by burn hash descending, none skipped', () async {
      for (final h in ['0xa', '0xc', '0xb', '0xd']) {
        await store.put(_job(h, at: _t(1)));
      }

      final seen = <String>[];
      String? cursor;
      do {
        final p = store.page(sdkAddress: _nodeA, limit: 1, cursor: cursor);
        seen.addAll(p.jobs.map((j) => j.burnTxHash));
        cursor = p.nextCursor;
      } while (cursor != null);

      expect(seen, ['0xd', '0xc', '0xb', '0xa']);
    });

    test('a newer job inserted between pages does not shift page 2', () async {
      await store.put(_job('0x1', at: _t(1)));
      await store.put(_job('0x2', at: _t(2)));
      await store.put(_job('0x3', at: _t(3)));

      final first = store.page(sdkAddress: _nodeA, limit: 1);
      await store.put(_job('0x4', at: _t(4)));
      final second = store.page(
        sdkAddress: _nodeA,
        limit: 2,
        cursor: first.nextCursor,
      );

      expect(second.jobs.map((j) => j.burnTxHash), ['0x2', '0x1']);
    });

    test('compares the node address case-insensitively', () async {
      await store.put(_job('0x1', node: '0xAb'));

      expect(store.page(sdkAddress: '0xaB', limit: 5).jobs, hasLength(1));
    });

    test('a malformed cursor throws FormatException', () {
      String enc(String s) => base64Url.encode(utf8.encode(s));
      for (final bad in [
        '***',
        enc('no-separator'),
        enc('abc|0x1'),
        enc('9000000000000000000|0x1'),
        '',
      ]) {
        expect(
          () => store.page(sdkAddress: _nodeA, limit: 1, cursor: bad),
          throwsFormatException,
          reason: bad,
        );
      }
    });
  });

  group('lookups', () {
    test('byIdempotencyKey matches origin and key, newest wins', () async {
      await store.put(_job('0x1', key: 'k', at: _t(1)));
      await store.put(_job('0x2', key: 'k', at: _t(2)));
      await store.put(
        _job('0x3', key: 'k', origin: 'https://other', at: _t(3)),
      );

      expect(store.byIdempotencyKey('https://o', 'k')!.burnTxHash, '0x2');
      expect(store.byIdempotencyKey('https://o', 'nope'), isNull);
      expect(store.byIdempotencyKey('https://nobody', 'k'), isNull);
    });

    test('byIdempotencyKey notBefore excludes an older record', () async {
      await store.put(_job('0x1', key: 'k', at: _t(1)));

      expect(
        store.byIdempotencyKey('https://o', 'k', notBefore: _t(2)),
        isNull,
      );
      expect(
        store.byIdempotencyKey('https://o', 'k', notBefore: _t(1)),
        isNotNull,
      );
    });

    test('byBurnHash is case-insensitive', () async {
      await store.put(_job('0xAbC'));

      expect(store.byBurnHash('0xABC'), isNotNull);
      expect(store.byBurnHash('0xabc'), isNotNull);
    });

    test(
      'byJobId matches a set id and is null for records without one',
      () async {
        await store.put(_job('0x1'));
        await store.put(_job('0x2', jobId: 'job-7'));

        expect(store.byJobId('job-7')!.burnTxHash, '0x2');
        expect(store.byJobId('job-8'), isNull);
      },
    );
  });

  test('a value that is not a record is skipped, not thrown', () async {
    await store.put(_job('0x1'));
    await box.put('garbage', 'not json');
    await box.put('wrong-shape', '{"v":1}');

    expect(store.page(sdkAddress: _nodeA, limit: 5).jobs, hasLength(1));
    expect(store.byIdempotencyKey('https://o', 'k'), isNotNull);
    expect(store.byJobId('x'), isNull);
  });
}
