/// The Compute panel's state ladder - pure Dart, no Flutter, no widget
/// context.
///
/// Modelled directly on `lib/dashboard/bridge/bridge_cta_state.dart`: the
/// panel resolves ONE of these per rebuild via [resolveComputeState] and
/// drives its dot, label, sub-line, bar and CTA purely from the result.
/// Colour mapping stays at the call site (where `GWColors` is in scope) -
/// this module only owns the precedence rule, the copy and the
/// bar/percentage derivation. That split is exactly why [ComputeDotRole] is
/// an enum and never a `Color`: a `Color` import would pull Flutter into a
/// file whose entire point is being testable without a widget pump.
///
/// **Eight states, not nine.** State 04 (Stalled - "Still starting up") is
/// parked as a backlog item
/// (`.planning/todos/pending/2026-07-29-stall-detector-needs-a-traced-processing-feed.md`)
/// because its threshold cannot be chosen honestly until the processing feed
/// is traced. `ComputeState` therefore has no ninth member for it: an enum
/// value nothing can return would silently weaken the exhaustive
/// distinctness guard in `test/dashboard/compute_state_distinct_test.dart`
/// and would mislead the next reader into thinking the detector shipped.
/// ponytail: the ceiling is "no stalled state" until that todo lands a real
/// N against a traced feed; the upgrade path is un-parking that file, adding
/// the ninth `ComputeState` member and letting the iterate-`values`
/// distinctness test catch any missing differentiation automatically.
library;

/// One of the eight states the compute node can be in, in the precedence
/// order [resolveComputeState] enforces (top wins).
enum ComputeState {
  /// No wallet is selected at all. Outranks every other rung - there is
  /// nothing else to say until one is chosen.
  noWallet,

  /// The SGNUS node does not report itself connected.
  ///
  /// Deliberately checked BEFORE [notLinked]: `wallet_overview.dart:179`
  /// passes `connection?.walletAddress ?? ""` for the node's wallet address
  /// when there is no connection, so without this ordering a disconnected
  /// node makes every wallet resolve to "not linked" - a false accusation
  /// against the user's own wallet. A future reader who reorders these two
  /// rungs re-introduces that bug.
  disconnected,

  /// The node is connected, but its own wallet address differs from the
  /// selected wallet's address.
  notLinked,

  /// The processing feed is flagged unavailable - `app_bloc.dart:192-195`
  /// cancels `_processingTimer` permanently on any exception and emits
  /// `isProcessing: false`, which is otherwise pixel-identical to a healthy
  /// idle node. Outranks starting up, processing and ready so that a dead
  /// feed never reads as a healthy one.
  unavailable,

  /// The initialization feed reports a percentage below 1.0.
  startingUp,

  /// The node is actively processing a job.
  processing,

  /// A job finished inside the completion window (see [jobCompleteWindow])
  /// and has not yet decayed to [ready].
  jobComplete,

  /// Node online, not processing, nothing to report.
  ready,
}

/// Semantic colour role for the status dot. An enum, not a `Color`: the
/// panel maps this to `GWColors` tokens where the theme is in scope,
/// keeping this file Flutter-free - the same house rule
/// `bridge_cta_state.dart`'s header comment prescribes.
enum ComputeDotRole { neutral, warning, success, brand, error }

/// The affordance a state's sub-line links to, if any.
enum ComputeLink {
  none,
  chooseWallet,
  switchWallet,
  seeNodeStatus,
  reconnect;

  /// Affordance copy from the copy contract (`14-UI-SPEC.md:775-783`).
  /// `null` for [ComputeLink.none] - there is nothing to render.
  String? get label => switch (this) {
    ComputeLink.none => null,
    ComputeLink.chooseWallet => 'Choose a wallet ›',
    ComputeLink.switchWallet => 'Switch wallet ›',
    ComputeLink.seeNodeStatus => 'See node status ›',
    ComputeLink.reconnect => 'Reconnect ›',
  };
}

/// How long a finished job keeps [ComputeState.jobComplete] before decaying
/// to [ComputeState.ready]. 60s, session-local, per `14-UI-SPEC.md:854-856`
/// open item 6's proposal - a transient acknowledgement, not a record, so it
/// is fine that a restart loses it.
const Duration jobCompleteWindow = Duration(seconds: 60);

