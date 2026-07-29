import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';

/// One expectation per rung of `resolveComputeState`'s ladder, plus the four
/// precedence cases that matter (14-01-PLAN.md Task 3) because each encodes a
/// bug this phase closes, the emptiness guard added this phase, the
/// stale-percentage trap in `lib/bloc/app_bloc.dart:184-191`, and the scale
/// defence against a hundred-times error between the two percentage feeds.
///
/// Style matches `test/dashboard/bridge/bridge_cta_state_test.dart`: plain
/// unit tests, no mocks, no `pumpWidget`, no bloc harness, no fixtures -
/// every call spells out its own inputs so a test reads as a single fact
/// about the ladder.
void main() {
  group('resolveComputeState — noWallet rung', () {
    test('no wallet selected -> noWallet, regardless of every other input', () {
      final state = resolveComputeState(
        hasSelectedWallet: false,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xWallet',
        isProcessingUnavailable: true,
        initPercentage: 0.2,
        isProcessing: true,
        sinceJobFinished: const Duration(seconds: 5),
      );
      expect(state, ComputeState.noWallet);
    });
  });

  group('resolveComputeState — disconnected rung', () {
    test('node reports itself not connected -> disconnected', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: false,
        nodeWalletAddress: '',
        selectedWalletAddress: '0xWallet',
        isProcessingUnavailable: false,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.disconnected);
    });
  });

  group('resolveComputeState — notLinked rung', () {
    test(
      'node connected, its wallet address differs from the selected one -> notLinked',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: '0xNode',
          selectedWalletAddress: '0xOther',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: null,
        );
        expect(state, ComputeState.notLinked);
      },
    );

    test(
      'connected node with an empty wallet address never resolves to notLinked '
      '(the emptiness guard is new this phase)',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: '',
          selectedWalletAddress: '0xWallet',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: null,
        );
        expect(state, isNot(ComputeState.notLinked));
        // Falls through the rest of the ladder to ready — nothing else
        // disqualifies it in this input set.
        expect(state, ComputeState.ready);
      },
    );
  });

  group('resolveComputeState — unavailable rung', () {
    test('processing feed flagged unavailable -> unavailable', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: true,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.unavailable);
    });
  });

  group('resolveComputeState — startingUp rung', () {
    test('init percentage below 1.0, nothing higher-ranked -> startingUp', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: false,
        initPercentage: 0.4,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.startingUp);
    });
  });

  group('resolveComputeState — processing rung', () {
    test('init complete, isProcessing true -> processing', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: false,
        initPercentage: 1.0,
        isProcessing: true,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.processing);
    });
  });

  group('resolveComputeState — jobComplete rung', () {
    test('job finished inside the completion window -> jobComplete', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: false,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: const Duration(seconds: 10),
      );
      expect(state, ComputeState.jobComplete);
    });
  });

  group('resolveComputeState — ready rung', () {
    test('healthy, idle, nothing recently finished -> ready', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: false,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.ready);
    });
  });

  group('resolveComputeState — the four precedence cases that matter', () {
    test(
      '1. disconnected outranks not-linked when the node reports an empty '
      'wallet address (wallet_overview.dart:179 passes connection?.walletAddress '
      "?? '' when there is no connection — without this ordering every wallet "
      'tests as not-linked and the user is falsely accused)',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: false,
          nodeWalletAddress: '',
          selectedWalletAddress: '0xWallet',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: null,
        );
        expect(state, ComputeState.disconnected);
        expect(state, isNot(ComputeState.notLinked));
      },
    );

    test('2. unavailable outranks ready', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: true,
        initPercentage: 1.0,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.unavailable);
    });

    test('3. unavailable outranks starting up', () {
      final state = resolveComputeState(
        hasSelectedWallet: true,
        isNodeConnected: true,
        nodeWalletAddress: '0xNode',
        selectedWalletAddress: '0xNode',
        isProcessingUnavailable: true,
        initPercentage: 0.3,
        isProcessing: false,
        sinceJobFinished: null,
      );
      expect(state, ComputeState.unavailable);
    });

    test(
      '4a. job-complete outranks ready inside the completion window '
      '(boundary inclusive)',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: '0xNode',
          selectedWalletAddress: '0xNode',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: jobCompleteWindow,
        );
        expect(state, ComputeState.jobComplete);
      },
    );

    test(
      '4b. job-complete decays to ready outside the completion window '
      '(both never resolve at once — the function returns exactly one value)',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: '0xNode',
          selectedWalletAddress: '0xNode',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: jobCompleteWindow + const Duration(seconds: 1),
        );
        expect(state, ComputeState.ready);
      },
    );
  });

  group('viewForComputeState — the stale-percentage trap', () {
    test(
      'isProcessing false with a leftover processingPercentage of 87.0 renders '
      'no bar and no percentage readout — reachable and permanent per '
      'lib/bloc/app_bloc.dart:184-191, which emits the percentage only inside '
      'the processing branch and never clears it when processing stops',
      () {
        final state = resolveComputeState(
          hasSelectedWallet: true,
          isNodeConnected: true,
          nodeWalletAddress: '0xNode',
          selectedWalletAddress: '0xNode',
          isProcessingUnavailable: false,
          initPercentage: 1.0,
          isProcessing: false,
          sinceJobFinished: null,
        );
        expect(state, ComputeState.ready);

        final view = viewForComputeState(state, processingPercentage: 87.0);
        expect(view.showBar, isFalse);
        expect(view.barValue, isNull);
        expect(view.trailing, isNot(contains('%')));
      },
    );
  });

  group('viewForComputeState — the scale test', () {
    test(
      'an initialization reading of 0.525 and a processing reading of 52.5 '
      'both produce a bar value of 0.525 — the whole defence against the '
      'hundred-times error between the two native scales',
      () {
        final startingUpView = viewForComputeState(
          ComputeState.startingUp,
          initPercentage: 0.525,
        );
        expect(startingUpView.barValue, 0.525);

        final processingView = viewForComputeState(
          ComputeState.processing,
          processingPercentage: 52.5,
        );
        expect(processingView.barValue, 0.525);
      },
    );
  });
}
