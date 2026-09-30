import 'dart:async';

import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';

/// A scriptable stand-in for [BanxaApiService]. Anything it does not script
/// throws, so a test never reaches the network by accident.
class FakeBanxaApi implements BanxaApiService {
  FakeBanxaApi({
    List<Order>? orders,
    this.fiats = const [],
    this.cryptos = const [],
    this.quote,
    this.createResult,
  }) : orders = orders ?? [];

  List<Order> orders;
  List<FiatCurrency> fiats;
  List<CryptoCurrency> cryptos;
  Quote? quote;
  OrderResponse? createResult;

  /// Statuses [getOrderById] returns for an order id, one per call; the last
  /// one repeats.
  final Map<String, List<String>> statuses = {};

  /// Mirror the client getters of the same name.
  @override
  bool isConfigured = true;
  @override
  bool isSandbox = false;

  /// When set, the matching call throws this instead of answering.
  Exception? fetchOrdersError;
  Exception? listError;
  Exception? quoteError;
  Exception? createError;
  Exception? orderByIdError;

  /// When set, [fetchAllOrders] waits for it before answering, so a test can
  /// finish two fetches in a chosen order.
  Completer<void>? Function(String? customerId)? holdFetch;

  /// When set, [getQuote] answers with this instead of [quote].
  Future<Quote> Function()? quoteHandler;

  int listCalls = 0;
  final List<Map<String, String?>> quoteRequests = [];
  final List<Map<String, String?>> createRequests = [];

  int fetchAllOrdersCalls = 0;
  String? lastCustomerId;
  final List<String?> customerIds = [];
  int getOrderByIdCalls = 0;
  final List<String> readIds = [];

  /// When set, [getOrderById] answers with the status it had at call time but
  /// only once this completes.
  Completer<void>? holdOrderById;

  @override
  Future<OrdersResponse> fetchAllOrders({
    required String startDateUtc,
    required String endDateUtc,
    String status = '',
    int pageSize = 100,
    int maxPages = 20,
    String? externalCustomerId,
  }) async {
    fetchAllOrdersCalls++;
    lastCustomerId = externalCustomerId;
    customerIds.add(externalCustomerId);
    final answer = List.of(orders);
    final error = fetchOrdersError;
    final held = holdFetch?.call(externalCustomerId);
    if (held != null) {
      await held.future;
    }
    if (error != null) {
      throw error;
    }
    return OrdersResponse(orders: answer, total: answer.length, pageTotal: 1);
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    getOrderByIdCalls++;
    readIds.add(orderId);
    final held = holdOrderById;
    if (held != null) {
      await held.future;
    }
    if (orderByIdError != null) {
      throw orderByIdError!;
    }
    final order = orders.firstWhere((o) => o.id == orderId);
    final script = statuses[orderId];
    if (script == null || script.isEmpty) {
      return order;
    }
    final next = script.length > 1 ? script.removeAt(0) : script.first;
    return Order.fromJson({...order.toJson(), 'status': next});
  }

  @override
  Future<List<FiatCurrency>> getFiatCurrencies() async {
    listCalls++;
    if (listError != null) {
      throw listError!;
    }
    return fiats;
  }

  @override
  Future<List<CryptoCurrency>> getCryptoCurrencies() async {
    listCalls++;
    if (listError != null) {
      throw listError!;
    }
    return cryptos;
  }

  @override
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
    quoteRequests.add({
      'fiat': fiat,
      'fiatAmount': fiatAmount,
      'paymentMethodId': paymentMethodId,
      'crypto': crypto,
      'blockchain': blockchain,
    });
    if (quoteHandler != null) {
      return quoteHandler!();
    }
    if (quoteError != null) {
      throw quoteError!;
    }
    return quote!;
  }

  @override
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
    createRequests.add({
      'walletAddress': walletAddress,
      'externalCustomerId': externalCustomerId,
      'fiatCurrency': fiatCurrency,
      'cryptoAmount': cryptoAmount,
    });
    if (createError != null) {
      throw createError!;
    }
    return createResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
