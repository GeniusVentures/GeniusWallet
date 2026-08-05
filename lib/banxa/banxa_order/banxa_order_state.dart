import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';

enum OrdersStatus { initial, loading, success, error }

class OrdersState {
  final OrdersStatus status;
  final OrdersResponse? orders;
  final List<Order>? filteredOrders;
  final String error;

  OrdersState({
    required this.status,
    this.orders,
    this.filteredOrders,
    required this.error,
  });

  factory OrdersState.initial() => OrdersState(
    status: OrdersStatus.initial,
    orders: null,
    filteredOrders: null,
    error: '',
  );

  OrdersState copyWith({
    OrdersStatus? status,
    OrdersResponse? orders,
    List<Order>? filteredOrders,
    String? error,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      error: error ?? this.error,
    );
  }

  /// Per-status counts (09-08 Task 1), a DERIVATION over the FULL list
  /// (`orders.orders`) — never `filteredOrders`. Reading the filtered list
  /// here would mean selecting "Pending" recomputes every other bucket to
  /// zero, so the count chips would contradict themselves the moment one is
  /// tapped.
  ///
  /// Every one of the four [OrderStatusTone] buckets is present, even when
  /// its count is zero, keyed through [orderStatusTone] rather than matching
  /// status strings again — that switch (`order_status_style.dart`) is the
  /// single ladder this app already established, and re-deriving it here is
  /// how the two would drift. `orderStatusTone`'s `default` arm returns
  /// [OrderStatusTone.neutral], so no order can be lost: the four bucket
  /// counts always sum to [totalOrderCount].
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
