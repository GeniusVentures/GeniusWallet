import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/submit_job/submit_job_cta_state.dart';

/// One expectation per `<behavior>` bullet in 14-05-PLAN.md's Task 3, plus
/// the precedence cases and the exhaustive-enum guard - a near-clone of
/// `test/dashboard/bridge/bridge_cta_state_test.dart`, mirrored deliberately
/// so the two read as a pair (submit-job's `<=` boundary is the one that
/// matches the house norm; the old `<` was the outlier).
void main() {
  group('resolveSubmitJobCtaState — noFileChosen rung', () {
    test(
      'no file chosen -> noFileChosen, disabled, ahead of any cost reasoning',
      () {
        final state = resolveSubmitJobCtaState(
          isSubmitting: false,
          hasFileChosen: false,
          jobCost: 0,
          gnusBalance: 0,
          costError: '',
        );
        expect(state, SubmitJobCtaState.noFileChosen);
        expect(submitJobCtaEnabled(state), isFalse);
      },
    );

    test('no file chosen outranks a cost error too', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: false,
        jobCost: 5,
        gnusBalance: 0,
        costError: 'some failure',
      );
      expect(state, SubmitJobCtaState.noFileChosen);
    });
  });

  group('resolveSubmitJobCtaState — costUnknown rung', () {
    test('job cost of zero -> costUnknown, NEVER insufficientFunds', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 0,
        gnusBalance: 0,
        costError: '',
      );
      expect(state, SubmitJobCtaState.costUnknown);
      expect(state, isNot(SubmitJobCtaState.insufficientFunds));
      expect(submitJobCtaEnabled(state), isFalse);
    });

    test('job cost of zero even with a nonzero balance -> costUnknown', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 0,
        gnusBalance: 1000,
        costError: '',
      );
      expect(state, SubmitJobCtaState.costUnknown);
    });
  });

  group('resolveSubmitJobCtaState — costError rung', () {
    test('a cost-channel failure -> costError, distinct from costUnknown', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 10,
        gnusBalance: 5,
        costError: 'Unable to fetch GNUS balance',
      );
      expect(state, SubmitJobCtaState.costError);
      expect(state, isNot(SubmitJobCtaState.costUnknown));
      expect(submitJobCtaEnabled(state), isFalse);
    });
  });

  group('resolveSubmitJobCtaState — insufficientFunds rung', () {
    test('cost above balance -> insufficientFunds, disabled', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 10,
        gnusBalance: 5,
        costError: '',
      );
      expect(state, SubmitJobCtaState.insufficientFunds);
      expect(submitJobCtaEnabled(state), isFalse);
    });

    test('the shortfall is carried as a number', () {
      final shortfall = submitJobShortfall(jobCost: 10, gnusBalance: 5);
      expect(shortfall, 5);
    });

    test('shortfall is 0 for an affordable cost', () {
      final shortfall = submitJobShortfall(jobCost: 5, gnusBalance: 10);
      expect(shortfall, 0);
    });
  });

  group('resolveSubmitJobCtaState — ready rung (exactly-affordable)', () {
    test('job cost 10, balance 10 (exactly affordable) -> ready, ENABLED - '
        'NOT insufficientFunds. Mirrors bridge_cta_state_test.dart\'s '
        '"amount 1, balance 1 (exactly affordable) -> NOT insufficient".', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 10,
        gnusBalance: 10,
        costError: '',
      );
      expect(state, SubmitJobCtaState.ready);
      expect(state, isNot(SubmitJobCtaState.insufficientFunds));
      expect(submitJobCtaEnabled(state), isTrue);
      expect(submitJobCtaLabel(state), 'Purchase');
    });

    test('cost below balance -> ready, enabled', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 5,
        gnusBalance: 10,
        costError: '',
      );
      expect(state, SubmitJobCtaState.ready);
      expect(submitJobCtaEnabled(state), isTrue);
    });

    test('a balance a hair below whole due to float dust still resolves ready '
        'at exactly-affordable (fixed-precision compare)', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: false,
        hasFileChosen: true,
        jobCost: 10,
        gnusBalance: 9.999999999,
        costError: '',
      );
      expect(state, SubmitJobCtaState.ready);
    });
  });

  group('resolveSubmitJobCtaState — submitting rung outranks everything', () {
    test(
      'isSubmitting true -> submitting, disabled, regardless of file/cost',
      () {
        final state = resolveSubmitJobCtaState(
          isSubmitting: true,
          hasFileChosen: false,
          jobCost: 0,
          gnusBalance: 0,
          costError: 'irrelevant',
        );
        expect(state, SubmitJobCtaState.submitting);
        expect(submitJobCtaEnabled(state), isFalse);
      },
    );

    test('submitting outranks insufficientFunds', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: true,
        hasFileChosen: true,
        jobCost: 100,
        gnusBalance: 1,
        costError: '',
      );
      expect(state, SubmitJobCtaState.submitting);
    });

    test('submitting outranks ready', () {
      final state = resolveSubmitJobCtaState(
        isSubmitting: true,
        hasFileChosen: true,
        jobCost: 1,
        gnusBalance: 100,
        costError: '',
      );
      expect(state, SubmitJobCtaState.submitting);
    });
  });

  group('submitJobCtaEnabled — exhaustive', () {
    test('exactly one rung enables the CTA', () {
      final enabledStates = SubmitJobCtaState.values
          .where(submitJobCtaEnabled)
          .toSet();
      expect(enabledStates, {SubmitJobCtaState.ready});
    });
  });
}
