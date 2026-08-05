import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/slippage_state.dart';

/// The rule the old drawer did not have.
///
/// `swap_settings_drawer.dart` applied any `double.tryParse` result with no
/// range at all. The two values that matter most are pinned first, because
/// they are the reason this file exists rather than a nice-to-have.
void main() {
  group('the two values the old drawer accepted', () {
    test('0 is refused — a zero tolerance rejects every swap', () {
      final s = slippageState('0');
      expect(s.level, SlippageLevel.error);
      expect(s.canApply, isFalse);
      expect(s.value, isNull);
    });

    test('900 is refused — that is accepting any price at all', () {
      final s = slippageState('900');
      expect(s.level, SlippageLevel.error);
      expect(s.canApply, isFalse);
    });
  });

  group('bounds', () {
    test('50 is the ceiling and is allowed', () {
      expect(slippageState('50').canApply, isTrue);
      expect(slippageState('50').level, SlippageLevel.warning); // >5
    });

    test('just over the ceiling is refused', () {
      expect(slippageState('50.01').level, SlippageLevel.error);
    });

    test('negatives are refused', () {
      expect(slippageState('-1').level, SlippageLevel.error);
    });

    test('the comfortable band confirms, and empty stays silent', () {
      // Was "the comfortable band is silent". Sketch 067-A draws a reassurance
      // line in the ok state and the drawer did not have one, so `ok` now
      // carries a message. Empty is the case that must NOT: it is the one
      // moment there is genuinely nothing to confirm, and it is what keeps the
      // panel from talking to someone who has only just cleared the field.
      for (final v in ['0.05', '0.1', '0.5', '1', '5']) {
        final s = slippageState(v);
        expect(s.level, SlippageLevel.ok, reason: '$v should be quiet');
        expect(s.message, isNotNull, reason: '$v should confirm itself');
      }
      expect(slippageState('').message, isNull);
      expect(slippageState(null).message, isNull);
    });
  });

  group('advice is advice — it warns but still applies', () {
    test('above 5% warns about front-running but is applied', () {
      final s = slippageState('6');
      expect(s.level, SlippageLevel.warning);
      expect(s.canApply, isTrue);
      expect(s.value, 6);
      expect(s.message, contains('front-running'));
    });

    test('below 0.05% warns about fills but is applied', () {
      final s = slippageState('0.01');
      expect(s.level, SlippageLevel.warning);
      expect(s.canApply, isTrue);
      expect(s.value, 0.01);
    });
  });

  group('input shape', () {
    test('a comma is read as a decimal separator', () {
      // A European keyboard's decimal key emits ','. Without this the value
      // silently became "no amount".
      expect(slippageState('1,5').value, 1.5);
      expect(slippageState('1,5').level, SlippageLevel.ok);
    });

    test('surrounding whitespace is tolerated', () {
      expect(slippageState('  0.5  ').value, 0.5);
    });

    test('letters are refused', () {
      expect(slippageState('abc').level, SlippageLevel.error);
      expect(slippageState('0.5x').level, SlippageLevel.error);
    });

    test('empty is neutral — not an error, but nothing to apply', () {
      for (final v in ['', '   ', null]) {
        final s = slippageState(v);
        expect(s.level, SlippageLevel.ok, reason: 'empty must not shout');
        expect(s.message, isNull);
        expect(s.canApply, isFalse, reason: 'but there is nothing to apply');
      }
    });
  });

  group('presets', () {
    test('every preset is a value the validator accepts silently', () {
      // A preset the rule then refuses or warns about would be a contradiction
      // built into the UI.
      for (final p in kSlippagePresets) {
        final s = slippageState(p.toString());
        expect(s.level, SlippageLevel.ok, reason: '$p is offered as safe');
        expect(s.canApply, isTrue);
        expect(s.value, p);
      }
    });
  });
}
