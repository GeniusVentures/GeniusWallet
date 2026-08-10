import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The three dashboard section caps of phase 25 - Assets 5, Transactions 5,
/// Markets 6 - plus the ONE structural assertion the phase actually exists for:
/// the Transactions panel installs no `Scrollable` of its own when the page
/// gives it unbounded height.
///
/// Jakub's complaint was a GESTURE, not a row count ("zamiast isc w dol to
/// scrolluje mi sie jakas sekcja"), and the caps are only half the answer. The
/// other half is that no panel may compete with the page for a drag, which is
/// what `group('one scroll')` below pins.
///
/// **What this file does NOT cover**, so the on-device walk knows what it owns:
///
///  * **Markets and Compute as widgets.** `DashboardMarkets` fetches in
///    `initState` and the Compute panel's real host needs a `GeniusApi`, so
///    neither is mountable here. Markets' cap is covered as the pure
///    [dashboardMarketRows] instead, and its hug branch is walked on device.
///  * **The gesture itself.** Which scrollable wins a drag is a live-screen
///    question; the closest a widget test gets is "there is no second
///    scrollable to lose to", which is exactly what is asserted below.
///  * **The `contentTopInset` rhythm**, which lives in
///    `test/components/gw_section_title_rhythm_test.dart`.

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

Transaction _tx({required DateTime at, String hash = '0xabc'}) => Transaction(
  hash: hash,
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: at,
  transactionDirection: TransactionDirection.sent,
  fees: '0.001',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: TransactionType.transfer,
);

CoinGeckoCoin _coinGecko(String symbol) =>
    CoinGeckoCoin(id: symbol.toLowerCase(), symbol: symbol, name: symbol);

/// The six the dashboard is meant to show, in the order
/// `topCoinsByCapitalization` already yields them, plus the two
/// `getDashboardMarketCoins()`'s `.take(8)` keeps as fallback.
final List<CoinGeckoCoin> _eightFetched = [
  _coinGecko('GNUS'),
  _coinGecko('BTC'),
  _coinGecko('ETH'),
  _coinGecko('XRP'),
  _coinGecko('BNB'),
  _coinGecko('SOL'),
  _coinGecko('TRX'),
  _coinGecko('DOGE'),
];

Set<String> _priced(Iterable<String> symbols) =>
    symbols.map((s) => s.toLowerCase()).toSet();

List<String> _symbols(List<CoinGeckoCoin> coins) =>
    coins.map((c) => c.symbol).toList();

/// [WalletDetailsCubit] takes a [GeniusApi] `CoinsScreen` only touches through
/// `getCoins()`, which nothing here triggers. Same four-line apparatus
/// `assets_screen_test.dart` uses, and it throws loudly rather than returning a
/// silent null if that ever stops being true.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Coin _coin(String symbol, {required double balance}) =>
    Coin(name: symbol, symbol: symbol, iconPath: '', balance: balance);

