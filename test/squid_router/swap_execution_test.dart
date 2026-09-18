// The whole swap, minus the screen — and the invariant that guards it.
//
// The bug this phase exists to kill was a success toast, a receipt and a
// stored row produced by code that never called the router. So the outcome
// type has exactly one shape carrying a hash, and `sideEffectsFor` answers
// all-false for every other shape. The last group is that guard; it is the
// most important set of assertions in the phase.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/squid_router/swap_execution.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

const _token = '0x6B175474E89094C44Da98b954EedeAC495271d0F';
const _native = '0x0000000000000000000000000000000000000000';
const _spender = '0xce16F69375520ab01377ce7B88f5BA8C48F8D666';
const _hash = '0xabc123';

final _amount = BigInt.from(1500000000000000000);

SwapTransaction _route() => const SwapTransaction(
  quoteId: 'q1',
  requestId: 'r1',
  spender: _spender,
  request: {'from': '0x1', 'to': _spender, 'value': '0x0', 'data': '0xdead'},
);

/// Records what the orchestrator actually did, so a test can assert on the
/// calls that were NOT made — which is most of what matters here.
class _Steps {
  _Steps({
    this.routeError,
    this.allowance,
    this.approveResult = true,
    this.approveError,
    this.sendResult = _hash,
    this.sendError,
    this.statuses = const [SwapStatus.success],
    this.recoveryUrl,
  });

  final Error? routeError;
  final BigInt? allowance;
  final bool approveResult;
  final Error? approveError;
  final String? sendResult;
  final Error? sendError;
  final List<SwapStatus> statuses;
  final String? recoveryUrl;

  final List<BigInt> approvals = [];
  final List<Map<String, String>> sends = [];
  int allowanceReads = 0;
  int statusReads = 0;
  int waits = 0;

  Future<SwapOutcome> run({String tokenAddress = _token, int attempts = 4}) =>
      executeSwap(
        tokenAddress: tokenAddress,
        amount: _amount,
        fetchRoute: () async {
          if (routeError != null) {
            throw routeError!;
          }
          return _route();
        },
        readAllowance: (spender) async {
          allowanceReads++;
          return allowance ?? BigInt.zero;
        },
        approve: (spender, amount) async {
          if (approveError != null) {
            throw approveError!;
          }
          approvals.add(amount);
          return approveResult;
        },
        send: (request) async {
          if (sendError != null) {
            throw sendError!;
          }
          sends.add(request);
          return sendResult;
        },
        readStatus: (route, hash) async {
          final answer = statuses[statusReads.clamp(0, statuses.length - 1)];
          statusReads++;
          if (answer == SwapStatus.notFound && statusReads == 1) {
            // The live API answers 404 for a transaction it has not indexed
            // yet, which reaches this callback as a throw.
            throw StateError('404 No transaction found');
          }
          return SwapSettlement(status: answer, recoveryUrl: recoveryUrl);
        },
        pollAttempts: attempts,
        wait: (_) async => waits++,
      );
}

