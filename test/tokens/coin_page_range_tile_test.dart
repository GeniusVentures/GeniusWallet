// The 24h-range checks, pinned after the 2026-07-29 walk ("ten tab jest jakiś
// nie halo") and moved along with the widget by sketch 165 Synthesis (change
// 5, 2026-07-30): the range readout is no longer a stat-rail tile, it is a
// fixed-24h footer under the chart, inside the chart's own card.
//
// **The first hypothesis was wrong and this test is what killed it.** The track
// was read as collapsing to zero width — `Container(height: 4)` carries no
// width, and a `Stack` lays its non-positioned children out under LOOSE
// constraints. That reasoning skips a rule: a `Container` with no child and no
// width expands to fill what it is offered, so the track was already spanning
// its parent. It measured 189.0px on the first run, before any fix. The rail
// was invisible for a COLOUR reason, not a layout one, and the fix moved
// accordingly. The width assertion stays as the regression guard the wrong
// theory earned - the width now comes from the chart card rather than a 213px
// stat tile, so the `greaterThan(80)` floor is if anything more slack than
// before.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Built through `fromJson` rather than the 25-argument constructor, and with
/// the same shape the walk was looking at: a price sitting near the LOW end of
/// the day's range, so a marker pinned at t≈0.09 cannot be mistaken for a
/// track that happens to start at the left edge.
CoinGeckoMarketData _btc() => CoinGeckoMarketData.fromJson({
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image': '',
  'current_price': 63514.0,
  'market_cap': 1.27e12,
  'market_cap_rank': 1,
  'total_volume': 2.81e10,
  'high_24h': 64700.0,
  'low_24h': 63400.0,
  'price_change_24h': -383.0,
  'price_change_percentage_24h': -0.6,
  'circulating_supply': 2.01e7,
  'total_supply': 2.01e7,
  'ath': 126000.0,
  'ath_change_percentage': -49.62,
});

/// The other extreme: a price sitting near the HIGH end of the day's range
/// (t ≈ 0.92), so a marker clamped at the wrong bound cannot pass by never
/// being asked to sit near the far edge.
CoinGeckoMarketData _btcNearHigh() => CoinGeckoMarketData.fromJson({
  'id': 'bitcoin',
  'symbol': 'btc',
  'name': 'Bitcoin',
  'image': '',
  'current_price': 64600.0,
  'market_cap': 1.27e12,
  'market_cap_rank': 1,
  'total_volume': 2.81e10,
  'high_24h': 64700.0,
  'low_24h': 63400.0,
  'price_change_24h': 700.0,
  'price_change_percentage_24h': 1.1,
  'circulating_supply': 2.01e7,
  'total_supply': 2.01e7,
  'ath': 126000.0,
  'ath_change_percentage': -48.73,
});

Widget _host(CoinGeckoMarketData data) => BlocProvider(
  create: (_) => WalletDetailsCubit(
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: Builder(
      builder: (context) => TokenInfoScreen(
        walletDetailsCubit: context.read<WalletDetailsCubit>(),
        args: TokenInfoArgs(marketData: data),
        isGnusWalletConnected: false,
      ),
    ),
  ),
);

