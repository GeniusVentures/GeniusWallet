import 'package:flutter/foundation.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GWCurrencyOption {
  const GWCurrencyOption(this.code, this.symbol, this.label);

  final String code;
  final String symbol;
  final String label;
}

const List<GWCurrencyOption> gwCurrencies = [
  GWCurrencyOption('USD', '\$', 'US Dollar'),
  GWCurrencyOption('EUR', '€', 'Euro'),
  GWCurrencyOption('GBP', '£', 'British Pound'),
  GWCurrencyOption('CHF', 'CHF ', 'Swiss Franc'),
  GWCurrencyOption('JPY', '¥', 'Japanese Yen'),
];

/// Display currency (Preferences ▸ Currency). Persisted in the `preferences`
/// Hive box; `main.dart` remounts the app when it changes.
///
/// Display-only for now: the chosen symbol is shown (e.g. on the home hero
/// balance) but values are NOT FX-converted — wiring real rates is a backend
/// follow-up (see HANDOFF.md §6).
///
/// WIRE-7 (see WIRING.md): add a USD->code rate source and convert every
/// displayed USD value (hero balance, asset rows, Buy amount) — not just the
/// symbol. `GWCurrency` carries only code/symbol/label today.
class GWCurrency extends ValueNotifier<String> {
  GWCurrency._() : super('USD');

  static final GWCurrency instance = GWCurrency._();

  static GWCurrencyOption get current => gwCurrencies.firstWhere(
        (c) => c.code == instance.value,
        orElse: () => gwCurrencies.first,
      );

  static String get symbol => current.symbol;

  /// Restore the persisted choice. Call once after Hive init.
  void load() {
    final saved = Hive.box(preferencesBoxName).get(currencyCodeKey) as String?;
    if (saved != null && gwCurrencies.any((c) => c.code == saved)) {
      value = saved;
    }
  }

  Future<void> setCode(String code) async {
    if (value == code) return;
    value = code;
    await Hive.box(preferencesBoxName).put(currencyCodeKey, code);
  }
}
