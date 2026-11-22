// Two copies of the app must not open Hive at the same time: a double launch
// races the per-box `.lock` checks and can truncate a box under the winner.
// The app lock decides, so its contention semantics are pinned here; the
// double-launch proof runs on the real app, not in this harness. The second
// copy is a separate process on purpose: fcntl locks never conflict inside
// one process, so a second in-process acquire cannot simulate a launch.
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/init.dart';

void main() {
  late Directory dir;
  setUp(() async {
    dir = await Directory.systemTemp.createTemp('gw-single-instance');
  });
  tearDown(() async {
    // The holder's fd may still be open on the lock file; a failed cleanup
    // of a temp dir is not the test's subject.
    try {
      await dir.delete(recursive: true);
    } on FileSystemException {
      // best effort
    }
  });

  test('the first copy takes the lock and the lock file exists', () async {
    expect(await acquireSingleInstanceLock(dir: dir), isTrue);
    expect(
      File('${dir.path}/genius_wallet.instance.lock').existsSync(),
      isTrue,
    );
    // The fd must be retained for the process lifetime, or the lock could
    // be finalized away while the app still runs.
    expect(heldInstanceLock, isNotNull);
  });

  test('a copy starting while another holds the lock is refused', () async {
    final probe = await Process.run('python3', ['--version']);
    if (probe.exitCode != 0) {
      throw StateError('python3 is required to simulate the second copy');
    }
    final holder = await Process.start('python3', [
      '-c',
      'import fcntl,sys,time;'
          'f=open(sys.argv[1],"a");'
          'fcntl.lockf(f,fcntl.LOCK_EX|fcntl.LOCK_NB);'
          'print("held",flush=True);'
          'time.sleep(15)',
      '${dir.path}/genius_wallet.instance.lock',
    ]);
    addTearDown(holder.kill);
    final ready = await holder.stdout
        .map(utf8.decode)
        .first
        .timeout(const Duration(seconds: 10));
    expect(ready, contains('held'));

    expect(await acquireSingleInstanceLock(dir: dir), isFalse);

    // Once the holder is gone the next start succeeds: a dead copy never
    // blocks the app behind a stale lock.
    holder.kill();
    await holder.exitCode.timeout(const Duration(seconds: 10));
    expect(await acquireSingleInstanceLock(dir: dir), isTrue);
  });

  test('copies on different data folders do not block each other', () async {
    final other = await Directory.systemTemp.createTemp('gw-single-instance-b');
    addTearDown(() async {
      try {
        await other.delete(recursive: true);
      } on FileSystemException {
        // best effort
      }
    });
    expect(await acquireSingleInstanceLock(dir: dir), isTrue);
    expect(await acquireSingleInstanceLock(dir: other), isTrue);
  });
}
