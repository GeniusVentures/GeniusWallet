import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';

import 'gw_pump.dart';

/// Pins 09-08 Task 2/3's claims that a screenshot of a single state cannot
/// see (Task 5).
///
/// `BanxaBuyScreen` builds its own `MakeOrderCubit` internally
/// (`MakeOrderCubit(BanxaApiService())`, with no injection seam — D-01/D-02
/// lock this, and it is not this plan's to change), and the Banxa sandbox is
/// unreachable under `flutter_test` (09-CONTEXT.md D-03). So the real widget
/// can only ever be pumped into its OFFLINE / no-quote step — the same
/// constraint 09-03's `banxa_buy_screen_test.dart` and `09-OUTSTANDING.md`'s
/// "ENABLED Create Order CTA rung" row already name and accept for this
/// exact class of claim.
///
/// So this file pins the claims true of the OFFLINE state: routing, absent
/// widgets, absent copy, the CTA label with no quote, the breakpoint layout.
///
/// The height-INVARIANCE claim used to live here too, as a hand-copied
/// RECONSTRUCTION of the quote grid - a design-contract proxy this file's own
/// doc admitted was not a regression guard, because Dart privacy is per-file
/// and the form card was unreachable. 260731-uhe extracted the card into the
/// public `BanxaBuyForm`, so that claim is now pinned against the REAL widget
/// in `buy_form_layout_test.dart` and the replica is deleted. A hand-copied
/// replica is a thing that can pass while production breaks.
void main() {
  Widget pumpableBuyScreen() => BlocProvider<OrdersCubit>(
    create: (_) => OrdersCubit(),
    child: const BanxaBuyScreen(),
  );

  Future<void> pumpOffline(
    WidgetTester tester, {
    double width = 500,
    double height = 900,
  }) async {
    // `SizedBox(width: ...)` alone is not enough to exercise the breakpoint
    // LayoutBuilder at a real 1400/800: flutter_test's default surface is
    // smaller than either, so a SizedBox merely asking for more than that
    // gets clamped back down to it. `setSurfaceSize` changes the actual test
    // window, which is what the LayoutBuilder's `constraints.maxWidth` reads.
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(gwHost(pumpableBuyScreen()));
    // Let the boot-time `loadCurrencies()`/`fetchOrders()` calls run their
    // course into their caught-error arms. A bare pump() rather than
    // pumpAndSettle(): the boot-loading scrim/spinner in the tree can make
    // pumpAndSettle hang.
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('the real BanxaBuyScreen (offline / no-quote step)', () {
    testWidgets('renders the buy form, not the orders list', (tester) async {
      await pumpOffline(tester);

      expect(find.text('Buy GNUS'), findsOneWidget);
      expect(find.text('Powered by Banxa'), findsOneWidget);
      expect(find.text('Get quote'), findsOneWidget);
      // Furniture unique to `OrdersPage` never appears here.
      expect(find.text('My Orders'), findsNothing);
      expect(find.text('Pick Date Range'), findsNothing);
    });

    testWidgets('contains no DropdownMenu widget', (tester) async {
      await pumpOffline(tester);
      expect(find.byType(DropdownMenu), findsNothing);
    });

    test(
      'the source constructs no raw DropdownMenu(/TextField( (only GWSelect/GWTextField)',
      () {
        final lines = File('lib/screens/banxa_buy_screen.dart')
            .readAsStringSync()
            .split('\n')
            .where((l) => !l.trim().startsWith('//'));

        // `\b` requires a word/non-word transition, so `\bTextField\(` does
        // NOT match inside `GWTextField(` (no boundary between "W" and "T",
        // both word characters) — same reasoning
        // `banxa_reskin_literals_test.dart` documents for `\bColors\.` vs
        // `GWColors`.
        expect(
          lines.any((l) => RegExp(r'\bDropdownMenu\(').hasMatch(l)),
          isFalse,
          reason: 'banxa_buy_screen.dart still constructs a raw DropdownMenu',
        );
        expect(
          lines.any((l) => RegExp(r'\bTextField\(').hasMatch(l)),
          isFalse,
          reason:
              'banxa_buy_screen.dart still constructs a bare TextField '
              '(only GWTextField is allowed)',
        );
      },
    );

    testWidgets('no widget reports a verification status', (tester) async {
      await pumpOffline(tester);

      // A negative claim, guarded so a future well-meaning addition trips
      // this test rather than shipping a lie.
      final forbidden = RegExp(
        r'\bunverified\b|\bverified\b|\bkyc\s*status\b|\bverification\s*status\b',
        caseSensitive: false,
      );
      final texts = tester.widgetList<Text>(find.byType(Text));
      for (final t in texts) {
        final data = t.data ?? t.textSpan?.toPlainText() ?? '';
        expect(
          forbidden.hasMatch(data),
          isFalse,
          reason: 'Text "$data" reports a verification status',
        );
      }
      // The "Verify with Banxa" header ACTION is present (restored
      // 2026-07-31 walk item 1, after a since-reversed deletion) - it is an
      // ACTION, not a status: the loop above is what actually guards against
      // this page ever claiming a verification state.
      expect(find.text('Verify with Banxa'), findsOneWidget);
    });

    testWidgets('with quote == null the CTA reads Get quote', (tester) async {
      await pumpOffline(tester);
      expect(find.text('Get quote'), findsOneWidget);
      // Exactly one "Buy GNUS" — the page title. A second one would mean the
      // CTA had (wrongly) already switched to its post-quote label.
      expect(find.text('Buy GNUS'), findsOneWidget);
    });

    testWidgets('at 1400px the form and rail are side by side', (tester) async {
      await pumpOffline(tester, width: 1400, height: 1400);

      final formMarker = tester.getTopLeft(find.text('Get quote'));
      // The rail's KICKER, not its error text. The old marker was
      // "Couldn't load your orders", which only appeared because the offline
      // fetch failed — once the cubit stopped querying with a placeholder
      // customer id, a wallet-less rail correctly shows its empty state and
      // the error text is gone. The kicker renders in every state and both
      // layout branches.
      final railMarker = tester.getTopLeft(find.text('YOUR ORDERS').first);

      expect(railMarker.dx, greaterThan(formMarker.dx));
    });

    testWidgets('at 800px the form and rail are stacked, form above rail', (
      tester,
    ) async {
      await pumpOffline(tester, width: 800, height: 2200);

      final formBottom = tester.getBottomLeft(find.text('Get quote'));
      final railMarker = tester.getTopLeft(find.text('YOUR ORDERS').first);

      expect(railMarker.dy, greaterThan(formBottom.dy));
    });
  });

  group('/buy lives inside the app shell (router.dart)', () {
    // A static source check, not a widget/navigation test: the real
    // `geniusWalletRouter` needs `AppBloc`/`WalletDetailsCubit`/`GeniusApi`
    // and the rest of `main.dart`'s provider tree to construct, which is out
    // of proportion for pinning one route's PLACEMENT. `ShellRoute`'s own
    // paren-depth span is walked instead of hardcoding a "next sibling route"
    // line number, so this survives the shell gaining or losing routes
    // around `/buy` without going stale.
    test("the '/buy' GoRoute sits inside the ShellRoute, not beside it", () {
      final source = File('lib/navigation/router.dart').readAsStringSync();

      final shellStart = source.indexOf('ShellRoute(');
      expect(
        shellStart,
        greaterThanOrEqualTo(0),
        reason: 'router.dart no longer declares a ShellRoute at all',
      );

      // Walk paren depth from the `(` right after `ShellRoute` to find where
      // that single call closes, so this test does not depend on which
      // routes flank it.
      var depth = 0;
      var shellEnd = -1;
      for (var i = shellStart + 'ShellRoute'.length; i < source.length; i++) {
        final ch = source[i];
        if (ch == '(') {
          depth++;
        } else if (ch == ')') {
          depth--;
          if (depth == 0) {
            shellEnd = i;
            break;
          }
        }
      }
      expect(
        shellEnd,
        greaterThan(shellStart),
        reason: "ShellRoute(...)'s closing paren was not found",
      );

      // The exact-quote form so `'/buy'` never matches `'/buy/orders'`
      // (which continues past the closing quote).
      const buyRouteLiteral = "path: '/buy'";
      final buyIndex = source.indexOf(buyRouteLiteral);
      expect(
        buyIndex,
        greaterThanOrEqualTo(0),
        reason: "router.dart no longer declares a '/buy' route",
      );
      expect(
        buyIndex,
        greaterThan(shellStart),
        reason: "'/buy' must be declared INSIDE the ShellRoute, not before it",
      );
      expect(
        buyIndex,
        lessThan(shellEnd),
        reason:
            "'/buy' must be declared INSIDE the ShellRoute's routes list, "
            'not after it closes',
      );

      // '/buy/orders' stays OUTSIDE the shell (unchanged by this move) — it
      // keeps its own back-arrow AppBar (`banxa_orders_history.dart`) rather
      // than the shell's persistent nav chrome.
      final ordersIndex = source.indexOf("path: '/buy/orders'");
      expect(
        ordersIndex,
        greaterThanOrEqualTo(0),
        reason: "router.dart no longer declares a '/buy/orders' route",
      );
      expect(
        ordersIndex < shellStart || ordersIndex > shellEnd,
        isTrue,
        reason: "'/buy/orders' unexpectedly moved inside the ShellRoute",
      );
    });
  });
}
