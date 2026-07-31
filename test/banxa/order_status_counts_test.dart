import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';

import 'fixtures.dart';

/// Pins 09-08 Task 1: `OrdersState.statusCounts` / `totalOrderCount` are a
/// pure DERIVATION over `orders.orders` (the FULL list), never
/// `filteredOrders`. Built directly with hand-made `Order` fixtures — no
/// cubit pump needed for a pure getter.
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
      testOrder(id: 'ord_0001', status: 'completed'),
      testOrder(id: 'ord_0002', status: 'completed'),
      testOrder(id: 'ord_0003', status: 'pendingpayment'),
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

    test('each bucket equals the count applyFilters would return for that '
        'bucket, for every one of the four buckets', () {
      final state = OrdersState.initial().copyWith(orders: response);
      final counts = state.statusCounts;

      // `OrdersCubit.applyFilters`'s own logic is `o.status == status`
      // (banxa_order_cubit.dart:95) — reproduced inline here rather than
      // spinning up a cubit, since this getter is pure and the plan calls
      // for hand-made fixtures only.
      int applyFiltersCount(String status) =>
          orders.where((o) => o.status == status).length;

      expect(counts[OrderStatusTone.success], applyFiltersCount('completed'));
      expect(counts[OrderStatusTone.success], 2);
      expect(
        counts[OrderStatusTone.warning],
        applyFiltersCount('pendingpayment'),
      );
      expect(counts[OrderStatusTone.warning], 1);
      expect(counts[OrderStatusTone.error], applyFiltersCount('declined'));
      expect(counts[OrderStatusTone.error], 1);
      // The unrecognised string lands in neutral, not nowhere.
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

    test('counts are computed from the FULL list, not the filtered one — '
        'selecting a filter does not change the numbers shown on the other '
        'filters', () {
      // Simulate a filter selection: `filteredOrders` narrowed down to a
      // single status, `orders` (the full list) unchanged.
      final filtered = orders.where((o) => o.status == 'declined').toList();
      final state = OrdersState.initial().copyWith(
        orders: response,
        filteredOrders: filtered,
      );

      expect(state.totalOrderCount, orders.length);
      expect(state.statusCounts[OrderStatusTone.success], 2);
      expect(state.statusCounts[OrderStatusTone.warning], 1);
      expect(state.statusCounts[OrderStatusTone.error], 1);
      expect(state.statusCounts[OrderStatusTone.neutral], 1);
    });
  });
}
