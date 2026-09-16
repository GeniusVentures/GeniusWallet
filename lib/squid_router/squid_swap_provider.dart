import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:squidrouter/squidrouter.dart';

/// The Squid adapter — the only file that knows Squid's wire types exist.
/// Everything above it speaks [SwapQuote] and [SwapQuoteRequest].
class SquidSwapProvider implements SwapProvider {
  const SquidSwapProvider();

  @override
  Future<SwapQuote> quote(SwapQuoteRequest request) async {
    final response = await squidApi().getRoute(
      routeRequest: _routeRequest(request),
    );
    final route = response.data;

    if (route == null) {
      throw StateError('Squid answered with no route');
    }

    return squidQuote(route);
  }
}

/// The wiring point. A different aggregator replaces this line and nothing
/// else outside its own adapter.
const SwapProvider swapProvider = SquidSwapProvider();

/// `quoteOnly` is what keeps the quote path harmless: Squid answers with an
/// empty transactionRequest, so no signable call ever reaches the screen.
RouteRequest _routeRequest(SwapQuoteRequest request) => RouteRequest(
  (b) => b
    ..fromChain = request.fromChainId
    ..fromToken = request.fromToken
    ..fromAmount = request.fromAmount.toString()
    ..toChain = request.toChainId
    ..toToken = request.toToken
    ..fromAddress = request.fromAddress
    ..toAddress = request.toAddress
    ..slippage = request.slippage
    ..quoteOnly = true,
);

/// Squid's estimate mapped into our own type, once. Public so the recorded
/// fixtures can prove the mapping with no network and no credential.
SwapQuote squidQuote(RouteResponseData route) {
  final estimate = route.route.estimate;
  final fromAmount = BigInt.parse(estimate.fromAmount);
  final toAmount = BigInt.parse(estimate.toAmount);

  return SwapQuote(
    id: route.route.quoteId,
    exchangeRate: estimate.exchangeRate,
    priceImpact: estimate.aggregatePriceImpact,
    fromAmount: fromAmount,
    toAmount: toAmount,
    toAmountMin: BigInt.parse(estimate.toAmountMin),
    // Each side scales by its own token's decimals. Sharing one value here
    // is how an 18-decimal pay side gets rendered as a 6-decimal receive.
    fromAmountDisplay: formatTokenAmount(
      fromAmount,
      estimate.fromToken.decimals.toInt(),
    ),
    toAmountDisplay: formatTokenAmount(
      toAmount,
      estimate.toToken.decimals.toInt(),
    ),
    feesUsd: _sumUsd(estimate.feeCosts.map((fee) => fee.amountUsd)),
    gasUsd: _sumUsd(estimate.gasCosts.map((gas) => gas.amountUsd)),
    estimatedDuration: Duration(
      seconds: estimate.estimatedRouteDuration.round(),
    ),
  );
}

/// A cost Squid sends as an unparseable string is worth nothing here, not a
/// crash on a screen the user is mid-swap on.
double _sumUsd(Iterable<String> amounts) =>
    amounts.fold(0.0, (sum, usd) => sum + (double.tryParse(usd) ?? 0.0));
