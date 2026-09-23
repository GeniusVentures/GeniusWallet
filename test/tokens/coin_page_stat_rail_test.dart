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
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/tokens/token_info_screen.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

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
        // when CoinGecko does not cover it. No `coinGeckoId` either, so the
        // page goes straight to `uncovered` rather than fetching.
        args: const TokenInfoArgs(),
        isGnusWalletConnected: false,
      ),
    ),
  ),
);

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const _usdcCoin = Coin(symbol: 'USDC', balance: 10);

Wallet _walletOf(WalletType type) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: type,
  balance: 0,
  address: '0x1234567890123456789012345678901234567890',
);

/// A wallet on a signable testnet, USDC seated as the page's selected coin --
/// the state that puts the Send button on screen.
class _SeededCubit extends WalletDetailsCubit {
  _SeededCubit({
    required super.geniusApi,
    required super.networkTokensProvider,
    WalletType walletType = WalletType.mnemonic,
  }) {
    emit(
      state.copyWith(
        selectedWallet: _walletOf(walletType),
        selectedNetwork: _amoy,
        selectedCoin: _usdcCoin,
        coins: const [_usdcCoin],
        coinsStatus: WalletStatus.successful,
      ),
    );
  }
}

/// Same page, routed: `/send` records the extra its Send button pushes so the
/// test can assert what actually crossed the boundary rather than trusting
/// the call was made.
Widget _routedHost(WalletDetailsCubit cubit, Map<String, dynamic> captured) {
  final router = GoRouter(
    initialLocation: '/token-info',
    routes: [
      GoRoute(
        path: '/token-info',
        builder: (context, state) => TokenInfoScreen(
          walletDetailsCubit: cubit,
          args: const TokenInfoArgs(),
          isGnusWalletConnected: false,
        ),
      ),
      GoRoute(
        path: '/send',
        builder: (context, state) {
          captured.addAll(state.extra as Map<String, dynamic>);
          return const Scaffold(body: Text('send placeholder'));
        },
      ),
    ],
  );
  return MaterialApp.router(
    theme: ThemeData(extensions: [GWColors.dark()]),
    routerConfig: router,
  );
}

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

  testWidgets('no market data: the page SAYS so and keeps what still works', (
    tester,
  ) async {
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
    // sketch 165 Synthesis, change 3: the actions carry visible labels now, so
    // this asks for a BUTTON saying the word rather than a tooltip - a
    // `find.text` alone would also match the drawer title.
    expect(find.widgetWithText(GWButton, 'Receive'), findsOneWidget);
    expect(find.byType(CoinInfoCard), findsOneWidget);
  });

  testWidgets(
    '074-C2: no Send without a signable network, and no Bridge on a coin '
    'that cannot bridge',
    (tester) async {
      tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host());
      await tester.pump();

      // Send is absent because no coin, wallet or signable network is
      // selected here -- `canSendFrom` refuses a `null` network. This is the
      // check that fails if someone drops the guard and shows Send always.
      //
      // A `find.byTooltip` finder would pass vacuously now that no action
      // carries a tooltip at all (sketch 165, change 3) - the wrong reason to
      // be green - so this asserts against the label directly.
      expect(find.widgetWithText(GWButton, 'Send'), findsNothing);

      // Swap is wired and works from every route.
      expect(find.widgetWithText(GWButton, 'Swap'), findsOneWidget);

      // Bridge is ABSENT, not greyed: no coin is selected here, so
      // `isGnusBridgeEnabled`'s symbol check is false regardless of
      // `isGnusWalletConnected` - the action does not apply rather than being
      // unavailable.
      expect(find.widgetWithText(GWButton, 'Bridge'), findsNothing);
    },
  );

  testWidgets('Send opens /send with the coin seated on a signable network', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final cubit = _SeededCubit(
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    final captured = <String, dynamic>{};

    await tester.pumpWidget(_routedHost(cubit, captured));
    await tester.pump();

    expect(find.widgetWithText(GWButton, 'Send'), findsOneWidget);

    await tester.tap(find.widgetWithText(GWButton, 'Send'));
    await tester.pumpAndSettle();

    expect(captured, {'symbol': 'USDC', 'chainId': 80002});
  });

  testWidgets('a watch-only or SDK wallet is offered no Send', (tester) async {
    tester.view.physicalSize = const Size(1400 * 2, 1000 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final type in [WalletType.tracking, WalletType.sgnus]) {
      final cubit = _SeededCubit(
        geniusApi: _UnusedApi(),
        networkTokensProvider: NetworkTokensProvider(),
        walletType: type,
      );

      await tester.pumpWidget(_routedHost(cubit, {}));
      await tester.pump();

      expect(
        find.widgetWithText(GWButton, 'Send'),
        findsNothing,
        reason: '$type',
      );
    }
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
    //
    // **The trap this replaces:** once the BUTTON also renders the word
    // "Receive" (sketch 165, change 3), a bare `find.text('Receive')` matches
    // two widgets - the button's own label and the drawer's title - and the
    // old assertion (`findsOneWidget`) would fail on a change it was never
    // about. Tap the button by its widget+text pair, then assert the null
    // interpolation never happened and that the drawer's own title renders.
    await tester.tap(find.widgetWithText(GWButton, 'Receive'));
    await tester.pumpAndSettle();

    expect(find.text('Receive null'), findsNothing);
    // The drawer's own title Text lives inside its `AppBar` -
    // `ResponsiveDrawer` renders one whenever `title` is non-null - which the
    // button (a `GWButton`, no `AppBar` in its tree) cannot match.
    final drawerTitle = find.descendant(
      of: find.byType(AppBar),
      matching: find.text('Receive'),
    );
    expect(drawerTitle, findsOneWidget);
  });
}
