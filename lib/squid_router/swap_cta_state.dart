/// The Swap CTA's state ladder — pure Dart, no Flutter, no widget context.
///
/// `swap_screen.dart` resolves ONE of these per rebuild via
/// [resolveSwapCtaState] and drives its button purely from the result; colour
/// mapping stays in the screen (where `GWColors` is in scope), this module
/// only owns the precedence rule, the copy and the enabled/disabled rule.
enum SwapCtaState {
  /// No tokens selected, or the amount is empty/unparseable.
  enterAmount,

  /// A valid amount exceeds the selected pay token's known balance.
  insufficientBalance,

  /// A valid amount is set and a route fetch is in flight.
  findingRoute,

  /// A valid amount, a settled (non-error) state — the happy path.
  ready,

  /// The submit closure is currently awaiting. Outranks every other rung.
  submitting,

  /// The last route fetch failed (D-09). The button stays enabled as "Retry"
  /// — it is the FIELD that is in error, not the button.
  routeError,
}

/// Resolves the swap CTA's state from the screen's raw inputs.
///
/// Precedence, top to bottom (D-09 / UI-SPEC CTA ladder):
/// `submitting` → `enterAmount` (no tokens / no parseable amount) →
/// `routeError` → `insufficientBalance` → `findingRoute` → `ready`.
SwapCtaState resolveSwapCtaState({
  required bool hasBothTokens,
  required String fromAmount,
  required double? fromBalance,
  required bool isFetchingRoute,
  required bool hasRoute,
  required bool routeError,
  required bool isSubmitting,
}) {
  // Submitting outranks everything — the closure is mid-flight.
  if (isSubmitting) {
    return SwapCtaState.submitting;
  }

  final parsedAmount = double.tryParse(fromAmount);
  if (!hasBothTokens || fromAmount.isEmpty || parsedAmount == null) {
    return SwapCtaState.enterAmount;
  }

  // The field is in error, not the button — surfaces as an enabled Retry.
  if (routeError) {
    return SwapCtaState.routeError;
  }

  // Never accuse the user on missing balance data (fromBalance == null).
  if (fromBalance != null && parsedAmount > fromBalance) {
    return SwapCtaState.insufficientBalance;
  }

  if (isFetchingRoute) {
    return SwapCtaState.findingRoute;
  }

  return SwapCtaState.ready;
}

/// The UI-SPEC Copywriting Contract's six swap CTA strings, verbatim.
///
/// [symbol] is interpolated only for [SwapCtaState.insufficientBalance];
/// falls back to the symbol-less string when null or empty.
String swapCtaLabel(SwapCtaState state, {String? symbol}) {
  switch (state) {
    case SwapCtaState.enterAmount:
      return 'Enter an amount';
    case SwapCtaState.insufficientBalance:
      final hasSymbol = symbol != null && symbol.isNotEmpty;
      return hasSymbol
          ? 'Insufficient $symbol balance'
          : 'Insufficient balance';
    case SwapCtaState.findingRoute:
      return 'Finding best route…';
    case SwapCtaState.ready:
      return 'Swap';
    case SwapCtaState.submitting:
      return 'Submitting swap…';
    case SwapCtaState.routeError:
      return 'Retry';
  }
}

/// True only for the two rungs the user can actually tap: the happy path and
/// the Retry that follows a failed route fetch (D-09).
bool swapCtaEnabled(SwapCtaState state) =>
    state == SwapCtaState.ready || state == SwapCtaState.routeError;
