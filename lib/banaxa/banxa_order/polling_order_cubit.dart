import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/banaxa/banaxa_api_services.dart';
import 'package:genius_wallet/banaxa/banxa_order/polling_order_state.dart';

class PollingCubit extends Cubit<PollingState> {
  final String orderId;
  final BanxaApiService api;
  Timer? _pollingTimer;

  bool hasNavigated = false;

  PollingCubit({required this.orderId, required this.api})
      : super(const PollingState(status: PollingStatus.initial));

  void startPolling() {
    emit(state.copyWith(status: PollingStatus.loading));

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      try {
        final order = await api.getOrderStatus(orderId);
        final statusLower = order.status.toLowerCase();

        emit(state.copyWith(
          status: PollingStatus.success,
          order: order,
          message: 'Order status: ${order.status}',
        ));

        // Stop polling if order is completed, failed, or cancelled
        if (statusLower == 'completed' ||
            statusLower == 'failed' ||
            statusLower == 'cancelled') {
          _pollingTimer?.cancel();
        }
      } catch (e) {
        emit(state.copyWith(
          status: PollingStatus.error,
          message: 'Error fetching order status: $e',
        ));
      }
    });
  }

  void stopPolling() {
    _pollingTimer?.cancel();
  }

  @override
  Future<void> close() {
    _pollingTimer?.cancel();
    return super.close();
  }
}
