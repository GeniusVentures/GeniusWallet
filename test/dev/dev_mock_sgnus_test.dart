import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dev/dev_mock_sgnus.dart';

/// Pure-Dart coverage of the `DevMockSgnus` fixture class only - it cannot go
/// through `AppBloc`'s dev branch: `kShowDevTools` is a `bool.fromEnvironment`
/// const that is `false` under `flutter test` (no `--dart-define` is passed
/// by the test runner), so that branch is unreachable here by construction.
/// See `test/dev/dev_mock_job_test.dart`'s identical header for the same
/// reasoning applied to the JOB fixture.
void main() {
  setUp(() {
    DevMockSgnus.instance.clear();
    DevMockSgnus.instance.clearInitPercentage();
    DevMockSgnus.instance.clearFeedUnavailable();
    DevMockSgnus.instance.clearJobComplete();
    // clearInitPercentage() above may itself have just armed a pending
    // release (if a previous test left an override armed) - drain it so no
    // test starts with a stray pending release already set.
    DevMockSgnus.instance.consumeInitRelease();
    // A previous test's armReady() (or a direct arm) may have left a
    // pending stale-completion request - drain it the same way.
    DevMockSgnus.instance.consumeStaleCompletion();
  });
  tearDown(() {
    DevMockSgnus.instance.clear();
    DevMockSgnus.instance.clearInitPercentage();
    DevMockSgnus.instance.clearFeedUnavailable();
    DevMockSgnus.instance.clearJobComplete();
    DevMockSgnus.instance.consumeInitRelease();
    DevMockSgnus.instance.consumeStaleCompletion();
  });

  group('processingPercentageForElapsed - pure ramp arithmetic', () {
    test('0s is 0', () {
      expect(DevMockSgnus.processingPercentageForElapsed(Duration.zero), 0.0);
    });

    test('1s is 4', () {
      expect(
        DevMockSgnus.processingPercentageForElapsed(const Duration(seconds: 1)),
        4.0,
      );
    });

    test('24s is 96', () {
      expect(
        DevMockSgnus.processingPercentageForElapsed(
          const Duration(seconds: 24),
        ),
        96.0,
      );
    });

    test('25s wraps back to 0', () {
      expect(
        DevMockSgnus.processingPercentageForElapsed(
          const Duration(seconds: 25),
        ),
        0.0,
      );
    });

    test('26s is 4', () {
      expect(
        DevMockSgnus.processingPercentageForElapsed(
          const Duration(seconds: 26),
        ),
        4.0,
      );
    });

    test('500ms does not advance', () {
      expect(
        DevMockSgnus.processingPercentageForElapsed(
          const Duration(milliseconds: 500),
        ),
        0.0,
      );
    });

    test('the sweep never yields 100 for any whole step in one full cycle', () {
      for (var second = 0; second < 25; second++) {
        final value = DevMockSgnus.processingPercentageForElapsed(
          Duration(seconds: second),
        );
        expect(
          value,
          lessThan(100.0),
          reason: 'second=$second produced $value, which must stay < 100',
        );
      }
    });
  });

  group('processingPercentage - instance getter', () {
    test('is 0.0 when nothing is armed', () {
      expect(DevMockSgnus.instance.processingPercentage, 0.0);
    });

    test('arm(processing: true) immediately followed by a read is 0.0', () {
      DevMockSgnus.instance.arm(processing: true);
      expect(DevMockSgnus.instance.processingPercentage, 0.0);
    });

    test('arm(processing: false) returns it to 0.0', () {
      DevMockSgnus.instance.arm(processing: true);
      DevMockSgnus.instance.arm(processing: false);
      expect(DevMockSgnus.instance.processingPercentage, 0.0);
    });

    test('clear() returns it to 0.0', () {
      DevMockSgnus.instance.arm(processing: true);
      DevMockSgnus.instance.clear();
      expect(DevMockSgnus.instance.processingPercentage, 0.0);
    });
  });

  group('jobCompleteOverride', () {
    test('is null until armed', () {
      expect(DevMockSgnus.instance.jobCompleteOverride, isNull);
    });

    test('is true once armed', () {
      DevMockSgnus.instance.armJobComplete();
      expect(DevMockSgnus.instance.jobCompleteOverride, isTrue);
    });

    test('is null after clearJobComplete()', () {
      DevMockSgnus.instance.armJobComplete();
      DevMockSgnus.instance.clearJobComplete();
      expect(DevMockSgnus.instance.jobCompleteOverride, isNull);
    });

    test('is NOT touched by clear() - the trap the Clear button comment '
        'warns about, pinned here', () {
      DevMockSgnus.instance.armJobComplete();
      DevMockSgnus.instance.clear();
      expect(DevMockSgnus.instance.jobCompleteOverride, isTrue);
      // Clean up manually since clear() deliberately does not do it.
      DevMockSgnus.instance.clearJobComplete();
    });
  });

  group('initPercentageOverride - 0.0-1.0 scale', () {
    test('armInitPercentage(0.37) stores 0.37', () {
      DevMockSgnus.instance.armInitPercentage(0.37);
      expect(DevMockSgnus.instance.initPercentageOverride, 0.37);
    });
  });

  group('init release semantics (Task 3)', () {
    test('clearInitPercentage() after an arm leaves a release pending', () {
      DevMockSgnus.instance.armInitPercentage(0.37);
      DevMockSgnus.instance.clearInitPercentage();
      expect(DevMockSgnus.instance.initReleasePending, isTrue);
    });

    test(
      'clearInitPercentage() with nothing armed leaves NO release pending',
      () {
        DevMockSgnus.instance.clearInitPercentage();
        expect(DevMockSgnus.instance.initReleasePending, isFalse);
      },
    );

    test('consumeInitRelease() returns true once and false thereafter', () {
      DevMockSgnus.instance.armInitPercentage(0.37);
      DevMockSgnus.instance.clearInitPercentage();
      expect(DevMockSgnus.instance.consumeInitRelease(), isTrue);
      expect(DevMockSgnus.instance.consumeInitRelease(), isFalse);
    });

    test('armInitPercentage after a clearInitPercentage leaves no release '
        'pending', () {
      DevMockSgnus.instance.armInitPercentage(0.37);
      DevMockSgnus.instance.clearInitPercentage();
      DevMockSgnus.instance.armInitPercentage(0.5);
      expect(DevMockSgnus.instance.initReleasePending, isFalse);
    });
  });

  group('the SGNUS init button resolves to startingUp', () {
    test('resolveComputeState reaches startingUp from the value the button '
        'arms', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: DevMockSgnus.address,
        selectedWalletAddress: DevMockSgnus.address,
        isProcessingUnavailable: false,
        initPercentage: 0.37,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.startingUp);
    });
  });

  group('armReady - forces every override ComputeState.ready needs', () {
    test('sets processingOverride to false', () {
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.processingOverride, isFalse);
    });

    test('sets initPercentageOverride to 1.0', () {
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.initPercentageOverride, 1.0);
    });

    test('clears a previously-armed feedUnavailableOverride', () {
      DevMockSgnus.instance.armFeedUnavailable();
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.feedUnavailableOverride, isNull);
    });

    test('clears a previously-armed jobCompleteOverride', () {
      DevMockSgnus.instance.armJobComplete();
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.jobCompleteOverride, isNull);
    });

    test('marks a stale-completion request pending', () {
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.staleCompletionPending, isTrue);
    });
  });

  group('consumeStaleCompletion - one-shot semantics', () {
    test('is false when nothing is pending', () {
      expect(DevMockSgnus.instance.consumeStaleCompletion(), isFalse);
    });

    test('returns true once, then false, after armReady()', () {
      DevMockSgnus.instance.armReady();
      expect(DevMockSgnus.instance.consumeStaleCompletion(), isTrue);
      expect(DevMockSgnus.instance.consumeStaleCompletion(), isFalse);
    });
  });

  group('the SGNUS ready button resolves to ready', () {
    test(
      'resolveComputeState reaches ready from the values armReady() arms, '
      'even with a job completed 30 seconds ago (inside jobCompleteWindow)',
      () {
        // Mirrors what armReady() plus the stale-completion consumption in
        // app_bloc.dart's dev branch actually produce: initPercentage: 1.0,
        // isProcessing: false, isProcessingUnavailable: false, and a
        // sinceJobFinished comfortably past jobCompleteWindow even though a
        // real Job done press 30 seconds ago would otherwise still be
        // inside the 60s window.
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: DevMockSgnus.address,
          selectedWalletAddress: DevMockSgnus.address,
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: jobCompleteWindow * 2,
        );
        expect(state, ComputeState.ready);
      },
    );

    test('resolveComputeState reaches ready with no prior job completion at '
        'all', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: DevMockSgnus.address,
        selectedWalletAddress: DevMockSgnus.address,
        isProcessingUnavailable: false,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.ready);
    });
  });
}
