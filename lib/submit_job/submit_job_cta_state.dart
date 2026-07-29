import 'dart:math' show pow;

/// The Submit Job CTA's purchase ladder - pure Dart, no Flutter, no widget
/// context.
///
/// Modelled on `lib/dashboard/bridge/bridge_cta_state.dart`: an enum, a
/// resolver, a label function and an enabled predicate, with the precedence
/// rule documented here rather than scattered across the screen.
///
/// Two separate bugs lived in the single boolean this replaces
/// (`submit_job_screen.dart:65`, `jobCost != 0 && jobCost < gnusBalance`):
/// strictly-less refused a user holding *exactly* the job cost, and folding
/// the zero-cost case into the same flag rendered "you do not have enough
/// GNUS" at a user whose job simply has not been priced yet. Separate rungs
/// fix the second; the `<=` comparison boundary fixes the first.
///
/// **The house already has the correct boundary one directory over.**
/// `bridge_cta_state.dart:62` uses a strict greater-than so that an
/// exactly-affordable amount passes, pinned by a named test at
/// `test/dashboard/bridge/bridge_cta_state_test.dart:59-69`
/// ("amount 1, balance 1 (exactly affordable) -> NOT insufficient").
/// Submit-job was the outlier here, not the norm.
enum SubmitJobCtaState {
  /// The submit closure (`bridgeTokens()`) is currently awaiting. Outranks
  /// every other rung.
  submitting,

  /// No job file has been chosen yet.
  noFileChosen,

  /// A file is chosen, but its cost has not been priced yet (`jobCost` is
  /// still `0`) and nothing on the cost channel has failed. Never reads as
  /// insufficient funds - a job that hasn't been priced is not an
  /// accusation.
  costUnknown,

  /// The cost channel (`SubmitJobState.costError`) carries a failure -
  /// balance fetch, token-info fetch, cost lookup, a missing precondition,
  /// or a failed gas estimate.
  costError,

  /// A known, non-zero cost exceeds the known balance.
  insufficientFunds,

  /// A known, non-zero cost is affordable (`cost <= balance`). The only
  /// rung that enables the CTA.
  ready,
}

/// Rounds [value] to [decimals] decimal places.
///
/// ponytail: a fixed-precision compare on a value the SDK produces, not a
/// comparison in the token's smallest unit. A balance arriving as, say,
/// `9.999999999` a hair below a whole number because of a wei-to-GNUS
/// conversion would otherwise refuse a user who has exactly enough.
/// Upgrade path: compare in the token's smallest unit (the SDK's integer
/// wei/minion amount) once that value is threaded through to this module.
double _roundToPrecision(num value, int decimals) {
  final factor = pow(10, decimals);
  return (value * factor).round() / factor;
}

/// Resolves the Submit Job CTA's state from the cubit's raw inputs.
///
/// Precedence, top to bottom: `submitting` -> `noFileChosen` ->
/// `costUnknown` -> `costError` -> `insufficientFunds` -> `ready`.
SubmitJobCtaState resolveSubmitJobCtaState({
  required bool isSubmitting,
  required bool hasFileChosen,
  required int jobCost,
  required double gnusBalance,
  required String costError,
}) {
  // Submitting outranks everything - the closure is mid-flight.
  if (isSubmitting) {
    return SubmitJobCtaState.submitting;
  }

  if (!hasFileChosen) {
    return SubmitJobCtaState.noFileChosen;
  }

  // A cost of zero means "not priced yet", never "free" and never
  // "unaffordable" - checked before costError so an in-flight/never-run
  // lookup never gets mistaken for a hard failure.
  if (jobCost == 0) {
    return SubmitJobCtaState.costUnknown;
  }

  if (costError.isNotEmpty) {
    return SubmitJobCtaState.costError;
  }

  final roundedCost = _roundToPrecision(jobCost, 4);
  final roundedBalance = _roundToPrecision(gnusBalance, 4);

  if (roundedCost > roundedBalance) {
    return SubmitJobCtaState.insufficientFunds;
  }

  return SubmitJobCtaState.ready;
}

/// GNUS-denominated shortfall for [SubmitJobCtaState.insufficientFunds] -
/// the amount still needed, as a plain number the UI prints rather than the
/// word "insufficient". Meaningless (and `0`) for every other rung.
double submitJobShortfall({required int jobCost, required double gnusBalance}) {
  final shortfall = jobCost - gnusBalance;
  return shortfall > 0 ? shortfall : 0;
}

/// Copy per rung. [shortfall] is interpolated only for
/// [SubmitJobCtaState.insufficientFunds] (see [submitJobShortfall]).
String submitJobCtaLabel(SubmitJobCtaState state, {double shortfall = 0}) {
  switch (state) {
    case SubmitJobCtaState.submitting:
      return 'Submitting…';
    case SubmitJobCtaState.noFileChosen:
      return 'Choose a job file';
    case SubmitJobCtaState.costUnknown:
      return 'Pricing job…';
    case SubmitJobCtaState.costError:
      return "Couldn't price job";
    case SubmitJobCtaState.insufficientFunds:
      return 'Insufficient GNUS - need ${shortfall.toStringAsFixed(2)} more';
    case SubmitJobCtaState.ready:
      return 'Purchase';
  }
}

/// True ONLY for [SubmitJobCtaState.ready] - every other rung is disabled.
bool submitJobCtaEnabled(SubmitJobCtaState state) =>
    state == SubmitJobCtaState.ready;
