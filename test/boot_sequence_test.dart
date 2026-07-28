// test/boot_sequence_test.dart
//
// The ONE runnable check CLAUDE.md requires behind BootSequence's real
// branching — the minimum-hold-vs-real-work race (13-CONTEXT D7).
//
// ORIGINALLY written as `tool/boot_sequence_check.dart`, a plain-Dart script,
// on the premise (from 13-RESEARCH.md and ROADMAP.md "Verification reality")
// that `flutter test` does not compile in this repo. **That premise was wrong
// and was verified wrong on 2026-07-22:** `flutter test` runs, with 187 tests
// passing and 1 pre-existing failure unrelated to this phase
// (`test/local_wallet_storage_test.dart` — file is entirely commented out, so
// it fails at load with "Missing definition of main method"; that is inherited
// state, not a regression).
//
// Moved here so the check runs with the rest of the suite instead of needing
// a separate command nobody would remember. `BootSequence` keeps its plain-Dart,
// no-Flutter-import shape — that was good design independent of the bad premise.
//
// WHAT THIS DOES NOT COVER: the boot screen's contrast, the mesh background's
// freeze/resume behaviour, and whether the frozen window reads as hung to a
// human are all walk-verified in 13-03/13-05, not simulable here. A green run
// is evidence the timing engine's branching is correct — it is NOT evidence
// the boot screen looks or feels right.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/screens/boot_sequence.dart';

void main() {
  group('BootSequence', () {
    test('finalHold derives from the D5 defaults and clamps at zero', () {
      expect(BootSequence().finalHold, const Duration(milliseconds: 600));

      // Stage gaps large enough to exhaust the hold must clamp, not go negative.
      final exhausted = BootSequence(
        stageGap: const Duration(milliseconds: 1000),
        minimumHold: const Duration(milliseconds: 1500),
      );
      expect(exhausted.finalHold, Duration.zero);
    });

    test('minimumHold is a floor — instant work cannot skip it', () async {
      final seq = BootSequence(
        stageGap: const Duration(milliseconds: 50),
        minimumHold: const Duration(milliseconds: 200),
      );
      final sw = Stopwatch()..start();
      await seq.run(onStage: (_, _, _) {}, work: Future.value(null));

      expect(
        sw.elapsedMilliseconds,
        greaterThanOrEqualTo(200),
        reason:
            'run() must take at least minimumHold even when work resolves '
            'instantly',
      );
    });

    test(
      'the hold is a floor, not a ceiling — slow work stretches it',
      () async {
        final seq = BootSequence(
          stageGap: const Duration(milliseconds: 50),
          minimumHold: const Duration(milliseconds: 200),
        );
        // finalHold = 200 - 50*2 = 100ms; work deliberately outlasts it.
        final work = Future<void>.delayed(const Duration(milliseconds: 300));
        final sw = Stopwatch()..start();
        await seq.run(onStage: (_, _, _) {}, work: work);

        expect(
          sw.elapsedMilliseconds,
          greaterThanOrEqualTo(300),
          reason: 'run() must stretch to cover work slower than finalHold (D7)',
        );
      },
    );

    test('work bounded by a timeout terminates the run', () async {
      final seq = BootSequence(
        stageGap: const Duration(milliseconds: 20),
        minimumHold: const Duration(milliseconds: 60),
      );
      // Same shape as coin_gecko_api.dart: .timeout(...) then a swallowing catch.
      final neverCompletes = Completer<void>().future
          .timeout(
            const Duration(milliseconds: 100),
            onTimeout: () => throw TimeoutException('simulated hang'),
          )
          .catchError((_) {});
      final sw = Stopwatch()..start();
      await seq.run(onStage: (_, _, _) {}, work: neverCompletes);

      expect(
        sw.elapsedMilliseconds,
        greaterThanOrEqualTo(100),
        reason: 'run() must terminate and take at least the bounded timeout',
      );
    });

    test('a rejecting work future is swallowed, never propagated', () async {
      final seq = BootSequence(
        stageGap: const Duration(milliseconds: 10),
        minimumHold: const Duration(milliseconds: 30),
      );
      final rejecting = Future<void>.delayed(
        const Duration(milliseconds: 5),
        () => throw Exception('simulated work failure'),
      );
      // Prime a second listener so the harness's zone does not report the
      // deliberately-thrown error as unhandled before run() awaits it. Futures
      // support multiple independent listeners, so this does not interfere.
      rejecting.catchError((_) {});

      await expectLater(
        seq.run(onStage: (_, _, _) {}, work: rejecting),
        completes,
        reason: 'a rejecting work future must not strand the boot screen',
      );
    });

    test(
      'drives D5\'s three stages in order with the right rail targets',
      () async {
        final seq = BootSequence(); // D5 defaults: stageGap 450ms, hold 1500ms
        final calls = <(BootStage, double, Duration)>[];
        await seq.run(
          onStage: (stage, target, duration) =>
              calls.add((stage, target, duration)),
          work: Future.value(null),
        );

        expect(calls.length, 3);
        expect(calls[0].$1, BootStage.walletsReady);
        expect(calls[0].$2, 1 / 3);
        expect(calls[1].$1, BootStage.balancesReady);
        expect(calls[1].$2, 2 / 3);
        expect(calls[2].$1, BootStage.marketsReady);
        expect(calls[2].$2, 1.0);
        expect(
          calls[2].$3,
          seq.finalHold,
          reason: 'the final ramp must run for finalHold',
        );
      },
    );
  });
}
