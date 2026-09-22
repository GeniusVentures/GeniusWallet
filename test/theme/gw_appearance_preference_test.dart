// `Hive.openBox(name, bytes: Uint8List(0))` selects hive_ce's in-memory
// `StorageBackendMemory`, so box writes are ordinary Futures with no real
// disk I/O to hang a test.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Opens a fresh in-memory `preferences` box, runs [body], then resets the
/// shared [GWAppearance.instance] to its dark default, clears the test OS
/// brightness override, and closes the box.
Future<void> _withPreferencesBox(
  WidgetTester tester,
  Future<void> Function(Box box) body,
) async {
  final box = await Hive.openBox(preferencesBoxName, bytes: Uint8List(0));
  try {
    await body(box);
  } finally {
    await GWAppearance.instance.setPreference(GWAppearancePreference.dark);
    tester.binding.platformDispatcher.clearPlatformBrightnessTestValue();
    await box.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a persisted light preference still loads as light', (
    tester,
  ) async {
    await _withPreferencesBox(tester, (box) async {
      await box.put(appearanceModeKey, 'light');

      GWAppearance.instance.load();

      expect(GWAppearance.instance.preference, GWAppearancePreference.light);
    });
  });

  testWidgets(
    'no persisted key loads as system and resolves to OS brightness',
    (tester) async {
      await _withPreferencesBox(tester, (box) async {
        tester.binding.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;

        GWAppearance.instance.load();

        expect(GWAppearance.instance.preference, GWAppearancePreference.system);
        expect(GWAppearance.instance.value, GWAppearanceMode.light);
      });
    },
  );

  testWidgets(
    'setPreference writes dark/system, and a later load reads each back',
    (tester) async {
      await _withPreferencesBox(tester, (box) async {
        // The tearDown default already leaves the singleton on `dark`, so
        // move off it first — otherwise the very first `setPreference` below
        // would be a same-value no-op and never write.
        await GWAppearance.instance.setPreference(GWAppearancePreference.light);

        await GWAppearance.instance.setPreference(GWAppearancePreference.dark);
        expect(box.get(appearanceModeKey), 'dark');
        GWAppearance.instance.load();
        expect(GWAppearance.instance.preference, GWAppearancePreference.dark);

        await GWAppearance.instance.setPreference(
          GWAppearancePreference.system,
        );
        expect(box.get(appearanceModeKey), 'system');
        GWAppearance.instance.load();
        expect(GWAppearance.instance.preference, GWAppearancePreference.system);
      });
    },
  );

  testWidgets(
    'preference system: an OS brightness flip changes value with no reload',
    (tester) async {
      await _withPreferencesBox(tester, (box) async {
        tester.binding.platformDispatcher.platformBrightnessTestValue =
            Brightness.dark;
        GWAppearance.instance.load();
        expect(GWAppearance.instance.value, GWAppearanceMode.dark);

        tester.binding.platformDispatcher.platformBrightnessTestValue =
            Brightness.light;

        expect(GWAppearance.instance.value, GWAppearanceMode.light);
      });
    },
  );

  testWidgets('preference light: the same OS flip leaves value alone', (
    tester,
  ) async {
    await _withPreferencesBox(tester, (box) async {
      await box.put(appearanceModeKey, 'light');
      GWAppearance.instance.load();
      expect(GWAppearance.instance.value, GWAppearanceMode.light);

      tester.binding.platformDispatcher.platformBrightnessTestValue =
          Brightness.dark;

      expect(GWAppearance.instance.value, GWAppearanceMode.light);
    });
  });
}
