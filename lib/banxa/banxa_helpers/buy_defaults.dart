import 'package:intl/intl.dart';

/// The fiat the Buy form opens on: the device locale's currency if Banxa
/// offers it, else USD, else whatever Banxa lists first.
String defaultFiatCode(String localeName, List<String> offered) {
  String? local;
  try {
    local = NumberFormat.simpleCurrency(locale: localeName).currencyName;
  } catch (_) {
    local = null;
  }
  if (local != null && offered.contains(local)) {
    return local;
  }
  if (offered.contains('USD') || offered.isEmpty) {
    return 'USD';
  }
  return offered.first;
}

const List<double> _steps = [1, 2, 2.5, 5, 10];

num _roundUp(double x) {
  var e = 1.0;
  while (e * 10 <= x) {
    e *= 10;
  }
  while (e > x) {
    e /= 10;
  }
  final f = x / e;
  final step = _steps.firstWhere((s) => s >= f - 1e-9);
  final v = step * e;
  return v == v.roundToDouble() ? v.round() : v;
}

/// Quick-pick amounts that scale from the payment method's minimum, so every
/// currency gets sensible chips without a hand-tuned table.
List<num> presetAmounts({required num min, required num max}) {
  final base = min > 0 ? min.toDouble() : 20.0;
  final out = <num>{
    for (final m in [2.5, 5, 12.5, 25]) _roundUp(base * m),
  }.toList();
  return max > 0 ? out.where((v) => v <= max).toList() : out;
}
