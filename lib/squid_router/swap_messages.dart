import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/squid_router/swap_execution.dart';

/// What to tell the user about a swap that did not simply succeed, or null
/// when there is nothing to report.
///
/// Selected by outcome SHAPE, never built from a caught error: a Dio or RPC
/// string carries node URLs and addresses, and is not a sentence anyone can
/// act on. The switch has no default arm on purpose — a new outcome with no
/// message must fail to compile rather than fall through to something vague.
String? swapFailureMessage(SwapOutcome outcome) => switch (outcome) {
  SwapRouteUnavailable() =>
    'No route is available for this pair right now. Try a smaller amount or '
        'a different token.',
  SwapRouteUnsignable() =>
    'The route came back incomplete, so nothing was sent. Try again in a '
        'moment.',
  SwapAllowanceUnreadable() =>
    "This token's spending allowance could not be checked, so nothing was "
        'swapped. Check your connection and try again.',
  SwapApprovalFailed() =>
    'The spending approval did not go through, so nothing was swapped.',
  SwapSendFailed() =>
    'The swap could not be sent. Check that you have enough to cover gas, '
        'then try again.',
  SwapSendUnconfirmed() =>
    'The network did not answer, so the swap may or may not have been sent. '
        'Check your balance and transactions before you try again.',
  SwapFeesChanged() =>
    "The route's fees changed since this quote was shown, so nothing was "
        'sent. Refresh the quote to see the current fees.',
  SwapBroadcast(:final status) => _settledMessage(status),
};

/// A swap that reached the chain. The funds have moved, so none of these may
/// claim otherwise — only the terminal success is silent.
String? _settledMessage(TransactionStatus status) => switch (status) {
  TransactionStatus.completed => null,
  TransactionStatus.pending =>
    'Your swap was sent and has not settled yet. It will update in your '
        'transactions.',
  TransactionStatus.partialSuccess =>
    'The swap finished with a different token than expected. Check your '
        'transactions for what arrived.',
  TransactionStatus.needsGas =>
    'The swap is paused and needs gas on the destination chain before it can '
        'finish.',
  TransactionStatus.refunded =>
    'The swap could not complete, and your funds were returned.',
  TransactionStatus.failed =>
    'The swap failed after it was sent. Check your transactions for details.',
  TransactionStatus.cancelled => 'The swap was cancelled.',
};