/// Resolves the compute node's state from the screen's raw inputs.
///
/// Precedence, top to bottom (14-01-PLAN.md Task 2 `<action>`): [noWallet] →
/// [disconnected] → [notLinked] → [unavailable] → [startingUp] →
/// [processing] → [jobComplete] → [ready].
///
/// - [hasSelectedWallet]: whether any wallet is selected at all.
/// - [isNodeConnected]: whether the SGNUS node reports itself connected.
/// - [nodeWalletAddress]: the node's own wallet address, empty when there is
///   no connection (`wallet_overview.dart:179`) or when a connected node has
///   not yet reported one.
/// - [selectedWalletAddress]: the currently selected wallet's address.
/// - [isProcessingUnavailable]: true once the processing feed has died
///   (`app_bloc.dart:192-195`) and nothing has re-armed it.
/// - [initPercentage]: the initialization feed, 0.0-1.0
///   (`packages/genius_api/lib/src/genius_api.dart:81`). `null` before the
///   first poll ever lands.
/// - [isProcessing]: whether the node is actively processing a job right
///   now.
/// - [sinceJobFinished]: elapsed time since the last job finished, `null` if
///   none has finished this session.
ComputeState resolveComputeState({
  required bool hasSelectedWallet,
  required bool isNodeConnected,
  required String nodeWalletAddress,
  required String selectedWalletAddress,
  required bool isProcessingUnavailable,
  required double? initPercentage,
  required bool isProcessing,
  required Duration? sinceJobFinished,
}) {
  if (!hasSelectedWallet) {
    return ComputeState.noWallet;
  }

  // Disconnected outranks not-linked - see the doc comment on
  // ComputeState.disconnected for why this ordering is load-bearing.
  if (!isNodeConnected) {
    return ComputeState.disconnected;
  }

  // The emptiness guard (new this phase): a connected node reporting an
  // empty wallet address never resolves to notLinked, whatever the selected
  // wallet is. An empty nodeWalletAddress here means the node has not yet
  // reported one, not that it is linked to nothing.
  if (nodeWalletAddress.isNotEmpty &&
      nodeWalletAddress != selectedWalletAddress) {
    return ComputeState.notLinked;
  }

  if (isProcessingUnavailable) {
    return ComputeState.unavailable;
  }

  if (initPercentage != null && initPercentage < 1.0) {
    return ComputeState.startingUp;
  }

  if (isProcessing) {
    return ComputeState.processing;
  }

  if (sinceJobFinished != null && sinceJobFinished <= jobCompleteWindow) {
    return ComputeState.jobComplete;
  }

  return ComputeState.ready;
}

/// Plain view model describing what a [ComputeState] renders. Every field is
/// a plain value - no `Color`, no widget - so the panel (and every test in
/// this phase) can consume it without a widget pump or a bloc harness.
class ComputeStatusView {
  /// Semantic colour role for the status dot.
  final ComputeDotRole dotRole;

  /// The state's label, e.g. "Ready" or "Status unavailable".
  final String label;

  /// The sub-line under the label, or `null` when the state has none
  /// (state has no honest sub-line to show - `14-UI-SPEC.md:857-861`).
  final String? subline;

  /// The affordance the sub-line links to, if any.
  final ComputeLink link;

  /// Whether the determinate progress bar renders. Only
  /// [ComputeState.processing] ever renders a bar: there the denominator is
  /// real (`N of M`, sourced from the SDK's job-progress feed), so a
  /// determinate bar tells the truth. [ComputeState.startingUp] used to
  /// render one too, but the SDK's init feed climbs to a ceiling (`0.525` in
  /// the shipped build) and stops - a determinate bar there is a claim about
  /// a denominator that does not exist, so this state renders no bar at all
  /// and keeps only its percentage as [trailing]. See [barValue]'s own doc
  /// comment for the field-level half of this rule.
  final bool showBar;

  /// The bar's value, normalised to 0.0-1.0. Non-null if and only if
  /// [showBar] is true - a percentage without a bar is forbidden, a bar
  /// without a percentage is impossible.
  final double? barValue;

