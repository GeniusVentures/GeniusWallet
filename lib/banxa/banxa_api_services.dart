import 'dart:convert';

import 'package:genius_wallet/banxa/banxa_env.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:http/http.dart' as http;

/// A Banxa call that did not come back 2xx. Carries the status code only: the
/// response body can echo request data, so it never reaches a message or log.
class BanxaRequestException implements Exception {
  const BanxaRequestException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'Banxa request failed ($statusCode)';
}

class BanxaApiService {
  BanxaApiService({
    String apiKey = kBanxaApiKey,
    bool sandbox = kBanxaSandbox,
    http.Client? client,
  }) : _apiKey = apiKey,
       _sandbox = sandbox,
       _client = client ?? http.Client();

  final String _apiKey;
  final bool _sandbox;
  final http.Client _client;

  /// The one return address for every order. If Banxa rejects a custom scheme,
  /// switch it to an https page on gnus.ai; the return matcher compares
  /// scheme, host and path, so it follows.
  static const redirectUrl = 'geniuswallet://banxa/callback';
  static final Uri returnUri = Uri.parse(redirectUrl);

  bool get isConfigured => _apiKey.isNotEmpty;
  bool get isSandbox => _sandbox;

  String get _baseUrl => banxaApiBase(sandbox: _sandbox);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  void _check(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw BanxaRequestException(response.statusCode);
    }
  }

  Future<List<FiatCurrency>> getFiatCurrencies() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/fiats/buy'),
      headers: _headers,
    );
    _check(response);
    final List data = json.decode(response.body);
    return data.map((e) => FiatCurrency.fromJson(e)).toList();
  }

  Future<Quote> getQuote({
    String orderType = 'buy',
    required String paymentMethodId,
    required String crypto,
    required String blockchain,
    required String fiat,
    String? fiatAmount,
    String? cryptoAmount,
    String? externalCustomerId,
    String? ipAddress,
    String? discountCode,
  }) async {
    if ((fiatAmount == null || fiatAmount.isEmpty) &&
        (cryptoAmount == null || cryptoAmount.isEmpty)) {
      throw ArgumentError(
        'Either fiatAmount or cryptoAmount must be provided.',
      );
    }

    final queryParams = <String, String>{
      'paymentMethodId': paymentMethodId,
      'crypto': crypto,
      'blockchain': blockchain,
      'fiat': fiat,
      'fiatAmount': ?fiatAmount,
      'cryptoAmount': ?cryptoAmount,
      'externalCustomerId': ?externalCustomerId,
      'ipAddress': ?ipAddress,
      'discountCode': ?discountCode,
    };

    final uri = Uri.parse(
      '$_baseUrl/quotes/$orderType',
    ).replace(queryParameters: queryParams);

    final response = await _client.get(uri, headers: _headers);
    _check(response);
    final Map<String, dynamic> jsonMap = json.decode(response.body);
    return Quote.fromJson(jsonMap);
  }

  Future<List<CryptoCurrency>> getCryptoCurrencies() async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/crypto/buy'),
      headers: _headers,
    );
    _check(response);
    final List data = json.decode(response.body);
    return data.map((e) => CryptoCurrency.fromJson(e)).toList();
  }

  Future<OrderResponse> createBuyOrder({
    required String fiatCurrency,
    required String cryptoCurrency,
    required String paymentMethodId,
    required String walletAddress,
    required String blockchain,
    required String cryptoAmount,
    String? fiatAmount,
    String? externalCustomerId,
    String? metadata,
    String? subPartnerId,
  }) async {
    final extOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';

    final bodyMap = {
      'fiat': fiatCurrency,
      'crypto': cryptoCurrency,
      'blockchain': blockchain,
      'walletAddress': walletAddress,
      'paymentMethodId': paymentMethodId,
      'redirectUrl': redirectUrl,
      'cryptoAmount': cryptoAmount,
      'fiatAmount': ?fiatAmount,
      'externalCustomerId': ?externalCustomerId,
      'externalOrderId': extOrderId,
      'metadata': ?metadata,
      'subPartnerId': ?subPartnerId,
    };

    final response = await _client.post(
      Uri.parse('$_baseUrl/buy'),
      headers: _headers,
      body: json.encode(bodyMap),
    );
    _check(response);
    return OrderResponse.fromJson(json.decode(response.body));
  }

  /// Fetches EVERY order in the window, not just the first page.
  ///
  /// The `limit` is per-request, and the response's own `total` says how many
  /// exist — so a user with more than [pageSize] orders used to lose the rest
  /// silently, with no marker in the UI that the list was cut.
  ///
  /// [externalCustomerId] has no fallback on purpose. It used to default to
  /// the literal `'your-cust-id'`, which matched nothing and made every
  /// unspecified call look like "this user has no orders" rather than "nobody
  /// said whose orders to fetch". A null id now returns an empty response
  /// without a network round trip.
  ///
  /// ponytail: pages via a `page` query parameter, which is the shape Banxa's
  /// v2 order list uses. If the server ignores it, the second page comes back
  /// identical to the first — so the loop stops on a repeated leading order id
  /// rather than spinning or duplicating rows. Ceiling: at most [maxPages]
  /// requests (2,000 orders) even if `total` claims more. Upgrade path: a
  /// cursor, if Banxa exposes one.
  Future<OrdersResponse> fetchAllOrders({
    required String startDateUtc,
    required String endDateUtc,
    String status = '',
    int pageSize = 100,
    int maxPages = 20,
    String? externalCustomerId,
  }) async {
    if (externalCustomerId == null || externalCustomerId.isEmpty) {
      return OrdersResponse(orders: const [], total: 0, pageTotal: 0);
    }

    final collected = <Order>[];
    var total = 0;
    var pageTotal = 0;
    String? previousFirstOrderId;

    for (var page = 1; page <= maxPages; page++) {
      final uri = Uri.parse('$_baseUrl/orders').replace(
        queryParameters: {
          'start': startDateUtc,
          'end': endDateUtc,
          if (status.isNotEmpty) 'status': status,
          'limit': pageSize.toString(),
          'page': page.toString(),
          'externalCustomerId': externalCustomerId,
        },
      );

      final response = await _client.get(uri, headers: _headers);
      _check(response);

      final parsed = OrdersResponse.fromJson(json.decode(response.body));
      total = parsed.total;
      pageTotal = parsed.pageTotal;

      if (parsed.orders.isEmpty) {
        break;
      }

      // A server that ignores `page` hands back page 1 forever. Detect it by
      // its leading id and stop, instead of accumulating the same rows.
      final firstOrderId = parsed.orders.first.id;
      if (page > 1 && firstOrderId == previousFirstOrderId) {
        break;
      }
      previousFirstOrderId = firstOrderId;

      collected.addAll(parsed.orders);

      if (parsed.orders.length < pageSize || collected.length >= total) {
        break;
      }
    }

    return OrdersResponse(
      orders: collected,
      total: total,
      pageTotal: pageTotal,
    );
  }

  Future<Order> getOrderById(String orderId) async {
    final response = await _client.get(
      Uri.parse('$_baseUrl/orders/$orderId'),
      headers: _headers,
    );
    _check(response);
    return Order.fromJson(json.decode(response.body));
  }
}
