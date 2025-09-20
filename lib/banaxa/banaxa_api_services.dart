// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:async';

import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/banaxa/banxa_helpers/order_service.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class BanxaApiService {
  static const String _partnerCode = 'gnus';
  static const String _apiKey = 'f4618be892ba64672e6fae3aab374c374bd53126';
  static const String _baseUrl =
      'https://api.banxa-sandbox.com/$_partnerCode/v2';
  static const redirectUrl = 'geniuswallet://banxa/callback';

  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      };

  static Future<BanxaKycResponse?> submitKYC(
      Map<String, dynamic> kycData) async {
    final url =
        Uri.parse('https://$_partnerCode.banxa-sandbox.com/api/identities');

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
          'Either fiatAmount or cryptoAmount must be provided.');
    }

    final queryParams = <String, String>{
      'paymentMethodId': paymentMethodId,
      'crypto': crypto,
      'blockchain': blockchain,
      'fiat': fiat,
      if (fiatAmount != null) 'fiatAmount': fiatAmount,
      if (cryptoAmount != null) 'cryptoAmount': cryptoAmount,
      if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
      if (ipAddress != null) 'ipAddress': ipAddress,
      if (discountCode != null) 'discountCode': discountCode,
    };

    final uri = Uri.parse('$_baseUrl/quotes/$orderType')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return Quote.fromJson(jsonMap);
    } else {
      throw Exception(
          'Failed to fetch quote (${response.statusCode}): ${response.body}');
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
    String? email,
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
      if (fiatAmount != null) 'fiatAmount': fiatAmount,
      if (email != null) 'email': email,
      if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
      'externalOrderId': extOrderId,
      if (metadata != null) 'metadata': metadata,
      if (subPartnerId != null) 'subPartnerId': subPartnerId,
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
    print('Order response: ${response.statusCode} - ${response.body}');

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
            'Failed to fetch order status (${response.statusCode})');
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

    checkStatus();

    timer = Timer.periodic(interval, (_) => checkStatus());

    return completer.future;
  }

  Future<OrdersResponse> fetchAllOrders({
    required String startDateUtc,
    required String endDateUtc,
    String status = '',
    int limit = 100,
    String? externalCustomerId,
  }) async {
    final uri = Uri.https(
      'api.banxa-sandbox.com',
      '/$_partnerCode/v2/orders',
      {
        'start': startDateUtc,
        'end': endDateUtc,
        if (status.isNotEmpty) 'status': status,
        'limit': limit.toString(),
        'externalCustomerId': externalCustomerId ?? 'your-cust-id'
      },
    );

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'x-api-key': _apiKey,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return OrdersResponse.fromJson(data);
    } else {
      print(
          'Failed to fetch orders: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
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

//! For Production and real buying of the fiats
// class BanxaApiService {
//   static const String _partnerCode = 'gnus';
//   static const String _apiKey = 'f4618be892ba64672e6fae3aab374c374bd53126';
//   static const String _apiSecret = 'demo_SECRET_HERE';
//   static const String _baseUrl =
//       'https://api.banxa-sandbox.com/$_partnerCode/v2';
//   static const redirectUrl = 'geniuswallet://banxa/callback';
//   String _buildPath(String endpoint) => '/$_partnerCode/v2/$endpoint';

//   Map<String, String> _headers(String method, String path,
//           [Map<String, dynamic>? body]) =>
//       {
//         'Accept': 'application/json',
//         'Content-Type': 'application/json',
//         ..._banxaHmac(
//           method: method,
//           path: path,
//           apiKey: _apiKey,
//           apiSecret: _apiSecret,
//           body: body,
//         ),
//       };

//   Map<String, String> _banxaHmac({
//     required String method,
//     required String path,
//     required String apiKey,
//     required String apiSecret,
//     Map<String, dynamic>? body,
//   }) {
//     final ts = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
//     final nonce = const Uuid().v4();

//     final payload = <String>[
//       method.toUpperCase(),
//       path,
//       ts,
//       if (body != null) jsonEncode(body),
//     ].join('\n');

//     final sig = Hmac(sha256, utf8.encode(apiSecret))
//         .convert(utf8.encode(payload))
//         .toString();

//     return {
//       'X-BANXA-KEY': apiKey,
//       'X-BANXA-TIMESTAMP': ts,
//       'X-BANXA-NONCE': nonce,
//       'X-BANXA-SIGNATURE': sig,
//     };
//   }

//   // ---- Example: KYC submission (static for now) ----
//   static Future<BanxaKycResponse?> submitKYC(
//     Map<String, dynamic> kycData,
//   ) async {
//     const path = '/gnus/v2/identities';
//     final url = Uri.parse('https://api.banxa-sandbox.com$path');

//     final headers = BanxaApiService()._headers('POST', path, kycData);

//     try {
//       final response = await http.post(
//         url,
//         headers: headers,
//         body: jsonEncode(kycData),
//       );
//       if (response.statusCode == 200) {
//         return BanxaKycResponse.fromJson(jsonDecode(response.body));
//       } else {
//         print('Banxa KYC failed: ${response.body}');
//         return null;
//       }
//     } catch (e) {
//       print('Banxa KYC error: $e');
//       return null;
//     }
//   }

//   Future<List<FiatCurrency>> getFiatCurrencies() async {
//     const endpoint = 'fiats/buy';
//     const url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final response = await http.get(
//       Uri.parse(url),
//       headers: _headers('GET', path),
//     );

//     if (response.statusCode == 200) {
//       final List data = json.decode(response.body);
//       return data.map((e) => FiatCurrency.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load fiat currencies');
//     }
//   }

//   Future<Quote> getQuote({
//     String orderType = 'buy',
//     required String paymentMethodId,
//     required String crypto,
//     required String blockchain,
//     required String fiat,
//     String? fiatAmount,
//     String? cryptoAmount,
//     String? externalCustomerId,
//     String? ipAddress,
//     String? discountCode,
//   }) async {
//     if ((fiatAmount == null || fiatAmount.isEmpty) &&
//         (cryptoAmount == null || cryptoAmount.isEmpty)) {
//       throw ArgumentError(
//           'Either fiatAmount or cryptoAmount must be provided.');
//     }

//     final endpoint = 'quotes/$orderType';
//     final url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final queryParams = <String, String>{
//       'paymentMethodId': paymentMethodId,
//       'crypto': crypto,
//       'blockchain': blockchain,
//       'fiat': fiat,
//       if (fiatAmount != null) 'fiatAmount': fiatAmount,
//       if (cryptoAmount != null) 'cryptoAmount': cryptoAmount,
//       if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
//       if (ipAddress != null) 'ipAddress': ipAddress,
//       if (discountCode != null) 'discountCode': discountCode,
//     };

//     final uri = Uri.parse(url).replace(queryParameters: queryParams);

//     final response = await http.get(
//       uri,
//       headers: _headers('GET', path),
//     );

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> jsonMap = json.decode(response.body);
//       return Quote.fromJson(jsonMap);
//     } else {
//       throw Exception(
//           'Failed to fetch quote (${response.statusCode}): ${response.body}');
//     }
//   }

//   Future<List<CryptoCurrency>> getCryptoCurrencies() async {
//     const endpoint = 'crypto/buy';
//     const url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final response = await http.get(
//       Uri.parse(url),
//       headers: _headers('GET', path),
//     );

//     if (response.statusCode == 200) {
//       final List data = json.decode(response.body);
//       return data.map((e) => CryptoCurrency.fromJson(e)).toList();
//     } else {
//       throw Exception('Failed to load crypto currencies');
//     }
//   }

//   Future<OrderResponse> createBuyOrder({
//     required String fiatCurrency,
//     required String cryptoCurrency,
//     required String paymentMethodId,
//     required String walletAddress,
//     required String blockchain,
//     required String cryptoAmount,
//     String? fiatAmount,
//     String? externalCustomerId,
//     String? email,
//     String? metadata,
//     String? subPartnerId,
//   }) async {
//     const endpoint = 'buy';
//     const url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final extOrderId = 'order_${DateTime.now().millisecondsSinceEpoch}';
//     final redirectUrl = Uri(
//       scheme: 'geniuswallet',
//       host: 'banxa',
//       path: '/callback',
//       queryParameters: {'extOrderId': extOrderId},
//     ).toString();

//     final bodyMap = {
//       'fiat': fiatCurrency,
//       'crypto': cryptoCurrency,
//       'blockchain': blockchain,
//       'walletAddress': walletAddress,
//       'paymentMethodId': paymentMethodId,
//       'redirectUrl': redirectUrl,
//       'cryptoAmount': cryptoAmount,
//       if (fiatAmount != null) 'fiatAmount': fiatAmount,
//       if (email != null) 'email': email,
//       if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
//       'externalOrderId': extOrderId,
//       if (metadata != null) 'metadata': metadata,
//       if (subPartnerId != null) 'subPartnerId': subPartnerId,
//     };

//     final response = await http.post(
//       Uri.parse(url),
//       headers: _headers('POST', path, bodyMap),
//       body: json.encode(bodyMap),
//     );

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       final order = OrderResponse.fromJson(json.decode(response.body));

//       if (order.orderId.isNotEmpty) {
//         OrderLinker.instance.put(extOrderId, order.orderId);
//       }

//       return order;
//     }

//     throw Exception('Order failed (${response.statusCode}): ${response.body}');
//   }

//   Future<OrderStatus> getOrderStatus(String orderId) async {
//     final endpoint = 'orders/$orderId';
//     final url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final response = await http.get(
//       Uri.parse(url),
//       headers: _headers('GET', path),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return OrderStatus.fromJson(data);
//     } else {
//       throw Exception('Failed to fetch order status (${response.statusCode})');
//     }
//   }

//   Future<OrderStatus> pollOrderStatus(
//     String orderId, {
//     Duration interval = const Duration(seconds: 5),
//     Duration timeout = const Duration(minutes: 2),
//   }) async {
//     final completer = Completer<OrderStatus>();
//     final stopwatch = Stopwatch()..start();
//     Timer? timer;

//     Future<void> checkStatus() async {
//       try {
//         final status = await getOrderStatus(orderId);

//         print('Order status: ${status.status}');

//         if (status.status.toLowerCase() == 'completed' ||
//             status.status.toLowerCase() == 'failed' ||
//             status.status.toLowerCase() == 'cancelled' ||
//             status.status.toLowerCase() == 'inprogress' ||
//             status.status.toLowerCase() == 'expired' ||
//             status.status.toLowerCase() == 'declined') {
//           timer?.cancel();
//           completer.complete(status);
//         } else if (stopwatch.elapsed >= timeout) {
//           timer?.cancel();
//           completer.completeError(Exception("Polling timed out"));
//         }
//       } catch (e) {
//         timer?.cancel();
//         completer.completeError(e);
//       }
//     }

//     checkStatus();

//     timer = Timer.periodic(interval, (_) => checkStatus());

//     return completer.future;
//   }

//   Future<OrdersResponse> fetchAllOrders({
//     required String startDateUtc,
//     required String endDateUtc,
//     String status = '',
//     int limit = 100,
//     String? externalCustomerId,
//   }) async {
//     const endpoint = 'orders';
//     const url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     final queryParams = {
//       'start': startDateUtc,
//       'end': endDateUtc,
//       if (status.isNotEmpty) 'status': status,
//       'limit': limit.toString(),
//       if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
//     };

//     final uri = Uri.parse(url).replace(queryParameters: queryParams);

//     final response = await http.get(
//       uri,
//       headers: _headers('GET', path),
//     );

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       return OrdersResponse.fromJson(data);
//     } else {
//       print(
//           'Failed to fetch orders: ${response.statusCode} - ${response.body}');
//       throw Exception('Failed to fetch orders: ${response.statusCode}');
//     }
//   }

//   Future<Order> getOrderById(String orderId) async {
//     final endpoint = 'orders/$orderId';
//     final url = '$_baseUrl/$endpoint';
//     final path = _buildPath(endpoint);

//     print('🟢 Fetching order with ID: $orderId');
//     print('🔗 URL: $url');
//     print('🛡️ Headers: ${_headers('GET', path)}');

//     final resp = await http.get(
//       Uri.parse(url),
//       headers: _headers('GET', path),
//     );

//     print('📤 Status code: ${resp.statusCode}');
//     print('📥 Response body: ${resp.body}');

//     if (resp.statusCode == 200) {
//       final data = json.decode(resp.body);
//       print('✅ Order fetched successfully: $data');
//       return Order.fromJson(data);
//     } else if (resp.statusCode == 404) {
//       throw Exception('❌ Order not found: $orderId');
//     } else {
//       throw Exception('❌ Failed to load order $orderId: ${resp.body}');
//     }
//   }

//   Future<void> openBanxaInBrowser(String url) async {
//     final uri = Uri.parse(url);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     }
//   }
// }
