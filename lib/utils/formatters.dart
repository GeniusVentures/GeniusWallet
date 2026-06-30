import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final allowDecimals =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+(\.\d*)?'));

  static final allowIntegers =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+'));
}

/// Amount-field formatter: allows only digits and a single decimal separator
/// ('.' or ',' — the redesign accepts a decimal comma). Blocks letters,
/// spaces, symbols and a SECOND separator, so ambiguous grouped input like
/// "1.000,50" can't be entered. (A lone grouping comma — "1,000" — is still
/// read as a decimal by double.tryParse after comma→dot, an under-send not an
/// over-send; full locale-aware grouping is WIRE-4 in WIRING.md.)
class SingleDecimalSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;
    if (RegExp(r'[^0-9.,]').hasMatch(text)) return oldValue; // letters/symbols
    if (RegExp(r'[.,]').allMatches(text).length > 1) return oldValue; // 2nd sep
    return newValue;
  }
}

final DateFormat dateFormatter = DateFormat.yMEd().add_jms();
