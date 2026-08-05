import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';

/// Pure-Dart coverage of the `DevMockJob` fixture class only - it cannot go
/// through `SubmitJobCubit`: `kShowDevTools` is a `bool.fromEnvironment`
/// const that is `false` under `flutter test` (no `--dart-define` is passed
/// by the test runner), so the cubit's dev branches are unreachable here by
/// construction. That is also why "why is the interception untested" is
/// answered here rather than by a cubit test - the interception's only
/// consumer, the gate, is compiled out in this environment.
void main() {
  setUp(DevMockJob.instance.clear);
  tearDown(DevMockJob.instance.clear);

  group('scenario lifecycle', () {
    test('scenario is null until armed', () {
      expect(DevMockJob.instance.scenario.value, isNull);
    });

    test('clear() nulls the scenario again', () {
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      DevMockJob.instance.clear();
      expect(DevMockJob.instance.scenario.value, isNull);
    });

    test('arming the same scenario twice is idempotent', () {
      DevMockJob.instance.arm(DevJobScenario.bridgeFailed);
      DevMockJob.instance.arm(DevJobScenario.bridgeFailed);
      expect(DevMockJob.instance.scenario.value, DevJobScenario.bridgeFailed);
    });
  });

  group('notifier semantics', () {
    // These pin what SubmitJobCubit's re-price listener now depends on -
    // see Task 1 of 260731-hrn-PLAN.md. Every listener added here is removed
    // before the test ends, or the singleton carries it into the next test.
    test('arming from null notifies exactly once', () {
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      DevMockJob.instance.scenario.removeListener(listener);
      expect(callCount, 1);
    });

    test('arming the SAME scenario a second time does NOT notify', () {
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      DevMockJob.instance.scenario.removeListener(listener);
      expect(callCount, 0);
    });

    test('switching from one scenario to a different one notifies', () {
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.arm(DevJobScenario.insufficientFunds);
      DevMockJob.instance.scenario.removeListener(listener);
      expect(callCount, 1);
    });

    test('clear() from an armed scenario notifies', () {
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.clear();
      DevMockJob.instance.scenario.removeListener(listener);
      expect(callCount, 1);
    });

    test('clear() when already clear does not notify', () {
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.clear();
      DevMockJob.instance.scenario.removeListener(listener);
      expect(callCount, 0);
    });

    test('a removed listener stops being called', () {
      var callCount = 0;
      void listener() => callCount++;
      DevMockJob.instance.scenario.addListener(listener);
      DevMockJob.instance.arm(DevJobScenario.pricedOk);
      DevMockJob.instance.scenario.removeListener(listener);
      DevMockJob.instance.arm(DevJobScenario.insufficientFunds);
      expect(callCount, 1);
    });
  });

  group('balance', () {
    test('insufficientFunds -> short balance', () {
      DevMockJob.instance.arm(DevJobScenario.insufficientFunds);
      expect(DevMockJob.instance.balance, DevMockJob.shortBalance);
    });

    test('every other scenario -> affordable balance', () {
      for (final scenario in DevJobScenario.values) {
        if (scenario == DevJobScenario.insufficientFunds) {
          continue;
        }
        DevMockJob.instance.arm(scenario);
        expect(
          DevMockJob.instance.balance,
          DevMockJob.affordableBalance,
          reason: '$scenario should use the affordable balance',
        );
      }
    });

    test('unarmed -> affordable balance', () {
      expect(DevMockJob.instance.scenario.value, isNull);
      expect(DevMockJob.instance.balance, DevMockJob.affordableBalance);
    });
  });

  group('cost failure', () {
    test('costFailure -> costShouldFail is true', () {
      DevMockJob.instance.arm(DevJobScenario.costFailure);
      expect(DevMockJob.instance.costShouldFail, isTrue);
    });

    test('every other scenario -> costShouldFail is false', () {
      for (final scenario in DevJobScenario.values) {
        if (scenario == DevJobScenario.costFailure) {
          continue;
        }
        DevMockJob.instance.arm(scenario);
        expect(
          DevMockJob.instance.costShouldFail,
          isFalse,
          reason: '$scenario should not force a pricing failure',
        );
      }
    });
  });

  group('outcome mapping - exhaustive over DevJobScenario.values', () {
    test('bridgeFailed -> SubmitOutcome.bridgeFailed', () {
      DevMockJob.instance.arm(DevJobScenario.bridgeFailed);
      expect(DevMockJob.instance.outcome, SubmitOutcome.bridgeFailed);
    });

    test('bridgedNotProcessed -> SubmitOutcome.bridgedNotProcessed', () {
      DevMockJob.instance.arm(DevJobScenario.bridgedNotProcessed);
      expect(DevMockJob.instance.outcome, SubmitOutcome.bridgedNotProcessed);
    });

    test('every remaining scenario -> SubmitOutcome.done', () {
      for (final scenario in DevJobScenario.values) {
        if (scenario == DevJobScenario.bridgeFailed ||
            scenario == DevJobScenario.bridgedNotProcessed) {
          continue;
        }
        DevMockJob.instance.arm(scenario);
        expect(
          DevMockJob.instance.outcome,
          SubmitOutcome.done,
          reason: '$scenario should map to SubmitOutcome.done',
        );
      }
    });

    test('every DevJobScenario value has a defined outcome (exhaustive)', () {
      for (final scenario in DevJobScenario.values) {
        DevMockJob.instance.arm(scenario);
        expect(DevMockJob.instance.outcome, isA<SubmitOutcome>());
      }
    });
  });

  group('fixture constants are internally consistent', () {
    test(
      'affordableBalance covers jobCost, shortBalance falls short of it',
      () {
        expect(
          DevMockJob.affordableBalance,
          greaterThanOrEqualTo(DevMockJob.jobCost),
        );
        expect(DevMockJob.shortBalance, lessThan(DevMockJob.jobCost));
      },
    );

    test('txHash and bridgeHash are distinct', () {
      expect(DevMockJob.txHash, isNot(DevMockJob.bridgeHash));
    });

    test('processFailure is the process-image error', () {
      expect(
        DevMockJob.processFailure,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE,
      );
    });
  });
}
