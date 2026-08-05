import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';

// DEV-ONLY: makes the SGNUS-wallet branch of WalletsOverview reachable in a
// walk for the first time. Before this fixture existed that branch needed a
// live SGNUS connection plus a real `isProcessing` tick — a state no walk
// had ever reached (05-VERIFICATION.md gap B1). Never used outside a
// kDebugMode && kShowDevTools call site — see dev_tools_bubble.dart for the
// two MOCK buttons that drive this and app_bloc.dart's
// `_onProcessingStatusTicked` for the gated short-circuit that makes
// [processingOverride] actually take effect.
//
// ponytail: process-lifetime in-memory state, one fixture wallet, not
// persisted. Destroyed by any `LoadWallets` dispatch (pull-to-refresh
// included), because `_onLoadWallets` (app_bloc.dart) rebuilds
// `WalletDetailsState` wholesale via `loadInitial` — pre-existing behavior
// already shared with the mock-holdings buttons. Upgrade path: re-press the
// MOCK button, or teach the cubit to survive a reload, which is a behavior
// change and out of scope here.
class DevMockSgnus {
  DevMockSgnus._();

  static final DevMockSgnus instance = DevMockSgnus._();

  /// Clearly-synthetic hex-shaped address with DEV legible in it, so it can
  /// never be mistaken for a real wallet address in a screenshot.
  static const String address = '0xDEV5GNUS00000000000000000000000000000001';

  /// Mirrors the shape real SGNUS wallets are built with at
  /// `app_bloc.dart:302-311`. `walletName` is a dev-tool label, not product
  /// copy, so it is outside the §6 copy contract — noted here so a later
  /// reader does not mistake it for a §6 violation.
  Wallet get wallet => const Wallet(
    walletName: 'DEV SGNUS Fixture',
    walletType: WalletType.sgnus,
    address: address,
    currencySymbol: 'minions',
    coinType: TWCoinType.TWCoinTypeEthereum,
    balance: 0,
  );

  /// `walletAddress` and `sgnusAddress` are BOTH [address] — deliberately.
  /// The compute panel's primary action (`lib/dashboard/compute/compute_panel.dart`,
  /// mounted by `lib/components/wallet_overview.dart`) only enables once
  /// `resolveComputeState` resolves to `ComputeState.ready`, which requires
  /// the connected node's wallet address to match the selected wallet's;
  /// matching them here is what makes this fixture reproduce the genuine
  /// worst case for `WalletsOverview` rather than a partial one missing
  /// that CTA. (Formerly the dashboard job button, deleted in 14-08.)
  SGNUSConnection get connection => const SGNUSConnection(
    sgnusAddress: address,
    walletAddress: address,
    isConnected: true,
  );

  /// Sticky, tri-state override for `AppState.isProcessing`. Null means "no
  /// override, read the SDK". Sticky (not one-shot) is a deliberate,
  /// opposite choice from [DevFaultInjector]'s one-shot fault: a walker
  /// needs to hold this state while resizing the window and toggling
  /// appearance, whereas a fault must be spent so a retry press can
  /// succeed. Both choices follow from what each walk needs.
  bool? processingOverride;

  /// One step per second: `app_bloc.dart:149`'s processing timer ticks at
  /// 1000ms, and that is the finest cadence this feed can express - a
  /// faster ramp would only skip values a walker never sees land.
  static const Duration processingStep = Duration(seconds: 1);

  /// 4 points per step, so a full sweep takes 25 seconds - long enough to
  /// watch the bar move and screenshot it at several widths, short enough
  /// that nobody waits.
  static const double processingStepPercent = 4.0;

  /// Modulo this, so the sequence is 0, 4, 8 ... 96, then 0 again. It never
  /// reads 100, because a bar at 100% on a job that has not finished is the
  /// one value that would be a lie. The loop is also what makes the ramp
  /// obviously synthetic: real progress does not restart.
  static const double processingCycle = 100.0;

  /// Set only on a transition INTO processing (see [arm]). `null` means
  /// nothing is armed, in which case [processingPercentage] reads 0.0.
  DateTime? _processingArmedAt;

