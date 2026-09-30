import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';

import 'fixtures.dart';

/// `OrdersState.statusCounts` / `totalOrderCount` derive from the full order
/// list. Built directly with hand-made `Order` fixtures; a pure getter needs
/// no cubit.
void main() {
  group('with no orders loaded', () {
    test('every count is zero and no count is null', () {
      final state = OrdersState.initial();

      expect(state.totalOrderCount, 0);
      for (final tone in OrderStatusTone.values) {
        expect(state.statusCounts[tone], 0);
      }
    });
  });

  group('with orders loaded', () {
    final orders = [
      testOrder(id: 'ord_0001', status: 'complete'),
      testOrder(id: 'ord_0002', status: 'complete'),
      testOrder(id: 'ord_0003', status: 'pendingPayment'),
      testOrder(id: 'ord_0004', status: 'declined'),
      // An unrecognised raw status string — the ladder's `default` arm must
      // still count it (in the neutral bucket) rather than dropping it.
      testOrder(id: 'ord_0005', status: 'weird-unmapped-status'),
    ];
    final response = OrdersResponse(
      orders: orders,
      total: orders.length,
      pageTotal: orders.length,
    );

    test('the all-count equals the total number of loaded orders', () {
      final state = OrdersState.initial().copyWith(orders: response);
      expect(state.totalOrderCount, orders.length);
    });

    test('each tone counts its own orders, unrecognised ones as neutral', () {
      final counts = OrdersState.initial()
          .copyWith(orders: response)
          .statusCounts;

      expect(counts[OrderStatusTone.success], 2);
      expect(counts[OrderStatusTone.warning], 1);
      expect(counts[OrderStatusTone.error], 1);
      expect(counts[OrderStatusTone.neutral], 1);
    });

    test('orders with an unrecognised status fall in the neutral bucket, so '
        'the four bucket counts always sum to the all-count', () {
      final state = OrdersState.initial().copyWith(orders: response);
      final counts = state.statusCounts;

      final sum = OrderStatusTone.values.fold<int>(
        0,
        (acc, tone) => acc + (counts[tone] ?? 0),
      );
      expect(sum, state.totalOrderCount);
    });
  });
}
