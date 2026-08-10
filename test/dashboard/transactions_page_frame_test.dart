import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/transactions_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The `/transactions` PAGE FRAME: `GWPageHeader` + the `xl` width cap + the
/// gutter, as [TransactionsScreen] actually builds them.
///
/// **This file pumps the REAL screen**, not a hand-copied replica of its tree.
/// The plan proposed the replica — pump the frame's widgets directly with a
/// `TransactionsSlimView(page: true)` standing in for the bloc-fed branch — to
/// avoid the provider apparatus below. That was measured and rejected: a
/// replica cannot fail for the reason this file exists. With the replica in
/// place, changing `GeniusBreakpoints.xl` to `xxl` in `transactions_screen.dart`
/// leaves all four tests GREEN, because no test ever reads that file. The
/// apparatus that buys a real mutation is eleven lines ([_host]) and one stub
/// ([_UnusedApi]), and it also covers the two pass-throughs 15-05 added, which
/// the replica skipped entirely.
///
/// What this file still does NOT cover, for 15-06's walk to judge:
///
///  * **The SGNUS branch.** Every pump here leaves `selectedWallet` null, so
///    `isSgnusWallet` is false and [TransactionsStream] mounts. Reaching
///    [SgnusTransactionsScreen] needs an `AppBloc`, a `GeniusApi` in the tree
///    and a live stream controller — apparatus far past what a frame assertion
///    earns. Its `page` pass-through is unexercised by any automated test.
///  * **`RefreshIndicator`'s pull gesture.** Preserved untouched by this plan,
///    but which scrollable now captures the drag is a live-screen question.
///
/// Harness trap, the same one `transaction_filter_rail_test.dart` documents:
/// `flutter_test`'s surface is **800x600 logical** and nothing in this repo
/// changes it. This file's entire subject is a 1280 cap, so on the default
/// surface the content measures 776 — over `medium` (768) by 8px, entirely by
/// accident, which would let a loose "wider than medium" assertion pass against
/// a completely unmodified widget while `xl` and `xxl` stayed
/// indistinguishable. Every pump goes through [_surface], and its teardowns are
/// not optional: a leaked surface changes every file that runs after this one.

Transaction _tx({
  TransactionType? type,
  TransactionDirection direction = TransactionDirection.sent,
}) => Transaction(
  hash: '0xabc',
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: DateTime(2026, 7, 22),
  transactionDirection: direction,
  fees: '0.001',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: type,
);

/// Three rows across three type filters — enough for a non-empty scope (which
/// is what makes the rail, and therefore the second card, appear) and short
/// enough not to fight the harness's wide fallback font at 360px.
List<Transaction> _some() => [
  _tx(type: TransactionType.transfer),
  _tx(type: TransactionType.mint),
  _tx(type: TransactionType.escrow),
];

/// [WalletDetailsCubit] takes a [GeniusApi] it never touches on this screen —
/// the only call is `getCoins()` behind the pull-to-refresh, which no test here
/// triggers. `noSuchMethod` forwarding to `super` satisfies the type with four
/// lines and no test dependency, and throws loudly if that ever stops being
/// true rather than returning a silent null.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// The real screen, with the two blocs its `BlocBuilder`s demand.
///
/// `selectedWallet` is left null, so the branch is the non-SGNUS one — see the
/// coverage note in the header comment.
Widget _host({List<Transaction>? txs}) => MultiBlocProvider(
  providers: [
    BlocProvider(
      create: (_) => WalletDetailsCubit(
        geniusApi: _UnusedApi(),
        networkTokensProvider: NetworkTokensProvider(),
      ),
    ),
    BlocProvider(create: (_) => TransactionsCubit(initial: txs ?? _some())),
  ],
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: const TransactionsScreen(),
  ),
);

