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
/// `costError` -> `costUnknown` -> `insufficientFunds` -> `ready`.
///
/// **Reversed 2026-07-31, deliberately - do not "fix" this back.**
/// `costError` now outranks `costUnknown`. Before this date,
/// `SubmitJobCubit.openFilePicker` discarded the picked file on a pricing
/// failure, so a zero `jobCost` paired with a set `costError` could not
/// happen in practice and the order didn't matter. Once that discard was
/// removed (submit_job_cubit.dart, 1a), a pricing failure leaves `jobCost`
/// at `0` AND sets `costError` in the same emit - the old order would read
/// that state as `costUnknown` forever, showing a permanent "Working out
/// what this job costs" spinner over a job whose pricing has already
/// definitively failed. That is a worse lie than the silence it replaced.
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

  // costError is checked before the zero-cost rung (reversed 2026-07-31,
  // see the doc comment above resolveSubmitJobCtaState for the full
  // reasoning). A zero cost means "not priced yet" ONLY while nothing on
  // the cost channel has failed - after the cubit stopped discarding files
  // on a pricing failure, a failed pricing attempt leaves jobCost at zero
  // too, and the failure is the more specific, more useful fact to report.
  if (costError.isNotEmpty) {
    return SubmitJobCtaState.costError;
  }

  // A cost of zero (with no cost-channel failure) means "not priced yet",
  // never "free" and never "unaffordable".
  if (jobCost == 0) {
    return SubmitJobCtaState.costUnknown;
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
