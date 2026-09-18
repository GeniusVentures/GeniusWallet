/// What the app asks an aggregator for. Amounts are base units — the integer
/// the router spends — never the typed string.
class SwapQuoteRequest {
  const SwapQuoteRequest({
    required this.fromChainId,
    required this.fromToken,
    required this.fromAmount,
    required this.toChainId,
    required this.toToken,
    required this.fromAddress,
    required this.toAddress,
    required this.slippage,
  });

  final String fromChainId;
  final String fromToken;
  final BigInt fromAmount;
  final String toChainId;
  final String toToken;
  final String fromAddress;
  final String toAddress;
  final double slippage;
}

/// One route fee, named the way the aggregator named it. Rendered generically
/// so an unrecognised name still shows, never matched against a literal.
class FeeLine {
  const FeeLine({required this.name, required this.amountUsd});

  final String name;
  final double amountUsd;
}

/// What comes back. Rates and impact stay strings so no float rounding is
/// introduced between the aggregator and the screen; amounts that are spent
/// are BigInt, and the display forms are derived once by the adapter using
/// the decimals the aggregator itself reported.
class SwapQuote {
  const SwapQuote({
    required this.id,
    required this.exchangeRate,
    required this.priceImpact,
    required this.fromAmount,
    required this.toAmount,
    required this.toAmountMin,
    required this.fromAmountDisplay,
    required this.toAmountDisplay,
    required this.feesUsd,
    required this.gasUsd,
    required this.estimatedDuration,
    this.feeLines = const [],
  });

  /// The aggregator's handle for this quote, needed to follow it up later.
  final String id;
  final String exchangeRate;

  /// A percentage, as the aggregator expressed it — `0.03` means 0.03%.
  final String priceImpact;
  final BigInt fromAmount;
  final BigInt toAmount;

  /// The floor slippage protection enforces on chain.
  final BigInt toAmountMin;
  final String fromAmountDisplay;
  final String toAmountDisplay;
  final double feesUsd;
  final double gasUsd;
  final Duration estimatedDuration;

  /// Each fee the route charges, kept apart so none of them get merged into
  /// one figure. Empty on a same-chain route — that is the normal case, not
  /// a missing one.
  final List<FeeLine> feeLines;

  /// What the swap costs. Gas is part of that, so a screen showing fees
  /// alone would understate it.
  double get totalCostUsd => feesUsd + gasUsd;
}
