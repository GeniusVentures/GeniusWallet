import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Locks 260731-ope: the Buy GNUS "Your orders" rail renders the SAME
/// `TransactionRow` the Transactions tab renders (D-03: the crypto amount in
/// the right column, the fiat actually paid as the value line beneath it), and
/// tapping one opens the SAME `showTransactionDetails` drawer carrying the
/// Banxa fields a `Transaction` has no slot for (D-01), with the footer
/// actions `/orderDetails` used to own (D-02).
///
/// Orders are seeded through `SeededOrdersCubit` (`fixtures.dart`) and pumped
/// through the real, public `BanxaBuyScreen` - `_OrdersRail` stays private to
/// `banxa_buy_screen.dart` and is never reached into.
void main() {
  final completed = testOrder(
    id: 'ord_completed',
    status: 'completed',
    fiatAmount: '111.11',
    cryptoAmount: '0.0011',
  );
  final pendingPayment = testOrder(
    id: 'ord_pending_payment',
    status: 'pendingPayment',
    fiatAmount: '222.22',
    cryptoAmount: '0.0022',
  );
  final declined = testOrder(
    id: 'ord_declined',
    status: 'declined',
    fiatAmount: '444.44',
    cryptoAmount: '0.0044',
  );

  Widget pumpableBuyScreen(List<Order> orders) => BlocProvider<OrdersCubit>(
    create: (_) => SeededOrdersCubit(seededOrdersState(orders)),
    child: const BanxaBuyScreen(),
  );

  /// 1600 by 1200: tall enough that the drawer's detail grids are BUILT rather
  /// than left off-viewport, which is what the `GWDetailGrid` assertions below
  /// depend on. Fixed-step pumps rather than `pumpAndSettle`, matching the
  /// rest of `test/banxa/` - the boot-loading scrim can make settle hang.
  Future<void> pumpRail(WidgetTester tester, List<Order> orders) async {
    await tester.binding.setSurfaceSize(const Size(1600, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(gwHost(pumpableBuyScreen(orders)));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// The row's amount line - the plain `Text` carrying `TxRowContent.amount`.
  Finder amountLine(Order order) =>
      find.text('+ ${order.cryptoAmount} ${order.crypto.id}');

  Future<void> openDrawerFor(WidgetTester tester, Order order) async {
    await tester.tap(amountLine(order));
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('the rail row is the Transactions-tab row', () {
    testWidgets('renders a TransactionRow per order', (tester) async {
      await pumpRail(tester, [completed, pendingPayment, declined]);

      expect(find.byType(TransactionRow), findsNWidgets(3));
    });

    testWidgets('the crypto amount leads and the fiat PAID is beneath it', (
      tester,
    ) async {
      await pumpRail(tester, [completed]);

      // Asserted on TEXT, not on the widget type alone: the point of D-03 is
      // which number sits where, and a TransactionRow proves neither on its
      // own.
      expect(find.text('+ 0.0011 BTC'), findsOneWidget);
      expect(find.text('111.11 USD'), findsOneWidget);
    });

    testWidgets('a declined order reads Not charged, never its fiat', (
      tester,
    ) async {
      await pumpRail(tester, [declined]);

      expect(find.text('Not charged'), findsOneWidget);
      expect(find.text('444.44 USD'), findsNothing);
    });

    testWidgets('rows are divider-separated, with no day headers', (
      tester,
    ) async {
      await pumpRail(tester, [completed, pendingPayment, declined]);

      // Three rows, two hairlines - none after the last.
      expect(find.byType(Divider), findsNWidgets(2));

      // The rail does NOT group by day the way the tab does; the day rides in
      // each row's own subtitle instead. (The reason used to be "the rail
      // renders at most four rows"; 260731-ti5 deleted that cap, and the
      // reason that survives it is that the tab's rows carry no date of their
      // own while these do - a day header above each would be duplication.)
      final dayLabel = txDayLabel(completed.createdAt, DateTime.now());
      expect(find.text(dayLabel.toUpperCase()), findsNothing);
      expect(find.textContaining('$dayLabel · Card purchase'), findsWidgets);
    });
  });

  group('tapping a row opens the shared drawer', () {
    testWidgets('it is the transactions drawer, carrying a Banxa-only field', (
      tester,
    ) async {
      await pumpRail(tester, [completed]);
      await openDrawerFor(tester, completed);

      // Both of the shared drawer's group kickers.
      expect(find.text('TRANSACTION'), findsOneWidget);
      expect(find.text('NETWORK'), findsOneWidget);

      // A Banxa-only value rendered INSIDE the shared drawer's own grid -
      // which is what proves this is that drawer and not a lookalike.
      expect(
        find.descendant(
          of: find.byType(GWDetailGrid),
          matching: find.text('Credit Card'),
        ),
        findsOneWidget,
      );
      // The fields a `Transaction` has no slot for.
      expect(find.text('Order amount'), findsOneWidget);
      expect(find.text('Processing fee'), findsOneWidget);
      expect(find.text('Network fee'), findsOneWidget);
      expect(find.text('Order ID'), findsOneWidget);
    });

    testWidgets('an unsettled order shows no Hash row and no explorer', (
      tester,
    ) async {
      await pumpRail(tester, [completed]);
      await openDrawerFor(tester, completed);

      // The fixture carries no `transactionHash`, so `orderAsTransaction`
      // leaves the hash blank and the drawer's own blank-skip guard drops both
      // the row and its footer - D-01's absent-not-empty.
      expect(find.text('Hash'), findsNothing);
      expect(find.text('View on Explorer'), findsNothing);
    });
  });

  group('the drawer footer is gated on the raw Banxa status (D-02)', () {
    testWidgets('a pendingPayment order can complete its payment', (
      tester,
    ) async {
      await pumpRail(tester, [pendingPayment]);
      await openDrawerFor(tester, pendingPayment);

      // Presence only - tapping Retry pushes a route and would throw outside
      // a GoRouter host.
      expect(find.text('Complete Payment'), findsOneWidget);
      expect(find.text('Retry Order'), findsNothing);
    });

    testWidgets('a declined order can be retried', (tester) async {
      await pumpRail(tester, [declined]);
      await openDrawerFor(tester, declined);

      expect(find.text('Retry Order'), findsOneWidget);
      expect(find.text('Complete Payment'), findsNothing);
    });

    testWidgets('a completed order offers neither', (tester) async {
      await pumpRail(tester, [completed]);
      await openDrawerFor(tester, completed);

      expect(find.text('Complete Payment'), findsNothing);
      expect(find.text('Retry Order'), findsNothing);
    });
  });
}
