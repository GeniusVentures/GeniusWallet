import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:genius_wallet/banxa/banxa_model.dart';
import 'package:genius_wallet/banxa/banxa_order/banxa_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_cubit.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/components/inputs/gw_select.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/screens/banxa_buy_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

import 'fixtures.dart';
import 'gw_pump.dart';

/// 260731-uhe: the Buy GNUS form card, restructured to the design's order.
///
/// Two kinds of test live here. The MEASUREMENT pair reads geometry, prints
/// it and asserts only that it is non-zero - the idiom
/// `orders_header_track_test.dart`'s own "MEASUREMENT" test established, so
/// the side-by-side threshold in `BanxaBuyForm` is set from numbers somebody
/// actually pumped rather than from an estimate. The rest are real claims,
/// pinned by GEOMETRY (`tester.getRect().top`) rather than by presence -
/// presence passes against the PRE-restructure form too and proves nothing
/// about order.
///
/// The quote state, a non-USD fiat and a min/max-bounded payment method are
/// reachable here for the first time because `BanxaBuyForm` is public and
/// takes a `MakeOrderState` (see its own doc). Before that they could only be
/// pinned against a hand-copied replica.
void main() {
  Widget pumpableBuyScreen() => BlocProvider<OrdersCubit>(
    create: (_) => OrdersCubit(),
    child: const BanxaBuyScreen(),
  );

  /// The form card ALONE, at a fixed width, with a seeded state - the seam the
  /// extraction bought. A real `MakeOrderCubit` is provided because the
  /// selects' `onChanged` closures read one; its constructor touches no
  /// network, and nothing in these tests calls it.
  Widget pumpableForm(MakeOrderState state, {required double cardInnerWidth}) =>
      BlocProvider<MakeOrderCubit>(
        create: (_) => MakeOrderCubit(BanxaApiService()),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            // The card's OUTER width. `cardInnerWidth` is that minus 34
            // (space8 of padding each side plus 1px of hairline each side),
            // which is exactly what the screen hands down.
            width: cardInnerWidth + 34,
            child: BanxaBuyForm(
              state: state,
              cardInnerWidth: cardInnerWidth,
              onRetryCurrencies: () {},
              onGetQuote: () {},
              onBuy: () {},
            ),
          ),
        ),
      );

  /// A payment method whose range admits [max] and above [min].
  PaymentMethod method({double min = 20, double max = 15000}) => PaymentMethod(
    id: 'pm_0001',
    name: 'Credit Card',
    minimum: min,
    maximum: max,
  );

  /// Pumps the form card alone on a surface tall enough to hold it. The
  /// default 800x600 test surface is SHORTER than the card, and a card that
  /// overflows its window measures its overflowed height, not its real one -
  /// which would quietly make the height comparisons below agree for the
  /// wrong reason.
  Future<void> pumpForm(
    WidgetTester tester,
    MakeOrderState state, {
    double cardInnerWidth = 726,
  }) async {
    await tester.binding.setSurfaceSize(const Size(1600, 2400));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      gwHost(pumpableForm(state, cardInnerWidth: cardInnerWidth)),
    );
    await tester.pump();
  }

  /// The offline pump shape the rest of `test/banxa/` uses: `setSurfaceSize`
  /// (a wrapping `SizedBox` gets clamped to the default surface and the page's
  /// own `LayoutBuilder` would never see the width), then fixed-step pumps -
  /// never `pumpAndSettle`, which can hang on the boot scrim.
  Future<void> pumpOffline(
    WidgetTester tester, {
    required double width,
    required double height,
  }) async {
    await tester.binding.setSurfaceSize(Size(width, height));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(gwHost(pumpableBuyScreen()));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
    'MEASUREMENT: the intrinsic widths of the CURRENCY and PAYMENT METHOD columns',
    (tester) async {
      // Worst-case REAL Banxa labels, not invented ones: the fiat select
      // renders `'${f.name} (${f.code})'`, and `'Credit / Debit Card'` is the
      // longest payment-method name the sandbox returns.
      Widget column(String kicker, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          GWKicker(kicker),
          const SizedBox(height: GeniusWalletConsts.space4),
          GWSelect<String>(
            value: value,
            items: [GWSelectItem(value: value, label: value)],
            onChanged: (_) {},
          ),
        ],
      );

      Future<double> measure(String kicker, String value) async {
        await tester.pumpWidget(
          gwHost(
            Align(
              alignment: Alignment.topLeft,
              child: IntrinsicWidth(child: column(kicker, value)),
            ),
          ),
        );
        await tester.pump();
        return tester.getSize(find.byType(GWSelect<String>)).width;
      }

      final currency = await measure('Currency', 'United States Dollar (USD)');
      final payment = await measure('Payment method', 'Credit / Debit Card');

      // The TYPICAL pair as well as the worst-case one. The worst case is not
      // a usable threshold on its own: a `GWSelect` ellipsizes rather than
      // overflowing, so demanding the longest label render untruncated would
      // set a floor no real window in the two-column layout can clear.
      final currencyTypical = await measure('Currency', 'Euro (EUR)');
      final paymentTypical = await measure('Payment method', 'Credit Card');

      // The chrome floor: a select showing nothing but a currency code is the
      // width below which the control is all padding and arrow.
      final chromeFloor = await measure('Currency', 'USD');

      // Printed, not asserted - this test reads geometry, it does not pin a
      // threshold.
      // ignore: avoid_print
      print(
        'MEASURED worstCase currency=$currency payment=$payment '
        'sum+gap(16)=${currency + GeniusWalletConsts.space8 + payment}',
      );
      // ignore: avoid_print
      print(
        'MEASURED typical currency=$currencyTypical payment=$paymentTypical '
        'sum+gap(16)='
        '${currencyTypical + GeniusWalletConsts.space8 + paymentTypical}',
      );
      // ignore: avoid_print
      print('MEASURED chromeFloor=$chromeFloor');

      expect(currency, greaterThan(0));
      expect(payment, greaterThan(0));
      expect(currencyTypical, greaterThan(0));
      expect(paymentTypical, greaterThan(0));
    },
  );

  testWidgets(
    'MEASUREMENT: the form card\'s real inner width, checked against the formula',
    (tester) async {
      // 1048 is the narrowest two-column window (the layout check is
      // `constraints.maxWidth >= 1024` and the page eats 24 of horizontal
      // padding); 1560 is where the page hits `GeniusBreakpoints.xxl` and
      // stops growing.
      for (final window in <double>[375, 500, 1048, 1328, 1560]) {
        await pumpOffline(tester, width: window, height: 2400);
        tester.takeException();

        // The formula under test, restated here rather than imported so a
        // silent change to it cannot make this check agree with itself.
        final available = window - 24 > 1536 ? 1536.0 : window - 24;
        final wide = available >= 1024;
        final outer = wide
            ? (available - GeniusWalletConsts.space8) / 2
            : available;
        final predicted = outer - 34;

        // The `GWDetailGrid` is the card's one full-bleed child, so its
        // rendered width IS the card's inner content width.
        final measured = tester.getSize(find.byType(GWDetailGrid)).width;

        // ignore: avoid_print
        print(
          'MEASURED window=$window wide=$wide '
          'predictedInner=$predicted measuredInner=$measured',
        );

        expect(measured, greaterThan(0));
        expect(
          measured,
          closeTo(predicted, 0.5),
          reason:
              'the card-inner-width formula is wrong at window $window, so any '
              'threshold built on it would be built on a lie',
        );
      }
    },
  );

  group('the design\'s order, proven by geometry', () {
    testWidgets(
      'kicker, hero field, chips, CURRENCY, WALLET ADDRESS, grid, CTA - top to bottom',
      (tester) async {
        // The real screen offline. Every one of these renders without seeded
        // state: an empty currency list still builds a `GWSelect`, and the
        // ladder is unfiltered while no payment method is selected.
        await pumpOffline(tester, width: 1560, height: 2400);
        tester.takeException();

        double topOf(Finder f) => tester.getRect(f).top;

        final youSpend = topOf(find.text('YOU SPEND'));
        final heroField = topOf(find.byType(GWTextField).first);
        // `.first` — the FORM's quick-amount track. A second GWControlTrack
        // (the orders rail's filter track) is now on screen too: the rail
        // used to sit in a network-error state here, and reaches its empty
        // state — chrome included — since the orders cubit stopped querying
        // with a placeholder customer id. This chain is about the form's own
        // top-to-bottom order, so the form's track is the one to read.
        final track = topOf(find.byType(GWControlTrack).first);
        final currency = topOf(find.text('CURRENCY'));
        final wallet = topOf(find.text('WALLET ADDRESS'));
        final grid = topOf(find.byType(GWDetailGrid));
        final cta = topOf(find.text('Get quote'));

        // A CHAIN, not a set of presence checks: presence passes against the
        // pre-restructure form, which had the amount fourth from the top.
        expect(youSpend, lessThan(heroField));
        expect(heroField, lessThan(track));
        expect(track, lessThan(currency));
        expect(currency, lessThan(wallet));
        expect(wallet, lessThan(grid));
        expect(grid, lessThan(cta));
      },
    );

    testWidgets('the amount field is the hero, in a bigger type step', (
      tester,
    ) async {
      await pumpOffline(tester, width: 1560, height: 2400);
      tester.takeException();

      final hero = tester.widget<GWTextField>(find.byType(GWTextField).first);
      final wallet = tester.widget<GWTextField>(find.byType(GWTextField).last);

      expect(hero.textStyle, isNotNull);
      // Strictly greater than bodyLg's 16, which is what every other field on
      // the card renders at.
      expect(
        hero.textStyle!.fontSize,
        greaterThan(GeniusWalletTypography.bodyLg.fontSize!),
      );
      expect(wallet.textStyle, isNull);
    });
  });

  group('the amount shortcut chips', () {
    testWidgets(
      'tapping a chip writes the amount and marks the chip selected',
      (tester) async {
        // Disposed inside the test body, not via `addTearDown`: the
        // framework's own "a SemanticsHandle was active at the end of the
        // test" check runs BEFORE tear-downs do.
        final semantics = tester.ensureSemantics();

        // The REAL screen, so the live cubit carries the tap through
        // `setAmountText` and back into the field's controller.
        await pumpOffline(tester, width: 1560, height: 2400);
        tester.takeException();

        // Scoped to the track, so this cannot match the amount the field is
        // about to show. The label is a BARE `500` rather than `$500` here
        // because offline no fiat is selected, so there is neither a symbol
        // nor a code to denominate it with - `_chipLabel`'s fallback, which
        // the EUR test below exercises from the other side.
        final chip = find.descendant(
          of: find.byType(GWControlTrack),
          matching: find.text('500'),
        );
        expect(chip, findsOneWidget);

        await tester.tap(chip);
        await tester.pump();

        // The bare, parseable value reached the field - not a formatted
        // string, which `double.tryParse` would reject and silently disable
        // the CTA with no error.
        final hero = tester.widget<GWTextField>(find.byType(GWTextField).first);
        expect(hero.controller!.text, '500');

        // Reported through Semantics, never by reaching into the private chip.
        expect(
          tester.getSemantics(chip),
          matchesSemantics(
            hasSelectedState: true,
            isSelected: true,
            isButton: true,
            hasTapAction: true,
            // The chip is keyboard-reachable since it moved onto
            // `GWActivatable` (WCAG 2.1.1, Level A). Before that it was a bare
            // `GestureDetector` and this matcher pinned the defect: no focus
            // action, no isFocusable.
            hasFocusAction: true,
            isFocusable: true,
            label: '500',
          ),
        );

        semantics.dispose();
      },
    );

    testWidgets('chip labels follow the SELECTED fiat, not the dollar', (
      tester,
    ) async {
      await pumpForm(
        tester,
        testFormState(
          fiatCode: 'EUR',
          fiatSymbol: '€',
          paymentMethod: method(),
        ),
      );
      expect(tester.takeException(), isNull);

      final labels = tester
          .widgetList<Text>(
            find.descendant(
              of: find.byType(GWControlTrack),
              matching: find.byType(Text),
            ),
          )
          .map((t) => t.data ?? '')
          .toList();

      expect(labels, isNotEmpty);
      for (final label in labels) {
        expect(
          label.startsWith('\$'),
          isFalse,
          reason: 'chip "$label" is denominated in dollars with EUR selected',
        );
      }
      expect(labels.any((l) => l.contains('€')), isTrue);
    });
  });

  group('the height invariants that hold the orders rail still', () {
    /// The card's own rendered height at [cardInnerWidth].
    double formHeight(WidgetTester tester) =>
        tester.getSize(find.byType(BanxaBuyForm)).height;

    // 260731-vty: the hero's currency symbol moved from Material's
    // `prefixIcon` gutter (centred, 48x48 minimum) to its inline `prefix`
    // slot (baseline-laid-out, content-sized). Both tests below were
    // measured against the tree BEFORE that move and must read the same
    // number after it - the card's height is what the orders rail's
    // `IntrinsicHeight` rides on, so a symbol that reflows the field is a
    // rail that jumps.
    testWidgets('VTY-03: identical with an EMPTY amount and with 500.00', (
      tester,
    ) async {
      // The inline prefix is opacity-faded, not unmounted, while the field is
      // empty and unfocused. Opacity is not layout, so this pair proves the
      // reveal costs nothing - which is the whole reason that Material
      // behaviour was accepted rather than pinned open.
      await pumpForm(
        tester,
        testFormState(paymentMethod: method(), amountText: ''),
      );
      final empty = formHeight(tester);

      await pumpForm(
        tester,
        testFormState(paymentMethod: method(), amountText: '500.00'),
      );
      final filled = formHeight(tester);

      expect(empty, filled);
      expect(tester.takeException(), isNull);
    });

    testWidgets('VTY-03: the card height is the pre-move number, 648.0', (
      tester,
    ) async {
      // 648.0 was printed by this exact body against the tree before
      // `gw_text_field.dart` was touched on 2026-07-31. An absolute literal,
      // because every other height check in this file is self-relative and
      // would stay green if the whole card grew by 16px in one step.
      await pumpForm(tester, testFormState(paymentMethod: method()));
      expect(formHeight(tester), 648.0);
    });

    testWidgets('identical with quote == null and with a real quote', (
      tester,
    ) async {
      // This is the load-bearing one: since 260731-ti5 the orders rail DERIVES
      // its height from this card through `IntrinsicHeight`, so a card that
      // reflows when a quote lands makes the rail JUMP, not merely shift.
      await pumpForm(
        tester,
        testFormState(withQuote: false, paymentMethod: method()),
      );
      final withoutQuote = formHeight(tester);

      await pumpForm(tester, testFormState(paymentMethod: method()));
      final withQuote = formHeight(tester);

      expect(withoutQuote, greaterThan(0));
      expect(withQuote, closeTo(withoutQuote, 1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('identical whether the ladder shows four chips, one, or NONE', (
      tester,
    ) async {
      await pumpForm(tester, testFormState(paymentMethod: method(max: 15000)));
      final fourChips = formHeight(tester);
      expect(
        find.descendant(
          of: find.byType(GWControlTrack),
          matching: find.byType(Text),
        ),
        findsNWidgets(4),
      );

      // A maximum that admits only the first ladder amount.
      await pumpForm(tester, testFormState(paymentMethod: method(max: 100)));
      final oneChip = formHeight(tester);
      expect(
        find.descendant(
          of: find.byType(GWControlTrack),
          matching: find.byType(Text),
        ),
        findsOneWidget,
      );

      // A range that excludes EVERY ladder amount, so no track renders at
      // all. This is the case the fixed slot actually exists for, and the
      // one a four-versus-one comparison does NOT reach: one chip is the
      // same height as four, so only the empty ladder can collapse the row.
      // Verified by mutation - deleting the slot's `height` leaves the
      // four/one comparison green and fails only here.
      await pumpForm(tester, testFormState(paymentMethod: method(max: 50)));
      final noChips = formHeight(tester);
      expect(find.byType(GWControlTrack), findsNothing);

      expect(oneChip, closeTo(fourChips, 1));
      expect(noChips, closeTo(fourChips, 1));
      expect(tester.takeException(), isNull);
    });
  });

  group('CURRENCY and PAYMENT METHOD collapse at a measured threshold', () {
    testWidgets('side by side at 1560px, where the card inner width is 726', (
      tester,
    ) async {
      await pumpOffline(tester, width: 1560, height: 2400);
      tester.takeException();

      final currency = tester.getRect(find.text('CURRENCY'));
      final payment = tester.getRect(find.text('PAYMENT METHOD'));

      expect(currency.top, closeTo(payment.top, 0.5));
      expect(payment.left, greaterThan(currency.left));
    });

    testWidgets('stacked at 375px, where the card inner width is 317', (
      tester,
    ) async {
      await pumpOffline(tester, width: 375, height: 3000);
      // A chip-row overflow surfaces in a widget test as a recorded exception,
      // which is what this drains and then asserts on below.
      final exception = tester.takeException();

      final currency = tester.getRect(find.text('CURRENCY'));
      final payment = tester.getRect(find.text('PAYMENT METHOD'));

      expect(payment.top, greaterThan(currency.top));
      expect(
        exception,
        isNull,
        reason: 'the form card overflowed at phone width: $exception',
      );
    });

    testWidgets(
      'no LayoutBuilder or scroll viewport sneaked inside the card - 1400px throws nothing',
      (tester) async {
        // 1400 is a TWO-COLUMN window, so `IntrinsicHeight` queries the form
        // card for an intrinsic height here. Both `_RenderLayoutBuilder` and
        // `RenderViewport` answer that query by throwing, so this is the
        // assertion that catches either sneaking into the card.
        await pumpOffline(tester, width: 1400, height: 2400);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
