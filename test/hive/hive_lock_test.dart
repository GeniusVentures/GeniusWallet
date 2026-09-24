import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/init.dart';

void main() {
  test('only a lock conflict on a box .lock file counts as a held lock', () {
    FileSystemException onPath(String path, int code) =>
        FileSystemException('failed', path, OSError('os', code));

    // Windows ERROR_LOCK_VIOLATION, as a real second instance reports it.
    expect(isHiveLockHeld(onPath('/d/wallet.lock', 33)), isTrue);
    // Linux EAGAIN.
    expect(isHiveLockHeld(onPath('/d/wallet.lock', 11)), isTrue);
    // Access denied on the lock file is a permissions problem, not a peer.
    expect(isHiveLockHeld(onPath('/d/wallet.lock', 5)), isFalse);
    // No space left on device.
    expect(isHiveLockHeld(onPath('/d/wallet.lock', 28)), isFalse);
    expect(isHiveLockHeld(onPath('/d/wallet.hive', 33)), isFalse);
    expect(isHiveLockHeld(const FileSystemException('no path')), isFalse);
  });
}