  /// The trailing value, e.g. `idle`, `52%` or `just now`. `null` when the
  /// state has no trailing value.
  final String? trailing;

  /// Whether the balance tile shows its `≈ $` fiat sub-line. This is the
  /// negation of [showBar]. That used to be justified as "the tallest
  /// states (bar visible) drop the fiat line to stay inside the height
  /// budget" - after this plan the claim is backwards: the one bar-showing
  /// state, [ComputeState.processing], measures as the SHORTEST non-empty
  /// state in the panel (234px per `14-08-SUMMARY.md`'s table), not the
  /// tallest. The real reason to keep `!showBar` is simpler than a height
  /// budget: a state already showing a determinate bar (with its own
  /// trailing `%`) has nothing left for a second, unrelated readout to say,
  /// so the fiat line stays reserved for the states that have no bar to
  /// speak for them. Derived here so a later plan cannot forget it.
  final bool showBalanceFiatSubline;

  /// Whether the panel's "New processing job" CTA is enabled. Only
  /// [ComputeState.ready] enables it - every other state either has nothing
  /// selected, nothing linked, nothing reachable, or a job already running.
  final bool ctaEnabled;

  const ComputeStatusView({
    required this.dotRole,
    required this.label,
    required this.subline,
    required this.link,
    required this.showBar,
    required this.barValue,
    required this.trailing,
    required this.showBalanceFiatSubline,
    required this.ctaEnabled,
  });
}

/// Builds the view model for a resolved [ComputeState].
///
/// Binds the strings from the copy contract (`14-UI-SPEC.md:769-784`).
///
/// Takes the two percentage feeds on their NATIVE scales and normalises
/// inside this function so no call site can get it wrong by a factor of one
/// hundred:
/// - [initPercentage]: 0.0-1.0
///   (`packages/genius_api/lib/src/genius_api.dart:81`), consulted only for
///   [ComputeState.startingUp].
/// - [processingPercentage]: 0.0-100.0
///   (`packages/genius_api/lib/ffi/genius_api_ffi.dart:1116-1118`), divided
///   by 100 here and consulted only for [ComputeState.processing].
///
/// Because each percentage is only read for its own state, a leftover
/// [processingPercentage] survives on a non-processing state (reachable and
/// permanent per `lib/bloc/app_bloc.dart:184-191`, which emits the
/// percentage only inside the processing branch) without ever producing a
/// bar or a trailing readout - [showBar] and [barValue] are derived from
/// [state] alone, never from a percentage being non-zero.
ComputeStatusView viewForComputeState(
  ComputeState state, {
  double? initPercentage,
  double? processingPercentage,
}) {
  final showBar = state == ComputeState.processing;

  double? barValue;
  String? percentageTrailing;
  if (state == ComputeState.startingUp) {
    // No bar for this state (see [ComputeStatusView.showBar]'s doc
    // comment), but the percentage survives as [trailing] - a number that
    // stops moving is self-evidently stuck in a way a bar parked at 52%
    // is not. barValue stays null: a non-null value here would violate
    // ComputeStatusView.barValue's own "non-null iff showBar" contract.
    final clampedInitPercentage = (initPercentage ?? 0.0).clamp(0.0, 1.0);
    percentageTrailing = '${(clampedInitPercentage * 100).round()}%';
  } else if (state == ComputeState.processing) {
    barValue = ((processingPercentage ?? 0.0) / 100.0).clamp(0.0, 1.0);
    percentageTrailing = '${(barValue * 100).round()}%';
  }

  final String label;
  String? subline;
  String? trailing = percentageTrailing;
  ComputeDotRole dotRole;
  ComputeLink link = ComputeLink.none;

  switch (state) {
    case ComputeState.noWallet:
      label = 'No wallet';
      subline = 'Select a wallet to use compute';
      dotRole = ComputeDotRole.neutral;
      link = ComputeLink.chooseWallet;
    case ComputeState.disconnected:
      label = 'Disconnected';
      subline = 'Not connected to the SGNUS network';
      dotRole = ComputeDotRole.error;
      link = ComputeLink.seeNodeStatus;
    case ComputeState.notLinked:
      label = 'Not linked';
      subline = 'This wallet is not the one connected to SGNUS';
      dotRole = ComputeDotRole.warning;
      link = ComputeLink.switchWallet;
    case ComputeState.unavailable:
      label = 'Status unavailable';
      subline = 'Feed stopped';
      dotRole = ComputeDotRole.error;
      link = ComputeLink.reconnect;
    case ComputeState.startingUp:
      label = 'Starting up';
      subline = 'Feed live';
      dotRole = ComputeDotRole.brand;
    case ComputeState.processing:
      label = 'Processing';
      subline = null;
      dotRole = ComputeDotRole.brand;
    case ComputeState.jobComplete:
      label = 'Job complete';
      subline = 'Finished · your balance is updating';
      trailing = 'just now';
      dotRole = ComputeDotRole.success;
    case ComputeState.ready:
      label = 'Ready';
      subline = 'Node online · waiting for work';
      trailing = 'idle';
      dotRole = ComputeDotRole.success;
  }

  return ComputeStatusView(
    dotRole: dotRole,
    label: label,
    subline: subline,
    link: link,
    showBar: showBar,
    barValue: barValue,
    trailing: trailing,
    showBalanceFiatSubline: !showBar,
    ctaEnabled: state == ComputeState.ready,
  );
}

