// package:flutter/foundation.dart (not material.dart) because this file has
// no widget-tree dependency otherwise — ValueNotifier is the only thing
// needed from Flutter here, for the same reason app_bloc.dart imports just
// kDebugMode from foundation.dart rather than pulling in material.dart.
import 'package:flutter/foundation.dart' show ValueNotifier;

// DEV-ONLY: makes the dashboard's real account-load error branch reachable
// on demand, so the 05-07 Retry button can be walked without restarting the
// app or hand-editing app_bloc.dart. Never used outside a
// kDebugMode && kShowDevTools call site — see dev_tools_bubble.dart for the
// button that drives this.
//
// ponytail: process-lifetime in-memory state, one fault kind, deliberately
// not persisted and not generalised into a fault registry. The upgrade path
// for a second fault is one more field + one more gated call site, following
// this same shape.

/// Which forced state, if any, the dashboard Markets panel
/// (`MarketsDashboardView` in dashboard_screen.dart, via
/// `getDashboardMarketCoins()` in dashboard_markets_util.dart) should
/// produce on its next fetch. `null` (see [DevFaultInjector.marketsFault])
/// means "no override — run the real fetch".
enum DevMarketsFault { error, empty }

class DevFaultInjector {
  DevFaultInjector._();

  static final DevFaultInjector instance = DevFaultInjector._();

  int _pendingAccountLoadFailures = 0;

  /// Arms exactly one account-load failure. Assigns, never increments: an
  /// impatient double-press must not queue a second failure that would then
  /// be eaten by the Retry press and make a working button look broken.
  void armAccountLoadFailure() {
    _pendingAccountLoadFailures = 1;
  }

  /// Consumes a pending failure if one is armed. This is the auto-clear: the
  /// arm is spent by the first fetch that reads it, which is the property
  /// the whole walk rests on. Returns false — and changes nothing — when
  /// nothing is armed, so a second call with no re-arm cannot fail twice.
  bool consumeAccountLoadFailure() {
    if (_pendingAccountLoadFailures <= 0) {
      return false;
    }
    _pendingAccountLoadFailures -= 1;
    return true;
  }

  /// Clears any pending failure. Used by the bubble's 'Clear'.
  void disarm() {
    _pendingAccountLoadFailures = 0;
  }

  /// Sticky override for the dashboard Markets panel — `null` means "no
  /// override, run the real fetch". A [ValueNotifier], not a plain field
  /// like [_pendingAccountLoadFailures] above: arming happens from the
  /// dev-tools bubble, a sibling widget of the Markets panel's private
  /// State class with no shared Bloc/Cubit to dispatch an event through
  /// the way the account fault (`FetchAccount`) and the SGNUS fixture
  /// (`ProcessingStatusTicked`) do, so the panel listens to this instead.
  ///
  /// Deliberately STICKY, not one-shot like [armAccountLoadFailure] above.
  /// The Markets walk needs the forced error/empty state to survive window
  /// resizes and light/dark toggles, which a one-shot arm (spent by the
  /// very next fetch) cannot do. But sticky-with-no-off would trap the
  /// panel's real Retry button: while armed, every fetch — including one
  /// triggered by pressing Retry — reproduces the same forced state, so
  /// nobody could ever see genuine recovery. [disarmMarketsFault] is the
  /// explicit off that resolves that: arm to hold and inspect the forced
  /// state, disarm to let the next fetch run for real. Both arming and
  /// disarming trigger an immediate refetch (see the listener registered
  /// in dashboard_screen.dart's `_MarketsDashboardViewState.initState`),
  /// so 'Clear' visibly restores real data on its own — the empty branch
  /// has no in-panel Retry affordance to press instead (05-08 Task 3). A
  /// walker who wants to specifically exercise the real Retry button's
  /// recovery path can still press it after disarming: by then the
  /// override is already null, so that fetch succeeds too.
  final ValueNotifier<DevMarketsFault?> marketsFault = ValueNotifier(null);

  /// Arms the sticky markets-panel override. Assigns, never toggles
  /// blindly — repeated presses of the same MOCK button are idempotent,
  /// same as [DevMockSgnus.arm].
  void armMarketsFault(DevMarketsFault fault) {
    marketsFault.value = fault;
  }

  /// Clears the markets-panel override so the next fetch runs for real.
  /// Used by the bubble's 'Clear'.
  void disarmMarketsFault() {
    marketsFault.value = null;
  }
}
