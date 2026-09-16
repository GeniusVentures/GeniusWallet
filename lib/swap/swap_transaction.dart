/// A route the wallet can actually sign, plus the handles needed to follow it
/// up. Aggregator-neutral: the adapter has already unwrapped the wire shape.
class SwapTransaction {
  const SwapTransaction({
    required this.quoteId,
    required this.requestId,
    required this.spender,
    required this.request,
  });

  /// The aggregator's handle for the route being executed.
  final String quoteId;

  /// Taken from the route call's response header, not its body — the body
  /// field is null, and status polling silently breaks without this.
  final String? requestId;

  /// The contract that will move the token, so it is what an ERC-20 approval
  /// must cover. Never a token address.
  final String spender;

  /// Ready for the signer: hex strings throughout, `to` rather than the
  /// aggregator's `target`, and the wallet address filled in as `from`.
  final Map<String, String> request;
}

/// What an aggregator reports about a broadcast swap. Ours, not a provider's
/// enum — the adapter maps its vocabulary onto these.
enum SwapStatus {
  ongoing,
  success,
  partialSuccess,
  needsGas,

  /// Not indexed yet, or not there at all. Right after a broadcast it is
  /// almost always the former, so it is NOT treated as an answer.
  notFound,
  failedOnDestination,
  refunded,
}
