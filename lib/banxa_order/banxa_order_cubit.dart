import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banxa_order/banxa_order_state.dart';
import 'package:intl/intl.dart';
class OrdersCubit extends Cubit<OrdersState> {
  OrdersCubit() : super(OrdersState.initial());

  Future<void> fetchOrders(String? externalCustomerId) async {
    emit(state.copyWith(status: OrdersStatus.loading, error: ''));

    final now = DateTime.now().toUtc();
    final oneMonthAgo = now.subtract(const Duration(days: 30));

    final startDateUtc =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(oneMonthAgo);
    final endDateUtc = DateFormat("yyyy-MM-dd'T'HH:mm:ss'Z'").format(now);

    try {
      final orders = await BanxaApiService().fetchAllOrders(
        startDateUtc: startDateUtc,
        endDateUtc: endDateUtc,
        externalCustomerId: externalCustomerId,
        status: '',
      );
      emit(state.copyWith(
        status: OrdersStatus.success,
        orders: orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.error,
        error: e.toString(),
      ));
    }
  }
}
