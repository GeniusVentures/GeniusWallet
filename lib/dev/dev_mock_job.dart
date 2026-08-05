// package:flutter/foundation.dart (not material.dart) because this file has
// no widget-tree dependency otherwise - ValueNotifier is the only thing
// needed from Flutter here, the same idiom dev_fault_injector.dart:1-5 uses
// for the same reason.
import 'package:flutter/foundation.dart' show ValueNotifier;
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';

// DEV-ONLY: makes the whole submit-job flow (choose file, cost, confirm, in
// flight, result) walkable with no native SuperGenius node and no real GNUS.
// Before this fixture existed, `SubmitJobCubit.openFilePicker` and
// `bridgeTokens` both went straight to the SDK - `requestGeniusSDKCost`
// returns 0 whenever the SDK is not initialized, and `bridgeOut` /
// `requestGeniusSDKProcess` cannot be provoked into any particular outcome
// on demand. Two of the flow's five terminals were unreachable by any means
// a human had: `bridgeFailed` needs a live bridge call to fail, and
// `bridgedNotProcessed` needs the bridge to succeed AND the process call to
// fail immediately after - reachable in production only by burning real
// GNUS and hoping the node misbehaves at exactly the right moment.
//
// This is intercepted at the point of use inside `SubmitJobCubit`, not
// provided further up the widget tree - the cubit is built per-subtree in
// two places (`lib/components/wallet_overview.dart`, `lib/navigation/
// router.dart`) and the dev bubble sits above neither, so it has no
// provider path to reach it. See `dev_tools_bubble.dart`'s JOB section for
// the five arm buttons that drive this.
enum DevJobScenario {
  /// The job prices affordably and the whole flow completes: steps 2 and 3
  /// populate, `Continue` enables, step 4 holds briefly, step 5 lands on
  /// the job-started terminal.
  pricedOk,

  /// The job prices above the fixture balance: step 2 shows the shortfall
  /// note and `Continue` stays disabled. The walk deliberately stops there
  /// - that is the screen being reviewed, not a bug.
  insufficientFunds,

  /// Pricing itself fails: step 1 still shows the picked filename (the
  /// Task 1 fix this quick task's elz plan made) and step 2 shows the
  /// failure reason instead of a cost. If Task 1 regresses, this button
  /// reproduces a blank step 1 again - the two verify each other.
  costFailure,

  /// The job prices fine but the bridge call itself fails: nothing was
  /// spent, and the walk reaches the "nothing was sent" terminal.
  bridgeFailed,

  /// The bridge succeeds - tokens are burned - but the job never starts.
  /// Otherwise unreachable by any means a human has: it requires the
  /// bridge to succeed and the native process call to fail immediately
  /// after, which cannot be provoked on a live walk without spending real
  /// GNUS and hoping the node misbehaves at exactly the right moment. This
  /// single fact is the strongest reason this fixture is worth building.
  bridgedNotProcessed,
}

/// The submit-job flow's dev fixture. See the file-level DEV-ONLY comment
/// above for what it replaces. Never used outside a `kDebugMode &&
/// kShowDevTools` call site - see `SubmitJobCubit`'s gated `_devJobScenario`
/// getter and `dev_tools_bubble.dart`'s JOB section.
class DevMockJob {
  DevMockJob._() {
    assert(
      affordableBalance >= jobCost,
      'affordableBalance must cover jobCost or the priced-OK walk breaks',
    );
    assert(
      shortBalance < jobCost,
      'shortBalance must fall short of jobCost or the insufficient-funds '
      'walk breaks',
    );
  }

  static final DevMockJob instance = DevMockJob._();

  /// `null` means no override - run for real. Sticky, not one-shot, for the
  /// same reason `DevMockSgnus.processingOverride` is sticky: a walker
  /// holds a state while resizing the window, toggling appearance and
  /// re-running the flow. Contrast with `DevFaultInjector`'s one-shot
  /// fault, which must be spent so a retry press can succeed - nothing
  /// here needs spending.
  ///
  /// A `ValueNotifier`, not a plain field, because `SubmitJobCubit` prices
  /// at pick time (see `openFilePicker`'s pricing branch): a scenario armed
  /// AFTER a file is already chosen has no pick event to ride in on, so it
  /// must be able to push a re-price itself rather than wait for one that
  /// will not come. `DevFaultInjector.marketsFault` is the precedent this
  /// follows. Arming the same scenario twice is still idempotent for free -
  /// `ValueNotifier` only notifies on a changed value - so the "assigns,
  /// never toggles" sentence above now has a second mechanism behind it.
  final ValueNotifier<DevJobScenario?> scenario = ValueNotifier(null);

