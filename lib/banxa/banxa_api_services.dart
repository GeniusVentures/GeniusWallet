// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:genius_wallet/banxa/banxa_helpers/order_service.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BanxaApiService {
  static const String _partnerCode = 'gnus';
  static const String _apiKey = 'b8282030faffa2dc15fbf428142be5bdb1d4e346';
  static const String _baseUrl = 'https://api.banxa.com/$_partnerCode/v2';

  static const redirectUrl = 'geniuswallet://banxa/callback';
  static const String banxaKycUrl = 'https://$_partnerCode.banxa-sandbox.com';

  static Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'x-api-key': _apiKey,
  };

  static String generateHmacSignature(String message) {
    final key = utf8.encode(_apiKey);
    final bytes = utf8.encode(message);

    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);

    return digest.toString();
  }

  static Future<BanxaKycResponse?> submitKYC(
    Map<String, dynamic> kycData,
  ) async {
    final url = Uri.parse(
      'https://$_partnerCode.banxa-sandbox.com/api/identities',
    );

    try {
      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(kycData),
      );
      if (response.statusCode == 200) {
        return BanxaKycResponse.fromJson(jsonDecode(response.body));
      } else {
        print('Banxa KYC failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Banxa KYC error: $e');
      return null;
    }
  }

  Future<List<FiatCurrency>> getFiatCurrencies() async {
    const url = '$_baseUrl/fiats/buy';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => FiatCurrency.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load fiat currencies');
    }
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

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return Quote.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch quote (${response.statusCode}): ${response.body}',
      );
    }
  }

  Future<List<CryptoCurrency>> getCryptoCurrencies() async {
    const url = '$_baseUrl/crypto/buy';
    final response = await http.get(Uri.parse(url), headers: _headers);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((e) => CryptoCurrency.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load crypto currencies');
    }
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
    const url = '$_baseUrl/buy';
    final extOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
    final redirectUrl = Uri(
      scheme: 'geniuswallet',
      host: 'banxa',
      path: '/callback',
      queryParameters: {'extOrderId': extOrderId},
    ).toString();

    print('🫩 Redirect URL: $redirectUrl');

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

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: json.encode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final order = OrderResponse.fromJson(json.decode(response.body));

      if (order.orderId.isNotEmpty) {
        OrderLinker.instance.put(extOrderId, order.orderId);
      }

      return order;
    }

    throw Exception('Order failed (${response.statusCode}): ${response.body}');
  }

  Future<OrderStatus> getOrderStatus(String orderId) async {
    final url = '$_baseUrl/orders/$orderId';
    try {
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return OrderStatus.fromJson(data);
      } else {
        throw Exception(
          'Failed to fetch order status (${response.statusCode})',
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<OrderStatus> pollOrderStatus(
    String orderId, {
    Duration interval = const Duration(seconds: 5),
    Duration timeout = const Duration(minutes: 2),
  }) async {
    final completer = Completer<OrderStatus>();
    final stopwatch = Stopwatch()..start();

    Timer? timer;

    Future<void> checkStatus() async {
      try {
        final status = await getOrderStatus(orderId);

        print('Order status: ${status.status}');

        if (status.status.toLowerCase() == 'completed' ||
            status.status.toLowerCase() == 'failed' ||
            status.status.toLowerCase() == 'cancelled' ||
            status.status.toLowerCase() == 'inProgress' ||
            status.status.toLowerCase() == 'expired' ||
            status.status.toLowerCase() == 'declined') {
          timer?.cancel();
          completer.complete(status);
        } else if (stopwatch.elapsed >= timeout) {
          timer?.cancel();
          completer.completeError(Exception("Polling timed out"));
        }
      } catch (e) {
        timer?.cancel();
        completer.completeError(e);
      }
    }

    unawaited(checkStatus());

    timer = Timer.periodic(interval, (_) => checkStatus());

    return completer.future;
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
      final uri = Uri.https('api.banxa.com', '/$_partnerCode/v2/orders', {
        'start': startDateUtc,
        'end': endDateUtc,
        if (status.isNotEmpty) 'status': status,
        'limit': pageSize.toString(),
        'page': page.toString(),
        'externalCustomerId': externalCustomerId,
      });

      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json', 'x-api-key': _apiKey},
      );

      if (response.statusCode != 200) {
        print(
          'Failed to fetch orders: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Failed to fetch orders: ${response.statusCode}');
      }

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
    final url = '$_baseUrl/orders/$orderId';

    print('🟢 Fetching order with ID: $orderId');
    print('🔗 URL: $url');
    print('🛡️ Headers: $_headers');

    try {
      final resp = await http.get(Uri.parse(url), headers: _headers);

      print('📤 Status code: ${resp.statusCode}');
      print('📥 Response body: ${resp.body}');

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        print('✅ Order fetched successfully: $data');
        return Order.fromJson(data);
      } else if (resp.statusCode == 404) {
        throw Exception('❌ Order not found: $orderId');
      } else {
        throw Exception('❌ Failed to load order $orderId: ${resp.body}');
      }
    } catch (e, st) {
      print('💥 Exception fetching order: $e');
      print(st);
      rethrow;
    }
  }

  Future<void> openBanxaInBrowser(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
