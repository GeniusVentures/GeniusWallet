import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/assets/assets_sort.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The `/assets` page, pumped for real.
///
/// **This file pumps the REAL screen**, not a hand-copied replica of its tree,
/// for the reason `transactions_page_frame_test.dart` sets out at length: a
/// replica cannot fail for the reason the file exists. Every assertion below
/// would stay green against a replica while `assets_screen.dart` was broken.
///
/// The apparatus is two pieces. [_UnusedApi] satisfies `WalletDetailsCubit`'s
/// `GeniusApi` dependency in four lines and throws loudly rather than
/// returning a silent null if the screen ever starts calling it. [_resolver]
/// is passed through `AssetsScreen(resolveMarketData:)` and is what keeps the
/// pump off Hive and off the network - without it the first box lookup throws
/// before a single row renders.
///
/// Coins are seeded through `WalletDetailsCubit(initialState:)` and NOT
/// through `injectMockCoins`, which flips the cubit into mock mode and would
/// route the page down its dev short-circuit instead of the branch that
/// ships.
///
/// **What this file does NOT cover**, so the on-device walk knows what it
/// owns:
///
///  * **The real network resolver.** `resolveAssetsMarketData` is never
///    called here; the id-resolution it duplicates from `coins_screen.dart` is
///    unexercised by any automated test.
///  * **S1 (loading) and S2 (error).** S1 mounts `Loading`, whose animation
///    never settles, so `pumpAndSettle` cannot be used on it and a
///    frame-counted pump would assert nothing the branch structure does not
///    already say. Both are branch-only code, walked on device.
///  * **`RefreshIndicator`'s pull gesture** - which scrollable captures the
///    drag is a live-screen question.
///  * **Mock mode's short-circuit branch** (`kDebugMode && cubit.mockMode`),
///    which is the path the dev bubble drives. Walked on device via the
///    `Unpriced` button.
///  * **Anything about how the page LOOKS** - contrast, the 48pt tap target,
///    the arrow's weight against the label. Those are W-9 on the walk.

/// [WalletDetailsCubit] takes a [GeniusApi] this screen never touches: the
/// only call is `getCoins()` behind pull-to-refresh and the retry button,
/// neither of which any test here triggers.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Coin _coin(String symbol, {required String name, double balance = 0}) =>
    Coin(name: name, symbol: symbol, iconPath: '', balance: balance);

/// A [CoinGeckoMarketData] carrying only the fields ordering and the row care
/// about; every other required field gets a harmless default.
CoinGeckoMarketData _md({required String symbol, required double price}) {
  final epoch = DateTime.fromMillisecondsSinceEpoch(0);
  return CoinGeckoMarketData(
    id: symbol.toLowerCase(),
    symbol: symbol.toLowerCase(),
    name: symbol,
    imageUrl: '',
    currentPrice: price,
    marketCap: 0,
    marketCapRank: 0,
    fullyDilutedValuation: 0,
    totalVolume: 0,
    high24h: 0,
    low24h: 0,
    priceChange24h: 0,
    priceChangePercentage24h: 0,
    marketCapChange24h: 0,
    marketCapChangePercentage24h: 0,
    circulatingSupply: 0,
    totalSupply: 0,
    maxSupply: null,
    ath: 0,
    athChangePercentage: 0,
    athDate: epoch,
    atl: 0,
    atlChangePercentage: 0,
    atlDate: epoch,
    lastUpdated: epoch,
    sparkline: null,
  );
}

/// The funded wallet: three priced holdings and one the feed does not cover.
///
/// Values are deliberately far apart so an assertion on the FULL order cannot
/// pass by accident: GNUS 85, USDC 250, ETH 3200, and UNLST unpriced.
final List<Coin> _wallet = [
  _coin('GNUS', name: 'GeniusAI', balance: 100),
  _coin('ETH', name: 'Ethereum', balance: 1),
  _coin('USDC', name: 'USD Coin', balance: 250),
  _coin('UNLST', name: 'Unlisted Token', balance: 42.5),
];

/// No `unlst` entry, deliberately - that absence is what makes UNLST an
/// unpriced holding.
final Map<String, CoinGeckoMarketData?> _prices = {
  'gnus': _md(symbol: 'GNUS', price: 0.85),
  'eth': _md(symbol: 'ETH', price: 3200),
  'usdc': _md(symbol: 'USDC', price: 1),
};

