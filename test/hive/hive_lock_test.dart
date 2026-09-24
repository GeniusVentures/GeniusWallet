import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/init.dart';

void main() {
  test('only a failure on a box .lock file counts as a held lock', () {
    const held = FileSystemException('lock failed', '/d/wallet.lock');
    const corrupt = FileSystemException('read failed', '/d/wallet.hive');
    const noPath = FileSystemException('no path');

    expect(isHiveLockHeld(held), isTrue);
    expect(isHiveLockHeld(corrupt), isFalse);
    expect(isHiveLockHeld(noPath), isFalse);
  });
}
