import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:genius_wallet/test/dev_overrides.dart';

/// Progress source for the AI-processing FAB (bottom-left), 0–100.
///
/// Integration point for the dev (see HANDOFF.md §6): nothing in the current
/// SDK surface exposes a numeric job progress, so push real SGNUS job
/// progress here — `AiProcessingStatus.instance.set(percent)` from wherever
/// job events arrive (e.g. the submit-job flow / SGNUS transaction events).
/// The FAB listens via [ValueListenableBuilder] and updates live.
///
/// In the mock/QA build (`WALLET_PK` set) a demo sweep animates 0→100 on a
/// loop so the FAB is reviewable; production builds stay at 0% until wired.
class AiProcessingStatus extends ValueNotifier<int> {
  AiProcessingStatus._() : super(0);

  static final AiProcessingStatus instance = AiProcessingStatus._();

  Timer? _demoTimer;

  /// Set the current AI-processing progress (clamped to 0–100).
  void set(int percent) => value = percent.clamp(0, 100);

  /// Demo sweep for the UI-only build — no-op outside mock (`WALLET_PK`).
  void startDemoSweepIfMock() {
    if (walletPK.isEmpty || _demoTimer != null) return;
    _demoTimer = Timer.periodic(const Duration(milliseconds: 240), (_) {
      value = value >= 100 ? 0 : value + 2;
    });
  }

  void stopDemo() {
    _demoTimer?.cancel();
    _demoTimer = null;
  }
}