/// Every balance zero, which is the state Jakub's real wallet is in. Every
/// row ties at value 0, so the direction-independent tie-breaks are the whole
/// ordering.
final List<Coin> _zeroWallet = [
  _coin('USDC', name: 'USD Coin'),
  _coin('ETH', name: 'Ethereum'),
  _coin('GNUS', name: 'GeniusAI'),
  _coin('AAVE', name: 'Aave'),
];

final Map<String, CoinGeckoMarketData?> _zeroPrices = {
  'gnus': _md(symbol: 'GNUS', price: 0.85),
  'eth': _md(symbol: 'ETH', price: 3200),
  'usdc': _md(symbol: 'USDC', price: 1),
  'aave': _md(symbol: 'AAVE', price: 90),
};

/// Seven rows, so `take(5)` actually drops something and the cross-plan
/// contract test below is not tautological.
final List<Coin> _bigWallet = [
  _coin('GNUS', name: 'GeniusAI', balance: 100), // 85
  _coin('ETH', name: 'Ethereum', balance: 1), // 3200
  _coin('USDC', name: 'USD Coin', balance: 250), // 250
  _coin('WBTC', name: 'Wrapped Bitcoin', balance: 0.5), // 30000
  _coin('SOL', name: 'Solana', balance: 10), // 1500
  _coin('DAI', name: 'Dai', balance: 12), // 12
  _coin('MATIC', name: 'Polygon', balance: 1000), // 400
];

final Map<String, CoinGeckoMarketData?> _bigPrices = {
  'gnus': _md(symbol: 'GNUS', price: 0.85),
  'eth': _md(symbol: 'ETH', price: 3200),
  'usdc': _md(symbol: 'USDC', price: 1),
  'wbtc': _md(symbol: 'WBTC', price: 60000),
  'sol': _md(symbol: 'SOL', price: 150),
  'dai': _md(symbol: 'DAI', price: 1),
  'matic': _md(symbol: 'MATIC', price: 0.4),
};

/// The stub [AssetsMarketDataResolver]. `Future.value`, so one
/// `pumpAndSettle` is enough to get prices onto the page.
Future<Map<String, CoinGeckoMarketData?>> Function(List<Coin>) _resolver(
  Map<String, CoinGeckoMarketData?> prices,
) =>
    (_) => Future.value(prices);

Widget _host({
  List<Coin> coins = const [],
  Map<String, CoinGeckoMarketData?> prices = const {},
  WalletStatus status = WalletStatus.successful,
}) => BlocProvider(
  create: (_) => WalletDetailsCubit(
    initialState: WalletDetailsState(coins: coins, coinsStatus: status),
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: AssetsScreen(resolveMarketData: _resolver(prices)),
  ),
);

/// A PHONE, not the harness's stock 800x600. `/assets` is a mobile-only page
/// and Jakub reviews on an iPhone; the teardowns are not optional, because a
/// leaked surface changes every file that runs after this one.
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The rendered row order, read in TREE order.
///
/// The FULL list is compared everywhere below, never just the first element:
/// a first-element assertion passes against a list that is otherwise
/// scrambled, which is exactly the failure a sort test must catch.
List<String> _rendered(WidgetTester tester) => tester
    .widgetList<CoinCardRow>(find.byType(CoinCardRow))
    .map((r) => r.symbol)
    .toList();

const String _descLabel = 'Sort by value, highest first';
const String _ascLabel = 'Sort by value, lowest first';

