import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// The one runnable check proving the Wave 0 test floor exists and runs
/// (09-01-PLAN.md Task 1). Its job is to prove the floor exists, not to
/// test Flutter.
void main() {
  test('testOrder() returns the requested status', () {
    final order = testOrder(status: 'declined');
    expect(order.status, 'declined');
  });

  test('testOrder() derived date fields are stable across two calls', () {
    final a = testOrder();
    final b = testOrder();
    expect(a.createdAt, b.createdAt);
    expect(a.updatedAt, b.updatedAt);
  });

  testWidgets('gwHost renders a trivial child under both gwBothModes entries', (
    tester,
  ) async {
    for (final gw in gwBothModes) {
      await tester.pumpWidget(gwHost(const Text('probe'), gw: gw));
      expect(find.text('probe'), findsOneWidget);
    }
  });
}
