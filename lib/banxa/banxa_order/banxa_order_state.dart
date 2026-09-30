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
}
