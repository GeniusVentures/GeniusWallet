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

  /// When set, the matching call throws this instead of answering.
  Exception? fetchOrdersError;
  Exception? quoteError;
  Exception? createError;
  Exception? orderByIdError;

  /// When set, [fetchAllOrders] waits for it before answering, so a test can
  /// finish two fetches in a chosen order.
  Completer<void>? Function(String? customerId)? holdFetch;

  int fetchAllOrdersCalls = 0;
  String? lastCustomerId;
  final List<String?> customerIds = [];
  int getOrderByIdCalls = 0;

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
    final held = holdFetch?.call(externalCustomerId);
    if (held != null) {
      await held.future;
    }
    if (fetchOrdersError != null) {
      throw fetchOrdersError!;
    }
    return OrdersResponse(
      orders: List.of(orders),
      total: orders.length,
      pageTotal: 1,
    );
  }

  @override
  Future<Order> getOrderById(String orderId) async {
    getOrderByIdCalls++;
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
  Future<List<FiatCurrency>> getFiatCurrencies() async => fiats;

  @override
  Future<List<CryptoCurrency>> getCryptoCurrencies() async => cryptos;

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
    if (createError != null) {
      throw createError!;
    }
    return createResult!;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
