import 'dart:async';

/// The closing-run confirmation stages (13-CONTEXT D5/D6). `preparing` is the
/// held opening line ("Preparing your wallet…") shown before
/// [BootSequence.run] is ever called — the caller already displays it while
/// waiting for the frozen main isolate to lift, so `run()` itself never
/// emits it. It exists here so the enum names the full four-window sequence,
/// not just the three it drives.
enum BootStage { preparing, walletsReady, balancesReady, marketsReady }

/// Plain-Dart closing-run timing engine for the boot sequence
/// (13-CONTEXT D5/D6/D7).
///
/// Drives three discrete confirmation stages at fixed offsets, then races a
/// minimum hold against the real, variable-length boot work (markets,
/// chart, and possibly holdings) so the boot screen hands over on whichever
/// finishes LAST — never before the hold's floor, never capped by it.
///
/// Deliberately has no Flutter dependency, which keeps its minimum-hold-vs-
/// real-work race testable in isolation: `test/boot_sequence_test.dart`
/// exercises this directly. The rail's own tween and the widget wiring live
/// in the splash screen (13-03), not here.
class BootSequence {
  BootSequence({
    this.stageGap = const Duration(milliseconds: 450),
    this.minimumHold = const Duration(milliseconds: 1500),
  });

  /// Gap between each staged confirmation (D5: 450ms).
  final Duration stageGap;

  /// Total minimum hold from the first staged confirmation to handover
  /// (D5: 1500ms). D7: a FLOOR, not a fixed delay — real work may stretch
  /// it, but it never shrinks below this.
  final Duration minimumHold;

  /// The remaining hold after the two staged gaps have elapsed — the tail
  /// D7 requires to STRETCH when markets/chart run long, and the ramp
  /// duration for the rail's final sweep to 100%. Clamped to zero rather
  /// than negative if a caller ever configures a [stageGap] large enough to
  /// exhaust [minimumHold].
  Duration get finalHold {
    final remainingMicros =
        minimumHold.inMicroseconds - (stageGap.inMicroseconds * 2);
    return Duration(microseconds: remainingMicros < 0 ? 0 : remainingMicros);
  }

  /// Drives D5's three confirmation stages, then holds until BOTH
  /// [finalHold] and [work] have completed — whichever finishes later
  /// decides when this returns.
  ///
  /// [onStage] fires exactly three times, in order:
  /// 1. `walletsReady`, rail target 1/3, ramped over [stageGap];
  /// 2. `balancesReady`, rail target 2/3, ramped over [stageGap];
  /// 3. `marketsReady`, rail target 1.0, ramped over [finalHold].
  ///
  /// [work] is the real, variable-length boot work already in flight
  /// (markets, chart, possibly holdings). A REJECTING [work] is swallowed
  /// HERE, inside `run()`, rather than left to the call site — if it were
  /// not, the combined await would throw, `run()` would never return, and
  /// the boot screen would be stranded on its last confirmation forever: a
  /// strictly worse failure than the frozen spinner this phase exists to
  /// remove. The caller's futures already fall back to cache internally
  /// (coin_gecko_api.dart's existing `catch (e)` blocks); this is the belt
  /// for the day one of them doesn't.
  ///
  /// [isLive], if provided, is checked after each delay so a disposed
  /// caller can abandon the run early instead of calling [onStage] or
  /// resolving against a widget that no longer exists.
  Future<void> run({
    required void Function(
      BootStage stage,
      double railTarget,
      Duration railDuration,
    )
    onStage,
    required Future<void> work,
    bool Function()? isLive,
  }) async {
    bool live() => isLive == null || isLive();

    onStage(BootStage.walletsReady, 1 / 3, stageGap);
    await Future.delayed(stageGap);
    if (!live()) {
      return;
    }

    onStage(BootStage.balancesReady, 2 / 3, stageGap);
    await Future.delayed(stageGap);
    if (!live()) {
      return;
    }

    onStage(BootStage.marketsReady, 1.0, finalHold);

    // Swallow a rejecting `work` here — see the doc comment above. This is
    // the one place that guarantee is enforced, so no present or future
    // caller can forget it.
    final guardedWork = () async {
      try {
        await work;
      } catch (_) {
        // Intentionally ignored: a failing work leg must not strand the
        // boot screen. Callers already fall back to cache internally.
      }
    }();

    await Future.wait([Future.delayed(finalHold), guardedWork]);
    if (!live()) {
      return;
    }
  }
}