/// The node's own tri-state processing reading, decoupled from
/// `GeniusProcessingStatus`
/// (`packages/genius_api/lib/ffi/genius_api_ffi.dart:1087-1095`) so this
/// module stays free of the genius_api/FFI dependency - the same house
/// rule that keeps [ComputeDotRole] an enum instead of a `Color`.
/// `AppBloc` maps the real FFI enum onto this one at the boundary.
enum NodeProcessingReading { disabled, idle, processing }

/// One value the processing feed can report to a UI: the node's tri-state
/// reading, or [unavailable] when the last read threw. [disabled] and
/// [idle] are kept distinct on purpose - `app_bloc.dart:180-182`'s
/// `statusInfo.status == GENIUS_PR_STATUS_PROCESSING.value` comparison
/// silently collapses both into the same `false`, which is exactly the
/// "processing off and processing disabled are the same value" bug this
/// phase closes.
enum ProcessingFeedReading { unavailable, disabled, idle, processing }

/// Maps the node's tri-state reading plus whether the read threw onto one
/// [ProcessingFeedReading] value. Pure extraction of the rule
/// `AppBloc._onProcessingStatusTicked` enforces at emit time (both its
/// `try` and `catch` branches funnel through this), kept here so it is
/// testable without a bloc harness (`test/dashboard/compute_feed_state_test.dart`).
///
/// A throw always wins: [readThrew] `true` returns [ProcessingFeedReading.unavailable]
/// regardless of [nodeReading], because a threw read has no data to
/// report, not even stale data.
ProcessingFeedReading resolveProcessingFeedReading({
  required bool readThrew,
  required NodeProcessingReading? nodeReading,
}) {
  if (readThrew) {
    return ProcessingFeedReading.unavailable;
  }
  return switch (nodeReading) {
    NodeProcessingReading.disabled => ProcessingFeedReading.disabled,
    NodeProcessingReading.idle => ProcessingFeedReading.idle,
    NodeProcessingReading.processing => ProcessingFeedReading.processing,
    // Not reachable from AppBloc (a non-throwing read always yields a
    // NodeProcessingReading), but null is a legal input to this pure
    // function, so it needs an honest answer rather than a throw.
    null => ProcessingFeedReading.idle,
  };
}

/// Whether a processing read just completed - the previous tick was
/// processing and the current one is not. Pure extraction of the
/// completion-edge rule `AppBloc._onProcessingStatusTicked` uses to decide
/// whether to write `AppState.processingCompletedAt`, kept here so it is
/// testable without a bloc harness
/// (`test/dashboard/compute_feed_state_test.dart`).
///
/// Only a true-to-false transition counts. false-to-true (a job starting)
/// and false-to-false / true-to-true (no transition) do not.
bool didProcessingJustComplete({
  required bool wasProcessing,
  required bool isProcessingNow,
}) {
  return wasProcessing && !isProcessingNow;
}
