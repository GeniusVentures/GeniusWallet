enum OrdersStatus { initial, loading, success, error }

class OrdersState {
  final OrdersStatus status;
  final List<Map<String, dynamic>> orders;
  final String error;

  OrdersState({
    required this.status,
    required this.orders,
    required this.error,
  });

  factory OrdersState.initial() => OrdersState(
        status: OrdersStatus.initial,
        orders: [],
        error: '',
      );

  OrdersState copyWith({
    OrdersStatus? status,
    List<Map<String, dynamic>>? orders,
    String? error,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      error: error ?? this.error,
    );
  }
}
