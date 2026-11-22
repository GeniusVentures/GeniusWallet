// The init feed is known to park below 1.0 forever when the node's READY
// transition never fires (shipped-build ceiling 0.525, sweep ceiling 0.60),
// which left the earning bar reading "Starting up" indefinitely. A reading
// frozen for at least the stall deadline resolves to its own state with a
// Retry affordance; a moving feed keeps reading plain "Starting up".
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';

ComputeState _resolve({
  double? initPercentage = 0.6,
  Duration? sinceInitReadingChanged,
}) {
  return resolveComputeState(
    hasSelectedWallet: true,
    isNodeConnected: true,
    nodeWalletAddress: '0xabc',
    selectedWalletAddress: '0xabc',
    isProcessingUnavailable: false,
    initPercentage: initPercentage,
    sinceInitReadingChanged: sinceInitReadingChanged,
    isProcessing: false,
    sinceJobFinished: null,
  );
}

void main() {
  group('resolveComputeState stalled refinement', () {
    test('a reading frozen past the deadline reads stalled', () {
      expect(
        _resolve(sinceInitReadingChanged: initStallDeadline),
        ComputeState.stalled,
      );
    });

    test('a fresh below-1.0 feed still reads starting up', () {
      expect(
        _resolve(sinceInitReadingChanged: const Duration(seconds: 5)),
        ComputeState.startingUp,
      );
    });

    test('stalled never leaks above 1.0', () {
      expect(
        _resolve(
          initPercentage: 1.0,
          sinceInitReadingChanged: initStallDeadline * 10,
        ),
        isNot(ComputeState.stalled),
      );
    });

    test('no reading yet never reads stalled', () {
      expect(_resolve(sinceInitReadingChanged: null), ComputeState.startingUp);
    });
  });

  group('initFeedIsStalled', () {
    test('at and past the deadline', () {
      expect(
        initFeedIsStalled(
          sinceReadingChanged: initStallDeadline,
          percentage: 0.6,
        ),
        isTrue,
      );
      expect(
        initFeedIsStalled(
          sinceReadingChanged: initStallDeadline * 3,
          percentage: 0.6,
        ),
        isTrue,
      );
    });

    test('inside the deadline', () {
      expect(
        initFeedIsStalled(
          sinceReadingChanged: initStallDeadline - const Duration(seconds: 1),
          percentage: 0.6,
        ),
        isFalse,
      );
    });

    test('no elapsed time known', () {
      expect(
        initFeedIsStalled(sinceReadingChanged: null, percentage: 0.6),
        isFalse,
      );
    });

    test('never once the feed reaches 1.0', () {
      expect(
        initFeedIsStalled(
          sinceReadingChanged: initStallDeadline * 100,
          percentage: 1.0,
        ),
        isFalse,
      );
    });
  });

  group('the stalled view', () {
    final view = viewForComputeState(ComputeState.stalled, initPercentage: 0.6);

    test('names the stall and offers Retry', () {
      expect(view.label, 'Still starting up');
      expect(view.link, ComputeLink.retry);
      expect(view.link.label, 'Retry ›');
    });

    test('keeps the stuck percentage and stays honest about the bar', () {
      expect(view.trailing, '60%');
      expect(view.showBar, isFalse);
      expect(view.barValue, isNull);
    });

    test('reads as a warning, distinct from plain starting up', () {
      expect(view.dotRole, ComputeDotRole.warning);
      final starting = viewForComputeState(
        ComputeState.startingUp,
        initPercentage: 0.6,
      );
      expect(view.label, isNot(starting.label));
      expect(view.subline, isNot(starting.subline));
      expect(view.dotRole, isNot(starting.dotRole));
      expect(view.link, isNot(starting.link));
    });
  });
}
