import 'package:dio/dio.dart';
import 'package:genius_wallet/squid_router/squid_client.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_provider.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/swap/swap_token.dart';
import 'package:genius_wallet/swap/swap_transaction.dart';
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
  Future<SwapTransaction> buildTransaction(SwapQuoteRequest request) async {
    // Raw dio for the same reason the catalogue uses it: the generated model
    // resolves transactionRequest through a oneOf that collapses the object
    // into a ListJsonObject, so the signable half is unreachable through it.
    final response = await squidDio().post<Object>(
      '/v2/route',
      options: Options(extra: kSquidAuthExtra),
      data: {..._routeBody(request), 'quoteOnly': false},
    );

    final body = response.data;
    if (body is! Map<String, dynamic>) {
      throw const SwapRouteException(SwapRouteFailure.unavailable);
    }

    return squidTransaction(
      body,
      from: request.fromAddress,
      requestId: response.headers.value('x-request-id'),
    );
  }

  @override
  Future<SwapSettlement> status(
    SwapTransaction transaction,
    String hash,
  ) async {
    final response = await squidDio().get<Object>(
      '/v2/status',
      queryParameters: {'quoteId': transaction.quoteId, 'transactionId': hash},
      options: Options(
        extra: kSquidAuthExtra,
        headers: {
          if (transaction.requestId != null) 'requestId': transaction.requestId,
        },
      ),
    );

    final body = response.data;
    if (body is! Map) {
      return const SwapSettlement(status: SwapStatus.notFound);
    }

    return SwapSettlement(
      status: swapStatusFrom(body['squidTransactionStatus']?.toString()),
      // Squid's own page for this transfer — where a paused one is resumed.
      // Absent is absent; nothing is built from the hash to stand in for it.
      recoveryUrl: body['axelarTransactionUrl']?.toString(),
    );
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

/// The route request as Squid's wire body. Shared by the quote and the
/// executable fetch, so the two can never describe different swaps.
Map<String, dynamic> _routeBody(SwapQuoteRequest request) => {
  'fromChain': request.fromChainId,
  'fromToken': request.fromToken,
  'fromAmount': request.fromAmount.toString(),
  'toChain': request.toChainId,
  'toToken': request.toToken,
  'fromAddress': request.fromAddress,
  'toAddress': request.toAddress,
  'slippage': request.slippage,
};

/// Squid's executable route unwrapped into ours, once. Public so the recorded
/// fixture can prove it with no network and no credential.
SwapTransaction squidTransaction(
  Map<String, dynamic> body, {
  required String from,
  required String? requestId,
}) {
  final route = body['route'];
  if (route is! Map) {
    throw const SwapRouteException(SwapRouteFailure.unavailable);
  }

  final wire = route['transactionRequest'];
  final target = wire is Map ? wire['target'] : null;
  final data = wire is Map ? wire['data'] : null;
  if (wire is! Map || target == null || data == null) {
    throw const SwapRouteException(SwapRouteFailure.unsignable);
  }
  if (wire['type'] != 'ON_CHAIN_EXECUTION') {
    throw SwapRouteException(
      SwapRouteFailure.unsignable,
      'route type ${wire['type']}',
    );
  }

  return SwapTransaction(
    quoteId: route['quoteId']?.toString() ?? '',
    requestId: requestId ?? wire['requestId']?.toString(),
    spender: target.toString(),
    request: {
      'from': from,
      'to': target.toString(),
      'data': data.toString(),
      'value': _hex(wire['value']),
      // `gas`, not `gasLimit`: the signer reads `tx['gas'] ?? tx['gasLimit']`.
      'gas': _hex(wire['gasLimit']),
      'maxFeePerGas': _hex(wire['maxFeePerGas']),
      'maxPriorityFeePerGas': _hex(wire['maxPriorityFeePerGas']),
    },
  );
}

/// Squid sends these as DECIMAL strings and the signer parses them as hex.
/// Passing them straight through reads a gasLimit of 969344 as 9,868,100.
String _hex(Object? value) {
  final text = value?.toString().trim() ?? '';
  if (text.isEmpty) {
    return '0x0';
  }
  if (text.startsWith('0x') || text.startsWith('0X')) {
    return text;
  }
  final parsed = BigInt.tryParse(text);
  if (parsed == null) {
    throw SwapRouteException(SwapRouteFailure.unsignable, 'number $text');
  }
  return '0x${parsed.toRadixString(16)}';
}

/// Squid's status vocabulary mapped onto ours. An unrecognised value is NOT
/// an answer — polling keeps going rather than resolving on a word we do not
/// know.
SwapStatus swapStatusFrom(String? reported) => switch (reported) {
  'success' => SwapStatus.success,
  'partial_success' => SwapStatus.partialSuccess,
  'needs_gas' => SwapStatus.needsGas,
  'ongoing' => SwapStatus.ongoing,
  'refunded' => SwapStatus.refunded,
  'failed_on_destination' => SwapStatus.failedOnDestination,
  _ => SwapStatus.notFound,
};
