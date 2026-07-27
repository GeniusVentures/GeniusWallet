/// Slippage validation, as a pure function.
///
/// Lives beside `swap_cta_state.dart` for the same reason that file exists: the
/// rule is worth reading and testing without a widget tree around it.
///
/// The drawer this replaces (`swap_settings_drawer.dart`) accepted **any**
/// `double.tryParse` result and had no range at all. Two values it let through:
///
/// * `0` — a zero tolerance rejects every swap, so the setting silently broke
///   the feature it configures.
/// * `900` — the user accepts any price the router returns. That is the
///   textbook MEV sandwich, entered through a settings field with no warning.
///
/// Bounds are from sketch 041, re-confirmed in 063: `0 < x <= 50`, with advice
/// (not refusal) above 5% and below 0.05%.
library;

enum SlippageLevel {
  /// Inside the comfortable band — nothing to say.
  ok,

  /// Accepted, but worth a word. Still applies.
  warning,

  /// Refused. The CTA must not apply this value.
  error,
}

class SlippageState {
  const SlippageState._(this.level, this.message, this.value);

  final SlippageLevel level;

  /// Null when there is nothing to say — never an empty string, so callers can
  /// branch on null instead of on `isEmpty`.
  final String? message;

  /// The parsed value, or null when it must not be applied. Note this is null
  /// for an EMPTY field too: empty is not an error to shout about while the
  /// user is still typing, but there is also nothing to apply.
  final double? value;

  /// Whether the Apply action may run.
  bool get canApply => value != null;

  /// Whether to paint the refusal treatment. Empty is not "wrong".
  bool get isError => level == SlippageLevel.error;
}

/// The comfortable band's upper edge — above this, front-running gets cheap.
const double kSlippageWarnAbove = 5.0;

/// Below this, the swap routinely fails to fill.
const double kSlippageWarnBelow = 0.05;

/// Hard ceiling. Anything above is refused outright.
const double kSlippageMax = 50.0;

/// The presets offered as the primary path. A person setting slippage is
/// choosing a posture, not tuning a number — the field is the escape hatch.
const List<double> kSlippagePresets = [0.1, 0.5, 1.0];

SlippageState slippageState(String? raw) {
  final text = (raw ?? '').trim().replaceAll(',', '.');

  // Empty is neutral, not wrong. Shouting at a field the user has only just
  // cleared teaches them to ignore the message that matters.
  if (text.isEmpty) {
    return const SlippageState._(SlippageLevel.ok, null, null);
  }

  final n = double.tryParse(text);
  if (n == null || n.isNaN || n.isInfinite) {
    return const SlippageState._(SlippageLevel.error, 'Enter a number.', null);
  }
  if (n <= 0) {
    return const SlippageState._(
      SlippageLevel.error,
      'Must be above 0 — a 0% tolerance rejects every swap.',
      null,
    );
  }
  if (n > kSlippageMax) {
    return SlippageState._(
      SlippageLevel.error,
      'Maximum is ${kSlippageMax.toStringAsFixed(0)}%.',
      null,
    );
  }
  if (n > kSlippageWarnAbove) {
    return SlippageState._(
      SlippageLevel.warning,
      'High — you may lose value to front-running.',
      n,
    );
  }
  if (n < kSlippageWarnBelow) {
    return SlippageState._(
      SlippageLevel.warning,
      'Very low — the swap will often fail to fill.',
      n,
    );
  }
  return SlippageState._(SlippageLevel.ok, null, n);
}
