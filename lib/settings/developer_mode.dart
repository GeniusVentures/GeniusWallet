import 'package:flutter/foundation.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

/// Whether the SDK diagnostics, the SDK network choice and EVM testnets are
/// shown. Off on a fresh install; persisted in the preferences box.
class DeveloperMode extends ValueNotifier<bool> {
  DeveloperMode._() : super(false);

  static final DeveloperMode instance = DeveloperMode._();

  static bool get isOn => instance.value;

  /// Restore the persisted value. Call once after Hive init.
  void load() {
    value = Hive.box(preferencesBoxName).get(developerModeKey) == true;
  }

  Future<void> setEnabled(bool enabled) async {
    if (enabled == value) {
      return;
    }
    value = enabled;
    await Hive.box(preferencesBoxName).put(developerModeKey, enabled);
  }
}
