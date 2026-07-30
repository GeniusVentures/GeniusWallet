// The 24h-range tile, pinned after the 2026-07-29 walk ("ten tab jest jakiś nie
// halo"). These are layout claims a screenshot can only show and no unit test
// could reach, so they are real renders at a real desktop width.
//
// **The first hypothesis was wrong and this test is what killed it.** The track
// was read as collapsing to zero width — `Container(height: 4)` carries no
// width, and a `Stack` lays its non-positioned children out under LOOSE
// constraints. That reasoning skips a rule: a `Container` with no child and no
// width expands to fill what it is offered, so the track was already spanning
// the tile. It measured 189.0px on the first run, before any fix. The rail was
// invisible for a COLOUR reason, not a layout one, and the fix moved
// accordingly. The width assertion stays as the regression guard the wrong
// theory earned.
//
// What was genuinely broken is the height: the bar costs `space4 + 4` on top of
// the shared `GWStatTile`, and a `Wrap` neither stretches nor equalises its
// children — so one card in a row of six stood proud of the other five.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
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
        marketData: data,
      ),
    ),
  ),
);

void main() {
  // Wide enough for the rail's own `>= 900` branch, so all six tiles share one
  // run and the height comparison is between neighbours rather than rows.
  const Size desktop = Size(1400, 1000);

  Future<void> pumpCoinPage(WidgetTester tester) async {
    tester.view.physicalSize = desktop;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(_btc()));
    await tester.pump();
  }

  testWidgets('the range track spans the tile instead of collapsing to 0', (
    tester,
  ) async {
    await pumpCoinPage(tester);

    final track = find.byKey(kCoinRangeTrackKey);
    expect(track, findsOneWidget);

    final double trackWidth = tester.getSize(track).width;
    // The card is ~213 wide at this viewport, less padding. The exact number is
    // layout's business; what matters is that a rail exists at all — the bug
    // measured 0.0 here.
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

  testWidgets('the range tile is the same height as its neighbours', (
    tester,
  ) async {
    await pumpCoinPage(tester);

    // GWKicker upper-cases what it is handed, so the rendered text is 'RANK',
    // not the 'Rank' the call site writes.
    Finder cardFor(String label) => find
        .ancestor(of: find.text(label), matching: find.byType(GWCard))
        .first;

    final double rank = tester.getSize(cardFor('RANK')).height;
    final double range = tester.getSize(cardFor('24H RANGE')).height;

    expect(
      range,
      moreOrLessEquals(rank, epsilon: 0.5),
      reason:
          'the range card was $range against $rank for Rank — one tile in a '
          'row of six standing proud is what read as broken on the walk',
    );
  });
}
