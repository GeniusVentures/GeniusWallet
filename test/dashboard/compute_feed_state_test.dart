import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';

/// Pins the two pure helpers `lib/bloc/app_bloc.dart#_onProcessingStatusTicked`
/// extracts into `compute_state.dart` (14-02-PLAN.md Task 3): the
/// completion-edge rule and the feed-flag rule. Style matches
/// `test/dashboard/compute_state_test.dart`: plain unit tests, no mocks, no
/// `pumpWidget`, no bloc harness.
void main() {
  group('didProcessingJustComplete - completion-edge rule', () {
    test('a true-to-false transition reports a completion', () {
      expect(
        didProcessingJustComplete(
          wasProcessing: true,
          isProcessingNow: false,
        ),
        isTrue,
      );
    });

    test('a false-to-true transition does not report a completion', () {
      expect(
        didProcessingJustComplete(
          wasProcessing: false,
          isProcessingNow: true,
        ),
        isFalse,
      );
    });

    test('a false-to-false non-transition does not report a completion', () {
      expect(
        didProcessingJustComplete(
          wasProcessing: false,
          isProcessingNow: false,
        ),
        isFalse,
      );
    });

    test('a true-to-true non-transition does not report a completion', () {
      // Not one of the plan's three named cases, but the fourth cell of
      // the 2x2 truth table - included so the function's full behaviour is
      // pinned, not just three of its four inputs.
      expect(
        didProcessingJustComplete(wasProcessing: true, isProcessingNow: true),
        isFalse,
      );
    });
  });

  group('resolveProcessingFeedReading - feed-flag rule', () {
    test(
      'a read that threw maps to unavailable regardless of the last good reading',
      () {
        expect(
          resolveProcessingFeedReading(
            readThrew: true,
            nodeReading: NodeProcessingReading.processing,
          ),
          ProcessingFeedReading.unavailable,
        );
        expect(
          resolveProcessingFeedReading(
            readThrew: true,
            nodeReading: NodeProcessingReading.idle,
          ),
          ProcessingFeedReading.unavailable,
        );
        expect(
          resolveProcessingFeedReading(
            readThrew: true,
            nodeReading: NodeProcessingReading.disabled,
          ),
          ProcessingFeedReading.unavailable,
        );
        expect(
          resolveProcessingFeedReading(readThrew: true, nodeReading: null),
          ProcessingFeedReading.unavailable,
        );
      },
    );

    test('the disabled reading and the idle reading map to different results', () {
      // The bug this pins: app_bloc.dart:180-182's
      // `statusInfo.status == GENIUS_PR_STATUS_PROCESSING.value` collapses
      // GENIUS_PR_STATUS_DISABLED and GENIUS_PR_STATUS_IDLE into the same
      // `false` - this is the fourth value that comparison destroys.
      final disabled = resolveProcessingFeedReading(
        readThrew: false,
        nodeReading: NodeProcessingReading.disabled,
      );
      final idle = resolveProcessingFeedReading(
        readThrew: false,
        nodeReading: NodeProcessingReading.idle,
      );

      expect(disabled, isNot(equals(idle)));
      expect(disabled, ProcessingFeedReading.disabled);
      expect(idle, ProcessingFeedReading.idle);
    });

    test('a healthy processing reading maps through unchanged', () {
      expect(
        resolveProcessingFeedReading(
          readThrew: false,
          nodeReading: NodeProcessingReading.processing,
        ),
        ProcessingFeedReading.processing,
      );
    });
  });
}
