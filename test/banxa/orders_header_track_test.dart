import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_state.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// Locks 260731-jx5's rebuild of the Buy GNUS "Your orders" header (sketch
/// 169 scheme B): the four labelled `GWControlTrack` chips (All / Pending /
/// Done / Issues), the tap-active-clears-to-All behaviour, and the
/// responsive kicker-row/own-row split — measured for real here rather than
/// trusted from the plan's pre-measurement estimate.
///
/// `OrdersCubit.fetchOrders` is DEV-gated (`kDebugMode && kShowDevTools`) and
/// otherwise hits an unreachable sandbox (09-CONTEXT.md D-03), so this file
/// seeds real order data with `SeededOrdersCubit` (`fixtures.dart`), which
/// overrides `fetchOrders` to emit a fixed `OrdersState` directly — legal
/// because `emit` is `@protected` (accessible to subclasses), not because
/// this reaches into `_OrdersRail`, which stays private to
/// `banxa_buy_screen.dart` (Dart privacy is per-file) and is exercised here
/// only through the real, public `BanxaBuyScreen`.
///
/// That subclass lived privately in THIS file until 260731-ope gave it a
/// second consumer (`order_rail_row_test.dart`); it moved to `fixtures.dart`
/// rather than being copied.
///
/// One order per tone plus a second warning-bucket order, so the Pending
/// chip's count proves it spans BOTH `pendingPayment` and `inProgress`
/// (`order_status_style.dart`'s `orderStatusTone`) rather than matching one
/// literal status string. Each carries a distinct `cryptoAmount` - see
/// [_rowFor] for why that, and not the `fiatAmount` these keyed off before.
final _completed = testOrder(
  id: 'ord_completed',
  status: 'completed',
  fiatAmount: '111.11',
  cryptoAmount: '0.0011',
);
final _pendingPayment = testOrder(
  id: 'ord_pending_payment',
  status: 'pendingPayment',
  fiatAmount: '222.22',
  cryptoAmount: '0.0022',
);
final _inProgress = testOrder(
  id: 'ord_in_progress',
  status: 'inProgress',
  fiatAmount: '333.33',
  cryptoAmount: '0.0033',
);
final _declined = testOrder(
  id: 'ord_declined',
  status: 'declined',
  fiatAmount: '444.44',
  cryptoAmount: '0.0044',
);

final _seededOrders = [_completed, _pendingPayment, _inProgress, _declined];

OrdersState _seededState() => OrdersState.initial().copyWith(
  status: OrdersStatus.success,
  orders: OrdersResponse(
    orders: _seededOrders,
    total: _seededOrders.length,
    pageTotal: _seededOrders.length,
  ),
  filteredOrders: _seededOrders,
);

/// Matches one order's row by its AMOUNT LINE.
///
/// This keyed off a `Text.rich` containing the order's `fiatAmount` until
/// 260731-ope replaced `_OrderRailRow` with the Transactions tab's own
/// `TransactionRow`. Two things broke it by construction, and neither is a
/// design change this file gets to argue with:
///   - the fiat is now a plain `Text` value line, not a rich-text span, and
///   - a declined order's value line reads `Not charged` (D-03), so its
///     `fiatAmount` is not on that row at all.
/// So the disambiguator moves to the crypto amount, which every row carries in
/// every status - hence the distinct `cryptoAmount` values above, chosen to
/// format to themselves through `formatTxAmount`.
///
/// It still identifies a ROW by content rather than merely proving something
/// rendered: a different order's row cannot satisfy it.
Finder _rowFor(Order order) =>
    find.text('+ ${order.cryptoAmount} ${order.crypto.id}');

