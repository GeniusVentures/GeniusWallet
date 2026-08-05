import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Locks 260731-ti5: the Buy GNUS "Your orders" rail renders no `View all`
/// (D-01), takes its height FROM the form card beside it rather than from its
/// own content (D-02), and scrolls its whole in-memory list instead of capping
/// at four rows (D-03) - except in the stacked layout, where there is no card
/// beside it to derive from and the page's own scroll carries the rows (D-04).
///
/// Every height claim here is asserted against `tester.getRect`, never against
/// a constant. A test that hard-coded the derived height would pass while the
/// derivation was replaced by a tuned number, which is the one thing D-02
/// forbids.
///
/// Orders are seeded through `SeededOrdersCubit` (`fixtures.dart`) and pumped
/// through the real, public `BanxaBuyScreen` - `_OrdersRail` stays private to
/// `banxa_buy_screen.dart` and is never reached into.
void main() {
  /// [count] orders, newest first once the rail sorts them, each with a
  /// DISTINCT `createdAt` so "the oldest order" is well defined and a distinct
  /// `cryptoAmount` so [amountLine] identifies exactly one row.
  ///
  /// The amounts are matched through `formatTxAmount` rather than compared
  /// raw: the row renders `'+ ${formatTxAmount(cryptoAmount)} ${symbol}'`
  /// (`order_transaction_mapping.dart:162`), and a raw value with a trailing
  /// zero - `0.0010` - renders as `0.001`, which would silently find nothing.
  List<Order> seedOrders(int count) => List<Order>.generate(
    count,
    (i) => testOrder(
      id: 'ord_${i.toString().padLeft(2, '0')}',
      status: 'completed',
      fiatAmount: '${100 + i}.00',
      cryptoAmount: '0.0${101 + i}',
      // One day apart, so the newest-first sort is total and deterministic.
      createdAt: DateTime.utc(2026, 1, 1, 12).add(Duration(days: i)),
    ),
  );

  Widget pumpableBuyScreen(OrdersState seeded) => BlocProvider<OrdersCubit>(
    create: (_) => SeededOrdersCubit(seeded),
    child: const BanxaBuyScreen(),
  );

  /// `setSurfaceSize`, not a wrapping `SizedBox`: the page's own
  /// `LayoutBuilder` reads the real test window width, and a `SizedBox` gets
  /// clamped to the default 800x600 surface. Fixed-step pumps rather than
  /// `pumpAndSettle`, matching the rest of `test/banxa/` - the boot-loading
  /// scrim can make settle hang.
  Future<void> pumpAt(
    WidgetTester tester, {
    required double width,
    required double height,
    required OrdersState seeded,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(gwHost(pumpableBuyScreen(seeded)));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Both cards found by CONTENT, not by index, so these tests do not depend
  /// on the order the two land in the tree. `.first` is the innermost
  /// matching ancestor, which is each card's own `GWCard`.
  final formCard = find
      .ancestor(of: find.text('Get quote'), matching: find.byType(GWCard))
      .first;
  final railCard = find
      .ancestor(of: find.text('YOUR ORDERS'), matching: find.byType(GWCard))
      .first;

  Finder amountLine(Order order) =>
      find.text('+ ${formatTxAmount(order.cryptoAmount)} ${order.crypto.id}');

  group('D-01: no View all, in either header branch', () {
    for (final width in <double>[1600, 400]) {
      testWidgets('nothing offers to view all at ${width.toInt()}px', (
        tester,
      ) async {
        await pumpAt(
          tester,
          width: width,
          height: 1400,
          seeded: seededOrdersState(seedOrders(3)),
        );
        tester.takeException();

        // TWO assertions, because either alone is weak. The type check alone
        // would pass a hand-rolled replacement link; the text sweep alone
        // would pass a `GWViewAllLink` with a relabelled `label:`.
        expect(find.byType(GWViewAllLink), findsNothing);

        final viewAllish = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => (t.data ?? '').toLowerCase())
            .where((s) => s.contains('view all'))
            .toList();
        expect(
          viewAllish,
          isEmpty,
          reason: 'a view-all affordance survived as text: $viewAllish',
        );
      });
    }
  });

  group('D-02: the rail is exactly the form card, and the form card decides', () {
    testWidgets('40 orders do not make the rail any taller than the form', (
      tester,
    ) async {
      await pumpAt(
        tester,
        width: 1600,
        height: 1000,
        seeded: seededOrdersState(seedOrders(40)),
      );

      final form = tester.getRect(formCard);
      final rail = tester.getRect(railCard);

      expect(form.height, greaterThan(0));
      expect(rail.height, closeTo(form.height, 0.5));
      // A derived height that came out too SMALL surfaces as a RenderFlex
      // overflow, which a widget test records as an exception - so this is
      // the assertion that catches it, not a cosmetic extra.
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'one order does not make the rail any shorter, and the form card is the same height either way',
      (tester) async {
        await pumpAt(
          tester,
          width: 1600,
          height: 1000,
          seeded: seededOrdersState(seedOrders(40)),
        );
        final formWith40 = tester.getRect(formCard).height;

        await pumpAt(
          tester,
          width: 1600,
          height: 1000,
          seeded: seededOrdersState(seedOrders(1)),
        );
        final formWith1 = tester.getRect(formCard).height;
        final railWith1 = tester.getRect(railCard).height;

        // Not shorter: the rail does not shrink to one row's worth of content.
        expect(railWith1, closeTo(formWith1, 0.5));
        // ONE-DIRECTIONAL: the form card measures the same whether the rail
        // holds 1 order or 40, which is what proves the rail is not driving
        // the row.
        expect(formWith1, closeTo(formWith40, 0.5));
        expect(tester.takeException(), isNull);
      },
    );
  });

  group('D-03: the box scrolls, and the four-row cap is gone', () {
    testWidgets(
      'the fifth row is present unscrolled and the last needs a scroll',
      (tester) async {
        final orders = seedOrders(40);
        await pumpAt(
          tester,
          width: 1600,
          height: 1000,
          seeded: seededOrdersState(orders),
        );

        // Newest first, so `sorted.first` is the last-created order.
        final sorted = List<Order>.of(orders)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final fifthNewest = sorted[4];
        final oldest = sorted.last;

        // Impossible under the old `visible.take(4)`.
        expect(amountLine(fifthNewest), findsOneWidget);
        // The list is lazy, so the far end is not built yet.
        expect(amountLine(oldest), findsNothing);

        final railList = find.descendant(
          of: railCard,
          matching: find.byType(ListView),
        );
        await tester.scrollUntilVisible(
          amountLine(oldest),
          200,
          scrollable: find.descendant(
            of: railList,
            matching: find.byType(Scrollable),
          ),
          maxScrolls: 200,
        );
        await tester.pump();

        // THE assertion that separates "the cap was removed" from "the cap was
        // raised": order 40 of 40 is reachable.
        expect(amountLine(oldest), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'the scroll viewport never reaches the card\'s rounded corners',
      (tester) async {
        await pumpAt(
          tester,
          width: 1600,
          height: 1000,
          seeded: seededOrdersState(seedOrders(40)),
        );

        final card = tester.getRect(railCard);
        final list = tester.getRect(
          find.descendant(of: railCard, matching: find.byType(ListView)),
        );

        expect(card.contains(list.topLeft), isTrue);
        expect(
          card.contains(list.bottomRight - const Offset(0.01, 0.01)),
          isTrue,
        );
        // `GWCard`'s inset is what makes a `ClipRRect` unnecessary: space8
        // (16px) of padding plus 1px of hairline, measured at 17px here,
        // clears radiusLg (15) - so neither a row nor the overscroll glow
        // can paint over the corner arc.
        expect(
          list.left - card.left,
          greaterThanOrEqualTo(GeniusWalletConsts.radiusLg),
        );
        expect(
          card.right - list.right,
          greaterThanOrEqualTo(GeniusWalletConsts.radiusLg),
        );
      },
    );
  });

  group('the empty and loading branches do not collapse', () {
    testWidgets('an empty rail still measures the form card in two columns', (
      tester,
    ) async {
      await pumpAt(
        tester,
        width: 1600,
        height: 1000,
        seeded: seededOrdersState(const <Order>[]),
      );

      expect(find.text('No orders yet'), findsOneWidget);
      expect(
        tester.getRect(railCard).height,
        closeTo(tester.getRect(formCard).height, 0.5),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('a loading rail still measures the form card in two columns', (
      tester,
    ) async {
      await pumpAt(
        tester,
        width: 1600,
        height: 1000,
        seeded: OrdersState.initial(),
      );

      // The loading branch renders no kicker, so the rail card is found by
      // its spinner instead of by `YOUR ORDERS`.
      final loadingRail = find
          .ancestor(of: find.byType(Loading), matching: find.byType(GWCard))
          .first;
      expect(loadingRail, findsOneWidget);
      expect(
        tester.getRect(loadingRail).height,
        closeTo(tester.getRect(formCard).height, 0.5),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('stacked, an empty rail keeps its own 220px slot', (
      tester,
    ) async {
      await pumpAt(
        tester,
        width: 400,
        height: 1400,
        seeded: seededOrdersState(const <Order>[]),
      );
      // PRE-EXISTING and out of scope: `GWEmptyState`'s message wraps taller
      // than the 220px slot at this width, which overflows. Logged by
      // 260731-jx5, untouched here - drained so it does not fail this test's
      // own claim, which is about the slot's HEIGHT.
      tester.takeException();

      expect(find.text('No orders yet'), findsOneWidget);
      // 220 is `_OrdersRail._boundedSlotHeight`, which is private; the number
      // is stated here with its source rather than imported. Plus the card's
      // own space8 padding top and bottom, plus the header - so `>=` 220, not
      // `==`.
      final rail = tester.getRect(railCard);
      expect(rail.height, greaterThan(0));
      expect(rail.height, greaterThanOrEqualTo(220));
    });
  });

  group('D-04: the stacked layout stacks, and is not bounded', () {
    testWidgets('the rail sits below the form card and is free to be taller', (
      tester,
    ) async {
      await pumpAt(
        tester,
        width: 400,
        height: 1400,
        seeded: seededOrdersState(seedOrders(40)),
      );
      tester.takeException();

      final form = tester.getRect(formCard);
      final rail = tester.getRect(railCard);

      // Stacked, not side by side.
      expect(rail.top, greaterThanOrEqualTo(form.bottom));
      // The honest observable consequence of D-04, and the guard against
      // someone later applying the derived bound where there is no card to
      // derive it from: with 40 rows shrink-wrapped, the rail is far taller
      // than the form card.
      expect(rail.height, greaterThan(form.height));
    });
  });
}
