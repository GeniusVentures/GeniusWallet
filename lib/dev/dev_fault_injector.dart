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
    if (_pendingAccountLoadFailures <= 0) return false;
    _pendingAccountLoadFailures -= 1;
    return true;
  }

  /// Clears any pending failure. Used by the bubble's 'Clear'.
  void disarm() {
    _pendingAccountLoadFailures = 0;
  }
}