void main() {
  Widget pumpableBuyScreen({required OrdersState seeded}) =>
      BlocProvider<OrdersCubit>(
        create: (_) => SeededOrdersCubit(seeded),
        child: const BanxaBuyScreen(),
      );

  Future<void> pumpSeeded(
    WidgetTester tester, {
    required double width,
    double height = 900,
    OrdersState? seeded,
  }) async {
    // `setSurfaceSize` (not a bare `SizedBox`) so the header's own
    // `LayoutBuilder` reads the real test window width — the same technique
    // `buy_page_layout_test.dart` uses for its breakpoint assertions.
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      gwHost(pumpableBuyScreen(seeded: seeded ?? _seededState())),
    );
    // Let the boot-time `loadCurrencies()` call (unreachable sandbox) run
    // its course into its caught-error arm — a bare pump() rather than
    // pumpAndSettle(), matching the rest of `test/banxa/`'s posture, since
    // the boot-loading scrim can make pumpAndSettle hang.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Reads a chip's label text and the sibling count text out of the same
  /// `Row` — `_OrderToneChip` renders `Text(label)` then `Text('$count')` as
  /// the only two `Text` descendants of its own `Row`, so the nearest `Row`
  /// ancestor of the label is exactly that chip's row (not the track's, not
  /// the kicker's).
  int chipCount(WidgetTester tester, String label) {
    final chipRow = find
        .ancestor(of: find.text(label), matching: find.byType(Row))
        .first;
    final texts = tester
        .widgetList<Text>(
          find.descendant(of: chipRow, matching: find.byType(Text)),
        )
        .toList();
    expect(
      texts.length,
      2,
      reason:
          'expected exactly 2 Text widgets (label, count) in the "$label" chip row',
    );
    return int.parse(texts[1].data!);
  }

  group('the four chips', () {
    testWidgets('render with the right labels and counts', (tester) async {
      await pumpSeeded(tester, width: 1600);

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.text('Done'), findsOneWidget);
      expect(find.text('Issues'), findsOneWidget);

      expect(chipCount(tester, 'All'), 4);
      // Pending spans BOTH pendingPayment and inProgress.
      expect(chipCount(tester, 'Pending'), 2);
      expect(chipCount(tester, 'Done'), 1);
      expect(chipCount(tester, 'Issues'), 1);
    });

    testWidgets(
      'Issues is the regression guard: selecting it keeps the declined order and drops a completed one',
      (tester) async {
        await pumpSeeded(tester, width: 1600);

        expect(chipCount(tester, 'Issues'), greaterThan(0));

        await tester.tap(find.text('Issues'));
        await tester.pump();

        expect(_rowFor(_declined), findsOneWidget);
        expect(_rowFor(_completed), findsNothing);
      },
    );

    testWidgets('counts reconcile: Pending + Done + Issues + neutral == All', (
      tester,
    ) async {
      await pumpSeeded(tester, width: 1600);

      final all = chipCount(tester, 'All');
      final pending = chipCount(tester, 'Pending');
      final done = chipCount(tester, 'Done');
      final issues = chipCount(tester, 'Issues');
      // The neutral bucket has no chip; derive it from the state directly,
      // the same derivation `_OrdersRail` reads
      // (`banxa_order_state.dart`'s `statusCounts`).
      final neutral = _seededState().statusCounts[OrderStatusTone.neutral] ?? 0;

      expect(pending + done + issues + neutral, all);
    });

    testWidgets('tapping the active chip clears back to All', (tester) async {
      await pumpSeeded(tester, width: 1600);

      await tester.tap(find.text('Done'));
      await tester.pump();
      expect(_rowFor(_completed), findsOneWidget);
      expect(_rowFor(_declined), findsNothing);

      await tester.tap(find.text('Done'));
      await tester.pump();
      // Back to All: every seeded order is visible again.
      for (final order in _seededOrders) {
        expect(_rowFor(order), findsOneWidget);
      }
    });
  });

  /// THE RAIL's control track, scoped by its own card.
  ///
  /// A bare `find.byType(GWControlTrack)` was unambiguous until 260731-uhe
  /// gave the FORM card beside this rail a track of its own (the amount
  /// shortcut chips). Both are the same shared container, so the type alone no
  /// longer identifies this one - scoping is the fix, and it weakens no claim
  /// below: every assertion still reads the rail's real geometry.
  final Finder railTrack = find.descendant(
    of: find
        .ancestor(of: find.text('YOUR ORDERS'), matching: find.byType(GWCard))
        .first,
    matching: find.byType(GWControlTrack),
  );

  /// Which header branch rendered, read off geometry.
  ///
  /// The branch detector USED to compare the track's vertical centre against
  /// the `View all` link's. 260731-ti5 deleted the link from both branches
  /// (D-01), so the reference moved to the kicker text, which both branches
  /// still render: inline puts the track and the kicker in one
  /// `Row(spaceBetween)`, so their centres agree; the own-row branch stacks
  /// them in a `Column`, so they cannot. This is a re-derivation of the same
  /// distinction, NOT a loosening - each assertion below still fails under
  /// the other branch.
  bool headerIsInline(WidgetTester tester) {
    final trackCenter = tester.getCenter(railTrack).dy;
    final kickerCenter = tester.getCenter(find.text('YOUR ORDERS')).dy;
    return (trackCenter - kickerCenter).abs() <= 1;
  }

  group('responsive header', () {
    // MEASURED (not an estimate — see the comment above
    // `_inlineTrackMinWidth` in `banxa_buy_screen.dart`).
    // `constraints.maxWidth` inside `_OrdersRail`'s `LayoutBuilder` is the
    // RAIL CARD'S inner content width, not the window width, and it does NOT
    // move monotonically with window width in this app: the page's
    // `ConstrainedBox(maxWidth: GeniusBreakpoints.xxl)` sits OUTSIDE the
    // two-column `Row`, so widening the window past `GeniusBreakpoints.large`
    // (1024) SHRINKS the rail card (it goes from full-width single-column to
    // half-width two-column).
    //
    // RE-MEASURED 2026-07-31 after `View all` was deleted. The inline budget
    // dropped from ~734px (kicker + track + link + two gaps) to 608.5px
    // (kicker 148.5 + gap 16 + track 444.0), and the threshold with it, 736
    // -> 610. That FLIPPED the old finding that the inline branch was
    // unreachable in the two-column layout. Every boundary below was pumped,
    // not derived - and note the card's inner width is its outer width minus
    // 34, not 32: `space8` padding each side PLUS a pixel each side for the
    // hairline, which `Container` adds as `decoration.padding`.
    //   - window <= 667px: single column, card inner (window - 58) is 609 or
    //     less -> OWN ROW.
    //   - 668px <= window < 1048px: still single column (the two-column
    //     breakpoint is checked against `window - 24` >= 1024, i.e. window
    //     >= 1048, not 1024), card inner 610 and up -> INLINE.
    //   - 1048px <= window <= 1327px: two columns, card inner
    //     (min(window - 24, 1536) - 16) / 2 - 34 runs from 470px to 609.5px,
    //     under 610 -> OWN ROW.
    //   - window >= 1328px: two columns and the card is finally wide enough
    //     -> INLINE, up to the 726px the xxl cap allows from window 1560 up.
    // Both branches are live at real window sizes now; the 1536px case below
    // is the one that flipped.

    testWidgets(
      'at 1024px window (single-column here, NOT two-column — see comment above) the header is inline with no overflow',
      (tester) async {
        await pumpSeeded(tester, width: 1024, height: 900);
        expect(tester.takeException(), isNull);

        expect(headerIsInline(tester), isTrue);
      },
    );

    testWidgets(
      'at the REAL two-column minimum (window 1048px) the track drops to its own row with no overflow',
      (tester) async {
        await pumpSeeded(tester, width: 1048, height: 900);
        expect(tester.takeException(), isNull);

        // Proves the FALLBACK branch actually engaged (track on its own row)
        // rather than the inline row merely happening to fit: the card's
        // inner width here is 470px, well under the 610px threshold.
        expect(headerIsInline(tester), isFalse);
      },
    );

    testWidgets(
      'at the widest reachable two-column width (1536px window, content capped at xxl) the track rides INLINE — flipped by deleting View all',
      (tester) async {
        await pumpSeeded(tester, width: 1536, height: 900);
        expect(tester.takeException(), isNull);

        // This assertion is the inverse of what it was before 260731-ti5.
        // The two-column card inner width here is 714px (the window is 24px
        // under the xxl cap, so the content is 1512 not 1536). 714 was under
        // the old 736px budget and is over the new 610px one, so the branch
        // that was permanently unreachable in two columns is now the one
        // that renders at wide windows.
        expect(headerIsInline(tester), isTrue);
      },
    );

    testWidgets('no overflow in the HEADER at phone width (400px window)', (
      tester,
    ) async {
      // Two SEPARATE, PRE-EXISTING, out-of-scope defects also overflow at
      // this width and are unrelated to this plan's header rebuild:
      //   1. `_OrderRailRow`'s status+date `Row` (with real orders present).
      //   2. `GWEmptyState`'s fixed `_boundedSlotHeight` slot (with zero
      //      orders — the message wraps taller than the fixed 220px slot).
      // Neither is touched by Task 2/3 (both predate this plan and are
      // dormant — no prior test pumped a real order or the empty state at
      // 400px). Logged to `deferred-items.md`, not fixed here (scope
      // boundary). To isolate the HEADER's own no-overflow claim from
      // these two unrelated widgets, `FlutterError.onError` is
      // intercepted directly (bypassing `tester.takeException()`, which
      // collapses multiple exceptions into one un-inspectable summary
      // string) and only entries naming the header's own widgets
      // (`gw_control_track.dart`, `gw_kicker.dart` — the only place in
      // this screen a `GWKicker` renders a two-child `Row`, since every
      // other call site passes no `trailing`) are treated as failures.
      final headerErrors = <String>[];
      final otherErrors = <String>[];
      final previousOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        final text = details.toString();
        if (text.contains('gw_control_track.dart') ||
            text.contains('gw_kicker.dart')) {
          headerErrors.add(text);
        } else {
          otherErrors.add(text);
        }
      };
      try {
        await pumpSeeded(tester, width: 400, height: 1400);
      } finally {
        FlutterError.onError = previousOnError;
      }
      // Drain whatever flutter_test's own binding still recorded so it
      // does not separately fail this test via its own bookkeeping.
      tester.takeException();

      expect(
        headerErrors,
        isEmpty,
        reason: 'the header itself overflowed at phone width: $headerErrors',
      );
    });

    testWidgets(
      'MEASUREMENT: the real intrinsic widths behind _inlineTrackMinWidth',
      (tester) async {
        // Wide enough (single-column band) that the inline branch engages
        // regardless of the constant's current value — this test reads
        // geometry, it does not assert the threshold.
        await pumpSeeded(tester, width: 1000, height: 900);
        expect(tester.takeException(), isNull);

        final kickerWidth = tester.getSize(find.text('YOUR ORDERS')).width;
        final trackWidth = tester.getSize(railTrack).width;

        // Printed (not asserted) so the executor's run notes can quote the
        // real numbers rather than the plan's pre-measurement estimate.
        // ignore: avoid_print
        print(
          'MEASURED kicker=$kickerWidth track=$trackWidth '
          'sum+gap(16)=${kickerWidth + 16 + trackWidth}',
        );

        expect(kickerWidth, greaterThan(0));
        expect(trackWidth, greaterThan(0));
      },
    );
  });
}