  /// Pure function behind [processingPercentage]: elapsed wall time in,
  /// synthetic percentage out. Deterministic given an arm time, so it
  /// cannot drift if a tick is missed - unlike a counter incremented once
  /// per tick, which would fall behind if `app_bloc.dart`'s timer ever
  /// skipped a beat.
  static double processingPercentageForElapsed(Duration elapsed) {
    final steps = elapsed.inMilliseconds ~/ processingStep.inMilliseconds;
    return (steps * processingStepPercent) % processingCycle;
  }

  /// A time-derived percentage so the compute panel's progress bar visibly
  /// moves once a second under `SGNUS busy` - a fixed value (this used to be
  /// a `static const double processingPercentage = 42.0`) can never move,
  /// which defeats the one thing a progress affordance most needs
  /// reviewing for. 0.0 when nothing is armed.
  double get processingPercentage {
    final armedAt = _processingArmedAt;
    if (armedAt == null) {
      return 0.0;
    }
    return processingPercentageForElapsed(DateTime.now().difference(armedAt));
  }

  /// Arms the sticky override. Assigns, never toggles blindly — repeated
  /// presses of the same MOCK button are idempotent - which is why the ramp
  /// start time is only set on a transition INTO processing
  /// (`processing && processingOverride != true`): a second `SGNUS busy`
  /// press must not restart the ramp.
  void arm({required bool processing}) {
    if (processing && processingOverride != true) {
      _processingArmedAt = DateTime.now();
    } else if (!processing) {
      _processingArmedAt = null;
    }
    processingOverride = processing;
  }

  /// Clears the override so the panel returns to reading the real SDK.
  void clear() {
    processingOverride = null;
    _processingArmedAt = null;
  }

  /// Sticky override for `AppState.initPercentage`, 0.0-1.0 to match the
  /// real feed's scale (`genius_api.dart:81-82`). `null` means "no
  /// override, read the SDK poll". Makes `ComputeState.startingUp`
  /// walkable - before this plan the shipped app had no dev entry point
  /// for the initialization feed at all. Consumed in the same
  /// dev-override branch as [processingOverride]
  /// (`app_bloc.dart#_onProcessingStatusTicked`), not the real init
  /// timer's handler, for the same reason documented on
  /// [processingOverride]: that branch already returns before touching
  /// the FFI, and dispatches its own tick rather than trusting a timer
  /// that may already be dead.
  double? initPercentageOverride;

  /// Sticky override forcing `AppState.processingFeedStatus` to its
  /// unavailable value. `null`/`false` means "no override". Makes
  /// `ComputeState.unavailable` walkable - the real feed only reaches
  /// that state after a live FFI read throws, which a walker cannot
  /// trigger on demand.
  bool? feedUnavailableOverride;

  /// One-shot release flag, spent by [consumeInitRelease]. `copyWith`
  /// cannot null `AppState.initPercentage` (see its own doc comment), and
  /// the real init timer self-cancels once a reading reaches 1.0
  /// (`app_bloc.dart`'s `_onInitializationStatusTicked`), so on a node that
  /// already finished initialising there is no further poll to correct a
  /// released `initPercentageOverride` - without this flag the panel would
  /// sit in `startingUp` forever after Clear. Follows the idiom
  /// `DevFaultInjector.consumeAccountLoadFailure` already establishes: set
  /// only if an override was actually armed, spent by the first read.
  bool _initReleasePending = false;

  /// Read-only view of [_initReleasePending], for tests.
  bool get initReleasePending => _initReleasePending;

  /// Arms the sticky initialization-percentage override. Drops any pending
  /// release - arming supersedes it.
  void armInitPercentage(double percentage) {
    initPercentageOverride = percentage;
    _initReleasePending = false;
  }

  /// Clears the initialization-percentage override. Sets the pending
  /// release flag only if an override was actually armed - clearing with
  /// nothing armed has nothing to release.
  void clearInitPercentage() {
    if (initPercentageOverride != null) {
      _initReleasePending = true;
    }
    initPercentageOverride = null;
  }

