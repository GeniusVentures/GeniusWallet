// The claim under test: growing the Markets hero chart from 180 to 253 would
// cost the WIDE card no height, because the right column sits in an
// `IntrinsicHeight` row whose height comes from the taller LEFT column, and
// the `Spacer` at markets_hero_card.dart:167 is holding 73px of slack.
//
// That number was DERIVED from the widget tree at 8ed02e78, not measured in a
// running app — and 253 consumed the slack EXACTLY (left column 301 = 32
// segment + 16 gap + 253 chart), landing on the boundary with zero margin. A
// derivation that lands exactly on a boundary is precisely the kind that must
// be measured, not trusted — and this one did not survive being measured.
//
// **RESULT: the hypothesis was FALSIFIED.** This test was written and run
// FIRST against the shipped 180px chart, recording the real card height as
// `measuredCardHeight` below. Flipping `kMarketsHeroChartHeight` to 253 and
// re-running the SAME assertion showed the wide card growing by 73px — the
// exact amount the `Spacer` was supposed to be absorbing — so the "free on
// wide" claim does not hold. Per this task's own instruction ("if the
// wide-layout card grows, STOP and report it; do not accept a taller card
// and do not adjust the constant to match"), `kMarketsHeroChartHeight` stays
// at 180. This test now guards that regression: if a future change makes the
// card grow at the SHIPPED height, or silently bumps the constant without
// re-verifying the claim, this fails. See `260729-gt4-SUMMARY.md` for the
// full writeup and the two candidate fixes.
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/chart/markets_hero_card.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

CoinGeckoCoin _coin() =>
    CoinGeckoCoin(id: 'bitcoin', symbol: 'btc', name: 'Bitcoin');

/// A 30-point RISING sparkline — `up` reads true, so the chart takes
/// `statusSuccess`, matching the deterministic trend-colour rule under test
/// in the implementation (not asserted directly here; the height claim is).
List<double> _risingSparkline() =>
    List<double>.generate(30, (i) => 60000.0 + i * 120.0);

CoinGeckoMarketData _marketData() {
  final sparkline = _risingSparkline();
  final high = sparkline.reduce(max);
  final low = sparkline.reduce(min);
  return CoinGeckoMarketData(
    id: 'bitcoin',
    symbol: 'btc',
    name: 'Bitcoin',
    imageUrl: '',
    currentPrice: sparkline.last,
    marketCap: 1.2e12,
    marketCapRank: 1,
    fullyDilutedValuation: 1.3e12,
    totalVolume: 3.4e10,
    high24h: high,
    low24h: low,
    priceChange24h: sparkline.last - sparkline.first,
    priceChangePercentage24h:
        ((sparkline.last - sparkline.first) / sparkline.first) * 100,
    marketCapChange24h: 0,
    marketCapChangePercentage24h: 0,
    circulatingSupply: 19700000,
    totalSupply: 21000000,
    maxSupply: 21000000,
    ath: high * 1.5,
    athChangePercentage: -10,
    athDate: DateTime(2026, 1, 1),
    atl: low * 0.5,
    atlChangePercentage: 500,
    atlDate: DateTime(2020, 1, 1),
    lastUpdated: DateTime(2026, 7, 29),
    sparkline: sparkline,
  );
}

/// The same shape as the hero's only real consumer, `markets_screen.dart:197`
/// — a fixed-width column inside a `SingleChildScrollView`, which hands its
/// child unbounded height in the scroll direction. 1200px clears
/// `GeniusBreakpoints.medium` (768), so this is the WIDE (`IntrinsicHeight`
/// row) layout, not the narrow stacked one.
Widget _host() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SizedBox(
      width: 1200,
      child: SingleChildScrollView(
        child: MarketsHeroCard(coin: _coin(), data: _marketData()),
      ),
    ),
  ),
);

void main() {
  group(
    'wide markets hero: the "grow to 253 for free" hypothesis, measured',
    () {
      // Measured on this machine, 2026-07-29, against the SHIPPED
      // `kMarketsHeroChartHeight = 180` at markets_hero_card.dart. Flipping
      // the constant to 253 grew this by 73px (692.0) instead of holding —
      // that is the falsified hypothesis this file documents. The constant
      // stays at 180 pending Jakub's decision, so this pins the CURRENT,
      // correct height.
      const measuredCardHeight = 619.0;

      testWidgets('the card holds this height (measured, not derived)', (
        tester,
      ) async {
        await tester.pumpWidget(_host());
        await tester.pump();

        // A right column taller than the row would overflow the
        // `IntrinsicHeight` row's own height and throw.
        expect(tester.takeException(), isNull);

        final cardSize = tester.getSize(find.byType(MarketsHeroCard));
        expect(cardSize.height, measuredCardHeight);
      });

      testWidgets(
        'the chart itself is the expected height — a squeezed chart cannot '
        'pass by shrinking',
        (tester) async {
          await tester.pumpWidget(_host());
          await tester.pump();

          expect(tester.takeException(), isNull);

          final chartSize = tester.getSize(find.byType(LineChart));
          // Pinned to the SAME constant `markets_hero_card.dart` uses for its
          // `SizedBox(height: ...)` around `_HeroChart` — 180 today, 253
          // after Task 4(a). Read from the shipped literal so this test fails
          // loudly (rather than silently) if the two constants ever diverge.
          expect(chartSize.height, kMarketsHeroChartHeight);
        },
      );
    },
  );
}
