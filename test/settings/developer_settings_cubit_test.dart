import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/settings/developer_mode.dart';
import 'package:genius_wallet/settings/developer_settings_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

void main() {
  late Box box;
  late List<SgnsNet> writes;
  late DeveloperSettingsCubit cubit;

  setUp(() async {
    box = await Hive.openBox(preferencesBoxName, bytes: Uint8List(0));
    writes = [];
    cubit = DeveloperSettingsCubit(
      readNet: () async => SgnsNet.test,
      writeNet: (net) async {
        writes.add(net);
        return true;
      },
    );
  });

  tearDown(() async {
    await cubit.close();
    DeveloperMode.instance.value = false;
    if (box.isOpen) {
      await box.close();
    }
  });

  test('selectNet persists through the injected writer', () async {
    await cubit.selectNet(SgnsNet.main);

    expect(writes, [SgnsNet.main]);
    expect(cubit.state.net, SgnsNet.main);
    expect(cubit.state.netStatus, contains('Saved'));
  });

  test('turning Developer mode off resets the SDK net to dev', () async {
    await cubit.load();
    await DeveloperMode.instance.setEnabled(true);

    final turnedOff = await cubit.setDeveloperMode(false);

    expect(turnedOff, isTrue);
    expect(writes, [SgnsNet.dev]);
    expect(cubit.state.net, SgnsNet.dev);
    expect(cubit.state.busy, isFalse);
    expect(DeveloperMode.isOn, isFalse);
  });

  test('a failed persist leaves Developer mode unchanged', () async {
    await box.close();

    final turnedOff = await cubit.setDeveloperMode(true);

    expect(turnedOff, isFalse);
    expect(DeveloperMode.isOn, isFalse);
    expect(cubit.state.status, startsWith('Error:'));
    expect(cubit.state.busy, isFalse);
  });

  test('off then on before the write lands keeps the net', () async {
    await DeveloperMode.instance.setEnabled(true);

    final off = cubit.setDeveloperMode(false);
    final on = cubit.setDeveloperMode(true);

    expect(await off, isFalse);
    expect(await on, isFalse);
    expect(writes, isEmpty);
    expect(DeveloperMode.isOn, isTrue);
    expect(box.get(developerModeKey), isTrue);
  });
}
