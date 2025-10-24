import 'package:genius_wallet/banaxa/banaxa_model.dart';

enum PollingStatus { initial, loading, success, error }

class PollingState {
  final PollingStatus status;
  final OrderStatus? order;
  final String message;

  const PollingState({
    required this.status,
    this.order,
    this.message = '',
  });

  PollingState copyWith({
    PollingStatus? status,
    OrderStatus? order,
    String? message,
  }) {
    return PollingState(
      status: status ?? this.status,
      order: order ?? this.order,
      message: message ?? this.message,
    );
  }
}
