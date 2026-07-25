import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/squid_router/swap_cta_state.dart';

/// One expectation per `<behavior>` bullet in 08-03-PLAN.md's Task 1, plus the
/// precedence cases. Note D-18b: the underlying Squid quote is a hardcoded
/// constant end to end — this ladder is proven independently of that, on pure
/// synthetic inputs, and never asserts the quote itself varies by token pair
/// or amount.
void main() {
  group('resolveSwapCtaState — enterAmount rung', () {
    test('empty amount, tokens selected -> enterAmount', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.enterAmount);
      expect(swapCtaEnabled(state), isFalse);
    });

    test('unparseable amount, tokens selected -> enterAmount', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: 'not-a-number',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.enterAmount);
      expect(swapCtaEnabled(state), isFalse);
    });

    test('no tokens selected -> enterAmount', () {
      final state = resolveSwapCtaState(
        hasBothTokens: false,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.enterAmount);
      expect(swapCtaEnabled(state), isFalse);
    });
  });

  group('resolveSwapCtaState — insufficientBalance rung', () {
    test('amount 5, balance 1 -> insufficientBalance, disabled', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '5',
        fromBalance: 1,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.insufficientBalance);
      expect(swapCtaEnabled(state), isFalse);
      expect(swapCtaLabel(state, symbol: 'ETH'), 'Insufficient ETH balance');
    });

    test('amount 1, balance 1 (exactly affordable) -> NOT insufficient', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 1,
        isFetchingRoute: false,
        hasRoute: true,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, isNot(SwapCtaState.insufficientBalance));
      expect(state, SwapCtaState.ready);
    });

    test('balance unknown (null) -> NOT insufficient', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1000000',
        fromBalance: null,
        isFetchingRoute: false,
        hasRoute: true,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, isNot(SwapCtaState.insufficientBalance));
      expect(state, SwapCtaState.ready);
    });

    test('label falls back when symbol is null', () {
      expect(
        swapCtaLabel(SwapCtaState.insufficientBalance),
        'Insufficient balance',
      );
    });

    test('label falls back when symbol is empty', () {
      expect(
        swapCtaLabel(SwapCtaState.insufficientBalance, symbol: ''),
        'Insufficient balance',
      );
    });
  });

  group('resolveSwapCtaState — findingRoute rung', () {
    test('amount valid, fetch in flight -> findingRoute, disabled', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: true,
        hasRoute: false,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.findingRoute);
      expect(swapCtaEnabled(state), isFalse);
      expect(swapCtaLabel(state), 'Finding best route…');
    });
  });

  group('resolveSwapCtaState — ready rung', () {
    test('amount valid, route present, no error -> ready, enabled', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: true,
        routeError: false,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.ready);
      expect(swapCtaEnabled(state), isTrue);
      expect(swapCtaLabel(state), 'Swap');
    });
  });

  group('resolveSwapCtaState — routeError rung (D-09)', () {
    test('routeError true -> routeError, ENABLED Retry', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: true,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.routeError);
      expect(swapCtaEnabled(state), isTrue);
      expect(swapCtaLabel(state), 'Retry');
    });

    test('routeError outranks insufficientBalance', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '5',
        fromBalance: 1,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: true,
        isSubmitting: false,
      );
      expect(state, SwapCtaState.routeError);
    });
  });

  group('resolveSwapCtaState — submitting rung outranks everything', () {
    test('isSubmitting true -> submitting, disabled, regardless of amount', () {
      final state = resolveSwapCtaState(
        hasBothTokens: false,
        fromAmount: '',
        fromBalance: null,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: true,
      );
      expect(state, SwapCtaState.submitting);
      expect(swapCtaEnabled(state), isFalse);
      expect(swapCtaLabel(state), 'Submitting swap…');
    });

    test('submitting outranks routeError', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: true,
        isSubmitting: true,
      );
      expect(state, SwapCtaState.submitting);
    });

    test('submitting outranks insufficientBalance', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '5',
        fromBalance: 1,
        isFetchingRoute: false,
        hasRoute: false,
        routeError: false,
        isSubmitting: true,
      );
      expect(state, SwapCtaState.submitting);
    });

    test('submitting outranks findingRoute', () {
      final state = resolveSwapCtaState(
        hasBothTokens: true,
        fromAmount: '1',
        fromBalance: 10,
        isFetchingRoute: true,
        hasRoute: false,
        routeError: false,
        isSubmitting: true,
      );
      expect(state, SwapCtaState.submitting);
    });
  });

  group('swapCtaEnabled — exhaustive', () {
    test('only ready and routeError are enabled', () {
      final enabledStates = SwapCtaState.values.where(swapCtaEnabled).toSet();
      expect(enabledStates, {SwapCtaState.ready, SwapCtaState.routeError});
    });
  });
}
