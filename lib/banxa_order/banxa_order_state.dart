import 'package:genius_wallet/banaxa/banaxa_model.dart';

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
}
