// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:http/http.dart' as http;

class BanxaApiService {
  static const String _partnerCode = 'gnus';
  static const String _apiKey = 'f4618be892ba64672e6fae3aab374c374bd53126';
  static const String _baseUrl =
      'https://api.banxa-sandbox.com/$_partnerCode/v2';

  static Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
      };

  Future<List<FiatCurrency>> getFiatCurrencies() async {
    const url = '$_baseUrl/fiats/buy';
    final response = await http.get(Uri.parse(url), headers: _headers);
    print('Fiat response: ${response.statusCode} - ${response.body}');

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
    print('Crypto response: ${response.statusCode} - ${response.body}');

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
    required String redirectUrl,
    required String blockchain,
    required String cryptoAmount,
    String? fiatAmount,
    String? externalCustomerId,
    String? externalOrderId,
    String? email,
    String? metadata,
    String? subPartnerId,
  }) async {
    const url = '$_baseUrl/buy';
    final bodyMap = {
      'fiat': fiatCurrency,
      'crypto': cryptoCurrency,
      'blockchain': blockchain,
      'walletAddress': walletAddress,
      'paymentMethodId': paymentMethodId,
      'redirectUrl': redirectUrl,

      // Guaranteed locked price:
      'cryptoAmount': cryptoAmount,

      // Optional, for your records:
      if (fiatAmount != null) 'fiatAmount': fiatAmount,

      // Extras:
      if (email != null) 'email': email,
      if (externalCustomerId != null) 'externalCustomerId': externalCustomerId,
      if (externalOrderId != null) 'externalOrderId': externalOrderId,
      if (metadata != null) 'metadata': metadata,
      if (subPartnerId != null) 'subPartnerId': subPartnerId,
    };

    final response = await http.post(
      Uri.parse(url),
      headers: _headers,
      body: json.encode(bodyMap),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return OrderResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Order failed (${response.statusCode}): ${response.body}');
    }
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

  Future<List<Map<String, dynamic>>> fetchAllOrders({
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
    print('Orders response: ${response.statusCode} - ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List orders = data['orders'] ?? [];
      return orders.cast<Map<String, dynamic>>();
    } else {
      print(
          'Failed to fetch orders: ${response.statusCode} - ${response.body}');
      throw Exception('Failed to fetch orders: ${response.statusCode}');
    }
  }
  Future<OrderResponseModel> getOrderById(String orderId) async {
    final url = '$_baseUrl/orders/$orderId';
    final resp = await http.get(Uri.parse(url), headers: _headers);
    if (resp.statusCode == 200) {
      return OrderResponseModel.fromJson(json.decode(resp.body));
    }
    throw Exception('Failed to load order $orderId: ${resp.body}');
  }
}
