import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class Formatters {
  static final allowDecimals = FilteringTextInputFormatter.allow(
    RegExp(r'^\d+(\.\d*)?'),
  );

  static final allowIntegers = FilteringTextInputFormatter.allow(
    RegExp(r'^\d+'),
  );
}

/// Keeps an amount field numeric: digits and at most one decimal separator.
///
/// Moved here from `bridge_screen.dart`, where it already guarded the bridge's
/// amount field. Swap — the bridge's twin — had no formatter at all, so the
/// same field accepted letters on one screen and refused them on the other.
/// A shared control belongs next to [Formatters], not inside a screen.
///
/// Two behaviours the bridge's copy did not have:
///
/// * **A comma becomes a dot.** On a European keyboard the decimal key emits
///   `,`, and every reader downstream calls `double.tryParse`, which returns
///   null for `1,5`. The field looked filled and the quote silently treated it
///   as no amount.
/// * **[decimalRange] caps precision.** The old docstring claimed "limited
///   decimals" but the pattern allowed unlimited — a user could type more
///   precision than the token has, and the surplus is truncated on chain.
///   Null keeps the old unlimited behaviour, so the bridge's existing call
///   site is unchanged.
///
/// ponytail: rejects the whole edit when it would break the shape, rather than
/// repairing it. Ceiling: pasting `1.2.3` leaves the field untouched instead of
/// salvaging `1.23`. Upgrade path is a sanitising pass, but it has to rebuild
/// the cursor offset by hand — not worth it until someone actually pastes.
class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({this.decimalRange})
    : assert(decimalRange == null || decimalRange >= 0);

  /// Maximum digits after the separator. Null means no cap.
  final int? decimalRange;

  /// Digits, at most one dot, digits. A bare `.` is allowed through so the
  /// field is typeable in the order a person types it; `double.tryParse('.')`
  /// is null, which every reader already treats as "no amount".
  static final RegExp _shape = RegExp(r'^\d*\.?\d*$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Same length, so the incoming selection stays valid without adjustment.
    final text = newValue.text.replaceAll(',', '.');

    if (!_shape.hasMatch(text)) {
      return oldValue;
    }

    if (decimalRange != null) {
      final dot = text.indexOf('.');
      if (dot >= 0) {
        // A token with no decimals has no use for a separator. Allowing the
        // bare dot let the field reach "1." and stick — nothing may follow it,
        // and the trailing dot is noise `double.tryParse` happens to survive.
        if (decimalRange == 0) {
          return oldValue;
        }
        if (text.length - dot - 1 > decimalRange!) {
          return oldValue;
        }
      }
    }

    return text == newValue.text ? newValue : newValue.copyWith(text: text);
  }
}

final DateFormat dateFormatter = DateFormat.yMEd().add_jms();
