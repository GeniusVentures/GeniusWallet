import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/squid_router/swap_allowance.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';

/// What a swap attempt turned out to be. **Exactly one shape carries a hash.**
///
/// The bug this replaces produced a success toast, a receipt and a stored row
/// from code that never called the router. Sealed, so a new shape is a compile
/// error in [sideEffectsFor] rather than a silent fourth way to lie.
sealed class SwapOutcome {
  const SwapOutcome();
}

/// The executable route never arrived. Nothing was approved and nothing sent.
final class SwapRouteFailed extends SwapOutcome {
  const SwapRouteFailed(this.error);

  final Object? error;
}

/// The allowance could not be read, or the approval failed or was rejected.
/// The send was not attempted.
final class SwapApprovalFailed extends SwapOutcome {
  const SwapApprovalFailed(this.error);

  final Object? error;
}

/// The signer refused or the broadcast failed, so no hash exists.
final class SwapSendFailed extends SwapOutcome {
  const SwapSendFailed(this.error);

  final Object? error;
}

/// Funds moved. The only shape carrying a hash, and the only one that may
/// produce a side effect.
final class SwapBroadcast extends SwapOutcome {
  const SwapBroadcast({
    required this.hash,
    required this.status,
    required this.transaction,
  });

  final String hash;

  /// What the aggregator actually reported, or pending when polling ran out.
  /// Never a status assumed at submit time.
  final TransactionStatus status;
  final SwapTransaction transaction;
}

/// What the screen is permitted to do about an outcome. The screen may not
/// decide this for itself — that is how the original bug was written.
class SwapSideEffects {
  const SwapSideEffects({
    required this.showToast,
    required this.showReceipt,
    required this.storeRow,
  });

  final bool showToast;
  final bool showReceipt;
  final bool storeRow;
}

const SwapSideEffects _none = SwapSideEffects(
  showToast: false,
  showReceipt: false,
  storeRow: false,
);

/// All three are false for every outcome without a hash. Exhaustive on
/// purpose: a new [SwapOutcome] must decide this here, not default into it.
SwapSideEffects sideEffectsFor(SwapOutcome outcome) => switch (outcome) {
  // A row is written even when the status is not success: the funds moved,
  // and hiding that is the same class of lie as showing a row when they did
  // not.
  SwapBroadcast() => const SwapSideEffects(
    showToast: true,
    showReceipt: true,
    storeRow: true,
  ),
  SwapRouteFailed() => _none,
  SwapApprovalFailed() => _none,
  SwapSendFailed() => _none,
};

/// The wallet's own reading of an aggregator status. `pending` means the swap
/// has no answer yet — it is never used to stand in for one.
TransactionStatus walletStatusFor(SwapStatus status) => switch (status) {
  SwapStatus.success => TransactionStatus.completed,
  SwapStatus.partialSuccess => TransactionStatus.partialSuccess,
  SwapStatus.needsGas => TransactionStatus.needsGas,
  SwapStatus.refunded => TransactionStatus.refunded,
  SwapStatus.failedOnDestination => TransactionStatus.failed,
  SwapStatus.ongoing || SwapStatus.notFound => TransactionStatus.pending,
};

/// Whether polling has its answer. `notFound` is not one: right after a
/// broadcast it means "not indexed yet", and stopping there would abandon a
/// swap that is on chain.
bool isTerminal(SwapStatus status) => switch (status) {
  SwapStatus.ongoing || SwapStatus.notFound => false,
  SwapStatus.success ||
  SwapStatus.partialSuccess ||
  SwapStatus.needsGas ||
  SwapStatus.refunded ||
  SwapStatus.failedOnDestination => true,
};

/// The orchestrator's shape, so a screen can take it as a parameter and a
/// case can drive every outcome without a network, a key or a wallet.
typedef SwapExecutor =
    Future<SwapOutcome> Function({
      required String tokenAddress,
      required BigInt amount,
      required Future<SwapTransaction> Function() fetchRoute,
      required Future<BigInt> Function(String spender) readAllowance,
      required Future<bool> Function(String spender, BigInt amount) approve,
      required Future<String?> Function(Map<String, String> request) send,
      required Future<SwapStatus> Function(SwapTransaction route, String hash)
      readStatus,
      required Future<void> Function(Duration delay) wait,
      int pollAttempts,
      Duration pollInterval,
    });

/// Runs a swap end to end: executable route, approval if the allowance is
/// short, send, then poll until the status is real.
///
/// Every dependency is injected, so this holds no client, no key and no
/// context. [amount] and the allowance are RAW base units.
Future<SwapOutcome> executeSwap({
  required String tokenAddress,
  required BigInt amount,
  required Future<SwapTransaction> Function() fetchRoute,
  required Future<BigInt> Function(String spender) readAllowance,
  required Future<bool> Function(String spender, BigInt amount) approve,
  required Future<String?> Function(Map<String, String> request) send,
  required Future<SwapStatus> Function(SwapTransaction route, String hash)
  readStatus,
  required Future<void> Function(Duration delay) wait,
  int pollAttempts = 20,
  Duration pollInterval = const Duration(seconds: 3),
}) async {
  // The quote on screen was fetched with quoteOnly, so it carries nothing
  // signable. Submitting re-fetches; the displayed quote is never signed.
  final SwapTransaction route;
  try {
    route = await fetchRoute();
  } catch (error) {
    return SwapRouteFailed(error);
  }

  try {
    // The native coin has no contract to approve, so its allowance is never
    // read — a call that would fail anyway.
    final allowance = isNativeToken(tokenAddress)
        ? BigInt.zero
        : await readAllowance(route.spender);
    final decision = decideApproval(
      tokenAddress: tokenAddress,
      allowance: allowance,
      amount: amount,
    );

    if (decision is ApproveExactAmount) {
      final granted = await approve(route.spender, decision.amount);
      if (!granted) {
        return const SwapApprovalFailed(null);
      }
    }
  } catch (error) {
    return SwapApprovalFailed(error);
  }

  final String? hash;
  try {
    hash = await send(route.request);
  } catch (error) {
    return SwapSendFailed(error);
  }
  if (hash == null || hash.isEmpty) {
    return const SwapSendFailed(null);
  }

  return SwapBroadcast(
    hash: hash,
    status: walletStatusFor(
      await _poll(
        route: route,
        hash: hash,
        readStatus: readStatus,
        wait: wait,
        attempts: pollAttempts,
        interval: pollInterval,
      ),
    ),
    transaction: route,
  );
}

/// Polls until the status resolves or the attempts run out. A read that
/// throws — which is how the live 404 for an unindexed transaction arrives —
/// is another "not yet", never a reason to discard the hash.
Future<SwapStatus> _poll({
  required SwapTransaction route,
  required String hash,
  required Future<SwapStatus> Function(SwapTransaction route, String hash)
  readStatus,
  required Future<void> Function(Duration delay) wait,
  required int attempts,
  required Duration interval,
}) async {
  var status = SwapStatus.ongoing;

  for (var attempt = 0; attempt < attempts; attempt++) {
    if (attempt > 0) {
      await wait(interval);
    }
    try {
      status = await readStatus(route, hash);
    } catch (_) {
      status = SwapStatus.notFound;
    }
    if (isTerminal(status)) {
      return status;
    }
  }

  // Unresolved is unresolved. `walletStatusFor` reads this as pending.
  return status;
}
