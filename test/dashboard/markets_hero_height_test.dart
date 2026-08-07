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
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
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
  group('wide markets hero: 335.0/301.0, driven by the RIGHT column', () {
    // Measured 2026-07-30 at 1400x1000 as 367.0/301.0, when the LEFT
    // column's fixed 2x2 stat grid drove this row.
    //
    // **RE-MEASURED THREE TIMES on 2026-08-07 (quick 260807-bxs) — see
    // `kMarketsHeroChartHeight`'s doc comment in `markets_hero_card.dart`
    // for the full chronology.** Summary: (1) the stat block became a
    // `Wrap`, which flipped the DRIVER from the left column to the right
    // (`GWTimeframeSegment` + `space8` + the fixed-height chart, a hard
    // 301.0 independent of the stat block) without moving either literal;
    // (2) the stat tiles dropped their fixed width for content-sizing,
    // which again left both literals unmoved (the left column's practical
    // range is still 242.0 with four tiles on one row or 301.0 with a
    // wrap, never more); (3) the card's own outer padding halved
    // (`space16` to `space8`, a SEPARATE request), which DOES move the
    // card literal: 32px of padding (16 top + 16 bottom) comes off the
    // total, so the card is now 335.0. `IntrinsicHeight` itself is
    // confirmed unaffected at 301.0 -- the padding sits outside that row.
    const wideCardHeight = 335.0;
    const intrinsicRowHeight = 301.0;

    testWidgets('the card holds its height at the shipped chart size', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(MarketsHeroCard)).height,
        wideCardHeight,
        reason:
            'was 367.0 before the card padding halved (space16 to space8, '
            '2026-08-07) -- 32px of padding (16 top + 16 bottom) came off '
            'the total; if this literal fails for any OTHER reason, the '
            'padding is not the cause, re-derive from scratch',
      );
    });

    testWidgets('the IntrinsicHeight row is driven by the RIGHT column', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(1400, 1000));

      // 301.0 is the RIGHT column's own height (timeframe segment +
      // `space8` + the fixed-height chart) -- see the group comment above.
      // Unaffected by the card's own padding (outside this row) or the
      // stat block's tile width (content-sized tiles are still bounded at
      // 242.0-301.0, never above the right's fixed value).
      expect(
        tester.getSize(find.byType(IntrinsicHeight)).height,
        intrinsicRowHeight,
        reason:
            'the right column (timeframe segment + chart) no longer '
            'measures 301.0 on its own -- re-derive kMarketsHeroChartHeight '
            'and this literal together; neither the stat block nor the '
            "card's own padding can be the cause, both are structurally "
            'incapable of moving this row',
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
        'failure here means the desktop hero price was shrunk, which decision '
        '3 never asked for (a failure here no longer moves 335.0/301.0 -- '
        'those are the RIGHT column\'s and the card\'s own padding now, see '
        'the group above)', (tester) async {
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

  group('2026-08-07 follow-up: the stat block flows, content-sized', () {
    testWidgets('at 1400x1000 -- the width that matters -- all four stat '
        'tiles share one row', (tester) async {
      // 1400, not a wider surface: content-sized tiles (no fixed-width
      // floor, second 2026-08-07 correction) need far less room than the
      // original 152px-floored design did. Four tiles plus three `space6`
      // gaps sum to well under the wide card's left column at 1400 (the
      // floored design needed ~1700px for this same claim); re-measured
      // directly rather than assumed, since Braian specifically asked
      // about this width.
      await tester.pumpHeroAt(const Size(1400, 1000));

      expect(tester.takeException(), isNull);
      final tiles = find.byType(GWStatTile);
      expect(tiles, findsNWidgets(4));

      // Geometric proof, not a widget count: every tile's own top-left `y`
      // is identical only if all four sit in the same `Wrap` run.
      final tops = [
        for (var i = 0; i < 4; i++) tester.getTopLeft(tiles.at(i)).dy,
      ];
      expect(
        tops.toSet(),
        hasLength(1),
        reason:
            'all four stat tiles should share one row\'s top edge at '
            '1400px -- content-sized tiles fit here even though the '
            'earlier fixed-152px-width design did not',
      );
    });

    testWidgets('at 402x900 the stat tiles do NOT all share one row', (
      tester,
    ) async {
      await tester.pumpHeroAt(const Size(402, 900));

      expect(tester.takeException(), isNull);
      final tiles = find.byType(GWStatTile);
      expect(tiles, findsNWidgets(4));

      final tops = [
        for (var i = 0; i < 4; i++) tester.getTopLeft(tiles.at(i)).dy,
      ];
      expect(
        tops.toSet().length,
        greaterThan(1),
        reason:
            'the phone-width card should still wrap the stat block across '
            'more than one row (three tiles then one, not the old fixed '
            '2x2 split, but still more than one row) -- this is the "at '
            '402px they do not [share a row]" claim',
      );
    });
  });
}
