import 'package:dio/dio.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
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

  @override
  Future<List<SwapToken>> tokens(String chainId) async {
    final catalogue = await _catalogue();
    return catalogue.where((token) => token.chainId == chainId).toList();
  }
}

/// One call answers every chain and the tier allows one request a second, so
/// the catalogue is read once a session rather than once per picker open.
Future<List<SwapToken>>? _pendingCatalogue;

Future<List<SwapToken>> _catalogue() async {
  final pending = _pendingCatalogue ??= _fetchCatalogue();
  try {
    return await pending;
  } catch (_) {
    // A failure must not be cached, or every later open inherits it.
    _pendingCatalogue = null;
    rethrow;
  }
}

/// `/v2/sdk-info` read off the generated transport but NOT through
/// `getSDKInfo()`: the live response carries a null `enableBoostByDefault`,
/// which the generated model rejects as non-nullable and takes the token list
/// down with it. Only `tokens` is read here, through the generated serializer.
Future<List<SwapToken>> _fetchCatalogue() async {
  final response = await squidDio().get<Object>(
    '/v2/sdk-info',
    options: Options(extra: kSquidAuthExtra),
  );

  final body = response.data;
  final entries = body is Map ? body['tokens'] : null;
  if (entries is! List) {
    throw StateError('Squid answered with no catalogue');
  }

  final tokens = <SwapToken>[];
  for (final entry in entries) {
    final token = _deserialize(entry);
    // A token we cannot parse or cannot size is a token we cannot offer. It
    // is dropped rather than shown, and it can never reach an amount.
    if (token == null ||
        token.disabled == true ||
        !isPlausibleDecimals(token.decimals)) {
      continue;
    }
    tokens.add(_swapToken(token));
  }
  return tokens;
}

Token? _deserialize(Object? entry) {
  try {
    return standardSerializers.deserializeWith(Token.serializer, entry);
  } catch (_) {
    return null;
  }
}

/// `decimals` is a `num` on the wire and a chain id is a `String`. Converting
/// once here is what keeps every comparison site downstream from doing it.
SwapToken _swapToken(Token token) => SwapToken(
  chainId: token.chainId,
  address: token.address,
  name: token.name,
  symbol: token.symbol,
  decimals: token.decimals.toInt(),
  logoUri: token.logoURI,
);

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
