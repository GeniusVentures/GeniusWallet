// The claim: growing the Markets hero chart from 180 to 253 costs the WIDE
// card no height, because the right column sits in an `IntrinsicHeight` row
// whose height comes from the taller LEFT column, and the `Spacer` in
// `buildRight` absorbs the 73px difference.
//
// **This file previously recorded that claim as FALSIFIED. It was not, and the
// error was here rather than in the claim.** The old host wrapped the card in
// `SizedBox(width: 1200)` and its comments asserted that width "clears
// GeniusBreakpoints.medium (768), so this is the WIDE (IntrinsicHeight row)
// layout". It never set `tester.view.physicalSize`, which defaults to 800x600,
// so the `SizedBox` was clamped and the card rendered **stacked**. The stacked
// branch passes `fill: false` - no `Spacer`, no `IntrinsicHeight` - so the card
// grew by exactly the chart's delta, which is correct behaviour for the one
// layout the claim was never about. 619.0 and 692.0 are stacked-layout numbers.
//
// The lesson is the one this repo keeps re-learning: a widget test that does
// not set its surface is not testing the width it says it is. Both layouts are
// now pinned, at surfaces that actually produce them.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/chart/chart_axis.dart';
import 'package:genius_wallet/dashboard/chart/markets_hero_card.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:intl/intl.dart';

import 'markets_fixtures.dart';

/// The exact string the hero's own private `_price` formats — built from the
/// fixture's `currentPrice` through the same `NumberFormat.currency` rather
/// than a hardcoded dollar string, so the finder cannot drift from the data.
String _fixturePriceText() {
  final v = marketsFixtureMarketData().currentPrice;
  final decimals = v >= 1 ? 2 : 6;
  return NumberFormat.currency(symbol: '\$', decimalDigits: decimals).format(v);
}

/// The same shape as the hero's only real consumer, `markets_screen.dart:197` —
/// a column inside a `SingleChildScrollView`, which hands its child unbounded
/// height in the scroll direction.
Widget _host() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SingleChildScrollView(
      child: MarketsHeroCard(
        coin: marketsFixtureCoin(),
        data: marketsFixtureMarketData(),
      ),
    ),
  ),
);

extension on WidgetTester {
  /// Sets the surface for real. Without this the default 800x600 decides the
  /// layout branch no matter what the widget tree asks for — the whole reason
  /// this file's earlier conclusion was wrong.
  Future<void> pumpHeroAt(Size size) async {
    view.physicalSize = size;
    view.devicePixelRatio = 1.0;
    addTearDown(view.reset);
    await pumpWidget(_host());
    await pump();
  }
}

void main() {
  group('wide markets hero: the Spacer really does absorb the chart', () {
    // Measured 2026-07-30 at a surface actually set to 1400x1000. The card is
    // the same height with a 180px chart and with a 253px one — re-verified by
    // flipping the constant and re-running, which is the check the old version
    // of this test believed it was doing.
    const wideCardHeight = 367.0;
    const intrinsicRowHeight = 301.0;

    testWidgets('the card holds its height at the shipped chart size', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MarketsHeroCard)).height,
        wideCardHeight,
      );
    });

    testWidgets('the IntrinsicHeight row is driven by the LEFT column', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      // 301 is the left column's derived height to the pixel — 46 icon + 20 +
      // 48 price + 16 + 24 pill + 24 + 1 rule + 24 + 39 stat + 20 + 39 stat.
      // If the RIGHT column ever became the taller one this number moves, and
      // the "free" chart height stops being free — which is the actual
      // invariant behind the constant, not the card height alone.
      expect(
        tester.getSize(find.byType(IntrinsicHeight)).height,
        intrinsicRowHeight,
        reason:
            'the right column now drives the row: the chart is no longer '
            'free and kMarketsHeroChartHeight must be re-measured',
      );
    });

    testWidgets('the chart fills the wide height and gets the frame', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      expect(tester.takeException(), isNull);

      // The frame splits the box into plot + time row, so the LineChart is
      // shorter than the SizedBox by exactly the time row. Asserting the
      // relationship rather than a literal keeps this honest if either
      // constant moves.
      final chartHeight = tester.getSize(find.byType(LineChart)).height;
      expect(chartHeight, lessThan(kMarketsHeroChartHeight));
      expect(chartHeight, greaterThan(kMarketsHeroChartHeight - 40));

      // The right axis is the frame's most visible promise: money labels on
      // nice-rounded values down the right edge.
      expect(find.textContaining(r'$6'), findsWidgets);
    });
  });

  group('stacked markets hero: the narrow chart now earns the frame', () {
    testWidgets('the stacked chart is framed: shorter than its box by the '
        'time row, and shows money labels', (tester) async {
      await tester.pumpHeroAt(const Size(600, 1200));

      expect(tester.takeException(), isNull);
      // The stacked branch still has no IntrinsicHeight — it stacks in an
      // unbounded Column, where IntrinsicHeight is neither needed nor safe.
      expect(find.byType(IntrinsicHeight), findsNothing);

      // The frame splits the box into plot + time row, so the LineChart is
      // shorter than kMarketsHeroChartHeightStacked by exactly the time row —
      // asserting the relationship, not a literal, keeps this honest if
      // either constant moves.
      final chartHeight = tester.getSize(find.byType(LineChart)).height;
      expect(chartHeight, kMarketsHeroChartHeightStacked - kChartTimeRowHeight);

      // Money labels down the right edge are the frame's most visible
      // promise, and BXS-02's whole point.
      expect(find.textContaining(r'$6'), findsWidgets);
    });
  });

  group('BXS-01: the price and title shrink at phone width only', () {
    testWidgets('at 402x900 the price resolves to numericDisplay and the '
        'title to titleMd', (tester) async {
      await tester.pumpHeroAt(const Size(402, 900));

      expect(tester.takeException(), isNull);

      final priceStyle = tester
          .renderObject<RenderParagraph>(find.text(_fixturePriceText()))
          .text
          .style;
      expect(
        priceStyle!.fontSize,
        GeniusWalletTypography.numericDisplay.fontSize,
      );

      final titleStyle = tester
          .renderObject<RenderParagraph>(find.text('Bitcoin'))
          .text
          .style;
      expect(titleStyle!.fontSize, GeniusWalletTypography.titleMd.fontSize);
    });

    testWidgets('at 1400x1000 the price is still 48 — a guard on decision 3: a '
        'failure here means the desktop hero was shrunk and the pinned '
        'heights (367.0 / 301.0) are about to move', (tester) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      expect(tester.takeException(), isNull);

      final priceStyle = tester
          .renderObject<RenderParagraph>(find.text(_fixturePriceText()))
          .text
          .style;
      expect(priceStyle!.fontSize, 48);

      final titleStyle = tester
          .renderObject<RenderParagraph>(find.text('Bitcoin'))
          .text
          .style;
      expect(titleStyle!.fontSize, GeniusWalletTypography.titleLg.fontSize);
    });
  });
}
