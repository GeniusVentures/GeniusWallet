import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_cta_state.dart';

/// One expectation per `<behavior>` bullet in 08-04-PLAN.md's Task 1, plus the
/// precedence cases (submitting outranks every other rung) and the two
/// boundary cases (exactly-affordable amount, unknown/null balance). Unlike
/// swap's ladder (`swap_cta_state_test.dart`), bridge treats a null balance
/// as insufficient — mirroring the pre-existing precheck at
/// `bridge_screen.dart:116-119` (`fromToken?.balance == null` already sets
/// `isError = true` today), not swap's "never accuse on missing data" rule.
void main() {
  group('resolveBridgeCtaState — enterAmount rung', () {
    test('empty amount -> enterAmount, disabled', () {
      final state = resolveBridgeCtaState(
        amount: '',
        balance: 10,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: false,
      );
      expect(state, BridgeCtaState.enterAmount);
      expect(bridgeCtaEnabled(state), isFalse);
      expect(bridgeCtaLabel(state), 'Enter an amount');
    });

    test('unparseable amount -> enterAmount, disabled', () {
      final state = resolveBridgeCtaState(
        amount: 'not-a-number',
        balance: 10,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: false,
      );
      expect(state, BridgeCtaState.enterAmount);
      expect(bridgeCtaEnabled(state), isFalse);
    });
  });

  group('resolveBridgeCtaState — insufficientBalance rung', () {
    test('amount 5, balance 1 -> insufficientBalance, disabled', () {
      final state = resolveBridgeCtaState(
        amount: '5',
        balance: 1,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: false,
      );
      expect(state, BridgeCtaState.insufficientBalance);
      expect(bridgeCtaEnabled(state), isFalse);
      expect(
        bridgeCtaLabel(state, symbol: 'GNUS'),
        'Insufficient GNUS balance',
      );
    });

    test('amount 1, balance 1 (exactly affordable) -> NOT insufficient', () {
      final state = resolveBridgeCtaState(
        amount: '1',
        balance: 1,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: false,
      );
      expect(state, isNot(BridgeCtaState.insufficientBalance));
    });

    test(
      'balance null -> insufficientBalance (mirrors bridge precheck), not a parse accusation',
      () {
        final state = resolveBridgeCtaState(
          amount: '1',
          balance: null,
          isEstimating: false,
          hasEstimate: false,
          isError: false,
          isSubmitting: false,
        );
        expect(state, BridgeCtaState.insufficientBalance);
        expect(
          bridgeCtaLabel(state, symbol: 'GNUS'),
          'Insufficient GNUS balance',
        );
      },
    );

    test('label falls back when symbol is null', () {
      expect(
        bridgeCtaLabel(BridgeCtaState.insufficientBalance),
        'Insufficient balance',
      );
    });

    test('label falls back when symbol is empty', () {
      expect(
        bridgeCtaLabel(BridgeCtaState.insufficientBalance, symbol: ''),
        'Insufficient balance',
      );
    });
  });

  group('resolveBridgeCtaState — estimatingGas rung', () {
    test('amount valid, estimate in flight -> estimatingGas, disabled', () {
      final state = resolveBridgeCtaState(
        amount: '1',
        balance: 10,
        isEstimating: true,
        hasEstimate: false,
        isError: false,
        isSubmitting: false,
      );
      expect(state, BridgeCtaState.estimatingGas);
      expect(bridgeCtaEnabled(state), isFalse);
      expect(bridgeCtaLabel(state), 'Estimating gas…');
    });
  });

  group('resolveBridgeCtaState — gasError rung', () {
    test(
      'estimate failed (isError true), amount parseable and affordable -> gasError, disabled',
      () {
        final state = resolveBridgeCtaState(
          amount: '1',
          balance: 10,
          isEstimating: false,
          hasEstimate: false,
          isError: true,
          isSubmitting: false,
        );
        expect(state, BridgeCtaState.gasError);
        expect(bridgeCtaEnabled(state), isFalse);
        expect(bridgeCtaLabel(state), "Couldn't estimate gas");
      },
    );
  });

  group('resolveBridgeCtaState — ready rung', () {
    test(
      'amount valid, transactionCost present, no error -> ready, ENABLED, label Bridge',
      () {
        final state = resolveBridgeCtaState(
          amount: '1',
          balance: 10,
          isEstimating: false,
          hasEstimate: true,
          isError: false,
          isSubmitting: false,
        );
        expect(state, BridgeCtaState.ready);
        expect(bridgeCtaEnabled(state), isTrue);
        expect(bridgeCtaLabel(state), 'Bridge');
      },
    );
  });

  group('resolveBridgeCtaState — submitting rung outranks everything', () {
    test('isSubmitting true -> submitting, disabled, regardless of amount', () {
      final state = resolveBridgeCtaState(
        amount: '',
        balance: null,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: true,
      );
      expect(state, BridgeCtaState.submitting);
      expect(bridgeCtaEnabled(state), isFalse);
      expect(bridgeCtaLabel(state), 'Bridging…');
    });

    test('submitting outranks insufficientBalance', () {
      final state = resolveBridgeCtaState(
        amount: '5',
        balance: 1,
        isEstimating: false,
        hasEstimate: false,
        isError: false,
        isSubmitting: true,
      );
      expect(state, BridgeCtaState.submitting);
    });

    test('submitting outranks estimatingGas', () {
      final state = resolveBridgeCtaState(
        amount: '1',
        balance: 10,
        isEstimating: true,
        hasEstimate: false,
        isError: false,
        isSubmitting: true,
      );
      expect(state, BridgeCtaState.submitting);
    });

    test('submitting outranks gasError', () {
      final state = resolveBridgeCtaState(
        amount: '1',
        balance: 10,
        isEstimating: false,
        hasEstimate: false,
        isError: true,
        isSubmitting: true,
      );
      expect(state, BridgeCtaState.submitting);
    });

    test('submitting outranks ready', () {
      final state = resolveBridgeCtaState(
        amount: '1',
        balance: 10,
        isEstimating: false,
        hasEstimate: true,
        isError: false,
        isSubmitting: true,
      );
      expect(state, BridgeCtaState.submitting);
    });
  });

  group('bridgeCtaEnabled — exhaustive', () {
    test('only ready is enabled', () {
      final enabledStates = BridgeCtaState.values
          .where(bridgeCtaEnabled)
          .toSet();
      expect(enabledStates, {BridgeCtaState.ready});
    });
  });
}
