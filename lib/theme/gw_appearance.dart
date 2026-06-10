import 'package:flutter/foundation.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum GWAppearanceMode { dark, light }

/// App-wide appearance: dark = black canvas, light = white canvas.
///
/// The neutral colour tokens in `GeniusWalletColors` / `GWDecorations` read
/// this singleton, and `main.dart` rebuilds `MaterialApp` whenever it changes,
/// so toggling re-skins the whole app live. Persisted in the `preferences`
/// Hive box; toggled from the Preferences sheet (Appearance row).
class GWAppearance extends ValueNotifier<GWAppearanceMode> {
  GWAppearance._() : super(GWAppearanceMode.dark);

  static final GWAppearance instance = GWAppearance._();

  static bool get isLight => instance.value == GWAppearanceMode.light;

  /// Restore the persisted mode. Call once after Hive init.
  void load() {
    final saved =
        Hive.box(preferencesBoxName).get(appearanceModeKey) as String?;
    if (saved == 'light') value = GWAppearanceMode.light;
  }

  Future<void> setMode(GWAppearanceMode mode) async {
    if (value == mode) return;
    value = mode;
    await Hive.box(preferencesBoxName).put(
      appearanceModeKey,
      mode == GWAppearanceMode.light ? 'light' : 'dark',
    );
  }
}
