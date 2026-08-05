import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';

import 'gw_pump.dart';

/// Pins 09-02 Task 3's replacement of `banxa_orders_history.dart`'s bare
/// error branch (`Center(child: Text("❌ ..."))`) and empty-state ternary
/// (`Text("No orders found.")`).
///
/// Per the plan: does NOT pump `OrdersPage` itself — its `initState` calls a
/// cubit that hits the network, which D-03 forbids. Instead this pumps the
/// two state widgets directly with the exact arguments the screen passes
/// them (confirmed by reading `banxa_orders_history.dart`'s own source),
/// asserting the contracted copy renders and that each callback fires.
void main() {
  group('error branch (GWErrorState)', () {
    testWidgets(
      'shows the exact operator error string alongside a retry affordance',
      (tester) async {
        var retried = false;
        const errorMessage = 'Banxa sandbox returned a 503';

        await tester.pumpWidget(
          gwHost(
            GWErrorState(
              title: "Couldn't load your orders",
              message: errorMessage,
              onRetry: () => retried = true,
            ),
          ),
        );

        // state.error is preserved verbatim as the detail line.
        expect(find.text(errorMessage), findsOneWidget);
        expect(find.text("Couldn't load your orders"), findsOneWidget);

        // Tapping retry re-dispatches the same call the screen's onRetry
        // closure makes (`fetchOrders('your-cust-id')`, confirmed by reading
        // banxa_orders_history.dart — this fake closure stands in for it so
        // no live cubit/network call is required, D-03).
        await tester.tap(find.text('Retry'));
        await tester.pump();
        expect(retried, isTrue);
      },
    );
  });

  group('empty branch (GWEmptyState) — no filter applied', () {
    testWidgets('reads "No orders yet" and offers New Order', (tester) async {
      var pushed = false;

      await tester.pumpWidget(
        gwHost(
          GWEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders yet',
            message:
                'Your Banxa purchases will show up here once you create one.',
            actionLabel: 'New Order',
            onAction: () => pushed = true,
          ),
        ),
      );

      expect(find.text('No orders yet'), findsOneWidget);
      expect(
        find.text(
          'Your Banxa purchases will show up here once you create one.',
        ),
        findsOneWidget,
      );
      expect(find.text('No orders found.'), findsNothing);

      await tester.tap(find.text('New Order'));
      await tester.pump();
      expect(pushed, isTrue);
    });
  });

  group('empty branch (GWEmptyState) — a filter is active', () {
    testWidgets('reads "No orders match this filter." and offers no action', (
      tester,
    ) async {
      await tester.pumpWidget(
        gwHost(
          const GWEmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No orders match this filter.',
          ),
        ),
      );

      expect(find.text('No orders match this filter.'), findsOneWidget);
      expect(find.text('No orders found.'), findsNothing);
      expect(find.text('New Order'), findsNothing);
      expect(find.text('Clear Filter'), findsNothing);
    });
  });
}