/// Sets the window to [width] x [height] LOGICAL pixels and tears it back down.
void _surface(WidgetTester tester, double width, [double height = 900]) {
  tester.view.physicalSize = Size(width * 3, height * 3); // logical x dpr
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// The `/assets` page, the reference every other page title is measured
/// against. Same two-piece apparatus `assets_screen_test.dart` documents: the
/// unused api, plus a stub resolver that keeps the pump off Hive and off the
/// network. One coin, because a funded wallet is the state the header sits
/// above on the phone.
Widget _assetsHost() => BlocProvider(
  create: (_) => WalletDetailsCubit(
    initialState: const WalletDetailsState(
      coins: [Coin(name: 'GeniusAI', symbol: 'GNUS', iconPath: '', balance: 1)],
      coinsStatus: WalletStatus.successful,
    ),
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: AssetsScreen(resolveMarketData: (_) async => const {}),
  ),
);

/// A page header's vertical frame, all three numbers relative to the header's
/// own top so a different page gutter cannot leak into the comparison.
///
/// A record rather than three loose doubles: `expect(a, b)` then reports all
/// three at once when they disagree, instead of failing on the first.
typedef _Geometry = ({double headerHeight, double titleTop, double contentTop});

_Geometry _headerGeometry(WidgetTester tester, String title, Finder content) {
  final header = find.byType(GWPageHeader);
  final double top = tester.getTopLeft(header).dy;
  return (
    headerHeight: tester.getSize(header).height,
    titleTop: tester.getTopLeft(find.text(title)).dy - top,
    contentTop: tester.getTopLeft(content).dy - top,
  );
}

/// The frame's content box, measured at BOTH ends of its `Column`: the header
/// above and the branch below. Both are direct children of the stretched
/// `Column` inside the `ConstrainedBox`, so both report the capped width — and
/// reading both means a cap applied to only one of them cannot hide.
double _contentWidth(WidgetTester tester) {
  final header = tester.getSize(find.byType(GWPageHeader)).width;
  final body = tester.getSize(find.byType(TransactionsSlimView)).width;
  expect(body, header, reason: 'header and branch must share one content box');
  return header;
}

void main() {
  testWidgets('the page is titled once, at page weight', (tester) async {
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(find.byType(GWPageHeader), findsOneWidget);
    // The panel's 18px section title must NOT reach the page. If it does, the
    // `page` flag failed somewhere along TransactionsScreen -> TransactionsStream
    // -> TransactionsSlimView, which is the single most likely wiring mistake
    // in this plan, and the user sees the word twice at two sizes.
    expect(find.byType(GWSectionTitle), findsNothing);
    expect(find.text('Transactions'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the content stops at the xxl cap', (tester) async {
    // A window WIDER than the cap, so the cap actually binds. At the cap itself
    // it would not bind (xxl - 24 gutter < xxl) and the test would silently
    // measure the viewport instead — the class of dead assertion the
    // plan-checker caught elsewhere in this phase.
    _surface(tester, 2000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // EXACTLY xxl (1536), not merely "wider than medium". The full cap and not
    // cap-24: the Padding is OUTSIDE the ConstrainedBox, so the cap binds the
    // CONTENT and the 12px gutter is additive on top of it. Nested the other
    // way this would read xxl-24, which is what makes this number the order test
    // as well as the cap test. The cap was 1280 (xl), briefly 1600 (sketch
    // 024-C), then narrowed to xxl (1536) to unify Transactions/Markets/News on
    // one frame (Jakub's call, commit 99a8913) — kept in sync with
    // transactions_screen.dart's GeniusBreakpoints.xxl.
    expect(
      _contentWidth(tester),
      closeTo(GeniusBreakpoints.xxl, 1),
      reason: 'expected the xxl cap to bind at a 2000px window',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('below the cap the content follows the viewport', (tester) async {
    _surface(tester, 1000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // The other end of the same property: a max-width constrains only a WIDER
    // viewport, so at 1000 the ConstrainedBox does nothing and the content is
    // viewport minus the two 12px gutters. A frame that measured the full xxl
    // cap here would be overflowing the window, not filling it.
    expect(
      _contentWidth(tester),
      closeTo(1000 - 24, 1),
      reason: 'expected viewport minus the 12px gutters at a 1000px window',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('a narrow viewport keeps its gutter', (tester) async {
    _surface(tester, 360, 800);
    // EMPTY scope here, and the reason is a measurement rather than a
    // convenience. Below 768 the page hands off to the PANEL, whose title row
    // (`GWSectionTitle` + the compact filter bar) does not fit a narrow harness
    // window: measured through this very host at 320/328/336/344/360/380/400 it
    // overflows by 93/85/77/69/53/33/13 — exactly 1:1 with width, clearing at
    // **413**. That is `_panel`'s row, which this plan does not touch, and it
    // is a harness-font artifact: the fallback font draws roughly one em per
    // character, so 'Transactions' costs ~216px here against real Inter's ~110.
    // It also got 8px BETTER under this plan, not worse — the old
    // `EdgeInsets.all(16)` left 328px of content and overflowed by 85.
    // An empty scope drops the filter bar entirely (15-03's `scoped.isEmpty`
    // guard), which removes that unrelated red without weakening anything
    // below: the gutter is measured on `GWPageHeader`, which sits ABOVE the
    // branch and renders identically either way. Logged for 15-06 in
    // `deferred-items.md`.
    await tester.pumpWidget(_host(txs: const []));
    await tester.pumpAndSettle();

    // At 360 the xxl cap is inert, so this gutter is the Padding's alone.
    // Delete the Padding and the content sits on the window bezel — the defect
    // the 06-01 walk found in `wallet_creation_screen.dart`. 6, not 12: the
    // gutter halves below 768. Above it, the two cap tests pin 12.
    expect(
      tester.getTopLeft(find.byType(GWPageHeader)).dx,
      closeTo(6, 0.01),
      reason: 'expected a gutter to survive a viewport under the cap',
    );
    expect(_contentWidth(tester), closeTo(360 - 12, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('rows sit on a card, not on raw surface-base', (tester) async {
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    // Two: the filter rail's card and the list's card. On the dashboard the
    // identical slim view is wrapped by dashboard_screen.dart's own container;
    // on the page the wrapping is the slim view's own, and a page that renders
    // it bare hangs rows on raw surface-base (the ROADMAP's defect #3).
    expect(find.byType(DashboardScrollContainer), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the cards hug their content — no full-height stretch', (
    tester,
  ) async {
    // Sketch 023-V3. Before it, the Row used CrossAxisAlignment.stretch and
    // both cards were forced to the window height, leaving two tall empty
    // boxes below eleven rows. The page now scrolls and the cards end at their
    // content. A tall window with a short list is the exact case that exposed
    // the bug: if stretch returns, the list card fills a 2000px window instead
    // of hugging its ~700px of rows.
    _surface(tester, 1600, 2000);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    final listCard = tester.getSize(find.byType(DashboardScrollContainer).last);
    // Well under the 2000px window and comfortably under the 496 floor's worst
    // case — a stretched card would be ~1900+. The floor keeps it >= 496 so the
    // pair stays aligned; the ceiling here is what proves it is not stretched.
    expect(
      listCard.height,
      lessThan(1200),
      reason: 'the list card must hug its rows, not fill the window',
    );
    expect(
      listCard.height,
      greaterThanOrEqualTo(496),
      reason: 'the list card floor keeps it paired with the rail',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the page shows no running total anywhere', (tester) async {
    // Removed on the walk (both the panel footer and the rail summary). A
    // "N transactions" line reappearing is the regression this guards: match
    // the digit-plus-word shape rather than an exact count so it catches the
    // footer, the old All row and the R4 summary alike.
    _surface(tester, 1600);
    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();

    expect(
      find.textContaining(RegExp(r'\d+ transactions')),
      findsNothing,
      reason: 'no footer count, no All summary — neither presentation totals',
    );
    expect(tester.takeException(), isNull);
  });

  // ── The phone page (quick task 260806-hfe) ────────────────────────────────
  //
  // These settle like every other test in the file. Until 2026-08-09 they
  // could not: below 768 the page wrapped its body in `GWMeshBackground`,
  // whose controller `..repeat()`s forever, so `pumpAndSettle` timed out. The
  // mesh is gone - the phone page now sits on the same flat `surfaceBase`
  // canvas Assets does.

  testWidgets('phone: a never-transacted wallet gets the empty state, and no '
      'filter control', (tester) async {
    _surface(tester, 360, 800);
    await tester.pumpWidget(_host(txs: const []));
    await tester.pumpAndSettle();

    // BRANCH 1. The page title stays — only the panel's duplicate went.
    expect(find.byType(GWPageHeader), findsOneWidget);
    expect(find.byType(GWEmptyState), findsOneWidget);
    expect(find.text(emptyTransactionsTitle), findsOneWidget);

    // 15-03's rule, carried onto the header: a control that filters an empty
    // set is an offer the app cannot honour. The GLYPH is what is asserted -
    // the trigger widget is always handed to the header, and hides itself by
    // painting nothing.
    expect(
      find.byIcon(Icons.filter_alt_outlined),
      findsNothing,
      reason: 'the filter trigger must be hidden entirely on an empty scope',
    );
    // And the track it replaced must not come back with it: sketch 195 took
    // the flat filter row out of the card for good.
    expect(find.byType(GWControlTrack), findsNothing);
    // The narrow page must never re-emit the panel's own title (the duplicate
    // "Transactions" this phase removed), empty scope included.
    expect(find.byType(GWSectionTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'phone: the filter trigger is a real touch target in the header',
    (tester) async {
      // 320 is the stress case, not 360: the header now carries a title AND a
      // control, so this is where they compete for the row.
      _surface(tester, 320, 800);
      await tester.pumpWidget(_host());
      await tester.pumpAndSettle();

      // 48 WIDE and 32 TALL. The width is the tap target - it clears 48dp
      // Android and 44pt iOS on that axis. The height is capped at the title
      // line's own 32 so the trigger cannot set the header row's height; the
      // geometry test below is what that number is FOR, and the trade it costs
      // (32 is under Apple's 44pt vertically, though it clears WCAG 2.2
      // SC 2.5.8's 24x24 floor) is stated at `TransactionsFilterTrigger`.
      //
      // It is the WIRING assertion as much as the size one: the trigger is
      // mounted by `TransactionsScreen`, so nothing below `_host` can produce
      // it.
      expect(
        tester.getSize(find.byType(TransactionsFilterTrigger)),
        const Size(48, 32),
        reason: 'the header trigger must not outgrow the title line',
      );
      // And it must still FIT beside the title at 320 without overflowing.
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('phone: the page title sits exactly where Assets puts its own', (
    tester,
  ) async {
    // THE regression this test exists for, and it is measured rather than
    // eyeballed. `GWPageHeader` lays `trailing` out beside the identity block
    // with `CrossAxisAlignment.center`, so a trailing TALLER than the 32px
    // title line sets the identity row's height and centres the title inside
    // it. With the filter trigger at 48x48 this page measured a 64px header
    // with its title 8px down, while every other page - Assets, Crypto News -
    // measured 48 with the title at 0. Jakub saw the 8px on the phone.
    //
    // Both screens are pumped HERE rather than the numbers being copied from
    // `assets_screen_test.dart`, so the assertion is a comparison and not a
    // pair of literals that can drift apart silently.
    _surface(tester, 390, 844);

    await tester.pumpWidget(_host());
    await tester.pumpAndSettle();
    final _Geometry transactions = _headerGeometry(
      tester,
      'Transactions',
      find.byType(TransactionsSlimView),
    );

    await tester.pumpWidget(_assetsHost());
    await tester.pumpAndSettle();
    final _Geometry assets = _headerGeometry(
      tester,
      'Assets',
      find.byType(DashboardScrollContainer).first,
    );

    expect(
      transactions,
      assets,
      reason: 'the two page headers must agree on height, title and content',
    );
    // And the absolute numbers, so a change that moved BOTH pages together
    // still reddens: a 32px title line plus `GWPageHeader`'s own space8 gap.
    expect(transactions.headerHeight, 48);
    expect(transactions.titleTop, 0);
    expect(transactions.contentTop, 48);
    expect(tester.takeException(), isNull);
  });
}
