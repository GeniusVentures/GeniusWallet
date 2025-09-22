import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banaxa_model.dart';
import 'package:genius_wallet/banxa_order/banxa_order_state.dart';

class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState.initial());

  Future<void> fetchOrders(String? externalCustomerId) async {
    emit(state.copyWith(status: OrdersStatus.loading, error: ''));

    final now = DateTime.now().toUtc();
    final oneMonthAgo = now.subtract(const Duration(days: 120));

    try {
      final orders = await BanxaApiService().fetchAllOrders(
        startDateUtc: oneMonthAgo.toIso8601String(),
        endDateUtc: now.toIso8601String(),
        externalCustomerId: externalCustomerId,
        status: '',
      );

      emit(state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
        filteredOrders: orders.orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.error,
        error: e.toString(),
      ));
    }
  }

  void applyFilters({String? status, DateTime? startDate, DateTime? endDate}) {
    if (state.orders == null) return;

    List<Order> filtered = state.orders!.orders;

    if (status != null && status.isNotEmpty) {
      filtered = filtered.where((o) => o.status == status).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((o) => o.createdAt.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((o) => o.createdAt.isBefore(endDate)).toList();
    }

    emit(state.copyWith(filteredOrders: filtered));
  }
}
