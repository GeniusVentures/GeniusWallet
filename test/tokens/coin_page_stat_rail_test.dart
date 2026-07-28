// The checks sketch 071-B owes.
//
// Two of the three defects it fixes are invisible to any screenshot:
//
//  * `SizedBox(height: 480)`. A constant chart height LOOKS fine - it looked
//    fine for months - and only reads as wrong when you notice half the window
//    is empty. So the height rule is pinned by asking for two viewports and
//    demanding two answers.
//
//  * `CoinGeckoMarketData.fromJson` defaults every numeric to 0.0 and the rank
//    to 0, so a coin missing a field renders `$0.00` and `#0` with complete
//    confidence. That is not an empty tile; it is a wrong one, and nothing on
//    screen says so.
//
// The third, the no-data page, is a real render because it is a layout claim:
// the empty state appears AND the action bar and Info card survive beside it.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// `WalletDetailsCubit` takes a `GeniusApi` this screen never touches in the
/// no-data path - the only call is `getCoins()` behind the More drawer, which
/// no test here opens. Same four-line stand-in the transactions frame test uses:
/// it satisfies the type and throws loudly rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget _host() => BlocProvider(
      create: (_) => WalletDetailsCubit(
        geniusApi: _UnusedApi(),
        networkTokensProvider: NetworkTokensProvider(),
      ),
      child: MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Builder(
          builder: (context) => TokenInfoScreen(
            walletDetailsCubit: context.read<WalletDetailsCubit>(),
            // The state this test exists for. Reachable from the wallet's own
            // Assets list, which looks the coin up by symbol and passes null
            // when CoinGecko does not cover it.
            marketData: null,
          ),
        ),
      ),
    );

void main() {
  group('coinChartHeight - the 480 literal must not come back', () {
    test('a taller window gives a taller chart', () {
      final short = coinChartHeight(viewportHeight: 800, isDesktop: true);
      final tall = coinChartHeight(viewportHeight: 1335, isDesktop: true);
      // The whole point. A constant passes every screenshot and fails this.
      expect(tall, greaterThan(short));
      expect(tall - short, 1335 - 800);
    });

    test('a short window hits the floor instead of collapsing', () {
      // 500 - 380 of chrome = 120, which is not a chart. The page scrolls.
      expect(coinChartHeight(viewportHeight: 500, isDesktop: true), 300);
      expect(coinChartHeight(viewportHeight: 200, isDesktop: true), 300);
    });

    test('mobile keeps its fixed height - there is no viewport to fill', () {
      // Below 768 the page is one scrolling column (sketch 152-D), so the
      // chart is a station on the way down rather than the page itself.
      expect(coinChartHeight(viewportHeight: 1335, isDesktop: false), 260);
      expect(coinChartHeight(viewportHeight: 400, isDesktop: false), 260);
    });
  });

  group('0 means unknown, not zero', () {
    test('a missing field says N/A rather than a confident zero', () {
      expect(formatCompactCurrency(0), 'N/A');
      expect(formatCompactCurrency(null), 'N/A');
      expect(formatCompactDecimal(0), 'N/A');
      expect(formatPrice(0), 'N/A');
      expect(formatPrice(null), 'N/A');
      // The rank is an int defaulting to 0, which would read as "first".
      expect(formatPercent(0), 'N/A');
      expect(formatPercent(null), 'N/A');
    });

    test('a real value still formats', () {
      expect(formatPrice(63504), '\$63,504.00');
      expect(formatPercent(-2.9), '-2.90%');
      // The sign is explicit on the way up, because "2.90%" and "+2.90%" read
      // differently next to a red one.
      expect(formatPercent(2.9), '+2.90%');
      expect(formatCompactCurrency(1270000000000), isNot('N/A'));
    });
  });

  testWidgets('no market data: the page SAYS so and keeps what still works',
      (tester) async {
    tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host());
    await tester.pump();

    // Before 071-B this state silently dropped the hero, the action bar and the
    // chart, and the user was left with a shorter page and no explanation.
    expect(find.byType(GWEmptyState), findsOneWidget);
    expect(find.text('No market data'), findsOneWidget);

    // Jakub's condition on the decision: what still works must stay. Receive
    // does not need a market price.
    //
    // 074-C2: the four-tile bar is gone, so this asks for the ACTION rather
    // than the widget - `byTooltip` is also the only check that fails if the
    // tooltip is dropped, which for an icon-only button is the whole label.
    expect(find.byTooltip('Receive'), findsOneWidget);
    expect(find.byType(CoinInfoCard), findsOneWidget);
  });

  testWidgets('074-C2: no Send, and no Bridge on a coin that cannot bridge',
      (tester) async {
    tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host());
    await tester.pump();

    // Send has no screen and no route - `GeniusApi.transferTokens` has zero
    // callers - so it must not appear at all, including as a disabled box.
    // This is the check that fails if someone "restores" the missing tile.
    expect(find.byTooltip('Send'), findsNothing);

    // Swap is wired and works from every route.
    expect(find.byTooltip('Swap'), findsOneWidget);

    // Bridge is ABSENT, not greyed: `isGnusWalletConnected` is null here, so
    // the action does not apply rather than being unavailable.
    expect(find.byTooltip('Bridge'), findsNothing);
  });

  testWidgets('the Receive drawer never says "Receive null"', (tester) async {
    tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_host());
    await tester.pump();

    // No coin is selected - the state you land in arriving from Markets, where
    // the wallet cubit's `selectedCoin` has nothing to do with the coin you
    // were reading about. `"Receive ${selectedCoin?.name}"` interpolated the
    // null straight into the header.
    await tester.tap(find.byTooltip('Receive'));
    await tester.pumpAndSettle();

    expect(find.text('Receive null'), findsNothing);
    expect(find.text('Receive'), findsOneWidget);
  });
}