  /// Consumes a pending release if one is armed. Returns and spends the
  /// flag - false, and no state change, when nothing is pending, so a
  /// second call with no re-clear cannot release twice.
  bool consumeInitRelease() {
    if (!_initReleasePending) {
      return false;
    }
    _initReleasePending = false;
    return true;
  }

  /// Arms the sticky feed-unavailable override.
  void armFeedUnavailable() {
    feedUnavailableOverride = true;
  }

  /// Clears the feed-unavailable override.
  void clearFeedUnavailable() {
    feedUnavailableOverride = null;
  }

  /// Sticky override forcing the compute panel into
  /// `ComputeState.jobComplete`. `null`/`false` means "no override". Makes
  /// that state walkable - `processingCompletedAt` (`app_state.dart`) is
  /// written only at `app_bloc.dart`'s real-SDK success path, which the dev
  /// branch never reaches, so `SGNUS busy` then `SGNUS idle` produces
  /// `ready`, not `jobComplete`. Deliberately NOT touched by [clear] - see
  /// [clearJobComplete] and the Clear button's own comment in
  /// `dev_tools_bubble.dart`, which is exactly the trap a third silently-
  /// unhandled override field would set.
  bool? jobCompleteOverride;

  /// Arms the sticky job-complete override.
  void armJobComplete() {
    jobCompleteOverride = true;
  }

  /// Clears the job-complete override.
  void clearJobComplete() {
    jobCompleteOverride = null;
  }

  /// One-shot flag consumed by `_onProcessingStatusTicked`'s general
  /// branch (`app_bloc.dart`): forces `AppState.processingCompletedAt` far
  /// enough into the past that `sinceJobFinished > jobCompleteWindow`, so a
  /// `Job done` press made shortly before [armReady] cannot leave a stale
  /// in-window timestamp behind. `copyWith` cannot null that field (see its
  /// own doc comment) and the dev branch's general emit does not otherwise
  /// touch it at all - without this, a recent `Job done` press would keep
  /// `SGNUS ready` masked behind `ComputeState.jobComplete` for up to 60
  /// seconds despite every other rung being satisfied.
  bool _staleCompletionPending = false;

  /// Read-only view of [_staleCompletionPending], for tests.
  bool get staleCompletionPending => _staleCompletionPending;

  /// Consumes a pending stale-completion request. Same idiom as
  /// [consumeInitRelease] - returns and spends the flag, so a second call
  /// with no re-arm cannot force it twice.
  bool consumeStaleCompletion() {
    if (!_staleCompletionPending) {
      return false;
    }
    _staleCompletionPending = false;
    return true;
  }

  /// Arms every override `ComputeState.ready` needs, and HOLDS it there.
  ///
  /// Why a dedicated `ready` fixture exists at all: `ready` is the only
  /// `ComputeState` whose CTA (`New processing job`) is clickable
  /// (`compute_state.dart`'s `ComputeStatusView.ctaEnabled`), so it is the
  /// gateway to the entire job flow - and before this method existed it was
  /// reachable only by accident, through the `armInitPercentage(37)` bug
  /// quick task 260731-hrn fixed (`37.0 < 1.0` read `false`, so the panel
  /// fell through to `ready`; fixing the fixture to the field's real
  /// 0.0-1.0 scale removed that accidental route). This method restores the
  /// route on purpose: `arm(processing: false)` clears `isProcessing`,
  /// `armInitPercentage(1.0)` satisfies the `initPercentage < 1.0` gate
  /// while the dev guard in `_onInitializationStatusTicked` stops the real
  /// 3s poll from clobbering it, `clearFeedUnavailable()` and
  /// `clearJobComplete()` release any fixture armed earlier in the session
  /// that would otherwise outrank `ready`, and the stale-completion flag
  /// (above) defeats a leftover in-window `processingCompletedAt` from an
  /// earlier `Job done` press. See `dev_tools_bubble.dart`'s `SGNUS ready`
  /// button for the call site.
  void armReady() {
    arm(processing: false);
    armInitPercentage(1.0);
    clearFeedUnavailable();
    clearJobComplete();
    _staleCompletionPending = true;
  }
}