void main() {
  testWidgets('the page is titled once, at page weight', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    expect(find.byType(GWPageHeader), findsOneWidget);
    // The 18px panel section title must NOT reach this page. Two "Assets" on
    // one screen at two sizes is the duplicate-title defect flagged on
    // Transactions, and this page is the one most likely to reproduce it.
    expect(find.byType(GWSectionTitle), findsNothing);
    expect(find.text('Assets'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('descending is the default and leads with the unpriced holding', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    // GNUS is pinned FIRST outright (Jakub, 2026-08-07), above even the
    // unpriced tier - so this also proves the pin outranks UNLST, not just the
    // priced rows. UNLST then sits above ETH, the LARGEST priced row, which is
    // the original point of this case and is unchanged.
    expect(_rendered(tester), ['GNUS', 'UNLST', 'ETH', 'USDC']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the sort toggle flips the rendered row order', (tester) async {
    _phone(tester);
    // Disposed explicitly at the END OF THE BODY, not via addTearDown: the
    // framework's leaked-handle check runs BEFORE tearDowns, so an
    // addTearDown(handle.dispose) fails every test that uses it - and leaks
    // semantics into the next test in the file, which is how the S3/S4 test
    // below was silently reading an enabled-semantics tree it never asked for.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    expect(_rendered(tester), ['GNUS', 'UNLST', 'ETH', 'USDC']);

    await tester.tap(find.bySemanticsLabel(_descLabel));
    await tester.pumpAndSettle();

    // The exact mirror: priced rows ascending, the unpriced tier LAST. A
    // toggle that left UNLST pinned to the top would fail here, which is the
    // point - a block that does not move makes the control read as broken.
    expect(_rendered(tester), ['GNUS', 'USDC', 'ETH', 'UNLST']);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('the toggle announces the direction it is currently in', (
    tester,
  ) async {
    _phone(tester);
    // Disposed explicitly at the END OF THE BODY, not via addTearDown: the
    // framework's leaked-handle check runs BEFORE tearDowns, so an
    // addTearDown(handle.dispose) fails every test that uses it - and leaks
    // semantics into the next test in the file, which is how the S3/S4 test
    // below was silently reading an enabled-semantics tree it never asked for.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    // The accessibility channel from D-4, not only the visual one: a
    // glyph-only direction is invisible to VoiceOver, and Jakub reviews on an
    // iPhone.
    expect(find.bySemanticsLabel(_descLabel), findsOneWidget);
    expect(find.bySemanticsLabel(_ascLabel), findsNothing);

    await tester.tap(find.bySemanticsLabel(_descLabel));
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(_ascLabel), findsOneWidget);
    expect(find.bySemanticsLabel(_descLabel), findsNothing);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('the search field filters the rendered rows', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    // Lower-case against a mixed-case name ('Ethereum') and an upper-case
    // symbol ('ETH'), so this covers the case-insensitivity as well as the
    // filtering.
    await tester.enterText(find.byType(GWSearchField), 'eth');
    await tester.pumpAndSettle();

    expect(_rendered(tester), ['ETH']);
    // The count kicker follows the filter. GWKicker upper-cases its label.
    expect(find.text('1 OF 4 ASSETS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('S3 and S4 are different empty states, and only S4 keeps the '
      'controls', (tester) async {
    _phone(tester);
    final handle = tester.ensureSemantics();

    // S4 first: coins present, query matches none.
    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(GWSearchField), 'zzz');
    await tester.pumpAndSettle();

    expect(_rendered(tester), isEmpty);
    expect(find.text('No assets found'), findsOneWidget);
    // The controls STAY MOUNTED: the query is the reason the list is empty and
    // the user needs the field to edit or clear it. This is the structural
    // half of the S3/S4 difference - the copy is only the visible half.
    expect(find.byType(GWSearchField), findsOneWidget);
    // BOTH controls, not just the field. The sort toggle stays too, so the
    // user is never left holding a filtered-to-nothing list with half the
    // controls that produced it.
    expect(find.bySemanticsLabel(_descLabel), findsOneWidget);
    expect(tester.takeException(), isNull);

    // S3: no coins at all.
    //
    // The bare pump in between is NOT ceremony. `_host` returns a
    // structurally identical tree either way, so pumping the second one
    // reuses the first `BlocProvider`'s element - and `create:` runs once per
    // element, so the cubit (and its four seeded coins) would survive. This
    // test passed its S3 half against the S4 wallet until the unmount was
    // added. Unmount first, and the second host builds a genuinely new cubit.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_host(coins: const []));
    await tester.pumpAndSettle();

    expect(find.text('No coins yet'), findsOneWidget);
    expect(find.text('No assets found'), findsNothing);
    expect(find.byType(GWEmptyState), findsOneWidget);
    // A search box over an empty wallet is a control that can only ever fail,
    // so it is not mounted at all.
    expect(find.byType(GWSearchField), findsNothing);
    expect(find.bySemanticsLabel(_descLabel), findsNothing);
    // The Receive / Buy GNUS pair, which S4 deliberately does NOT offer: the
    // user there is not out of assets, they are out of matches.
    expect(find.text('Receive'), findsOneWidget);
    expect(find.text('Buy GNUS'), findsOneWidget);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('the all-zero wallet renders rows, and the toggle does not '
      'reorder them', (tester) async {
    _phone(tester);
    // Disposed explicitly at the END OF THE BODY, not via addTearDown: the
    // framework's leaked-handle check runs BEFORE tearDowns, so an
    // addTearDown(handle.dispose) fails every test that uses it - and leaks
    // semantics into the next test in the file, which is how the S3/S4 test
    // below was silently reading an enabled-semantics tree it never asked for.
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(_host(coins: _zeroWallet, prices: _zeroPrices));
    await tester.pumpAndSettle();

    // NOT an empty state. Four real rows, every one reading $0.00, ordered
    // GNUS first then alphabetically. "A wallet with no funds is not a broken
    // wallet."
    expect(find.byType(GWEmptyState), findsNothing);
    const expected = ['GNUS', 'AAVE', 'ETH', 'USDC'];
    expect(_rendered(tester), expected);

    await tester.tap(find.bySemanticsLabel(_descLabel));
    await tester.pumpAndSettle();

    // The arrow flipped; the order did not. Correct per D-1 - nothing has
    // value to rank - and it is on the walk as W-4 so it is not mistaken for
    // a dead button.
    expect(find.bySemanticsLabel(_ascLabel), findsOneWidget);
    expect(_rendered(tester), expected);
    expect(tester.takeException(), isNull);
    handle.dispose();
  });

  testWidgets('the page order IS sortAssets, and its top 5 is the contract '
      'plan 25-01 must honour', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(coins: _bigWallet, prices: _bigPrices));
    await tester.pumpAndSettle();

    // Written out rather than derived, so this fails loudly if the shared rule
    // changes: WBTC 30000, ETH 3200, SOL 1500, MATIC 400, USDC 250, GNUS 85,
    // DAI 12.
    //
    // It DID fail loudly, exactly as designed, when GNUS was pinned first
    // (Jakub, 2026-08-07) - GNUS leads on 85 despite being sixth by value, and
    // USDC is the row the pin pushed off the five. Updated deliberately, with
    // the rule change, rather than relaxed.
    const topFive = ['GNUS', 'WBTC', 'ETH', 'SOL', 'MATIC'];

    final rows = _bigWallet
        .map(
          (c) => AssetRowData(
            name: c.name ?? '',
            symbol: c.symbol ?? '',
            balance: c.balance ?? 0,
            price: _bigPrices[c.symbol?.toLowerCase()]?.currentPrice ?? 0,
            hasMarketData: _bigPrices[c.symbol?.toLowerCase()] != null,
          ),
        )
        .toList();

    // The cross-plan contract, in one line: the dashboard's capped Assets
    // section is `sortAssets(rows, ascending: false).take(5)`, and this page
    // renders the same ordering authority. If 25-01 rolls its own ordering the
    // two surfaces disagree in front of the user (walk item W-7) - this test
    // is what makes the disagreement fail in CI instead.
    expect(
      sortAssets(rows, ascending: false).take(5).map((r) => r.symbol).toList(),
      topFive,
    );
    expect(_rendered(tester).take(5).toList(), topFive);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the page has exactly one scroll region', (tester) async {
    _phone(tester);
    await tester.pumpWidget(_host(coins: _wallet, prices: _prices));
    await tester.pumpAndSettle();

    // VERTICAL scrollables, counted rather than `findsOneWidget` on
    // `Scrollable`. The naive assertion is factually wrong and was corrected
    // rather than relaxed: every `EditableText` carries its own HORIZONTAL
    // Scrollable (axisDirection right, restorationId "editable") to scroll
    // text inside the input, so a page that mounts a search field can never
    // have exactly one Scrollable of any axis. That horizontal one is not a
    // page scroll region and cannot capture a vertical drag.
    //
    // The invariant this phase actually cares about is that nothing scrolls
    // VERTICALLY inside the page scroll - which is what a stray ListView,
    // GridView or nested SingleChildScrollView would add, and what the grep
    // gate in the plan guards from the other side.
    final verticalScrollables = tester
        .widgetList<Scrollable>(find.byType(Scrollable))
        .where(
          (s) =>
              s.axisDirection == AxisDirection.down ||
              s.axisDirection == AxisDirection.up,
        )
        .length;
    expect(
      verticalScrollables,
      1,
      reason: 'the page scroll must be the only vertical scroll region',
    );
    expect(tester.takeException(), isNull);
  });
}
