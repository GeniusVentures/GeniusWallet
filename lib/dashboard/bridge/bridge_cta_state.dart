/// The Bridge CTA's state ladder — pure Dart, no Flutter, no widget context.
///
/// `bridge_screen.dart` resolves ONE of these per rebuild via
/// [resolveBridgeCtaState] and drives its button purely from the result;
/// colour mapping stays in the screen (where `GWColors` is in scope), this
/// module only owns the precedence rule, the copy and the enabled/disabled
/// rule.
///
/// This deliberately does NOT reuse `swap_cta_state.dart`'s enum: bridge has
/// no route fetch and no Retry rung, and swap has no gas estimate — a shared
/// enum would have to carry rungs that are unreachable on one screen.
enum BridgeCtaState {
  /// The amount field is empty or unparseable.
  enterAmount,

  /// A valid amount exceeds the known balance, OR the balance is unknown
  /// (bridge's own precheck at `bridge_screen.dart:116-119` already treats
  /// `fromToken?.balance == null` this way — mirrored here, not swap's
  /// "never accuse on missing data" rule).
  insufficientBalance,

  /// A valid, affordable amount and the 300ms-debounced gas estimate is in
  /// flight (or has not yet been requested for the current amount).
  estimatingGas,

  /// The last gas estimate call failed.
  gasError,

  /// A valid, affordable amount and a settled gas estimate — the happy path.
  ready,

  /// The submit closure (`bridgeOut(...)`) is currently awaiting. Outranks
  /// every other rung.
  submitting,
}

/// Resolves the bridge CTA's state from the screen's raw inputs.
///
/// Precedence, top to bottom (08-04-PLAN.md Task 1 `<behavior>`):
/// `submitting` → `enterAmount` → `insufficientBalance` → `estimatingGas` →
/// `gasError` → `ready`.
BridgeCtaState resolveBridgeCtaState({
  required String amount,
  required double? balance,
  required bool isEstimating,
  required bool hasEstimate,
  required bool isError,
  required bool isSubmitting,
}) {
  // Submitting outranks everything — the closure is mid-flight.
  if (isSubmitting) {
    return BridgeCtaState.submitting;
  }

  final parsedAmount = double.tryParse(amount);
  if (amount.isEmpty || parsedAmount == null) {
    return BridgeCtaState.enterAmount;
  }

  // Bridge's own pre-check treats an unknown balance as insufficient (it
  // returns before any API call in that case too) — mirrored here.
  if (balance == null || parsedAmount > balance) {
    return BridgeCtaState.insufficientBalance;
  }

  if (isEstimating) {
    return BridgeCtaState.estimatingGas;
  }

  if (isError) {
    return BridgeCtaState.gasError;
  }

  if (hasEstimate) {
    return BridgeCtaState.ready;
  }

  // A valid, affordable amount with no estimate in flight, none failed and
  // none received yet (the pre-debounce window). Reads as still-estimating
  // rather than falsely enabling the CTA on stale/absent data.
  return BridgeCtaState.estimatingGas;
}

/// GNUS-denominated copy per 08-04-PLAN.md's `<behavior>` bullets.
/// [symbol] is interpolated only for [BridgeCtaState.insufficientBalance];
/// falls back to the symbol-less string when null or empty.
///
/// The ready rung's label is "Bridge" — develop's own word — NOT "Review
/// bridge", because no second confirmation step exists (D-02 discipline
/// extended to bridge).
String bridgeCtaLabel(BridgeCtaState state, {String? symbol}) {
  switch (state) {
    case BridgeCtaState.enterAmount:
      return 'Enter an amount';
    case BridgeCtaState.insufficientBalance:
      final hasSymbol = symbol != null && symbol.isNotEmpty;
      return hasSymbol
          ? 'Insufficient $symbol balance'
          : 'Insufficient balance';
    case BridgeCtaState.estimatingGas:
      return 'Estimating gas…';
    case BridgeCtaState.gasError:
      return "Couldn't estimate gas";
    case BridgeCtaState.ready:
      return 'Bridge';
    case BridgeCtaState.submitting:
      return 'Bridging…';
  }
}

/// True ONLY for [BridgeCtaState.ready] — every other rung is disabled.
bool bridgeCtaEnabled(BridgeCtaState state) => state == BridgeCtaState.ready;
