import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/utils/formatters.dart';

/// Guards the amount field shared by Swap and Bridge.
///
/// The two screens are twins (D-11), and until this formatter moved out of
/// `bridge_screen.dart` only one of them refused letters. These cases pin both
/// the behaviour the bridge already had and the two the shared version adds,
/// so a future edit cannot quietly take either back.
void main() {
  /// Simulates typing/pasting [next] over [previous].
  String apply(
    DecimalTextInputFormatter formatter,
    String previous,
    String next,
  ) => formatter
      .formatEditUpdate(
        TextEditingValue(
          text: previous,
          selection: TextSelection.collapsed(offset: previous.length),
        ),
        TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        ),
      )
      .text;

  group('shape', () {
    final f = DecimalTextInputFormatter();

    test('accepts digits', () {
      expect(apply(f, '1', '12'), '12');
    });

    test('accepts one decimal separator', () {
      expect(apply(f, '1', '1.'), '1.');
      expect(apply(f, '1.', '1.5'), '1.5');
    });

    test('accepts a leading separator — people type ".5"', () {
      expect(apply(f, '', '.'), '.');
      expect(apply(f, '.', '.5'), '.5');
    });

    test('rejects letters, keeping what was already there', () {
      expect(apply(f, '1.5', '1.5a'), '1.5');
      expect(apply(f, '', 'abc'), '');
    });

    test('rejects a second separator', () {
      expect(apply(f, '1.5', '1.5.'), '1.5');
    });

    test('rejects a minus sign — there is no negative amount', () {
      expect(apply(f, '', '-'), '');
      expect(apply(f, '1', '-1'), '1');
    });

    test('rejects whitespace', () {
      expect(apply(f, '1', '1 '), '1');
    });

    test('allows clearing the field', () {
      expect(apply(f, '1.5', ''), '');
    });
  });

  group('comma becomes a dot', () {
    // Every reader downstream calls double.tryParse, which returns null for
    // "1,5" — the field looked filled while the quote saw no amount.
    final f = DecimalTextInputFormatter();

    test('a typed comma is accepted as a separator', () {
      expect(apply(f, '1', '1,'), '1.');
      expect(apply(f, '1,', '1,5'), '1.5');
    });

    test('the result actually parses', () {
      expect(double.tryParse(apply(f, '1', '1,5')), 1.5);
    });

    test('a comma after an existing dot is still a second separator', () {
      expect(apply(f, '1.5', '1.5,'), '1.5');
    });
  });

  group('decimalRange', () {
    test('caps digits after the separator', () {
      final f = DecimalTextInputFormatter(decimalRange: 2);
      expect(apply(f, '1.2', '1.23'), '1.23');
      expect(apply(f, '1.23', '1.234'), '1.23');
    });

    test('does not limit digits before the separator', () {
      final f = DecimalTextInputFormatter(decimalRange: 2);
      expect(apply(f, '123456', '1234567'), '1234567');
    });

    test('zero means integers only', () {
      final f = DecimalTextInputFormatter(decimalRange: 0);
      expect(apply(f, '1', '12'), '12');
      expect(apply(f, '1', '1.'), '1');
    });

    test('null is unlimited — the bridge call site is unchanged', () {
      final f = DecimalTextInputFormatter();
      expect(apply(f, '1.12345678', '1.123456789'), '1.123456789');
    });

    test('a comma is capped the same as a dot', () {
      final f = DecimalTextInputFormatter(decimalRange: 2);
      expect(apply(f, '1.23', '1,234'), '1.23');
    });
  });
}