void main() {
  group('the route', () {
    test('a failed re-fetch sends nothing and carries no hash', () async {
      final steps = _Steps(routeError: StateError('price impact'));
      final outcome = await steps.run();

      expect(outcome, isA<SwapRouteUnavailable>());
      expect(steps.sends, isEmpty);
      expect(steps.approvals, isEmpty);
      expect(steps.allowanceReads, 0);
    });
  });

  group('the approval', () {
    test('a sufficient allowance is not topped up', () async {
      final steps = _Steps(allowance: _amount);
      final outcome = await steps.run();

      expect(steps.approvals, isEmpty);
      expect(steps.sends, hasLength(1));
      expect(outcome, isA<SwapBroadcast>());
    });

    test(
      'a short allowance is approved for the swap amount and no more',
      () async {
        final steps = _Steps(allowance: BigInt.one);
        await steps.run();

        // Exactly one approval, for exactly this swap. Never uint256 max.
        expect(steps.approvals, [_amount]);
      },
    );

    test('the native coin is never approved and never read', () async {
      final steps = _Steps();
      final outcome = await steps.run(tokenAddress: _native);

      expect(steps.allowanceReads, 0);
      expect(steps.approvals, isEmpty);
      expect(outcome, isA<SwapBroadcast>());
    });

    test('a rejected approval stops before the send', () async {
      final steps = _Steps(allowance: BigInt.zero, approveResult: false);
      final outcome = await steps.run();

      expect(outcome, isA<SwapApprovalFailed>());
      expect(steps.sends, isEmpty);
    });

    test('a thrown approval stops before the send', () async {
      final steps = _Steps(approveError: StateError('user rejected'));
      final outcome = await steps.run();

      expect(outcome, isA<SwapApprovalFailed>());
      expect(steps.sends, isEmpty);
    });

    test('an unreadable allowance is its own failure, not an approval one', () {
      // Whether an approval was even needed is unknown, so the two cannot
      // share a message. 26-07 gives each its own.
      expect(
        const SwapAllowanceUnreadable(null),
        isNot(isA<SwapApprovalFailed>()),
      );
    });
  });

  group('the send', () {
    test('a thrown send carries no hash', () async {
      final steps = _Steps(sendError: StateError('nonce too low'));
      expect(await steps.run(), isA<SwapSendFailed>());
    });

    test('a send that answers no hash carries no hash', () async {
      final steps = _Steps(sendResult: null);
      expect(await steps.run(), isA<SwapSendFailed>());
    });

    test('an empty hash is not a hash', () async {
      final steps = _Steps(sendResult: '');
      expect(await steps.run(), isA<SwapSendFailed>());
    });

    test('a successful send carries the hash the signer returned', () async {
      final steps = _Steps();
      final outcome = await steps.run();

      expect(outcome, isA<SwapBroadcast>());
      expect((outcome as SwapBroadcast).hash, _hash);
      expect(steps.sends.single, _route().request);
    });
  });

  group('polling', () {
    test('an ongoing status polls again; a terminal one stops', () async {
      final steps = _Steps(
        allowance: _amount,
        statuses: const [
          SwapStatus.ongoing,
          SwapStatus.ongoing,
          SwapStatus.success,
        ],
      );
      final outcome = await steps.run();

      expect(steps.statusReads, 3);
      expect((outcome as SwapBroadcast).status, TransactionStatus.completed);
    });

    test('a status that never resolves stops at the attempt bound', () async {
      final steps = _Steps(
        allowance: _amount,
        statuses: const [SwapStatus.ongoing],
      );
      final outcome = await steps.run(attempts: 4);

      expect(steps.statusReads, 4);
      // Unresolved is unresolved. Never completed.
      expect((outcome as SwapBroadcast).status, TransactionStatus.pending);
    });

    test(
      'a failed status read keeps the hash rather than losing the swap',
      () async {
        // The first read throws, exactly as the live 404 does.
        final steps = _Steps(
          allowance: _amount,
          statuses: const [SwapStatus.notFound],
        );
        final outcome = await steps.run(attempts: 2);

        expect(outcome, isA<SwapBroadcast>());
        expect((outcome as SwapBroadcast).hash, _hash);
        expect(outcome.status, TransactionStatus.pending);
      },
    );

    test('polling waits between attempts, never between none', () async {
      final settled = _Steps(
        allowance: _amount,
        statuses: const [SwapStatus.success],
      );
      await settled.run();
      expect(settled.waits, 0, reason: 'a first-read success must not sleep');
    });
  });

  group('the recovery link', () {
    test('a settled swap carries the link the status call returned', () async {
      const url = 'https://axelarscan.io/gmp/0xabc';
      final steps = _Steps(
        allowance: _amount,
        statuses: const [SwapStatus.needsGas],
        recoveryUrl: url,
      );
      final outcome = await steps.run();

      expect((outcome as SwapBroadcast).recoveryUrl, url);
    });

    test('no link sent means no link carried, never a composed one', () async {
      final steps = _Steps(
        allowance: _amount,
        statuses: const [SwapStatus.needsGas],
      );
      final outcome = await steps.run();

      expect((outcome as SwapBroadcast).recoveryUrl, isNull);
    });
  });

  group('every Squid status has a wallet status', () {
    test('the mapping is total and says only what happened', () {
      expect(walletStatusFor(SwapStatus.success), TransactionStatus.completed);
      expect(
        walletStatusFor(SwapStatus.partialSuccess),
        TransactionStatus.partialSuccess,
      );
      expect(walletStatusFor(SwapStatus.needsGas), TransactionStatus.needsGas);
      expect(walletStatusFor(SwapStatus.refunded), TransactionStatus.refunded);
      expect(
        walletStatusFor(SwapStatus.failedOnDestination),
        TransactionStatus.failed,
      );
      // Neither of these is an answer yet.
      expect(walletStatusFor(SwapStatus.ongoing), TransactionStatus.pending);
      expect(walletStatusFor(SwapStatus.notFound), TransactionStatus.pending);
    });

    test('only a resolved answer is terminal', () {
      expect(isTerminal(SwapStatus.ongoing), isFalse);
      // Not indexed yet is not the same as not there.
      expect(isTerminal(SwapStatus.notFound), isFalse);
      for (final s in [
        SwapStatus.success,
        SwapStatus.partialSuccess,
        SwapStatus.needsGas,
        SwapStatus.refunded,
        SwapStatus.failedOnDestination,
      ]) {
        expect(isTerminal(s), isTrue, reason: '$s should stop the poll');
      }
    });
  });

  group('THE GUARD: no hash, no side effects', () {
    test('every outcome without a hash produces none of the three', () {
      for (final outcome in <SwapOutcome>[
        const SwapRouteUnavailable(null),
        const SwapRouteUnsignable(null),
        const SwapAllowanceUnreadable(null),
        const SwapApprovalFailed(null),
        const SwapSendFailed(null),
      ]) {
        final effects = sideEffectsFor(outcome);
        expect(effects.showToast, isFalse, reason: '$outcome toasted');
        expect(
          effects.showReceipt,
          isFalse,
          reason: '$outcome opened a receipt',
        );
        expect(effects.storeRow, isFalse, reason: '$outcome wrote a row');
      }
    });

    test('a broadcast swap produces all three', () {
      final effects = sideEffectsFor(
        SwapBroadcast(
          hash: _hash,
          status: TransactionStatus.completed,
          transaction: _route(),
        ),
      );
      expect(effects.showToast, isTrue);
      expect(effects.showReceipt, isTrue);
      expect(effects.storeRow, isTrue);
    });

    test(
      'a broadcast swap still shows its row when the status is not success',
      () {
        // The funds moved. Hiding the row because the outcome was partial would
        // be the same class of lie as showing one when nothing moved.
        final effects = sideEffectsFor(
          SwapBroadcast(
            hash: _hash,
            status: TransactionStatus.pending,
            transaction: _route(),
          ),
        );
        expect(effects.storeRow, isTrue);
      },
    );
  });

  group('the broadcast is announced', () {
    test('before settling begins, not after it finishes', () async {
      // Settling polls for up to a minute. Whatever records the transfer has
      // to hear the hash first: a crash inside that window would otherwise
      // leave no trace at all of funds that have already left the wallet.
      final order = <String>[];

      await executeSwap(
        tokenAddress: _token,
        amount: _amount,
        fetchRoute: () async => _route(),
        readAllowance: (spender) async => _amount,
        approve: (spender, amount) async => true,
        send: (request) async {
          order.add('send');
          return _hash;
        },
        readStatus: (route, hash) async {
          order.add('status');
          return const SwapSettlement(status: SwapStatus.success);
        },
        wait: (delay) async {},
        onBroadcast: (hash) async => order.add('broadcast:$hash'),
      );

      expect(order.first, 'send');
      expect(order[1], 'broadcast:$_hash');
      expect(order.skip(2), everyElement('status'));
    });

    test('never for a send that produced no hash', () async {
      // No hash means nothing reached the network, so a row written here would
      // be a record of something that did not happen.
      var announced = false;

      final outcome = await executeSwap(
        tokenAddress: _token,
        amount: _amount,
        fetchRoute: () async => _route(),
        readAllowance: (spender) async => _amount,
        approve: (spender, amount) async => true,
        send: (request) async => null,
        readStatus: (route, hash) async =>
            const SwapSettlement(status: SwapStatus.success),
        wait: (delay) async {},
        onBroadcast: (hash) async => announced = true,
      );

      expect(announced, isFalse);
      expect(outcome, isA<SwapSendFailed>());
    });
  });
}