void main() {
  // Wide enough for the rail's own `>= 900` branch, so all FIVE tiles share
  // one run and the height comparison is between neighbours rather than rows.
  const Size desktop = Size(1400, 1000);

  Future<void> pumpCoinPage(
    WidgetTester tester, {
    CoinGeckoMarketData? data,
    Size size = desktop,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(data ?? _btc()));
    await tester.pump();
  }

  testWidgets('the range track spans the chart card instead of collapsing '
      'to 0', (tester) async {
    await pumpCoinPage(tester);

    final track = find.byKey(kCoinRangeTrackKey);
    expect(track, findsOneWidget);

    final double trackWidth = tester.getSize(track).width;
    // The chart card is roughly a third of a 1400px window, less padding. The
    // exact number is layout's business; what matters is that a rail exists
    // at all — the bug measured 0.0 here.
    expect(
      trackWidth,
      greaterThan(80),
      reason:
          'the 24h-range track collapsed to $trackWidth — a Stack lays its '
          'non-positioned children out loose, so a width-less Container is 0',
    );

    // And the marker must sit ON that track, not past its end.
    final marker = find.byKey(kCoinRangeMarkerKey);
    expect(marker, findsOneWidget);
    final double trackLeft = tester.getTopLeft(track).dx;
    final double markerLeft = tester.getTopLeft(marker).dx;
    final double markerRight = markerLeft + tester.getSize(marker).width;
    expect(markerLeft, greaterThanOrEqualTo(trackLeft - 0.01));
    expect(markerRight, lessThanOrEqualTo(trackLeft + trackWidth + 0.01));
  });

  testWidgets('the marker does not overshoot at the high end of the range', (
    tester,
  ) async {
    await pumpCoinPage(tester, data: _btcNearHigh());

    final track = find.byKey(kCoinRangeTrackKey);
    final marker = find.byKey(kCoinRangeMarkerKey);
    expect(track, findsOneWidget);
    expect(marker, findsOneWidget);

    final double trackLeft = tester.getTopLeft(track).dx;
    final double trackWidth = tester.getSize(track).width;
    final double markerLeft = tester.getTopLeft(marker).dx;
    final double markerRight = markerLeft + tester.getSize(marker).width;

    // Near the top of the range, the marker sits close to the track's RIGHT
    // end - and must never cross it, however the clamp is written.
    expect(markerRight, lessThanOrEqualTo(trackLeft + trackWidth + 0.01));
    expect(
      markerLeft,
      greaterThan(trackLeft + trackWidth * 0.5),
      reason:
          'a price near the HIGH end of the range should sit past the '
          'track\'s midpoint, not near its low end',
    );
  });

  testWidgets(
    'the five rail cards are the same height, and none of them is a range '
    'tile',
    (tester) async {
      await pumpCoinPage(tester);

      // GWKicker upper-cases what it is handed, so the rendered text is
      // 'RANK', not the 'Rank' the call site writes.
      Finder cardFor(String label) => find
          .ancestor(of: find.text(label), matching: find.byType(GWCard))
          .first;

      // sketch 165 Synthesis, change 4: `_RangeTile` left the rail to become
      // the chart's footer, so the rail is five cards now, none of them a
      // range readout.
      const labels = [
        'RANK',
        '24H CHANGE',
        'VOLUME 24H',
        'MARKET CAP',
        'FROM ATH',
      ];
      final heights = labels
          .map((label) => tester.getSize(cardFor(label)).height)
          .toList();

      for (final h in heights.skip(1)) {
        expect(
          h,
          moreOrLessEquals(heights.first, epsilon: 0.5),
          reason:
              'rail card heights were $heights — one tile standing proud of '
              'its neighbours is what read as broken on the walk',
        );
      }

      expect(
        find.text('24H RANGE'),
        findsNothing,
        reason:
            'the range readout moved to the chart footer; it must not '
            'still be a rail tile',
      );
    },
  );

  testWidgets(
    'no rail row leaves a hole at its right edge, at any tested width',
    (tester) async {
      const labels = [
        'RANK',
        '24H CHANGE',
        'VOLUME 24H',
        'MARKET CAP',
        'FROM ATH',
      ];

      // 1400/900/768/600/360: the five widths the checkpoint walk is asked to
      // resize slowly through. Five tiles has no perRow ladder whose steps
      // all divide 5 (only 1 and 5 do), so the rail computes each ROW's tile
      // width from that row's own tile count rather than from a nominal
      // `perRow` — the fix that makes a partial last row reach the same
      // right edge as a full one instead of stopping short.
      for (final width in const [1400.0, 900.0, 768.0, 600.0, 360.0]) {
        await pumpCoinPage(tester, size: Size(width, 1800));

        // At narrow widths, unrelated subtrees this plan does not touch and
        // is not scoped to fix - `CoinConvertCard`'s read-only price row,
        // `CryptoLiveChart`'s own no-network fallback - can overflow. That is
        // a pre-existing condition, out of scope here (`AGENTS.md`/DECISION.md
        // both forbid touching Convert or the chart file in this plan); drain
        // it so this test only fails on what it actually asserts, the rail's
        // own layout.
        while (tester.takeException() != null) {}

        final rects = labels.map((label) {
          final card = find
              .ancestor(of: find.text(label), matching: find.byType(GWCard))
              .first;
          final topLeft = tester.getTopLeft(card);
          final size = tester.getSize(card);
          return Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
        }).toList();

        // Cluster cards into rows by their top Y (cards on the same row
        // share one), then take each row's rightmost edge.
        final rowTops = <double>[];
        final rowRightEdges = <double, double>{};
        for (final rect in rects) {
          final existingTop = rowTops.firstWhere(
            (y) => (y - rect.top).abs() < 1,
            orElse: () {
              rowTops.add(rect.top);
              return rect.top;
            },
          );
          final current = rowRightEdges[existingTop];
          rowRightEdges[existingTop] = current == null
              ? rect.right
              : math.max(current, rect.right);
        }

        final edges = rowRightEdges.values.toList();
        for (final edge in edges.skip(1)) {
          expect(
            edge,
            moreOrLessEquals(edges.first, epsilon: 1),
            reason:
                'row right edges were $edges at width $width — a shorter '
                'row is a hole at the rail\'s right edge',
          );
        }
      }
    },
  );

  testWidgets(
    'wide layout: the chart card and the Info+Convert column share one '
    'height',
    (tester) async {
      // Above GeniusBreakpoints.large (1024): the two-panel layout, where an
      // `IntrinsicHeight` row is supposed to take its height from the
      // Info+Convert column and stretch the chart card to match - never the
      // other way around. `_FillHeight` inside the chart card answers zero to
      // an intrinsic-height query so the footer added in Task 2 cannot
      // quietly make the chart start driving the row instead.
      await pumpCoinPage(tester, size: const Size(1400, 1000));

      final chartCard = find
          .ancestor(
            of: find.byType(CryptoLiveChart),
            matching: find.byType(GWCard),
          )
          .first;
      final infoCard = find.byType(CoinInfoCard);
      final convertCard = find.byType(CoinConvertCard);

      final double chartHeight = tester.getSize(chartCard).height;
      final double infoTop = tester.getTopLeft(infoCard).dy;
      final double convertBottom =
          tester.getTopLeft(convertCard).dy +
          tester.getSize(convertCard).height;
      final double infoConvertHeight = convertBottom - infoTop;

      expect(
        chartHeight,
        moreOrLessEquals(infoConvertHeight, epsilon: 1),
        reason:
            'chart card was $chartHeight tall against $infoConvertHeight '
            'for Info+Convert - the row must take its height from the side '
            'column, not the chart',
      );
    },
  );
}