/// A real 390pt iPhone width at 3x density - makes `compact` true. Every host
/// in this file otherwise runs on the harness's default 800x600 surface,
/// which sits above the 768 breakpoint (`transaction_row_test.dart`'s "phone
/// window" tests hit the same gap), so nothing here exercises the compact
/// branch without it.
void _setPhoneWidth(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

// ---------------------------------------------------------------------------

void main() {
  group('Markets - dashboardMarketRows', () {
    test('caps at six and keeps the incoming order', () {
      final rows = dashboardMarketRows(
        _eightFetched,
        _priced(['gnus', 'btc', 'eth', 'xrp', 'bnb', 'sol', 'trx', 'doge']),
      );

      expect(rows.length, kDashboardMarketsCap);
      // The six Jakub named, in the order he named them. They come out this way
      // for free because `topCoinsByCapitalization`'s first six already are
      // this list - there is no re-ordering step to get wrong.
      expect(_symbols(rows), ['GNUS', 'BTC', 'ETH', 'XRP', 'BNB', 'SOL']);
    });

    test('drops coins with no market data', () {
      final rows = dashboardMarketRows(
        _eightFetched,
        _priced(['gnus', 'btc', 'eth']),
      );
      expect(_symbols(rows), ['GNUS', 'BTC', 'ETH']);
    });

    // THE ordering assertion: the cap is taken AFTER the availability filter.
    // Taken before, XRP being unpriced would render FIVE rows with a silent
    // hole where the sixth should be, instead of falling back on TRX.
    test('an unpriced coin is backfilled, not left as a hole', () {
      final rows = dashboardMarketRows(
        _eightFetched,
        _priced(['gnus', 'btc', 'eth', 'bnb', 'sol', 'trx', 'doge']),
      );

      expect(rows.length, kDashboardMarketsCap);
      expect(_symbols(rows), ['GNUS', 'BTC', 'ETH', 'BNB', 'SOL', 'TRX']);
    });

    test('returns fewer than the cap without complaint', () {
      expect(
        dashboardMarketRows(_eightFetched, _priced(['gnus'])),
        hasLength(1),
      );
      expect(dashboardMarketRows(_eightFetched, const {}), isEmpty);
      expect(dashboardMarketRows(const [], _priced(['gnus'])), isEmpty);
    });
  });

  group('Transactions - groupTransactionsByDay(limit:)', () {
    final DateTime now = DateTime(2026, 8, 7, 12);
    DateTime dayAt(int daysAgo, int hour) =>
        DateTime(now.year, now.month, now.day - daysAgo, hour);

    /// Eleven transactions over four days, handed over in a deliberately
    /// SCRAMBLED order so "the first five the caller gave us" and "the five
    /// most recent" cannot be the same list.
    List<Transaction> eleven() => [
      _tx(at: dayAt(3, 9), hash: 'old-a'),
      _tx(at: dayAt(0, 9), hash: 'new-e'),
      _tx(at: dayAt(3, 10), hash: 'old-b'),
      _tx(at: dayAt(0, 11), hash: 'new-d'),
      _tx(at: dayAt(2, 9), hash: 'old-c'),
      _tx(at: dayAt(1, 15), hash: 'new-c'),
      _tx(at: dayAt(2, 10), hash: 'old-d'),
      _tx(at: dayAt(1, 16), hash: 'new-b'),
      _tx(at: dayAt(2, 11), hash: 'old-e'),
      _tx(at: dayAt(0, 14), hash: 'new-a'),
      _tx(at: dayAt(3, 11), hash: 'old-f'),
    ];

    test('no limit is byte-identical to today for every existing caller', () {
      final days = groupTransactionsByDay(eleven(), now: now);
      expect(days.map((d) => d.items.length).fold(0, (a, b) => a + b), 11);
      expect(days, hasLength(4));
    });

    test('limit 5 keeps the FIVE MOST RECENT, not the first five given', () {
      final days = groupTransactionsByDay(eleven(), now: now, limit: 5);
      final kept = [for (final d in days) ...d.items.map((t) => t.hash)];

      expect(kept, hasLength(5));
      // Newest first, across day boundaries. `old-*` appearing anywhere here
      // means the limit ran before the sort.
      expect(kept, ['new-a', 'new-d', 'new-e', 'new-b', 'new-c']);
    });

    test('a day whose every item fell outside the limit does not appear', () {
      final days = groupTransactionsByDay(eleven(), now: now, limit: 5);
      // Four days exist; the five survivors span only two of them, and the
      // other two must be ABSENT rather than present-and-empty.
      expect(days, hasLength(2));
      expect(days.map((d) => d.label), ['Today', 'Yesterday']);
      for (final day in days) {
        expect(day.items, isNotEmpty);
      }
    });

    test('a limit larger than the list is a no-op', () {
      expect(
        groupTransactionsByDay(eleven(), now: now, limit: 50),
        hasLength(4),
      );
    });
  });

  group('one scroll - TransactionsSlimView under each height contract', () {
    Widget host({required double? height, bool page = false}) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 900,
            height: 600,
            child: height == null
                // Unbounded height, the shape `compute_panel_height_test.dart`
                // already uses to hand a widget the constraint the uncapped
                // one-column dashboard gives it.
                ? SingleChildScrollView(
                    child: TransactionsSlimView(
                      page: page,
                      transactions: _manyTx(),
                    ),
                  )
                : SizedBox(
                    height: height,
                    child: TransactionsSlimView(
                      page: page,
                      transactions: _manyTx(),
                    ),
                  ),
          ),
        ),
      ),
    );

    testWidgets('unbounded: five rows, no throw, and NO scrollable of its own', (
      tester,
    ) async {
      await tester.pumpWidget(host(height: null));

      expect(find.byType(TransactionRow), findsNWidgets(5));
      expect(tester.takeException(), isNull);

      // THE assertion this whole phase is about, and the only one standing
      // between a future edit and a fifth nested scroll area on the mobile
      // dashboard. A panel that installs its own Scrollable consumes the drag
      // that started inside it and the page never moves - which is precisely
      // what Jakub reported. Row counts can be restored by a dozen wrong fixes;
      // this cannot.
      expect(
        find.descendant(
          of: find.byType(TransactionsSlimView),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
    });

    testWidgets('bounded: still fills and scrolls, still throws nothing', (
      tester,
    ) async {
      await tester.pumpWidget(host(height: 400));

      // The DESKTOP contract, unchanged: a bounded host still gets the
      // Expanded + ListView branch. The cap applies on both, because the panel
      // is the same five-row preview wherever it is mounted.
      expect(tester.takeException(), isNull);
      expect(
        find.descendant(
          of: find.byType(TransactionsSlimView),
          matching: find.byType(Scrollable),
        ),
        findsOneWidget,
      );
      expect(find.byType(TransactionRow), findsNWidgets(5));
    });

    testWidgets('page: true is uncapped in the unbounded branch', (
      tester,
    ) async {
      await tester.pumpWidget(host(height: null, page: true));

      // The destination the panel's `View all` points at shows everything.
      expect(find.byType(TransactionRow), findsNWidgets(8));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty scope offers no View all and no filter control', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: const Scaffold(
            body: Center(
              child: SizedBox(
                width: 900,
                height: 600,
                child: SingleChildScrollView(
                  child: TransactionsSlimView(transactions: []),
                ),
              ),
            ),
          ),
        ),
      );

      // Viewing all of nothing is the same offer the app cannot honour that
      // hiding the filter bar on an empty scope already refuses to make.
      expect(find.byType(GWViewAllLink), findsNothing);
      // And the never-transacted empty state still renders under the title.
      expect(find.text(emptyTransactionsTitle), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // The pair below pins the cap at PHONE width, from both sides - capped
    // panel five rows, uncapped page all eight - so `compact` is exercised
    // (see `_setPhoneWidth`) rather than only the harness's 800px default.
    //
    // These two used to be three, and they used to assert the cap THROUGH
    // `endOfTransactionsLabel`: the terminus was gated on `limit == null`, so
    // its absence proved the panel was capped and its presence proved the page
    // was not. Jakub removed the label on 2026-08-09, so the row counts below
    // now carry the cap on their own. The third test, which pinned the
    // terminus's own type scale to `bodySm`, has NO successor - its entire
    // subject is gone.
    testWidgets('phone: the panel caps at five rows', (tester) async {
      _setPhoneWidth(tester);
      await tester.pumpWidget(host(height: null));

      // Eight transactions in, five rows out - the rest live behind
      // `View all`.
      expect(find.byType(TransactionRow), findsNWidgets(5));
      expect(find.byType(GWViewAllLink), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('phone: the uncapped page renders every row, and offers no '
        'View all', (tester) async {
      _setPhoneWidth(tester);
      await tester.pumpWidget(host(height: null, page: true));

      expect(find.byType(TransactionRow), findsNWidgets(8));
      // The other half of the cap: the page IS the destination, so there is
      // nothing left to view all of. A `View all` here would mean the page had
      // silently taken the panel's limit.
      expect(find.byType(GWViewAllLink), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('Assets - the dashboard panel is the head of the /assets list', () {
    /// Seven holdings with distinct balances, handed over in an order that is
    /// neither sorted nor GNUS-first, so no accidental pass is possible.
    ///
    /// Market data never arrives in this harness - `CoinsScreen` fetches it
    /// from its `BlocListener`, which fires on a state CHANGE and this cubit is
    /// seeded already-successful. So every row is an UNPRICED HOLDING, the tier
    /// `compareAssetsByValue` ranks by BALANCE descending. That is a real
    /// branch of the shared comparator, not a degenerate one, and it is the
    /// branch a hand-rolled "GNUS first, then fetch order" sort fails.
    final List<Coin> wallet = [
      _coin('AAA', balance: 3),
      _coin('GNUS', balance: 5),
      _coin('BBB', balance: 7),
      _coin('CCC', balance: 1),
      _coin('DDD', balance: 6),
      _coin('EEE', balance: 2),
      _coin('FFF', balance: 4),
    ];

    Widget host({required Function(Coin)? onCoinSelected}) => MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: BlocProvider<WalletDetailsCubit>(
          create: (_) => WalletDetailsCubit(
            initialState: WalletDetailsState(
              coins: wallet,
              coinsStatus: WalletStatus.successful,
            ),
            geniusApi: _UnusedApi(),
            networkTokensProvider: NetworkTokensProvider(),
          ),
          child: SingleChildScrollView(
            child: SizedBox(
              width: 900,
              child: CoinsScreen(onCoinSelected: onCoinSelected),
            ),
          ),
        ),
      ),
    );

    testWidgets('renders exactly five rows, ordered by the shared comparator', (
      tester,
    ) async {
      await tester.pumpWidget(host(onCoinSelected: null));
      await tester.pump();

      expect(find.byType(CoinCardRow), findsNWidgets(kDashboardAssetsCap));

      final rows = tester
          .widgetList<CoinCardRow>(find.byType(CoinCardRow))
          .map((r) => r.symbol)
          .toList();
      // Balance descending under a pinned GNUS, and the two smallest holdings
      // fell off the panel. GNUS at 5 leads despite being third by value:
      // Jakub restored the absolute pin on 2026-08-07, after phase 25 had
      // demoted it to a tie-break as the price of agreeing with `/assets`.
      // The pin now lives in `compareAssetsByValue` itself, so BOTH surfaces
      // carry it and the agreement survives. If this ever reads GNUS anywhere
      // but first, the panel has stopped using that comparator and the two
      // surfaces have diverged.
      expect(rows, ['GNUS', 'BBB', 'DDD', 'FFF', 'AAA']);

      // The link to the rest.
      expect(find.byType(GWViewAllLink), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a coin PICKER reuse stays uncapped and carries no link', (
      tester,
    ) async {
      await tester.pumpWidget(host(onCoinSelected: (_) {}));
      await tester.pump();

      // Picking from a truncated list is not a preview, it is a missing coin.
      expect(find.byType(CoinCardRow), findsNWidgets(wallet.length));
      expect(find.byType(GWViewAllLink), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });
}

/// Eight transactions across three days - more than the panel's cap of five, so
/// the cap is doing something, and enough days that truncation has to fall
/// inside a day rather than tidily on a boundary.
List<Transaction> _manyTx() {
  final DateTime now = DateTime.now();
  DateTime at(int daysAgo, int hour) =>
      DateTime(now.year, now.month, now.day - daysAgo, hour);
  return [
    _tx(at: at(0, 9), hash: 'a'),
    _tx(at: at(0, 10), hash: 'b'),
    _tx(at: at(0, 11), hash: 'c'),
    _tx(at: at(1, 9), hash: 'd'),
    _tx(at: at(1, 10), hash: 'e'),
    _tx(at: at(1, 11), hash: 'f'),
    _tx(at: at(2, 9), hash: 'g'),
    _tx(at: at(2, 10), hash: 'h'),
  ];
}
