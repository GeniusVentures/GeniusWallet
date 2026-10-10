import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/settings/developer_mode.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() {
  late Box box;

  setUp(() async {
    // Empty bytes select hive_ce's in-memory backend: no disk I/O.
    box = await Hive.openBox(preferencesBoxName, bytes: Uint8List(0));
  });

  tearDown(() async {
    DeveloperMode.instance.value = false;
    await box.close();
  });

  test('no persisted key loads as off', () {
    DeveloperMode.instance.value = true;

    DeveloperMode.instance.load();

    expect(DeveloperMode.isOn, isFalse);
  });

  test('setEnabled(true) persists and a later load reads it back', () async {
    await DeveloperMode.instance.setEnabled(true);
    expect(box.get(developerModeKey), isTrue);

    DeveloperMode.instance.value = false;
    DeveloperMode.instance.load();

    expect(DeveloperMode.isOn, isTrue);
  });
}
