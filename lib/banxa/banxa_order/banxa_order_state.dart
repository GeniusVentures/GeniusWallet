import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';

enum OrdersStatus { initial, loading, success, error }

class OrdersState {
  final OrdersStatus status;
  final OrdersResponse? orders;
  final String error;

  /// Orders that turned final in the emit that carries this; every other
  /// emit clears it, so a listener sees each outcome once.
  final List<Order> justFinished;

  OrdersState({
    required this.status,
    this.orders,
    required this.error,
    this.justFinished = const [],
  });

  factory OrdersState.initial() =>
      OrdersState(status: OrdersStatus.initial, orders: null, error: '');

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersResponse? orders,
    String? error,
    List<Order>? justFinished,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error ?? this.error,
      justFinished: justFinished ?? const [],
    );
  }

  /// Per-tone counts over the full list. Every [OrderStatusTone] is present
  /// even at zero, and an unrecognised status lands in neutral, so the counts
  /// always sum to [totalOrderCount].
  Map<OrderStatusTone, int> get statusCounts {
    final counts = <OrderStatusTone, int>{
      for (final tone in OrderStatusTone.values) tone: 0,
    };
    for (final order in orders?.orders ?? const <Order>[]) {
      final tone = orderStatusTone(order.status);
      counts[tone] = counts[tone]! + 1;
    }
    return counts;
  }

  /// The all-count: the total number of loaded orders. Zero (never null)
  /// when no orders are loaded.
  int get totalOrderCount => orders?.orders.length ?? 0;
}
