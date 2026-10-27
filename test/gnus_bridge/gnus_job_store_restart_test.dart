import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_ce/hive.dart';

// Plain test() on a real temp dir: real Hive disk I/O inside testWidgets never
// completes in the fake-async zone.
void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('gw_gnus_jobs');
    Hive.init(dir.path);
  });

  tearDown(() async {
    await Hive.deleteBoxFromDisk(gnusJobsBoxName);
    await Hive.close();
    await dir.delete(recursive: true);
  });

  test('a record survives Hive.close and a reopen with every field', () async {
    final job = GnusJob(
      jobId: null,
      burnTxHash: '0xAbC',
      sdkAddress: '0x${'a' * 128}',
      origin: 'https://dash.example',
      idempotencyKey: 'key-1',
      submittedAt: DateTime.utc(2026, 10, 27, 12, 30, 15, 123, 456),
      cost: '1234000000000000000000',
      status: GnusJobStatus.bridgedNotProcessed,
      bodyHash: 'deadbeef',
    );
    final a = GnusJobStore(await Hive.openBox<String>(gnusJobsBoxName));
    await a.put(job);

    await Hive.close();
    Hive.init(dir.path);
    final b = GnusJobStore(await Hive.openBox<String>(gnusJobsBoxName));

    for (final found in [
      b.byBurnHash('0xabc'),
      b.page(sdkAddress: job.sdkAddress, limit: 5).jobs.single,
      b.byIdempotencyKey(job.origin, job.idempotencyKey),
    ]) {
      expect(found, isNotNull);
      expect(found!.toContract(), job.toContract());
      expect(found.bodyHash, job.bodyHash);
      expect(found.submittedAt, job.submittedAt);
    }
  });
}