  /// A counting run - reads as fake at a glance, unlike any real job's
  /// cost.
  static const int jobCost = 1234;

  /// Nobody holds this much GNUS. Comfortably covers [jobCost] (pinned by
  /// the constructor's assertion above).
  static const double affordableBalance = 99999.99;

  /// Produces a clean 1221.66 shortfall against [jobCost] - the exact
  /// number step 2's shortfall note prints.
  static const double shortBalance = 12.34;

  /// A display string on the real state too, not a number - the cubit
  /// never parses this.
  static const String jobGasCost = '42.42 Gwei';

  /// Hex-shaped with DEV legible in it, distinct tail from [bridgeHash] so
  /// the two terminals can never be confused in a screenshot, and neither
  /// can be mistaken for a real chain artefact.
  static const String txHash = '0xDEV0B00000000000000000000000000000000D00E';

  /// Same idiom as [txHash], distinct tail (`BR1DGE`) so the two hash
  /// fields are never confused with each other.
  static const String bridgeHash =
      '0xDEV0B0000000000000000000000000000BR1DGE01';

  /// The process-image error - the cubit's existing private
  /// `_processErrorMessage` mapper turns this into the real production
  /// sentence, so the [DevJobScenario.bridgedNotProcessed] terminal shows
  /// exactly what a genuine failure shows rather than dev prose.
  static const GeniusNodeReturnValue processFailure =
      GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE;

  /// Names itself as a fixture - this is the one fixture value with no
  /// production equivalent to borrow, so it is a dev label, not product
  /// copy, and sits outside the copy contract (same footing as
  /// `DevMockSgnus.wallet`'s `walletName`).
  static const String costErrorMessage =
      'DEV fixture: pricing forced to fail (DevJobScenario.costFailure)';

  /// ponytail: a fixed delay, not a simulation of real bridge latency.
  /// Without a pause the fixture would flash past step 4 and the in-flight
  /// screen - one of the five screens a walk exists to look at - would
  /// never be seen. Upgrade path: none needed unless a walk ever needs
  /// variable timing.
  static const Duration inFlightDelay = Duration(seconds: 2);

  /// Arms the sticky override. Assigns, never toggles - repeated presses
  /// of the same JOB button are idempotent.
  void arm(DevJobScenario value) {
    scenario.value = value;
  }

  /// Clears the override so the cubit returns to reading the real SDK.
  void clear() {
    scenario.value = null;
  }

  /// The short balance for [DevJobScenario.insufficientFunds], the
  /// affordable balance for every other scenario (including unarmed).
  double get balance => scenario.value == DevJobScenario.insufficientFunds
      ? shortBalance
      : affordableBalance;

  /// True only for [DevJobScenario.costFailure] - every other scenario
  /// (including unarmed) prices successfully.
  bool get costShouldFail => scenario.value == DevJobScenario.costFailure;

  /// Exhaustive switch over [DevJobScenario] (plus `null` for unarmed),
  /// so adding a new scenario without updating this mapping fails
  /// analysis rather than silently defaulting. [DevJobScenario.bridgeFailed]
  /// and [DevJobScenario.bridgedNotProcessed] map to their matching
  /// [SubmitOutcome]; every other value (and unarmed) maps to
  /// [SubmitOutcome.done].
  SubmitOutcome get outcome {
    switch (scenario.value) {
      case DevJobScenario.bridgeFailed:
        return SubmitOutcome.bridgeFailed;
      case DevJobScenario.bridgedNotProcessed:
        return SubmitOutcome.bridgedNotProcessed;
      case DevJobScenario.pricedOk:
      case DevJobScenario.insufficientFunds:
      case DevJobScenario.costFailure:
      case null:
        return SubmitOutcome.done;
    }
  }
}
