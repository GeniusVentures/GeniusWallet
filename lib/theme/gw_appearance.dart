import 'package:flutter/widgets.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

enum GWAppearanceMode { dark, light }

/// What the user asked for, as distinct from [GWAppearanceMode] (what is
/// painted right now): `system` resolves against the OS brightness.
enum GWAppearancePreference { system, light, dark }

/// App-wide appearance: dark = black canvas, light = white canvas. Read via
/// `GeniusWalletColors`/`GWDecorations`; set from the Settings screen's
/// Appearance control, which resolves `system` against OS brightness.
class GWAppearance extends ValueNotifier<GWAppearanceMode>
    with WidgetsBindingObserver {
  GWAppearance._() : super(GWAppearanceMode.dark);

  static final GWAppearance instance = GWAppearance._();

  static bool get isLight => instance.value == GWAppearanceMode.light;

  GWAppearancePreference _preference = GWAppearancePreference.system;
  bool _observing = false;

  GWAppearancePreference get preference => _preference;

  GWAppearanceMode _resolve() {
    switch (_preference) {
      case GWAppearancePreference.system:
        final osBrightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return osBrightness == Brightness.light
            ? GWAppearanceMode.light
            : GWAppearanceMode.dark;
      case GWAppearancePreference.light:
        return GWAppearanceMode.light;
      case GWAppearancePreference.dark:
        return GWAppearanceMode.dark;
    }
  }

  /// Restore the persisted preference. Call once after Hive init.
  ///
  /// On a genuine first launch (no persisted value yet) this follows the OS
  /// light/dark setting (D-03) rather than defaulting to dark unconditionally.
  void load() {
    final saved =
        Hive.box(preferencesBoxName).get(appearanceModeKey) as String?;
    if (saved == 'light') {
      _preference = GWAppearancePreference.light;
    } else if (saved == 'dark') {
      _preference = GWAppearancePreference.dark;
    } else {
      // No persisted preference, or an unrecognised/'system' value: follow
      // the OS setting.
      _preference = GWAppearancePreference.system;
    }
    value = _resolve();
    if (!_observing) {
      WidgetsBinding.instance.addObserver(this);
      _observing = true;
    }
  }

  /// Re-resolves on an OS brightness flip, but only while following it.
  @override
  void didChangePlatformBrightness() {
    if (_preference != GWAppearancePreference.system) {
      return;
    }
    value = _resolve();
  }

  @override
  void dispose() {
    if (_observing) {
      WidgetsBinding.instance.removeObserver(this);
      _observing = false;
    }
    super.dispose();
  }

  Future<void> setPreference(GWAppearancePreference pref) async {
    if (pref == _preference) {
      return;
    }
    _preference = pref;
    await Hive.box(preferencesBoxName).put(appearanceModeKey, pref.name);
    final resolved = _resolve();
    if (value == resolved) {
      // The resolved mode didn't change (e.g. light -> system on a light
      // OS), but the preference itself did, so listeners still need to know.
      notifyListeners();
    } else {
      value = resolved;
    }
  }

  Future<void> setMode(GWAppearanceMode mode) async {
    await setPreference(
      mode == GWAppearanceMode.light
          ? GWAppearancePreference.light
          : GWAppearancePreference.dark,
    );
  }
}
